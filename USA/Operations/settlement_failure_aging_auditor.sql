-- Settlement Failure & Aging Auditor
-- Purpose: Identify failed trades and calculate the financial penalty (cost of carry)

SELECT 
    Trade_ID, Counterparty, Asset_Class, Settlement_Date,
    DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Days_Past_Due,
    Principal_Amount,
    (Principal_Amount * 0.05 / 360) * DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Estimated_Fail_Penalty
FROM Settlement_Ledger
WHERE Status = 'FAILED' 
  AND Settlement_Date < CURRENT_DATE;

-- Settlement Fail Monitor
-- Purpose: Identify trades past their contractual settlement date and calculate penalty costs.

SELECT 
    Trade_ID, 
    Counterparty_ID, 
    Settlement_Date,
    Asset_Class,
    Principal_Amount,
    DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Days_Overdue,
    -- Calculate estimated 'Fail Charge' (Assuming 3% Fed Funds + Penalty)
    (Principal_Amount * 0.03 / 360) * DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Estimated_Capital_Charge
FROM Settlement_Ledger
WHERE Status IN ('PENDING', 'FAILED') 
  AND Settlement_Date < CURRENT_DATE;
