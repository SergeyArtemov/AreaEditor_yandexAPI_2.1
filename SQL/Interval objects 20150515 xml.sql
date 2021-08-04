declare @xmltext varchar(max) =
'<INTERVAL_LIST USER="s.kholin">
<INTERVAL ID="0" AREAID="87" START="20150525 17:00:00.000" LEN="19700101 09:00:00.000" ></INTERVAL></INTERVAL_LIST>'

declare @xml xml = cast(@xmltext as xml)
declare @out table (ID int)
declare @temp table(ID int, AreaID int, [Date] datetime, [Start] datetime,[Len] datetime, Active bit)
insert into @temp
 select 
   t.r.value('@ID','int')												as [ID]
  ,t.r.value('@AREAID','int')											as [AreaId]
  ,t.r.value('@START','datetime') as [Start]
  ,DateAdd(hh,t.r.value('@END','int')-t.r.value('@BEGIN','int'), 0)		as [Len]
  ,t.r.value('@ACTIVE','bit')											as [Active]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as t(r)

update [dbo].[map_AreaTime_Full_New] 
  set [dbo].[map_AreaTime_Full_New].[Date]	= src.[Date]
     ,[dbo].[map_AreaTime_Full_New].[Start]	= src.[Start]
     ,[dbo].[map_AreaTime_Full_New].[Len]		= src.EndHour
	 ,[dbo].[map_AreaTime_Full_New].[Priority]	= src.[Priority]
	 ,[dbo].[map_AreaTime_Full_New].[Active]	= src.[Active]
output deleted.ID into @out
from (select * from @temp where [ID]>0)src
where ([dbo].[map_AreaTime_Full_New].ID = src.ID) 

insert [dbo].[map_AreaTime_Full_New] ([AreaID], [Date], [Start], [Len], [Active]) 
output deleted.ID into @out
select [AreaID], [Date], [Start], [Len], [Active] from @temp where [ID]=0

select @Res = count(*) from @out 
if (select count(*) from @temp)<>@Res set @Res=0