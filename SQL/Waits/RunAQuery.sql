/*============================================================================
  File:     ExtendedEvents.sql

  Summary:  Example query for wait stats tracking.

  Date:     October 2010, MCM

  SQL Server Version: 10.0.2531.0 (SQL Server 2008 SP1)
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE MASTER;
GO

IF DATABASEPROPERTYEX ('production', 'Version') > 0
	DROP DATABASE production;
GO

CREATE DATABASE production;
GO

USE production;
GO

CREATE TABLE t1 (
	c1 INT IDENTITY,
	c2 UNIQUEIDENTIFIER ROWGUIDCOL DEFAULT NEWID(),
	c3 CHAR (5000) DEFAULT 'a');
CREATE CLUSTERED INDEX t1_CL ON t1 (c1);
CREATE NONCLUSTERED INDEX t1_NCL ON t1 (c2);
GO

SET NOCOUNT ON;
INSERT INTO t1 DEFAULT VALUES;
GO 2000

USE production;
GO

DBCC DROPCLEANBUFFERS;
GO

-- Get connection to put into XEvent
SELECT @@SPID;
GO

ALTER INDEX t1_CL ON t1 REBUILD;
GO