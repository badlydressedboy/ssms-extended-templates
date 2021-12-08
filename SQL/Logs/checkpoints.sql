SELECT 
   DB_NAME() AS DatabaseName
   , [Current LSN]
   , [Previous LSN]
   , Operation
   , [Checkpoint Begin]
   , [Checkpoint End]
   , [Dirty Pages] 
FROM fn_dblog(NULL, NULL) 
WHERE operation IN ( 'LOP_BEGIN_CKPT', 'LOP_END_CKPT') 

checkpoint

select * FROM fn_dblog(NULL, NULL) 