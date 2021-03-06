/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [StartTime]
      ,[CurrentTime]
      ,[Duration]
      ,[CPUTime]
      ,b.name as event
      ,c.name as subevent
      ,[TextData]
      ,[NTUserName]      
      ,[ConnectionID]
      ,[SPID]
      ,[ApplicationName]
      ,[IntegerData]
      ,[DatabaseName]
      ,[ObjectName]
      ,[Error]
      ,[ClientProcessID]
      ,[NTDomainName]
      ,[RequestParameters]
      ,[RequestProperties]
      ,[BinaryData]
      , eventclass
  FROM [SSASLogs].[dbo].[Uat_PerfTesting_20101013] a
  inner join OLAPProfilerEventClass b 
	on a.eventclass = b.eventclassid
	inner join dbo.OLAPProfilerEventSubClass c
	on a.eventsubclass = c.eventsubclassid
	and a.eventclass = c.eventclassid
  where starttime > '2010-10-13 10:51:00'  
--and starttime < '2010-10-13 10:57:00'    
--and eventclass not in (9,10,15,16)
--and databasename = 'repro_uat'
	and eventclass not in (35, 33, 39)
--order by duration desc


--no completed queries took more than 23 seconds








