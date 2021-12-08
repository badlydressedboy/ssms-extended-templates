
-- currently executing traces
select id
	, status
	, path
	, start_time
	, last_event_time
	, event_count
	, reader_spid
	, is_default
	, buffer_size
	, buffer_count
	, max_files
	, max_size
	, status
	, is_rollover
	, is_shutdown
from sys.traces