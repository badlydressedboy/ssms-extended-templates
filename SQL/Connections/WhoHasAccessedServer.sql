SELECT 
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   Min(I.StartTime) as first_used,
   Max(I.StartTime) as last_used,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name
FROM
   sys.traces T CROSS Apply
   ::fn_trace_gettable(CASE 
                          WHEN CHARINDEX( '_',T.[path]) <> 0 THEN 
                               SUBSTRING(T.PATH, 1, CHARINDEX( '_',T.[path])-1) + '.trc' 
                          ELSE T.[path] 
                       End, T.max_files) I LEFT JOIN
   sys.server_principals S ON
       CONVERT(VARBINARY(MAX), I.loginsid) = S.sid  
WHERE
    T.id = 1 And
    I.LoginSid is not null
Group By
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name
   order by Max(I.StartTime) desc