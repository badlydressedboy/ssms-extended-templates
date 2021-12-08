

SELECT
    GranteeName = grantee.name
    	, case dp.class_desc
          when 'SCHEMA' then schema_name(major_id)
          when 'OBJECT_OR_COLUMN' then
                          case when minor_id = 0 then object_name(major_id)
                           else (select object_name(object_id) + '.'+ name
                                  from sys.columns 
                                  where object_id = dp.major_id 
                                     and column_id = dp.minor_id) end
		  when 'DATABASE' then db_name(major_id)                                     
          else 'other' end as object_name
    , dp.class_desc
    , dp.permission_name
    , dp.state_desc	
	, GrantorName = grantor.name
FROM sys.database_permissions dp
JOIN sys.database_principals grantee on dp.grantee_principal_id = grantee.principal_id
JOIN sys.database_principals grantor on dp.grantor_principal_id = grantor.principal_id

