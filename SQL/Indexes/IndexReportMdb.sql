SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
                SET LOCK_TIMEOUT 1200000
		        select 	
                  object_name(i.object_id) as [table_name]
                , i.name as [index_name]
                , LEFT(index_type_desc, 4) as index_type_desc
                , p.partition_number
                , VALUE as part_range_value
                , CONVERT(int,ips.avg_fragmentation_in_percent) as avg_frag_pc
                , fragment_count
                , page_count 
                , CONVERT(DECIMAL(16,2),(page_count * 8)/1024.00) as sizeMb
                , index_depth
                , index_level
                , user_seeks as seeks
	            , user_scans as scans
	            , user_lookups as lookups
	            , user_updates as updates
	            , ISNULL(total_user_operations,0) as total_operations
	            , last_user_operation as last_operation
	            , CONVERT(VARCHAR(50),DATEDIFF(d,last_user_operation,getdate())) + 'd (' + CONVERT(VARCHAR(50),DATEDIFF(hh,last_user_operation,getdate())) + 'hrs)'  last_operation_age	
                , CONVERT(VARCHAR(50),STATS_DATE(i.OBJECT_ID, i.index_id)) AS stats_updated 
                , CONVERT(VARCHAR(50),DATEDIFF(hh,STATS_DATE(i.OBJECT_ID, i.index_id),getdate()))+ 'hrs (' + CONVERT(VARCHAR(50),DATEDIFF(d,STATS_DATE(i.OBJECT_ID, i.index_id),getdate())) + 'd)' stats_age	
            from 
                sys.dm_db_index_physical_stats(DB_ID(), default, default, default,'limited') ips --limited\sampled\detailed
            join sys.indexes i 
                on ips.object_id = i.object_id 
                and ips.index_id = i.index_id
                left join sys.partitions p
                    ON p.object_id = i.object_id 
                    and p.index_id = i.index_id
                    and ips.partition_number = p.partition_number
                left JOIN sys.partition_schemes ps
                    ON ps.data_space_id = i.data_space_id
                left JOIN sys.partition_functions f
                    ON f.function_id = ps.function_id
                LEFT JOIN sys.partition_range_values rv
                    ON f.function_id = rv.function_id
                    AND p.partition_number = rv.boundary_id 
                LEFT JOIN (select  [OBJECT_ID]
				            , index_id 
				            , user_seeks
				            , user_scans
				            , user_lookups
				            , user_updates
				            , total_user_operations
				            , CASE 
					            WHEN last_user_scan > last_user_lookup AND last_user_scan > last_user_seek AND last_user_scan > last_user_update THEN last_user_scan
					            WHEN last_user_lookup > last_user_scan AND last_user_lookup > last_user_seek AND last_user_lookup > last_user_update THEN last_user_lookup
					            WHEN last_user_seek > last_user_scan AND last_user_seek > last_user_lookup AND last_user_seek > last_user_update THEN last_user_seek
					            WHEN last_user_update > last_user_scan AND last_user_update > last_user_lookup AND last_user_update > last_user_seek THEN last_user_update        
					            ELSE NULL
				              END	As  last_user_operation
				              from
					            (SELECT   [OBJECT_ID]
						            , index_id 
						            , user_seeks
						            , user_scans
						            , user_lookups
						            , user_updates
						            , user_seeks + user_scans + user_lookups + user_updates as total_user_operations     
						            , ISNULL(last_user_scan, '1901-01-01') as last_user_scan
						            , ISNULL(last_user_lookup, '1901-01-01') as last_user_lookup
						            , ISNULL(last_user_seek, '1901-01-01') as last_user_seek
						            , ISNULL(last_user_update, '1901-01-01') as last_user_update
					            from sys.dm_db_index_usage_stats 
                                where database_id = DB_ID()
					            ) us1
		            ) us
		            ON i.[OBJECT_ID] = us.[OBJECT_ID]
		            AND i.index_id = us.index_id
            where 
                ips.database_id = db_id()	                
                AND index_type_desc != 'HEAP'
                AND CONVERT(int,ips.avg_fragmentation_in_percent) > 10
            order by avg_frag_pc desc , page_count desc
                 --i.name
                --avg_fragmentation_in_percent desc
            