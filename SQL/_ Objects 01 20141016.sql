print ('Обратить внимание на используемую БД и флаг "пересоздавать таблицы" : @NeedDropTables')
GO

--select * from map_AreaList_log 

USE MO_tmp
GO

print('Таблицы блока "AreaEditor" and "Map" ) (префикс "ae_") : '+ DB_NAME()) 
GO
declare @NeedDropTables bit = 0 -->-- ВАЖНО!!!
if @NeedDropTables = 1
begin
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaList_log]') AND type in (N'U'))			
   DROP TABLE [dbo].[map_AreaList_log]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ae_AccidentList]') AND type in (N'U'))			
   DROP TABLE [dbo].[ae_AccidentList]
print('  Таблицы блока  "AreaEditor" and "Map" удалены.') 
end


SET ANSI_PADDING ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaList_log]') AND type in (N'U'))	
CREATE TABLE [dbo].[map_AreaList_log](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AreaId]				[int]			NOT NULL,
	[DateEdit]				[datetime]		NOT NULL,
	[xml]					[varchar](max)	NOT NULL,
	WorkStation				[varchar](128)	NOT NULL,
	[User]					[varchar](64)	NOT NULL,
    [ipdata]				[varchar](128)	NOT NULL
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "map_AreaList_log" (Журнал изменений описаний областей)') 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ae_AccidentList]') AND type in (N'U'))	
CREATE TABLE [dbo].[ae_AccidentList](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
    [acDate]				[datetime]		NOT NULL,	-- дата события
    [acPlace]				[varchar](256)	NOT NULL,	-- место события
    [acCar]					[varchar](10)	NOT NULL,	-- номер автомобиля по Navision (выбирается по дате)
    [acDriver]				[varchar](128)	NOT NULL,	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    [acType]				[int]			NOT NULL,	-- тип (словарь, HardCode (20141015))
    [acNote]				[varchar](256)	NOT NULL,	-- описание (если тип "Другое" или уточнение)
    [clType]				[int]			NOT NULL,	-- тип (словарь, HardCode (20141015))
    [clFIO]					[varchar](256)	NOT NULL,	-- ФИО звонившего
    [clPhone]				[varchar](32)	NOT NULL,	-- телефон звонившего
    [resNote]				[varchar](256)		NULL	-- заключение по случаю
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "ae_AccidentList" (Список событий с автомобилями компании)') 
GO

--> ae_AccidentList_Log.Event
-- 0 добавление
-- 1 изменение
-- 2 удаление
-- 4 изменение вердикта

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ae_AccidentList_Log]') AND type in (N'U'))	
CREATE TABLE [dbo].[ae_AccidentList_Log](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordID]				[int]			NOT NULL,
	[Event]					[int]			NOT NULL, 
	[DateEvent]				[datetime]		NOT NULL, 
	[UserID]				[int]				NULL, 
	[WorkStation]			[varchar](128)	NOT	NULL,
	[User]					[varchar](64)		NULL,
    [ipdata]				[varchar](128)	NOT NULL
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "ae_AccidentList_Log" (Журнал изменений таблицы "ae_AccidentList")') 
GO


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

-- field map_AreaTime_Full.Activity
-- field map_AreaTime_Full.ID

-- table map_Area_Agent(&) AreaID, DeliveryAgent


print('Функции блока "AreaEditor" and "Map" () (префикс "fn_") : '+ DB_NAME()) 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_StringToJavaUTF8Ex]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_StringToJavaUTF8Ex]
GO

CREATE FUNCTION [dbo].[fn_StringToJavaUTF8Ex] (@input varchar(max))  
RETURNS varchar(max) AS  
BEGIN
declare @res varchar(max) = ''
declare @char varchar(6)
declare @cnt int=1
declare @len int = LEN(@input)
while @cnt<=@len
 begin
 set @char=REPLACE(master.dbo.fn_varbintohexstr(CONVERT(varbinary(2),UNICODE(SUBSTRING(@input,@cnt,1)))),'0x','\u')
 set @res = @res+@char
 set @cnt=@cnt+1 
 end
