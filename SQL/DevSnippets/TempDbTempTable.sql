--use a ref to tempdb to create a temp table that can in turn be referenced from execing sql
IF object_id('tempdb..#DBInfo') IS NOT NULL
BEGIN
   DROP TABLE #DBInfo
END	
CREATE TABLE #DBInfo()



set @sql = 'UPDATE #DBInfo with x'
--exec

--finally get at temp table from normal context

select * from #dbinfo