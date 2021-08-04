--declare 
--select dbo.fn_RandomDate('20140101',getdate())

 

select 
 Al.ID
,AL.[Name]
,AT.[Date]
from dbo.map_AreaList(nolock) AL
join (select AreaID, [Date] from dbo.map_AreaTime_Full(nolock) where AreaID in (274)) AT on AT.AreaID = AL.ID
order by 1,3
