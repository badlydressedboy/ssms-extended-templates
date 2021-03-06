
/****** Object:  Role [RePro User]    Script Date: 08/19/2009 10:50:57 ******/
CREATE ROLE [RePro User] AUTHORIZATION [dbo]
GO

grant execute on schema::dbo to [RePro User]
go


CREATE LOGIN [TONY] FROM WINDOWS
GO
--ADD LOGIN TO FIXED SERVER ROLE
EXEC sp_addsrvrolemember 'TONY', 'sysadmin';
GO

/****** Object:  User [CSFB\appFidOfficeCustomisation]    Script Date: 08/19/2009 10:50:57 ******/
CREATE USER [CSFB\appFidOfficeCustomisation] FOR LOGIN [CSFB\appFidOfficeCustomisation]
GO
EXEC sp_addrolemember N'RePro User', N'CSFB\appFidOfficeCustomisation'
GO

--SSAS DATABASE USERS
/****** Object:  User [CSFB\SLON12P10081$]    Script Date: 08/19/2009 10:50:57 ******/
CREATE USER [CSFB\SLON12P10081$] FOR LOGIN [CSFB\SLON12P10081$] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'RePro User', N'CSFB\SLON12P10081$'
GO

/*GRANT DIFF PERMS*/
grant VIEW SERVER STATE to [CSFB\bFIDLONPRIMODMNGR]
grant VIEW DATABASE STATE to [CSFB\bFIDLONPRIMODMNGR]
grant SHOWPLAN to [CSFB\bFIDLONPRIMODMNGR]
grant CREATE SCHEMA to [CSFB\bFIDLONPRIMODMNGR]
grant CREATE ROLE to [CSFB\bFIDLONPRIMODMNGR]
grant CREATE PROCEDURE to [CSFB\bFIDLONPRIMODMNGR]
grant CREATE FUNCTION to [CSFB\bFIDLONPRIMODMNGR]
grant BACKUP LOG to [CSFB\bFIDLONPRIMODMNGR]
grant BACKUP DATABASE to [CSFB\bFIDLONPRIMODMNGR]



