alter view vw_counters
as
SELECT
		CounterDateTime,
        CAST(LEFT(CounterDateTime, 16) as smalldatetime) AS CounterTime,
        REPLACE(CounterDetails.MachineName,'\\','') AS ComputerName,
        CounterDetails.ObjectName,
        CounterDetails.InstanceName,
        CounterDetails.CounterName,
        CounterDetails.ObjectName + ISNULL('(' + CounterDetails.InstanceName + ')','') + '\' + CounterDetails.CounterName AS [Counter],
        CONVERT (NUMERIC(20,2),CounterData.CounterValue) as value--, *
    FROM CounterData
        INNER JOIN CounterDetails ON CounterData.CounterID = CounterDetails.CounterID
        INNER JOIN DisplayToID ON CounterData.GUID = DisplayToID.GUID