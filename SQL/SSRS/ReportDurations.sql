SELECT TOP 100
      [UserName]      
	  ,[TimeStart]
      ,[TimeEnd]
      , datediff(ms,[TimeStart],[TimeEnd]) AS duration 
      ,[TimeDataRetrieval]
      ,[TimeProcessing]
      ,[TimeRendering]
      , [TimeDataRetrieval] + [TimeProcessing] + [TimeRendering] as total_time      
      ,[ByteCount]
      ,[RowCount]      
      ,[RequestType]
      ,[Format]
      ,[Parameters]
      ,[ReportAction]
FROM [ReportServer$TIBDB_RISK_DEV].[dbo].[ExecutionLogStorage]  
where UserName not like '%eddy%'
order by timestart desc