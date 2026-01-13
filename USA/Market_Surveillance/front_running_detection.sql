-- Front Running Detection 
-- Goal: To identify trades occuring within 30 mins of a client trade. 
-- Execution: Reconcile Personal_Trade and Client_Trade files to see if there is any trade occured in same ticker within 30 minutes.

SELECT 
    p.Trade_ID AS Personal_Trade,
    c.Trade_ID AS Client_Trade,
    p.Ticker,
    p.Timestamp AS Personal_Time,
    c.Timestamp AS Client_Time
FROM Personal_Trades p
JOIN Client_Trades c ON p.Ticker = c.Ticker
WHERE p.Action = 'BUY' 
  AND c.Action = 'BUY'
  AND p.Timestamp < c.Timestamp
  AND c.Timestamp <= (p.Timestamp + INTERVAL '30 minutes');
     
front_running_detection.sql
