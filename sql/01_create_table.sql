CREATE DATABASE banking_analysis;
USE banking_analysis;

-- We Create FOUR tables
-- 1.create customer table
-- 2.create accounts table
-- 3.create transaction table
-- 4.create alerts table

CREATE TABLE customers(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
customer_type VARCHAR(30),
city VARCHAR(50)
);

CREATE TABLE accounts(
account_id INT PRIMARY KEY,
customer_id int,
account_type VARCHAR(30),
account_status VARCHAR(30),
FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

CREATE TABLE transactions (
transaction_id INT PRIMARY KEY,
account_id INT,
transaction_time DATETIME,
amount DECIMAL,
transaction_type VARCHAR(30),
transacton_status VARCHAR(30),
FOREIGN KEY (account_id) REFERENCES accounts (account_id)
);


CREATE TABLE alerts(
alert_id INT PRIMARY KEY,
transaction_id INT,
alert_reason VARCHAR(100),
alert_status VARCHAR(30),
FOREIGN KEY (transaction_id) REFERENCES transactions (transaction_id)
);
