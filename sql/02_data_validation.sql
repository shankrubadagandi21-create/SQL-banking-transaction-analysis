--INSPECT THE DATA

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

Find missing accounts references
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
