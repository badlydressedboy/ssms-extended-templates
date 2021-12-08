--to varchar
SET @retentiondate = CONVERT(varchar(8), GETDATE(), 112) 

--to an int
SET @retentiondate = CONVERT(INT,CONVERT(varchar(8), GETDATE(), 112) )