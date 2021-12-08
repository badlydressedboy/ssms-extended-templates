/******INSERT INTO TOP OF TEST CODE*****/
declare @message varchar(500)
declare @starttime datetime
declare @stepstarttime datetime
set @starttime = getdate()
set @stepstarttime = getdate()
/***************************************/


--CREATE THESE 2 PROCEDURES--------------------------------------------
alter PROCEDURE usp_PrintTestStepInfo (@stepname varchar(100), @starttime datetime, @stepstarttime datetime OUTPUT)
AS
BEGIN
	
	DECLARE @now datetime
	DECLARE @steptime bigint
	SET @steptime = datediff(ms,@stepstarttime,GETDATE())
	SET @now = GETDATE()
	
	IF OBJECT_ID('TEMPDB..PerfTestData') is null
		CREATE TABLE TEMPDB..PerfTestData(stepname varchar(500), time bigint)
	
	INSERT TEMPDB..PerfTestData
	VALUES (@stepname, @steptime)
	
	declare @message varchar(500)
	SET @message = @stepname + '; Step Time: ' + convert(varchar(20),@steptime) 
		+ ' Running Time: ' + convert(varchar(20), datediff(ms,@starttime,@now)) 		
	--RAISERROR(@message, 0, 1) WITH NOWAIT--this line can really increase exe times, only use if necessary
	
	SET @stepstarttime = @now
END


CREATE PROCEDURE usp_DisplayTestStepInfoPercentages 
AS
BEGIN

	DECLARE @totaltime float
	SET @totaltime = (select SUM(time) FROM TEMPDB..PerfTestData) * 1.0
	select @totaltime as totaltime
	
	SELECT stepname, time, cast((time/@totaltime)*100 as decimal(12,2)) as percentage 
	FROM TEMPDB..PerfTestData
	ORDER BY time desc
	
	DELETE FROM TEMPDB..PerfTestData
	
END
----------------------------------------------------------------------------------------

--USAGE
--CALL AFTER EVERY STEP IN TEST CODE
exec usp_PrintTestStepInfo '1', @starttime, @stepstarttime OUTPUT--increment message string as calls are made

--CALL AT THE END OF THE TEST CODE
exec usp_DisplayTestStepInfoPercentages


/**************NOTES************
The RAISERROR in usp_PrintTestStepInfo can fck exe time, it is expensive so only enable if totally necessary

This is the definitive time that should be used when performance testing

Actual execution plan query cost % does not take parrallelism into account and gives estimated cost based on 1 core
So is not a real 'timing' of the way the execution took place
The actual exe plan will tell you what operations were performed but the cost estimates arent that helpful

Use profiler if you need to verify timings
*******************************/


                