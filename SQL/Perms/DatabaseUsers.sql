
--sp_helpuser *TURBO edition*

set nocount on
set ansi_warnings off

declare
    @RetCode               int
   ,@_rowcount             int

declare
    @charMaxLen_UsName     varchar(11)
   ,@charMaxLen_RlName     varchar(11)
   ,@charMaxLen_LoName     varchar(11)
   ,@charMaxLen_DbName     varchar(11)
   ,@charMaxLen_ScName     varchar(11)
   ,@name_in_db			   varchar(11)

declare
    @Name1Type             char(2)

-----------------------  create holding table  --------------------
/*Create temp table before any DML to ensure dynamic*/

CREATE TABLE #tb1_uga
   (
    zUserName        sysname        collate database_default Null
   ,zRoleName        sysname        collate database_default Null
   ,zLoginName       sysname        collate database_default Null
   ,zDefDBName       sysname        collate database_default Null
   ,zDefScName   sysname        collate database_default Null
   ,zUID             int		Null
   ,zSID             varbinary(85)  Null
   )

--------

select
    @RetCode               = 0
   ,@Name1Type             = Null
   ,@name_in_db				= null


-------------  What type of value (U,G,A) was input?  --------------

-------- NULL

IF (@name_in_db IS Null)
   begin

   select @Name1Type = '-'


   INSERT into  #tb1_uga
               (
                zUserName
               ,zRoleName
               ,zLoginName
               ,zDefDBName
               ,zDefScName
               ,zUID
               ,zSID
               )
      select
                   u.name
                  ,case when (r.principal_id is null) then 'public'
				else r.name
			end
                  ,l.name
                  ,l.default_database_name
                  ,u.default_schema_name
                  ,u.principal_id
                  ,u.sid
         from sys.database_principals u
         left join (sys.database_role_members m join sys.database_principals r on m.role_principal_id = r.principal_id) on m.member_principal_id = u.principal_id
         left join sys.server_principals l on u.sid = l.sid
         where u.type <> 'R'


   GOTO LABEL_25NAME1TYPEKNOWN

   end


-------- USER

INSERT   into   #tb1_uga
               (
                zUserName
               ,zRoleName
               ,zLoginName
               ,zDefDBName
               ,zDefScName
               ,zUID
               ,zSID
               )
      select
                   u.name
                  ,case when (r.principal_id is null) then 'public'
				else r.name
			end
                  ,l.name
                  ,l.default_database_name
                  ,u.default_schema_name
                  ,u.principal_id
                  ,u.sid
	from sys.database_principals u
         left join (sys.database_role_members m join sys.database_principals r on m.role_principal_id = r.principal_id) on u.principal_id = m.member_principal_id
         left join sys.server_principals l on u.sid = l.sid
	where u.name = @name_in_db and u.type <> 'R'

select @_rowcount = @@rowcount


IF (@_rowcount > 0)
   begin
   select @Name1Type = 'US'

   GOTO LABEL_25NAME1TYPEKNOWN

   end


 -------- ALIAS

INSERT   into   #tb1_uga
               (
                zUserName
               ,zRoleName
               ,zLoginName
               ,zDefDBName
               ,zDefScName
               ,zUID
               ,zSID
               )

	select
                   usu.name
                  ,case when (usg.principal_id is null) then 'public'
				else usg.name
			   end
                  ,lo.name
                  ,lo.default_database_name
                  ,usu.default_schema_name
                  ,usu.principal_id
                  ,usu.sid
         from sys.database_principal_aliases al
         	join sys.database_principals usu on usu.principal_id = al.alias_principal_id
         	left join (sys.database_role_members mem join sys.database_principals usg on usg.principal_id = mem.role_principal_id) on mem.member_principal_id = usu.principal_id
              left join sys.server_principals lo on lo.sid = usu.sid
         where (usu.type = 'S' or usu.type = 'U') and
                   al.sid = suser_sid(@name_in_db)

select @_rowcount = @@rowcount


IF (@_rowcount > 0)
   begin
   select @Name1Type = 'AL'

   GOTO LABEL_25NAME1TYPEKNOWN

   end


-------- ROLES

if exists (select * from sys.database_principals where  name = @name_in_db and type = 'R')
   begin
   select @Name1Type = 'RL'

   select Role_name = substring(r.name, 1, 25), Role_id = r.principal_id,
	   Users_in_role = substring(u.name, 1, 25), Userid = u.principal_id
	from sys.database_principals u, sys.database_principals r, sys.database_role_members m
	where r.name = @name_in_db
		and r.principal_id = m.role_principal_id
		and u.principal_id = m.member_principal_id
	order by 1, 2

   GOTO LABEL_75FINAL  --Done

   end


-------- Error
raiserror(15198,-1,-1 ,@name_in_db)  --Input Name is unfound
select @RetCode = @RetCode | 1

GOTO LABEL_75FINAL

--------


LABEL_25NAME1TYPEKNOWN:


-----------------------  Printout the report  -------------------------

-------- Preparations for dynamic exec

select
          @charMaxLen_UsName  = convert( varchar,
                  isnull( max( datalength( zUserName)),8))

         ,@charMaxLen_RlName  = convert( varchar,
                  isnull( max( datalength( zRoleName)),9))

         ,@charMaxLen_LoName  = convert( varchar,
                  isnull( max( datalength( zLoginName)),9))

         ,@charMaxLen_DbName  = convert( varchar,
                  isnull( max( datalength( zDefDBName)),9))

         ,@charMaxLen_ScName  = convert( varchar,
                  isnull( max( datalength( zDefScName)),9))
   from
          #tb1_uga


-------- Dynamic EXEC() to printout report


EXECUTE(
'
select
             ''UserID''    = convert(char(10),zUID)
             
            ,''LoginName'' =
                     substring(zLoginName,1,' + @charMaxLen_LoName + ')

            ,''UserName''  =
                     substring(zUserName ,1,' + @charMaxLen_UsName + ')

            ,''RoleName'' =
                     substring(zRoleName,1,' + @charMaxLen_RlName + ')
            
            ,''DefDBName'' =
                     substring(zDefDBName,1,' + @charMaxLen_DbName + ')

            ,''DefSchemaName'' =
                     substring(zDefScName,1,' + @charMaxLen_ScName + ')          
           
      from
             #tb1_uga
      order by
             1
'
)

-----------------------  A little extra nice-to-have

IF (@Name1Type IN ('-','US'))
   begin

   IF EXISTS (select * from #tb1_uga tb1, sys.database_principal_aliases al where tb1.zUID = al.alias_principal_id)
      begin

      select   'LoginName' = suser_sname(al.sid)
              ,'UserNameAliasedTo' = tb1.zUserName
         from  #tb1_uga tb1, sys.database_principal_aliases al
         where tb1.zUID = al.alias_principal_id
         order by 1

      end
   end


-----------------------  Finalization  ----------------------


LABEL_75FINAL:


IF (object_id('tempdb..#tb1_uga') IS not Null)
            DROP TABLE #tb1_uga

