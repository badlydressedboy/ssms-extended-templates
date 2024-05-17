

declare @query_text_snippet nvarchar(1000) = 'template'
select p.plan_id, query_id, query_plan, count_executions, avg_duration*0.00001 avg_duration_sec, avg_cpu_time*0.00001 avg_cpu_time_sec, first_execution_time
from sys.query_store_plan p join sys.query_store_runtime_stats rs
	on p.plan_id = rs.plan_id
where query_plan LIKE '%'+@query_text_snippet+'%'
and rs.first_execution_time > dateadd(dd, -7, getdate())
and rs.last_execution_time < dateadd(minute, -60, getdate())--otherwise this query of query store may be included
and avg_duration > 100000 --microseconds, look for 1 second and over
order by avg_duration desc








--slow queries with missing index recommendations
select top 100
	p.plan_id, query_id, query_plan, count_executions, avg_duration*0.000001 avg_duration_sec, avg_cpu_time*0.000001 avg_cpu_time_sec, first_execution_time
from sys.query_store_plan p join sys.query_store_runtime_stats rs
	on p.plan_id = rs.plan_id
where query_plan like '%MissingIndexes%'
and rs.first_execution_time > dateadd(dd, -7, getdate())
and rs.last_execution_time < dateadd(minute, -120, getdate())--otherwise this query of query store may be included
and avg_duration > 10000 --microseconds, look for 1oo milliseonds and over
order by avg_duration desc


--slow queries with missing index recommendations for table x
declare @schema nvarchar(100) = 'dbo'
declare @table nvarchar(100) = 'notification'
declare @str nvarchar(1000) = '%MissingIndex Database="['+db_name()+']" Schema="['+@schema+']" Table="['+@table+']"%'
print @str

set @str = 'MissingIndex Database="[oct-oi-prd-uks-sqldb-notification-api]" Schema="[dbo]" Table="[notification]'

select top 100
	p.plan_id, query_id, query_plan, count_executions, avg_duration*0.00001 avg_duration_sec, avg_cpu_time*0.00001 avg_cpu_time_sec, first_execution_time
from sys.query_store_plan p join sys.query_store_runtime_stats rs
	on p.plan_id = rs.plan_id
where query_plan like '%MissingIndex Database="['+db_name()+']" Schema="['+@schema+']" Table="['+@table+']"%'
and rs.first_execution_time > dateadd(dd, -70, getdate())
and rs.last_execution_time < dateadd(minute, -120, getdate())--otherwise this query of query store may be included
--and avg_duration > 10000 --microseconds, look for 1oo milliseconds and over
order by avg_duration desc


--recommended indexes that would actually make tangeable difference
SELECT TOP 20
    CONVERT (varchar(30), getdate(), 126) AS runtime,
    CONVERT (decimal (28, 1), 
        migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) 
        ) AS estimated_improvement,
		migs.unique_compiles benefitted_compiles,--Compilations and recompilations of many different queries can contribute to this value.
		migs.user_seeks benefitted_seeks,--seeks index could have been used for 
		migs.user_scans benefitted_scans,--scans index could have been used for 
    'CREATE INDEX missing_index_2_1' + 
        CONVERT (varchar, mig.index_group_handle) + '_' + 
        CONVERT (varchar, mid.index_handle) + ' ON ' + 
        mid.statement + ' (' + ISNULL (mid.equality_columns, '') + 
        CASE
            WHEN mid.equality_columns IS NOT NULL
            AND mid.inequality_columns IS NOT NULL THEN ','
            ELSE ''
        END + ISNULL (mid.inequality_columns, '') + ')' + 
        ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
		statement as table_name
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON 
    migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON 
    mig.index_handle = mid.index_handle
WHERE (migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 100000 --tangeable benefit?
ORDER BY estimated_improvement DESC;

--CREATE INDEX missing_index_2_1 ON [oct-oi-prd-uks-sqldb-notification-api].[dbo].[template] ([platform_id], [name_tx], [delete_dttm], [default_ind])
--lookup existing index details
declare @tablename nvarchar(100) = 'template'
SELECT
	QUOTENAME(SCHEMA_NAME(t.schema_id)) AS SchemaName,
    QUOTENAME(t.name) AS TableName,
    QUOTENAME(i.name) AS IndexName,
	i.type_desc,
    i.is_primary_key,
    i.is_unique,
    i.is_unique_constraint,
    STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') AS KeyColumns,
    STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') AS IncludedColumns,
    u.user_seeks,
    u.user_scans,
    u.user_lookups,
    u.user_updates
FROM sys.tables AS t
INNER JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.dm_db_index_usage_stats AS u ON i.object_id = u.object_id AND i.index_id = u.index_id
WHERE t.is_ms_shipped = 0
AND i.type <> 0
AND t.name = @tablename



