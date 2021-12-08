
DROP TABLE #tables
DROP TABLE #SpaceUsed
DECLARE @sql varchar(128)
CREATE TABLE #tables(name varchar(128))
	
INSERT
		#tables
SELECT
		TABLE_NAME
FROM
		INFORMATION_SCHEMA.TABLES
WHERE
		TABLE_TYPE = 'BASE TABLE'
	
CREATE TABLE
		#SpaceUsed
(
		name varchar(128)
	,	rows varchar(11)
	,	reserved varchar(18)
	,	data varchar(18)
	,	index_size varchar(18)
	,	unused varchar(18)
)

DECLARE @name varchar(128)

SELECT
		@name = ''
WHILE EXISTS
(
	SELECT
			*
	FROM
			#tables
	WHERE
			name > @name
)
BEGIN
	SELECT
			@name = min(name)
	FROM
			#tables
	WHERE
			name > @name

	SELECT @sql = 'exec sp_executesql N''insert #SpaceUsed exec sp_spaceused ' + @name + ''''
	EXEC (@sql)
END

SELECT
		* 
FROM
		#SpaceUsed
ORDER BY
		left( reserved, len(reserved) - 3) + 0 DESC
--		rows + 0 DESC