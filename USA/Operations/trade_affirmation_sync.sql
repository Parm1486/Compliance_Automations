-- Trade Affirmation Sync
-- Focus: Match internal trade status against the External Matching Platform (e.g., DTCC).

SELECT 
    i.Trade_ID,
    i.Trade_Status AS Internal_Status,
    e.External_Status,
    CASE 
        WHEN i.Trade_Status = 'AFFIRMED' AND e.External_Status = 'UNCONFIRMED' THEN 'ACTION_REQUIRED: SEND_REMINDER'
        WHEN i.Trade_Status <> e.External_Status THEN 'STATUS_MISMATCH'
        ELSE 'MATCHED'
    END AS Sync_Diagnostic
FROM Internal_Trade_Table i
LEFT JOIN DTCC_Feed e ON i.Trade_Ref = e.External_Ref
WHERE i.Trade_Status <> e.External_Status OR e.External_Status IS NULL;
