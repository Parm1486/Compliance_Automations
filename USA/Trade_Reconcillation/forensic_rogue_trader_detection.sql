-- Forensic Rogue Trader Detection
-- Focus: Find trades where the price was manually changed by a user, not a feed

SELECT 
    Trade_ID,
    Trader_ID,
    Ticker,
    System_Price,
    Manual_Override_Price,
    ABS(System_Price - Manual_Override_Price) AS Price_Manipulation_Gap,
    Last_Modified_By
FROM Trade_Audit_Log
WHERE Manual_Override_Flag = 'TRUE'
  AND ABS(System_Price - Manual_Override_Price) / System_Price > 0.05; -- 5% change
