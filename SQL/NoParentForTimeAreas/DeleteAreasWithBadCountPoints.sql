begin tran

declare @delTable table(ID integer)
insert @delTable
select 
  Area.[ID]
from dbo.map_AreaList Area(nolock)
left join (select Area_ID,COUNT(*) PointsCount from dbo.map_PointList(nolock) group by Area_ID) Points on Points.Area_ID = Area.ID 
where IsNull(Points.PointsCount,0)<=2

delete dbo.old_map_AreaTime where AreaId in (select ID from @delTable)  
print 'dbo.old_map_AreaTime clear'

delete dbo.map_AreaTime_Full where AreaId in (select ID from @delTable)
print 'dbo.map_AreaTime_Full clear'

delete dbo.map_AreaTime_Full_New where AreaId in (select ID from @delTable)
print 'dbo.map_AreaTime_Full_New clear'

delete dbo.map_Link_AddrIdAreaId where AreaId in (select ID from @delTable)
print 'dbo.map_Link_AddrIdAreaId clear'

delete dbo.map_AreaTime_Full_LogPriority where AreaId in (select ID from @delTable)  
print 'dbo.map_AreaTime_Full_LogPriority clear'

delete dbo.map_AreaList where id in (select ID from @delTable)
print 'dbo.map_AreaList clear'

print 'That''s all'

--rollback tran
--commit tran