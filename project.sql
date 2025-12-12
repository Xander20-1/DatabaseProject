CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(150) NOT NULL
);

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    room_name VARCHAR(50) NOT NULL,
    price_per_day INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available',

    CONSTRAINT fk_rooms_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE room_details (
    room_id INT PRIMARY KEY,  -- room boleh tidak punya details => cukup tidak ada row di sini

    bedrooms INT DEFAULT 0,
    bathrooms INT DEFAULT 1,
    smoking_allowed VARCHAR(10) DEFAULT 'no',

    room_size FLOAT,

    has_smart_tv BOOLEAN DEFAULT FALSE,
    has_kitchen BOOLEAN DEFAULT FALSE,
    has_balcony BOOLEAN DEFAULT FALSE,

    maximum_adults INT DEFAULT 2,
    maximum_children INT DEFAULT 0,

    amenities_description TEXT,

    CONSTRAINT fk_room_details_room
        FOREIGN KEY (room_id) REFERENCES rooms(room_id)
        ON DELETE CASCADE
);


CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role VARCHAR(50) NOT NULL,

    CONSTRAINT fk_employees_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT NOT NULL,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL,

    dp_amount INT NOT NULL,

    original_total_price INT NOT NULL,
    discount_amount INT NOT NULL DEFAULT 0,
    total_price INT NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'pending',

    ktp_upload_url VARCHAR(255),
    ktp_verification_status VARCHAR(20) NOT NULL DEFAULT 'not_uploaded',
    ktp_verified_at DATETIME,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),

    CONSTRAINT fk_bookings_room
        FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,

    invoice_type VARCHAR(20) NOT NULL,
    amount INT NOT NULL,
    issued_date DATETIME NOT NULL,
    paid_date DATETIME,
    status VARCHAR(20) NOT NULL DEFAULT 'unpaid',

    CONSTRAINT fk_invoices_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

CREATE TABLE room_cleaning (
    cleaning_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    employee_id INT NOT NULL,
    booking_id INT NOT NULL,

    cleaning_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',

    CONSTRAINT fk_cleaning_room
        FOREIGN KEY (room_id) REFERENCES rooms(room_id),

    CONSTRAINT fk_cleaning_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),

    CONSTRAINT fk_cleaning_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

INSERT INTO locations (name, address) VALUES
('The Majestic Apartment', 'Jl. Surya Sumantri No. 21, Bandung'),
('Grand Setiakawan Apartment', 'Jl. Surya Sumantri No. 40, Bandung');

INSERT INTO rooms (location_id, room_type, room_name, price_per_day, status) VALUES
(1,'Studio','Tokyo',360000,'available'),
(1,'Studio','Shibuya',360000,'available'),
(1,'Studio','Shinjuku',370000,'available'),
(1,'Studio','Akihabara',370000,'available'),
(1,'1BR','Asakusa',460000,'available'),
(1,'1BR','Ueno',460000,'available'),
(1,'1BR','Ginza',480000,'available'),
(1,'1BR','Roppongi',480000,'available'),
(1,'2BR','Ikebukuro',660000,'available'),
(1,'2BR','Odaiba',660000,'available'),
(1,'2BR','Kyoto',690000,'available'),
(1,'2BR','Gion',690000,'available'),
(1,'Family','Osaka',760000,'available'),
(1,'Family','Namba',760000,'available'),
(1,'Studio','Umeda',380000,'available'),
(1,'1BR','Kobe',490000,'available'),
(1,'2BR','Sapporo',710000,'available'),
(1,'Family','Hakodate',810000,'available'),
(1,'Studio','Fukuoka',365000,'available'),
(1,'1BR','Nagoya',475000,'available');

INSERT INTO rooms (location_id, room_type, room_name, price_per_day, status) VALUES
(2,'Studio','Paris',340000,'available'),
(2,'Studio','London',340000,'available'),
(2,'Studio','Rome',355000,'available'),
(2,'Studio','Milan',355000,'available'),
(2,'1BR','Venice',440000,'available'),
(2,'1BR','Florence',440000,'available'),
(2,'1BR','Barcelona',465000,'available'),
(2,'1BR','Madrid',465000,'available'),
(2,'2BR','Lisbon',630000,'available'),
(2,'2BR','Porto',630000,'available'),
(2,'2BR','Amsterdam',655000,'available'),
(2,'2BR','Rotterdam',655000,'available'),
(2,'Family','Berlin',730000,'available'),
(2,'Family','Munich',730000,'available'),
(2,'Studio','Vienna',360000,'available'),
(2,'1BR','Prague',470000,'available'),
(2,'2BR','Budapest',690000,'available'),
(2,'Family','Zurich',790000,'available'),
(2,'Studio','Geneva',345000,'available'),
(2,'1BR','Brussels',455000,'available');

