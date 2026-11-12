analyse transactions activity
-- Q1: Total transaction values
SELECT COUNT(*) AS transaction_count
FROM transactions;

-- Q2: Total Succussful Transaction values
SELECT SUM(amount) AS total_transaction_values
FROM transactions
WHERE transaction_status = 'Successful';

-- total failed transactions values
select SUM(amount) as total_transaction_values
FROM transactions
WHERE transaction_status = 'Failed';

-- Q3: Transaction valume by type
SELECT transaction_type,
      COUNT(*) AS total_transactions,
      SUM(amount) AS total_amount
FROM transactions
GROUP BY transaction_type;

-- Q4 : Identify high value transactions
SELECT transaction_id,
       account_id,
       amount,
       transaction_time
FROM transactions
WHERE amount >100000
ORDER BY amount DESC;

-- Q5: Identify repeated transactions
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

-- Q6: Compare cuurent and previous transactions amount
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

-- Q7 : Identify  accounts with unusually high daily totals
SELECT  account_id,
        DATE(transaction_time) AS transaction_date,
        SUM(amount) as daily_transaction_value
FROM transactions
WHERE transaction_status = 'Successful'
GROUP BY account_id,
         DATE(transaction_time)
HAVING SUM(amount) >200000
ORDER BY daily_transaction_value desc;

-- 8 :Identify frequent transactions
SELECT account_id,
       DATE(transaction_time) AS transaction_date,
       COUNT(*) AS transaction_count
FROM transactions
GROUP BY account_id,
         DATE(transaction_time)
ORDER BY transaction_count desc;
      
-- Q 9 : Identify inactive accounts that become active
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
     

