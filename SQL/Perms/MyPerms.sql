SELECT *
FROM fn_my_permissions(NULL, 'SERVER');
GO 

--returns 1 when has perm
SELECT HAS_PERMS_BY_NAME(null, null, 'VIEW SERVER STATE');
