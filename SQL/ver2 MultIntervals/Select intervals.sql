declare @xmltext varchar(max) = 
'<INTERVALS>
<I S="20150506 06:30:00" F="20150506 09:00:00" A="20150506 00:00:00" OS="390" OF="540"/>
<I S="20150507 08:00:00" F="20150507 10:30:00" A="20150506 00:00:00" OS="1920" OF="2070"/>
<I S="20150507 12:00:00" F="20150507 20:30:00" A="20150506 00:00:00" OS="2160" OF="2670"/>
</INTERVALS>'


declare @xml xml = cast(@xmltext as xml)
select @xml

select 
   t.r.value('@S', 'datetime') as Start
  ,t.r.value('@F', 'datetime') as Finish
  ,DATEADD(mi,t.r.value('@OS', 'int'),t.r.value('@A', 'datetime'))
  ,DATEADD(mi,t.r.value('@OF', 'int'),t.r.value('@A', 'datetime'))
  --,DATEADD(mi,t.r.value('@OS', 'int'),-2)
  --,DATEADD(mi,t.r.value('@OF', 'int'),-2)
  --,CAST(0 as datetime)
from @xml.nodes('INTERVALS/I') as t(r)