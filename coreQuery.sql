-- 1) Insert data (DML INSERT)
-- user daftar
INSERT INTO users (full_name, email, phone)
VALUES (?, ?, ?);

-- Booking dibuat (pending)
INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NULL, 'not_uploaded', NULL);

-- Buat 2 Invoice
INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  (?, 'DP',   ?, NOW(), NULL, 'unpaid'),
  (?, 'Full', ?, NOW(), NULL, 'unpaid');


-- 2) Update status otomatis (dengan CASE WHEN)
-- Update status booking berdasarkan kondisi pembayaran + kTP
UPDATE bookings b
LEFT JOIN (
  SELECT
    booking_id,
    SUM(CASE WHEN invoice_type='DP'   AND status='paid' THEN 1 ELSE 0 END) AS dp_paid_count,
    SUM(CASE WHEN invoice_type='Full' AND status='paid' THEN 1 ELSE 0 END) AS full_paid_count
  FROM invoices
  GROUP BY booking_id
) x ON x.booking_id = b.booking_id
SET b.status = CASE
  WHEN b.status = 'cancelled' THEN 'cancelled'
  WHEN b.ktp_verification_status = 'verified'
       AND COALESCE(x.dp_paid_count,0) >= 1
       AND COALESCE(x.full_paid_count,0) >= 1
       AND CURDATE() >= b.start_date
       AND CURDATE() <  b.end_date
    THEN 'active'
  WHEN COALESCE(x.dp_paid_count,0) >= 1
    THEN 'dp_paid'
  ELSE 'pending'
END
WHERE b.booking_id = ?;

-- Update Status room otomatis berdasarkan kondisi booking & cleaning
UPDATE rooms r
LEFT JOIN bookings b
  ON b.room_id = r.room_id AND b.status IN ('pending','dp_paid','active','completed')
LEFT JOIN room_cleaning rc
  ON rc.room_id = r.room_id AND rc.booking_id = b.booking_id
SET r.status = CASE
  WHEN b.status = 'active' THEN 'occupied'
  WHEN b.status IN ('pending','dp_paid') THEN 'booked'
  WHEN b.status = 'completed' AND rc.status IN ('scheduled','in_progress') THEN 'cleaning'
  WHEN b.status = 'completed' AND rc.status = 'completed' THEN 'available'
  WHEN b.status IS NULL THEN 'available'
  ELSE r.status
END
WHERE r.room_id = ?;

-- 3) Join antar tabel (untuk tampilan/dashboard)
-- Booking list (admin view)
SELECT
  b.booking_id,
  u.full_name AS customer_name,
  l.name AS location,
  r.room_name,
  b.start_date, b.end_date, b.total_days,
  b.dp_amount, b.total_price,
  b.status,
  b.created_at
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN rooms r ON r.room_id = b.room_id
JOIN locations l ON l.location_id = r.location_id
ORDER BY b.created_at DESC;

-- Cleaning task list (staff view)
SELECT
  rc.cleaning_id,
  l.name AS location,
  r.room_name,
  e.full_name AS staff_name,
  rc.cleaning_date,
  rc.status
FROM room_cleaning rc
JOIN rooms r ON r.room_id = rc.room_id
JOIN locations l ON l.location_id = r.location_id
JOIN employees e ON e.employee_id = rc.employee_id
WHERE rc.status IN ('scheduled','in_progress')
ORDER BY rc.cleaning_date ASC;

-- 4) Aggregate (COUNT, SUM, AVG)
-- COUNT bookings per status
SELECT status, COUNT(*) AS total
FROM bookings
GROUP BY status;

-- SUM revenue (yang sudah paid)
SELECT
  SUM(i.amount) AS total_paid_revenue
FROM invoices i
WHERE i.status = 'paid';

-- AVG lama menginap (days)
SELECT
  AVG(total_days) AS avg_stay_days
FROM bookings
WHERE status IN ('active','completed');

-- Occupancy rate per location
SELECT
  l.name AS location,
  SUM(CASE WHEN r.status IN ('booked','occupied','cleaning') THEN 1 ELSE 0 END) AS not_available_rooms,
  COUNT(*) AS total_rooms
FROM rooms r
JOIN locations l ON l.location_id = r.location_id
GROUP BY l.location_id, l.name;

-- 5) Stored Procedures
DELIMITER $$

CREATE PROCEDURE sp_complete_checkout_least_workload(IN p_booking_id INT)
BEGIN
  DECLARE v_room_id INT;
  DECLARE v_employee_id INT;

  START TRANSACTION;

  -- Ambil room_id dari booking
  SELECT room_id
  INTO v_room_id
  FROM bookings
  WHERE booking_id = p_booking_id
  FOR UPDATE;

  IF v_room_id IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Booking not found';
  END IF;

  -- Update booking -> completed
  UPDATE bookings
  SET status = 'completed'
  WHERE booking_id = p_booking_id;

  -- Update room -> cleaning
  UPDATE rooms
  SET status = 'cleaning'
  WHERE room_id = v_room_id;

  -- Pilih staff dengan beban kerja aktif paling sedikit
  SELECT e.employee_id
  INTO v_employee_id
  FROM employees e
  JOIN rooms r ON r.location_id = e.location_id
  LEFT JOIN room_cleaning rc
    ON rc.employee_id = e.employee_id
    AND rc.status IN ('scheduled','in_progress')
  WHERE r.room_id = v_room_id
    AND e.role = 'Cleaning Staff'
  GROUP BY e.employee_id
  ORDER BY COUNT(rc.cleaning_id) ASC, e.employee_id ASC
  LIMIT 1;

  IF v_employee_id IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No Cleaning Staff available for this location';
  END IF;

  -- Buat task cleaning dengan staff terpilih
  INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
  VALUES (v_room_id, v_employee_id, p_booking_id, NOW(), 'scheduled');

  COMMIT;
END$$

DELIMITER ;



