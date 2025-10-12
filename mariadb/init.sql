-- Create test database for PHPUnit
CREATE DATABASE IF NOT EXISTS `clientxcms_test`;
GRANT ALL PRIVILEGES ON `clientxcms_test`.* TO 'clientxcms'@'%';
FLUSH PRIVILEGES;
