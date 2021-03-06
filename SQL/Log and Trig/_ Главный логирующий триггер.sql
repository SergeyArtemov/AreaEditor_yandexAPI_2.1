--declare @triggername nvarchar(50)
--declare @tablename nvarchar(50)
--set @triggername='map_AreaTime_Full_New_log'; -- TRIGGER_NAME
--set @tablename='map_AreaTime_Full_New'; -- TABLE_NAME
--IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].['+@triggername+']') AND type in (N'TR'))
--exec('create trigger [dbo].['+@triggername+'] on [dbo].['+@tablename+'] after insert as begin print('''+@triggername+' trigger signaled!'') end')
--GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[map_AreaTime_Full_New_log] ON  [dbo].[map_AreaTime_Full_New]
   WITH EXECUTE AS'dbo'
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
SET NOCOUNT ON
BEGIN TRY

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
-- inserted(new) recpords -----------------------
set @inserted=
(select top 10 
 [id]
,[AreaId]
,[Start] 
,[Len]
from inserted as [record] 
for xml auto, type)
-- deleted(old) recpords -----------------------
set @deleted=
(select top 10 
 [id]
,[AreaId]
,[Start] 
,[Len]
from deleted as [record] 
for xml auto, type)

--if  not (IsNull(CAST(@deleted as varchar(max)),'') <>'')
--or  not (IsNull(CAST(@inserted as varchar(max)),'') <>'')
--begin
declare @xmltext varchar(max) 
set @xmltext = CAST((select header,inserted,deleted from (select @header as [header],@inserted	as [inserted],@deleted as [deleted]) as [root] for xml auto, type) as varchar(max))
if (CHARINDEX('<deleted>', @xmltext)<>0) or 
   (CHARINDEX('<inserted>', @xmltext)<>0)
begin
insert [dbo].[map_AreaTime_ChangeLog]([AreaId],[DateEdit],[xml],[WorkStation],[User],[ipdata],[SPID])
select
   2147483647			as [AreaId]
 , getdate()			as [DateEdit]
 , @xmltext	as [xml]
 , USER					as [User]
  --,SYSTEM_USER			as [SysUser]
 ,HOST_NAME()			as [WorkStation]
 ,[client_net_address]+':'+cast([client_tcp_port] as varchar) as [ipdata]
 ,@@SPID
from [master].[sys].[dm_exec_connections](nolock) header
where [session_id]=@@SPID
end
END TRY
BEGIN CATCH
print ('')
END CATCH
END
