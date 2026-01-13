-- Private Credit PIK Reconciliation
-- Focus: Verify that the Loan Balance increased correctly by the PIK amount

SELECT 
    i.Facility_ID,
    i.Borrower_Name,
    i.Opening_Principal,
    i.PIK_Interest_Accrued,
    (i.Opening_Principal + i.PIK_Interest_Accrued) AS Expected_Closing_Balance,
    a.Agent_Reported_Balance,
    -- Calculate the discrepancy
    ((i.Opening_Principal + i.PIK_Interest_Accrued) - a.Agent_Reported_Balance) AS Balance_Break
FROM Internal_Private_Credit_Ledger i
JOIN Agent_Bank_Position_Report a ON i.Facility_ID = a.Facility_ID
WHERE ABS((i.Opening_Principal + i.PIK_Interest_Accrued) - a.Agent_Reported_Balance) > 1.00; -- Even a $1 break is investigated


-- Focus: Covenant Breach Detector

SELECT 
    l.Loan_ID,
    l.Borrower_Name,
    f.Total_Debt / NULLIF(f.EBITDA, 0) AS Current_Leverage_Ratio,
    l.Max_Allowed_Leverage,
    CASE 
        WHEN (f.Total_Debt / f.EBITDA) > l.Max_Allowed_Leverage THEN 'CRITICAL: COVENANT BREACH'
        WHEN (f.Total_Debt / f.EBITDA) > (l.Max_Allowed_Leverage * 0.9) THEN 'WARNING: NEAR BREACH'
        ELSE 'COMPLIANT'
    END AS Covenant_Status
FROM Loan_Terms l
JOIN Borrower_Financials_Staging f ON l.Borrower_ID = f.Borrower_ID
WHERE f.Report_Period = 'Q4-2025';


-- Focus: Funded/Unfunded, Rate Calculation, and Frequency Check

SELECT 
    i.Facility_ID,
    i.Borrower_Name,
    -- 1. Check Funded vs Unfunded
    i.Total_Commitment,
    (i.Funded_Amount + i.Unfunded_Amount) AS Total_Check,
    -- 2. Base Rate + Spread Check
    i.Current_Interest_Rate AS Internal_Rate,
    (m.Base_Rate + i.Spread_Bps / 10000.0) AS Calculated_Rate,
    -- 3. Frequency Check
    i.Payment_Frequency AS Our_Freq,
    a.Payment_Frequency AS Agent_Freq
FROM Internal_Facility_Ledger i
JOIN Agent_Bank_Data a ON i.Facility_ID = a.Facility_ID
JOIN Market_Indices m ON i.Base_Rate_Index = m.Index_Name
WHERE ABS(i.Current_Interest_Rate - (m.Base_Rate + i.Spread_Bps / 10000.0)) > 0.0001
   OR i.Payment_Frequency <> a.Payment_Frequency;

