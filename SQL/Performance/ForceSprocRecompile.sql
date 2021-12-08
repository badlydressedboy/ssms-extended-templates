-- when a user calls a stored procedure, SQL Server does not create a new data access plan to retrieve the information from the database. The queries used by stored procedures are optimized only when they are compiled. As you make changes to the table structure or introduce new indexes which may optimize the data retrieval you should recompile your stored procedures as already compiled stored procedures may lose efficiency.

--do it in the sproc call
exec ui.usp_UI_GetJobListingForRunDate '2010-02-01' WITH RECOMPILE


--or in the sproc itself
CREATE PROCEDURE usp_MyProcedure WITH RECOMPILE
AS
Select SampleName, SampleDesc From SampleTable
GO


--or
exec sp_recompile sproc


