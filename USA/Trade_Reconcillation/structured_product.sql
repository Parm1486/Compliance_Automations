-- Structured Products Reconciliation
-- Focus: Barrier Levels and Model Types

SELECT 
    i.Note_ID,
    i.Underlying_Asset,
    i.Barrier_Level,
    i.Is_Barrier_Triggered AS Internal_Barrier_Status,
    e.Is_Barrier_Triggered AS External_Barrier_Status,
    i.Valuation_Model_Type AS Internal_Model,
    e.Valuation_Model_Type AS External_Model
FROM Structured_Note_Inventory i
JOIN Issuer_Valuation_Report e ON i.Note_ID = e.Note_ID
WHERE i.Is_Barrier_Triggered <> e.Is_Barrier_Triggered
   OR i.Valuation_Model_Type <> e.Valuation_Model_Type;

-- Focus: Barrier Levels and Strike Prices 

SELECT 
    i.Tranche_ID,
    i.Underlying_Asset_Basket,
    i.Strike_Price,
    b.Strike_Price AS Counterparty_Strike,
    i.Barrier_Level,
    b.Barrier_Level AS Counterparty_Barrier,
    i.Participation_Rate
FROM Structured_Note_Log i
JOIN Issuing_Bank_Report b ON i.Tranche_ID = b.Tranche_ID
WHERE i.Barrier_Level <> b.Barrier_Level 
   OR i.Strike_Price <> b.Strike_Price;
