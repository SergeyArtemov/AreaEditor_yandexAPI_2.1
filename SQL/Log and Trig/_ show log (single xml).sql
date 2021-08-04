set datefirst 1

declare @xml xml 
select @xml = CAST([xml] as xml) from [dbo].[map_AreaTime_ChangeLog](nolock) where id=266

declare @exists table(id int, AreaId int, Start datetime, [Len] datetime) 
declare @input table(id int, AreaId int, Start datetime, [Len] datetime) 

select @xml

insert @exists
select 
   t.r.value('@id','int') as [id]
  ,t.r.value('@AreaId','int') as [AreaId]
  ,t.r.value('@Start','datetime') as [Start]
  ,t.r.value('@Len','datetime') as [Len]
from @xml.nodes('ROOT/DATA/ATF') as t(r)
insert @input
select 
   t.r.value('@ID','int') as [id]
  ,t.r.value('@AREAID','int') as [AreaId]
  ,t.r.value('@START','datetime') as [Start]
  ,t.r.value('@LEN','datetime') as [Len]
from @xml.nodes('ROOT/INPUT/INTERVAL_LIST/INTERVAL') as t(r)

/*
select 
   id
  ,AreaId 
  ,CAST(Start as date) as [StartDate]
  ,CAST(Start as time(0)) as [BeginTime]
  ,CAST(Start+[Len] as time(0)) as [EndTime]
  ,DATEPART(dw,Start) as [day of week]
from @exists
order by AreaId, Start

select 
   id
  ,AreaId 
  ,CAST(Start as date) as [StartDate]
  ,CAST(Start as time(0)) as [BeginTime]
  ,CAST(Start+[Len] as time(0)) as [EndTime]
  ,DATEPART(dw,Start) as [day of week]
from @input
order by AreaId, Start
*/

declare @delAreaID	int
declare @delMinDate datetime
declare @delMaxDate datetime
select 
   @delAreaID  = t.r.value('@AREAID','int')   
  ,@delMinDate = CAST(t.r.value('@MINDATE','datetime2(0)') as datetime)
  ,@delMaxDate = CAST(t.r.value('@MAXDATE','datetime2(0)') as datetime)
from @xml.nodes('ROOT/INPUT/INTERVAL_LIST') as t(r)

select @delAreaID,@delMinDate,@delMaxDate 
select * from [dbo].[map_AreaTime_Full_New](nolock)
where AreaId=@delAreaID 
 and Start>=@delMinDate and Start<DATEADD(DAY,1,@delMaxDate)
 --and (CAST(Start as datetime2) between @delMinDate and @delMaxDate)
order by Start desc



/*
select * from dbo.map_AreaTime_Full_New(nolock)
--where id in (390081)
where AreaId=437 and Start='20171230 10:00:00.000'
*/


