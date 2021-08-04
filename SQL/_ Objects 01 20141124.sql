print ('Обратить внимание на используемую БД и флаг "пересоздавать таблицы" : @NeedDropTables')
GO

USE MO_tmp
GO


print('Таблицы блока "AreaEditor" and "Map" ) (префикс "ae_") : '+ DB_NAME()) 
GO
declare @NeedDropTables bit = 0 -->-- ВАЖНО!!!
if @NeedDropTables = 1
begin
-- НЕ ВКЛЮЧАТЬ!!!
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaList_log]') AND type in (N'U'))			
--   DROP TABLE [dbo].[map_AreaList_log]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ae_AccidentList]') AND type in (N'U'))			
   DROP TABLE [dbo].[ae_AccidentList]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ae_AccidentList_Log]') AND type in (N'U'))			
   DROP TABLE [dbo].[ae_AccidentList_Log]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Value]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_Value]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Entity]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_Entity]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Task]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_Task]
-- эти таблицы lst_PermItem, lst_PermUser, lst_PermLink можно было бы не делать , но тогда требуется поле с доменным именем в cc_Ref_Employees  
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermItem]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_PermItem]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermUser]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_PermUser]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermLink]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_PermLink]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermLog]') AND type in (N'U'))			
   DROP TABLE [dbo].[lst_PermLog]
print('  Таблицы блока  "AreaEditor" and "Map" удалены.') 
end
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaTime_Full_View]') AND type in (N'V'))			
   DROP VIEW [dbo].[map_AreaTime_Full_View]
GO

SET ANSI_PADDING ON
GO
-- долго будет выполняться!!! --
declare @ResColumn bit 
SELECT @ResColumn = COLUMNPROPERTY( OBJECT_ID('map_AreaTime_Full'),'Active','AllowsNull')
if @ResColumn is null
  begin
  ALTER TABLE dbo.map_AreaTime_Full ADD Active bit NULL default 1
  if @@ERROR=0
     begin
	 set nocount on
	 /* -- запустить после модификации
	 begin tran
	 update dbo.map_AreaTime_Full set Active=1
	 commit tran
	 */
	 set nocount off
	 print('Таблица "dbo.map_AreaTime_Full" (Active) : модифицирована успешно') 
	 end
   else begin
     print('Таблица "dbo.map_AreaTime_Full" (Active) : ОШИБКА модифицикации') 
   end
  end
  else print('Таблица "dbo.map_AreaTime_Full" (Active) уже модифицирована') 
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
    [resNote]				[varchar](256)		NULL,	-- заключение по случаю (описание)
	[resGuilty]				[tinyint]			NULL	-- заключение по случаю (признак виновности: 0 -unknown,1 -notguilty,2 -guilty)
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
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "ae_AccidentList_Log" (Журнал изменений таблицы "ae_AccidentList")') 
GO

-- задача, группа разрешений, ограничитель версий и т.п.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Task]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_Task](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Task_CODE]				[int]			NOT NULL,
	[Task_Name]				[varchar](128)	NOT NULL,
	[AppName]				[varchar](260)		NULL, -- исполняемый модуль
	[Version]				[varchar](20)		NULL, -- версия (проверка действия и т.п., возможны символы заменители)
	[Active]				[tinyint]		NOT	NULL default 255, -- позиционный код, выключатель, 255=11111111 - включено всё
	[Task_Type]				[tinyint]		NOT	NULL  -- тип задачи (на 20141106 : 0 - словарь, 1 - исполняемая)
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_Task" (Список задач)') 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Entity]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_Entity](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Task_CODE]				[int]			NOT	NULL, -- для "общедостпности" следует завести "общедоступную для всех" задачу
	[Entity_CODE]			[int]			NOT NULL,
	[Entity_Name]			[varchar](128)	NOT NULL
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_Entity" (Список сущностей (классов, групп значений и т.п.))') 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_Value]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_Value](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ParentID]				[int]				NULL, -- для организации иерархических справочников
	[Entity_CODE]			[int]			NOT NULL,
	[Value]					sql_variant		NOT NULL  -- 
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_Value" (Список значений для справочных списков (линейных и иерархических))') 
GO

-- заполнение для "ДТП" ------------------
declare @Task_Code int = 1
declare @Task_Name varchar(64) = 'ДТП'
declare @Entity_Code int = 1
declare @Entity_Name varchar(64) = 'Тип нарушения'
set nocount on 
begin try
begin tran
if not exists(select * from dbo.lst_Task where Task_code=@Task_Code and Task_name=@Task_name)
   begin
   insert dbo.lst_Task(Task_Code, Task_name, AppName, [Version], Active, Task_Type) values(@Task_Code,@Task_name, '', 0, 255, 0)
   --print('  Таблица "lst_Value" : '+@Task_Name)
   end
if not exists(select * from dbo.lst_Entity where Entity_Code=@Entity_Code and Entity_name=@Entity_name)
   begin
   insert dbo.lst_Entity(Task_Code, Entity_Code, Entity_name) values(@Task_Code, @Entity_Code, @Entity_name)
   --print('  Таблица "lst_Entity" : '+@Entity_name)
   end
if not exists(select * from dbo.lst_Value where Entity_code=@Entity_code) 
   begin
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Агрессивный стиль вождения (резкое торможение, перестроение, подрезание и т.п.)')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Движение в обратном направлении по односторонней улице')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Движение по встречной полосе')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Наезд на пешехода')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Не правильная остановка и стоянка (парковка)')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Пересечение двойной сплошной')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Превышение скорости')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Проезд на запрещающий сигнал светофора')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Скрылся с места ДТП')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Столкновение с другим Т/С')
   insert dbo.lst_value(ParentID,Entity_Code,Value) values(null, @Entity_Code,'Другое (описать нарушение ПДД)')
   end
