-- Master Multi-Asset Margin Reconciliation
-- Purpose: Consolidate margin disputes across FX, Fixed Income, and OTC Swaps
   
WITH Margin_Comparison AS (
    SELECT 
        m.Agreement_ID,
        m.Counterparty_Name,
        m.Product_Type,
        m.Internal_Margin_Call AS Our_X,
        c.Counterparty_Demand AS Their_X_Plus_Y,
        (c.Counterparty_Demand - m.Internal_Margin_Call) AS Total_Variance
    FROM Internal_Margin_Requests AS m
    JOIN Counterparty_Margin_Files AS c ON m.Agreement_ID = c.Agreement_ID
    -- Filter early for performance
    WHERE ABS(c.Counterparty_Demand - m.Internal_Margin_Call) > 50000
)
SELECT 
    mc.Agreement_ID,
    mc.Counterparty_Name,
    mc.Product_Type,
    mc.Our_X,
    mc.Their_X_Plus_Y,
    mc.Total_Variance,
    -- Using CASE with CAST to ensure CONCAT doesn't fail on numeric fields
    CASE 
        WHEN mc.Product_Type = 'OTC_SWAP' THEN 
             CONCAT('Curve Mismatch: ', CAST(sw.Discount_Curve AS VARCHAR(50)))
        
        WHEN mc.Product_Type = 'FIXED_INCOME' THEN 
             CONCAT('Interest Mismatch: ', CAST(bn.Accrued_Int_Amt AS VARCHAR(50)))
              
        WHEN mc.Product_Type = 'FX_FORWARD' THEN 
             CONCAT('Points Mismatch: ', CAST(fx.Fwd_Points AS VARCHAR(50)))
              
        ELSE 'Check Inventory/General Pricing'
    END AS Dispute_Root_Cause
FROM Margin_Comparison AS mc
-- Joining specific product tables to find the 'Why' behind the gap
LEFT JOIN Swap_Valuations AS sw ON mc.Agreement_ID = sw.Agreement_ID
LEFT JOIN Bond_Valuations AS bn ON mc.Agreement_ID = bn.Agreement_ID
LEFT JOIN FX_Valuations AS fx   ON mc.Agreement_ID = fx.Agreement_ID;


-- Margin Call Dispute & Root Cause Analysis
-- Goal: Find the 'Y' difference and check if it's caused by Price or Haircut

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

