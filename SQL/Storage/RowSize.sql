declare @table varchar(20)
declare @idcol varchar(10)
declare @sql varchar(1000)
select sum(max_length)
from sys.columns
where object_id = 112
--72,698





select * from sys.tables where name = 'incident'
