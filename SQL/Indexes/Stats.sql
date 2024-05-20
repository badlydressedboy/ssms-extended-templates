select   o.name as TableName  
       , i.name as StatName  --really is a sysindexes.name
       --, o.id
       --, st.stats_id
       , pc_rows_changed = 
			case 	
				when t.rows	= 0 then 0
				when t.rows	> 0 then convert(decimal,(i.rowmodctr * 1.00/ISNULL(NULLIF(t.rows * 1.00, 0),0)) * 100) 
			end    
       , i.rowmodctr as StatsRowsChanged  
       , t.rows as TableRowsTotal        
       , STATS_DATE(i.ID, i.indid) AS StatsUpdated 
       , CONVERT(VARCHAR(50),DATEDIFF(d,STATS_DATE(i.ID, i.indid),getdate())) + 'd (' + CONVERT(VARCHAR(50),DATEDIFF(hh,STATS_DATE(i.ID, i.indid),getdate())) + 'hrs)'  StatsAge	
       , stats_id --same as indexid
	   , auto_created
	   , user_created
	   , no_recompute
	   , has_filter
	   , filter_definition
from sysobjects o  
	join sysindexes i 
		on o.id = i.id  
	join sysindexes t 
		on t.id = i.id 
		and t.indid in (0, 1)  
	join sys.stats st 
		on i.name = st.name
WHERE i.rowmodctr > 0  
	and o.xtype = 'U' 
	and i.name is not null 	
	and o.name = 'valuations'
order by pc_rows_changed desc

