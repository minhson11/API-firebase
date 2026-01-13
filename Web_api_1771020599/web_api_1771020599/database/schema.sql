-- Tạo database
CREATE DATABASE IF NOT EXISTS db_exam_1771020599;
USE db_exam_1771020599;

-- Bảng 1: Khách hàng
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    address TEXT NULL,
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Bảng 2: Menu Items
CREATE TABLE menu_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    category ENUM('Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(500) NULL,
    preparation_time INT NULL COMMENT 'Thời gian chế biến (phút)',
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_spicy BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng 5: Tables (tạo trước để reservations có thể reference)
CREATE TABLE tables (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_number VARCHAR(50) UNIQUE NOT NULL,
    capacity INT NOT NULL COMMENT 'Sức chứa (số người)',
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng 3: Reservations
CREATE TABLE reservations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    reservation_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Mã đặt bàn tự sinh',
    reservation_date TIMESTAMP NOT NULL,
    number_of_guests INT NOT NULL,
    table_number VARCHAR(50) NULL COMMENT 'Số bàn được phân',
    status ENUM('pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
    special_requests TEXT NULL,
    subtotal DECIMAL(10,2) DEFAULT 0,
    service_charge DECIMAL(10,2) DEFAULT 0 COMMENT 'Phí phục vụ (10% subtotal)',
    discount DECIMAL(10,2) DEFAULT 0 COMMENT 'Giảm giá từ loyalty points',
    total DECIMAL(10,2) DEFAULT 0,
    payment_method ENUM('cash', 'card', 'online') NULL,
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
    FOREIGN KEY (table_number) REFERENCES tables(table_number) ON DELETE SET NULL
);

-- Bảng 4: Reservation Items (Bảng trung gian)
CREATE TABLE reservation_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL COMMENT 'Giá tại thời điểm đặt',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE RESTRICT
);

-- Indexes để tối ưu performance
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_active ON customers(is_active);
CREATE INDEX idx_menu_items_category ON menu_items(category);
CREATE INDEX idx_menu_items_available ON menu_items(is_available);
CREATE INDEX idx_reservations_customer ON reservations(customer_id);
CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_reservation_items_reservation ON reservation_items(reservation_id);
CREATE INDEX idx_tables_available ON tables(is_available);

-- Triggers để tự động tính toán
DELIMITER //

-- Trigger tự động tạo reservation_number
CREATE TRIGGER before_reservation_insert 
BEFORE INSERT ON reservations
FOR EACH ROW
BEGIN
    IF NEW.reservation_number IS NULL OR NEW.reservation_number = '' THEN
        SET NEW.reservation_number = CONCAT('RSV', YEAR(NOW()), LPAD(MONTH(NOW()), 2, '0'), LPAD(DAY(NOW()), 2, '0'), LPAD(NEW.id, 4, '0'));
    END IF;
END//

-- Trigger tự động tính service_charge và total
CREATE TRIGGER before_reservation_update 
BEFORE UPDATE ON reservations
FOR EACH ROW
BEGIN
    -- Tính service charge (10% của subtotal)
    SET NEW.service_charge = NEW.subtotal * 0.10;
    -- Tính total = subtotal + service_charge - discount
    SET NEW.total = NEW.subtotal + NEW.service_charge - NEW.discount;
END//

DELIMITER ;

-- Thêm dữ liệu mẫu

-- Customers
INSERT INTO customers (email, password, full_name, phone_number, address, loyalty_points) VALUES
('john.doe@email.com', '$2b$10$example_hashed_password1', 'John Doe', '0901234567', '123 Nguyễn Huệ, Q1, TP.HCM', 150),
('jane.smith@email.com', '$2b$10$example_hashed_password2', 'Jane Smith', '0907654321', '456 Lê Lợi, Q3, TP.HCM', 200),
('nguyen.van.a@email.com', '$2b$10$example_hashed_password3', 'Nguyễn Văn A', '0912345678', '789 Trần Hưng Đạo, Q5, TP.HCM', 75),
('tran.thi.b@email.com', '$2b$10$example_hashed_password4', 'Trần Thị B', '0923456789', '321 Điện Biên Phủ, Q10, TP.HCM', 300);

-- Menu Items
INSERT INTO menu_items (name, description, category, price, image_url, preparation_time, is_vegetarian, is_spicy, rating) VALUES
-- Appetizers
('Gỏi Cuốn Tôm Thịt', 'Gỏi cuốn tươi với tôm và thịt heo, rau sống', 'Appetizer', 45000, 'https://example.com/goi-cuon.jpg', 10, FALSE, FALSE, 4.5),
('Chả Giò Rế', 'Chả giò giòn rụm với nhân thịt và rau củ', 'Appetizer', 35000, 'https://example.com/cha-gio.jpg', 15, FALSE, FALSE, 4.2),
('Salad Rau Củ', 'Salad tươi mát với rau củ hữu cơ', 'Appetizer', 30000, 'https://example.com/salad.jpg', 5, TRUE, FALSE, 4.0),

-- Soups
('Canh Chua Cá', 'Canh chua cá bông lau chua ngọt đậm đà', 'Soup', 55000, 'https://example.com/canh-chua.jpg', 20, FALSE, TRUE, 4.3),
('Súp Nấm', 'Súp nấm thơm ngon cho người ăn chay', 'Soup', 40000, 'https://example.com/sup-nam.jpg', 15, TRUE, FALSE, 4.1),

-- Main Courses
('Phở Bò Tái', 'Phở bò tái truyền thống với nước dùng đậm đà', 'Main Course', 65000, 'https://example.com/pho-bo.jpg', 25, FALSE, FALSE, 4.7),
('Bún Chả Hà Nội', 'Bún chả thơm ngon với thịt nướng', 'Main Course', 55000, 'https://example.com/bun-cha.jpg', 20, FALSE, TRUE, 4.4),
('Cơm Tấm Sườn Nướng', 'Cơm tấm với sườn nướng thơm lừng', 'Main Course', 70000, 'https://example.com/com-tam.jpg', 30, FALSE, FALSE, 4.6),
('Mì Quảng', 'Mì Quảng đặc sản miền Trung', 'Main Course', 60000, 'https://example.com/mi-quang.jpg', 25, FALSE, TRUE, 4.5),
('Cơm Chay Đậu Hũ', 'Cơm chay với đậu hũ và rau củ', 'Main Course', 45000, 'https://example.com/com-chay.jpg', 20, TRUE, FALSE, 4.2),

-- Beverages
('Cà Phê Sữa Đá', 'Cà phê sữa đá truyền thống Việt Nam', 'Beverage', 25000, 'https://example.com/ca-phe-sua.jpg', 5, TRUE, FALSE, 4.3),
('Trà Đá', 'Trà đá mát lạnh', 'Beverage', 10000, 'https://example.com/tra-da.jpg', 2, TRUE, FALSE, 4.0),
('Nước Dừa Tươi', 'Nước dừa tươi mát', 'Beverage', 20000, 'https://example.com/nuoc-dua.jpg', 3, TRUE, FALSE, 4.4),
('Sinh Tố Bơ', 'Sinh tố bơ béo ngậy', 'Beverage', 35000, 'https://example.com/sinh-to-bo.jpg', 8, TRUE, FALSE, 4.2),

-- Desserts
('Chè Ba Màu', 'Chè ba màu mát lạnh truyền thống', 'Dessert', 25000, 'https://example.com/che-ba-mau.jpg', 10, TRUE, FALSE, 4.1),
('Bánh Flan', 'Bánh flan mềm mịn', 'Dessert', 30000, 'https://example.com/banh-flan.jpg', 5, TRUE, FALSE, 4.3),
('Kem Dừa', 'Kem dừa tự làm mát lạnh', 'Dessert', 28000, 'https://example.com/kem-dua.jpg', 3, TRUE, FALSE, 4.0);

-- Tables
INSERT INTO tables (table_number, capacity) VALUES
('T01', 2), ('T02', 2), ('T03', 4), ('T04', 4), ('T05', 6), 
('T06', 6), ('T07', 8), ('T08', 8), ('T09', 10), ('T10', 12),
('VIP01', 6), ('VIP02', 8), ('VIP03', 10);

-- Sample Reservations
INSERT INTO reservations (customer_id, reservation_number, reservation_date, number_of_guests, table_number, status, subtotal, special_requests) VALUES
(1, 'RSV20250113001', '2025-01-15 19:00:00', 4, 'T03', 'confirmed', 280000, 'Không cay'),
(2, 'RSV20250113002', '2025-01-16 18:30:00', 2, 'T01', 'pending', 0, NULL),
(3, 'RSV20250113003', '2025-01-17 20:00:00', 6, 'VIP01', 'confirmed', 450000, 'Sinh nhật, cần bánh kem'),
(4, 'RSV20250113004', '2025-01-18 12:00:00', 8, 'T07', 'seated', 680000, 'Tiệc công ty');

-- Sample Reservation Items
INSERT INTO reservation_items (reservation_id, menu_item_id, quantity, price) VALUES
-- Reservation 1 (4 người)
(1, 6, 2, 65000), -- 2 Phở Bò Tái
(1, 7, 2, 55000), -- 2 Bún Chả
(1, 11, 4, 25000), -- 4 Cà Phê Sữa Đá

-- Reservation 3 (6 người - sinh nhật)
(3, 1, 6, 45000), -- 6 Gỏi Cuốn
(3, 6, 3, 65000), -- 3 Phở Bò Tái
(3, 8, 3, 70000), -- 3 Cơm Tấm
(3, 15, 6, 25000), -- 6 Chè Ba Màu

-- Reservation 4 (8 người - tiệc công ty)
(4, 2, 8, 35000), -- 8 Chả Giò
(4, 6, 4, 65000), -- 4 Phở Bò Tái
(4, 8, 4, 70000), -- 4 Cơm Tấm
(4, 11, 8, 25000); -- 8 Cà Phê Sữa Đá

-- Update reservations với service charge và total
UPDATE reservations SET 
    service_charge = subtotal * 0.10,
    total = subtotal + (subtotal * 0.10) - discount
WHERE subtotal > 0;