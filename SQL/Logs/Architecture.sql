/*
SIMPLE
The "Simple" recovery model is the most basic recovery model for SQL Server.  
Every transaction is still written to the transaction log, but once the transaction is complete 
and the data has been written to the data file the space that was used in the transaction log 
file is now re-usable by new transactions.


FULL
In addition, if the database is set to the full recovery model you need to also issue transaction log 
backups otherwise your database transaction log will continue to grow forever. 


BULK LOGGED
With this model there are certain bulk operations such as BULK INSERT, CREATE INDEX, SELECT INTO, etc... 
that are not fully logged in the transaction log and therefore do not take as much space in the transaction log.  
The advantage of using the "Bulk-logged" recovery model is that your transaction logs will not get that large 
if you are doing bulk operations and it still allows you to do point in time recovery as long as your last 
transaction log backup does not include a bulk operation as mentioned above.  
If no bulk operations are run this recovery model works the same as the Full recovery model.  
*/