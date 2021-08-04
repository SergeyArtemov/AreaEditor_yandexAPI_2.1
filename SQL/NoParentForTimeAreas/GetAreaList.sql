
select * from dbo.map_PointList(nolock)
where Area_ID in (340,458)

select 
  Area.[ID]
 ,Area.[Level]
 ,Area.[Name] 
 ,IsNull(Points.PointsCount,0) as PointsCount
 --,Area.*
from dbo.map_AreaList Area(nolock)
left join (select Area_ID,COUNT(*) PointsCount from dbo.map_PointList(nolock) group by Area_ID) Points on Points.Area_ID = Area.ID 
where IsNull(Points.PointsCount,0)<=2
order by Points.PointsCount,Area.[Level],Area.[ID],Area.[Name] 



declare @Res int
declare @ResTable table(XMLBody xml, CreateDate datetime)
declare @IDs table([ID] int,[Level] int,[Name] varchar(500),[PointsCount] int)
declare @ParamXML varchar(max)
set @ParamXML= '<MODE>ID</MODE>'
insert  @IDs exec dbo.map_GetAreas
select @Res=count(*) from @IDs
select @ParamXML = @ParamXML + case when IsNull(ID,0)<>0 then '<V>'+CAST(ID as varchar(10))+'</V>' else '' end from @IDs order by ID     
insert @ResTable exec dbo.map_LoadAreasFromDB @ParamXML

declare @xml xml
select @xml=XMLBody from @ResTable

select @xml


select
 t.r.value('ID[1]'		,'int')
,t.r.value('LEVEL[1]'	,'int')
,t.r.value('PARENTID[1]','int')
,t.r.value('NAME[1]'	,'varchar(256)')
from @xml.nodes('AREASET/AREA') as t(r)
 where t.r.value('ID[1]','int') in (458, 340)


 select * from @IDs where ID in (458, 340)

