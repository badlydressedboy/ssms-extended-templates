-- Look at active Lock Manager resources for current database
-- Potentially long running!!!!!!!!!
SELECT request_session_id, DB_NAME(resource_database_id) AS [Database], 
resource_type, resource_subtype, request_type, request_mode, 
resource_description, request_mode, request_owner_type
FROM sys.dm_tran_locks
WHERE request_session_id > 50
AND resource_database_id = DB_ID()
AND request_session_id <> @@SPID
ORDER BY request_session_id;


