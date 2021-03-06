  
   
   
declare @table table(
/*+00*/[OrderNo]			varchar(20),		--OrderNo            : array[1..20] of char;
/*+01*/[Host]				int,					--OrderHost          : integer;
/*+02*/[fk_MapAddressList]	int,		--fk_MapAddressList  : integer;
/*+03*/[AreaId]				int,					--AreaID             : integer;
/*+04*/[AreaLevel]			int,				--AreaLevel          : integer;
/*+05*/[AreaName]			varchar(255),		--AreaName           : array[1..255] of char;
/*+06*/[ShippingDate]		datetime,				-- > -- absent 
/*+07*/[AddrFound]			varchar(512),					--AddrFound          : array[1..512] of char;
/*+08*/[Lat]				float,						--LatLng.Lat         : TFloatPoint;
/*+09*/[Lng]				float,						--LatLng.Lng         : TFloatPoint;
/*+10*/[DeliveryFIO]		varchar(255),--DeliveryFIO        : array[1..255] of char;
/*+11*/[Phone]				varchar(255),--Phone              : array[1..255] of char;
/*+12*/[ShippingTime]		varchar(16),--Interval           : array[1..16]  of char;
/*13*/[timeAreas]			varchar(255),--Areas              : array[1..255] of char;
/*+14*/[KLADR]				varchar(24),--KLADR              : array[1..24] of char;
/*+15*/[AdrStrDelim]		varchar(512),--AdrStrDelim        : array[1..512] of char; -- Needname
/*16*/[AddrStr]				varchar(512),				--AdrStr             : array[1..512] of char;
/*17*/[AdrStrNav]			varchar(2048),--AdrStrNav          : array[1..2048] of char;//array[1..2048] of char; --Needname2 !!! *UNUSED*
/*18*/[Customer]			int,--Customer           : integer;
/*19*/[OrderType]			int ,--OrderType          : integer;
/*20*/OrderTypeName			varchar(4),--OrderTypeName      : array[1..4]  of char;
/*21*/[Deliver]				int,--Deliver            : integer;
/*22*/[CustomerFIO]			varchar(255),--CustomerFIO        : array[1..255] of char;
/*+23*/[Ducrot]				bit, --Ducrot             : integer;  
/*+24*/[OrderNo_NAV]		varchar(16),--OrderNo_NAV        : array[1..16]  of char;
/*+25*/[Customer_NAV]		varchar(16),--Customer_NAV       : array[1..16]  of char;
/*+26*/diCampainName		varchar(255),--diCampainName       : array[1..255] of char;
/*+27*/diCommentCC			varchar(1024), -- diCommentCC         : array[1..1024] of char;
/*+28*/diOrderTypeFullName	varchar(32),-- diOrderTypeFullName : array[1..32] of char;
/*+29*/ItemCount			int,--ItemsCount         : integer;
/*+30*/ItemAmount			money,--ItemsAmount        : currency;
/*+31*/LineCount			int -- LinesCount         : integer;
)

insert @table
exec mo.dbo.rt_LoadDeliveriesPointByDates_dvv '20141215','20141215',1