USE master

IF OBJECT_ID('tempdb..#bk') IS NOT NULL DROP TABLE #bk

--POPULATE TEMP TABLE
select a.database_name, b.type, b.backup_start_date, a.backup_finish_date 
	, datediff(s,b.backup_start_date, a.backup_finish_date) 'duration_secs'
	, CONVERT(varchar, DATEADD(ss, (datediff(s,b.backup_start_date, a.backup_finish_date)), 0), 108) duration_hhmmss
	, m.physical_device_name, b.backup_size
into #bk
from msdb..backupset b
join (select database_name
		 , MAX(backup_finish_date) AS backup_finish_date
		from msdb..backupset b
		GROUP BY database_name, type) a
	on b.backup_finish_date = a.backup_finish_date
	and b.database_name = a.database_name
JOIN 
	msdb.dbo.backupmediafamily m 
	ON b.media_set_id = m.media_set_id
order by database_name


--SELECT * FROM #bk order by database_name
--select * FROM     master.sys.databases 

--LATEST BACKUP OF EACH TYPE BY DB
SELECT   name,
         recovery_model_desc,
		 d.backup_finish_date AS full_backup_finish,
         l.backup_finish_date AS log_backup_finish,
		 i.backup_finish_date AS differential_backup_finish,
		 f.backup_finish_date AS file_backup_finish,
		 g.backup_finish_date AS differential_file_backup_finish,
		 p.backup_finish_date AS partial_backup_finish,
		 q.backup_finish_date AS differential_partial_backup_finish
		 --l.physical_device_name
FROM     master.sys.databases 
         LEFT OUTER JOIN (select * from #bk where type = 'L') l ON l.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'D') d ON d.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'I') i ON d.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'F') f ON d.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'G') g ON d.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'P') p ON d.database_name = name
		 LEFT OUTER JOIN (select * from #bk where type = 'Q') q ON d.database_name = name
where name not in ('master','model','tempdb','msdb')
ORDER BY name 



--LATEST BACKUPS BY DB/TYPE
select d.name, 
--recovery_model_desc, 
	case when #bk.type = 'D' then 'FULL'
		when #bk.type = 'L' then 'TRAN LOG'
		when #bk.type = 'I' then 'DIFFERENTIAL'
		when #bk.type = 'F' then 'FILE'
		when #bk.type = 'G' then 'DIFFERENTIAL FILE'
		when #bk.type = 'P' then 'PARTIAL'
		when #bk.type = 'Q' then 'DIFFERENTIAL PARTIAL'
		ELSE #bk.type
	end as backup_type,
	backup_start_date,
	backup_finish_date,
	duration_hhmmss,
	FORMAT(isnull(backup_size, 1) / 1048576, 'N0') size_mb,
	physical_device_name
FROM     master.sys.databases d
left join #bk
	on d.name = #bk.database_name
where name not in ('master','model','tempdb','msdb')
ORDER BY name 




--DROP TABLE #bk

