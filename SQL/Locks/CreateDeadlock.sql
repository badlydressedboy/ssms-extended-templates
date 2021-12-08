--Create 3 tables
create table t1 (c1 int, c2 varchar(50))
create table t2 (c1 int, c2 varchar(50))
create table t3 (c1 int, c2 varchar(50))
--Create 3 query windows in SQL Server Enterprise Manager.
--In the first query window execute
begin tran
insert into t1 select 1, 'abc' 

--In the second query window execute
begin tran
insert into t2 select 2, 'xyz'
Select * from t1

--The second query window will be waiting on the first query.
--In the third query window execute
begin tran
insert into t3 select 3, 'mno'
Select * from t2

--In the first query window execute
Select * from t3
--Now, query 1 will be waiting on query 3, which is waiting on query 2, which is waiting on query 1.  We have a deadlock.  You should notice that within a couple of seconds, one of the queries is cancelled and the transaction rolled back.