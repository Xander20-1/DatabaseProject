-- =========================================================
-- SIMULASI CUSTOMER BARU: LOKI
-- Alur: daftar -> booking pending -> buat invoice -> bayar DP -> upload+verif KTP
--       -> bayar Full -> check-in (active) -> check-out (completed)
--       -> buat task cleaning -> cleaning selesai -> room available
-- Catatan: GANTI ANGKA user_id / room_id / booking_id sesuai hasil SELECT di DB kamu
-- =========================================================


-- 1) Loki daftar akun
INSERT INTO users (full_name, email, phone)
VALUES ('Loki', 'loki@example.com', '081777777777');


-- 2) Ambil user_id Loki (pakai yang paling baru)
SELECT user_id, full_name
FROM users
WHERE full_name = 'Loki'
ORDER BY user_id DESC
LIMIT 1;

-- (GANTI di query berikut) Misal hasilnya: user_id = 5


-- 3) Ambil room_id untuk kamar yang dipilih (contoh: Tokyo)
SELECT room_id, room_name, price_per_day, status
FROM rooms
WHERE room_name = 'Tokyo';

-- (GANTI di query berikut) Misal hasilnya: room_id = 1, price_per_day = 360000


-- 4) Cek bentrok booking untuk tanggal yang dipilih (harus 0)
SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 1
  AND status <> 'cancelled'
  AND start_date < '2025-12-23'
  AND end_date   > '2025-12-20';


-- 5) Buat booking (pending)
-- total_days = 3 (20->23), original_total_price = 3 * 360000 = 1080000
-- discount_amount = 0, total_price = 1080000
-- dp_amount (30%) = 324000
INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  5, 1,
  '2025-12-20', '2025-12-23', 3,
  324000,
  1080000, 0, 1080000,
  'pending',
  NULL, 'not_uploaded', NULL
);


-- 6) Ambil booking_id terbaru (booking Loki yang baru dibuat)
SELECT booking_id, user_id, room_id, status
FROM bookings
ORDER BY booking_id DESC
LIMIT 1;

-- (GANTI di query berikut) Misal hasilnya: booking_id = 12


-- 7) Sistem membuat 2 invoice: DP & Full (status unpaid)
-- Full = total_price - dp_amount = 1080000 - 324000 = 756000
INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  (12, 'DP',   324000, NOW(), NULL, 'unpaid'),
  (12, 'Full', 756000, NOW(), NULL, 'unpaid');


-- 8) Loki membayar DP -> invoice DP jadi paid
UPDATE invoices
SET status = 'paid',
    paid_date = NOW()
WHERE booking_id = 12
  AND invoice_type = 'DP';


-- 9) Setelah DP paid -> booking status jadi dp_paid
UPDATE bookings
SET status = 'dp_paid'
WHERE booking_id = 12;


-- 10) Setelah DP paid -> room status jadi booked (di-lock untuk tanggal tersebut)
UPDATE rooms
SET status = 'booked'
WHERE room_id = 1;


-- 11) Loki upload KTP -> status verifikasi jadi pending
UPDATE bookings
SET ktp_upload_url = 'https://cloud.example.com/ktp/loki.jpg',
    ktp_verification_status = 'pending',
    ktp_verified_at = NULL
WHERE booking_id = 12;


-- 12) Admin/CS verifikasi KTP -> verified + timestamp
UPDATE bookings
SET ktp_verification_status = 'verified',
    ktp_verified_at = NOW()
WHERE booking_id = 12;


-- 13) Loki membayar Full (H-1) -> invoice Full jadi paid
UPDATE invoices
SET status = 'paid',
    paid_date = NOW()
WHERE booking_id = 12
  AND invoice_type = 'Full';


-- 14) Hari H check-in -> booking aktif (active)
UPDATE bookings
SET status = 'active'
WHERE booking_id = 12;


-- 15) Hari H check-in -> room jadi occupied
UPDATE rooms
SET status = 'occupied'
WHERE room_id = 1;


-- 16) Hari check-out -> booking selesai (completed)
UPDATE bookings
SET status = 'completed'
WHERE booking_id = 12;


-- 17) Setelah checkout -> room masuk status cleaning
UPDATE rooms
SET status = 'cleaning'
WHERE room_id = 1;


-- 18) Sistem buat task cleaning (assign 1 Cleaning Staff dari lokasi yang sama)
INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT
  b.room_id,
  e.employee_id,
  b.booking_id,
  NOW(),
  'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id = b.room_id
JOIN employees e ON e.location_id = r.location_id
WHERE b.booking_id = 12
  AND e.role = 'Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;


-- 19) Petugas mulai cleaning -> status in_progress
UPDATE room_cleaning
SET status = 'in_progress'
WHERE booking_id = 12;


-- 20) Petugas selesai cleaning -> status completed
UPDATE room_cleaning
SET status = 'completed'
WHERE booking_id = 12;


-- 21) Setelah cleaning completed -> room kembali available
UPDATE rooms
SET status = 'available'
WHERE room_id = 1;


-- 22) (Opsional) Cek hasil akhir: booking, invoice, cleaning, room
SELECT booking_id, status, start_date, end_date
FROM bookings
WHERE booking_id = 12;

SELECT invoice_type, amount, status, paid_date
FROM invoices
WHERE booking_id = 12
ORDER BY invoice_type;

SELECT cleaning_id, status, cleaning_date, employee_id
FROM room_cleaning
WHERE booking_id = 12;

SELECT room_id, room_name, status
FROM rooms
WHERE room_id = 1;
