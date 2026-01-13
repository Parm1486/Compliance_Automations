-- Pre-Settlement Liquidity Check
-- Purpose: Ensure cash in Nostro account covers today's outgoing wires

SELECT 
    Account_ID,
    Current_Balance,
    Pending_Outgoing_Wires,
    (Current_Balance - Pending_Outgoing_Wires) AS Projected_EOD_Balance
FROM Cash_Nostro_Accounts
WHERE (Current_Balance - Pending_Outgoing_Wires) < 0; -- ALARM: Overdraft Risk
