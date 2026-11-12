-- analyse transactions activity
-- Total transaction values
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

-- Transaction valume by type
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

--  Identify  accounts with unusually high daily totals
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
      
     

