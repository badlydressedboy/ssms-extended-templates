select *
from sys.dm_exec_requests
where database_id = db_id()