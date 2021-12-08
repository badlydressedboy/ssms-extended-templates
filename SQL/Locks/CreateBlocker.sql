-- create a blocker
-- first query window
BEGIN TRAN

--USE AdventureWorks2008R2X

UPDATE Person.Address 
SET AddressLine2 = 'Test Address 2'
WHERE AddressID = 1

SELECT resource_type, request_mode, resource_description
FROM   sys.dm_tran_locks
WHERE  resource_type <> 'DATABASE'

--ROLLBACK

--second query window


UPDATE Person.Address 
SET AddressLine2 = 'Test Address 2'
WHERE AddressID = 1