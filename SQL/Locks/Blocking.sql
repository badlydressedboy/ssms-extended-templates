set nocount on
declare @spid varchar(10)
declare @blkby varchar(10)
declare @stmt varchar(100)
if not exists ( select top 1 name from tempdb..sysobjects where name like '#temp%' )
begin
   create table #temp ( spid integer, status varchar(100), login varchar(50), hostname varchar(25), blkby varchar(10), 
                        dbname varchar(25), command varchar(100), cputime integer, diskio integer, lastbatch varchar(25), 
                        programname varchar(255), spid2 integer, requestid int )
end
else
begin
   truncate table #temp
end
insert into #temp
exec sp_who2

declare curs cursor for
select convert(varchar(10),spid), blkby from #temp where blkby not like '%.%'

open curs

fetch next from curs into @spid, @blkby
while @@fetch_status = 0
begin
   set @stmt = 'dbcc inputbuffer(' + @blkby + ')'
   raiserror('SPID:%s is Blocking with the following statement',0,1,@blkby) with nowait
   exec (@stmt)
   raiserror('SPID that is Blocked:%s',0,1,@spid) with nowait
   set @stmt = 'dbcc inputbuffer(' + convert(varchar(10), @spid) + ')'
   exec (@stmt)
   fetch next from curs into @spid, @blkby
end

close curs 

deallocate curs

--drop table #temp



