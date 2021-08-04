declare @xmltext varchar(max) = 
'<INTERVAL_LIST USER="s.kholin">
<INTERVAL ID="0" AREAID="89" DATE="20140906" BEGIN="12" END="20" PRIORITY="0" ACTIVITY="1"></INTERVAL>
<INTERVAL ID="0" AREAID="77" DATE="20140906" BEGIN="12" END="20" PRIORITY="0" ACTIVITY="1"></INTERVAL>
<INTERVAL ID="0" AREAID="89" DATE="20150906" BEGIN="12" END="20" PRIORITY="0" ACTIVITY="1"></INTERVAL>
</INTERVAL_LIST>'

declare @xml xml = CAST(@xmltext as xml)
declare @temp table(ID int, AreaID int, [Date] datetime,StartHour tinyint, EndHour tinyint, [Priority] int, Activity bit, [exists] bit)
declare @out table (AreaID int, [Date] datetime, Oper tinyint)
set nocount on

insert into @temp
  select 
   tab.rws.value('@ID[1]'		,'int')		as [ID]
  ,tab.rws.value('@AREAID[1]'	,'int')		as [AreaID]
  ,tab.rws.value('@DATE[1]'		,'datetime')as [Date]
  ,tab.rws.value('@BEGIN[1]'	,'tinyint') as [StartHour]
  ,tab.rws.value('@END[1]'		,'tinyint') as [EndHour]
  ,tab.rws.value('@PRIORITY[1]'	,'int')		as [Priority]
  ,tab.rws.value('@ACTIVITY[1]'	,'bit')		as [Activity]
  ,isNull((select 1 from [dbo].[map_AreaTime_Full](nolock) where AreaID = tab.rws.value('@AREAID[1]','int')	and [Date] =tab.rws.value('@DATE[1]','datetime') ),0) as [Exists]
from @xml.nodes('/INTERVAL_LIST/INTERVAL') as tab(rws)
-- UPADTE
set nocount off
begin tran
update [dbo].[map_AreaTime_Full] 
  set [dbo].[map_AreaTime_Full].StartHour	= src.StartHour
     ,[dbo].[map_AreaTime_Full].EndHour		= src.EndHour
	 ,[dbo].[map_AreaTime_Full].[Priority]	= src.[Priority]
output deleted.AreaID, deleted.[Date], 1 into @out
from (select * from @temp where [exists]=1)src
where ([dbo].[map_AreaTime_Full].AreaID = src.AreaID) and ([dbo].[map_AreaTime_Full].[Date] = src.[Date])
-- INSERT
insert into [dbo].[map_AreaTime_Full] 
output inserted.AreaID, inserted.[Date], 2  into @out
select AreaID, [Date], StartHour, EndHour, [Priority] from @temp where [exists]=0
/*DEBUG or CATCH*/rollback tran
-- prepare return of result
declare @res int 
select @res = count(*) from @out 
if (select count(*) from @temp)<>@res set @res=0
select @res

select * from @out
--select * from [dbo].[map_AreaTime_Full] where AreaID=89