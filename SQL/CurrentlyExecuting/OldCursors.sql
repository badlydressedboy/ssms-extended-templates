--To find any cursors that have been open for more than 24 hours:

SELECT name, cursor_id, creation_time, c.session_id, login_name
FROM sys.dm_exec_cursors(0) AS c
 JOIN sys.dm_exec_sessions AS s
 ON c.session_id = s.session_id
WHERE DATEDIFF(hh, c.creation_time, GETDATE()) > 24;