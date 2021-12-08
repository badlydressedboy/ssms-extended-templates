--select * from sys.dm_io_virtual_file_stats(null,null)

select sum(num_of_reads) as reads
	, sum(num_of_bytes_read) as bytes_read
	, sum(num_of_writes) as writes
	, sum(num_of_bytes_written) as bytes_written
from sys.dm_io_virtual_file_stats(db_id(),null)


