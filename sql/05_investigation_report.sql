-- DATABASE DESIGN:
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


-- INSPECT THE DATA

SELECT * FROM customers LIMIT 10;

SELECT * FROM accounts LIMIT 10;

SELECT * FROM transactions LIMIT 10;

SELECT * FROM alerts LIMIT 10;

-- Check the number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Check the Number of accounts
SELECT COUNT(*) AS accounts
FROM accounts;

-- Check the number of alerts
SELECT COUNT(*) AS total_alerts
FROM alerts;

-- PERFORM THE DATA QUALITY CHECKS 
-- Find missing accounts references
SELECT *
FROM  transactions
WHERE account_id IS NULL;

-- Find invalid amounts
SELECT *
FROM transactions
WHERE amount <=0;

-- Find duplicate transaction references
SELECT 
     transaction_id,
     COUNT(*) AS duplicate_transactions
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*)>1;
     
-- Find transactions associated with invalid accounts
SELECT t.transaction_id,a.account_id
FROM transactions t 
LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

--  analyse transactions activity
-- Q1: Total transaction values
SELECT COUNT(*) AS transaction_count
FROM transactions;

-- Total Succussful Transaction values
SELECT SUM(amount) AS total_transaction_values
FROM transactions
WHERE transaction_status = 'Successful';

-- total failed transactions values
select SUM(amount) as total_transaction_values
FROM transactions
WHERE transaction_status = 'Failed';

--  Transaction valume by type
SELECT transaction_type,
      COUNT(*) AS total_transactions,
      SUM(amount) AS total_amount
FROM transactions
GROUP BY transaction_type;

--  Identify high value transactions
SELECT transaction_id,
       account_id,
       amount,
       transaction_time
FROM transactions
WHERE amount >100000
ORDER BY amount DESC;

-- Identify repeated transactions
SELECT 
       account_id,
       amount,
       DATE(transaction_time) AS transaction_date,
       COUNT(*) AS transaction_count
FROM transactions
WHERE transaction_status = 'Successful'
GROUP BY account_id,
         amount,
         DATE(transaction_time)
HAVING COUNT(*) >=1
order by transaction_count desc;

--  Compare cuurent and previous transactions amount
WITH transaction_history AS (
     SELECT account_id,
            transaction_id,
            transaction_time,
            amount,
            
            LAG(amount) OVER (ORDER BY transaction_id,transaction_time  desc) AS previous_amount
    FROM transactions
    WHERE transaction_status = 'Successful'
)
SELECT  
      account_id,
      transaction_id,
      amount,
      previous_amount,
      amount - previous_amount AS amount_difference
FROM transaction_history;

-- Identify  accounts with unusually high daily totals
SELECT  account_id,
        DATE(transaction_time) AS transaction_date,
        SUM(amount) as daily_transaction_value
FROM transactions
WHERE transaction_status = 'Successful'
GROUP BY account_id,
         DATE(transaction_time)
HAVING SUM(amount) >200000
ORDER BY daily_transaction_value desc;

-- Identify frequent transactions
SELECT account_id,
       DATE(transaction_time) AS transaction_date,
       COUNT(*) AS transaction_count
FROM transactions
GROUP BY account_id,
         DATE(transaction_time)
ORDER BY transaction_count desc;
      
-- Identify inactive accounts that become active
-- For this analysis,aasume an account is considered inactive if no successful transaction occured in the 
-- previous 90 days before a new tranasction

WITH transaction_history AS (
       SELECT account_id,
              transaction_id,
              transaction_time,
              
              LAG(transaction_time) OVER (PARTITION BY account_id ORDER BY transaction_time 
              ) as previous_transaction_time
       FROM transactions
       WHERE transaction_status = 'Successful'
)
 SELECT account_id,
        transaction_id,
        previous_transaction_time,
        transaction_time,
        DATEDIFF(
                 transaction_time,
                 previous_transaction_time
       ) AS inactive_days
FROM transaction_history
WHERE previous_transaction_time IS NOT NULL
      AND DATEDIFF(
                   transaction_time,
                   previous_transaction_time
     )>90;
     
--  Create anomaly calssification report
SELECT transaction_id,
       account_id,
       transaction_time,
CASE
     WHEN amount >100000 THEN 'High value Transaction'
     WHEN HOUR(transaction_time) BETWEEN 0 AND 4 THEN 'Unusual Hour'
     ELSE 'Normal Review'
 END AS review_category
FROM transactions;
