-- Create users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'store_owner', 'customer') DEFAULT 'store_owner',
    email_verified_at TIMESTAMP NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add owner_id to stores table
ALTER TABLE stores 
ADD COLUMN owner_id INT NULL AFTER id,
ADD CONSTRAINT fk_stores_owner 
FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL;

-- Create index on owner_id
CREATE INDEX idx_stores_owner ON stores(owner_id);

-- Insert default admin user (password: admin123)
INSERT INTO users (name, email, password, phone, role, created_at, updated_at) 
VALUES (
    'Admin',
    'admin@linkkart.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '8639424962',
    'admin',
    NOW(),
    NOW()
);
