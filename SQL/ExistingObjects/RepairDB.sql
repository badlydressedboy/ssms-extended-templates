dbcc checkdb('repro_0_7_dev')

alter database repro_0_7_dev set SINGLE_USER

dbcc checkdb('repro_0_7_dev',REPAIR_REBUILD)

set database repro_0_7_dev set MULTI_USER