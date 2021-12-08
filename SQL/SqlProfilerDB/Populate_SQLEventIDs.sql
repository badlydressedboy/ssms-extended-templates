USE [TraceDB];
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[SQLEventIDs]([ID], [Description])
SELECT 0, N'Reserved' UNION ALL
SELECT 1, N'Reserved' UNION ALL
SELECT 2, N'Reserved' UNION ALL
SELECT 3, N'Reserved' UNION ALL
SELECT 4, N'Reserved' UNION ALL
SELECT 5, N'Reserved' UNION ALL
SELECT 6, N'Reserved' UNION ALL
SELECT 7, N'Reserved' UNION ALL
SELECT 8, N'Reserved' UNION ALL
SELECT 9, N'Reserved' UNION ALL
SELECT 10, N'RPC:Completed' UNION ALL
SELECT 11, N'RPC:Starting' UNION ALL
SELECT 12, N'SQL:BatchCompleted' UNION ALL
SELECT 13, N'SQL:BatchStarting' UNION ALL
SELECT 14, N'Login' UNION ALL
SELECT 15, N'Logout' UNION ALL
SELECT 16, N'Attention' UNION ALL
SELECT 17, N'ExistingConnection' UNION ALL
SELECT 18, N'ServiceControl' UNION ALL
SELECT 19, N'DTCTransaction' UNION ALL
SELECT 20, N'Login Failed' UNION ALL
SELECT 21, N'EventLog' UNION ALL
SELECT 22, N'ErrorLog' UNION ALL
SELECT 23, N'Lock:Released' UNION ALL
SELECT 24, N'Lock:Acquired' UNION ALL
SELECT 25, N'Lock:Deadlock' UNION ALL
SELECT 26, N'Lock:Cancel' UNION ALL
SELECT 27, N'Lock:Timeout' UNION ALL
SELECT 28, N'DOP Event' UNION ALL
SELECT 29, N'Reserved' UNION ALL
SELECT 30, N'Reserved' UNION ALL
SELECT 31, N'Reserved' UNION ALL
SELECT 32, N'Reserved' UNION ALL
SELECT 33, N'Exception' UNION ALL
SELECT 34, N'SP:CacheMiss' UNION ALL
SELECT 35, N'SP:CacheInsert' UNION ALL
SELECT 36, N'SP:CacheRemove' UNION ALL
SELECT 37, N'SP:Recompile' UNION ALL
SELECT 38, N'SP:CacheHit' UNION ALL
SELECT 39, N'SP:ExecContextHit' UNION ALL
SELECT 40, N'SQL:StmtStarting' UNION ALL
SELECT 41, N'SQL:StmtCompleted' UNION ALL
SELECT 42, N'SP:Starting' UNION ALL
SELECT 43, N'SP:Completed' UNION ALL
SELECT 44, N'SP:StmtStarting' UNION ALL
SELECT 45, N'SP:StmtCompleted' UNION ALL
SELECT 46, N'Object:Created' UNION ALL
SELECT 47, N'Object:Deleted' UNION ALL
SELECT 48, N'Reserved' UNION ALL
SELECT 49, N'Reserved'
COMMIT;
RAISERROR (N'[dbo].[SQLEventIDs]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[SQLEventIDs]([ID], [Description])
SELECT 50, N'SQL Transaction' UNION ALL
SELECT 51, N'Scan:Started' UNION ALL
SELECT 52, N'Scan:Stopped' UNION ALL
SELECT 53, N'CursorOpen' UNION ALL
SELECT 54, N'Transaction Log' UNION ALL
SELECT 55, N'Hash Warning' UNION ALL
SELECT 56, N'Reserved' UNION ALL
SELECT 57, N'Reserved' UNION ALL
SELECT 58, N'Auto Update Stats' UNION ALL
SELECT 59, N'Lock:Deadlock Chain' UNION ALL
SELECT 60, N'Lock:Escalation' UNION ALL
SELECT 61, N'OLE DB Errors' UNION ALL
SELECT 62, N'Reserved' UNION ALL
SELECT 63, N'Reserved' UNION ALL
SELECT 64, N'Reserved' UNION ALL
SELECT 65, N'Reserved' UNION ALL
SELECT 66, N'Reserved' UNION ALL
SELECT 67, N'Execution Warnings' UNION ALL
SELECT 68, N'Execution Plan' UNION ALL
SELECT 69, N'Sort Warnings' UNION ALL
SELECT 70, N'CursorPrepare' UNION ALL
SELECT 71, N'Prepare SQL' UNION ALL
SELECT 72, N'Exec Prepared SQL' UNION ALL
SELECT 73, N'Unprepare SQL' UNION ALL
SELECT 74, N'CursorExecute' UNION ALL
SELECT 75, N'CursorRecompile' UNION ALL
SELECT 76, N'CursorImplicitConversion' UNION ALL
SELECT 77, N'CursorUnprepare' UNION ALL
SELECT 78, N'CursorClose' UNION ALL
SELECT 79, N'Missing Column Statistics' UNION ALL
SELECT 80, N'Missing Join Predicate' UNION ALL
SELECT 81, N'Server Memory Change' UNION ALL
SELECT 82, N'User Configurable 0' UNION ALL
SELECT 83, N'User Configurable 1' UNION ALL
SELECT 84, N'User Configurable 2' UNION ALL
SELECT 85, N'User Configurable 3' UNION ALL
SELECT 86, N'User Configurable 4' UNION ALL
SELECT 87, N'User Configurable 5' UNION ALL
SELECT 88, N'User Configurable 6' UNION ALL
SELECT 89, N'User Configurable 7' UNION ALL
SELECT 90, N'User Configurable 8' UNION ALL
SELECT 91, N'User Configurable 9' UNION ALL
SELECT 92, N'Data File Auto Grow' UNION ALL
SELECT 93, N'Log File Auto Grow' UNION ALL
SELECT 94, N'Data File Auto Shrink' UNION ALL
SELECT 95, N'Log File Auto Shrink' UNION ALL
SELECT 96, N'Show Plan Text' UNION ALL
SELECT 97, N'Show Plan ALL' UNION ALL
SELECT 98, N'Show Plan Statistics' UNION ALL
SELECT 99, N'Reserved'
COMMIT;
RAISERROR (N'[dbo].[SQLEventIDs]: Insert Batch: 2.....Done!', 10, 1) WITH NOWAIT;
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[SQLEventIDs]([ID], [Description])
SELECT 100, N'RPC Output Parameter' UNION ALL
SELECT 101, N'Reserved' UNION ALL
SELECT 102, N'Audit Statement GDR' UNION ALL
SELECT 103, N'Audit Object GDR' UNION ALL
SELECT 104, N'Audit Add/Drop Login' UNION ALL
SELECT 105, N'Audit Login GDR' UNION ALL
SELECT 106, N'Audit Login Change Property' UNION ALL
SELECT 107, N'Audit Login Change Password' UNION ALL
SELECT 108, N'Audit Add Login to Server Role' UNION ALL
SELECT 109, N'Audit Add DB User' UNION ALL
SELECT 110, N'Audit Add Member to DB' UNION ALL
SELECT 111, N'Audit Add/Drop Role' UNION ALL
SELECT 112, N'App Role Pass Change' UNION ALL
SELECT 113, N'Audit Statement Permission' UNION ALL
SELECT 114, N'Audit Object Permission' UNION ALL
SELECT 115, N'Audit Backup/Restore' UNION ALL
SELECT 116, N'Audit DBCC' UNION ALL
SELECT 117, N'Audit Change Audit' UNION ALL
SELECT 118, N'Audit Object Derived
Permission'
COMMIT;
RAISERROR (N'[dbo].[SQLEventIDs]: Insert Batch: 3.....Done!', 10, 1) WITH NOWAIT;
GO

