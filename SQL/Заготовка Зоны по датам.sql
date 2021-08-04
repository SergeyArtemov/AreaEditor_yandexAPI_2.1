declare @xmltext varchar(max) ='<REQUEST BEGIN="20140909" END="20140909"/>'


declare @xml xml = CAST(@xmltext as xml)
declare @Begin as datetime
declare @End as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 

declare @top varchar(10)  = '����'+CHAR(160)+'��������'

declare @DT table(show varchar(100), adate varchar(100), aint varchar(100), D datetime, B integer, E integer)


declare @t int=3
select RIGHT('00'+CAST(@t as varchar),2)

insert into @DT
select distinct
  CONVERT(varchar(20),[ATF].[Date],104)+' ('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' 
 ,CONVERT(varchar(20),[ATF].[Date],104)
 ,'('+RIGHT('00'+CAST([ATF].[StartHour] as varchar),2)+'-' +RIGHT('00'+CAST([ATF].[EndHour] as varchar),2)+')' 
 ,[ATF].[Date] 
 ,[ATF].[StartHour]
 ,[ATF].[EndHour]
from dbo.map_AreaTime_Full(nolock) [ATF]
where ([ATF].[Date]>=@Begin) and ([ATF].[Date]<=@End) 
order by 1


select 
  [����].adate [����]
 ,[����].aint [��������]
 ,[Name] [����]
from @DT [����]
join dbo.map_AreaTime_Full ATF on ATF.Date = [����].D and ATF.StartHour = [����].B and ATF.EndHour = [����].E 
join (select id,parentid,name from map_AreaList) [������������] on ID = [ATF].AreaID
group by [����].adate,[����].aint,[Name]
for xml auto
 

select 
   [����].show [��������]
  ,[Name] [����]
from @DT [����]
join dbo.map_AreaTime_Full ATF on ATF.Date = [����].D and ATF.StartHour = [����].B and ATF.EndHour = [����].E 
join (select id,parentid,name from map_AreaList) [������������] on ID = [ATF].AreaID
group by [����].show,[Name]
for xml auto
  ,elements			-- ��� ����������� �������� ������� ����(xxx) � ���� <TAG>xxx</TAG> (����� TAG="xxx")
  ,root('����_��������')	-- ��� ������� ��������� ROOT-���





