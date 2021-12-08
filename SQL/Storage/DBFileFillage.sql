--DB FILE FILLAGE
SELECT name
, size/128 AS TotalSizeMB
, CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128 as UsedMb
, size/128 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128 AS AvailableMB
, CONVERT(decimal(10,2) , (CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / (size/128.0) * 100) as UsedPc
FROM sys.database_files
ORDER BY CONVERT(decimal(10,2) , (CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / (size/128.0) * 100) DESC


