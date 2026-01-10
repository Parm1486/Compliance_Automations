-- FX Forward Reconciliation
-- Focus: Forward Points and Value Date

SELECT 
    i.Trade_ID,
    i.Currency_Pair,
    i.Value_Date,
    i.Internal_Fwd_Points,
    e.External_Fwd_Points,
    (i.Internal_Fwd_Points - e.External_Fwd_Points) AS Points_Gap,
    i.Spot_Rate_Snapshot -- Check if the base 'Spot' rate matches
FROM Internal_FX_Desk i
JOIN Counterparty_FX_File e ON i.Trade_ID = e.Trade_ID
WHERE i.Value_Date = e.Value_Date
  AND ABS(i.Internal_Fwd_Points - e.External_Fwd_Points) > 0.5; -- Threshold in pips

-- Focus: Detecting 'Settlement Date' and 'Notional' mismatches

SELECT 
    i.Trade_ID,
    i.Currency_Pair, -- e.g., 'EUR/USD'
    i.Value_Date AS Internal_Settlement_Date,
    b.Value_Date AS Broker_Settlement_Date,
    i.Notional_Amount,
    b.Notional_Amount AS Broker_Notional,
    CASE 
        WHEN i.Value_Date <> b.Value_Date THEN 'SETTLEMENT_DATE_MISMATCH'
        WHEN i.Currency_Pair <> b.Currency_Pair THEN 'DIRECTIONAL_ERROR'
        WHEN ABS(i.Notional_Amount - b.Notional_Amount) > 0.01 THEN 'CASH_AMOUNT_BREAK'
    END AS Error_Code
FROM FX_Internal_Book i
JOIN FX_Broker_Report b ON i.Trade_ID = b.Trade_ID
WHERE i.Value_Date <> b.Value_Date 
   OR i.Currency_Pair <> b.Currency_Pair
   OR i.Notional_Amount <> b.Notional_Amount;

