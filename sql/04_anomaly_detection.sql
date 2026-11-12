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


-- Create anomaly calssification report
   
SELECT transaction_id,
       account_id,
       transaction_time,
CASE
     WHEN amount >100000 THEN 'High value Transaction'
     WHEN HOUR(transaction_time) BETWEEN 0 AND 4 THEN 'Unusual Hour'
     ELSE 'Normal Review'
 END AS review_category
FROM transactions;

