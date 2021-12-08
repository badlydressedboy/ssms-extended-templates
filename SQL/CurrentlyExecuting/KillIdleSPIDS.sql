if object_Id( 'dbspKillIdleSpids') Is Not Null
 drop procedure dbspKillIdleSpids
go

CREATE procedure dbspKillIdleSpids
	@sec int = Null
as
/*
*************************************************************
Name: dbspKillIdleSpids
Description: kills connections that have been
inactive for @sec seconds. 

Usage: exec dbspKillIdleSpids <sec>

Author: Steve Jones - www.dkranch.net

Input Params:
-------------
@sec 	int. defaults to  Null, # seconds for connection to be
	idle to kill it.

Output Params:
--------------

Return: 0, no error. Raises error if no parameters sent in.

Results:
---------

Locals:
--------

Modifications:
--------------

*************************************************************
*/
declare @err int,
	 @spid int,
	 @cmd char( 100)

if @sec Is Null
 begin
  raiserror( 'Usage:exec dbspKillIdleSpids <sec>', 12, 1)
  return -1
 end

declare u_curs scroll insensitive cursor for
 select s.spid
  from master..sysprocesses s
  where ( datediff( ss, s.last_batch, getdate())) > @sec

open u_curs

fetch next from u_curs into @spid

while @@fetch_status = 0
 begin
  select @cmd = 'kill ' + convert( char( 4), @spid)
  print @cmd
  fetch next from u_curs into @spid
 end

deallocate U_curs
return
GO


