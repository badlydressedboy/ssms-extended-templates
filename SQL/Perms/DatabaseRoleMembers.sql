
--DB ROLE MEMBERS	 - THIS does *NOT* list users not assigned to roles
select 
	dp.name AS role_name	
	, dpu.name AS member_name
	, dpu.type_desc as user_type
	, dp.create_date role_create_date
	, dp.modify_date role_modify_date
	, dpu.create_date user_create_date
	, dpu.modify_date user_modify_date
	--, * 
FROM
   sys.database_role_members as drm
RIGHT JOIN sys.database_principals as dp
    ON dp.principal_id = drm.role_principal_id
RIGHT JOIN sys.database_principals as dpu
    ON dpu.principal_id = drm.member_principal_id
WHERE
    drm.role_principal_id IS NOT NULL
    AND drm.member_principal_id IS NOT NULL
ORDER BY dp.name



--This contains all db users and roles even if roles have *NO* members
select * from sys.database_principals
order by type


--compare principals for 2 databases:
select 
	* 
from 
	tracedb_prod.sys.database_principals a
FULL JOIN
	tracedb_DEV.sys.database_principals b
ON
	a.name = b.name
AND
	a.type = b.type	
WHERE
	 A.name is null
	 

