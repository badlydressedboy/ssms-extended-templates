



delete 
	top (1) trp -- this alias HAS to be here AND TOP number must be in ()
from 
	TaskRequestParameter trp
inner join 
	TaskRequest tr
	on trp.TaskRequestId = tr.TaskRequestId
where 
	tr.RequestedTime < DateAdd(dd, -10, CURRENT_TIMESTAMP)
	

--example select statement	
select top 10 aliasinfromsection.* --this alias does NOT HAVE to be here and not () around top param
from TaskRequestParameter aliasinfromsection 	