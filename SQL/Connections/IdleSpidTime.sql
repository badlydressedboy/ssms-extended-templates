create table #sp_who2
( 	spid int
	, Status varchar( 50)
	, login varchar( 80)
	, hostname varchar( 80)
	, blkby varchar( 10)
	, dbanme varchar( 80)
	, command varchar( 500)
	, cputime int
	, diskio int
	, lastbatch varchar( 22)
	, programname varchar( 200)
	, spid2 int
	, requestid int
)
insert #sp_who2
	exec sp_who2
select
	spid, login, programname
			, datediff( ss, cast( 
	substring( lastbatch, 1, 5) +
	'/' + 
	cast( datepart( year, getdate()) as char( 4)) +
	' ' +
	substring( lastbatch, 7, 20) as datetime)
	, getdate() ) / (60*60*24) 'days'	
	
				, datediff( ss, cast( 
	substring( lastbatch, 1, 5) +
	'/' + 
	cast( datepart( year, getdate()) as char( 4)) +
	' ' +
	substring( lastbatch, 7, 20) as datetime)
	, getdate() ) / (60*60) 'hours'	
	
		, datediff( ss, cast( 
	substring( lastbatch, 1, 5) +
	'/' + 
	cast( datepart( year, getdate()) as char( 4)) +
	' ' +
	substring( lastbatch, 7, 20) as datetime)
	, getdate() ) / 60 'minutes'	
	
	, datediff( ss, cast( 
	substring( lastbatch, 1, 5) +
	'/' + 
	cast( datepart( year, getdate()) as char( 4)) +
	' ' +
	substring( lastbatch, 7, 20) as datetime)
	, getdate() ) 'seconds'
	

	

 from #sp_who2
 order by seconds
drop table #sp_who2

