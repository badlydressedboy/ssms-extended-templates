SELECT *
from sys.traces where is_default = 1 

SELECT  *
FROM    sys.configurations
WHERE   configuration_id = 1568

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO

select traceid, property, value from fn_trace_getinfo(NULL)

SELECT *   FROM ::fn_trace_getinfo(default)