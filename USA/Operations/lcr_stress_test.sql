-- LCR "Stress Test" Monitor
-- Focus: Aggregate liquid assets vs. 30-day projected outflows

SELECT 
    (SUM(CASE WHEN Asset_Type = 'Level 1 HQLA' THEN Market_Value * 1.0 
              WHEN Asset_Type = 'Level 2A HQLA' THEN Market_Value * 0.85 
         ELSE 0 END)) / 
    NULLIF(SUM(CASE WHEN Flow_Type = 'Outflow' AND Days_to_Maturity <= 30 THEN Amount ELSE 0 END), 0) AS LCR_Ratio
FROM Liquidity_Ladder
HAVING 
    (SUM(CASE WHEN Asset_Type = 'Level 1 HQLA' THEN Market_Value * 1.0 ELSE 0 END) / 
     NULLIF(SUM(CASE WHEN Flow_Type = 'Outflow' THEN Amount ELSE 0 END), 0)) < 1.0; -- Alert if < 100%