INSERT INTO room_details (
  room_id, bedrooms, bathrooms, smoking_allowed, room_size,
  has_smart_tv, has_kitchen, has_balcony,
  maximum_adults, maximum_children, amenities_description
)
SELECT
  r.room_id,
  CASE r.room_type
    WHEN 'Studio' THEN 0
    WHEN '1BR' THEN 1
    WHEN '2BR' THEN 2
    ELSE 2
  END AS bedrooms,
  CASE r.room_type
    WHEN '2BR' THEN 2
    ELSE 1
  END AS bathrooms,
  'no',
  CASE r.room_type
    WHEN 'Studio' THEN 24
    WHEN '1BR' THEN 32
    WHEN '2BR' THEN 48
    ELSE 55
  END AS room_size,
  TRUE, TRUE,
  CASE r.room_type
    WHEN 'Studio' THEN FALSE
    ELSE TRUE
  END AS has_balcony,
  CASE r.room_type
    WHEN 'Studio' THEN 2
    WHEN '1BR' THEN 2
    WHEN '2BR' THEN 4
    ELSE 6
  END AS maximum_adults,
  CASE r.room_type
    WHEN 'Family' THEN 2
    ELSE 1
  END AS maximum_children,
  CONCAT(
    r.room_type,
    ' themed room, inspired by ',
    r.room_name,
    '. Smart TV, WiFi, AC, kitchen set.'
  )
FROM rooms r
WHERE r.location_id IN (1,2);


INSERT INTO employees (location_id, full_name, phone, role) VALUES
-- The Majestic Apartment
(1, 'Andi Pratama', '081200000001', 'Cleaning Staff'),
(1, 'Budi Santoso', '081200000002', 'Cleaning Staff'),
(1, 'Citra Lestari', '081200000003', 'Cleaning Staff'),
(1, 'Dewi Anggraini', '081200000004', 'Cleaning Staff'),
(1, 'Eko Wibowo', '081200000005', 'Cleaning Staff'),

(1, 'Rizky Hidayat', '081200000006', 'Maintenance Technician'),
(1, 'Fajar Nugraha', '081200000007', 'Maintenance Technician'),

-- Grand Setiakawan Apartment
(2, 'Ahmad Fauzi', '081300000001', 'Cleaning Staff'),
(2, 'Bella Kurnia', '081300000002', 'Cleaning Staff'),
(2, 'Cahyo Putro', '081300000003', 'Cleaning Staff'),
(2, 'Dina Maharani', '081300000004', 'Cleaning Staff'),
(2, 'Farhan Maulana', '081300000005', 'Cleaning Staff'),

(2, 'Yoga Prasetyo', '081300000006', 'Maintenance Technician'),
(2, 'Kevin Adrian', '081300000007', 'Maintenance Technician');


-- =========================================================
-- SIMULASI 5 CUSTOMER (berdasarkan range room_id)
-- Jepang: room_id 1-20  -> Jiro, Louis
-- Eropa : room_id 21-40 -> Wilbert, Steven, Kurniawan
-- Catatan:
-- - Booking dibuat tidak bentrok (tanggal dibuat beda).
-- =========================================================


-- =========================================================
-- A) JIRO (Jepang) pilih room_id = 3 
-- =========================================================

-- A1) Daftar akun
INSERT INTO users (full_name, email, phone)
VALUES ('Jiro', 'jiro@example.com', '081700000001');

-- A2) Cek room yang dipilih harus ada & status available
SELECT room_id, room_name, status, price_per_day
FROM rooms
WHERE room_id = 3;

-- A3) Cek bentrok booking (harus 0)
SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 3
  AND status <> 'cancelled'
  AND start_date < '2025-12-23'
  AND end_date   > '2025-12-20';

-- A4) Buat booking (pending)
INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  (SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1),
  3,
  '2025-12-20', '2025-12-23', 3,
  300000,
  1000000, 0, 1000000,
  'pending',
  NULL, 'not_uploaded', NULL
);

-- A5) Buat 2 invoice DP & Full
INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'DP', 300000, NOW(), NULL, 'unpaid'),
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'Full', 700000, NOW(), NULL, 'unpaid');

-- A6) Bayar DP -> booking dp_paid -> room booked
UPDATE invoices
SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='DP';

UPDATE bookings
SET status='dp_paid'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='booked'
WHERE room_id=3;

-- A7) Upload & verify KTP
UPDATE bookings
SET ktp_upload_url='https://cloud.example.com/ktp/jiro.jpg',
    ktp_verification_status='pending',
    ktp_verified_at=NULL
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE bookings
SET ktp_verification_status='verified',
    ktp_verified_at=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

