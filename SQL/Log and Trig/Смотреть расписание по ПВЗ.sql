
SELECT  PIL.ID
      , PIL.[PVZ_id]
	  , SA.[Description]
      , PIL.[Start]
      , PIL.[Len]	 
FROM [MO].[dbo].[pvz_IntervalList] PIL
join dbo.cc_Ref_ShippingAgent_Service SA on SA.id = PIL.[PVZ_id]
where PIL.Start>'20170228'
 and PIL.PVZ_id>0
order by PIL.Start desc, PIL.PVZ_ID 