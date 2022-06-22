; with cte as (
SELECT
  S.name AS schema_name,
  T.name AS table_name,
  C.name AS column_name,
  TY.name AS type_name,
  IT.information_type AS information_type,
  IT.label AS sensitivity_label

FROM sys.schemas AS S

JOIN sys.tables AS T
  ON T.schema_id = S.schema_id

JOIN sys.columns AS C
  ON C.object_id = T.object_id

JOIN sys.types AS TY
  ON TY.user_type_id = C.user_type_id

LEFT OUTER JOIN sys.sensitivity_classifications AS IT
  ON IT.major_id = C.object_id
  AND IT.minor_id = C.column_id
  )

  select * from cte 
  order by information_type, sensitivity_label
