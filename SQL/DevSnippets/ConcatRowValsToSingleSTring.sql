select ( select top 2 brandname + '-' 
	from brand
	FOR XML PATH(''), TYPE
).value('/', 'NVARCHAR(MAX)')