commit tran
end try
begin catch
while @@trancount>0 rollback tran
print('  Ошибка при подготовке списка (['+@Task_Name+'].['+@Entity_Name+'] : ' + ERROR_MESSAGE())
end catch
set nocount off 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermItem]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_PermItem](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Task_CODE]				[int]			NOT	NULL, -- указатель на задачу, т.е., в данном случае, на группу разрешений
	[CODE]					[int]			NOT NULL, -- код разрешения( в т.ч. для связи с внутренними типами приложения)  
	[Name]					[varchar](128)	NOT NULL, -- описание разрешения 
	[Active]				[tinyint]		NOT NULL default 255 -- позиционный код, выключатель, 255=11111111 - включено всё (по любому bit хранится в байте)
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_PermItem" (Список разрешений по задачам для пользователя)') 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermUser]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_PermUser](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DomainName]			[varchar](64)	NOT NULL, -- доменное имя пользователя
	[NormalName]			[varchar](128)	NOT NULL, -- FIO пользователя	
	[mo2_userId]			[int]				NULL, -- опцион
	[Active]				[tinyint]		NOT NULL default 255 -- позиционный код, выключатель, 255=11111111 - включено всё (по любому bit хранится в байте)
	-- можно еще таблицу с графиками доступа сделать
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_PermUser" (Список пользователей)') 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermLink]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_PermLink](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ID_PermUser]			[int]			NOT NULL, -- доменное имя пользователя
	[ID_PermItem]			[int]			NOT NULL, -- FIO пользователя	
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_PermLink" (Таблица связок "Пользователь - Разрешение")') 
GO

-- на 24.11.2014 значение поля Entity 
--  0 -- добавление 
--  1 -- изменение
--  2 -- удаление
-- 30 -- отключение сущности (Active = 0 (false))
-- 31 -- включение (Active > 0 (true))

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lst_PermLog]') AND type in (N'U'))	
CREATE TABLE [dbo].[lst_PermLog](
	[ID]					[int]			IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Entity]				[int]			NOT NULL, --
	[RecordID]				[int]			NOT NULL, --
	[Event]					[tinyint]		NOT NULL, --
	[EventDate]				[datetime]		NOT NULL, --
	[User]					[varchar](64)	NOT NULL, --
	[WorkStation]			[varchar](64)	NOT NULL  --
 ) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
print('  Таблица "lst_PermLog" (Таблица журнала изменений задач, прав, пользователей)') 
GO

-- заполнение для "ДТП" ------------------
declare @Task_Code int = 2
declare @Task_Name varchar(64) = 'AreaEditor'
declare @DomainName varchar(64)='s.kholin'
declare @out table(id int)
declare @id_permuser int

set nocount on 
begin try
begin tran
if not exists(select * from dbo.lst_Task where Task_code=@Task_Code and Task_name=@Task_name)
   begin
   insert dbo.lst_Task(Task_Code, Task_name, AppName, [Version], Active, Task_Type) values(@Task_Code,@Task_name,'AreaEditor.exe','1.0',255,1)
   --print('  Таблица "lst_Value" : '+@Task_Name)
   end

if not exists(select * from dbo.lst_PermUser where DomainName=@DomainName) 
   begin
   insert dbo.[lst_PermUser]([DomainName],[NormalName],[mo2_userId],[Active])
   output inserted.ID into @out
   values(@DomainName,@DomainName,125,255)
   select @id_permuser = id from @out
   end
   else begin
   select @id_permuser = id from dbo.[lst_PermUser] where DomainName=@DomainName 
   end
delete from @out

declare @PermCode int
declare @PermName varchar(128)


set @PermCode = 0
set @PermName = 'Запуск задачи' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out


set @PermCode = 1
set @PermName = 'Просмотр областей' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out

set @PermCode = 2
set @PermName = 'Редактирование областей' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out

set @PermCode = 3
set @PermName = 'Просмотр точек доставки' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out
   
set @PermCode = 4
set @PermName = 'Подготовка маршрута доставки' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out

set @PermCode = 5
set @PermName = 'Данные по Москве' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out

set @PermCode = 6
set @PermName = 'Данные по Санкт-Петербургу' 
if not exists(select * from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName) 
   insert dbo.lst_PermItem([Task_CODE],[CODE],[Name],[Active]) 
   output inserted.ID into @out
   values(@Task_Code,@PermCode,@PermName,255)
 else 
   insert @out select id from dbo.lst_PermItem where task_code=@Task_Code and code=@PermCode and [Name]=@PermName
if not exists(select * from dbo.lst_PermLink p join @out o on o.id = p.ID_PermItem and p.ID_PermUser = @id_permuser)
   insert dbo.lst_PermLink(ID_PermUser, ID_PermItem) select @id_permuser, id from @out
delete from @out

while @@trancount>0 commit tran
end try
begin catch
while @@trancount>0 rollback tran
print('  Ошибка при подготовке списка (['+@Task_Name+'] : ' + ERROR_MESSAGE())
end catch
set nocount off 
GO

--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[map_AreaTime_Full_View]') AND type in (N'V'))		
CREATE VIEW [dbo].[map_AreaTime_Full_View]
AS
select 
  [AreaID]
 ,[Date]
 ,[StartHour]
 ,[EndHour]
 ,[Priority]
 ,[Active]
