print ('Внимание на используемую БД и флаг "пересоздавать таблицы" : @NeedDropTables')
GO
USE MO_Test
GO

--print('Таблицы блока "" ) (префикс "") : '+ DB_NAME()) 
--GO
--declare @NeedDropTables bit = 1 -->-- ВАЖНО!!!
--if @NeedDropTables = 1
--begin
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rt_Drivers_Schedule]') AND type in (N'U'))			
--   DROP TABLE [dbo].[rt_Map_Profile]
--print('  Таблицы блока "" удалены.') 
--end
--GO
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

-- field map_AreaTime_Full.Activity
-- field map_AreaTime_Full.ID

-- table map_Area_Agent(&) AreaID, DeliveryAgent


print('Функции блока "" () (префикс "") : '+ DB_NAME()) 
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


print('Хранимые процедуры блока "" () (префикс "") : '+ DB_NAME()) 
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
print('  Процедура [dbo].[ae_AreaUsed_Load] (Поолучение списка используемых областей) создана.') 
GO



exec ae_AreaUsed_Load '<REQUEST BEGIN="20140910" END="20140910"></REQUEST>'
