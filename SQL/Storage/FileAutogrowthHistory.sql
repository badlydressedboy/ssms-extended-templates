--Requires ALTER TRACE  
IF (select convert(int,value_in_use) from sys.configurations where name = 'default trace enabled' ) = 1
BEGIN
	declare @indx int ;
	declare @curr_tracefname varchar(500) ;
	declare @base_tracefname varchar(500) ;
					
	select @curr_tracefname = path from sys.traces where is_default = 1 ;
	set @curr_tracefname = reverse(@curr_tracefname);
	select @indx  = patindex('%\%', @curr_tracefname) ;
	set @curr_tracefname = reverse(@curr_tracefname) ;
	set @base_tracefname = left( @curr_tracefname,len(@curr_tracefname) - @indx) + '\log.trc' ;

	SELECT  (dense_rank() over (order by StartTime desc))%2 as l1
	,       convert(int, EventClass) as EventClass
	,       DatabaseName
	,       Filename
	,       (Duration/1000) as Duration
	,       StartTime
	,       EndTime
	,       (IntegerData*8.0/1024) as ChangeInSize
	FROM ::fn_trace_gettable( @base_tracefname, default )					
	WHERE ServerName = @@servername and EventClass between 92 and 95
	AND databasename not in ('tempdb', 'model', 'master', 'msdb')
	ORDER BY StartTime DESC ;
END     
ELSE
BEGIN
	select -1 as l1, 0 as EventClass, 0 DatabaseName, 0 as Filename, 0 as Duration, 0 as StartTime, 0 as EndTime,0 as ChangeInSize
END 