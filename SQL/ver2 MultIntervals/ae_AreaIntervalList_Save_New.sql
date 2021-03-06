USE [MO_tmp]
GO
/****** Object:  StoredProcedure [dbo].[ae_AreaIntervalList_Save_New]    Script Date: 02.10.2015 16:45:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ae_AreaIntervalList_Save_New]
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



