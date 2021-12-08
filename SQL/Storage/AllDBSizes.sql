EXEC sp_MSforeachdb 'USE ?; EXEC sp_spaceused'


EXEC sp_MSforeachdb 'USE ? EXEC sp_helpfile;'


EXEC sp_MSforeachdb 'USE ?; PRINT DB_NAME()'