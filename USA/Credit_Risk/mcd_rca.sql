-- Margin Call Dispute & Root Cause Analysis
-- Purpose: Find the 'Y' difference and check if it's caused by Price or Haircut

SELECT 
    m.Counterparty_ID,
    m.Internal_Margin_Estimate AS System_X,
    c.Counterparty_Demand AS X_Plus_Y,
    (c.Counterparty_Demand - m.Internal_Margin_Estimate) AS Margin_Gap_Y,
    t.Internal_Price,
    t.Market_Price_Per_Counterparty,
    -- Analysis Logic: Is the gap caused by Price?
    CASE 
        WHEN ABS(t.Internal_Price - t.Market_Price_Per_Counterparty) > 0.01 THEN 'PRICE_DISPUTE'
        WHEN m.Haircut_Percentage <> c.Counterparty_Haircut THEN 'HAIRCUT_MISMATCH'
        ELSE 'UNEXPLAINED_GAP_CHECK_INVENTORY'
    END AS Dispute_Reason
FROM Margin_System_Calculations m
JOIN Counterparty_Margin_Requests c ON m.Agreement_ID = c.Agreement_ID
LEFT JOIN Trade_Valuations t ON m.Agreement_ID = t.Agreement_ID
WHERE ABS(c.Counterparty_Demand - m.Internal_Margin_Estimate) > 10000; -- Only care if gap > $10k
