/*
select * from (
SELECT distinct
   t.r.value('@id','int') as [id in ATFN]
  ,t.r.value('@AreaId','int') as [AreaId]
  ,CAST(t.r.value('@Start','datetime') as date) as [IntDate]
  ,CAST(t.r.value('@Start','datetime') as time(0)) as [StartTime]
  ,CAST(t.r.value('@Start','datetime') + t.r.value('@Len','datetime') as time(0)) as [FinishTime]
  , case 
     when ATFN.id is null then abs(t.r.value('@id','int'))*-1
	  else ATFN.id
    end as [OLD id in ATFN]
  , ATFNnew.id as [NEW id in ATFN]
  ,ATCL.ID as [ChangeLog ID]
  --,ATCL.[AreaId]
  ,ATCL.[DateEdit]
  --,CAST(ATCL.[xml] as xml) as [Source]
  ,ATCL.[WorkStation]
  ,ATCL.[User]
  --,ATCL.[ipdata]	   
FROM [MO].[dbo].[map_AreaTime_ChangeLog](nolock) ATCL 
left join (select id,CAST([xml] as xml) as xmldata from [MO].[dbo].[map_AreaTime_ChangeLog]) srcxml on srcxml.id = ATCL.id
cross apply srcxml.xmldata.nodes('/ROOT/DATA/ATF') as t(r)
left join dbo.map_AreaTime_Full_New(nolock) ATFN on ATFN.id = t.r.value('@id','int')
left join dbo.map_AreaTime_Full_New(nolock) ATFNnew on ATFNnew.AreaId = t.r.value('@AreaId','int')  and CAST(ATFNnew.Start as date)= CAST(t.r.value('@Start','datetime') as date)
--order by t.r.value('@AreaId','int'), CAST(t.r.value('@Start','datetime') as date), t.r.value('@id','int') ,ATFN.id, ATFNnew.id
) res
order by [AreaId], [IntDate], [id in ATFN] ,[OLD id in ATFN], [NEW id in ATFN]
*/



--select * from dbo.map_AreaTime_Full_New(nolock) where id in (713018)

SELECT  ATCL.ID
       ,ATCL.[AreaId]
       ,ATCL.[DateEdit]
	   ,CAST(ATCL.[xml] as xml) as [Source]
       ,ATCL.[WorkStation]
       ,ATCL.[User]
       ,ATCL.[ipdata]	   
FROM [MO].[dbo].[map_AreaTime_ChangeLog](nolock) ATCL 
order by ID desc



