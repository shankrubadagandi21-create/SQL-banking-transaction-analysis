 Create anomaly calssification report
   
SELECT transaction_id,
       account_id,
       transaction_time,
CASE
     WHEN amount >100000 THEN 'High value Transaction'
     WHEN HOUR(transaction_time) BETWEEN 0 AND 4 THEN 'Unusual Hour'
     ELSE 'Normal Review'
 END AS review_category
FROM transactions;

