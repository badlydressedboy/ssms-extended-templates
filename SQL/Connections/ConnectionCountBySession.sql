-- Connections by session\host\ip
SELECT es.login_name, es.[host_name], es.[program_name], 
COUNT(ec.session_id) AS [connection count], ec.client_net_address
FROM sys.dm_exec_sessions AS es  
INNER JOIN sys.dm_exec_connections AS ec  
ON es.session_id = ec.session_id   
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  
ORDER BY COUNT(ec.session_id) DESC, es.login_name
--ec.client_net_address, es.[program_name];