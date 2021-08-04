declare @AreaId int = 504
--select * from dbo.map_AreaList(nolock) where id=504


select 
 AreaId
,Start
,[Len]
,Count(*) as [Count of Doubles]
--,MAX(id)
from dbo.map_AreaTime_Full_New(nolock)
where Start>'20000101' and AreaId=@AreaId
group by AreaId, Start, [Len]
having count(*)>1
order by AreaId, Start desc


declare @begin	datetime2(0) = '20170101'
declare @end	datetime2(0) = '20170331'
select * from dbo.map_AreaTime_Full_New(nolock)
where AreaId=@AreaId 
 and CAST(Start as datetime2) between @begin and @end 
order by AreaId, Start desc

declare @xml xml = '<INTERVAL_LIST AREAID="'+CAST(@AreaId as varchar)+'" MINDATE="20170101" MAXDATE="20170331"/>'
declare @delAreaID	int
declare @delMinDate datetime
declare @delMaxDate datetime
select 
   @delAreaID  = t.r.value('@AREAID','int')   
  ,@delMinDate = t.r.value('@MINDATE','datetime2(0)')
  ,@delMaxDate = t.r.value('@MAXDATE','datetime2(0)')
from @xml.nodes('/INTERVAL_LIST') as t(r)
select * from dbo.map_AreaTime_Full_New(nolock)
where (AreaId=@delAreaID) 
 -- and ((Start>=@delMinDate) and (Start<DATEADD(DAY,1,@delMaxDate)))
  and CAST(Start as datetime2) between @delMinDate and @delMaxDate 
order by AreaId, Start desc
