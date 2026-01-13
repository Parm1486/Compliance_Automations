-- Wash Trading & Spoofing Detector
-- Focus: Finding trades where Buyer = Seller OR High Cancel-to-Trade Ratio

-- Wash Trading Check

SELECT 
    Trade_ID, Ticker, Quantity, Price, Trade_Time,
    Buying_Entity_ID, Selling_Entity_ID
FROM Trade_Log
WHERE Buying_Entity_ID = Selling_Entity_ID;

-- Spoofing Check (High Volume of Canceled Orders without Execution)

SELECT 
    Trader_ID, Ticker,
    COUNT(CASE WHEN Status = 'CANCELED' THEN 1 END) AS Canceled_Orders,
    COUNT(CASE WHEN Status = 'EXECUTED' THEN 1 END) AS Executed_Trades,
    (COUNT(CASE WHEN Status = 'CANCELED' THEN 1 END) * 1.0 / NULLIF(COUNT(*), 0)) AS Cancel_Ratio
FROM Order_Audit_Trail
GROUP BY Trader_ID, Ticker
HAVING (COUNT(CASE WHEN Status = 'CANCELED' THEN 1 END) * 1.0 / NULLIF(COUNT(*), 0)) > 0.90; -- 90% Cancel Ratio
