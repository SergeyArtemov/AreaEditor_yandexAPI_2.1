
set nocount on 
declare @resTable table(
     [ID]					[int]			IDENTITY(1,1) NOT NULL
    ,[acDate]				[datetime]		NOT NULL	-- дата события
    ,[acPlace]				[varchar](256)	NOT NULL	-- место события
    ,[acCar]				[varchar](10)	NOT NULL	-- номер автомобиля по Navision (выбирается по дате)
    ,[acDriver]				[varchar](128)	NOT NULL	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
    ,[acType]				[int]			NOT NULL	-- тип (словарь, HardCode (20141015))
    ,[acNote]				[varchar](256)	NOT NULL	-- описание (если тип "Другое" или уточнение)
    ,[clType]				[int]			NOT NULL	-- тип (словарь, HardCode (20141015))
    ,[clFIO]				[varchar](256)	NOT NULL	-- ФИО звонившего
    ,[clPhone]				[varchar](32)	NOT NULL	-- телефон звонившего
    ,[resNote]				[varchar](256)		NULL	-- заключение по случаю (описание)
	,[resGuilty]			[bit]				NULL	-- заключение по случаю (признак виновности)
	)
declare @counter int = cast(cast('0x'+substring(cast(newid() as varchar(36)),1,4) as  BINARY(4)) as int) - 813180000
declare @reccount int
declare @date datetime	
declare @guid varchar(36)	
declare @Place varchar(128)	
 declare @pl int																				
declare @Car varchar(10)
declare @Driver varchar(128)
declare @acType int = 0 
declare @acNote varchar(256)
declare @clType int = 0 
declare @clFIO varchar(256)
declare @clPhone varchar(256)
declare @resNote varchar(256)
if (exists (select top 1 * from dbo.ae_AccidentList(nolock)))
   set @counter=0
while @counter>0 
 begin
 set @date=dbo.fn_RandomDate('20130701', cast(dateadd(dd,-1,getdate()) as date))
 select @reccount=count(*)from [dbo].[RouteDataFromNav](nolock) where RouteDate=@date
 while @reccount=0
   begin
   set @date=dbo.fn_RandomDate('20130701', cast(dateadd(dd,-1,getdate()) as date))
   select @reccount=count(*)from [dbo].[RouteDataFromNav](nolock) where RouteDate=@date
   end 

 select top 1 @guid = newid() , @Place = IsNull(Addr,'г.Москва') , @Car = [CarNum], @Driver=[Driver], @clFIO=Str1, @clPhone=Str3 from  [dbo].[RouteDataFromNav](nolock) where RouteDate=@date order by 1

 begin try -->--
 set @pl=Patindex('%, д.%',@Place)-1
 if IsNull(@pl,0)>=0 set @Place = IsNull(Substring(@Place,1,@pl),'г.Москва')
 end try -->--
 begin catch --<--
 print(@Place+ ' : '+ cast(@pl as varchar))
 end catch --<--
 
 begin try
 select @acType = cast(val as int)/ datepart(ms,getdate()) from dbo.vfn_RandomDate
 while not (@acType between 1 and 11)
   begin
   set @acType = @acType / 3
   end
end try -->--
begin catch --<--
set @acType = 0
end catch --<--
set @acNote=''
if @acType=11
   set @acNote='Инцидент от "'+Convert(varchar(20),@date,104)+'"  в районе "'+@Place+'"'

begin try -->--
 select @clType = cast(val as int)/ datepart(ms,getdate()) from dbo.vfn_RandomDate
 while not (@clType between 1 and 4)
   begin
   set @clType = @clType / 3
   end
end try -->--
begin catch --<--
set @clType = 0
end catch --<--

 begin try -->--
 set @clPhone = IsNull(Substring(@clPhone,18,18),'Никто')
 end try -->--
 begin catch --<--
 print(@clPhone)
 end catch --<--

 begin try -->--
 insert @resTable(acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote, resGuilty) 
          values (@date , @Place , @Car ,  @Driver, @acType, @acNote,@clType,@clFIO,@clPhone,@resNote, 0)
 end try -->--
 begin catch --<--
 print('Date: '+@date+', Place: '+@Place+', Car: '+@Car+', Driver: '+@Driver+', acType: '+@acType+', acNote: '+@acNote+', clType: '+@clType+', clFio: '+@clFIO+', clPhone: '+@clPhone+', resNote: '+@resNote)
 end catch --<--


		 


 set @counter = @counter-1
 end

if not exists (select top 1 * from dbo.ae_AccidentList(nolock))
   insert dbo.ae_AccidentList(acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote, resGuilty) 
   select acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote, resGuilty from @resTable order by 1

select id,acDate, acPlace, acCar, acDriver, acType ,  acNote, clType, clFIO, clPhone, resNote from ae_AccidentList order by 1

 --select top 100 Addr,*  from  [dbo].[RouteDataFromNav](nolock)  2014-01-06 00:00:00.000
 -- select Convert(varchar(20),getdate(),104)
 
 
