
declare @value varchar(100)
select @value = 'sightseeing'


declare tables cursor for select name from sysobjects where xtype = 'U'
declare @tablename sysname
declare @fieldname sysname
declare @sql varchar(8000)
open tables

fetch next from tables into @tablename
while @@FETCH_STATUS = 0
begin
		
	declare fields cursor for select name from syscolumns where id = object_id(@tablename) 
		and 
		(
			xtype in
			(35, 99, 167, 175, 231, 239) --only query text type fields
				and 1 = 1
		or xtype in
			(48, 52, 56, 104, 127)	--integral types
				and 0 = 1
		or xtype in
			(59, 60, 62, 106, 108, 122) --floating types
				and 0 = 1
		or xtype in
			(48, 52, 56, 104, 127, 59, 60, 62, 106, 108, 122)	--all numbers
				and 0 = 1
		)

	open fields
	
	fetch next from fields into @fieldname
	while @@FETCH_STATUS = 0
	begin
		--Text
		IF 1 = 1
		begin
			select @sql = 'IF EXISTS(SELECT * FROM [' + @tablename + '] WHERE [' + @fieldname + '] LIKE ''%' + @value + '%'')
				SELECT ''' + @tablename + ''' [Table], ''' + @fieldname + ''' [Field], [' + @fieldname + '] 
				FROM [' + @tablename + '] WHERE [' + @fieldname + '] LIKE ''%' + @value + '%'''
		--Number
		end
		ELSE
		begin
			select @sql = 'IF EXISTS(SELECT * FROM [' + @tablename + '] WHERE [' + @Fieldname + '] = ' + @value + ')
				SELECT ''' + @tablename + ''' [Table], ''' + @fieldname + ''' [Field], [' + @fieldname + ']
				FROM [' + @tablename + '] WHERE [' + @fieldname + '] = ' + @value
		end

		exec(@sql)
		fetch next from fields into @fieldname
	end
	close fields
	deallocate fields

	fetch next from tables into @tablename
end



close tables
deallocate tables