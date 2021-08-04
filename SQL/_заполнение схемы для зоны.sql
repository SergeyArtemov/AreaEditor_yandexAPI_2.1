set nocount on
set datefirst 1

declare @temp table(ID int, AreaID int,[Start] datetime, [Len] datetime)
declare @usedDW table(DWnum tinyint, Start tinyint, [Len] tinyint ) -- параметры интервалов по дням
insert @usedDW values
 (1,  8,  4),
 (1,  14, 5),
 (3,  9, 12),
 (5, 10,  8)


declare @AreaId		int			= 526
declare @startDate	datetime	= '20170101'
declare @finishDate datetime	= '20171231'
declare @stepDays	tinyint		= 1
declare @beginHour	tinyint		= 8
declare @hoursLen	tinyint		= 10

if exists(select * from @usedDW)
   begin -- работаем по дням недели
   while @startDate<=@finishDate
     begin
	 insert into @temp
	 select 
	   0
	  ,@AreaId
	  ,DATEADD(HOUR,[Start],@startDate)
	  ,DATEADD(HOUR,[Len],0)
     from @usedDW dw
     where DATEPART(DW,@startDate) = DWnum
	 order by [Start]
     set @startDate = DATEADD(DAY,1,@startDate)
     end
   end
   else begin -- работаем по числам и кол-во дней между числами
   while @startDate<=@finishDate
     begin
     insert into @temp values (0, @AreaId, DATEADD(HOUR,@beginHour,@startDate), DATEADD(HOUR,@hoursLen,0))
     set @startDate = DATEADD(DAY,@stepDays,@startDate)
     end
   end
/*
select 
 AreaID							as [AreaID]
,CAST(Start as date)			as [Date]
,CAST(Start as time(0))			as [Begin]
,CAST(Start+[Len] as time(0))	as [End]
from @temp
*/

declare @prevValues	xml 
set @prevValues = (
select ATF.* 
from dbo.map_AreaTime_Full_New(nolock) ATF
right join @temp T on T.AreaID = ATF.AreaId and CAST(T.Start as date) = CAST(ATF.Start as date)
where ATF.AreaId is not null
order by T.AreaID, T.Start
for XML AUTO, ROOT('DATA')
) 

select @prevValues as [True xml],IsNULL(CAST(@prevValues as varchar(max)),'') as [xml in varchar]