USE [TraceDB];
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[OLAPProfilerEventClass]([EventClassID], [Name], [Description])
SELECT 1, N'Audit Login', N'Collects all new connection events since the trace was started, such as when a client requests a connection to a server running an instance of SQL Server.' UNION ALL
SELECT 2, N'Audit Logout', N'Collects all new disconnect events since the trace was started, such as when a client issues a disconnect command.' UNION ALL
SELECT 4, N'Audit Server Starts And Stops', N'Records service shut down, start, and pause activities.' UNION ALL
SELECT 5, N'Progress Report Begin', N'Progress report begin.' UNION ALL
SELECT 6, N'Progress Report End', N'Progress report end.' UNION ALL
SELECT 7, N'Progress Report Current', N'Progress report current.' UNION ALL
SELECT 8, N'Progress Report Error', N'Progress report error.' UNION ALL
SELECT 9, N'Query Begin', N'Query begin.' UNION ALL
SELECT 10, N'Query End', N'Query end.' UNION ALL
SELECT 11, N'Query Subcube', N'Query subcube, for Usage Based Optimization.' UNION ALL
SELECT 12, N'Query Subcube Verbose', N'Query subcube with detailed information. This event may have a negative impact on performance when turned on.' UNION ALL
SELECT 15, N'Command Begin', N'Command begin.' UNION ALL
SELECT 16, N'Command End', N'Command end.' UNION ALL
SELECT 17, N'Error', N'Server error.' UNION ALL
SELECT 18, N'Audit Object Permission Event', N'Records object permission changes.' UNION ALL
SELECT 19, N'Audit Backup/Restore Event', N'Records server backup/restore.' UNION ALL
SELECT 33, N'Server State Discover Begin', N'Start of Server State Discover.' UNION ALL
SELECT 34, N'Server State Discover Data', N'Contents of the Server State Discover Response.' UNION ALL
SELECT 35, N'Server State Discover End', N'End of Server State Discover.' UNION ALL
SELECT 36, N'Discover Begin', N'Start of Discover Request.' UNION ALL
SELECT 38, N'Discover End', N'End of Discover Request.' UNION ALL
SELECT 39, N'Notification', N'Notification event.' UNION ALL
SELECT 40, N'User Defined', N'User defined Event.' UNION ALL
SELECT 41, N'Existing Connection', N'Existing user connection.' UNION ALL
SELECT 42, N'Existing Session', N'Existing session.' UNION ALL
SELECT 43, N'Session Initialize', N'Session Initialize.' UNION ALL
SELECT 50, N'Deadlock', N'Metadata locks deadlock.' UNION ALL
SELECT 51, N'Lock timeout', N'Metadata lock timeout.' UNION ALL
SELECT 60, N'Get Data From Aggregation', N'Answer query by getting data from aggregation. This event may have a negative impact on performance when turned on.' UNION ALL
SELECT 61, N'Get Data From Cache', N'Answer query by getting data from one of the caches. This event may have a negative impact on performance when turned on.' UNION ALL
SELECT 70, N'Query Cube Begin', N'Query cube begin.' UNION ALL
SELECT 71, N'Query Cube End', N'Query cube end.' UNION ALL
SELECT 72, N'Calculate Non Empty Begin', N'Calculate non empty begin.' UNION ALL
SELECT 73, N'Calculate Non Empty Current', N'Calculate non empty current.' UNION ALL
SELECT 74, N'Calculate Non Empty End', N'Calculate non empty end.' UNION ALL
SELECT 75, N'Serialize Results Begin', N'Serialize results begin.' UNION ALL
SELECT 76, N'Serialize Results Current', N'Serialize results current.' UNION ALL
SELECT 77, N'Serialize Results End', N'Serialize results end.' UNION ALL
SELECT 78, N'Execute MDX Script Begin', N'Execute MDX script begin.' UNION ALL
SELECT 79, N'Execute MDX Script Current', N'Execute MDX script current.' UNION ALL
SELECT 80, N'Execute MDX Script End', N'Execute MDX script end.' UNION ALL
SELECT 81, N'Query Dimension', N'Query dimension.'
COMMIT;
RAISERROR (N'[dbo].[OLAPProfilerEventClass]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

