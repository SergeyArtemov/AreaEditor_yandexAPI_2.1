USE [MO]
GO
/****** Object:  StoredProcedure [dbo].[map_SaveOneArea]    Script Date: 13.12.2016 15:44:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[map_SaveOneArea](@xmltext nvarchar(max))
AS
BEGIN
declare @Res int = 0
declare @ErrorString varchar(500)
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
declare @crlf	varchar(2)	= CHAR(13)+CHAR(10)
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
declare @id int
select
    @user = IsNull(tab.rws.value('@USER[1]','varchar(100)'),'def.'+user)
   ,@id   = Abs(IsNull(tab.rws.value('(ID)[1]','int'),0))
from @xml.nodes('/AREA') as tab(rws)

--
declare @prevArea varchar(max) 
declare @prevPoints varchar(max)
if @id<>0
   begin
   set @prevArea = 
   (select  
   ' <RECORDSTATE>0</RECORDSTATE>'+@crlf+
   ' <ID>'+CAST(AL.ID as varchar)+'</ID>'+@crlf+
   ' <PARENTID>'+CAST(AL.ParentID as varchar)+'</PARENTID>'+@crlf+
   ' <NAME>'+AL.Name+'</NAME>'+@crlf+
   ' <LEVEL>'+CAST(AL.[Level] as varchar)+'</LEVEL>'+@crlf+
   ' <RGBLINE>'+AL.RGBLine+'</RGBLINE>'+@crlf+
   ' <RGBFILL>'+AL.RGBFill+'</RGBFILL>'+@crlf+
   ' <ROUTENUM>'+CAST(AL.RouteNum as varchar)+'</ROUTENUM>'+@crlf+
   ' <DAYS>'+AL.[Days]+'</DAYS>'+@crlf+
   ' <PREVCHANGEDATE>'+CONVERT(varchar(20),AL.ChangeDate,112)+' '+CONVERT(varchar(20),AL.ChangeDate,114)+'</PREVCHANGEDATE>'+@crlf
   from dbo.map_AreaList(nolock) AL where AL.ID=30)
   set @prevPoints=CAST((
   select 
     Latitude as [LAT] 
    ,Longitude as [LNG] 
   from dbo.map_PointList(nolock) as LATLNG
   where Area_ID=30
   order by NumInSeq
   for XML AUTO, ELEMENTS) as varchar(max))
   set @prevArea = @crlf+'<AREA_PREV>'+@prevArea+@prevPoints+@crlf+'</AREA_PREV>' 
   end
   else set @prevArea =''
--

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
      ([AreaId],[DateEdit],[xml],WorkStation,[User],[ipdata])
select @arID   , GetDate(), @xmltext + @prevArea ,HOST_NAME(),IsNull(@user,'def.'+user),[client_net_address]+':'+cast([client_tcp_port] as varchar)
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