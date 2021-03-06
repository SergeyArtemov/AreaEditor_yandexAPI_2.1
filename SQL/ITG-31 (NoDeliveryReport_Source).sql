SET NOCOUNT ON

declare @xmltext varchar(max) = '<REQUEST BEGIN="20161122" END="20161122"/>'

declare @Res int
declare @ErrorString varchar(500)


--BEGIN TRAN
-->-----------------------------------------
declare @xml xml = CAST(@xmltext as xml)
declare @Begin as datetime
declare @End as datetime
/*2*/declare @mid as datetime
select @Begin = t.r.value('@BEGIN','datetime'),@End = t.r.value('@END','datetime')from @xml.nodes('/REQUEST') as t(r) 
if @Begin>@End
  begin
  --set @Begin=@Begin+@End
  --set @End=@Begin-@End
  --set @Begin=@Begin-@End
  /*2*/set @mid=@Begin
  /*2*/set @Begin=@End
  /*2*/set @End=@mid
  end;
--set @End= convert(date,DATEADD(dd,1,@End)) -- заглушка если используется условие <@End
-->-- 20141107 (сутки начинаются и заканчиваются в 7.00) --<--
set @Begin = convert(datetime,convert(date, @Begin))	
set @End = convert(datetime,convert(date, @End))	
set @Begin = DateAdd(hour , 7, @Begin)
set @End = DateAdd(hour , 7, DateAdd(day,1,@End))
-- ATTENTION : переключено условие <=@End на <@End
-->-- 20141107 --<-- ---------------------------------------------------------------------
select 
convert(datetime,convert(date, OrderStates.[Date]))						"Дата",
[dbo].[cc_Author_GetName](OrderStates.[Author], OrderStates.[User])		"Оператор",
convert(varchar,OrderStates.[OrderNo])+'('+refOrderType.[FullName]+')'	"№ заказа",
refOrderState.[Description2]+'. '+refOrderState.[Description]			"Состояние заказа",
refOrderState.[AdditionalCode]											"StateAdditionalCode",
OrderHead.[OrderAmount]													"Сумма заказа",
RDN.[RouteName]															"Маршрут",
RDN.[Driver]															"Водитель",
RDN.[CarNum]															"Гос. номер",
OrderStates.[Date]														"RealDate",	
CAST(IsNUll(refCustomer.FirstOrder,0) as bit)							[IsFirstOrder]

 ,OrderHead.[OrderNo]
 ,OrderHead.[Host] 
 ,OrderHead.[OrderType]
 ,OrderStates.[User]
 ,LogCall.CallType
 ,LogCall.StartCall
 ,OrderStates.StateId
 ,refOrderState.[Description]
 ,refOrderState.[Description2]
from
(
SELECT [id]
      ,[Description]
      ,[Code]
      ,[AdditionalCode]
	  ,[Description2]
  FROM [dbo].[cc_Ref_OrderStates](nolock)
  where [Code]='05' and [AdditionalCode]<>'' -- перенос 
)refOrderState -- это состояние заказов
inner join -- это описание заказов
(SELECT [OrderNo]
       ,[Host]
       ,[StateId]
       ,[Author]
       ,[User]
       ,[Date]
  FROM [dbo].[cc_Order_State](nolock)
  -->-- 20141107 -- where convert(date, [Date])>=@Begin and convert(date, [Date])<=@End
  where [Date]>=@Begin and [Date]<@End
)OrderStates on refOrderState.id=OrderStates.[StateId]
left join -- это описание маршрутов из Navision
(SELECT [RouteName]
       ,[Driver]
	   ,[CarNum]
	   ,[RouteDate]
	   ,[OrderNo]
	   ,[Host] 
	   FROM [dbo].[RouteDataFromNav](nolock)
) RDN on RDN.[RouteDate]=convert(date, OrderStates.[Date]) and RDN.[OrderNo]=OrderStates.[OrderNo] and RDN.[Host]=OrderStates.Host
left join
(SELECT [OrderNO]
       ,[Host]
       ,[OrderType]
   	   ,[OrderAmount]
  FROM [dbo].[cc_OrderHead](nolock)
) OrderHead on OrderStates.[OrderNo]=OrderHead.[OrderNO] and OrderStates.[Host]=OrderHead.[Host]
left join
(SELECT [id]
       ,[FullName]
   FROM [dbo].[cc_Ref_OrderTypes](nolock)
)refOrderType on OrderHead.[OrderType]=refOrderType.[id]
left join -- KhS 20160805
( select 
    [FirstOrder]
   ,[Host]
   from dbo.cc_Ref_Customer(nolock)
)refCustomer on refCustomer.FirstOrder = OrderStates.[OrderNo] and refCustomer.Host = OrderStates.Host
left join (
select 
 CallId
 ,op_id as ccOper
 , [User] as ccUser
 ,CallLine
 ,CallType
 ,StartCall
 ,StartTalk
 ,EndCall
from CallOCall_Log_Call(nolock) CLC
--left join cc_Ref_Outline ROL on ROL.Line = CLC.CallLine 
where 1=1
   and CallResult	= 1 -- успех
   and CallLine		= '84952258343' -- линия связи с ТП
) LogCall on CAST(LogCall.Startcall as date) = CAST(OrderStates.[Date] as date) 
             and (LogCall.ccUser = OrderStates.[User]
			 and OrderStates.[Date] between DATEADD(MINUTE,-5,LogCall.Startcall) and DATEADD(MINUTE,5,LogCall.Startcall)) 
order by 1, 4, 5, 2
--order by 1, 2, 6, RealDate
-->-----------------------------------------
