-- AML "Structuring" Detection
-- Focus: Find entities making multiple deposits just below the $10,000 reporting threshold

SELECT 
    Entity_ID, 
    SUM(Transaction_Amount) AS Total_Inflow,
    COUNT(*) AS Transaction_Count
FROM Cash_Flow_Logs
WHERE Transaction_Amount BETWEEN 9000 AND 9999
GROUP BY Entity_ID, DATE_TRUNC('day', Transaction_Timestamp)
HAVING COUNT(*) > 2; -- Multiple "near-threshold" deposits in one day
