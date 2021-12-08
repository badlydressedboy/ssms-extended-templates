--amount of space the version store is using
SELECT version_store_in_kb = version_store_reserved_page_count*8192/1024 
FROM sys.dm_db_file_space_usage



--related objects
select * from sys.dm_tran_active_snapshot_database_transactions
select * from sys.dm_tran_transactions_snapshot
select * from sys.dm_tran_current_transaction
select * from sys.dm_tran_current_snapshot
select db_name(database_id), * from sys.dm_tran_top_version_generators
select * from sys.dm_tran_version_store