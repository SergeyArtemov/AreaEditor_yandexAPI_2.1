set datefirst 1

update dbo.map_AreaTime_Full_New
set [Len]=0
where id in (
select AT.id
--,AT.AreaId, AL.Name, AT.Start, AT.[Len], datepart(dw,start) as [DayOfWeek]
from dbo.map_AreaTime_Full_New AT
join dbo.map_AreaList(nolock) AL on AL.ParentID=412 and AT.AreaId = AL.id
where 1=1
  and start>'20160101' and [len]>0
  and datepart(dw,start) in (6,7)
)
