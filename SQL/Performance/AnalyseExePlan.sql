/*A few key terms in plans

An index SCAN is where SQL server reads the whole of the index looking for matches - the time this takes is proportional to the size of the index.

An index SEEK is where SQL server uses the b-tree structure of the index to seek directly to matching records (see http://mattfleming.com/node/192 for an idea on how this works) - time taken is only proportional to the number of matching records.

    * In general an index seek is preferable to an index scan (when the number of matching records is proprtionally much lower than the total number of records), as the time taken to perform an index seek is constant regardless of the toal number of records in your table.
    * Note however that in certain situations an index scan can actually be faster than an index seek - usually when the table is very small, or when a large percentage of the records match the predicate

Clustered Index Update
	Even though a column that is NOT in the index is updated a c i update is performed - why?
	Tables come in two flavors: clustered indexes and heaps. You have a PRIMARY KEY constraint so you have created implicitly a clustered index. 
	You'd have to go to extra length during the table create for this not to happen. Any update of the 'table' is an update of the clustered index, since the clustered index is the table





*/






--THE EXE PLAN XML SHOULD BE SAVED TO A FILE TO GET ROUND ESCAPING QUOTES
DECLARE @plancontents VARCHAR(MAX)
SET @plancontents=(SELECT * FROM OPENROWSET(BULK 'C:\TEMP\Plan.XML', SINGLE_CLOB) x)
--Get rid of the namespace stuff
SET @plancontents=REPLACE(@plancontents,'xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan"','')
--Now put that into our XML variable
DECLARE @xml XML
SET @xml=@plancontents


-- go through all the execution plan nodes, get the attributes and sort on them
SELECT c.value('.[1]/@EstimatedTotalSubtreeCost', 'nvarchar(max)') as EstimatedTotalSubtreeCost,
       c.value('.[1]/@EstimateRows', 'nvarchar(max)') as EstimateRows,
       c.value('.[1]/@EstimateIO', 'nvarchar(max)') as EstimateIO,
       c.value('.[1]/@EstimateCPU', 'nvarchar(max)') as EstimateCPU,
       -- this returns just the node xml for easier inspection
       c.query('.') as ExecPlanNode        
FROM   -- this returns only nodes with the name RelOp even if they are children of children
       @xml.nodes('//child::RelOp') T(c)
ORDER BY EstimatedTotalSubtreeCost DESC


-- go through all the SQL Statements, get the attributes and sort on them
SELECT c.value('.[1]/@StatementText', 'nvarchar(max)') as StatementText,
       c.value('.[1]/@StatementSubTreeCost', 'nvarchar(max)') as StatementSubTreeCost,
       c.value('.[1]/@StatementEstRows', 'nvarchar(max)') as StatementEstimateRows,
       c.value('.[1]/@StatementOptmLevel', 'nvarchar(max)') as StatementOptimizationLevel,
       -- this returns just the statement xml for easier inspection
       c.query('.') as ExecPlanNode
FROM   -- this returns only nodes with the name StmtSimple
       @xml.nodes('//child::StmtSimple') T(c)
ORDER BY StatementSubTreeCost DESC