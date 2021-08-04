declare @xmltext varchar(max) ='<REQUEST BEGIN="20140912" END="20140909"/>'



declare @xml xml = CAST(@xmltext as xml)
declare @Begin as datetime
declare @End as datetime
/*2*/declare @mid as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  --set @Begin=@Begin+@End
  --set @End=@Begin-@End
  --set @Begin=@Begin-@End
  /*2*/set @mid=@Begin
  /*2*/set @Begin=@End
  /*2*/set @End=@mid
  end;

select 
   CONVERT(varchar(20),[ATF].[Date],104)+' ('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' [Дата (Интервал)]
  ,[AL].[Name] [Зона]
  ,[ALP].[Name] [Владелец]
from dbo.map_AreaTime_Full(nolock) ATF
join (select id,parentid,name from map_AreaList(nolock)) [AL] on [AL].ID = [ATF].AreaID
left outer join (select id,name from map_AreaList(nolock)) [ALP] on [ALP].ID = [AL].parentid
where ([ATF].[Date]>=@Begin) and ([ATF].[Date]<=@End)
group by CONVERT(varchar(20),[ATF].[Date],104)+' ('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' ,[AL].[Name],[ALP].[Name]
order by 1,2,3

