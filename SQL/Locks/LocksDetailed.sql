
-- List all Locks of the Current Database 
SELECT tl.resource_type AS [Resource Type]
      ,tl.resource_description AS [Resource Desc]
      ,tl.request_mode AS [Request Mode]
      ,tl.request_type AS [Request Type]
      ,tl.request_status AS [Request Status]
      ,tl.request_owner_type AS [Request Owner Type]
      ,tat.[name] AS [Trans Name]
      ,wt.blocking_session_id [Blocking Session Id]
      ,tat.transaction_begin_time AS [Trans Begin Time] 
      ,DATEDIFF(ss, tat.transaction_begin_time, GETDATE()) AS [Trans Duration]
      ,es.session_id AS [Session Id] 
      ,es.login_name AS Login 
      ,COALESCE(obj.name, parobj.name) AS [Object]
      ,paridx.name AS [Index]
      ,es.host_name AS [Host] 
      ,es.program_name AS [Program Name]
FROM sys.dm_tran_locks AS tl 
	LEFT JOIN sys.dm_os_waiting_tasks as wt 
		ON tl.lock_owner_address = wt.resource_address
     INNER JOIN sys.dm_exec_sessions AS es 
         ON tl.request_session_id = es.session_id 
     LEFT JOIN sys.dm_tran_active_transactions AS tat 
         ON tl.request_owner_id = tat.transaction_id 
            AND tl.request_owner_type = 'TRANSACTION' 
     LEFT JOIN sys.objects AS obj 
         ON tl.resource_associated_entity_id = obj.object_id 
            AND tl.resource_type = 'OBJECT' 
     LEFT JOIN sys.partitions AS par 
         ON tl.resource_associated_entity_id = par.hobt_id 
            AND tl.resource_type IN ('PAGE', 'KEY', 'HOBT', 'RID') 
     LEFT JOIN sys.objects AS parobj 
         ON par.object_id = parobj.object_id 
     LEFT JOIN sys.indexes AS paridx 
         ON par.object_id = paridx.object_id 
            AND par.index_id = paridx.index_id 
WHERE tl.resource_database_id  = DB_ID() 
      AND es.session_id <> @@spid 
      AND tl.request_mode <> 'S' -- Exclude simple shared locks 
ORDER BY tl.resource_type 
        ,tl.request_mode 
        ,tl.request_type 
        ,tl.request_status 
        ,[Object] 
        ,es.login_name;
        
        