Return @res
END
GO
print('  Функция [dbo].[fn_StringToJavaUTF8Ex] (Преоразование строки ASCII в строку \uXXXX\uXXXX (java, js; unicode)) создана.') 
GO


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


print('Хранимые процедуры блока "AreaEditor" and "Map" () (префикс "ae_") : '+ DB_NAME()) 
GO

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
declare @procname nvarchar(50)
set @procname='[PROC_NAME]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[PROC_NAME]
(@xmltext varchar(max) = '<GRAPH></GRAPH>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
-->-----------------------------------------



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
GO
print('  Процедура [dbo].[PROC_NAME] () создана.') 
GO
*/


declare @procname nvarchar(50)
set @procname='[ae_GetFullData]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_GetFullData]
(@xmltext varchar(max) = '<PARAMS></PARAMS>')
-- @DATE = DeliveryDate
-- @AGENT = DeliveryAgent (1 Москва, 13 Санкт-Петербург)
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
-->-----------------------------------------
declare @xmltext_source varchar(max)
declare @xml xml = CAST(@xmltext as xml)      
select @xmltext_source = XMLBody from dbo.rt_History(nolock) H
join (select t.r.value('@DATE','datetime') as DeliveryDate
            ,t.r.value('@AGENT','int') as DeliveryAgent
      from @xml.nodes('/PARAMS') as t(r)) P on H.DeliveryDate = P.DeliveryDate and H.DeliveryAgent=P.DeliveryAgent
set @xml = CAST(@xmltext_source as xml)      
--> DataSet 0 : набор данных из "Router", полученный по параметрам <--
--> Это необходимо для отображения областей и т.п. НА МОМЕНТ СОХРАНЕНИЯ, а не после возможных изменений
select @xml
--> DataSet 1 : описание пар "автомобиль-водитель" и соответсвующая область для пары <--
select 
   tab.rws.value('ID[1]','int') as Car_ID
  ,tab.rws.value('MODEL[1]','varchar(20)') as Car_Model
  ,tab.rws.value('LICENSE_PLATE[1]','varchar(20)') as Car_Reg_Num
  ,tab.rws.value('FIO[1]','varchar(100)') as Driver_FIO
  ,tab.rws.value('AREA_ID[1]','int') as Area_ID
  ,tab.rws.value('AREANAME[1]','varchar(100)') as Area_Name
from 
 @xml.nodes('/CARSLIST/CAR') as tab(rws)
where tab.rws.value('ACTIVE[1]','bit')=1 
--> DataSet 2 : описание точек доставки для построения маршрутов <--
select
  tab.rws.value('../AREAID[1]', 'int') as [Area_ID]
 ,tab.rws.value('../CARID[1]', 'int') as [Car_ID]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(tab.rws.value('../DELIVERYFIO[1]','varchar(max)')) as [Delivery_FIO]
 ,tab.rws.value('../DELIVERYFIO[1]','varchar(200)') as [Delivery_FIO]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../CUSTOMERFIO[1]','varchar(max)')) as [Customer_FIO]
 ,tab.rws.value('../CUSTOMERFIO[1]','varchar(200)') as [Customer_FIO]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../ADDRFOUND[1]','varchar(max)')) as [Delivery_Addr]
 ,tab.rws.value('../ADDRFOUND[1]','varchar(500)') as [Delivery_Addr]
 ,tab.rws.value('../PHONE[1]','varchar(100)') as [Phone]
 ,tab.rws.value('../INTERVAL[1]','varchar(100)') as [Interval]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../ABOUTFULL[1]','varchar(max)')) as [About_Full]
 ,tab.rws.value('../ABOUTFULL[1]','varchar(max)') as [About_Full]
 ,tab.rws.value('LAT[1]', 'numeric(10,7)') as [lat]  
 ,tab.rws.value('LNG[1]', 'numeric(10,7)') as [lng] 
 ,tab.rws.value('../ORDERCOUNT[1]','int') as [OrderCount]
from 
 @xml.nodes('/DELIVERYPOINTLIST/DELIVERYPOINT/LATLNG') as tab(rws)

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
GO
print('  Процедура [dbo].[ae_GetFullData] (Получение ВСЕХ данных для работы приложения AreaEditor) создана.') 
GO



declare @procname nvarchar(50)
set @procname='[ae_AreaIntervalList_Load]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_AreaIntervalList_Load]
(@xmltext varchar(max) = '<XML></XML>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
-->-----------------------------------------
declare @xml xml=CAST(@xmltext as xml)
declare @AreaID int = 0
select @AreaID = t.r.value('@AREAID[1]','int') from @xml.nodes('/XML') as t(r)
if ISNULL(@AreaID,0)=0 
   begin
   select 0, @AreaID, GETDATE(), 0,0,0,0,'00-00'
   return 0
   end

select * from (
SELECT 
       0				as [aiID]
      ,ATF.[AreaId]		as [aiArea]
      ,ATF.[Date]		as [aiDate]
      ,ATF.[StartHour]	as [aiBegin]
      ,ATF.[EndHour]	as [aiEnd]
      ,ATF.[Priority]	as [aiPriority]
      ,CAST(1 as bit)	as [aiActivity]
      ,SUBSTRING(CAST((100+ATF.[StartHour]) as varchar),2,2)+'-'+SUBSTRING(CAST((100+ATF.[EndHour]) as varchar),2,2) as [aiInterval]
FROM [dbo].[map_AreaTime_Full] ATF(nolock)
where ATF.[AreaId]=@AreaID 
) ATF
order by ATF.aiArea, ATF.aiDate desc, ATF.aiInterval
set @Res=1

-->-----------------------------------------
END TRY
BEGIN CATCH -->-- ------------------------- --<--
   set @Res = ERROR_NUMBER() * -1
   set @ErrorString = 'Ошибка в '+IsNull(ERROR_PROCEDURE(),'PROCEDURE*')+
                      '(строка №'+CAST(ERROR_LINE() as varchar(10))+').'+
                      'Код, уровень, статус ошибки : '+CAST(ERROR_NUMBER() as varchar(10))+', '+CAST(ERROR_SEVERITY() as varchar(10))+', '+CAST(ERROR_STATE() as varchar(10))+'.'+
                      'Описание ошибки : '+ERROR_MESSAGE()+'.'
   RaisError('%s',16,1,@ErrorString)   
END CATCH
RETURN @Res
END
GO
print('  Процедура [dbo].[ae_AreaIntervalList_Load] (Получение списка интервалов доставки по области) создана.') 
GO


declare @procname nvarchar(50)
set @procname='[ae_AreaIntervalList_Save]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_AreaIntervalList_Save]
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
declare @xml xml = CAST(@xmltext as xml)
declare @temp table(ID int, AreaID int, [Date] datetime,StartHour tinyint, EndHour tinyint, [Priority] int, Activity bit, [exists] bit)
declare @out table (AreaID int, [Date] datetime, Oper tinyint)
insert into @temp
  select 
   tab.rws.value('@ID[1]'		,'int')		as [ID]
  ,tab.rws.value('@AREAID[1]'	,'int')		as [AreaID]
  ,tab.rws.value('@DATE[1]'		,'datetime')as [Date]
  ,tab.rws.value('@BEGIN[1]'	,'tinyint') as [StartHour]
  ,tab.rws.value('@END[1]'		,'tinyint') as [EndHour]
  ,tab.rws.value('@PRIORITY[1]'	,'int')		as [Priority]
  ,tab.rws.value('@ACTIVITY[1]'	,'bit')		as [Activity]
  ,isNull((select 1 from [dbo].[map_AreaTime_Full](nolock) where AreaID = tab.rws.value('@AREAID[1]'	,'int')	and [Date] =tab.rws.value('@DATE[1]','datetime') ),0) as [Exists]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as tab(rws)
-- UPADTE
update [dbo].[map_AreaTime_Full] 
  set [dbo].[map_AreaTime_Full].StartHour	= src.StartHour
     ,[dbo].[map_AreaTime_Full].EndHour		= src.EndHour
	 ,[dbo].[map_AreaTime_Full].[Priority]	= src.[Priority]
output deleted.AreaID, deleted.[Date], 1 into @out
from (select * from @temp where [exists]=1)src
where ([dbo].[map_AreaTime_Full].AreaID = src.AreaID) and ([dbo].[map_AreaTime_Full].[Date] = src.[Date])
-- INSERT
insert into [dbo].[map_AreaTime_Full] 
output inserted.AreaID, inserted.[Date], 2  into @out
select AreaID, [Date], StartHour, EndHour, [Priority] from @temp where [exists]=0
-- prepare return of result
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
GO
print('  Процедура [dbo].[ae_AreaIntervalList_Save] (Сохрание интервала(списка интервалов) доставки) создана.') 
GO

 
--exec dbo.ae_GetFullData '<PARAMS DATE="20140724" AGENT="1"></PARAMS>'
--exec dbo.ae_GetFullData '<PARAMS DATE="20140609" AGENT="1"></PARAMS>'
--exec dbo.ae_AreaIntervalList_load '<XML AREAID="87"/>'  


declare @procname nvarchar(50)
set @procname='[ae_AreaUsed_Load]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_AreaUsed_Load]
(@xmltext varchar(max) = '<REQUEST></REQUEST>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
-->-----------------------------------------

declare @xml xml = CAST(@xmltext as xml)
declare @Begin as datetime
declare @End as datetime
/*2*/declare @mid as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  --set @Begin=@Begin+@End
  --set @End=@Begin-@End
  --set @Begin=@Begin-@End
  /*2*/set @mid=@Begin
  /*2*/set @Begin=@End
  /*2*/set @End=@mid
  end;

select 
   CONVERT(varchar(20),[ATF].[Date],104)+' ('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' [Дата (Интервал)]
  ,[AL].[Name] [Зона]
  ,[ALP].[Name] [Владелец]
from dbo.map_AreaTime_Full(nolock) ATF
join (select id,parentid,name from map_AreaList(nolock)) [AL] on [AL].ID = [ATF].AreaID
left outer join (select id,name from map_AreaList(nolock)) [ALP] on [ALP].ID = [AL].parentid
where ([ATF].[Date]>=@Begin) and ([ATF].[Date]<=@End)
group by CONVERT(varchar(20),[ATF].[Date],104)+' ('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' ,[AL].[Name],[ALP].[Name]
order by 1,2,3

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
GO
print('  Процедура [dbo].[ae_AreaUsed_Load] (Получение списка используемых областей) создана.') 
GO
--exec ae_AreaUsed_Load '<REQUEST BEGIN="20140910" END="20140910"></REQUEST>'
--select * from map_AreaList_log

ALTER PROCEDURE [dbo].[map_SaveOneArea](@xmltext nvarchar(max))
--with execute as 'dbo'
AS
BEGIN
declare @Res int = 0
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
declare @xml	xml
declare @arID	int 
declare @arRS	int 
declare @t		int -- используется только для формирования номера точки в последовательности 


declare @tmpAreaList	table(
							  [RecordState]	int
							, [id]			int
							, [ParentID]	int
							, [Level]		int
							, [Name]		varchar(255) collate Cyrillic_General_CI_AS
							, [RGBLine]		varchar(6)
							, [RGBFill]		varchar(6)
							, [RouteNum]	int
							, [Days]		varchar(7)
							, [ChangeDate]	datetime
                        )
declare @tmpPointList	table([Area_ID] int
							, [NumInSeq] int
							, [Latitude] numeric(17,14)
							, [Longitude] numeric(17,14)
                          )  
declare @arOutID		table(ID int) 
-------------------------------------------------------------------------                                                  
set @xml = CAST(@xmltext as xml)

declare @user varchar(100)
select
   @user = IsNull(tab.rws.value('@USER[1]','varchar(100)'),'def.'+user)
from @xml.nodes('/AREA') as tab(rws)

select @arID = IsNull(tab.rws.value('(ID)[1]', 'int'),0) from @xml.nodes('/AREA') as tab(rws)
select @arRS = IsNull(tab.rws.value('(RECORDSTATE)[1]', 'int'),0) from @xml.nodes('/AREA') as tab(rws)
insert into @tmpAreaList
select
  IsNull(tab.rws.value('(RECORDSTATE)[1]'	, 'int'			),0)		,
  IsNull(tab.rws.value('(ID)[1]'			, 'int'			),0)		,
  IsNull(tab.rws.value('(PARENTID)[1]'	    , 'int'			),0)		,
  IsNull(tab.rws.value('(LEVEL)[1]'			, 'int'			),0)		,
  IsNull(tab.rws.value('(NAME)[1]'			, 'varchar(255)'),'NONAME')	,
  IsNull(tab.rws.value('(RGBLINE)[1]'		, 'varchar(6)'	),'FF0000')	,
  IsNull(tab.rws.value('(RGBFILL)[1]'		, 'varchar(6)'	),'FF0000')	,
  IsNull(tab.rws.value('(ROUTENUM)[1]'		, 'int'			),0)		,
  substring(IsNull(tab.rws.value('(DAYS)[1]'			, 'char(7)'		),'1111111')+'1111111', 1, 7),
  GETDATE()
  from @xml.nodes('/AREA') as tab(rws)
insert into @tmpPointList
select
  @arID													"Area_ID"	,
  ROW_NUMBER() over (order by @t)						"NumInSeq"	,
  tab.rws.value('(LAT)[1]'			, 'numeric(17,14)')	"Latitude"	,
  tab.rws.value('(LNG)[1]'			, 'numeric(17,14)')	"Longitude" 
  from @xml.nodes('/AREA/LATLNG') as tab(rws)   
if ((@arID=0) /*or (@arRS=2)*/ or not (exists(select top 1 * from dbo.map_AreaList(nolock) where ID=@arID)))   
 begin -- добавление области
 insert dbo.map_AreaList([ParentID], [Level], [Name], [RGBLine], [RGBFill], [RouteNum], [Days], [ChangeDate])
  output inserted.id into @arOutID
  select [ParentID], [Level], [Name], [RGBLine], [RGBFill], [RouteNum], [Days], GETDATE() from @tmpAreaList
 select @arID = ID from @arOutID
 insert dbo.map_PointList([Area_ID], [NumInSeq], [Latitude], [Longitude])  
  select @arID,  [NumInSeq], [Latitude], [Longitude] from @tmpPointList
 set @Res = @arID
 end
 else
if ((@arID>0) and (exists(select top 1 * from dbo.map_AreaList(nolock) where ID=@arID)))
 begin  -- редактирование области
 delete from dbo.map_PointList where [Area_ID]=@arID
 update dbo.map_AreaList
  set dbo.map_AreaList.[ParentID]	= src.[ParentID]
	, dbo.map_AreaList.[Level]		= src.[Level]
	, dbo.map_AreaList.[Name]		= src.[Name]
	, dbo.map_AreaList.[RGBLine]		= src.[RGBLine]
	, dbo.map_AreaList.[RGBFill]		= src.[RGBFill]
	, dbo.map_AreaList.[RouteNum]	= src.[RouteNum]
	, dbo.map_AreaList.[Days]		= src.[Days] 
	, dbo.map_AreaList.[ChangeDate]	= getdate()
  from @tmpAreaList src	
  where dbo.map_AreaList.[ID] = @arID
 insert dbo.map_PointList([Area_ID], [NumInSeq], [Latitude], [Longitude])  
  select @arID,  [NumInSeq], [Latitude], [Longitude] from @tmpPointList	
 set @Res=@arID
 end
-- данное действо блокируется ограничениями внешнего ключа 
-- else
--if (@arID<0)
-- begin -- удаление области
-- select GETDATE() -- затычка на отладку 
-- end

insert into dbo.[map_AreaList_log]
      ([AreaId],[DateEdit],[xml]     ,WorkStation,[User],[ipdata])
select @arID   , GetDate(), @xmltext ,HOST_NAME(),IsNull(@user,'def.'+user),[client_net_address]+':'+cast([client_tcp_port] as varchar)
  FROM [master].[sys].[dm_exec_connections](nolock)
  where [session_id]=@@SPID



COMMIT TRAN
select @res
END TRY
BEGIN CATCH -->-- ------------------------- --<--
ROLLBACK TRAN
   set @Res = ERROR_NUMBER() * -1
   set @ErrorString = 'Ошибка в '+IsNull(ERROR_PROCEDURE(),'PROCEDURE*')+
                      '(строка №'+CAST(ERROR_LINE() as varchar(10))+').'+
                      'Код, уровень, статус ошибки : '+CAST(ERROR_NUMBER() as varchar(10))+', '+CAST(ERROR_SEVERITY() as varchar(10))+', '+CAST(ERROR_STATE() as varchar(10))+'.'+
                      'Описание ошибки : '+ERROR_MESSAGE()+'.'
   RaisError('%s',16,1,@ErrorString)   
END CATCH
RETURN @Res
END
GO
print('  Процедура [dbo].[map_SaveOneArea] (Сохранение описания области) создана.') 
GO
-------------------------------------------------------------------------------

declare @procname nvarchar(50)
set @procname='[ae_NoDelivery_Report]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
SET ANSI_PADDING ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_NoDelivery_Report]
(@xmltext varchar(max) = '<REQUEST></REQUEST>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
-->-----------------------------------------

declare @xml xml = CAST(@xmltext as xml)
declare @Begin as datetime
declare @End as datetime
/*2*/declare @mid as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  --set @Begin=@Begin+@End
  --set @End=@Begin-@End
  --set @Begin=@Begin-@End
  /*2*/set @mid=@Begin
  /*2*/set @Begin=@End
  /*2*/set @End=@mid
  end;
--set @End= convert(date,DATEADD(dd,1,@End)) -- заглушка если используется условие <@End
select 
convert(datetime,convert(date, OrderStates.[Date]))"Дата",
[dbo].[cc_Author_GetName](OrderStates.[Author], OrderStates.[User])"Оператор",
convert(varchar,OrderStates.[OrderNo])+'('+refOrderType.[FullName]+')' "№ заказа",
refOrderState.[Description2]+'. '+refOrderState.[Description] "Состояние заказа",
refOrderState.[AdditionalCode] "StateAdditionalCode",
OrderHead.[OrderAmount] "Сумма заказа",
(SELECT [RouteName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"Маршрут",
(SELECT [Driver] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"Водитель",
--(SELECT [CarName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"CarName",
(SELECT [CarNum] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"Гос. номер"
from
(
SELECT [id]
      ,[Description]
      ,[Code]
      ,[AdditionalCode]
	  ,[Description2]
  FROM [dbo].[cc_Ref_OrderStates](nolock)
  where [Code]='05'
  and [AdditionalCode]<>''
)refOrderState
inner join
(
SELECT [OrderNo]
      ,[Host]
      ,[StateId]
      ,[Author]
      ,[User]
      ,[Date]
  FROM [dbo].[cc_Order_State](nolock)
  where [Date]>=@Begin
  and [Date]<=@End
)OrderStates
on refOrderState.id=OrderStates.[StateId]
left join
(
SELECT [OrderNO]
      ,[Host]
      ,[OrderType]
	  ,[OrderAmount]
  FROM [dbo].[cc_OrderHead](nolock)
)OrderHead
on OrderStates.[OrderNo]=OrderHead.[OrderNO] and OrderStates.[Host]=OrderHead.[Host]
left join
(
SELECT [id]
      ,[FullName]
  FROM [dbo].[cc_Ref_OrderTypes](nolock)
)refOrderType
on OrderHead.[OrderType]=refOrderType.[id]
order by 1, 4, 5, 2

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
GO
print('  Процедура [dbo].[ae_NoDelivery_Report] (Отчет о недоставленнох заказах) создана.') 
GO
--exec ae_NoDelivery_Report '<REQUEST BEGIN="20141013" END="20141013"/>'

-------------------------------------------------------------------------------

declare @procname nvarchar(50)
set @procname='[ae_GetCarForDate_Nav]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
SET ANSI_PADDING ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_GetCarForDate_Nav]
(@xmltext varchar(max) = '<REQUEST></REQUEST>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
-->-----------------------------------------
declare @xml xml = CAST(@xmltext as xml)
SELECT distinct 
 [CarNum]
,[Driver] 
FROM [dbo].[RouteDataFromNav](nolock) RDN 
join (select t.r.value('@DATE','datetime') as D from @xml.nodes('/REQUEST') as t(r)) X on RDN.RouteDate=X.D
order by 1,2
-->-----------------------------------------
END TRY
BEGIN CATCH -->-- ------------------------- --<--
   set @Res = ERROR_NUMBER() * -1
   set @ErrorString = 'Ошибка в '+IsNull(ERROR_PROCEDURE(),'PROCEDURE*')+
                      '(строка №'+CAST(ERROR_LINE() as varchar(10))+').'+
                      'Код, уровень, статус ошибки : '+CAST(ERROR_NUMBER() as varchar(10))+', '+CAST(ERROR_SEVERITY() as varchar(10))+', '+CAST(ERROR_STATE() as varchar(10))+'.'+
                      'Описание ошибки : '+ERROR_MESSAGE()+'.'
   RaisError('%s',16,1,@ErrorString)   
END CATCH
RETURN @Res
END
GO
print('  Процедура [dbo].[ae_GetCarForDate_Nav] (Получение списка автомобилей и водителей на определенное число из Navision) создана.') 
GO
--exec ae_GetCarForDate_Nav '<REQUEST DATE="20141013"/>'

declare @procname nvarchar(50)
set @procname='[ae_AccidentList_Edit]'; 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@procname) AND type in (N'P', N'PC'))
exec('create procedure [dbo].'+@procname+' with execute as ''dbo'' as print('''+@procname+' procedure signaled!'')')
exec('grant execute on [dbo].'+@procname+' to [mo2]')
exec('grant view definition on [dbo].'+@procname+' to [mo2]')
GO
SET ANSI_NULLS ON
SET ANSI_PADDING ON
GO
SET QUOTED_IDENTIFIER ON
GO	
ALTER PROCEDURE [dbo].[ae_GetCarForDate_Nav]
(@xmltext varchar(max) = '<DATA></DATA>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRAN
BEGIN TRY
-->-----------------------------------------
declare @xml xml = CAST(@xmltext as xml)
select 
  t.r.value('@ID','int')					as [ID]
 ,t.r.value('@ACDATE','datetime')			as [acData]		-- дата события
 ,t.r.value('@ACPLACE','[varchar](256)')	as [acPlace]	-- место события
 ,t.r.value('@ACCAR','[varchar](10)')		as [acCar]		-- номер автомобиляпо Navision (выбирается по дате)
 ,t.r.value('@ACDRIVER','[varchar](128)')	as [acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
 ,t.r.value('@ACTYPE','[int]')				as [acType]		-- тип (словарь, HardCode (20141015))
 ,t.r.value('@ACNOTE','[varchar](256)')		as [acNote]		-- описание (если тип "Другое" или уточнение)
 ,t.r.value('@CLTYPE','[int]')				as [clType]		-- тип (словарь, HardCode (20141015))
 ,t.r.value('@CLFIO','[varchar](256)')		as [clFIO]		-- ФИО звонившего
 ,t.r.value('@CLPHONE','[varchar](32)')		as [clPhone]	-- телефон звонившего
 ,t.r.value('@RESNOTE','[varchar](256)')	as [resNote]	-- заключение по случаю
from @xml.nodes('/DATA') as t(r)
declare @resTable table(id int)
declare @RecordID	int = 0
declare @Event		int = -1
declare @UserID		int = 0
declare @User		varchar(128) = ''
select 
  @user = IsNull(t.r.value('@USER[1]','varchar(128)'),'def.'+user)
from @xml.nodes('/DATA') as t(r)





insert into dbo.[ae_AccidentList_Log] 
      ([RecordId]  ,[Event],[DateEvent],[UserID] ,[WorkStation],[User]                   ,[ipdata])
select @RecordID   ,@Event , GetDate() , @UserID ,HOST_NAME()  ,IsNull(@User,'def.'+user),[client_net_address]+':'+cast([client_tcp_port] as varchar)
  FROM [master].[sys].[dm_exec_connections](nolock)
where [session_id]=@@SPID
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
GO
print('  Процедура [dbo].[ae_GetCarForDate_Nav] (Получение списка автомобилей и водителей на определенное число из Navision) создана.') 
GO
--exec ae_GetCarForDate_Nav '<REQUEST DATE="20141013"/>'


