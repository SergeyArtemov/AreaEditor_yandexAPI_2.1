declare @xmltext varchar(max) = '<DATA APP="AreaEditor" USER="s.kholin" />'
declare @xml xml
set @xml=CAST(@xmltext as xml)
declare @_user varchar(128)
declare @_app varchar(128) 
declare @_userid int = 0
select 
   @_app  = t.r.value('@APP[1]'	, 'varchar(128)')
  ,@_user = t.r.value('@USER[1]'	, 'varchar(128)')
from 
 @xml.nodes('/DATA') as t(r)


-- это при Windows авторизации работает
declare @user_full varchar(128) = USER_NAME()
declare @user varchar(128) = SUBSTRING(@user_full,IsNull(charindex('\',@user_full),0)+1,len(@user_full))

---select @user_full,@user
select @_userid = id from dbo.lst_PermUser(nolock) PU where DomainName=@user_full
if IsNull(@_userid,0)=0
  select @_userid = id from dbo.lst_PermUser(nolock) PU where DomainName=@user
if IsNull(@_userid,0)=0
  select @_userid = id from dbo.lst_PermUser(nolock) PU where DomainName=@_user
if IsNull(@_userid,0)=0
  begin
  select 0 [ID] , 0 [Code], 'Spile' [Name], 0 [Active]
  end
 

select 
  itm.ID
 ,itm.Code 
 ,itm.Name  
 ,itm.Active
from dbo.lst_PermItem(nolock) itm
join (select Task_Code from dbo.lst_Task(nolock) where Task_name=@_app) tsk on  tsk.Task_CODE = itm.Task_CODE
join (select ID_PermUser, ID_PermItem from dbo.lst_PermLink(nolock) where ID_PermUser = @_userid) lnk on itm.ID = lnk.ID_PermItem
where itm.Active>0

/*
update mo_tmp.dbo.ae_AccidentList
set resNote=''
,resGuilty=0
where id=1

delete mo_tmp.dbo.ae_AccidentList_log where id=2
*/