from dbo.map_AreaTime_Full(nolock)
where [Active]=1 
GO
print('  Представление "map_AreaTime_Full_View" (Список активных интервалов)') 
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vfn_RandomDate]') and xtype in (N'V'))
drop view [dbo].[vfn_RandomDate]
GO
CREATE VIEW dbo.vfn_RandomDate(val) AS SELECT cast(cast(cast('0x'+substring(cast(newid() as varchar(36)),1,4) as  BINARY(4)) as int) - 813140000 as datetime)--- 813142000 as datetime);
GO
print('  .Представление [dbo].[vfn_RandomDate] (использование в функции [dbo].[fn_RandomDate]) создана.') 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vfn_NewID]') and xtype in (N'V'))
drop view [dbo].[vfn_NewID]
GO
CREATE VIEW dbo.vfn_NewID(val) AS SELECT newid()
GO
print('  .Представление [dbo].[vfn_NewID] (Получение значения NewID() в функциях) создана.') 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_RandomDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_RandomDate]
GO
CREATE FUNCTION [dbo].[fn_RandomDate] (@mindate date, @maxdate date)  
RETURNS datetime AS  
BEGIN
declare @tmpdate datetime = null 
select @tmpdate=val from [dbo].[vfn_RandomDate]
declare @y int = 0
declare @m int = 0
declare @d int = 0
if @tmpdate<@mindate
   begin 
   --set @y = datepart(yy,@tmpdate)
   set @tmpdate = dateadd(yy,Abs(datepart(yy,@mindate)-datepart(yy,@tmpdate)/*@y*/),@tmpdate)
   if @tmpdate<@mindate
      begin 
      --set @m = datepart(mm,@tmpdate)
      set @tmpdate = dateadd(mm,abs(datepart(mm,@mindate)-datepart(mm,@tmpdate)/*@m*/),@tmpdate)
      end
   if @tmpdate<@mindate
      begin 
      --set @d = datepart(dd,@tmpdate)
      set @tmpdate = dateadd(dd,abs(datepart(dd,@mindate)-datepart(dd,@tmpdate)/*@d*/),@tmpdate)
      end
   end
   else
if @tmpdate>@maxdate
   begin 
   --set @y = datepart(yy,@tmpdate)  
   set @tmpdate = dateadd(yy,datepart(yy,@maxdate)-datepart(yy,@tmpdate)/*@y*/,@tmpdate)
   if @tmpdate>@maxdate
      begin 
      --set @m = datepart(mm,@tmpdate)
      set @tmpdate = dateadd(mm,datepart(mm,@maxdate)- datepart(mm,@tmpdate)/*@m*/,@tmpdate)
      end
  if @tmpdate>@maxdate
     begin 
     --set @d = datepart(dd,@tmpdate)
     set @tmpdate = dateadd(dd,datepart(dd,@maxdate)-datepart(dd,@tmpdate)/*@d*/,@tmpdate)
     end
  end
--select @mindate, @tmpdate, @maxDate
return @tmpdate
END
GO
print('  Функция [dbo].[fn_RandomDate] (Получение случайной даты (отладочные цели)) создана.') 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_RandomInt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_RandomInt]
GO
CREATE FUNCTION [dbo].[fn_RandomInt] (@min int, @max int)  
RETURNS int AS  
BEGIN
declare @res int = 0
select @res=checksum(val) from [dbo].[vfn_NewID]
if @min>0 set @res=abs(@res)
while not (@res between @min and @max)
  set @res = @res/3 
--select @min, @res, @max
return @res
END
GO
print('  Функция [dbo].[fn_RandomInt] (Получение случайного целого (отладочные цели)) создана.') 
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
      ,ATF.[Active]		as [aiActive]
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
declare @temp table(ID int, AreaID int, [Date] datetime,StartHour tinyint, EndHour tinyint, [Priority] int, Active bit, [exists] bit)
declare @out table (AreaID int, [Date] datetime, Oper tinyint)
insert into @temp
  select 
   tab.rws.value('@ID[1]'		,'int')		as [ID]
  ,tab.rws.value('@AREAID[1]'	,'int')		as [AreaID]
  ,tab.rws.value('@DATE[1]'		,'datetime')as [Date]
  ,tab.rws.value('@BEGIN[1]'	,'tinyint') as [StartHour]
  ,tab.rws.value('@END[1]'		,'tinyint') as [EndHour]
  ,tab.rws.value('@PRIORITY[1]'	,'int')		as [Priority]
  ,IsNull(IsNUll(tab.rws.value('@ACTIVITY[1]'	,'bit'),tab.rws.value('@ACTIVE[1]'	,'bit')),1) as [Active]  -- для обратной совместимости сохранено такое наименование параметра
  ,isNull((select 1 from [dbo].[map_AreaTime_Full](nolock) where AreaID = tab.rws.value('@AREAID[1]'	,'int')	and [Date] =tab.rws.value('@DATE[1]','datetime') ),0) as [Exists]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as tab(rws)
-- UPADTE
update [dbo].[map_AreaTime_Full] 
  set [dbo].[map_AreaTime_Full].StartHour	= src.StartHour
     ,[dbo].[map_AreaTime_Full].EndHour		= src.EndHour
	 ,[dbo].[map_AreaTime_Full].[Priority]	= src.[Priority]
	 ,[dbo].[map_AreaTime_Full].[Active]	= src.[Active]