-- A8) Bayar Full
UPDATE invoices
SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='Full';

-- A9) Check-in -> active, room occupied
UPDATE bookings
SET status='active'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='occupied'
WHERE room_id=3;

-- A10) Check-out -> completed, room cleaning
UPDATE bookings
SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='cleaning'
WHERE room_id=3;

-- A11) Buat task cleaning (assign 1 Cleaning Staff di lokasi sama)
INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT b.room_id, e.employee_id, b.booking_id, NOW(), 'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id=b.room_id
JOIN employees e ON e.location_id=r.location_id
WHERE b.booking_id=(SELECT booking_id FROM bookings
                    WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                    ORDER BY booking_id DESC LIMIT 1)
  AND e.role='Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;

-- A12) Cleaning selesai -> room available
UPDATE room_cleaning
SET status='in_progress'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE room_cleaning
SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='jiro@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='available'
WHERE room_id=3;



-- =========================================================
-- B) LOUIS (Jepang) pilih room_id = 7 
-- =========================================================

INSERT INTO users (full_name, email, phone)
VALUES ('Louis', 'louis@example.com', '081700000005');

SELECT room_id, room_name, status, price_per_day
FROM rooms
WHERE room_id = 7;

SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 7
  AND status <> 'cancelled'
  AND start_date < '2025-12-26'
  AND end_date   > '2025-12-24';

INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  (SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1),
  7,
  '2025-12-24', '2025-12-26', 2,
  240000,
  800000, 0, 800000,
  'pending',
  NULL, 'not_uploaded', NULL
);

INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'DP', 240000, NOW(), NULL, 'unpaid'),
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'Full', 560000, NOW(), NULL, 'unpaid');

UPDATE invoices
SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='DP';

UPDATE bookings
SET status='dp_paid'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='booked'
WHERE room_id=7;

UPDATE bookings
SET ktp_upload_url='https://cloud.example.com/ktp/louis.jpg',
    ktp_verification_status='pending',
    ktp_verified_at=NULL
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE bookings
SET ktp_verification_status='verified',
    ktp_verified_at=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE invoices
SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='Full';

UPDATE bookings
SET status='active'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='occupied'
WHERE room_id=7;

UPDATE bookings
SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='cleaning'
WHERE room_id=7;

INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT b.room_id, e.employee_id, b.booking_id, NOW(), 'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id=b.room_id
JOIN employees e ON e.location_id=r.location_id
WHERE b.booking_id=(SELECT booking_id FROM bookings
                    WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                    ORDER BY booking_id DESC LIMIT 1)
  AND e.role='Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;

UPDATE room_cleaning
SET status='in_progress'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE room_cleaning
SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='louis@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms
SET status='available'
WHERE room_id=7;



-- =========================================================
-- C) KURNIAWAN (Eropa) pilih room_id = 22 
-- =========================================================

INSERT INTO users (full_name, email, phone)
VALUES ('Kurniawan', 'kurniawan@example.com', '081700000002');

SELECT room_id, room_name, status, price_per_day
FROM rooms
WHERE room_id = 22;

SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 22
  AND status <> 'cancelled'
  AND start_date < '2025-12-30'
  AND end_date   > '2025-12-27';

INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  (SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1),
  22,
  '2025-12-27', '2025-12-30', 3,
  270000,
  900000, 0, 900000,
  'pending',
  NULL, 'not_uploaded', NULL
);

INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'DP', 270000, NOW(), NULL, 'unpaid'),
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'Full', 630000, NOW(), NULL, 'unpaid');

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='DP';

UPDATE bookings SET status='dp_paid'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='booked' WHERE room_id=22;

UPDATE bookings
SET ktp_upload_url='https://cloud.example.com/ktp/kurniawan.jpg',
    ktp_verification_status='pending',
    ktp_verified_at=NULL
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE bookings
SET ktp_verification_status='verified',
    ktp_verified_at=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='Full';

UPDATE bookings SET status='active'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='occupied' WHERE room_id=22;

UPDATE bookings SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='cleaning' WHERE room_id=22;

INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT b.room_id, e.employee_id, b.booking_id, NOW(), 'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id=b.room_id
JOIN employees e ON e.location_id=r.location_id
WHERE b.booking_id=(SELECT booking_id FROM bookings
                    WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                    ORDER BY booking_id DESC LIMIT 1)
  AND e.role='Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;

UPDATE room_cleaning SET status='in_progress'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE room_cleaning SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='kurniawan@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='available' WHERE room_id=22;



