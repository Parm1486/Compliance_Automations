-- Benford's Law Forensic Auditor
-- Purpose: Compare actual distribution of first digits vs. theoretical Benford distribution

WITH First_Digits AS (
    SELECT 
        LEFT(CAST(ABS(Transaction_Amount) AS VARCHAR), 1) AS First_Digit
    FROM General_Ledger
    WHERE Transaction_Amount != 0
),
Actual_Distribution AS (
    SELECT 
        First_Digit,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM First_Digits) AS Actual_Pct
    FROM First_Digits
    GROUP BY First_Digit
)
SELECT 
    a.First_Digit,
    a.Actual_Pct,
    CASE 
        WHEN a.First_Digit = '1' THEN 30.1
        WHEN a.First_Digit = '2' THEN 17.6
        WHEN a.First_Digit = '3' THEN 12.5
        WHEN a.First_Digit = '4' THEN 9.7
        WHEN a.First_Digit = '5' THEN 7.9
        WHEN a.First_Digit = '6' THEN 6.7
        WHEN a.First_Digit = '7' THEN 5.8
        WHEN a.First_Digit = '8' THEN 5.1
        WHEN a.First_Digit = '9' THEN 4.6
    END AS Benford_Expected_Pct
FROM Actual_Distribution a
ORDER BY a.First_Digit;
