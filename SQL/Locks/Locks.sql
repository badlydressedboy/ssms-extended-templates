sp_lock

-- anything not shared
select *
FROM   sys.dm_tran_locks
where request_mode != 's'

--applocks
SELECT resource_type, request_mode, 
     resource_description
FROM   sys.dm_tran_locks
where resource_type = 'APPLICATION'

--locks and waiting tasks
SELECT tl.request_session_id, wt.blocking_session_id, DB_NAME(tl.resource_database_id) AS DatabaseName, tl.resource_type, tl.request_mode, tl.resource_associated_entity_id 
FROM sys.dm_tran_locks as tl 
left JOIN sys.dm_os_waiting_tasks as wt 
ON tl.lock_owner_address = wt.resource_address;
GO

select * from sys.dm_os_waiting_tasks