
declare @xmltext varchar(max)= '<REQUEST USER="s.kholin" TASK="AreaEditor" />'
declare @xml xml = CAST(@xmltext as xml)
declare @user varchar(64)
declare @task varchar(64)
select @user = t.r.value('@USER','varchar(64)')
      ,@task = t.r.value('@TASK','varchar(64)')
from @xml.nodes('/REQUEST') as t(r)

select 
  PRM.Code
 ,PRM.Name
from dbo.lst_PermItem(nolock) PRM
join dbo.lst_PermLink PL on PRM.ID = PL.ID_PermItem and PRM.Active>0 
join (select task_Code from dbo.lst_Task where Task_Name=@task) LT on LT.Task_Code = PRM.Task_Code
join (select id from dbo.lst_PermUser where DomainName=@user) PU on PU.ID = PL.ID_PermUser

--
select * from map_AreaTime_Full(nolock) where Active=0


select * from mo.dbo.lst_PermUser


select * from mo.dbo.lst_Task where Task_Type=1

select top 100 * from mo_tmp.dbo.Email_Head


/*
declare @xmltext varchar(max)= '<REQUEST USER="s.kholin" TASK="areaeditor2" />'
declare @xml xml = CAST(@xmltext as xml)

select 
  PRM.Code
 ,PRM.Name
 ,PRM.Active
from dbo.lst_PermItem(nolock) PRM
join dbo.lst_PermLink PL on PRM.ID = PL.ID_PermItem and PRM.Active>0 and PRM.Task_Code = LT.Task_Code
join dbo.lst_PermUser PU on PU.ID = PL.ID_PermUser
select @user=t.r.value('@USER','varchar(64)')
       ,@t.r.value('@TASK','varchar(64)') as [TaskName]
       from @xml.nodes('/REQUEST') as t(r)
*/

