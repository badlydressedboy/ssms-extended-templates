
SELECT *
FROM sys.trace_categories

SELECT *
FROM sys.trace_subclass_values

--Get trace Event Columns
SELECT 
     t.EventID,
     t.ColumnID,
     e.name AS Event_Descr,
     c.name AS Column_Descr
FROM ::fn_trace_geteventinfo(1) t
     INNER JOIN sys.trace_events e 
          ON t.eventID = e.trace_event_id
     INNER JOIN sys.trace_columns c 
          ON t.columnid = c.trace_column_id
          
