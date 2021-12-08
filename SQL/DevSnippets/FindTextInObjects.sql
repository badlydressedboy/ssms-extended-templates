/*
List of objects and their definitions (that contain certain text)
*/
select ObjType=type_desc 
   ,ObjName=schema_name(schema_id)+'.'+name
   ,ObjDefLink
from sys.objects
cross apply (select ObjDef=object_definition(object_id)) F1
cross apply (select ObjDefLink=(select [processing-instruction(q)]=':'+nchar(13)+ObjDef+nchar(13)
                for xml path(''),type)) F2
where type in ('P'       /* Procedures */
       ,'V'       /* Views */
       ,'TR'      /* Triggers */
       ,'FN','IF','TF' /* Functions */
       ) 
 and ObjDef like '%trades%' /* String to search for */ 
order by charindex('F',type) desc /* Group the function together */
    ,ObjType
    ,ObjName