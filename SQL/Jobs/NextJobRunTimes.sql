
select * from 
(
	select 
		CASE SJ.next_run_date
        WHEN 0 THEN cast('n/a' as char(10))
        ELSE convert(char(10), convert(datetime, convert(char(8),SJ.next_run_date)),120)  + ' ' + left(stuff((stuff((replicate('0', 6 - len(next_run_time)))+ convert(varchar(6),next_run_time),3,0,':')),6,0,':'),8)
    END AS NextRunTime
    ,S.name AS JobName,
    SS.name AS ScheduleName,                    
    CASE(SS.freq_type)
        WHEN 1  THEN 'Once'
        WHEN 4  THEN 'Daily'
        WHEN 8  THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Weeks'  else 'Weekly'  end)
        WHEN 16 THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' else 'Monthly' end)
        WHEN 32 THEN 'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' -- RELATIVE
        WHEN 64 THEN 'SQL Startup'
        WHEN 128 THEN 'SQL Idle'
        ELSE '??'
    END AS Frequency,  
    CASE
        WHEN (freq_type = 1)                       then 'One time only'
        WHEN (freq_type = 4 and freq_interval = 1) then 'Every Day'
        WHEN (freq_type = 4 and freq_interval > 1) then 'Every ' + convert(varchar(10),freq_interval) + ' Days'
        WHEN (freq_type = 8) then (select 'Weekly Schedule' = MIN(D1+ D2+D3+D4+D5+D6+D7 )
                                    from (select SS.schedule_id,
                                                    freq_interval, 
                                                    'D1' = CASE WHEN (freq_interval & 1  <> 0) then 'Sun ' ELSE '' END,
                                                    'D2' = CASE WHEN (freq_interval & 2  <> 0) then 'Mon '  ELSE '' END,
                                                    'D3' = CASE WHEN (freq_interval & 4  <> 0) then 'Tue '  ELSE '' END,
                                                    'D4' = CASE WHEN (freq_interval & 8  <> 0) then 'Wed '  ELSE '' END,
                                                'D5' = CASE WHEN (freq_interval & 16 <> 0) then 'Thu '  ELSE '' END,
                                                    'D6' = CASE WHEN (freq_interval & 32 <> 0) then 'Fri '  ELSE '' END,
                                                    'D7' = CASE WHEN (freq_interval & 64 <> 0) then 'Sat '  ELSE '' END
                                                from msdb..sysschedules ss
                                            where freq_type = 8
                                        ) as F
                                    where schedule_id = SJ.schedule_id
                                )
        WHEN (freq_type = 16) then 'Day ' + convert(varchar(2),freq_interval) 
        WHEN (freq_type = 32) then (select  freq_rel + WDAY 
                                    from (select SS.schedule_id,
                                                    'freq_rel' = CASE(freq_relative_interval)
                                                                WHEN 1 then 'First'
                                                                WHEN 2 then 'Second'
                                                                WHEN 4 then 'Third'
                                                                WHEN 8 then 'Fourth'
                                                                WHEN 16 then 'Last'
                                                                ELSE '??'
                                                                END,
                                                'WDAY'     = CASE (freq_interval)
                                                                WHEN 1 then ' Sun'
                                                                WHEN 2 then ' Mon'
                                                                WHEN 3 then ' Tue'
                                                                WHEN 4 then ' Wed'
                                                                WHEN 5 then ' Thu'
                                                                WHEN 6 then ' Fri'
                                                                WHEN 7 then ' Sat'
                                                                WHEN 8 then ' Day'
                                                                WHEN 9 then ' Weekday'
                                                                WHEN 10 then ' Weekend'
                                                                ELSE '??'
                                                                END
                                            from msdb..sysschedules SS
                                            where SS.freq_type = 32
                                            ) as WS 
                                    where WS.schedule_id = SS.schedule_id
                                    ) 
    END AS Interval,
    CASE (freq_subday_type)
        WHEN 1 then   left(stuff((stuff((replicate('0', 6 - len(active_start_time)))+ convert(varchar(6),active_start_time),3,0,':')),6,0,':'),8)
        WHEN 2 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' seconds'
        WHEN 4 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' minutes'
        WHEN 8 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' hours'
        ELSE '??'
    END AS [Time]
    , [AvgDurationSec] = CONVERT(int, [jobhistory].[AvgDuration])    
	, RIGHT('00'+CONVERT(VARCHAR(10), [jobhistory].[AvgDuration]/3600)  ,2) 
    +':' 
    + RIGHT('00'+CONVERT(VARCHAR(20),( [jobhistory].[AvgDuration]%3600)/60),2) 
    +':' 
    + RIGHT('00'+CONVERT(VARCHAR(20), [jobhistory].[AvgDuration]%60),2) AS [AvgDuration]
from msdb.dbo.sysjobs S
inner join msdb.dbo.sysjobschedules SJ on S.job_id = SJ.job_id  
inner join msdb.dbo.sysschedules SS on SS.schedule_id = SJ.schedule_id
LEFT OUTER JOIN 
                    (   SELECT   [job_id], [AvgDuration] = convert(int,(SUM(((isnull([run_duration],0) / 10000 * 3600) + 
                                                                ((isnull([run_duration],0) % 10000) / 100 * 60) + 
                                                                 (isnull([run_duration],0) % 10000) % 100)) * 1.0) / COUNT([job_id]))
																
                        FROM     [msdb].[dbo].[sysjobhistory] WITh(NOLOCK)
                        WHERE    [step_id] = 0 
                        GROUP BY [job_id]
                     ) AS [jobhistory] 
                 ON [jobhistory].[job_id] = s.[job_id]
where s.enabled = 1
and ss.enabled = 1
) a
where NextRunTime > getdate()
order by NextRunTime 


--select *  FROM     [msdb].[dbo].[sysjobhistory]

select DB_ID('ReportServer')



USE [master]
                  SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server , CONVERT(CHAR(100)
                , SERVERPROPERTY('MachineName')) AS MachineName
				, ISNULL(DB_ID('ReportServer'), 0) as SsrsDbId
				
				
				select top 300 * 
				from [ReportServer].[dbo].[ExecutionLog3]
				order by timestart desc
				
				[InstanceName], [ItemPath],
				 [UserName], [], 
				 [], [], 
				 [Parameters], [],
				  [], [],
				   [],
				    [],
					 [], 
					 [], [], 
					 [], [],
					  []


