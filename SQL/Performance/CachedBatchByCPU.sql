SELECT TOP 50 
      SUM(qs.total_worker_time) AS total_cpu_time, 
      SUM(qs.execution_count) AS total_execution_count,
      COUNT(1) AS  number_of_statements, 
      qs.sql_handle 
FROM sys.dm_exec_query_stats AS qs
GROUP BY qs.sql_handle
ORDER BY SUM(qs.total_worker_time) DESC


---agg cpu with text
SELECT 
      total_cpu_time, 
      total_execution_count,
      number_of_statements,
      s2.text
      --(SELECT SUBSTRING(s2.text, statement_start_offset / 2, ((CASE WHEN statement_end_offset = -1 THEN (LEN(CONVERT(NVARCHAR(MAX), s2.text)) * 2) ELSE statement_end_offset END) - statement_start_offset) / 2) ) AS query_text
FROM 
      (SELECT TOP 50 
            SUM(qs.total_worker_time) AS total_cpu_time, 
            SUM(qs.execution_count) AS total_execution_count,
            COUNT(*) AS  number_of_statements, 
            qs.sql_handle --,
            --MIN(statement_start_offset) AS statement_start_offset, 
            --MAX(statement_end_offset) AS statement_end_offset
      FROM 
            sys.dm_exec_query_stats AS qs
      GROUP BY qs.sql_handle
      ORDER BY SUM(qs.total_worker_time) DESC) AS stats
      CROSS APPLY sys.dm_exec_sql_text(stats.sql_handle) AS s2 