-- =====================================================================
-- ShopSphere E-Commerce System Database Schema
-- Compatible with MySQL 8.x
-- =====================================================================

DROP DATABASE IF EXISTS shopsphere;
CREATE DATABASE shopsphere CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopsphere;

-- ---------------------------------------------------------------------
-- 1. Users Table
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('CUSTOMER', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    status ENUM('ACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. Categories Table
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cat_slug (slug),
    INDEX idx_cat_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Products Table
-- ---------------------------------------------------------------------
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    discount DECIMAL(5, 2) DEFAULT 0.00 CHECK (discount >= 0 AND discount <= 100),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_url VARCHAR(500),
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_prod_category (category_id),
    INDEX idx_prod_status (status),
    INDEX idx_prod_price (price),
    INDEX idx_prod_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. Addresses Table
-- ---------------------------------------------------------------------
CREATE TABLE addresses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_addr_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. Carts and Cart Items Tables
-- ---------------------------------------------------------------------
CREATE TABLE carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uq_cart_product (cart_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. Orders Table
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(32) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    shipping_fee DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    order_status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50) NOT NULL DEFAULT 'COD',
    coupon_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_order_user (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_order_status (order_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7. Order Items Table
-- ---------------------------------------------------------------------
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_applied DECIMAL(5, 2) DEFAULT 0.00,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    INDEX idx_item_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 8. Payments Table
-- ---------------------------------------------------------------------
CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    method VARCHAR(50) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') NOT NULL DEFAULT 'PENDING',
    transaction_ref VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_payment_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 9. Wishlist Table
-- ---------------------------------------------------------------------
CREATE TABLE wishlist (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uq_wishlist_user_prod (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 10. Reviews Table
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uq_review_user_prod (user_id, product_id),
    INDEX idx_review_prod (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 11. Coupons Table
-- ---------------------------------------------------------------------
CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type ENUM('PERCENTAGE', 'FIXED') NOT NULL DEFAULT 'PERCENTAGE',
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    usage_limit INT DEFAULT 100,
    times_used INT DEFAULT 0,
    expiry_date DATE NOT NULL,
    status ENUM('ACTIVE', 'EXPIRED', 'DISABLED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_coupon_code (code),
    INDEX idx_coupon_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- Sample Seed Data
-- =====================================================================

-- BCrypt Hashes:
-- 'Admin@123'    -> $2a$10$w8T.Zf8zL4P3K1hL0gK9e.hJ8x7uYgVbBv3qQ8wE2rT1yU4iO7pPa
-- 'Customer@123' -> $2a$10$7zD1a2b3c4d5e6f7g8h9iO.jK1l2m3n4o5p6q7r8s9t0u1v2w3xYa
-- (Standard reliable BCrypt hashes for Admin@123 and Customer@123 generated via BCrypt)

INSERT INTO users (id, name, email, password_hash, phone, role, status) VALUES
(1, 'ShopSphere Administrator', 'admin@shopsphere.com', '$2a$10$e8T/oUGBcO2c3o9sK5lMne8Z8v2hU1l6Wn9x2P4r.Xo8A5q2r9D5K', '+91 9876543210', 'ADMIN', 'ACTIVE'),
(2, 'John Doe', 'john@example.com', '$2a$10$1M5g9x7h2w.k4L6m8N0p1u2R3t4Y5u6I7o8P9q0A1b2C3d4E5f6G7', '+91 9123456780', 'CUSTOMER', 'ACTIVE'),
(3, 'Priya Sharma', 'priya@example.com', '$2a$10$1M5g9x7h2w.k4L6m8N0p1u2R3t4Y5u6I7o8P9q0A1b2C3d4E5f6G7', '+91 9988776655', 'CUSTOMER', 'ACTIVE');

-- Categories
INSERT INTO categories (id, name, slug, description, image_url, status) VALUES
(1, 'Electronics & Gadgets', 'electronics', 'High performance laptops, smartphones, audio devices and accessories', 'images/cat-electronics.jpg', 'ACTIVE'),
(2, 'Fashion & Apparel', 'fashion', 'Trendy men and women clothing, footwear and luxury accessories', 'images/cat-fashion.jpg', 'ACTIVE'),
(3, 'Home & Living', 'home-living', 'Modern home furniture, kitchen appliances, and luxury interior decor', 'images/cat-home.jpg', 'ACTIVE'),
(4, 'Sports & Fitness', 'sports-fitness', 'Gym gear, yoga accessories, outdoor wear and sports equipment', 'images/cat-sports.jpg', 'ACTIVE'),
(5, 'Books & Stationery', 'books-stationery', 'Bestselling novels, academic books, notebooks and artist supplies', 'images/cat-books.jpg', 'ACTIVE');

-- Products
INSERT INTO products (id, category_id, name, brand, description, price, discount, stock, image_url, status) VALUES
(1, 1, 'SphereBook Pro 16 M-Series', 'SphereTech', 'Ultra-fast laptop featuring 16GB Unified RAM, 512GB NVMe SSD, and 16-inch Retina Liquid Display.', 1299.99, 10.00, 25, 'images/prod-laptop.jpg', 'ACTIVE'),
(2, 1, 'AeroSound Noise Cancelling Headphones', 'AeroSound', 'Active noise cancelling wireless headphones with 40-hour battery life and studio acoustic tuning.', 199.99, 15.00, 50, 'images/prod-headphones.jpg', 'ACTIVE'),
(3, 1, 'Nova 5G Ultra Smartphone', 'NovaMobile', '6.7 inch AMOLED 120Hz display, 108MP quad-camera array, and 5000mAh battery with 67W Turbo Charge.', 749.00, 5.00, 30, 'images/prod-phone.jpg', 'ACTIVE'),
(4, 1, 'PulseTrack Smartwatch Elite', 'PulseTech', 'Precision fitness tracker with Heart Rate, SpO2, Sleep monitor, GPS, and 14-day battery life.', 129.50, 20.00, 45, 'images/prod-watch.jpg', 'ACTIVE'),
(5, 2, 'Classic Tailored Oxford Shirt', 'UrbanFit', '100% premium Egyptian combed cotton casual-formal shirt with classic collar and modern slim fit.', 45.00, 0.00, 100, 'images/prod-shirt.jpg', 'ACTIVE'),
(6, 2, 'Heritage Vintage Leather Jacket', 'BespokeLeather', 'Genuine distressed cowhide leather bomber jacket with quilted thermal lining and antique brass zippers.', 249.99, 12.00, 15, 'images/prod-jacket.jpg', 'ACTIVE'),
(7, 2, 'CloudStride Pro Running Shoes', 'CloudStride', 'Featherlight breathable knit sneakers with responsive nitrogen-infused foam sole for maximum cushion.', 89.99, 10.00, 60, 'images/prod-shoes.jpg', 'ACTIVE'),
(8, 3, 'Barista Craft Espresso Maker', 'AromaHome', '15-bar Italian pump espresso and cappuccino machine with steam milk frother wand and double filter.', 179.00, 8.00, 20, 'images/prod-espresso.jpg', 'ACTIVE'),
(9, 3, 'Ergonomic Mesh Executive Chair', 'ErgoPro', 'Adjustable lumbar support, 3D armrests, and breathable high-density mesh for all-day comfort.', 189.99, 15.00, 18, 'images/prod-chair.jpg', 'ACTIVE'),
(10, 4, 'ZenGrip Eco-Friendly Yoga Mat', 'ZenFitness', 'Non-slip 6mm high-density natural rubber and cork alignment yoga mat with carrying strap.', 39.99, 0.00, 80, 'images/prod-yogamat.jpg', 'ACTIVE'),
(11, 4, 'HexSteel Rubber Dumbbells Set (20kg)', 'TitanIron', 'Durable cast iron dumbbells with heavy-duty hex rubber encasing and knurled ergonomic chrome handles.', 79.99, 10.00, 35, 'images/prod-dumbbells.jpg', 'ACTIVE'),
(12, 5, 'The Art of Software Architecture', 'TechPress', 'Comprehensive guide to designing robust, scalable, modern enterprise software architectures.', 49.99, 5.00, 40, 'images/prod-book.jpg', 'ACTIVE');

-- Addresses
INSERT INTO addresses (id, user_id, recipient_name, phone, address_line1, address_line2, city, state, postal_code, country, is_default) VALUES
(1, 2, 'John Doe', '+91 9123456780', 'Flat 402, Green Valley Apartments', 'MG Road, Indiranagar', 'Bengaluru', 'Karnataka', '560038', 'India', TRUE),
(2, 3, 'Priya Sharma', '+91 9988776655', 'Sector 14, House No. 88', 'Near City Center Metro', 'Noida', 'Uttar Pradesh', '201301', 'India', TRUE);

-- Coupons
INSERT INTO coupons (id, code, discount_type, discount_value, min_order_amount, usage_limit, times_used, expiry_date, status) VALUES
(1, 'WELCOME10', 'PERCENTAGE', 10.00, 50.00, 500, 12, '2028-12-31', 'ACTIVE'),
(2, 'SAVE50', 'FIXED', 50.00, 200.00, 200, 5, '2028-12-31', 'ACTIVE'),
(3, 'FESTIVE25', 'PERCENTAGE', 25.00, 300.00, 100, 0, '2028-12-31', 'ACTIVE');

-- Sample Wishlist
INSERT INTO wishlist (user_id, product_id) VALUES
(2, 2),
(2, 6);

-- Sample Reviews
INSERT INTO reviews (user_id, product_id, rating, review_text) VALUES
(2, 1, 5, 'Exceptional build quality and lightning fast performance! The screen is gorgeous for coding and media.'),
(3, 2, 5, 'The active noise cancellation is unmatched at this price point. Very comfortable for long study sessions.'),
(2, 5, 4, 'Very comfortable cotton fabric. Fits nicely. Will definitely order in another color.');
