declare @tab_txt table (body varchar(max))
declare @tab_xml table (body xml)
insert @tab_txt select  XMLBody  from mo_tmp.dbo.rt_History(nolock) where DeliveryDate>='20140901' and DeliveryDate<='20140904' and DeliveryAgent=1
insert @tab_xml select CAST(body as xml) from @tab_txt

--select body from @tab_xml

select 
    body.query('(/DELIVERYPOINTLIST/DELIVERYPOINT)')
	--.value('/ABOUTFULL[2]','varchar(max)')
	--.value('./ABOUTFULL','varchar(max)') as [About_Full]
	--.
from @tab_xml
