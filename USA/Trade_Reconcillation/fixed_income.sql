-- Fixed Income (Bond) Reconciliation
-- Purpose: Accrued Interest Mismatches

SELECT 
    i.ISIN,
    i.Settlement_Date,
    i.Internal_Accrued_Interest,
    e.External_Accrued_Interest,
    (i.Internal_Accrued_Interest - e.External_Accrued_Interest) AS Interest_Break,
    i.Day_Count_Convention -- Check if one is 30/360 and other is ACT/360
FROM Internal_Bond_Books i
JOIN Broker_Margin_Report e ON i.ISIN = e.ISIN
WHERE ABS(i.Internal_Accrued_Interest - e.External_Accrued_Interest) > 1000;


-- Purpose: ISIN identification and Accrued Interest accuracy

SELECT 
    i.Trade_ID,
    i.ISIN, -- The unique 'Social Security Number' of a bond
    i.Clean_Price,
    i.Accrued_Interest AS Internal_Accrued,
    b.Accrued_Interest AS Broker_Accrued,
    (i.Clean_Price + i.Accrued_Interest) AS Internal_Dirty_Price,
    (b.Clean_Price + b.Accrued_Interest) AS Broker_Dirty_Price
FROM Bond_Inventory i
JOIN Custodian_Statement b ON i.ISIN = b.ISIN
WHERE ABS(i.Accrued_Interest - b.Accrued_Interest) > 0.05 -- Allowing for small rounding
   OR i.Settlement_Date <> b.Settlement_Date;
