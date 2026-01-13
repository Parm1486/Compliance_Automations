-- Cash Management & Funding
-- Purpose: Projecting End-of-Day (EOD) Nostro balances based on pending wires.

SELECT 
    Account_ID,
    Currency,
    Opening_Balance,
    (SELECT SUM(Amount) FROM Pending_Inflows WHERE Status = 'MATCHED') AS Expected_In,
    (SELECT SUM(Amount) FROM Pending_Outflows WHERE Status = 'MATCHED') AS Expected_Out,
    (Opening_Balance + 
     COALESCE((SELECT SUM(Amount) FROM Pending_Inflows), 0) - 
     COALESCE((SELECT SUM(Amount) FROM Pending_Outflows), 0)) AS Projected_EOD_Position
FROM Nostro_Accounts
HAVING Projected_EOD_Position < 0; -- ALARM: Funding Gap Detected