output deleted.AreaID, deleted.[Date], 1 into @out
from (select * from @temp where [exists]=1)src
where ([dbo].[map_AreaTime_Full].AreaID = src.AreaID) and ([dbo].[map_AreaTime_Full].[Date] = src.[Date])
-- INSERT
insert into [dbo].[map_AreaTime_Full] 
output inserted.AreaID, inserted.[Date], 2  into @out
select AreaID, [Date], StartHour, EndHour, [Priority],[Active] from @temp where [exists]=0
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
	, dbo.map_AreaList.[RGBLine]	= src.[RGBLine]
	, dbo.map_AreaList.[RGBFill]	= src.[RGBFill]
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
set @procname='[ae_NoDelivery_Report_SRC]'; 
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
ALTER PROCEDURE [dbo].[ae_NoDelivery_Report_SRC]
(@xmltext varchar(max) = '<REQUEST></REQUEST>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
--BEGIN TRAN
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
-->-- 20141107 (сутки начинаются и заканчиваются в 7.00) --<--
set @Begin = convert(datetime,convert(date, @Begin))	
set @End = convert(datetime,convert(date, @End))	
set @Begin = DateAdd(hour , 7, @Begin)
set @End = DateAdd(hour , 7, DateAdd(day,1,@End))
-- ATTENTION : переключено условие <=@End на <@End
-->-- 20141107 --<-- ---------------------------------------------------------------------
select 
convert(datetime,convert(date, OrderStates.[Date]))						"Дата",
[dbo].[cc_Author_GetName](OrderStates.[Author], OrderStates.[User])		"Оператор",
convert(varchar,OrderStates.[OrderNo])+'('+refOrderType.[FullName]+')'	"№ заказа",
refOrderState.[Description2]+'. '+refOrderState.[Description]			"Состояние заказа",
refOrderState.[AdditionalCode]											"StateAdditionalCode",
OrderHead.[OrderAmount]													"Сумма заказа",
RDN.[RouteName]															"Маршрут",
RDN.[Driver]															"Водитель",
RDN.[CarNum]															"Гос. номер",
OrderStates.[Date]														"RealDate"	
from
(
SELECT [id]
      ,[Description]
      ,[Code]
      ,[AdditionalCode]
	  ,[Description2]
  FROM [dbo].[cc_Ref_OrderStates](nolock)
  where [Code]='05' and [AdditionalCode]<>'' -- перенос 
)refOrderState -- это состояние заказов
inner join -- это описание заказов
(SELECT [OrderNo]
       ,[Host]
       ,[StateId]
       ,[Author]
       ,[User]
       ,[Date]
  FROM [dbo].[cc_Order_State](nolock)
  -->-- 20141107 -- where convert(date, [Date])>=@Begin and convert(date, [Date])<=@End
  where [Date]>=@Begin and [Date]<@End
)OrderStates on refOrderState.id=OrderStates.[StateId]
left join -- это описание маршрутов из Navision
(SELECT [RouteName]
       ,[Driver]
	   ,[CarNum]
	   ,[RouteDate]
	   ,[OrderNo]
	   ,[Host] 
	   FROM [dbo].[RouteDataFromNav](nolock)
) RDN on RDN.[RouteDate]=convert(date, OrderStates.[Date]) and RDN.[OrderNo]=OrderStates.[OrderNo] and RDN.[Host]=OrderStates.Host
left join
(SELECT [OrderNO]
       ,[Host]
       ,[OrderType]
   	   ,[OrderAmount]
  FROM [dbo].[cc_OrderHead](nolock)
) OrderHead on OrderStates.[OrderNo]=OrderHead.[OrderNO] and OrderStates.[Host]=OrderHead.[Host]
left join
(SELECT [id]
       ,[FullName]
   FROM [dbo].[cc_Ref_OrderTypes](nolock)
)refOrderType on OrderHead.[OrderType]=refOrderType.[id]
order by 1, 4, 5, 2
-->-----------------------------------------
--COMMIT TRAN
END TRY
BEGIN CATCH -->-- ------------------------- --<--
--WHILE @@TRANCOUNT>0 BEGIN ROLLBACK TRAN END
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
print('  Процедура [dbo].[ae_NoDelivery_Report_SRC] (Отчет о недоставленных заказах (Исходная)) создана.') 
GO
--exec ae_NoDelivery_Report_SRC '<REQUEST BEGIN="20141013" END="20141013"/>'

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

declare @temp table (
  [Дата]				datetime
 ,[Оператор]			varchar(200)
 ,[№ заказа]			varchar(200)
 ,[Состояние заказа]	varchar(200)
 ,[StateAdditionalCode]	varchar(200)
 ,[Сумма заказа]		money
 ,[Маршрут]				varchar(200)
 ,[Водитель]			varchar(200)
 ,[Гос. номер]			varchar(10)
 ,[RealDate]			datetime
 )
	
insert @temp
exec ae_NoDelivery_Report_SRC @xmltext
select 
  Src.[Дата]
 ,Src.[Оператор]
 ,Src.[№ заказа]
 ,Src.[Состояние заказа]
 ,Src.[StateAdditionalCode]
 ,Src.[Сумма заказа]
 ,Src.[Маршрут]
 ,Src.[Водитель]
 ,Src.[Гос. номер]
 ,Src.[RealDate]
from @temp Src
join (select max([RealDate]) [MaxDate], [№ заказа] from @temp group by [№ заказа]) Flt on Flt.MaxDate = Src.RealDate and Flt.[№ заказа] = Src.[№ заказа]
END TRY
BEGIN CATCH -->-- ------------------------- --<--
--WHILE @@TRANCOUNT>0 BEGIN ROLLBACK TRAN END
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
print('  Процедура [dbo].[ae_NoDelivery_Report] (Отчет о недоставленных заказах (с максимальной датой)) создана.') 
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
set @procname='[ae_AccidentList_Load]'; 
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
ALTER PROCEDURE [dbo].[ae_AccidentList_Load]
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
declare @Begin as datetime
declare @End as datetime
declare @mid as datetime
declare @empty as bit
declare @id as integer
select  @Begin = t.r.value('@BEGIN','datetime')
      , @End = t.r.value('@END','datetime')
	  , @empty= t.r.value('@EMPTY','bit') 
	  , @id= t.r.value('@ID','int') 
from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  set @mid=@Begin
  set @Begin=@End
  set @End=@mid
  end;

if IsNull(@id,0)>0
  begin
select  
     AL.[ID]
    ,AL.[acDate]	-- дата события
    ,AL.[acPlace]	-- место события
    ,AL.[acCar]	-- номер автомобиля по Navision (выбирается по дате)
    ,AL.[acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,AL.[acType]	-- тип (словарь, HardCode (20141015))
    ,AL.[acNote]	-- описание (если тип "Другое" или уточнение)
    ,AL.[clType]	-- тип (словарь, HardCode (20141015))
    ,AL.[clFIO]	-- ФИО звонившего
    ,AL.[clPhone]	-- телефон звонившего
    ,AL.[resNote]	-- заключение по случаю (описание)
	,AL.[resGuilty]-- заключение по случаю (признак виновности)
    ,Alog0.[DateEvent] -- дата добавления
	,Alog0.[User] -- оператор
	,Alog4.[DateEvent]-- дата резолюции
	,Alog4.[User] -- логист
   from dbo.ae_AccidentList(nolock) AL
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=0) AlogAdd on AlogAdd.RecordID = AL.ID
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=4) AlogRes on AlogRes.RecordID = AL.ID
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog0 on Alog0.RecordID = AlogAdd.RecordID and Alog0.DateEvent =  AlogAdd.MaxDateEvent 
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=4) Alog4 on Alog4.RecordID = AlogRes.RecordID and Alog4.DateEvent =  AlogRes.MaxDateEvent 
   where [ID]=@id
  end
  else
