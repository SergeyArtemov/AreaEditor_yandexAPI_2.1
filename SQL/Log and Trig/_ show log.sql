select 
 ATCL.ID
,ATCL.AreaId
,AL.Name
,ATCL.DateEdit
,ATCL.[xml]
,CAST(ATCL.[xml] as xml) as [ready xml]
,ATCL.WorkStation
,ATCL.[User]
,ATCL.ipdata
,ATCL.SPID
from [dbo].[map_AreaTime_ChangeLog](nolock) ATCL
left join dbo.map_AreaList(nolock) AL on AL.ID = ATCL.AreaId
--join (select id,CAST(ATCL.[xml] as xml) as [xml] from [dbo].[map_AreaTime_ChangeLog](nolock) where AreaId<>2147483647) src on 

--where AreaId<>2147483647
order by ATCL.DateEdit desc

