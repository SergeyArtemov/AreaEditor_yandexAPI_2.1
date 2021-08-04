 select  
     AL.[ID]
    ,AL.[acDate]	-- дата события
    ,AL.[acPlace]	-- место события
    ,AL.[acCar]	-- номер автомобиля по Navision (выбирается по дате)
    ,AL.[acDriver]	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,AL.[acType]	-- тип (словарь, HardCode (20141015))
    ,AL.[acNote]	-- описание (если тип "Другое" или уточнение)
    ,AL.[clType]	-- тип (словарь, HardCode (20141015))
    ,AL.[clFIO]	-- ФИО звонившего
    ,AL.[clPhone]	-- телефон звонившего
    ,AL.[resNote]	-- заключение по случаю (описание)
	,AL.[resGuilty]-- заключение по случаю (признак виновности)
	,Alog2.[DateEvent]
	,Alog2.[User]
   from dbo.ae_AccidentList(nolock) AL
   --right join (select [RecordID],[Event], max([DateEvent]), [User] from mo.dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog on Alog.RecordID = AL.ID
   left join (select [RecordID],[Event], max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event] having [Event]=0) Alog on Alog.RecordID = AL.ID
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog2 on Alog2.RecordID = ALog.RecordID and Alog2.DateEvent =  Alog.MaxDateEvent 
   where [acDate]>='20141112' and [acDate]<='20141113'

--select * from dbo.ae_AccidentList_log --order by DateEvent