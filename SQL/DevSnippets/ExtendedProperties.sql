
--view all ext props in db
SELECT class, class_desc, major_id, minor_id, name, value
FROM sys.extended_properties;
GO



SELECT t.name AS [Table Name]
FROM sys.extended_properties AS ep
INNER JOIN sys.tables AS t ON ep.major_id = t.object_id 
WHERE 
	ep.name = 'RePro_TableType'
	
	