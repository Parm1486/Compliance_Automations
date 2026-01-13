-- Settlement Failure & Aging Auditor
-- Focus: Identify failed trades and calculate the financial penalty (cost of carry)

SELECT 
    Trade_ID, Counterparty, Asset_Class, Settlement_Date,
    DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Days_Past_Due,
    Principal_Amount,
    (Principal_Amount * 0.05 / 360) * DATEDIFF(day, Settlement_Date, CURRENT_DATE) AS Estimated_Fail_Penalty
FROM Settlement_Ledger
WHERE Status = 'FAILED' 
  AND Settlement_Date < CURRENT_DATE;
