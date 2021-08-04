declare @xmltext varchar(1024) = '<REQUEST DATE="20141013" />'
declare @xml xml = cast(@xmltext as xml)


SELECT distinct 
 [CarNum]
,[Driver] 
FROM [dbo].[RouteDataFromNav](nolock) RDN 
join (select t.r.value('@DATE','datetime') as D from @xml.nodes('/REQUEST') as t(r)) X on RDN.RouteDate=X.D
order by 1,2
