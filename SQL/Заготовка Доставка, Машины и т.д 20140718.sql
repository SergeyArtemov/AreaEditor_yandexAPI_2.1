
declare @xmltext varchar(max)= '<PARAMS DATE="20140724" AGENT="1"></PARAMS>'--ae_GetFullData('<P D="20140718" A="1"></P>')
declare @xmltext_source varchar(max)
declare @xml xml = CAST(@xmltext as xml)

select @xmltext_source = XMLBody from dbo.rt_History(nolock) H
join (select t.r.value('@DATE','datetime') as DeliveryDate
            ,t.r.value('@AGENT','int') as DeliveryAgent
      from @xml.nodes('/PARAMS') as t(r)) P on H.DeliveryDate = P.DeliveryDate and H.DeliveryAgent=P.DeliveryAgent
set @xml = CAST(@xmltext_source as xml)     
select @xml

select 
   tab.rws.value('ID[1]','int') as Car_ID
  ,tab.rws.value('LICENSE_PLATE[1]','varchar(20)') as Car_Reg_Num
  ,tab.rws.value('FIO[1]','varchar(100)') as Driver_FIO
  ,tab.rws.value('AREA_ID[1]','int') as Area_ID
  ,tab.rws.value('AREANAME[1]','varchar(100)') as Area_Name
from 
 @xml.nodes('/CARSLIST/CAR') as tab(rws)
where tab.rws.value('ACTIVE[1]','bit')=1 

select
  tab.rws.value('../AREAID[1]', 'int') as [Area_ID]
 ,tab.rws.value('../CARID[1]', 'int') as [Car_ID]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(tab.rws.value('../DELIVERYFIO[1]','varchar(max)')) as [Delivery_FIO]
 ,tab.rws.value('../DELIVERYFIO[1]','varchar(200)') as [Delivery_FIO]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../CUSTOMERFIO[1]','varchar(max)')) as [Customer_FIO]
 ,tab.rws.value('../CUSTOMERFIO[1]','varchar(200)') as [Customer_FIO]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../ADDRFOUND[1]','varchar(max)')) as [Delivery_Addr]
 ,tab.rws.value('../ADDRFOUND[1]','varchar(500)') as [Delivery_Addr]
 ,tab.rws.value('../PHONE[1]','varchar(100)') as [Phone]
 ,tab.rws.value('../INTERVAL[1]','varchar(100)') as [Interval]
 /*JS*/--,dbo.fn_StringToJavaUTF8Ex(,tab.rws.value('../ABOUTFULL[1]','varchar(max)')) as [About_Full]
 ,tab.rws.value('../ABOUTFULL[1]','varchar(max)') as [About_Full]
 ,tab.rws.value('LAT[1]', 'numeric(10,7)') as [lat]  
 ,tab.rws.value('LNG[1]', 'numeric(10,7)') as [lng] 
 ,tab.rws.value('../ORDERCOUNT[1]','int') as [OrderCount]
 --,tab.rws.query('.')
from 
 @xml.nodes('/DELIVERYPOINTLIST/DELIVERYPOINT/LATLNG') as tab(rws)
where tab.rws.value('../ABOUTFULL[1]','varchar(max)') like '%)*%' 
  /*
  tab.rws.value('AREALEVEL[1]','') as []
  tab.rws.value('AREANAME[1]','') as []			-->35.РеутовЛюберцы</AREANAME>
  tab.rws.value('ORDERCOUNT[1]','') as []		-->1</ORDERCOUNT>
  tab.rws.value('ADDRFOUND[1]','') as []			-->г Москва, ул Святоозерская, д.32, корпус -</ADDRFOUND>  
  tab.rws.value('PHONE[1]','') as []-->+7 (916) 654-09-12</PHONE>
  tab.rws.value('INTERVAL[1]','') as []-->09:00-21:00</INTERVAL>
  tab.rws.value('AREAS[1]','') as []-->курьер</AREAS>
  tab.rws.value('CUSTOMER[1]','') as []-->12231751</CUSTOMER>
  tab.rws.value('CUSTOMERFIO[1]','') as []-->Эмма Никитина</CUSTOMERFIO>
  tab.rws.value('DELIVER[1]','') as []-->4335265</DELIVER>
  tab.rws.value('ABOUT[1]','') as []-->833073778;</ABOUT>
  tab.rws.value('CAMPAINNAME[1]','') as []-->Бельевой каприз</CAMPAINNAME>
  tab.rws.value('COMMENTCC[1]','') as []-- />
  tab.rws.value('ORDERTYPEFULLNAME[1]','') as []-->KupiVip</ORDERTYPEFULLNAME>
  */
  
