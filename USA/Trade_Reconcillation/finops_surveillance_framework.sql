-- Pre-Settlement Liquidity Check
-- Focus: Ensure cash in Nostro account covers today's outgoing wires

SELECT 
    Account_ID,
    Current_Balance,
    Pending_Outgoing_Wires,
    (Current_Balance - Pending_Outgoing_Wires) AS Projected_EOD_Balance
FROM Cash_Nostro_Accounts
WHERE (Current_Balance - Pending_Outgoing_Wires) < 0; -- ALARM: Overdraft Risk



-- Corporate Action Normalization
-- Focus: Match trades even if a stock split has occurred

SELECT 
    i.Ticker,
    i.Quantity AS Internal_Qty,
    -- Multiply internal qty by the split factor (e.g., 4.0)
    (i.Quantity * ca.Split_Factor) AS Normalized_Internal_Qty,
    b.Quantity AS Broker_Qty,
    CASE 
        WHEN (i.Quantity * ca.Split_Factor) = b.Quantity THEN 'MATCH_POST_SPLIT'
        ELSE 'GENUINE_BREAK'
    END AS Status
FROM Internal_Positions i
JOIN Broker_Positions b ON i.Ticker = b.Ticker
JOIN Corp_Action_Calendar ca ON i.Ticker = ca.Ticker
WHERE ca.Effective_Date = CURRENT_DATE;



