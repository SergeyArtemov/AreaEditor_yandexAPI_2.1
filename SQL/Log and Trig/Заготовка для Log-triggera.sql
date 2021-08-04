
declare @header		xml
declare @inserted	xml
declare @deleted	xml

set @header =
(
select
   USER_NAME()	as [User]
  ,SYSTEM_USER	as [SysUser]
  ,HOST_NAME()  as [WorkStation]
  ,[client_net_address]+':'+cast([client_tcp_port] as varchar) as [ipdata]
from [master].[sys].[dm_exec_connections](nolock) header
where [session_id]=@@SPID
for xml auto, type)

set @inserted=
(select top 10 
 id
,AreaId
,[Start] 
,[Len]
from dbo.map_AreaTime_Full_New(nolock) as [record] 
for xml auto, type)

set @deleted=
(select top 10 
 id
,AreaId
,[Start] 
,[Len]
from dbo.map_AreaTime_Full_New(nolock) as [record] 
for xml auto, type)


select
   2147483647			as [AreaId]
 , getdate()			as [DateEdit]
 ,(select header
         ,inserted
         ,deleted
   from (select 
			@header		as [header]
		   ,@inserted	as [inserted]
           ,@deleted	as [deleted]
         ) as [root]
   for xml auto, type)	as [xml]
  ,USER					as [User]
  ,SYSTEM_USER			as [SysUser]
  ,HOST_NAME()			as [WorkStation]
  ,[client_net_address]+':'+cast([client_tcp_port] as varchar) as [ipdata]
from [master].[sys].[dm_exec_connections](nolock) header
where [session_id]=@@SPID


