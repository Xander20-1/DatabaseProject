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
