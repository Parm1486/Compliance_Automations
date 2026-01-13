-- Lifecycle & Identity Auditor
-- Purpose: Finding Version Mismatches and Legal Entity Errors

SELECT 
    i.Trade_ID,
    i.Internal_Version_No,
    e.External_Version_No,
    i.Legal_Entity_ID AS Our_Entity,
    e.Legal_Entity_ID AS Counterparty_Entity,
    CASE 
        WHEN i.Internal_Version_No < e.External_Version_No THEN 'STALE_INTERNAL_VERSION'
        WHEN i.Legal_Entity_ID <> e.Legal_Entity_ID THEN 'INCORRECT_LEGAL_ENTITY'
        WHEN i.Counterparty_ID <> e.Counterparty_ID THEN 'NOVATION_MISSING'
    END AS Lifecycle_Status
FROM Internal_Ledger i
JOIN External_Feed e ON i.Trade_ID = e.Trade_ID
WHERE i.Internal_Version_No <> e.External_Version_No 
   OR i.Legal_Entity_ID <> e.Legal_Entity_ID;


-- Platform Synchronization Check
-- Purpose: Find trades confirmed in DTCC but missing from the Portfolio

SELECT 
    d.DTCC_Control_Number,
    d.Trade_Date,
    d.Status AS DTCC_Status
FROM DTCC_Confirmed_Trades d
LEFT JOIN Counterparty_Portfolio_Report c ON d.Trade_ID = c.Trade_ID
WHERE c.Trade_ID IS NULL -- Trade exists in DTCC but not in their report
  AND d.Status = 'MATCHED';

-- Timing & Maturity Monitor
-- Purpose: Upcoming maturities and 'Pending' vs 'Confirmed' status

SELECT 
    Trade_ID,
    Asset_Class,
    Maturity_Date,
    Booking_Status, -- e.g., 'PRELIMINARY', 'PENDING', 'LIVE'
    CURRENT_DATE AS Today
FROM Multi_Asset_Subledger
WHERE Maturity_Date <= DATE_ADD(CURDATE(), INTERVAL 5 DAY) -- Upcoming Maturities
   OR Booking_Status = 'PRELIMINARY'; -- Unconfirmed/Ghost Trades

-- Model Hierarchy Auditor
-- Purpose: Highlight where the Price difference is due to Model Methodology

SELECT 
    i.Asset_ID,
    i.Asset_Class,
    i.Model_Name AS Internal_Model,
    e.Model_Name AS External_Model,
    i.Fair_Value AS Our_Value,
    e.Fair_Value AS Cpty_Value
FROM Internal_Valuations i
JOIN Counterparty_Valuations e ON i.Asset_ID = e.Asset_ID
WHERE i.Model_Name <> e.Model_Name 
  AND ABS(i.Fair_Value - e.Fair_Value) > 100000;
