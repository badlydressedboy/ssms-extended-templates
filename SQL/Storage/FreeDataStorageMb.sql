--server free space - free space for every drive that is used by data files

DECLARE @drivefreespace TABLE(Drive CHAR(1), FreeMb bigint)
INSERT @drivefreespace EXEC ('exec xp_fixeddrives')

-- free and used storage by device------------------------------------------
SELECT 	 
	  x.Drive
	, AVG(x.FreeMb) as AvailableDataMb
	, sum(size)/128 UsedSizeMB
	, count(size) as Files
FROM 	
(
select 
	DFS.Drive
	, FreeMb
	, size	
FROM    sys.master_files DF
	INNER JOIN @drivefreespace DFS ON LEFT(DF.physical_name, 1) = DFS.Drive
) X
group by X.Drive




