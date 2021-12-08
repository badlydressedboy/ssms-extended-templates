
-- version to count objects changed per day
select 
    LEFT(CONVERT(VARCHAR(20),modify_date,112),8) as modify_date
    , COUNT(*) as objects_modified_count
from sys.objects
where is_ms_shipped = 0
group by LEFT(CONVERT(VARCHAR(20),modify_date,112),8)
order by LEFT(CONVERT(VARCHAR(20),modify_date,112),8) desc





