select schema_name(schema_id) as [schema]
	, so.name table_name
	, si.name index_name
    , modify_date   
from sys.objects so
	inner join sys.indexes si on so.object_id = si.object_id
where is_ms_shipped = 0
order by modify_date desc