if isNull(@empty,0)=0
select  
     AL.[ID]
    ,AL.[acDate]	-- дата события
    ,AL.[acPlace]	-- место события
    ,AL.[acCar]	-- номер автомобиля по Navision (выбирается по дате)
    ,AL.[acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,AL.[acType]	-- тип (словарь, HardCode (20141015))
    ,AL.[acNote]	-- описание (если тип "Другое" или уточнение)
    ,AL.[clType]	-- тип (словарь, HardCode (20141015))
    ,AL.[clFIO]	-- ФИО звонившего
    ,AL.[clPhone]	-- телефон звонившего
    ,AL.[resNote]	-- заключение по случаю (описание)
	,AL.[resGuilty]-- заключение по случаю (признак виновности)
    ,Alog0.[DateEvent] -- дата добавления
	,Alog0.[User] -- оператор
	,Alog4.[DateEvent]-- дата резолюции
	,Alog4.[User] -- логист
   from dbo.ae_AccidentList(nolock) AL
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=0) AlogAdd on AlogAdd.RecordID = AL.ID
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=4) AlogRes on AlogRes.RecordID = AL.ID
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog0 on Alog0.RecordID = AlogAdd.RecordID and Alog0.DateEvent =  AlogAdd.MaxDateEvent 
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=4) Alog4 on Alog4.RecordID = AlogRes.RecordID and Alog4.DateEvent =  AlogRes.MaxDateEvent 
   where [acDate]>=@Begin and [acDate]<=@End
   else
   select  
     AL.[ID]
    ,AL.[acDate]	-- дата события
    ,AL.[acPlace]	-- место события
    ,AL.[acCar]	-- номер автомобиля по Navision (выбирается по дате)
    ,AL.[acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,AL.[acType]	-- тип (словарь, HardCode (20141015))
    ,AL.[acNote]	-- описание (если тип "Другое" или уточнение)
    ,AL.[clType]	-- тип (словарь, HardCode (20141015))
    ,AL.[clFIO]	-- ФИО звонившего
    ,AL.[clPhone]	-- телефон звонившего
    ,AL.[resNote]	-- заключение по случаю (описание)
	,AL.[resGuilty]-- заключение по случаю (признак виновности)
    ,Alog0.[DateEvent] -- дата добавления
	,Alog0.[User] -- оператор
	,Alog4.[DateEvent]-- дата резолюции
	,Alog4.[User] -- логист
   from dbo.ae_AccidentList(nolock) AL
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=0) AlogAdd on AlogAdd.RecordID = AL.ID
   left join (select [RecordID],[Event],max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event]  having [Event]=4) AlogRes on AlogRes.RecordID = AL.ID
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog0 on Alog0.RecordID = AlogAdd.RecordID and Alog0.DateEvent =  AlogAdd.MaxDateEvent 
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=4) Alog4 on Alog4.RecordID = AlogRes.RecordID and Alog4.DateEvent =  AlogRes.MaxDateEvent 
   where [resGuilty]=0

