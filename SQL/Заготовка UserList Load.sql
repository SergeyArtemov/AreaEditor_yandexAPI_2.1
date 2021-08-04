



exec [dbo].[lst_Permissions_Load]

 declare @xml xml
 
-->-- это наборы данных (XML) в одном Recordset-e с указанием типа данных --<--
 declare @res table (dtType int, dataset xml)
  -->--  TaskList --<--

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
 insert @res values(1,@xml)


 set @xml = 
  (select 
     I.[ID]			"piID"
    ,I.[Task_CODE]	"piTASKCODE"
	,I.[CODE]		"piCODE"
	,I.[Name]		"piNAME"
	,I.[Active]		"piACTIVE"
 from dbo.lst_PermItem(nolock) I for xml auto ,elements)
 insert @res values(2,@xml)

 set @xml = 
  (select 
     U.[ID]			"uiID"
	,U.[DomainName]	"uiDOMAINNAME"
	,U.[NormalName] "uiNORMALNAME"
	,U.[mo2_userId]	"uiMO2_USERID"
	,U.[Active]		"uiATIVE"
 from dbo.lst_PermUser(nolock) U for xml auto ,elements)
 insert @res values(3,@xml)

  set @xml = 
  (select 
     L.[ID]			"liID"
    ,L.[ID_PermUser]"liPERMUSER"
	,L.[ID_PermItem]"liPERMITEM"
  from dbo.lst_PermLink(nolock) L for xml auto ,elements)
 insert @res values(4,@xml)
 
 --select * from @res

-->-- это получение данных из XML для TaskList-a --<-- 
--set @xml = '<T><tiID>1</tiID><tiCODE>1</tiCODE><tiNAME>ДТП</tiNAME><tiAPPNAME /><tiVERSION>0</tiVERSION><tiACTIVE>255</tiACTIVE><tiTYPE>0</tiTYPE></T><T><tiID>2</tiID><tiCODE>2</tiCODE><tiNAME>AreaEditor</tiNAME><tiAPPNAME>AreaEditor.exe</tiAPPNAME><tiVERSION>1.0</tiVERSION><tiACTIVE>255</tiACTIVE><tiTYPE>1</tiTYPE></T>'
select @xml=dataset from @res where dtType=1
select 
   t.r.value('tiID[1]'		, 'int')			[tiID]
  ,t.r.value('tiCODE[1]'	, 'int')			[tiCode]
  ,t.r.value('tiNAME[1]'	, 'varchar(128)')	[tiName]
  ,t.r.value('tiAPPNAME[1]'	, 'varchar(260)')	[tiAppName]
  ,t.r.value('tiVERSION[1]'	, 'varchar(20)')	[tiVersion]
  ,t.r.value('tiACTIVE[1]'	, 'tinyint')		[tiActive]
  ,t.r.value('tiTYPE[1]'	, 'tinyint')		[tiType]
from 
 @xml.nodes('/T') as t(r)


--set @xml = '<I><piID>1</piID><piTASKCODE>2</piTASKCODE><piCODE>0</piCODE><piNAME>Запуск задачи</piNAME><piACTIVE>255</piACTIVE></I><I><piID>2</piID><piTASKCODE>2</piTASKCODE><piCODE>1</piCODE><piNAME>Просмотр областей</piNAME><piACTIVE>255</piACTIVE></I><I><piID>3</piID><piTASKCODE>2</piTASKCODE><piCODE>2</piCODE><piNAME>Редактирование областей</piNAME><piACTIVE>255</piACTIVE></I><I><piID>4</piID><piTASKCODE>2</piTASKCODE><piCODE>3</piCODE><piNAME>Просмотр точек доставки</piNAME><piACTIVE>255</piACTIVE></I><I><piID>5</piID><piTASKCODE>2</piTASKCODE><piCODE>4</piCODE><piNAME>Подготовка маршрута доставки</piNAME><piACTIVE>255</piACTIVE></I>'
select @xml=dataset from @res where dtType=2
select 
   t.r.value('piID[1]'		, 'int')			[piID]
  ,t.r.value('piTASKCODE[1]', 'int')			[piTaskCode]
  ,t.r.value('piCODE[1]'	, 'int')			[piCode]
  ,t.r.value('piNAME[1]'	, 'varchar(128)')	[piName]
  ,t.r.value('piACTIVE[1]'	, 'tinyint')		[piActive]
