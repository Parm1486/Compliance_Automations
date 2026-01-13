-- Insider Trading "Event Window" Detector
-- Purpose: Match private employee trades against firm-wide "Restricted List" events

SELECT 
    t.Employee_ID,
    t.Ticker,
    t.Trade_Date,
    e.Event_Name,
    e.Event_Date,
    ABS(DATEDIFF(day, t.Trade_Date, e.Event_Date)) AS Days_Before_Event
FROM Employee_Trades t
JOIN Corporate_Events_Calendar e ON t.Ticker = e.Ticker
WHERE ABS(DATEDIFF(day, t.Trade_Date, e.Event_Date)) <= 5 -- 5 day "Red Zone"
  AND t.Trade_Direction = e.Expected_Price_Movement; -- e.g., Buy before positive earnings
