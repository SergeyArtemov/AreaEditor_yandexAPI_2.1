USE [MO]
GO


declare @procname nvarchar(50)
set @procname='ae_AreaIntervalList_Save_New2'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].['+@procname+']') AND type in (N'P', N'PC'))
exec('create procedure [dbo].['+@procname+'] with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].['+@procname+'] to [mo2]')
exec('grant view definition on [dbo].['+@procname+'] to [mo2]')
GO


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
-- delete existed --
declare @delAreaID	int
declare @delMinDate datetime2
declare @delMaxDate datetime2
select 
   @delAreaID  = t.r.value('@AREAID','int')   
  ,@delMinDate = t.r.value('@MINDATE','datetime2(0)')
  ,@delMaxDate = t.r.value('@MAXDATE','datetime2(0)')
from @xml.nodes('/INTERVAL_LIST') as t(r)
delete [dbo].[map_AreaTime_Full_New]
where AreaId=@delAreaID and (CAST(Start as datetime2) between @delMinDate and @delMaxDate)
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



