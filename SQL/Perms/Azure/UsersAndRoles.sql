SELECT 
    ISNULL(DP2.name, 'No members') AS DatabaseUserName
	, DP2.type_desc
	, DP1.name AS DatabaseRoleName
 
FROM sys.database_role_members AS DRM  
RIGHT OUTER JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id  
LEFT OUTER JOIN sys.database_principals AS DP2  ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
and DP2.name is not null
and DP2.name <> 'dbo'
ORDER BY DP2.type_desc, DP2.name, ISNULL(DP2.name, 'No members');


--CREATE USER [octopus_amlkyc_api_dev] FROM login octopus_amlkyc_api_dev;


