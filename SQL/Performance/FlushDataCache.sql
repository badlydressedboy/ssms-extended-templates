/*
Queries that take a long time on first execution but are then quick could be doing so as the result set was
large and took time to read into the cache on 1st execution. Subsequent executions read from the data
cache until it is flushed. It can be flushed be a lot more data being cached from other queries.
This may be seen by a sproc for param x being slow then fast until param y is used, which fills the 
buffers with other pages, flushing out the param xs buffers. Then rerunning with param x is slow again.

If you need to take data caching out of the equasion for testing purposes then run the following:
*/

USE <YOURDATABASENAME>;
GO
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO

--This has the same effect as restarting the sql service