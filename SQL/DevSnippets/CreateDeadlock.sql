
/*
--First run this code to create the tables
create table ##temp1 (col1 int)
create table ##temp2 (col1 int)

insert ##temp1 
Select 1 union select 2 union select 3

insert ##temp2
Select 1 union select 2 union select 3

select * from  ##temp1 
*/

/*
--Paste this code in an other QA window
--QA window #2
begin tran
	update ##temp2 set col1 = 4 where col1 = 3

	--delay long enough to lock ##temp2 in this process 
	--and allow ##temp1 to be locked in other process
	waitfor delay '0:0:05'

	--this proc is holding lock on ##temp2 waiting for ##temp1 to be released
	update ##temp1 set col1 = 4 where col1 = 3
commit tran
*/


--QA window #1
begin tran
	update ##temp1 set col1 = 4 where col1 = 3

	--delay long enough to lock ##temp1 in this process 
	--and allow ##temp2 to be locked in other process
	waitfor delay '0:0:05'

	--this proc is holding lock on ##temp1 waiting for ##temp2 to be released
	update ##temp2 set col1 = 4 where col1 = 3
commit tran

/*
sElect @@trancount
drop table ##temp1
drop table ##temp2
*/