SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
WITH XMLNAMESPACES
 
(DEFAULT
 
  'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 
SELECT
 
  query_plan AS CompleteQueryPlan,
 
  n.value('(@StatementText)[1]', 'VARCHAR(4000)')
 
  AS StatementText, n.value('(@StatementSubTreeCost)[1]',
 
  'VARCHAR(128)') AS StatementSubTreeCost, dm_ecp.usecounts
 
FROM sys.dm_exec_cached_plans AS dm_ecp
 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS dm_eqp
 
CROSS APPLY query_plan.nodes
 
  ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple')
 
  AS qp(n)
 
WHERE
 
n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1
 
GO
