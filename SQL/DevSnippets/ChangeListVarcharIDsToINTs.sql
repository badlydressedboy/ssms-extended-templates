USE [CPPLUS]
GO
/****** Object:  StoredProcedure [dbo].[ReportAppealsReceived]    Script Date: 1/31/2020 9:33:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--Total Appeal Statuses = 252
SELECT COUNT(*)
FROM dbo.CaseNotice a WITH (NOLOCK)
INNER JOIN dbo.CaseState h WITH (NOLOCK) ON h.CaseStateID = a.CaseStateID
	AND h.CaseStateID IN (8,9,10,11,  12,13,14)

----------------------------

SELECT * FROM dbo.CaseStatus
SELECT * FROM dbo.CaseState

8  APPEAL_RECEIVED
9  APPEAL_ACCEPTED
10  APPEAL_REJECTED
11  APPEAL_POPLA_RECEIVED
12  APPEAL_POPLA_SUBMITTED
13  APPEAL_POPLA_REJECTED
14  APPEAL_POPLA_ACCEPTED

SELECT * FROM dbo.v_Entity
ORDER BY EntityOrder, Label

SELECT * FROM dbo.v_CarParkClient
ORDER BY CarPark

SELECT * FROM dbo.v_CarParkClient
WHERE ClientEntityID = 40
ORDER BY CarPark

SELECT * FROM dbo.v_CarParkClient
WHERE ClientEntityID = 5
ORDER BY CarPark

--EntityID 342 RoyalSurreyCountyHospital
SELECT * FROM dbo.v_CarParkClient
WHERE CarParkCode = 'CP1159'
ORDER BY CarPark

SELECT Client, ClientEntityID, COUNT(*) CarParks 
FROM dbo.v_CarParkClient
GROUP BY Client, ClientEntityID
ORDER BY Client


SELECT * 
FROM dbo.CaseNoticeStatusLog
WHERE CaseStatusID IN (5,6)

SELECT * FROM dbo.CaseStatus

SELECT * FROM dbo.CaseStatusReason


-----------------------------

--All Sites
EXEC CPPLUS.dbo.ReportAppealsReceived '2019-12-01', '2019-12-31', NULL

*/
create PROCEDURE [dbo].[ReportAppealsReceivedMulti] (
   @OffenceDateFrom DATETIME
 , @OffenceDateTo DATETIME 
 , @EntityIDs varchar(4000)
)
AS
;
--get IDs first
declare @EntityIDs varchar(4000) = '2,3, 4, 5, 6, 7, 14, 15'
declare @tempIDs table(id int)
declare @data xml

SET @EntityIDs = replace(@EntityIDs, ' ', '')
select @data = '<t>' + replace(@EntityIDs, ',', '</t><t>') + '</t>'

insert into @tempIDs
select
    t.c.value('.', 'int') as id
from @data.nodes('t') as t(c)

select * from @tempIDs


SELECT 
   a.CaseNoticeID  
 , a.CaseNoticeCaptureDate AS CaseNoticeDate
 , e.VRM
 , k.CaseNoticeTypeCode
 , f.CaseStatusID
 , g.CaseStatus
 , h.CaseState
 , c.ClientID
 , c.Client -- required in list 
 , d.CarPark -- required in list
 , d.CarParkCode
 , a.ExternalCaseNumber --AS CNNumber
 , a.ObservationDatetimeInitial
 , a.AffixDatetime
 , ee.VehicleBrand
 , ee1.VehicleModel
 , ee2.VehicleColour
 , l.ContraventionCode
 , l.Contravention
 --, a.CaseNoticeCaptureDate AS OffenceDateTime
 , j.Charge
 , a.Poplareference
-- , j.Fee
 --, j.Payment AS AmountPaid	
 --, j.Refund AS AmountRefunded
 --, j.PaymentDate AS PaymentReceived
-- , f.ProcessModifiedDateTime AS WriteoffDateTime
-- , DATEDIFF(day, a.CaseNoticeCaptureDate, j.PaymentDate) AS DaysTakenToPay
--DECLARE @OffenceDateFrom DATETIME = '2015-03-01', @OffenceDateTo DATETIME = '2015-06-01'
--SELECT TOP 100 CaseNoticeCaptureDate, *
FROM dbo.CaseNotice a WITH (NOLOCK)
INNER JOIN dbo.EntityRelation b WITH (NOLOCK) ON a.EntityID = b.SubjectEntityID
INNER JOIN dbo.Client c WITH (NOLOCK) ON b.ObjectEntityID = c.EntityID
INNER JOIN dbo.CarPark d WITH (NOLOCK) ON a.EntityID = d.EntityID
INNER JOIN dbo.Vehicle e WITH (NOLOCK) ON a.VehicleID = e.VehicleID
LEFT OUTER JOIN dbo.VehicleBrand ee WITH (NOLOCK) ON ee.VehicleBrandID = e.VehicleBrandID
LEFT OUTER JOIN dbo.VehicleModel ee1 WITH (NOLOCK) ON ee1.VehicleModelID = e.VehicleModelID
LEFT OUTER JOIN dbo.VehicleColour ee2 WITH (NOLOCK) ON ee2.VehicleColourID = e.VehicleColourID
INNER JOIN dbo.CaseNoticeStatusLog f WITH (NOLOCK) ON f.CaseNoticeStatusLogID = a.CaseNoticeStatusLogID
-- AND f.CaseStatusID = 9 -- WRITE OFF
 AND a.CaseNoticeCaptureDate >= @OffenceDateFrom 
 AND a.CaseNoticeCaptureDate < DATEADD(day, 1, @OffenceDateTo)
INNER JOIN dbo.CaseStatus g WITH (NOLOCK) ON g.CaseStatusID = f.CaseStatusID
INNER JOIN dbo.CaseState h WITH (NOLOCK) ON h.CaseStateID = a.CaseStateID
CROSS APPLY dbo.f_AmountsPerType(a.ExternalCaseNumber) j
LEFT OUTER JOIN dbo.CasenoticeType k ON k.CaseNoticeTypeID = a.CaseNoticeTypeID
LEFT OUTER JOIN dbo.Contravention l ON l.ContraventionID = a.ContraventionID
WHERE (@EntityID IS NULL 
	OR a.EntityID = @EntityID
	OR c.EntityID = @EntityID
)
AND (EXISTS (
		SELECT * 
		FROM dbo.CaseNoticeStatusLog qr
		WHERE qr.CaseStatusID IN (10,5,6) -- POPLA APPEAL, HOLD or HOLD MORE INFO
		AND qr.CaseNoticeID = a.CaseNoticeID
)
OR EXISTS (
		SELECT * 
		FROM dbo.CaseNoticeNarrative qs
		WHERE (qs.CaseNoticeNarrative LIKE '%incoming%') 
		AND qs.CaseNoticeID = a.CaseNoticeID
)
OR ISNULL(a.PoplaReference,'') != ''
OR h.CaseStateID IN (8,9,10,11,  12,13,14)
)
ORDER BY c.Client, d.CarPark, e.VRM, a.AffixDateTime




