
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[nav_ListOfDrivers]') AND type in (N'V'))	
  DROP VIEW  [dbo].[nav_ListOfDrivers]
GO  	

CREATE VIEW [dbo].[nav_ListOfDrivers]
AS
select 
   DR.FIO 
  ,DAL.DeliveryAgent
from dbo.rt_Drivers(nolock) DR 
join [dbo].[rt_DeliveryAgentLink](nolock) DAL on DAL.rtEntity=2 and DAL.rtEntityID = DR.ID
where Active=1
GO
