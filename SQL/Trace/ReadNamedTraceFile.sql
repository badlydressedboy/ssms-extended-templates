select *          
FROM ::fn_trace_gettable('E:\MSSQL\MSSQL10_50.TIBDB_RISK_DEV\MSSQL\Log\log_28.trc',0)          
where TextData is not null
order by StartTime desc