from 
 @xml.nodes('/I') as t(r)


--set @xml = '<U><uiID>1</uiID><uiDOMAINNAME>s.kholin</uiDOMAINNAME><uiNORMALNAME>s.kholin</uiNORMALNAME><uiMO2_USERID>125</uiMO2_USERID><uiATIVE>255</uiATIVE></U>'
select @xml=dataset from @res where dtType=3
select 
   t.r.value('uiID[1]'		, 'int')				[uiID]
  ,t.r.value('uiDOMAINNAME[1]'	, 'varchar(128)')	[uiDomainName]
  ,t.r.value('uiNORMALNAME[1]'	, 'varchar(128)')	[uiNormalName]
  ,t.r.value('uiMO2_USERID[1]', 'int')				[uiMO2_UserId]
  ,t.r.value('piACTIVE[1]'	, 'tinyint')			[uiActive]
from 
 @xml.nodes('/U') as t(r)


--set @xml = '<L><liID>1</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L><L><liID>2</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>2</liPERMITEM></L><L><liID>3</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>3</liPERMITEM></L><L><liID>4</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>4</liPERMITEM></L><L><liID>5</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>5</liPERMITEM></L><L><liID>6</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L><L><liID>7</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L><L><liID>8</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L><L><liID>9</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L><L><liID>10</liID><liPERMUSER>1</liPERMUSER><liPERMITEM>1</liPERMITEM></L>'
select @xml=dataset from @res where dtType=4
select 
   t.r.value('liID[1]'		, 'int')				[liID]
  ,t.r.value('liPERMUSER[1]', 'int')				[liPermUser]
  ,t.r.value('liPERMITEM[1]', 'int')				[liPermItem]
from 
 @xml.nodes('/L') as t(r)


 -->-- это разрешения по задачам --<--
/*
select 
  T.ID			"TaskID"
 ,T.Task_Code	"TaskCode"
 ,T.Task_Name	"TaskName"
 ,[PI].ID		"piID"
 ,[PI].CODE		"piCode"
 ,[PI].Name		"piName"
 ,[PI].Active	"piActive"
from dbo.lst_Task(nolock) T
left outer join dbo.lst_PermItem(nolock) [PI] on [PI].Task_CODE = T.Task_CODE
for xml auto
  ,elements			-- это оборачивает значение каждого поля(xxx) в пару <TAG>xxx</TAG> (иначе TAG="xxx")
  --,root('TaskPermission')	-- это создает заглавный ROOT-тэг
*/
 

 -->-- это TaskList в формате CSV --<--
 /*
 declare @csv varchar(max) = ''
 select @csv=
    case 
    when @csv is null then ''
    else @csv+'"'+CAST(T.[ID] as varchar)+'"'+';'+
              '"'+CAST(T.[Task_CODE] as varchar)+'"'+';'+
              '"'+REPLACE(T.[Task_Name],'"','""')+'"'+';'+
			  '"'+REPLACE(T.[AppName],'"','""')+'"'+';'+
			  '"'+T.[Version]+'"'+';'+
              '"'+CAST(T.[Active] as varchar)+'"'+';'+
              '"'+CAST(T.[Task_Type] as varchar)+'"'+CHAR(13)+CHAR(10)  
    end			   
  from dbo.lst_Task(nolock) T 
  select @csv
  */

  --select * from dbo.lst_Value

update mo_tmp.dbo.lst_PermItem
   set Active=0
where ID=4
