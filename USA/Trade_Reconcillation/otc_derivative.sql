-- OTC Interest Rate Swap Reconciliation
-- Focus: Fixed vs Floating rate terms

SELECT 
    i.Trade_ID,
    i.Notional_Amount,
    i.Fixed_Rate,
    b.Fixed_Rate AS Broker_Fixed_Rate,
    i.Floating_Index_Name, -- e.g., 'SOFR' or 'LIBOR'
    i.Termination_Date
FROM OTC_Swap_Book i
JOIN Counterparty_Confirm b ON i.Trade_ID = b.Trade_ID
WHERE i.Fixed_Rate <> b.Fixed_Rate 
   OR i.Termination_Date <> b.Termination_Date;

-- Focus: On dates, floating rates and maturity which are critical for derivatives

SELECT 
    i.Trade_ID,
    i.Counterparty_ID,
    i.Notional_Amount,
    CASE WHEN i.Effective_Date <> b.Effective_Date THEN 'DATE_MISMATCH' END AS Date_Alert,
    CASE WHEN i.Fixed_Rate <> b.Fixed_Rate THEN 'RATE_MISMATCH' END AS Rate_Alert,
    CASE WHEN i.Termination_Date <> b.Termination_Date THEN 'TENOR_MISMATCH' END AS Maturity_Alert
FROM Internal_Derivatives_Book i
JOIN External_Counterparty_Report b ON i.Trade_ID = b.Trade_ID
WHERE i.Effective_Date <> b.Effective_Date 
   OR i.Fixed_Rate <> b.Fixed_Rate
   OR i.Termination_Date <> b.Termination_Date;


-- Focus: NPV and Discount Curve Identification

SELECT 
    i.Trade_ID,
    i.Counterparty_Name,
    i.Internal_NPV,
    e.External_NPV,
    ABS(i.Internal_NPV - e.External_NPV) AS NPV_Gap,
    i.Discount_Curve_Used AS Internal_Curve,
    e.Discount_Curve_Used AS External_Curve
FROM Internal_Swap_Valuations i
JOIN External_Counterparty_Data e ON i.Trade_ID = e.Trade_ID
WHERE ABS(i.Internal_NPV - e.External_NPV) > 25000 -- Threshold for dispute
   OR i.Discount_Curve_Used <> e.Discount_Curve_Used;
