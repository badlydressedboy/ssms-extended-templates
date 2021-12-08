-- ALERTS
--files about to explode

DECLARE @FileFillThreshold int
SET @FileFillThreshold = 70


--get drive MB Free to equate that to drives used by files
DECLARE @drivefreespace TABLE(Drive CHAR(1), FreeMb bigint)
INSERT @drivefreespace EXEC ('exec xp_fixeddrives')
SELECT * FROM @drivefreespace

--Is there space for all threshold full files to increment?
--subquery necessary as multiple drives may be used
SELECT ISNULL(SUM(Y.FreeSpaceWarning),0) AS DBFreeSpaceWarning
FROM 
(
	SELECT 	 
		  x.Drive
		, SUM(x.MbNeededForNextGrowth) as TotalMbNeededForNextGrowth
		, AVG(x.FreeMb) as FreeMbAvailable
		, CASE
			WHEN AVG(x.FreeMb) < SUM(x.MbNeededForNextGrowth) THEN 1
			ELSE 0
		  END as FreeSpaceWarning
	FROM 	
	(select 
		DFS.Drive
		, FreeMb
		, CASE
			WHEN is_percent_growth = 1 THEN CONVERT(bigint,(size/128) * 1+(growth*0.01))
			ELSE growth/128				
		  END AS MbNeededForNextGrowth
	FROM    sys.database_files DF
		INNER JOIN @drivefreespace DFS ON LEFT(DF.physical_name, 1) = DFS.Drive
	WHERE
		((CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / (size/128.0)) * 100 > 70--@FileFillThreshold
		AND max_size = -1 --is this right?	
	) X
	group by X.Drive
) Y

SELECT  name
	, type_desc
	, LEFT(physical_name, 1) + '(' + CONVERT(VARCHAR(20), DFS.FreeMb) + 'Mb Free)' AS DRIVE	
	, size/128 as FileMb
	, CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128 as FileUsedMb
	, CONVERT(decimal(10,2) ,((CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / NULLIF((size/128.0),0)) * 100) as FileFullPc
	, max_size/128 as MaxFileMb
	, growth
	, is_percent_growth
  	, CASE 
		WHEN max_size = -1 THEN 
			CONVERT(decimal(20,2) ,(DFS.FreeMb / (size/128.0)))
		ELSE
			CONVERT(decimal(20,2) ,(((max_size/128.00)-(size/128)) / (size/128)) )
	  END as PossibleFileMultipleFactor	
	,  CASE
		WHEN is_percent_growth = 1 THEN CONVERT(bigint,(size/128) * (growth*0.01))
		ELSE growth/128				
	  END AS MbNeededForNextGrowth
	, CASE 
		WHEN (is_percent_growth = 1) AND (((DFS.FreeMb / NULLIF((size/128.0),0)) - 1) * 100 >= GROWTH) THEN 1		
		WHEN (is_percent_growth = 0) AND (DFS.FreeMb >= (GROWTH/128.0)) THEN 1		
		ELSE 0
	  END AS CanExpand
	, CASE 
		WHEN (((CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / NULLIF((size/128.0),0)) * 100) > @FileFillThreshold THEN 1
		ELSE 0
	  END as AboutToFill 	  
	, CASE 
		WHEN ((is_percent_growth = 1) AND (((DFS.FreeMb / NULLIF((size/128.0),0)) - 1) * 100 < GROWTH)) --can expand: looking for no FALSE
			AND ( (((CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / NULLIF((size/128.0),0)) * 100) > @FileFillThreshold) THEN 1 --about to fill: looking for TRUE	
		WHEN ((is_percent_growth = 0) AND (DFS.FreeMb < GROWTH))	--can expand: looking for no FALSE
			AND ( (((CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128) / NULLIF((size/128.0),0)) * 100) > @FileFillThreshold) THEN 1 --about to fill: looking for TRUE
		ELSE 0
	  END AS AboutToExplode
FROM    sys.database_files DF
	INNER JOIN @drivefreespace DFS ON LEFT(DF.physical_name, 1) = DFS.Drive
--where AboutToExplode = 1
order by size desc