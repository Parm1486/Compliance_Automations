-- Universal Match & Break Reporter
-- Purpose: To identify if a trade is 'Matched', 'Price_Break', or 'Quantity_Break'

SELECT 
    i.Trade_ID,
    i.Asset_Class,
    i.Ticker,
    CASE 
        WHEN i.Price = b.Price AND i.Quantity = b.Quantity THEN 'MATCHED'
        WHEN i.Price <> b.Price AND i.Quantity = b.Quantity THEN 'PRICE_BREAK'
        WHEN i.Price = b.Price AND i.Quantity <> b.Quantity THEN 'QTY_BREAK'
        ELSE 'CRITICAL_MISMATCH'
    END AS Reconciliation_Status
FROM Internal_Trades i
LEFT JOIN Broker_Statements b ON i.Trade_ID = b.Trade_ID;
