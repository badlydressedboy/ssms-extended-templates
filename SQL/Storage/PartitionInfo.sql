
SELECT *--fg.name as fg_name, ps.name as part_scheme_name, pf.name function_name, pf.type_desc as func_type, dds.*,  fanout, boundary_value_on_right
FROM sys.destination_data_spaces dds
INNER JOIN sys.partition_schemes ps
	ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
	ON ps.function_id = pf.function_id
INNER JOIN sys.filegroups fg
	ON dds.data_space_id = fg.data_space_id
	
	
	


SELECT * FROM sys.partition_schemes
SELECT * FROM sys.partition_functions
select * from sys.destination_data_spaces
select * from sys.filegroups



select * from sys.partition_range_values r, sys.partition_functions f
where r.function_id = f.function_id
  and f.name = 'fn_F_IrVega_Status'
  and r.boundary_id = (select max(boundary_id)-1 from sys.partition_range_values a 
						where a.function_id = r.function_id)


SELECT partition_id, p.object_id, p.partition_number, p.data_compression_desc
, p.rows, au.total_pages, au.used_pages, au.data_pages, au.type_desc
, fg.name fg_name, fg.type_desc fg_type
, rv2.value lower_value, rv.value upper_value 
--, ps.name
FROM sys.partitions p
JOIN sys.indexes i 
ON p.object_id = i.object_id 
and p.index_id = i.index_id 
INNER JOIN sys.allocation_units au
ON au.container_id = p.hobt_id
INNER JOIN sys.filegroups fg
ON fg.data_space_id = au.data_space_id
LEFT JOIN sys.partition_schemes ps 
ON ps.data_space_id = i.data_space_id 
LEFT JOIN sys.partition_functions f 
ON f.function_id = ps.function_id 
LEFT JOIN sys.partition_range_values rv 
ON f.function_id = rv.function_id 
AND p.partition_number = rv.boundary_id     
LEFT JOIN sys.partition_range_values rv2 
ON f.function_id = rv2.function_id 
AND p.partition_number - 1= rv2.boundary_id 
WHERE p.index_id in(0,1) 
AND au.type = 1 

