
select top 1 * from dbo.map_AreaList_log where AreaID=30 order by DateEdit desc

declare @crlf varchar(2)= CHAR(13)+CHAR(10)
declare @prevArea varchar(max) 
declare @prevPoints varchar(max)
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
set @prevArea = '<AREA_PREV>'+@prevArea+@prevPoints+@crlf+'</AREA_PREV>'
select @prevArea


declare @xml xml = CAST(@prevArea as xml)
select @xml



