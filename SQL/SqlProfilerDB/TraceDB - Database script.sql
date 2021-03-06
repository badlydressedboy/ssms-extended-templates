USE [TraceDB]
GO
/****** Object:  User [CSFB\sysFIDlonIRPpanDev]    Script Date: 10/19/2009 10:04:47 ******/
CREATE USER [CSFB\sysFIDlonIRPpanDev] FOR LOGIN [CSFB\sysFIDlonIRPpanDev] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [CSFB\sysFIDLonFIDIRPpan]    Script Date: 10/19/2009 10:04:47 ******/
CREATE USER [CSFB\sysFIDLonFIDIRPpan] FOR LOGIN [CSFB\sysFIDLonFIDIRPpan] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [CSFB\bFIDLONPRIMODRW]    Script Date: 10/19/2009 10:04:47 ******/
CREATE USER [CSFB\bFIDLONPRIMODRW] FOR LOGIN [CSFB\bFIDLONPRIMODRW]
GO
/****** Object:  Table [dbo].[TaskRequests]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TaskRequests](
	[TaskRequestId] [uniqueidentifier] NOT NULL,
	[ParentTaskRequestId] [uniqueidentifier] NULL,
	[CorrelationId] [uniqueidentifier] NULL,
	[TaskName] [varchar](255) NULL,
	[Status] [varchar](50) NULL,
	[RequestedTime] [datetime] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[TaskInfoPath] [varchar](512) NULL,
	[RequestedBy] [varchar](50) NULL,
	[RunningOn] [varchar](50) NULL,
	[ProcessId] [varchar](50) NULL,
	[Channel] [varchar](255) NULL,
	[HasErrors] [bit] NULL,
	[HasWarnings] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TaskRequestParameters]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TaskRequestParameters](
	[TaskRequestId] [uniqueidentifier] NOT NULL,
	[ParameterName] [varchar](255) NOT NULL,
	[Value] [sql_variant] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SQLEventIDs]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SQLEventIDs](
	[ID] [int] NULL,
	[Description] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OLAPProfilerEventSubClass]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OLAPProfilerEventSubClass](
	[EventClassID] [int] NOT NULL,
	[EventSubClassID] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProfilerEventSubClass] PRIMARY KEY CLUSTERED 
(
	[EventClassID] ASC,
	[EventSubClassID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OLAPProfilerEventClass]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OLAPProfilerEventClass](
	[EventClassID] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_ProfilerEventClass] PRIMARY KEY CLUSTERED 
(
	[EventClassID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ASTraceTable]    Script Date: 10/19/2009 10:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ASTraceTable](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[ClientProcessID] [int] NULL,
	[ConnectionID] [int] NULL,
	[CurrentTime] [datetime] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[EventSubclass] [int] NULL,
	[NTCanonicalUserName] [nvarchar](128) NULL,
	[NTDomainName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[RequestParameters] [ntext] NULL,
	[RequestProperties] [ntext] NULL,
	[SPID] [int] NULL,
	[ServerName] [nvarchar](128) NULL,
	[SessionID] [nvarchar](128) NULL,
	[SessionType] [nvarchar](128) NULL,
	[StartTime] [datetime] NULL,
	[TextData] [ntext] NULL,
	[CPUTime] [bigint] NULL,
	[Duration] [bigint] NULL,
	[EndTime] [datetime] NULL,
	[Error] [int] NULL,
	[Severity] [int] NULL,
	[Success] [int] NULL,
	[ClientHostName] [nvarchar](128) NULL,
	[BinaryData] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_AllTaskRequests]    Script Date: 10/19/2009 10:04:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[vw_AllTaskRequests]
AS
WITH PartitionedData AS
(
	SELECT *, ROW_NUMBER() OVER 
	(
		PARTITION BY	TaskRequestId
		ORDER BY		EndTime DESC
	) RowCounter
	FROM TaskRequests
)

SELECT * FROM PartitionedData WHERE RowCounter = 1
GO
/****** Object:  View [dbo].[vw_AllActivity]    Script Date: 10/19/2009 10:04:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[vw_AllActivity]
AS
select 
	rownumber,
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
/****** Object:  View [dbo].[vw_NoBegins]    Script Date: 10/19/2009 10:04:49 ******/
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
/****** Object:  View [dbo].[vw_LatestActivity]    Script Date: 10/19/2009 10:04:48 ******/
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
/****** Object:  View [dbo].[vw_Slowest]    Script Date: 10/19/2009 10:04:49 ******/
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
/****** Object:  View [dbo].[vw_LatestActivityNoBegins]    Script Date: 10/19/2009 10:04:49 ******/
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
