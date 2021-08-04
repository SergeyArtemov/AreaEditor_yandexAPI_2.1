set nocount on

-- int & bigint --

declare @min int = -1000
declare @max int = 45321
--declare @counter int = cast(cast('0x'+substring(cast(newid() as varchar(36)),1,4) as  VARBINARY) as int) 
declare @counter int = abs(CHECKSUM(NEWID()))
while not (@counter between @min and @max)
  set @counter = @counter/3 
declare @counter2 bigint = cast(Substring(cast(cast(rand() as numeric(30,18)) as varchar(40)),3,18) as bigint)
while not (@counter2 between @min and @max)
  set @counter2 = @counter2/3 
select @min, @counter,dbo.fn_randomint(@min, @max), @counter2, @max 

-- datetime --

declare @xmltext varchar(1024) = '<REQUEST DATE="'+convert(varchar(20),dbo.fn_RandomDate('20130701',cast(dateadd(dd,-1,getdate()) as date)),112)+'" />'
declare @xml xml = cast(@xmltext as xml)
select @xml
SELECT distinct 
 [CarNum]
,[Driver] 
FROM [dbo].[RouteDataFromNav](nolock) RDN 
join (select t.r.value('@DATE','datetime') as D from @xml.nodes('/REQUEST') as t(r)) X on RDN.RouteDate=X.D
order by 1,2
select count(*) from  [dbo].[RouteDataFromNav](nolock) where RouteDate='20140106'