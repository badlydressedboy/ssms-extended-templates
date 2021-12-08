USE [TraceDB]
GO

/****** Object:  View [dbo].[vw_AllActivity]    Script Date: 10/08/2009 17:58:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_AllActivity]
AS
select 
	currenttime, 
	databasename, 
	EC.NAME AS eventclass, 
	esc.NAME AS eventsubclass, 
	ntusername, 
	duration, 
	textdata, 
	starttime, 
	endtime 
FROM [TraceDB].[dbo].[ASTraceTable] t
	INNER JOIN dbo.OLAPProfilerEventSubClass esc
		ON t.eventsubclass = esc.EventSubClassID
		AND t.eventclass = esc.EventClassID
	INNER JOIN dbo.OLAPProfilerEventClass ec
		ON t.eventclass = ec.EventClassID
GO



USE [TraceDB]
GO

/****** Object:  View [dbo].[vw_LatestActivity]    Script Date: 10/08/2009 17:58:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  CREATE view [dbo].[vw_LatestActivity]
  as
	select top 1000 *
	from vw_allactivity
	order by currenttime desc
GO


USE [TraceDB]
GO

/****** Object:  View [dbo].[vw_NoBegins]    Script Date: 10/08/2009 17:59:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_NoBegins]
as
SELECT * 
FROM vw_AllActivity
WHERE 		
	EventClass <> 'Command Begin'
AND	
	EventSubClass <> 'Query Begin'
GO



USE [TraceDB]
GO

/****** Object:  View [dbo].[vw_LatestActivityNoBegins]    Script Date: 10/08/2009 17:59:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_LatestActivityNoBegins]
as
select top 1000 *
from dbo.vw_NoBegins
order by currenttime desc
GO




USE [TraceDB]
GO

/****** Object:  View [dbo].[vw_Slowest]    Script Date: 10/08/2009 17:59:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_Slowest] 
as
SELECT     TOP (1000) *
FROM         dbo.vw_NoBegins
ORDER BY duration DESC
GO

