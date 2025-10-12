-- Initialize database for KH POS Lite
CREATE DATABASE IF NOT EXISTS kh_pos_lite;
USE kh_pos_lite;

-- Grant privileges to the application user
GRANT ALL PRIVILEGES ON kh_pos_lite.* TO 'pos_user'@'%';
FLUSH PRIVILEGES;