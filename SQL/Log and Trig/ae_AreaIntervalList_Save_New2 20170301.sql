USE [MO]
GO
/****** Object:  StoredProcedure [dbo].[ae_AreaIntervalList_Save_New2]    Script Date: 01.03.2017 15:38:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ae_AreaIntervalList_Save_New2]
(@xmltext varchar(max) = '<INTERVAL_LIST></INTERVAL_LIST>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
-->-----------------------------------------

declare @xml xml = cast(@xmltext as xml)
declare @out table (ID int)
declare @temp table(ID int, AreaID int,[Start] datetime, [Len] datetime)
insert into @temp
 select 
   t.r.value('@ID','int')								as [ID]
  ,t.r.value('@AREAID','int')							as [AreaId]
  ,CAST(t.r.value('@START','datetime2(0)') as datetime)	as [Start]
  ,CAST(t.r.value('@LEN','datetime2(0)') as datetime)	as [Len]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as t(r)
where IsNull(t.r.value('@TYPE','int'),0)=0 -- TAreaIntervalIdType (0 для областей)

-- KhS20170216 Подготовка XML с предыдущими данным и запись в лог ---------------------------------------------------------
begin try
declare @AreaId			int
declare @WorkStation	varchar(100)
declare @user			varchar(64)
declare @ipdata			varchar(64)
declare @prevValues		xml 
set @prevValues= 
(select ATF.* 
from dbo.map_AreaTime_Full_New(nolock) ATF
right join @temp T on T.AreaID = ATF.AreaId and CAST(T.Start as date) = CAST(ATF.Start as date)
where ATF.AreaId is not null --KhS20170217
order by T.AreaID, T.Start
for XML AUTO, ROOT('DATA')) 
select 
   @AreaId		= t.r.value('@AREAID','int')			
  ,@User		= t.r.value('@USER'	 ,'varchar(100)')	
from @xml.nodes('/INTERVAL_LIST') as t(r)
select
   @WorkStation	= HOST_NAME()
  ,@ipdata		= [client_net_address]+':'+cast([client_tcp_port] as varchar)
from [master].[sys].[dm_exec_connections](nolock) 
where [session_id]=@@SPID
if IsNull(@AreaID,0) = 0 
   select @AreaId = t.r.value('@AREAID','int') from @xml.nodes('/INTERVAL_LIST/INTERVAL') as t(r)
if IsNull(@AreaID,0) = 0 -- это вряд ли сработает
   select @AreaId = t.r.value('@AreaId[1]','int') from @prevValues.nodes('DATA/ATF') as t(r)
--
insert [dbo].[map_AreaTime_ChangeLog]([AreaId],[DateEdit],[xml],[WorkStation],[User],[ipdata],[SPID])
select 
 @AreaId		as [AreaID]
,getdate()		as [DateEdit]
,'<ROOT>'+
'<HEADER HOST="'+HOST_NAME()+'"'+
       ' USER="'+SYSTEM_USER+'"'+
       ' IP="'+[client_net_address]+':'+cast([client_tcp_port] as varchar)+'"'+
	   ' DT="'+CONVERT(varchar(20),getdate(),112)+' '+CONVERT(varchar(20),getdate(),114)+'"'+
 '/>'+
 --'<DATA>'+IsNULL(CAST(@prevValues as varchar(max)),'')+'</DATA>'+ --KhS20170217
 IsNULL(CAST(@prevValues as varchar(max)),'')+ --KhS20170217
 --KhS20170217 -- end 
 '<INPUT>'+@xmltext+'</INPUT>'+
 '</ROOT>'		as [xml]
,@WorkStation	as [WorkStation]
,@user			as [User]
,@ipdata		as [ipdata]
,@@SPID			as [SPID]
FROM [master].[sys].[dm_exec_connections](nolock)
  where [session_id]=@@SPID
end try
begin catch
end catch
---------------------------------------------------------------------------------------------------
-- delete existed --
declare @delAreaID	int
declare @delMinDate datetime
declare @delMaxDate datetime
select 
   @delAreaID  = t.r.value('@AREAID','int')   
  ,@delMinDate = CAST(t.r.value('@MINDATE','datetime2(0)') as datetime)
  ,@delMaxDate = CAST(t.r.value('@MAXDATE','datetime2(0)') as datetime)
from @xml.nodes('/INTERVAL_LIST') as t(r)

if (@delMinDate is null)  or (@delMaxDate is null) and ((select count(*) from (select AreaId from @temp group by AreaID) src) = 1)
 begin
 select 
    @delAreaID  = AreaId
  , @delMinDate = CAST(CAST(min([Start]) as date) as datetime)
  , @delMaxDate = CAST(CAST(max([Start]) as date) as datetime)
 from @temp
 group by AreaID
 end

delete [dbo].[map_AreaTime_Full_New]
where (AreaId=@delAreaID) and ((Start>=@delMinDate) and (Start<DATEADD(DAY,1,@delMaxDate)))
--  this from "ae_AreaIntervalList_Save_New"
delete [dbo].[map_AreaTime_Full_New]
output deleted.ID into @out
where ID in (select ABS(ID) from  @temp where [ID]<0)
-- update existed --
update [dbo].[map_AreaTime_Full_New] 
   set [dbo].[map_AreaTime_Full_New].[AreaID]	= src.[AreaID]
      ,[dbo].[map_AreaTime_Full_New].[Start]	= src.[Start]
      ,[dbo].[map_AreaTime_Full_New].[Len]		= src.[Len]
output deleted.ID into @out
from (select * from @temp where [ID]>0)src
where ([dbo].[map_AreaTime_Full_New].ID = src.ID) 
-- insert new --
insert [dbo].[map_AreaTime_Full_New] ([AreaID], [Start], [Len]) 
output inserted.ID into @out
select [AreaID], [Start], [Len] from @temp where [ID]=0
-- check result --
select @Res = count(*) from @out 
if (select count(*) from @temp)<>@Res set @Res=0
-->-----------------------------------------
COMMIT TRAN
END TRY
BEGIN CATCH -->-- ------------------------- --<--
WHILE @@TRANCOUNT>0 BEGIN ROLLBACK TRAN END
   set @Res = ERROR_NUMBER() * -1
   set @ErrorString = 'Ошибка в '+IsNull(ERROR_PROCEDURE(),'PROCEDURE*')+
                      '(строка №'+CAST(ERROR_LINE() as varchar(10))+').'+
                      'Код, уровень, статус ошибки : '+CAST(ERROR_NUMBER() as varchar(10))+', '+CAST(ERROR_SEVERITY() as varchar(10))+', '+CAST(ERROR_STATE() as varchar(10))+'.'+
                      'Описание ошибки : '+ERROR_MESSAGE()+'.'
   RaisError('%s',16,1,@ErrorString)   
END CATCH
RETURN @Res
END



