 select  
     AL.[ID]
    ,AL.[acDate]	-- ���� �������
    ,AL.[acPlace]	-- ����� �������
    ,AL.[acCar]	-- ����� ���������� �� Navision (���������� �� ����)
    ,AL.[acDriver]	-- ��� �������� �� Navision (��������� �� ������������, ���������� ��� ������ ����������)
    ,AL.[acType]	-- ��� (�������, HardCode (20141015))
    ,AL.[acNote]	-- �������� (���� ��� "������" ��� ���������)
    ,AL.[clType]	-- ��� (�������, HardCode (20141015))
    ,AL.[clFIO]	-- ��� ����������
    ,AL.[clPhone]	-- ������� ����������
    ,AL.[resNote]	-- ���������� �� ������ (��������)
	,AL.[resGuilty]-- ���������� �� ������ (������� ����������)
	,Alog2.[DateEvent]
	,Alog2.[User]
   from dbo.ae_AccidentList(nolock) AL
   --right join (select [RecordID],[Event], max([DateEvent]), [User] from mo.dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog on Alog.RecordID = AL.ID
   left join (select [RecordID],[Event], max([DateEvent]) [MaxDateEvent] from dbo.ae_AccidentList_log(nolock) group by [RecordID],[Event] having [Event]=0) Alog on Alog.RecordID = AL.ID
   left join (select [RecordID],[DateEvent],[User] from dbo.ae_AccidentList_log(nolock) where [Event]=0) Alog2 on Alog2.RecordID = ALog.RecordID and Alog2.DateEvent =  Alog.MaxDateEvent 
   where [acDate]>='20141112' and [acDate]<='20141113'

--select * from dbo.ae_AccidentList_log --order by DateEvent