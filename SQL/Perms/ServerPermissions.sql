



--SERVER PERMISSIONS
SELECT 
	prin.name
	, prin.type_desc
	, permission_name
	, create_date 
	, modify_date
	--,* 
FROM 
	sys.server_permissions perms
inner join 
	sys.server_principals prin
on
	perms.grantee_principal_id = prin.principal_id	
order by
	prin.name	

