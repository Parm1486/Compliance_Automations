-- Collateral Management
-- Purpose: Calculate the 'Adjusted Value' of collateral after applying Haircuts (Market_Value * (1 - Haircut)).

SELECT 
    Asset_ID,
    Asset_Type,
    Market_Value,
    Haircut_Pct,
    (Market_Value * (1 - Haircut_Pct)) AS Collateral_Value,
    -- Identify inefficient cash usage
    CASE 
        WHEN Asset_Type = 'CASH' AND Market_Value > 10000000 THEN 'LOW_EFFICIENCY: REPLACE_WITH_BONDS'
        ELSE 'OPTIMIZED'
    END AS Efficiency_Rating
FROM Collateral_Pool
WHERE Eligibility_Flag = 'TRUE';