-- =========================================================
-- D) STEVEN (Eropa) pilih room_id = 28
-- =========================================================

INSERT INTO users (full_name, email, phone)
VALUES ('Steven', 'steven@example.com', '081700000003');

SELECT room_id, room_name, status, price_per_day
FROM rooms
WHERE room_id = 28;

SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 28
  AND status <> 'cancelled'
  AND start_date < '2026-01-03'
  AND end_date   > '2025-12-31';

INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  (SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1),
  28,
  '2025-12-31', '2026-01-03', 3,
  360000,
  1200000, 0, 1200000,
  'pending',
  NULL, 'not_uploaded', NULL
);

INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'DP', 360000, NOW(), NULL, 'unpaid'),
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'Full', 840000, NOW(), NULL, 'unpaid');

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='DP';

UPDATE bookings SET status='dp_paid'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='booked' WHERE room_id=28;

UPDATE bookings
SET ktp_upload_url='https://cloud.example.com/ktp/steven.jpg',
    ktp_verification_status='pending',
    ktp_verified_at=NULL
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE bookings
SET ktp_verification_status='verified',
    ktp_verified_at=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='Full';

UPDATE bookings SET status='active'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='occupied' WHERE room_id=28;

UPDATE bookings SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='cleaning' WHERE room_id=28;

INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT b.room_id, e.employee_id, b.booking_id, NOW(), 'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id=b.room_id
JOIN employees e ON e.location_id=r.location_id
WHERE b.booking_id=(SELECT booking_id FROM bookings
                    WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                    ORDER BY booking_id DESC LIMIT 1)
  AND e.role='Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;

UPDATE room_cleaning SET status='in_progress'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE room_cleaning SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='steven@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='available' WHERE room_id=28;



-- =========================================================
-- E) WILBERT (Eropa) pilih room_id = 35 
-- =========================================================

INSERT INTO users (full_name, email, phone)
VALUES ('Wilbert', 'wilbert@example.com', '081700000004');

SELECT room_id, room_name, status, price_per_day
FROM rooms
WHERE room_id = 35;

SELECT COUNT(*) AS conflict_count
FROM bookings
WHERE room_id = 35
  AND status <> 'cancelled'
  AND start_date < '2026-01-06'
  AND end_date   > '2026-01-04';

INSERT INTO bookings (
  user_id, room_id,
  start_date, end_date, total_days,
  dp_amount,
  original_total_price, discount_amount, total_price,
  status,
  ktp_upload_url, ktp_verification_status, ktp_verified_at
)
VALUES (
  (SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1),
  35,
  '2026-01-04', '2026-01-06', 2,
  210000,
  700000, 0, 700000,
  'pending',
  NULL, 'not_uploaded', NULL
);

INSERT INTO invoices (booking_id, invoice_type, amount, issued_date, paid_date, status)
VALUES
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'DP', 210000, NOW(), NULL, 'unpaid'),
  ((SELECT booking_id FROM bookings
    WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
    ORDER BY booking_id DESC LIMIT 1),
   'Full', 490000, NOW(), NULL, 'unpaid');

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='DP';

UPDATE bookings SET status='dp_paid'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='booked' WHERE room_id=35;

UPDATE bookings
SET ktp_upload_url='https://cloud.example.com/ktp/wilbert.jpg',
    ktp_verification_status='pending',
    ktp_verified_at=NULL
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE bookings
SET ktp_verification_status='verified',
    ktp_verified_at=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE invoices SET status='paid', paid_date=NOW()
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1)
  AND invoice_type='Full';

UPDATE bookings SET status='active'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='occupied' WHERE room_id=35;

UPDATE bookings SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='cleaning' WHERE room_id=35;

INSERT INTO room_cleaning (room_id, employee_id, booking_id, cleaning_date, status)
SELECT b.room_id, e.employee_id, b.booking_id, NOW(), 'scheduled'
FROM bookings b
JOIN rooms r ON r.room_id=b.room_id
JOIN employees e ON e.location_id=r.location_id
WHERE b.booking_id=(SELECT booking_id FROM bookings
                    WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                    ORDER BY booking_id DESC LIMIT 1)
  AND e.role='Cleaning Staff'
ORDER BY e.employee_id
LIMIT 1;

UPDATE room_cleaning SET status='in_progress'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE room_cleaning SET status='completed'
WHERE booking_id=(SELECT booking_id FROM bookings
                  WHERE user_id=(SELECT user_id FROM users WHERE email='wilbert@example.com' ORDER BY user_id DESC LIMIT 1)
                  ORDER BY booking_id DESC LIMIT 1);

UPDATE rooms SET status='available' WHERE room_id=35;
