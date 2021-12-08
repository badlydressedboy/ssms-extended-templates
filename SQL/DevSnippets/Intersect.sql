/*
A semi-join returns rows from the first input if there is as least one matching row in the second input. 
An anti-join returns rows from the first input if there are no matching rows in the second input. 
You use the EXCEPT and INTERSECT operators to perform semi-joins and anti-joins.
*/

--returns distinct values that occur in both lists
SELECT ProductID 
FROM Production.Product
INTERSECT ----------------------
SELECT ProductID 
FROM Production.WorkOrder ;


--returns distinct values that occur in first but NOT second
SELECT ProductID 
FROM Production.Product
EXCEPT -------------------------
SELECT ProductID 
FROM Production.WorkOrder 
