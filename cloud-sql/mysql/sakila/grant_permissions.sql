-- Ensure the user exists for the '%' host before granting
-- Note: The password will be handled by Terraform, here we just ensure the account structure exists
CREATE USER IF NOT EXISTS 'sakilla_user'@'%';
GRANT SELECT, RELOAD, SHOW DATABASES, LOCK TABLES, REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'sakilla_user'@'%';
FLUSH PRIVILEGES;
