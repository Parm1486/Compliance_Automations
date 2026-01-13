-- Custody Inventory Reconciliation
-- Focus: Daily reconciliation of internal book-entry vs Custodian's actual vault/CSD record.

SELECT 
    i.Account_Number,
    i.ISIN,
    i.Position_Qty AS Internal_Qty,
    c.Position_Qty AS Custodian_Qty,
    (i.Position_Qty - c.Position_Qty) AS Inventory_Gap,
    -- Check for missing Income (Dividends/Interest)
    i.Pending_Income - c.Received_Income AS Income_Leakage
FROM Internal_Ledger i
JOIN Custodian_Report c ON i.ISIN = c.ISIN AND i.Account_Number = c.Account_Number
WHERE i.Position_Qty <> c.Position_Qty OR i.Pending_Income <> c.Received_Income;
