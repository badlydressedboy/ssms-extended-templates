--SUMMARY
SELECT  SUBSTRING([name], 0, 40) as [Name], 
                (([size]*8)/1024) as SizeMB,
                CASE [growth]
                        WHEN 0 THEN 'Fixed Size'
                        ELSE
                                CASE [is_percent_growth]
                                        WHEN 0 THEN 'Absolute growth: ' + CAST([growth] as varchar)
                                        WHEN 1 THEN 'Percentage growth: ' + CAST([growth] as varchar)
                                END
                END as [GrowthInfo]
FROM    sys.database_files 
ORDER BY sizemb DESC


--More detail
--SP_HELPFILE


--MAX Detail
--SELECT  *
--FROM    sys.database_files



