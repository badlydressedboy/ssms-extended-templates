-- Look for blocking
SELECT tl.resource_type, tl.resource_database_id,
       tl.resource_associated_entity_id, tl.request_mode,
       tl.request_session_id, wt.blocking_session_id, 
       wt.wait_type, wt.wait_duration_ms
FROM sys.dm_tran_locks as tl
INNER JOIN sys.dm_os_waiting_tasks as wt
ON tl.lock_owner_address = wt.resource_address
ORDER BY wait_duration_ms DESC;