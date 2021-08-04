declare @dat1 datetime='20141013',
@dat2 datetime=getdate()

select 
--convert(datetime, round(convert(float, OrderStates.[Date]), 0, 1))"Date",
convert(date, OrderStates.[Date])"Date",
[dbo].[cc_Author_GetName](OrderStates.[Author], OrderStates.[User])"Author",
OrderStates.[OrderNo],
refOrderType.[FullName] "OrderType",
refOrderState.[Description2]+'. '+refOrderState.[Description] "OrderState",
refOrderState.[AdditionalCode] "StateAdditionalCode",
OrderHead.[OrderAmount] "CurrentOrderAmount",
--(SELECT [RouteName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(datetime, round(convert(float, OrderStates.[Date]), 0, 1)) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"RouteName",
--(SELECT [Driver] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(datetime, round(convert(float, OrderStates.[Date]), 0, 1)) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"Driver",
--(SELECT [CarName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(datetime, round(convert(float, OrderStates.[Date]), 0, 1)) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"CarName",
--(SELECT [CarNum] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(datetime, round(convert(float, OrderStates.[Date]), 0, 1)) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"CarNum"
(SELECT [RouteName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"RouteName",
(SELECT [Driver] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"Driver",
(SELECT [CarName] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"CarName",
(SELECT [CarNum] FROM [dbo].[RouteDataFromNav](nolock) where [RouteDate]=convert(date, OrderStates.[Date]) and [OrderNo]=OrderStates.[OrderNo] and [Host]=OrderStates.Host)"CarNum"
from
(
SELECT [id]
      ,[Description]
      ,[Code]
      ,[AdditionalCode]
	  ,[Description2]
  FROM [dbo].[cc_Ref_OrderStates](nolock)
  where [Code]='05'
  and [AdditionalCode]<>''
)refOrderState
inner join
(
SELECT [OrderNo]
      ,[Host]
      ,[StateId]
      ,[Author]
      ,[User]
      ,[Date]
  FROM [dbo].[cc_Order_State](nolock)
  where [Date]>=@dat1
  and [Date]<@dat2
)OrderStates
on refOrderState.id=OrderStates.[StateId]
left join
(
SELECT [OrderNO]
      ,[Host]
      ,[OrderType]
	  ,[OrderAmount]
  FROM [dbo].[cc_OrderHead](nolock)
)OrderHead
on OrderStates.[OrderNo]=OrderHead.[OrderNO] and OrderStates.[Host]=OrderHead.[Host]
left join
(
SELECT [id]
      ,[FullName]
  FROM [dbo].[cc_Ref_OrderTypes](nolock)
)refOrderType
on OrderHead.[OrderType]=refOrderType.[id]
order by 1, 4, 5, 2