--set @End= convert(date,DATEADD(dd,1,@End)) -- заглушка если используется условие <@End

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
print('  Процедура [dbo].[ae_AccidentList_Load] (Получение списка инцедентов) создана.') 
GO


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
ALTER PROCEDURE [dbo].[ae_AccidentList_Edit]
(@xmltext varchar(max) = '<DATA></DATA>')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRAN
BEGIN TRY
-- на самом деле эту процедуру стоило назвать ae_Accident>>ITEM<<_Edit
-->-----------------------------------------
declare @xml xml = CAST(@xmltext as xml)
declare @srcTable table(
     [ID]					[int]			NOT NULL
    ,[acDate]				[datetime]		NOT NULL	-- дата события
    ,[acPlace]				[varchar](256)	NOT NULL	-- место события
    ,[acCar]				[varchar](10)	NOT NULL	-- номер автомобиля по Navision (выбирается по дате)
    ,[acDriver]				[varchar](128)	NOT NULL	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,[acType]				[int]			NOT NULL	-- тип (словарь, HardCode (20141015))
    ,[acNote]				[varchar](256)	NOT NULL	-- описание (если тип "Другое" или уточнение)
    ,[clType]				[int]			NOT NULL	-- тип (словарь, HardCode (20141015))
    ,[clFIO]				[varchar](256)	NOT NULL	-- ФИО звонившего
    ,[clPhone]				[varchar](32)	NOT NULL	-- телефон звонившего
    ,[resNote]				[varchar](256)		NULL	-- заключение по случаю (описание)
	,[resGuilty]			[tinyint]			NULL	-- заключение по случаю (признак виновности)
	)
