-- db specific query - will not run at server level
select name
    , modify_date
    , type_desc
    , object_name(parent_object_id) as parent
    , schema_name(schema_id) as [schema]
from sys.objects
where is_ms_shipped = 0
order by modify_date desc

--modify_date: Date the object was last modified by using an ALTER statement. 
--If the object is a table or a view, modify_date also changes when a clustered index on the table or view is created or altered.





