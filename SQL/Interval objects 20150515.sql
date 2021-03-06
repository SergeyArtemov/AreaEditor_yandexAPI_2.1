USE MO_TMP
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMP_AreaTime_Full_New]') AND type in (N'U'))
   DROP TABLE [dbo].[TEMP_AreaTime_Full_New]
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TEMP_AreaTime_Full_New](
	[AreaId]		[int]					NOT NULL,
	[Start]			[datetime]				NOT NULL,
    [Len]			[datetime]				NOT NULL,
	[Active]		[bit]						NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

insert [dbo].[TEMP_AreaTime_Full_New]([AreaId], [Start], [Len], [Active])
select [AreaId], [Start], [Len], 1 from [dbo].[map_AreaTime_Full_New](nolock)
GO 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaTime_Full_New]') AND type in (N'U'))
   DROP TABLE [dbo].[map_AreaTime_Full_New]
GO
SET ANSI_PADDING ON
GO   
CREATE TABLE [dbo].[map_AreaTime_Full_New](
	[ID]			[int]	IDENTITY(1,1)	NOT NULL, -- идентификатор
	[AreaId]		[int]					NOT NULL,
	[Start]			[datetime]				NOT NULL,
    [Len]			[datetime]				NOT NULL,
	[Active]		[bit]						NULL
) ON [PRIMARY]
print('  Таблица [dbo].[map_AreaTime_Full_New] (Table) создана.') 
GO
SET ANSI_PADDING OFF
GO

SET NOCOUNT ON
GO
insert [dbo].[map_AreaTime_Full_New]([AreaId], [Start], [Len], [Active])
select [AreaId], [Start], [Len], [Active] from [dbo].[TEMP_AreaTime_Full_New](nolock) order by [Start],[AreaID]
GO 

DROP TABLE [dbo].[TEMP_AreaTime_Full_New]
GO


----------------- процедура сохранения интервала (списка интервалов) -------------------------------------------
SET ANSI_PADDING ON
GO
declare @procname nvarchar(50)
set @procname='ae_AreaIntervalList_Save_New'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].['+@procname+']') AND type in (N'P', N'PC'))
exec('create procedure [dbo].['+@procname+'] with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].['+@procname+'] to [mo2]')
exec('grant view definition on [dbo].['+@procname+'] to [mo2]')
GO
SET ANSI_PADDING OFF
GO


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
declare @temp table(ID int, AreaID int,[Date] datetime, [Start] datetime, [Len] datetime, Active bit)
insert into @temp
 select 
   t.r.value('@ID','int')												as [ID]
  ,t.r.value('@AREAID','int')											as [AreaId]
  ,t.r.value('@DATE','datetime')										as [Date]
  ,DateAdd(hh,t.r.value('@BEGIN','int'), t.r.value('@DATE','datetime')) as [Start]
  ,DateAdd(hh,t.r.value('@END','int')-t.r.value('@BEGIN','int'), 0)		as [Len]
  ,t.r.value('@ACTIVE','bit')											as [Active]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as t(r)
-- update existed --
update [dbo].[map_AreaTime_Full_New] 
   set [dbo].[map_AreaTime_Full_New].[AreaID]	= src.[AreaID]
      ,[dbo].[map_AreaTime_Full_New].[Start]	= src.[Start]
      ,[dbo].[map_AreaTime_Full_New].[Len]		= src.[Len]
 	  ,[dbo].[map_AreaTime_Full_New].[Active]	= src.[Active]
output deleted.ID into @out
from (select * from @temp where [ID]>0)src
where ([dbo].[map_AreaTime_Full_New].ID = src.ID) 
-- insert new --
insert [dbo].[map_AreaTime_Full_New] ([AreaID], [Start], [Len], [Active]) 
output deleted.ID into @out
select [AreaID], [Start], [Len], [Active] from @temp where [ID]=0
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