insert into @srcTable 
select 
  t.r.value('@ID'		,'int')				as [ID]
 ,t.r.value('@ACDATE'	,'datetime')		as [acData]		-- дата события
 ,t.r.value('@ACPLACE'	,'[varchar](256)')	as [acPlace]	-- место события
 ,t.r.value('@ACCAR'	,'[varchar](10)')	as [acCar]		-- номер автомобиляпо Navision (выбирается по дате)
 ,t.r.value('@ACDRIVER'	,'[varchar](128)')	as [acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
 ,t.r.value('@ACTYPE'	,'[int]')			as [acType]		-- тип (словарь, HardCode (20141015))
 ,t.r.value('@ACNOTE'	,'[varchar](256)')	as [acNote]		-- описание (если тип "Другое" или уточнение)
 ,t.r.value('@CLTYPE'	,'[int]')			as [clType]		-- тип (словарь, HardCode (20141015))
 ,t.r.value('@CLFIO'	,'[varchar](256)')	as [clFIO]		-- ФИО звонившего
 ,t.r.value('@CLPHONE'	,'[varchar](32)')	as [clPhone]	-- телефон звонившего
 ,t.r.value('@RESNOTE'	,'[varchar](256)')	as [resNote]	-- заключение по случаю (описание)
 ,t.r.value('@RESGUILTY','[tinyint]')		as [resGuilty]	-- заключение по случаю (признак виновности)
from @xml.nodes('/DATA') as t(r)
declare @resTable table(id int)
declare @RecordID	int = 0
declare @Event		int = -1
declare @UserID		int = 0
declare @User		varchar(128) = ''
declare @WS 		varchar(128) = ''
declare @verdict    tinyint = 0   

select 
  @UserID	= IsNull(t.r.value('@USERID'	,'int'),0)
 ,@User		= IsNull(t.r.value('@USERNAME'	,'[varchar](128)'),'def.'+user)
 ,@WS		= IsNull(t.r.value('@WS'		,'[varchar](128)'),HOST_NAME())
from @xml.nodes('/DATA') as t(r)

select @Res = ID from @srcTable
if @Res=0
  begin
  insert dbo.ae_AccidentList
        (acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote, resGuilty)
  output inserted.ID into @resTable
  select acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote, resGuilty from @srcTable
  select @Res=id from @resTable
  set @Event = 0
  end
  else
if @Res>0
  begin
  update dbo.ae_AccidentList 
  set [acDate]	= SRC.[acDate]
    ,[acPlace]	= SRC.[acPlace]
    ,[acCar]	= SRC.[acCar]
    ,[acDriver]	= SRC.[acDriver]
    ,[acType]	= SRC.[acType]
    ,[acNote]	= SRC.[acNote]
    ,[clType]	= SRC.[clType]
    ,[clFIO]	= SRC.[clFIO]
    ,[clPhone]	= SRC.[clPhone]
    ,[resNote]	= SRC.[resNote]
	,[resGuilty]= SRC.[resGuilty]
  from (select * from @srcTable)  SRC
  where dbo.ae_AccidentList.ID = SRC.id	
  select @verdict=IsNull(SRC.[resGuilty],0) from @srcTable SRC
  if @verdict=0 set @Event = 1 else set @Event = 4
  end
  else
if @Res<0
  begin
  set @Res=Abs(@Res)
  delete from dbo.ae_AccidentList where ID=@Res
  set @Event = 2
  end
  else set @Res=0
--> ae_AccidentList_Log.Event
-- 0 добавление
-- 1 изменение
-- 2 удаление
-- 4 изменение вердикта
insert into dbo.[ae_AccidentList_Log] 
       ([RecordId],[Event],[DateEvent],[UserID] ,[WorkStation],[User] )
values (@Res      ,@Event , GetDate() , @UserID ,@WS          ,@User  )

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
print('  Процедура [dbo].[ae_AccidentList_Edit] (Сохранение данных об инцеденте) создана.') 
GO
--exec ae_AccidentList_Edit ''<DATA ID="0" ACDATE="20141026" ACPLACE="Москва Самокатная 1" ACCAR="е334ко777" ACDRIVER="Самойленко Антон" ACTYPE="5" ACNOTE="" CLTYPE="3" CLFIO="Шутник Епифан Афиногенович" CLPHONE="000-0000" RESNOTE="" RESGUILTY="0" USERID="125" USERNAME="s.kholin" WS="KUPIVIP00000"/>''

declare @procname nvarchar(50)
set @procname='[ae_AreaLogList_Load]'; 
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
ALTER PROCEDURE [dbo].[ae_AreaLogList_Load]
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
declare @Begin as datetime
declare @End as datetime
declare @mid as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  set @mid=@Begin
  set @Begin=@End
  set @End=@mid
  end;
--set @End= convert(date,DATEADD(dd,1,@End)) -- заглушка если используется условие <@End
select  
     ALLog.[ID]
	,ALLog.[AreaID]	
    ,ALLog.[DateEdit]	
    ,ALLog.[User]
	,ALLog.[WorkStation]
	,Al.[Name] as AreaName
	,ALLog.[xml]
from dbo.map_AreaList_log(nolock) ALLog
join (select [ID],[Name] from dbo. map_AreaList(nolock)) AL on AL.id = ALLog.AreaId
where CONVERT(date,[DateEdit])>=@Begin and CONVERT(date,[DateEdit])<=@End
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
print('  Процедура [dbo].[ae_AreaLogList_Load] (Получение записей журнала изменения областей) создана.') 
GO
--exec ae_AreaLogList_Load '<REQUEST BEGIN="20141023" END="20141112"/>'

declare @procname nvarchar(50)
set @procname='[lst_Load]'; 
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
ALTER PROCEDURE [dbo].[lst_Load]
(@xmltext varchar(max) = '<LIST />')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
-->-----------------------------------------
declare @xml xml = CAST(@xmltext as xml)
select id, Value from dbo.lst_Value(nolock) Val 
join (select IsNull(t.r.value('@ENTITY','int'),0) Entity_Code from @xml.nodes('/LIST') as t(r)) FLT on Val.Entity_Code = FLT.Entity_Code 
--declare @Task int = 0
--declare @Entity int = 0
--select @Task = IsNull(t.r.value('@TASK','int'),0)
--     ,@Entity = IsNull(t.r.value('@ENTITY','int'),0)
--from @xml.nodes('/LIST') as t(r) 
--select id, Value from dbo.lst_Value(nolock) Val where Entity_Code = @Entity 
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
print('  Процедура [dbo].[lst_Load] (Получение списка для определенной сущности) создана.') 
GO
-- exec [dbo].[lst_Load] '<LIST TASK="1" ENTITY="1" />'

declare @procname nvarchar(50)
set @procname='[lst_Permissions_Load]'; 
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
ALTER PROCEDURE [dbo].[lst_Permissions_Load]
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
-->-----------------------------------------
declare @xml xml 
declare @SrcTable table (dtType int, dataset xml)
set @Res=0
set @xml = 
  (select  
     T.[ID]			"tiID"
    ,T.[Task_CODE]	"tiCODE"
	,T.[Task_Name]	"tiNAME"
	,T.[AppName]	"tiAPPNAME"
	,T.[Version]	"tiVERSION"
	,T.[Active]		"tiACTIVE"
	,T.[Task_Type]	"tiTYPE"
from dbo.lst_Task(nolock) T for xml auto ,elements)
insert @SrcTable values(1,@xml)
set @Res=@Res+1
set @xml = 
  (select 
     I.[ID]			"piID"
    ,I.[Task_CODE]	"piTASKCODE"
	,I.[CODE]		"piCODE"
	,I.[Name]		"piNAME"
	,I.[Active]		"piACTIVE"
from dbo.lst_PermItem(nolock) I for xml auto ,elements)
insert @SrcTable values(2,@xml)
set @Res=@Res+1
set @xml = 
  (select 
     U.[ID]			"uiID"
	,U.[DomainName]	"uiDOMAINNAME"
	,U.[NormalName] "uiNORMALNAME"
	,U.[mo2_userId]	"uiMO2_USERID"
	,U.[Active]		"uiACTIVE"
from dbo.lst_PermUser(nolock) U for xml auto ,elements)
insert @SrcTable values(3,@xml)
set @Res=@Res+1
set @xml = 
  (select 
     L.[ID]			"liID"
    ,L.[ID_PermUser]"liPERMUSER"
	,L.[ID_PermItem]"liPERMITEM"
from dbo.lst_PermLink(nolock) L for xml auto ,elements)
insert @SrcTable values(4,@xml)
set @Res=@Res+1
select dtType, dataset from @SrcTable
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
print('  Процедура [dbo].[lst_Permissions_Load] (Получение списков для работы с разграничением доступа) создана.') 
GO


declare @procname nvarchar(50)
set @procname='[lst_TaskItem_Save]'; 
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
ALTER PROCEDURE [dbo].[lst_TaskItem_Save](@xmltext varchar(max) = '<DATA />')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
declare @xml xml = CAST(@xmltext as xml)

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
print('  Процедура [dbo].[lst_TaskItem_Save] (Сохранение описания задачи) создана.') 
GO

declare @procname nvarchar(50)
set @procname='[lst_PermItem_Save]'; 
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
ALTER PROCEDURE [dbo].[lst_PermItem_Save](@xmltext varchar(max) = '<DATA />')
with execute as 'dbo'
AS
BEGIN
declare @Res int
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
declare @xml xml = CAST(@xmltext as xml)

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
print('  Процедура [dbo].[lst_PermItem_Save] (Сохранение описания разрешения) создана.') 
GO

declare @procname nvarchar(50)
set @procname='[lst_UserItem_Save]'; 
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
ALTER PROCEDURE [dbo].[lst_UserItem_Save](@xmltext varchar(max) = '<DATA />')
with execute as 'dbo'
AS
BEGIN
declare @Res int = 0
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
declare @xml xml = CAST(@xmltext as xml)
------------------------------------------
BEGIN TRAN
declare @user varchar(64)
declare @workstation varchar(64)
declare @group_update bit 
select 
   @user         = t.r.value('@USER[1]'					, 'varchar(128)')
  ,@workstation  = t.r.value('@WORKSTATION[1]'			, 'varchar(128)')
  ,@group_update = IsNull(t.r.value('@GROUP_UPDATE[1]'	, 'bit'),0)
from 
 @xml.nodes('/DATA') as t(r)
-- debug -- select @user, @workstation
declare @temptable table (uiID int
                        , uiDomainName varchar(128)
						, uiNormalName varchar(128)
						, uiMO2_UserID int
						, uiActive tinyint
						, resID int)
declare @restable table ( ID int
                        , DomainName varchar(128))
--  0 -- добавление 
--  1 -- изменение
--  2 -- удаление
-- 30 -- отключение
-- 31 -- включение
declare @logtable table (Entity int
						,RecordID int
						,[Event] tinyint
						,[EventDate] datetime
						,[User] varchar(64)
						,[WorkStation] varchar(64))
insert into @temptable
select 
   t.r.value('@uiID[1]'			, 'int')
  ,t.r.value('@uiDOMAINNAME[1]'	, 'varchar(128)')
  ,t.r.value('@uiNORMALNAME[1]'	, 'varchar(128)')
  ,t.r.value('@uiMO2_USERID[1]'	, 'int')
  ,t.r.value('@uiACTIVE[1]'		, 'tinyint')
  ,0
from 
 @xml.nodes('/DATA/I') as t(r)

-- защита от повторного добавления, НО  (!!!!) не изменения (могут быть изменены NormalName, Active)
 update @temptable 
     set uiID = CHK.id
 from 
 (select id from dbo.lst_PermUser PU
 join (select uiID, uiDomainName from @temptable where uiID=0 and resID=0) T on T.uiDomainName = PU.DomainName) CHK
-- А ЭТО уже защита существующих записей от групповых изменений
 declare @cnt int = 0
 select @cnt=COUNT(*) from @temptable
 if (@cnt>1) and (IsNull(@group_update,0)=0) -- если групповая операция и ЗАПРЕЩЕНЫ групповые изменения 
   update @temptable 
      set resID = CHK.id -- помечаем записи как "ужо изменены, однако!"
    from (select id from dbo.lst_PermUser PU
          join (select uiID, uiDomainName from @temptable where uiID=0 and resID=0) T on T.uiDomainName = PU.DomainName) CHK
-- insert --------------------------------------------------------------
insert into dbo.lst_PermUser(DomainName, NormalName, MO2_UserID, Active)
output inserted.ID, inserted.DomainName into @restable
select uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID=0 and resID=0
update @temptable
 set resID = Res.ID
 from (select ID, DomainName from @restable) RES 
where uiDomainName = Res.DomainName
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate],[User],[WorkStation]) select 3, ID, 0/*insert*/,getdate(), @user, @workstation from @restable
delete @restable
-- debug -- select * from dbo.lst_PermUser
-- update --------------------------------------------------------------
select uiID,uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID>0 and resID=0
update dbo.lst_PermUser
 set DomainName = SRC.uiDomainName
    ,NormalName = SRC.uiNormalName
	,mo2_userId = SRC.uiMO2_UserID
	,Active = SRC.uiActive
