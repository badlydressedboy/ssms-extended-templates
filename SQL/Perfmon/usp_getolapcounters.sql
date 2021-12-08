--EXEC perfmon.dbo.usp_getolapcounters 'ssaslon12p10007'
--EXEC usp_getolapcounters 'ssaslon12u10007'
--EXEC usp_getolapcounters 'ssaslon12u10007', '2010-10-27 18:00:00'
--EXEC usp_getolapcounters 'ssaslon12u10007', '2010-10-27 18:00:00', '2010-10-27 18:15:00'

ALTER PROCEDURE usp_getolapcounters(
							  @servername varchar(200)
							, @startdatetime smalldatetime = NULL
							, @enddatetime smalldatetime = NULL)

AS
BEGIN
	IF @startdatetime IS NULL
		SET @startdatetime = DATEADD(Minute,-720,GETDATE())--12 hours ago

	IF @enddatetime IS NULL
		SET @enddatetime = GETDATE()
				
	--temp table needs to exist to help with required order by clause
	declare @formattedcounters table(CounterTime smalldatetime
			, ComputerName varchar(200)
			, cpu float--NUMERIC(3,2)
			, connections bigint
			, locks bigint
			, lockwaits bigint
			, MemUseageKb bigint
			, TRowsProcessed bigint
			, TQueries bigint)
	insert @formattedcounters

	select *
	from vw_formattedcounters

	select 
		  a.CounterTime
		, a.ComputerName
		, a.cpu
		, a.connections
		, a.locks
		, a.lockwaits	
		, a.TRowsProcessed - b.TRowsProcessed as RowsProcessed
		, a.TQueries - b.TQueries as QueriesComplete
		, a.MemUseageKb
	from 
		@formattedcounters a
	inner join 
		@formattedcounters b on a.countertime = dateadd(Minute,1,b.countertime)
		and a.computername = b.computername
	where 
		a.ComputerName = @servername	
		and a.CounterTime > @startdatetime
		and a.CounterTime <= @enddatetime						       
	ORDER BY 
		CounterTime desc
END		