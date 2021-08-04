declare @xmltext varchar(max) = 
'<?xml version="1.0" encoding="windows-1251"?>
<SCHEME>
<HEAD NAME="Новая схема" DATE="20150805 10:01"/>
<INTERVALS DAYS="3">
<I S="20150805 03:00:00" F="20150805 12:00:00" A="20150805 00:00:00" OS="180" OF="720"/>
<I S="20150805 14:00:00" F="20150805 20:00:00" A="20150805 00:00:00" OS="840" OF="1200"/>
<I S="20150806 01:00:00" F="20150806 13:00:00" A="20150805 00:00:00" OS="1500" OF="2220"/>
<I S="20150807 01:00:00" F="20150807 21:00:00" A="20150805 00:00:00" OS="2940" OF="4140"/>
</INTERVALS>
</SCHEME>'

declare @xml xml = CAST(@xmltext as xml)



select 
   t.r.value('@NAME', 'varchar(250)') "Name"
 , t.r.value('@DATE', 'datetime') "Date"
from @xml.nodes('SCHEME/HEAD') as t(r)

select
  t.r.value('@DAYS', 'int') "Days"
from @xml.nodes('SCHEME/INTERVALS') as t(r)


select 
   t.r.value('@OS', 'int') "Offset Start (minutes)"
  ,t.r.value('@OF', 'int') "Offset Finish (minutes)"
  ,DATEADD(mi,t.r.value('@OS', 'int'),0) "Start"
  ,DATEADD(mi,t.r.value('@OF', 'int') - t.r.value('@OS', 'int'),0) "Len"
from @xml.nodes('SCHEME/INTERVALS/I') as t(r)