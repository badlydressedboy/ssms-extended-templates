--read all data into buffers by selecting from every table in the db

declare @tables table(name varchar(200), [schema] varchar(50))
declare @name  varchar(200)
declare @schema  varchar(200)

insert @tables
select name, SCHEMA_NAME(schema_id)
from sys.tables

select * from @tables


declare @remaining int
select @remaining = COUNT(*) from @tables

while @remaining > 0
begin
	select  top 1 @name = name, @schema = [schema] from @tables
	
	print 'truncate table ' + @schema + '.' + @name
	exec ('truncate table ' + @schema + '.' + @name)
	
	delete top (1) from @tables
	select @remaining = COUNT(*) from @tables

end