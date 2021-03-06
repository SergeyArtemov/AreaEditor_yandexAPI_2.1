declare @xmltext varchar(100)  = '<XML AREAID="17"/>'
declare @xml xml=CAST(@xmltext as xml)
declare @AreaID int = 0
select @AreaID = t.r.value('@AREAID[1]','int') from @xml.nodes('/XML') as t(r)
--if ISNULL(@AreaID,0) return 0

SELECT 
       0				as [aiID]
      ,ATF.[AreaId]		as [aiArea]
      ,ATF.[Date]		as [aiDate]
      ,ATF.[StartHour]	as [aiBegin]
      ,ATF.[EndHour]	as [aiEnd]
      ,ATF.[Priority]	as [aiPriority]
      ,1				as [aiActivity]
FROM [dbo].[map_AreaTime_Full] ATF(nolock)
where ATF.[AreaId]=@ArteaID 
order by ATF.[Date] desc
-- показать можно все, а вот редактировать только с завтрашней(? послезавтрашней ?)
-- where  ATF.[Date]>=GETDATE()-1 
select * from (
SELECT 
       0				as [aiID]
      ,ATF.[AreaId]		as [aiArea]
      ,ATF.[Date]		as [aiDate]
      ,ATF.[StartHour]	as [aiBegin]
      ,ATF.[EndHour]	as [aiEnd]
      ,ATF.[Priority]	as [aiPriority]
      ,1				as [aiActivity]
      ,SUBSTRING(CAST((100+ATF.[StartHour]) as varchar),2,2)+'-'+SUBSTRING(CAST((100+ATF.[EndHour]) as varchar),2,2) as [aiInterval]
FROM [dbo].[map_AreaTime_Full] ATF(nolock)
) ATF
order by ATF.aiArea, ATF.aiDate desc, ATF.aiInterval

