declare @test bit = 1
declare @staytable table(AreaId int, Start datetime, [Len] datetime, recCount int, maxID int) 


insert  @staytable
select 
 AreaId
,Start
,[Len]
,Count(*)
,MAX(id)
from dbo.map_AreaTime_Full_New(nolock)
where Start>'20000101'
group by AreaId, Start, [Len]
having count(*)>1
order by AreaId, Start desc
print ('---- �������� ������������ ������ � maxID (��� ��������)')

declare @update table (Oldid int)
insert @update
select ATFN.id 
from dbo.map_AreaTime_Full_New(nolock) ATFN
right join @staytable ST on ST.AreaId = ATFN.AreaId 
                       and ST.Start = ATFN.Start
					   and ST.[Len] = ATFN.[Len]
					   and ST.maxID <> ATFN.id 
order by ATFN.AreaId, ATFN.Start desc
print ('---- �������� ������������ ������, ������� ����� �������� (���������� �� 50 ��� � �������)')


begin tran

if exists(select * from @update)
  begin
  update dbo.map_AreaTime_Full_New
      set Start=DATEADD(YEAR,-50,Start)
  from @update
      where id = Oldid
  print ('---- ������ ���������� �� 50 ��� � �������')
  end
  else begin
  set nocount on
  select 'no finded doubles' as [message]
  end

if @test=1
   begin
   --select * 
   --from dbo.map_AreaTime_Full_New(nolock)
   --where Start<'20000101'
   --order by AreaId, Start desc
   --print ('---- �������� �������, ������� ���������� �� 50 ��� � �������')
   rollback tran
   end
   else 
   commit tran

----select * from dbo.map_AreaTime_Full_New(nolock) where AreaId=1 and Start='20170224 09:00:00.000' and [Len]='19000101 09:00:00.000'