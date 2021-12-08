--SERVER LOGINS   
Use master
GO
SELECT PRINCIPAL_ID AS [Principal ID],
 NAME AS [User],
 TYPE_DESC AS [Type Description],
 IS_DISABLED AS [Status] 
FROM sys.server_principals 
GO

--SERVER ROLES
Use master
GO
SELECT 
 SSP.name AS [Login Name],
 SSP.type_desc AS [Login Type],
 UPPER(SSPS.name) AS [Server Role]
FROM sys.server_principals SSP 
INNER JOIN sys.server_role_members SSRM
ON SSP.principal_id=SSRM.member_principal_id 
INNER JOIN sys.server_principals SSPS 
ON SSRM.role_principal_id = SSPS.principal_id
GO


