declare @xmltext varchar(max) =
'<?xml version="1.0" encoding="WINDOWS-1251"?>
<SCHEME NAME="Новая схема (s.kholin, 18.08.2014 14:19)" BEGIN="20140823" END="20140829">
<INTERVAL BEGIN="9" END="21"></INTERVAL>
<INTERVAL BEGIN="9" END="21"></INTERVAL>
<INTERVAL BEGIN="9" END="21"></INTERVAL>
<INTERVAL BEGIN="9" END="21"></INTERVAL>
<INTERVAL BEGIN="9" END="21"></INTERVAL>
</SCHEME>'

declare @xml xml = CAST(@xmltext as xml)

select @xml

select t.r.value('@NAME','varchar(128)') as SchemeName
      ,t.r.value('@BEGIN','datetime') as DateBegin
	  ,t.r.value('@END','datetime') as DateEnd
from @xml.nodes('/SCHEME') as t(r) 

select t.r.value('@BEGIN','tinyint') as HourBegin
	  ,t.r.value('@END','tinyint') as HourEnd
from @xml.nodes('/SCHEME/INTERVAL') as t(r) 