output deleted.ID into @restable(ID)
from (select uiID,uiDomainName, uiNormalName, uiMO2_UserID, uiActive from @temptable where uiID>0 and resID=0) SRC
where ID = SRC.uiID
select * from dbo.lst_PermUser
update @temptable
 set resID = Res.ID
 from (select ID from @restable) RES 
where uiID = Res.ID
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate],[User],[WorkStation]) select 3, ID, 1/*update*/,getdate(), @user, @workstation from @restable
delete @restable
-- debug --select * from dbo.lst_PermUser
-- delete --------------------------------------------------------------
delete from dbo.lst_PermLink 
  where ID_PermUser in (select abs(uiID) from @temptable where uiID<0 and resID=0)
delete from dbo.lst_PermUser
  output deleted.ID into @restable(ID)
  where ID in (select abs(uiID) from @temptable where uiID<0 and resID=0)
update @temptable
 set resID = Res.ID
 from (select ID from @restable) RES 
where abs(uiID) = Res.ID
/*log*/insert @logtable(Entity, RecordID,[Event], [EventDate] ,[User],[WorkStation]) select 3, ID, 2/*delete*/,getdate(), @user, @workstation from @restable
delete @restable
-- debug -- select * from dbo.lst_PermUser
insert into dbo.lst_PermLog
select [Entity], [RecordID], [Event], [EventDate], [User], [WorkStation] from @logtable 
select @Res = count(*) from @temptable where resID<>0
COMMIT TRAN
------------------------------------------
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
print('  Процедура [dbo].[lst_UserItem_Save] (Сохранение описания пользователя) создана.') 
GO

