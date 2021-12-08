
--use testlogfull
--exec dbo.DangerouslyFullFiles
create procedure DangerouslyFullFiles
as
begin

DECLARE @SqlStatement nvarchar(MAX), @DatabaseName sysname;
	
IF OBJECT_ID(N'tempdb..#DatabaseSpace') IS NOT NULL DROP TABLE #DatabaseSpace;
	
CREATE TABLE #DatabaseSpace([db_id] int,[file_id] int, used_mb	decimal(12, 2));
	
DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM sys.databases where state = 0;
	
OPEN DatabaseList;
WHILE 1 = 1
BEGIN
	FETCH NEXT FROM DatabaseList INTO @DatabaseName;
	IF @@FETCH_STATUS = -1 BREAK;
	SET @SqlStatement = N'USE [' + @DatabaseName + ']
		INSERT INTO #DatabaseSpace
	select DB_ID(), file_id, CONVERT(decimal(12,2),round(fileproperty(f.name,''SpaceUsed'')/128.000,2)) FROM sys.database_files f';

	BEGIN TRY
		EXECUTE(@SqlStatement);
    END TRY
	BEGIN CATCH
		PRINT 'Db Error:' + ERROR_MESSAGE();
	END CATCH 
END
CLOSE DatabaseList;
DEALLOCATE DatabaseList;

--SELECT * FROM #DatabaseSpace;

 /*

exec msdb.dbo.sp_send_dbmail                  
	@profile_name =  '',                  
	@recipients   = 'badlydressedboy@gmail.com',                    
	@subject      =  'test'

 */

IF OBJECT_ID(N'tempdb..#files_raw') IS NOT NULL DROP TABLE #files_raw;
 --drop table #files_raw

select DB_NAME( mf.database_id) db
	, mf.database_id
    , mf.file_id
	, name	            
	, type_desc	            	         	           
	, convert(numeric(18,2),(size)/128) as size_mb		
	, max_size		
	, case 
		when max_size = 0 then 'NoGrowth'
		when max_size = -1 then 'Unlimited'
		else 'Limited' end as max_size_type
	, (max_size)/128 max_size_mb
	, growth
	, is_percent_growth 
	, case
		when is_percent_growth = 1 then convert(varchar(20),growth) + '%'
		else convert(varchar(20)
			,((growth*8)/1024)) 
				+ 'Mb' end as growth_desc

	, physical_name	        

	, vol.volume_mount_point
	, vol.available_bytes/1024/1024 as available_mb				
	, vol.total_bytes/1024/1024 as total_mb	
				
	, 0 as next_growth_increment_mb
	, 0 as size_after_next_growth_mb
	, 0 as free_mb_after_next_growth
	, 0 as next_growth_breaches_max_size
	, 0 as next_growth_fills_drive
	, ds.used_mb as current_used_mb
	, convert(float, 0) as current_used_pc
into #files_raw
from sys.master_files  mf		   
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id)  vol  
JOIN #DatabaseSpace ds on mf.database_id = ds.db_id and mf.file_id = ds.file_id
order by  mf.database_id, mf.file_id


--select *
--from #files_raw


/*testing---------
update #files_raw
set growth = 9999999
where is_percent_growth = 0

update #files_raw
set growth = 9999
where is_percent_growth = 1
*/--------------------

update #files_raw
set current_used_pc = (current_used_mb/size_mb)*100.0
where size_mb > 0

update #files_raw
set next_growth_increment_mb = size_mb*(growth*0.01)
	, size_after_next_growth_mb = size_mb+(size_mb*(growth*0.01))
	, free_mb_after_next_growth = available_mb-(size_mb*(growth*0.01))
where is_percent_growth = 1

update #files_raw
set next_growth_increment_mb = (growth*8)/1024
	, size_after_next_growth_mb = size_mb+((growth*8)/1024)
	, free_mb_after_next_growth = available_mb-((growth*8)/1024)
where is_percent_growth = 0


update #files_raw
set next_growth_breaches_max_size = 1	
where max_size_type = 'Limited'
and size_after_next_growth_mb > max_size_mb

update #files_raw
set next_growth_fills_drive = 1	
where free_mb_after_next_growth < 0



select db, database_id, file_id , name, type_desc
	, next_growth_breaches_max_size
	, next_growth_fills_drive
	, size_mb, current_used_pc, current_used_mb
	, max_size_type, max_size_mb
	, growth_desc, next_growth_increment_mb, size_after_next_growth_mb, free_mb_after_next_growth
	, total_mb, available_mb
	, physical_name
from #files_raw
order by db, file_id


--are we in deep sht?
select *, next_growth_increment_mb, next_growth_breaches_max_size, next_growth_fills_drive
from #files_raw
where next_growth_breaches_max_size = 1	
or next_growth_fills_drive = 1	
and current_used_pc > 50



if @@ROWCOUNT > 0
begin

	DECLARE @tableHTML  NVARCHAR(MAX) ;  
  
	SET @tableHTML =  
		N'<H2>Files About To Fill</H2>' +  
		N'These files will NOT be able to grow when they hit 100% full!' +  
		N'<table border="1">' +  
		N'<tr><th>DB</th><th>File</th><th>% Full</th><th>Growth MB</th><th>Breaches Max File Size</th><th>Fills Drive</th></tr>' +  
		CAST ( ( select td = db, ''
			, td = physical_name, ''
			, td = convert(int,current_used_pc), ''
			, td = next_growth_increment_mb, ''
			, td = next_growth_breaches_max_size, ''
			, td = next_growth_fills_drive
		from #files_raw
		where next_growth_breaches_max_size = 1	
		or next_growth_fills_drive = 1	
		and current_used_pc > 50
		and db != 'ANPRArchive'
				  FOR XML PATH('tr'), TYPE   
		) AS NVARCHAR(MAX) ) +  
		N'</table>' ;  
  
	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name =  'RSUKAZSVRSQL4',        
		@recipients='dbasupport@groupnexus.co.uk',  
		@subject = 'File about to fill',  
		@body = @tableHTML,  
		@body_format = 'HTML' ;  	

end

end











select db
	, file_id
	, size_mb
	, growth	
	, size_mb*(growth*0.01) as inc
	, size_mb + (size_mb*(growth*0.01)) as target_total
from #files_raw
where is_percent_growth = 1




	