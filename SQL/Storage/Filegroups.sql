select fg.name
	, count(df.name) as files
	, sum(df.size) as size
from sys.database_files df
left join sys.filegroups fg
	on df.data_space_id = fg.data_space_id
where df.data_space_id > 0	
group by fg.name
order by size desc




