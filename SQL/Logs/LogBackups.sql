--dbname and optional type should be set in the where clause

SELECT          
	cast(database_name as varchar(15)) 'database_name'
	--, cast(backup_start_date as varchar(11)) 'start_date'
	, backup_start_date start_date
    , backup_finish_date
	, datediff(s,backup_start_date,backup_finish_date) 'duration_secs'					
	, [type]
    , cast(backup_size/1024.0 as int) AS backup_size_Kb
    , cast((backup_size/(1024 * 1024 * 1024))as int) 'backup_size_Gb'
	, physical_device_name
FROM 
	msdb.dbo.backupset b
JOIN 
	msdb.dbo.backupmediafamily m 
	ON b.media_set_id = m.media_set_id
WHERE 
	--database_name = db_name()
	 [Type] = 'L'
ORDER BY 
	backup_finish_date DESC

   







