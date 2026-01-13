-- Trade Reconciliation 
-- Purpose: Identify discrepancies between Internal_Books and Broker_Records

SELECT
	i.Trade_ID,
    i.Ticker,
    i.Price AS Internal_Price,
    b.Price AS Broker_Price,
    (i.Price - b.Price) AS Price_Difference,
    i.Quantity AS Internal_Qty,
    b.Quantity AS Broker_Qty
FROM Internal_Trades_i
JOIN Broker_Statements b ON i.Trade_ID = b.Trade_ID
WHERE i.Price <> b.Price OR i.Quantity <> b.Quantity;
