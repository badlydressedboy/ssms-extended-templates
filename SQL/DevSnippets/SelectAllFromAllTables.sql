--read all data into buffers by selecting from every table in the db

dbcc dropcleanbuffers
go




declare @tables table(name varchar(200), [schema] varchar(50))
declare @name  varchar(200)
declare @schema  varchar(200)

insert @tables
select name, SCHEMA_NAME(schema_id)
from sys.tables

select * from @tables


declare @remaining int
select @remaining = 9999999

while @remaining > 0
begin
	exec usp_balls

	set @remaining = @remaining - 1

	waitfor delay '0:0:20'
end

