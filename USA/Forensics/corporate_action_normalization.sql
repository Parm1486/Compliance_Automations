-- Corporate Action Normalization
-- Purpose: Match trades even if a stock split has occurred

SELECT 
    i.Ticker,
    i.Quantity AS Internal_Qty,
    -- Multiply internal qty by the split factor (e.g., 4.0)
    (i.Quantity * ca.Split_Factor) AS Normalized_Internal_Qty,
    b.Quantity AS Broker_Qty,
    CASE 
        WHEN (i.Quantity * ca.Split_Factor) = b.Quantity THEN 'MATCH_POST_SPLIT'
        ELSE 'GENUINE_BREAK'
    END AS Status
FROM Internal_Positions i
JOIN Broker_Positions b ON i.Ticker = b.Ticker
JOIN Corp_Action_Calendar ca ON i.Ticker = ca.Ticker
WHERE ca.Effective_Date = CURRENT_DATE;
