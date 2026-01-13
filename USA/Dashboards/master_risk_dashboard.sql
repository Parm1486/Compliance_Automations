-- CEO/CRO Risk Dashboard
-- Purpose: Consolidate systemic threats into a single oversight layer

CREATE OR REPLACE VIEW Master_Risk_Dashboard AS

-- 1. LIQUIDITY BREAKER (LCR Risk)
SELECT 
    'LIQUIDITY' AS Risk_Category,
    'LCR Below Threshold' AS Risk_Event,
    'CRITICAL' AS Severity,
    CONCAT('LCR Ratio at ', ROUND(LCR_Value * 100, 2), '%') AS Details
FROM Liquidity_Monitor_Results -- Assuming results from your LCR script
WHERE LCR_Value < 1.0

UNION ALL

-- 2. COMPLIANCE BREAKER (Insider Trading)
SELECT 
    'COMPLIANCE' AS Risk_Category,
    'Insider Trade Detected' AS Risk_Event,
    'URGENT' AS Severity,
    CONCAT('Employee ', Employee_ID, ' traded ', Ticker, ' in restricted window') AS Details
FROM Insider_Trading_Hits

UNION ALL

-- 3. FORENSIC BREAKER (Accounting Fraud)
SELECT 
    'FORENSIC' AS Risk_Category,
    'Benford Deviation Found' AS Risk_Event,
    'HIGH' AS Severity,
    CONCAT('Digit ', First_Digit, ' deviation: ', Actual_Pct, '% vs ', Expected_Pct, '%') AS Details
FROM Benford_Audit_Results
WHERE ABS(Actual_Pct - Expected_Pct) > 5.0

UNION ALL

-- 4. MARKET BREAKER (Margin Variance)
SELECT 
    'MARKET' AS Risk_Category,
    'Archegos-Scale Variance' AS Risk_Event,
    'CRITICAL' AS Severity,
    CONCAT('Variance: $', ROUND(Total_Variance / 1000000.0, 2), 'M on ', Counterparty_Name) AS Details
FROM Margin_Comparison
WHERE Total_Variance > 10000000 -- $10M Threshold

UNION ALL

-- 5. CREDIT BREAKER (Private Credit Defaults)
SELECT 
    'CREDIT' AS Risk_Category,
    'Covenant Breach' AS Risk_Event,
    'HIGH' AS Severity,
    CONCAT('Borrower ', Borrower_Name, ' Leverage: ', Current_Leverage, 'x') AS Details
FROM Covenant_Alerts
WHERE Status = 'CRITICAL: COVENANT BREACH';
