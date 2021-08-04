unit AreaEditor_Types;
{$WARN GARBAGE OFF}
(*DELETED AREAS*) // -- где-то надо (20140827) сделать переключатель отображения удаленных (Abs(aLevel)*-1)
(*HTML PHONES*)   // -- подготовка телефонов для прозвона (a href="tel:0000000")
interface
uses
   AppLogNew
 , FnADODB, FNCommon
 , SysUtils
 , SHDocVw, MSHTML
 , ActiveX, xmldoc, xmldom
 , ADODB, DB
 , Windows
 , types
 , variants
 , classes
 , StrUtils
 , Graphics
 , Math
 , ImgList
 , Controls
 , Forms
 ;



const
 APP_INTERVAL = $8000(*WM_APP*) + $E0;

// ILEnabled, ILDisabled = TImageList
const
 ilClose      = 0;
 ilRefresh    = 1;
 ilFilter     = 2;
 ilInfoMsg    = 3;
 ilShow       = 4;
 ilHide       = 5;

// ILPaint = TImageList
const
 ptpSendDoc       = 00;  // документ отправлен (DocState)
 ptpRecivedDoc    = 01;  // документ получен (DocState)
 ptpNotReady      = 02;  // основная картика 16х16 НЕ ГОТОВ
 ptpReady         = 03;  // основная картинка 16х16 ГОТОВ
 ptpUser          = 04;  // основная картинка 16х16 ПОЛЬЗОВАТЕЛЬ
 ptpPolitic       = 05;  // основная картинка 16х16 ПОЛИТИКА
 ptpDivision      = 06;  // основная картинка 16х16 ПОДРАЗДЕЛЕНИЕ
 ptpUnchecked     = 07;
 ptpChecked       = 08;
 ptpDisabled      = 09;
 ptpUncheckedClr  = 10;
 ptpCheckedClr    = 11;
 ptpPartCheck02   = 12;

 ptp_SpileStateIndex1  = 13;
 ptp_SpileStateIndex2  = 14;
 ptp_SpileStateIndex3  = 15;

 ptpHandWrite     = 16;
 ptpGroupMail     = 17;
 ptpPortfel       = 18;
 ptpOverLap       = 19;
 ptpAdmView       = 20;
 ptpInformation   = 21;
 ptpAttention     = 22;
 ptpUsers         = 23;
 ptpReturn        = 24;
 ptpSearch        = 25;
 ptpMap           = 26;
 ptpEditSign      = 27;
 ptpCarKupivip    = 28;
 ptpFilter        = 29;
 ptpCheckSign     = 30;
 ptpUnCheckSign   = 31;
 ptpClose         = 32;
 ptpRefresh       = 33;
 ptpPrint         = 34;
 ptpExit          = 35;
 ptpSmallAdd      = 36;
 ptpSmallEdit     = 37;
 ptpSmallDelete   = 38;
 ptpSmallSave     = 39;
 ptpArea1         = 40;
 ptpArea2         = 41;
 ptpBigAdd        = 42;
 ptpBigEdit       = 43;
 ptpBigDelete     = 44;
 ptpBigSave       = 45;
 ptpInterval      = 46;
 ptpBoxes         = 47;
 ptpOptions       = 48;
 ptpMoscow        = 49;
 ptpSPb           = 50;
 ptpHammerOfJudge = 51;
 ptpListEmpty     = 52;
 ptpListGreen     = 53;
 ptpListRed       = 54;
 ptpRostov        = 55;
 ptpHome          = 56;
 ptpHumans        = 57;
 ptpForClient     = 58;
 ptpAddPresent    = 59;
 ptpView          = 60;
 ptpHide          = 61;
 ptpUndo          = 62;
 ptpDownOrback    = 63;


 shbLatLng            = '<LATLNG><LAT>%s</LAT><LNG>%s</LNG></LATLNG>';
 shbNamedLatLng       = '<LATLNG><NAME>%s</NAME><LAT>%s</LAT><LNG>%s</LNG></LATLNG>';
 shbNamedFloatPoint   = '<FP><NAME>%s</NAME>%s</FP>'; // -- на место второго параметра вставляется по shbLatLng
 FlPtFormat           = '#0.00000000000000';
 GroupDelimiter       = DaggerChar; //'|';
 ItemDelimiter        = BulletChar; //'^';
 AreaDelimiter        = '&';
 ArrayDelimiter       = ','; // JavaScript array of object delimiter

 FieldsDelimiter  = DaggerChar;
 RecordsDelimiter = BulletChar; //'^';

 ipID 			 = 0;
 ipParentID	 = 1;
 ipName 		 = 2;
 ipLevel 		 = 3;
 ipLineColor = 4;
 ipFillColor = 5;
 ipRoute 		 = 6;
 ipSessionID = 7;

 sqlZeroDate = 2;// 01.01.1900



type
 TMapMode = (mmYandex = 0
            ,mmGoogle = 1
 );

 TDeliveryAgent = (daMoscow         = 1
                  ,daSanktPeterburg = 13
                  ,daRostovNaDonu   = 8519);
 // -- режим отображения "Доставка" (что автоматически отображать при переходе на новый автомобиль)
 TDeliveryShowMode = (dsmUndefined = 0
                     ,dsmMarker    = 1
                     ,dsmRoute     = 2);
 // -- режим отображения описания области
 TXMLShowMode = ( xsmUnknown = 0 // -- при передаче такого параметра всё зависит от Mem_XML.Visible и работает как переключатель
                 ,xsmHide    = 1
                 ,xsmShow    = 2);

 TWorkModeType =
    (wmtUnknown  = 0
    ,wmtRead     = 1
    ,wmtWrite    = 2 // -- areas only
    ,wmtMarkers  = 3 // -- readonly
    ,wmtRoute    = 4 // -- readonly
    ,wmtMoscow   = 5 // -- работа с Московским данными
    ,wmtPiter    = 6 // -- работа с Питерскими данными
    ,wmtRostov   = 7 // -- работа с Ростовскими данными
    );

 TWorkMode = set of TWorkModeType;

 TUsedAreasViewMode = ( uavmList     = 0 // -- гладкий список
                      , uavmInterval = 1 // -- дерево с группировкой по интервалу (дата + интервал)
                      , uavmArea     = 2 // -- дерево с группировкой по наименованию зоны
                      , uavmOwner    = 3 // --дерево с группировкой по наименованию зоны-владельца
                      );

 TAreaIntervalIdType = (
                        aiitArea     = 0
                      , aiitPVZ      = 1 //[dbo].[cc_Ref_ShippingAgent_Service](nolock) where [Agent]=1 and [Outlet]=1
             );

 PAreaIntervalItem = ^TAreaIntervalItem;
 TAreaIntervalItem = record
   aiID       : integer;  // -- !!-- absent, need for multiple intervals
   aiAreaID   : integer;  // id области (для отдельной загрузки и привязки к области)
//   aiDate     : TDateTime;    // дата
//   aiBegin    : integer;  // начало интервала
//   aiEnd      : integer;  // окончание интервала
//   aiPriority : integer;
//   aiActive   : boolean;  // -- !!-- absent, need for profile of area
   aiStart    : TDateTime;
   aiLen      : TDateTime;
   aiIdType   : TAreaIntervalIdType;
   _Changed   : boolean;
   function GetXML(single : boolean) : string;
   function SaveIntoDB : boolean;
 end;

 PAreaIntervalList = ^TAreaIntervalList;
 TAreaIntervalList = record
   Items : array of TAreaIntervalItem;
   function LoadFromDB(aAreaID : integer; aIdType : TAreaIntervalIdType) : integer;
   function LoadFromSource(const aSourceItems : array of TAreaIntervalItem) : integer;
   function Arrange(aOldIndex : integer) : integer; // -- сортировка по AreaID asc, Date desc, Begin-End asc
   //function GetIndexForDate(aDate : TDateTime) : integer;
   function GetIndexForAll(aAreaID : integer; aStart, aLen : TDateTime) : integer;
   function GetIndexByID(aID : integer) : integer;
   function GetForDate(adate  :TdateTime; var aAIL : TAreaIntervalList; aWithClear : boolean) : integer;
   function Add(const aAII :  TAreaIntervalItem) : integer;
   //function FillForDates(aDateBegin, aDateEnd : TDate; aDTL : TDatesIntervalList);
   function GetXML(aAreaID : integer; aAreaType : TAreaIntervalIdType) : string;
   function SaveIntoDB(aAreaID : integer; aAreaType : TAreaIntervalIdType) : boolean;
   function Clear : boolean;
 end;

 TAreaListAccept = ( alaNone          = 0 // -- не принимать изменения
                    ,alaChangeExists  = 1 // -- изменить существующие интервалы
                    ,alaAddNoExists   = 2 // -- дополнить несуществующие и оставить существующие в неприкосновенности
                    ,alaFullAccept    = 3 // -- полное замещение существующих и добавление несуществующих
 ); // -- можно, конечно, сделать через [set of ...] ....

  TFloatPointRound = 1..8;

  PFloatPoint = ^TFloatPoint;
  TFloatPoint = record
  procedure LongitudeIntoDMS(var aDegrees,aMinutes : word;var aSeconds : double);
  function GetLongitudeIntoDMS : string;
  procedure LatitudeIntoDMS(var aDegrees,aMinutes : word;var aSeconds : double);
  function GetLatitudeIntoDMS : string;
  function GetXML : string;
  function LatitudeForRequest : string;
  function LongitudeForRequest : string;
  procedure FillFromSelfXML(const aXML : string);
  procedure SetLongitudeFromDMS(aDegree,aMinutes,aSeconds : integer);
  procedure SetLatitudeFromDMS(aDegree,aMinutes,aSeconds : integer);
  function GetLatLon : string; overload;
  function GetLatLon(aRound : TFloatPointRound) : string; overload;
  function GetLonLatIntoDMS : string;
  function getJSObject : string;
  class function Get(aLatitude,aLongitude : double) : TFloatPoint; static;
  case integer of
   0 : (X,Y : double);
   1 : (Longitude,Latitude: double);   (*Долгота, широта - для совместимости с X,Y*)
  end;
  TArrayOfFloatPoint = array of TFloatPoint;

  PFloatRect = ^TFloatRect;
  TFloatRect = record
  class procedure FillBorders(const aPts : array of TFloatPoint; var aRes : TFloatRect); static;
    case Integer of
      0: (Left, Top, Right, Bottom: double);     // another names is : West,North,East,South (!!ATTENTION North coord>South coord)
      1: (TopLeft, BottomRight: TFloatPoint);
  end;

  PNamedFloatPoint = ^TNamedFloatPoint;
  TNamedFloatPoint = record
   fpName : array[1..128] of char;
   Point  : TFloatPoint;
  end;

  TNamedFloatPointArray = record
    Items : array of TNamedFloatPoint;
  end;


 PAreaItem = ^TAreaItem;
 TAreaItem = record
  //aIsEditing   : boolean;
  aID          : integer;     // -- идентификатор
  aParentID    : integer;     // -- идентификатор области-владельца
  aLevel       : integer;
  aRecordState : byte;        // -- признак изменения записи (1 байт по любому, хоть так, хоть boolean)
  aSessionID   : string[38];  // -- идентификатор на сессию (время существования) и для множественного добавления без предварительного сохранения добавленных ранее
  aName        : string[255]; // -- наименование области
  aRGBLine     : string[6];   // -- цвет границы в формате RGB hex RRGGBB
  aRGBFill     : string[6];   // -- цвет заливки в формате RGB hex RRGGBB
  aRouteNum    : integer;
  aGeoType     : string[32];  // -- тип получившегося Geometry
  aGeoNum      : integer;     // -- кол-во элементов в Geometry
  LatLng       : array of TFloatPoint;
 function GetXML : string;
 function LoadFromXML(const aXML : string; aPrevVersion : boolean = false) : boolean;
 procedure LoadFromSource(const aSrcItem : TAreaItem);
 //--20170525-- function getStrObject : string;
 function getJSObject : string;
 function SaveIntoDB : integer;
 //function Equal(Test : TAreaItem) : boolean;
 procedure Clear;
 end;

 TAreaListSort = (alsNone, alsName, alsID);

 PAreaList = ^TAreaList;
 TAreaList = record
   Items : array of TAreaItem;
   als: TAreaListSort;
   function LoadFromDB(const aXMLFilter : string = '') : boolean;
   function LoadFromXML(const aXML : string) : boolean;
   //--20170525--function getStrObject(const aIDs : array of integer) : string;
   function getJSObject(const aIDs : array of integer) : string;
   function SaveIntoDB : boolean;

   procedure DeleteAreaFromAreaList(aDelIndex : integer; aMarkOnly : boolean);
   function GetAreaDataById(aAreaID : integer; var aAreaName : string;var aRouteNum : integer) : integer;
   function FillItem(const aSrc : TAreaItem) : integer;

   procedure Arrange(mode : TAreaListSort);

   function GetIndexByID(aAreaID : integer) : integer;
   function GetRegion(const aIDs : array of integer; var aRegion : TFloatRect) : string;
   function getJSONForBound(const aIDs : array of integer) : string;
   procedure ClearUnsaved;
   function Clear : boolean;
 end;

 PCarItem = ^TCarItem;
 TCarItem = record
  Car_ID      : integer;
  Car_Model   : array[1..20] of char;
  Car_Reg_Num : array[1..20] of char;
  Driver_FIO  : array[1..100] of char;
  Area_ID     : integer;
  Area_name   : array[1..100] of char;
  _Points     : integer;
  _Deliveries : integer;
  _Return     : integer;
  NumPic      : TBitmap;
 function LoadFromSource(const aCarItem : TCarItem) : boolean;
 procedure Clear;
 end;

 TCarListArrange = (
     claNone           =  0
   , claCar_Model      =  1
   , claCar_Reg_Num    =  2   // --
   , claDriver_FIO     =  3
   , claArea_Name      =  4
   , claOrders         =  5
   );

 PCarList = ^TCarList;
 TCarList = record
   Items  : array of TCarItem;
   clArr  : TCarListArrange;
   clDesc : boolean;
 procedure Arrange(aMode : TCarListArrange; aDesc : boolean);
 function Clear : boolean;
 end;


 PMarkerItem = ^TMarkerItem;
 TMarkerItem = record // это неполнолценная TDeliveryPoint из ROUTER
   Area_ID       : integer;
   Car_ID        : integer;
   Delivery_FIO  : array[1..255] of char ;
   Customer_FIO  : array[1..255] of char ;
   Delivery_Addr : array[1..512] of char ;
   Phone         : array[1..1024* 8] of char ;
   Interval      : array[1..32*16] of char;
   AboutFull     : array[1..1024*16] of char ;
   LatLng        : TFloatPoint;
 function getDescription : string;
 function getDescriptionObj : string;
 end;

 PMarkerList = ^TMarkerList;
 TMarkerList = record // это неполнолценная TDeliveryPoint из ROUTER
   Items : array of TMarkerItem;
 procedure CalculateForCar(aCarID : integer; out aPt, aDlv, aRet : integer); // -- считает точки, заказы и возвраты по AboutFull для машины
 function MarkersForDisplay(aCarID : integer; out aMarkerList : TMarkerList) : boolean;
 function getDescription : string;
 function getDescriptionObj(aPack : boolean) : string;
 function Clear : boolean;
 end;


 TPackedMarkerItem = packed record
   LatLng  : TFloatPoint;
   Markers : TMarkerList;
   function IsIt(aLat,aLng : double) : boolean;
   function Add(aMI : TMarkerItem) : integer;
   function Clear : boolean;
 end;


 TPackedMarkerList = packed record
   Items : array of TPackedMarkerItem;
   function getIndex(aLat,aLng : double) : integer;
   function AddItem(const aMI : TMarkerItem) : integer;
   function FillItems(const aML : array of TMarkerItem) : boolean;
   function getDescriptionObj : string;
   function Clear : boolean;
 end;


 PHourInterval = ^THourInterval;
 THourInterval = record
   DayBegin  : byte;
   HourBegin : byte;
   DayEnd    : byte;
   HourEnd   : byte;
 end;

 PIntervalSchemeItem = ^TIntervalSchemeItem;
 TIntervalSchemeItem = record
   SchemeName : array[1..128] of char;
   DateBegin  : TDate;
   DateEnd    : TDate;
   Intervals  : array of THourInterval;
   function LoadFromDB(const aName : string) : boolean;
   function LoadFromXML(const aFileOrBody : string) : boolean;
   function LoadFromSource(const aSrc : TIntervalSchemeItem) : boolean;
   function SaveIntoDB : boolean;
   function SaveIntoXML(const aFileName : string) : boolean;
   function FillDateIntervalList(aDateBegin,aDateEnd : TDate; aAreaId : integer; aAreaType : TAreaIntervalIdType; var aAIL : TAreaIntervalList) : boolean;
   procedure Clear;
 end;

 PIntervalSchemeList = ^TIntervalSchemeList;
 TIntervalSchemeList = record
   Intervals : array of TIntervalSchemeItem;
//   function LoadFromDB : boolean;
   function LoadFromXML(const aFileOrBody : string) : boolean;
//   function SaveIntoDB : boolean;
//   function SaveIntoXML(const aFileName : string) : boolean;
   procedure Clear;
 end;

 PUsedAreaItem = ^TUsedAreaItem;
 TUsedAreaItem = record
  Date_Interval : array[0..20] of char ; // -- в формате: dd.mm.yyyy (hh-hh)
  AreaName      : array[0..100] of char ;
  AreaOwnerName : array[0..100] of char ;
 end;

 PUsedAreaList = ^TUsedAreaList;
 TUsedAreaList = record
   Items : array of TUsedAreaItem;
   function LoadFromDB(const aXMLFilter : string = '') : boolean;
   procedure GetMaxLengths(var aMaxArea, aMaxOwner : integer);
   function GroupBy(aVM : TUsedAreasViewMode) : string;
   procedure IntoExcel(const aTitle : string);
   procedure Clear;
 end;

 PNoDeliveryItem = ^TNoDeliveryItem;
 TNoDeliveryItem = record
   ndiDate              : TDate;   // -- Дата
   Oper                 : array[1..64] of char;// -- Оператор
   OrderNT              : array[1..64] of char;// -- № заказа и Тип заказа
   OrderState           : array[1..64] of char;// -- Состояние заказа
   StateAdditionalCode  : array[1..32] of char;// -- StateAdditionalCode
   OrderAmount          : currency;// -- Сумма заказа
   RouteName            : array[1..64] of char;// -- Маршрут
   Driver               : array[1..64] of char;// -- Водитель
   CarRegNum            : array[1..10] of char;// -- Гос. номер
   IsFirstOrder         : boolean;
   _RealDate            : TDateTime;
 end;

 PNoDeliveryList = ^TNoDeliveryList;
 TNoDeliveryList = record
   Items : array of TNoDeliveryItem;
   function LoadFromDB(aBegin, aEnd : TDate) : boolean;
   function IntoExcel(const aTitle  :string) : boolean;
   function Clear : boolean;
 end;

 PAreaLogItem = ^TAreaLogItem;
 TAreaLogItem = record
   id       : integer;
   AreaID   : integer;
   AreaName : array[1..128] of char;
   DateEdit : TDateTime;
   user     : array[1..64] of char;
   fullname : array[1..256] of char;
   ws       : array[1..64] of char;
   xml      : array[1..MAXSHORT*2] of char;  // ATTENTION!!! возникают ошибки когда xml не помещается в MAXSHORT
  procedure LoadFromSource(aALI : TAreaLogItem);
  procedure Clear;
 end;

 TAreaLogListArrange = (
    allaNone     = 0
   ,allaAreaID   = 1
   ,allaAreaName = 2
   ,allaDateEdit = 3
   ,allaUser     = 4
   ,allaFullName = 5
   ,allaWS       = 6
   ,allaID       = 7

 );

 PAreaLogList = ^TAreaLogList;
 TAreaLogList = record
   Items : array of TAreaLogItem;
   allArr  : TAreaLogListArrange;
   allDesc : boolean;
  function LoadFromDB(const aXMLFilter : string) : boolean;
  function IntoExcel(const aTitle : string) : boolean;
  function getUserName(const aNetName  :string)  :string;
  procedure Arrange(aMode : TAreaLogListArrange; aDesc : boolean);
  function Clear : boolean;
 end;

 PSimpleAreaItem = ^TSimpleAreaItem ;
 TSimpleAreaItem = packed record
   AreaId   : integer;
   AreaName : array[1..255] of char;
 end;

 PForPointAreaList = ^TForPointAreaList;
 TForPointAreaList = packed record
   Point : TFloatPoint;
   Items : array of TSimpleAreaItem;
  function Fill(aPoint : TFloatPoint; const aAreaList : TAreaList) : integer;
  function Clear : boolean;
 end;

 PPVZItem = ^TPVZItem;
 TPVZItem = packed record
   id           : integer;
   Description  : array[1..255] of char;
   Region       : array[1..3] of char;
 end;

 TPVZList = packed record
   Items : array of TPVZItem;
   function LoadFromDB : integer;
   function GetDescriptionByID(aID  :integer) : string;
   function Clear : boolean;
 end;


 PCurObject = ^TCurObject;
 TCurObject = packed record
   id     : integer;
   idType : TAreaIntervalIdType;
   procedure Fill(aID : integer; aType : TAreaIntervalIdType);
 end;


 TAreaPicItem = record
   clrFill : TColor;
   clrLine : TColor;
   indexPic: integer;
 end;

 TAreaPicList = record  // -- подобие TNamedImageList или TImageList from Delphi XE10 (FMX)
   imageList : TImageList;
   items     : array of TAreaPicItem;
   procedure Create;
   procedure Clear;
   function GetIndex(aFill, aLine : TColor) : integer; inline;
   function Add(aFill, aLine : TColor) : integer; inline;
   procedure DrawBitmap(const aFill,aLine : shortstring; var bmp : TBitmap); inline;
 end;

 TH2Item = record
   id        : integer;
   TimeFrom  : TTime;
   TimeTo    : TTime;
   Used      : byte;
   function View(long : boolean) : string;
   procedure Assign(const src : TH2Item);
 end;


 TH2List = record
   items : array of TH2Item;
   function IndexOf(id : integer) : integer; overload;
   function IndexOf(TimeFrom, TimeTo : TTime) : integer; overload;
   function Add(const src : TH2Item) : integer; overload;
   function Add(id: integer; TimeFrom, TimeTo : TTime; Used : byte) : integer; overload;
   function LoadFromDB : integer;
   function DisplayString(index, col : integer) : string;
   function Clear : boolean;
 end;



 TPayIntervalItem = record
   id : integer;
   AreaId : integer;
   IntervalId : integer;
   DateBegin : TDateTime;
   DateEnd : TDateTime;
   Quota : integer;
   procedure Assign(const src : TPayIntervalItem);
   function GetXML : string;
 end;

 // -- проверка валидности создаваемого интервала --

 TPILCheck = ( // -- результат проверки допустимости инервалов
             pilcNotExists  //  -- интервал не существовать (id 0)
            ,pilcExisOpen   //  -- попытка добавить интервал к существующему с незакрытой датой
            ,pilcOverlap    //  -- попытка добавить интервал к существующему с закрытой датой в перехлест
        );

 TUpdPIL = (updNone, updInsert, updUpdate, updDelete);

 TPayIntervalList = record
   items : array of TPayIntervalItem;
   function IndexOf(id : integer) : integer; overload;
   function IndexOf(AreaId, IntervalId : integer) : integer; overload; // -- есть или нет для такой области такой интервал
   function LoadFromDB : integer;
   function GetXML : string;
   function SaveToDB : boolean;
   function CheckValid(const Check : TPayIntervalItem) : TPILCheck;
   function Add(id,AreaId,IntervalId : integer; DateBegin,DateEnd:TDateTime;Quota:integer) : integer; overload;
   function Add(const src : TPayIntervalItem) : integer; overload;
   procedure Sort;
   function Delete(index : integer) : boolean;
   procedure Clear;
 end;

 TAreaAgentItem = record
   AreaId : integer;
   Agent  : integer;
 end;

 TAreaAgentList = record
   items : array of TAreaAgentItem;
   function LoadFromDB : integer;
   function IndexOf(AreaId : integer) : integer;
   function CheckAreaAgent(AreaId, Agent : integer) : boolean;
   function GetAreas(Agent : integer; var Areas : TIntegerDynArray) : integer;
   procedure Clear;
 end;

 (*ATTENTION*)
 (* TAccidentItem и TAccidentList объявления и реализация в U_DTP_Editor для возможности работы в MO2 *)



const // --  управление IE : к примеру PrintPreview SendMessage(SDV_Handle, WM_COMMAND, MakeWParam(ID_IE_FILE_PRINTPREVIEW, IECMD_SDV), 0);
//http://www.codeweblog.com/ie-scale-operations-and-regular-news/
IECMD_SDV = 1; //public, controls, type Shell DocObject View
ID_IE_FILE_SAVEAS             = 258; //open, save the current page to your hard disk. "Shell DocObject View" Window handle of the Command ID
ID_IE_FILE_PAGESETUP          = 259; //open, print page setup. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_PRINT              = 260; //open and print the page. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_NEWWINDOW          = 275; //open new browser window. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_PRINTPREVIEW       = 277; //open, print preview. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_NEWMAIL            = 279; //the public, the drafting of new messages. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_SENDDESKTOPSHORTCUT= 284; //open, create a desktop shortcut to the current page. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_ABOUTIE            = 336; //open, IE help on the Internet Explore. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_HELPINDEX          = 337; //open, IE Help Contents and Index. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_WEBTUTORIAL        = 338; //open, IE help navigate Internet Explore. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_FREESTUFF          = 341; //open, IE help Download Internet Explore. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_PRODUCTUPDATE      = 342; //open, IE help Windows Update information. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_FAQ                = 343; //open, IE help FAQ. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_ONLINESUPPORT      = 344; //open, IE help online support. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_FEEDBACK           = 345; //open, IE help feedback. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_BESTPAGE           = 346; //open, IE help Exchange Server. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_SEARCHWEB          = 347; //open, IE to help search the Web. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_MSHOME             = 348; //open, IE to help Microsoft home page. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_VISITINTERNET      = 349; //open, IE help Get ISDN. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_STARTPAGE          = 350; //open, IE start page to help. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_IMPORTEXPORT       = 374; //open, IE file import and export. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_ADDTRUST           = 376; //open, IE file to a trusted site. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_ADDLOCAL           = 377; //open, IE files to the local site. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_NEWPUBLISHINFO     = 387; //open, start the Internet Connection Wizard. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_NEWCORRESPONDENT   = 390; //open, start Outlook. "Shell DocObject View" window handle of the Command ID
ID_IE_FILE_NEWCALL            = 395; //open, start NetMeeting. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_NETSCAPEUSER       = 351; //open, IE tips to help Netscape users. "Shell DocObject View" window handle of the Command ID
ID_IE_HELP_ENHANCEDSECURITY   = 375; //open, IE enhanced security configuration to help. "Shell DocObject View" window handle of the Command ID

IECMD_IES = 2; //public, controls, types of Internet Explorer_Server
ID_IE_CONTEXTMENU_ADDFAV      = 2261; //open to the IE Favorites. "Internet Explorer_Server" window handle of the Command ID
ID_IE_CONTEXTMENU_VIEWSOURCE  = 2139; //open, view web page source code. "Internet Explorer_Server" window handle of the Command ID
ID_IE_CONTEXTMENU_REFRESH     = 6042; //open, refresh the current page. "Internet Explorer_Server" window handle of the Command ID

WorkModeTypeDescr : array[TWorkModeType] of string =
  (
   'Запуск программы'
  ,'Отображение областей'
  ,'Редактирование областей'
  ,'Просмотр точек доставки'
  ,'Построение маршрута доставки'
  ,'Москва'
  ,'Санкт-Петербург'
  ,'Ростов-на-Дону'
  );

 AIL_xmlBase    = 'INTERVAL_LIST';
 AIL_xmlHeader  = '<%s USER="%s" MINDATE="%s" MAXDATE="%s" AREAID="%d" AREATYPE="%d">';
 AIL_xmlItemNew = '<INTERVAL ID="%d" AREAID="%d" START="%s" LEN="%s" TYPE="%d" />';

 BordersPoints : array[0..3] of TFloatPoint =
   (
  // долгота                   широта
   ( Longitude :   59.23944  ; Latitude : 81.84306 ),    // -- север
   ( Longitude : -168.98333  ; Latitude : 65.78333 ),    // -- восток
   ( Longitude :   47.85778  ; Latitude : 41.22056 ),    // -- юг
   ( Longitude :   19.63861  ; Latitude : 54.4625  )     // -- запад
   );
//http://ru.wikipedia.org/wiki/%D0%9A%D1%80%D0%B0%D0%B9%D0%BD%D0%B8%D0%B5_%D1%82%D0%BE%D1%87%D0%BA%D0%B8_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B8
//Северная точка — мыс Флигели, Земля Франца-Иосифа, Архангельская область
// (81°50′35″ с. ш. 59°14′22″ в. д. (G) (O))
//Южная точка — не именованная на картах точка с высотой свыше 3500 м расположена в 2,2 км к востоку от горы Рагдан и к юго-западу от гор Несен (3,7 км) и Базардюзю (7,3 км), Дагестан
// (41°13′14″ с. ш. 47°51′28″ в. д. (G) (O))[1]
//Западная точка — Нармельн, Балтийская коса, Калининградская область
// (54°27′45″ с. ш. 19°38′19″ в. д. (G) (O))
//Восточная точка — остров Ратманова, Чукотский автономный округ
// (65°47′ с. ш. 169°01′ з. д. (G) (O))

BordersContinentPoints : array[0..1] of TFloatPoint =
(
 (Longitude : 27.31667   ; Latitude : 77.71667),  // -- NE  Северо-Запад
 (Longitude : -168.33333 ; Latitude : 41.21667)   // -- SW  Юго-восток
);
//Северная точка — мыс Челюскин, Красноярский край
//   (77°43’N)
//Южная точка — не именованная на картах точка с высотой свыше 3500 м расположена в 2,2 км к востоку от горы Рагдан и к юго-западу от гор Несен (3,7 км) и Базардюзю (7,3 км), Дагестан
//   (41°13’N)
//Западная точка — берег реки Педедзе, Псковская область
//   (27°19’E)
//Восточная точка — мыс Дежнёва, Чукотский автономный округ
//   (169°40’W)

var
 MapMode           : TMapMode;
 WorkMode          : TWorkMode;
 FullAreaList      : TAreaList; // -- это для редактора и отображения по фильтру
 HistoryAreaList   : TAreaList; // -- это для отображения истории зон из XML от Router;
 CarList           : TCarList;
 MarkerList        : TMarkerList;
 AreaIntervalList  : TAreaIntervalList;
 CurIntervalScheme : TIntervalSchemeItem;
 AreaListAccept    : TAreaListAccept = alaNone;
 UsedAreaList      : TUsedAreaList;
 UsedAreasViewMode : TUsedAreasViewMode = uavmList;
 AreaLogList       : TAreaLogList;
 AreaLogItem       : TAreaLogItem;

 HTMLFileName     : string;
 CanDelHTMLOnExit : boolean = true;
 SDV_Handle : cardinal = 0;  // handle of "Shell DocObject View" class
 IES_Handle : cardinal = 0;  // handle of "Internet Explorer_Server" class

 DeliveryShowMode : TDeliveryShowMode = dsmUndefined;

 // -- значения по умолчанию для создания области
 defAreaLevel : integer = 4;
 defColorLine : string[6] = '000000';
 defColorFill : string[6] = 'FFFFFF';

 defHourBegin : byte = 9;
 defHourEnd   : byte = 21;

 loginUser         : string = ''; // -- пользователь вошедший в систему
 lastUser          : string = ''; // -- крайний
 needMapMode       : boolean = false;// -- отрабатывать если loginUser=lastUser
 needAreaType      : TAreaIntervalIdType = aiitArea;
 needDeliveryMode  : boolean = false;// -- отрабатывать если loginUser=lastUser
 needToolsMode     : boolean = false;// -- отрабатывать если loginUser=lastUser
 needTwoHoursMode  : boolean = false;// -- отрабатывать если loginUser=lastUser

 CheckOutPoints    : boolean = true;// -- проверять полное вхождение точек в родительскую зону

 spNoDeliveryReport     : string = 'ae_NoDelivery_Report'; // -- процедура получения отчета по недоставке
 spIntervalListLoad     : string = 'ae_AreaIntervalList_Load_New';
 spIntervalListSave     : string = 'ae_AreaIntervalList_Save_New2';
 spIntervalListLoadPVZ  : string = 'pvz_GetIntervalList';
 spIntervalListSavePVZ  : string = 'pvz_SetIntervalList';

 dtRnd             : integer = -10; // округление TdateTime для последующего сравнения

 ForPointAreaList  :  TForPointAreaList;
 PVZList           :  TPVZList;
 AreaPicList       :  TAreaPicList;
 H2List            :  TH2List; // -- список двухчасовых интервалов "супер-платной" доставки
 PayIntervalList   :  TPayIntervalList; // -- полный список для всех областей
 UpdatePIL         :  TPayIntervalList; // -- список интервалов "супер-платной" для сохранения в БД
 AreaAgentList     :  TAreaAgentList;

//-- получение информации о режиме работы (чтение, запись и т.п.)
function AboutWorkMode : string;
(* ГЛАВНАЯ : Получение информации за день из таблицы rt_History ***********************************)
function GetFullData(aDate : TDateTime; aAgent: TDeliveryAgent) : boolean;
//-- получение набора координат в простой строке (не XML, не JSON)
function ArrayOfFloatPointIntoString(const aArFP : TArrayOfFloatPoint) : string;
//-- запуск на выполнение скрипта JavaScript
procedure ExecuteScript(aWebBrowser : TWebBrowser; aScript: string);
(* Получение значения тэга (элемента) со страницы HTML ********************************************)
function GetIdValue(aWB  : TWebBrowser; const Id : string) : string;
(* Получение отображения регистрационного номера и подгонка по TRect ******************************)
function GetRegNumber(const aRegNumber  :string; const aRect : TRect; var aBMP : TBitmap) : boolean;
(* Подготовка наименования области для упорядочивания *********************************************)
function AreaNameForArrange(const aAreaname : string) : string;
(* Проверка вхождения точки в область *************************************************************)
function PointInArea(const aCont : array of TFloatPoint;aTestPoint : TFloatPoint) : boolean;
(* Получение набора точек, входящих в область (aIn  - область, aCont - контрольный набор) *********)
function GetInnerPoints(aIn, aCont : array of TFloatPoint; var aRes : TArrayOfFloatPoint) : integer;
(* Подготовка описания точек для отображения ******************************************************)
function GetPointsForDisplay(const aPoints : TArrayOfFloatPoint) : string;



 procedure IE_PrintPreview; // -- предварительный просмотр перед печатью
 procedure IE_ImportExport; // -- импорт / экспорт настроек
 procedure IE_Refresh;      // -- обновление страницы (F5)



  procedure WebBrowserFocus(Wb : TWebBrowser);

implementation

uses U_Main;

(*OVERLOADING*) // SysUtils.StringReplace
function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
Result:=StringReplaceEx(S, OldPattern, NewPattern, Flags);
end;



procedure InitTypes;
begin
AreaPicList.Create;
end;

procedure FinalTypes;
begin
AreaAgentList.Clear;
UpdatePIL.Clear;
PayIntervalList.Clear;
H2List.Clear;
AreaPicList.Clear;
PVZList.Clear;
MarkerList.Clear;
CarList.Clear;
HistoryAreaList.Clear;
FullAreaList.Clear;
AreaIntervalList.Clear;
UsedAreaList.Clear;
AreaLogList.Clear;
AreaLogItem.Clear;
end;




(**************************************************************************************)
function TAreaIntervalItem.GetXML(single : boolean) : string;
const
 bool : array[boolean] of char = ('0','1');
begin
Result:='';
try
Result:=Result+Format(AIL_xmlItemNew,[
       aiID
      ,aiAreaID
      ,FormatDateTime('yyyymmdd hh:nn:ss.zzz',RoundTo(aiStart,dtRnd))
      ,FormatDateTime('yyyymmdd hh:nn:ss.zzz',RoundTo(sqlZeroDate+aiLen, dtRnd))
      ,integer(aiIdType)
      ]);

if single
   then Result:=Format('<%s USER="%s">',[AIL_xmlBase, AppParams.UserName])+crlf+Result+Format('</%s>',[AIL_xmlBase]);
except
 on E : Exception do LogErrorMessage('TAreaIntervalItem.GetXML',E,[]);
end;
end;

function TAreaIntervalItem.SaveIntoDB : boolean;
var
 xml   : string;
 ADOSP : TADOStoredProc;
begin
Result:=false;
try
xml:=GetXML(true);
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:=spIntervalListSave; //spIntervalListSavePVZ
case aiIdType of
aiitArea : ADOSP.ProcedureName:=spIntervalListSave;
aiitPVZ  : ADOSP.ProcedureName:=spIntervalListSavePVZ;
end;
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.ExecProc;
Result:=integer(ADOSP.Parameters[0].Value)>0;
finally
if Assigned(ADOSP)then FreeAndNil(ADOSP);
end;
Result:=true;
except
 on E : Exception do LogErrorMessage('TAreaIntervalItem.SaveIntoDB',E,[]);
end;
end;



// -- TAreaIntervalList ---------------------------------------------------------
function TAreaIntervalList.LoadFromDB(aAreaID : integer; aIdType : TAreaIntervalIdType) : integer;
var
 xml   : string;
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=-1;
try
Clear;
if aAreaID>0
   then xml:=Format('<XML AREAID="%d"/>', [aAreaID])
   else xml:='<XML AREAID="0"/>';
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
case aIdType of
aiitArea : ADOSP.ProcedureName:=spIntervalListLoad;
aiitPVZ  : ADOSP.ProcedureName:=spIntervalListLoadPVZ;
end;
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.Active:=True;

if integer(ADOSP.Parameters[0].Value)<=0
   then begin
   Result:=0;
   Exit;
   end;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Length(Items);
    SetLength(Items,ind+1);
    with Items[ind] do
      begin
      {-$MESSAGE Hint 'Внимание!!! В таблице "map_AreaTime_Full" нет ID. Это поле нужно сделать в новой таблице!'}
      aiID       := Fields[0].AsInteger;  (*ATTENTION*)
      aiAreaID   := Fields[1].AsInteger;
      aiStart    := RoundTo(Fields[2].AsDateTime,dtRnd);
      aiLen      := RoundTo(Fields[3].AsDateTime  - sqlZeroDate,dtRnd);
      if ADOSP.Fields.Count>4
          then aiIdType:=TAreaIntervalIdType(Fields[4].AsInteger)
          else aiIdType:=aiitArea;
      //aiDate     := Fields[2].AsDateTime;
      //aiBegin    := Fields[3].AsInteger;
      //aiEnd      := Fields[4].AsInteger;
      //aiPriority := Fields[5].AsInteger;
      //aiActive   := Fields[6].AsBoolean;
      // aiInterval:= Fields[7].AsString; в формате '00-00'
      _Changed   := false;
      end;
    Next;
    end;
  end;
Result:=Length(Items);
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.LoadFromDB',E,[]);
end;
end;
//---
function TAreaIntervalList.LoadFromSource(const aSourceItems : array of TAreaIntervalItem) : integer;
var
 ln : integer;
begin
Result:=-1;
try
Clear;
ln:=Length(aSourceItems);
if ln>0
   then begin
   SetLength(Items, ln);
   System.Move(aSourceItems[0],Items[0], SizeOf(TAreaIntervalItem)*ln);
   end;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.LoadFromSource',E,[]);
end;
end;

function TAreaIntervalList.Arrange(aOldIndex : integer) : integer; // -- сортировка по AreaID asc AND Date desc AND Begin-End asc
var
 strl : TStringList;
 anc  : string;
 ss   : string;
 cnt  : integer;
 tmp  : array of TAreaIntervalItem;
begin
Result:=aOldIndex;
anc:='';
try
if (Result>=Low(Items)) and (Result<=High(Items))
   then with Items[Result]
         do //anc:=FormatFloat('0000000000',aiAreaID)+FormatFloat('0000000000',Trunc(aiDate))+FormatFloat('00',aiBegin)+FormatFloat('00',aiEnd);
         anc:=FormatFloat('0000000000',aiAreaID)+FormatDateTime('yyyymmdd_hhnnss',aiStart)+FormatDateTime('yyyymmdd_hhnnss',aiStart+aiLen);
strl:=TStringList.Create;
try
for cnt:=0 to High(Items)
  do begin
  //ss:=FormatFloat('0000000000',Items[cnt].aiAreaID)+FormatFloat('0000000000',100000-Trunc(Items[cnt].aiDate))+FormatFloat('00',Items[cnt].aiBegin)+FormatFloat('00',Items[cnt].aiEnd);
  ss:=FormatFloat('0000000000',Items[cnt].aiAreaID)+FormatDateTime('_yyyymmdd',100000-Trunc(Items[cnt].aiStart))+FormatDateTime('_hhnnss',Frac(Items[cnt].aiStart))+FormatDateTime('yyyymmdd_hhnnss',Items[cnt].aiStart+Items[cnt].aiLen);
  strl.AddObject(ss, TObject(@Items[cnt]));
  end;
strl.Sort;
SetLength(tmp, strl.count);
for cnt:=0 to High(Items)
  do System.Move(PAreaIntervalItem(strl.Objects[cnt])^, tmp[cnt], SizeOf(TAreaIntervalItem));
SetLength(Items, 0);
SetLength(Items, Length(tmp));
System.Move(tmp[0], Items[0], SizeOf(TAreaIntervalItem)*Length(Items));
if anc<>''
   then for cnt:=0 to High(Items)
          do with Items[cnt]
              do //if FormatFloat('0000000000',aiAreaID)+FormatFloat('0000000000',Trunc(aiDate))+FormatFloat('00',aiBegin)+FormatFloat('00',aiEnd) = anc
                   if FormatFloat('0000000000',aiAreaID)+FormatDateTime('yyyymmdd_hhnnss',aiStart)+FormatDateTime('yyyymmdd_hhnnss',aiStart+aiLen)=anc
                    then begin
                    Result:=cnt;
                    Break;
                    end
   else Result:=-1;
finally
Setlength(tmp,0);
FreeStringList(strl);
end;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.Arrange',E,[]);
end;
end;
//---
function TAreaIntervalList.GetIndexForAll(aAreaID : integer; aStart, aLen : TDateTime) : integer;
var
 cnt : integer;
 dtS : extended;
 dtL : extended;
begin
Result:=-1;
try
dtS:=RoundTo(aStart, dtRnd);
dtL:=RoundTo(aLen  , dtRnd);
for cnt:=0 to High(Items)
  do //if aDate = items[cnt].aiDate
    if (aAreaID = Items[cnt].aiAreaID) and
       (dtS = RoundTo(items[cnt].aiStart,dtRnd)) and
       (dtL = RoundTo(items[cnt].aiLen,dtRnd))
       then begin
       Result:=cnt;
       Break;
       end
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.GetIndexForAll',E,[aAreaID, aStart, aLen]);
end;
end;
//---
function TAreaIntervalList.GetIndexByID(aID : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if (aID = Items[cnt].aiID)
       then begin
       Result:=cnt;
       Break;
       end;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.GetIndexByID',E,[aID]);
end;
end;
//---
function TAreaIntervalList.GetForDate(aDate : TdateTime; var aAIL : TAreaIntervalList; aWithClear : boolean) : integer;
var
 cnt   : integer;
 dtInt : integer;
 ind   : integer;
 sz    : cardinal;
begin
Result:=-1;
try
if aWithClear then aAIL.Clear;
dtInt:=Trunc(aDate);
sz:=SizeOf(TAreaIntervalItem);
for cnt:=0 to High(Items)
  do if (dtInt = Trunc(Items[cnt].aiStart))
       then begin
       ind:=Length(aAIL.Items);
       Setlength(aAIL.Items, ind+1);
       System.Move(Items[cnt],aAIL.Items[ind],sz);
       end;
Result:=Length(aAIL.Items);
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.GetForDate',E,[]);
end;
end;
//---
function TAreaIntervalList.Add(const aAII :  TAreaIntervalItem) : integer;
var
 ind : integer;
begin
Result:=-1;
try
ind := length(Items);
SetLength(Items, ind+1);
System.Move(aAII, Items[ind], SizeOf(TAreaIntervalItem));
Result:=ind;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.ExistsForDate',E,[aAII.aiID, aAII.aiStart]);
end;
end;


function TAreaIntervalList.GetXML(aAreaID : integer; aAreaType : TAreaIntervalIdType) : string;
var
 cnt : integer;
 minDate  : TDateTime;
 maxDate  : TDateTime;
 BaseDate : TDateTime;

begin
Result:='';
try
minDate:=EncodeDate(2099,12,31);
maxDate:=EncodeDate(2000,1,1);
for cnt:=0 to High(Items)
  do begin
  BaseDate:=Items[cnt].aiStart;
  if BaseDate<minDate then minDate:=BaseDate;
  BaseDate:=Items[cnt].aiStart+Items[cnt].aiLen;
  if BaseDate>maxDate then maxDate:=BaseDate;
  end;
for cnt:=0 to High(Items)
  do Result:=Result+Items[cnt].GetXML(false)+crlf;
Result:=Format(AIL_xmlHeader,[AIL_xmlBase, AppParams.UserName, FormatDateTime('yyyymmdd',minDate), FormatDateTime('yyyymmdd',maxDate),aAreaID, integer(aAreaType)])+crlf+Result+Format('</%s>',[AIL_xmlBase]);
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.GetXML',E,[]);
end;
end;


function TAreaIntervalList.SaveIntoDB(aAreaID : integer; aAreaType : TAreaIntervalIdType) : boolean;
var
 xml   : string;
 ADOSP : TADOStoredProc;
begin
Result:=false;
xml:='';
try
xml:=GetXML(aAreaID,aAreaType);
//CopyStringIntoClipboard(xml);
//Exit;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
case aAreaType of
aiitArea : ADOSP.ProcedureName:=spIntervalListSave;
aiitPVZ  : ADOSP.ProcedureName:=spIntervalListSavePVZ;
end;
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.ExecProc;
Result:=integer(ADOSP.Parameters[0].Value)>0;
finally
if Assigned(ADOSP)then FreeAndNil(ADOSP);
end;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.SaveIntoDB',E,[xml]);
end;
end;

//---
function TAreaIntervalList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
 on E : Exception do LogErrorMessage('TAreaIntervalList.Clear',E,[]);
end;
end;

procedure TFloatPoint.LongitudeIntoDMS(var aDegrees,aMinutes : word; var aSeconds : double);
(*ATTENTION*) // SOUTH Longitude is negative
begin
aDegrees := TRUNC(Longitude);
aMinutes := TRUNC((Longitude-aDegrees)*60);
aSeconds := ((Longitude-aDegrees)*60-aMinutes)*60;
end;


function TFloatPoint.GetLongitudeIntoDMS : string;
var
 Degrees,Minutes : word;
 Seconds         : double;
 res             : string;
begin
LongitudeIntoDMS(Degrees,Minutes,Seconds);
if Longitude>0
   then res:='СШ'  // -- N
   else res:='ЮШ'; // -- S
Result:=Format('%d'+DegreeChar+'%d''%s'''' %s',[Degrees,Minutes,FormatFloat('00.0000',Seconds),res]);
end;


procedure TFloatPoint.LatitudeIntoDMS(var aDegrees,aMinutes : word; var aSeconds : double);
(*ATTENTION*) // WEST Latitude is negative
begin
aDegrees := TRUNC(Latitude);
aMinutes := TRUNC((Latitude-aDegrees)*60);
aSeconds := ((Latitude-aDegrees)*60-aMinutes)*60;
end;


function TFloatPoint.GetLatitudeIntoDMS : string;
var
 Degrees,Minutes : word;
 Seconds         : double;
 res             : string;
begin
LatitudeIntoDMS(Degrees,Minutes,Seconds);
if Latitude>0
   then res:='ВД'   // -- E
   else res:='ЗД';  // -- W
Result:=Format('%d'+DegreeChar+'%d''%s'''' %s',[Degrees,Minutes,FormatFloat('00.0000',Seconds),res]);
end;

function TFloatPoint.GetXML : string;
var
 txtLat : string;
 txtLng : string;
begin
txtLat:=StringReplace(FloatToStr(Latitude),FormatSettings.DecimalSeparator,'.',[]);
txtLng:=StringReplace(FloatToStr(Longitude),FormatSettings.DecimalSeparator,'.',[]);
Result:=Format(shbLatLng,[txtLat,txtLng]);
end;

function TFloatPoint.LatitudeForRequest : string;
var
 ds : char;
begin
ds:=FormatSettings.DecimalSeparator;
try
FormatSettings.DecimalSeparator:='.';
Result:=FormatFloat(FlPtFormat,Latitude);
finally
FormatSettings.DecimalSeparator:=ds;
end;
end;

function TFloatPoint.LongitudeForRequest : string;
var
 ds : char;
begin
ds:=FormatSettings.DecimalSeparator;
try
FormatSettings.DecimalSeparator:='.';
Result:=FormatFloat(FlPtFormat,Longitude);
finally
FormatSettings.DecimalSeparator:=ds;
end;
end;

procedure TFloatPoint.FillFromSelfXML(const aXML : string);
begin
Latitude:=StrToFloat(StringReplace(GetTagData(aXML,'LAT'),'.',FormatSettings.DecimalSeparator,[]));
Longitude:=StrToFloat(StringReplace(GetTagData(aXML,'LNG'),'.',FormatSettings.DecimalSeparator,[]));
end;

procedure TFloatPoint.SetLongitudeFromDMS(aDegree,aMinutes,aSeconds : integer);
var
 IsNeg : boolean;
begin
IsNeg:=aDegree<0;
if IsNeg
   then Longitude:=Abs(aDegree)-(aMinutes/60+aSeconds/3600)
   else Longitude:=Abs(aDegree)+aMinutes/60+aSeconds/3600;
//Longitude:=Abs(aDegree)+aMinutes/60+aSeconds/3600;
if IsNeg then Longitude:=Longitude*-1;
end;

procedure TFloatPoint.SetLatitudeFromDMS(aDegree,aMinutes,aSeconds : integer);
var
 IsNeg : boolean;
begin
IsNeg:=aDegree<0;
if IsNeg
   then Latitude:=Abs(aDegree)-(aMinutes/60+aSeconds/3600)
   else Latitude:=Abs(aDegree)+aMinutes/60+aSeconds/3600;
if IsNeg then Latitude:=Latitude*-1;
end;

function TFloatPoint.GetLatLon : string;
begin
Result:=LatitudeForRequest+','+LongitudeForRequest;
end;

function TFloatPoint.GetLatLon(aRound : TFloatPointRound) : string;
var
 ds : char;
 sh : string;
begin
ds:=FormatSettings.DecimalSeparator;
try
FormatSettings.DecimalSeparator:='.';
sh:='0.'+Replicate('0',aRound);
Result:='vert: '+FormatFloat(sh,Latitude)+', '+'horz: '+FormatFloat(sh,Longitude)
finally
FormatSettings.DecimalSeparator:=ds;
end;
end;

function TFloatPoint.GetLonLatIntoDMS : string;
begin
Result:=GetLongitudeIntoDMS+' '+GetLatitudeIntoDMS;
end;

function TFloatPoint.getJSObject : string;
begin
Result:=Format('{lat:%17.14f'+DaggerChar+'lng:%17.14f}',[Latitude,Longitude]);
Result:=StringReplace(Result,FormatSettings.DecimalSeparator,'.',[rfReplaceAll]);
Result:=StringReplace(Result,DaggerChar,',',[rfReplaceAll]);
end;


class function TFloatPoint.Get(aLatitude,aLongitude : double) : TFloatPoint;
begin
Result.Latitude:=aLatitude;
Result.Longitude:=aLongitude;
end;


class procedure TFloatRect.FillBorders(const aPts : array of TFloatPoint; var aRes : TFloatRect);
var
 cnt : integer;
begin
with aRes do
  begin
  Left  :=  180;
  Top   :=  -90;
  Bottom:=   90;
  Right := -180;
  end;
for cnt:=0 to High(aPts)
  do begin
  if aRes.Left>aPts[cnt].Longitude
     then aRes.Left:=aPts[cnt].Longitude
     else
  if aRes.Right<aPts[cnt].Longitude
     then aRes.Right:=aPts[cnt].Longitude;

  if aRes.Top<aPts[cnt].Latitude
     then aRes.Top:=aPts[cnt].Latitude
     else
  if aRes.Bottom>aPts[cnt].Latitude
     then aRes.Bottom:=aPts[cnt].Latitude;
  end;
end;


(******************************************************************************)

function TAreaItem.GetXML : string;
const
// -- ВНИМАНИЕ! Здесь важно сохранять позицию каждого элемента -------------
 Shablon = '<AREA USER="%s" APP="AREAEDITOR">'+crlf+
           ' <RECORDSTATE>%d</RECORDSTATE>'+crlf+
           ' <ID>%d</ID>'+crlf+
           ' <PARENTID>%d</PARENTID>'+crlf+
           ' <NAME>%s</NAME>'+crlf+
           ' <LEVEL>%d</LEVEL>'+crlf+
           ' <RGBLINE>%s</RGBLINE>'+crlf+
           ' <RGBFILL>%s</RGBFILL>'+crlf+
           ' <ROUTENUM>%d</ROUTENUM>'
           //--20170525--+crlf+' <DAYS>%s</DAYS>'
           ;
var
 cnt : integer;
begin
//--20170525-- if trim(string(aDays))='' then aDays:='1111111';
Result:=Format(Shablon,[AppParams.UserName,0,aID,aParentID,aName,aLevel,aRGBLine,aRGBFill,aRouteNum
//--20170525--,aDays
])+crlf;
for cnt:=0 to High(LatLng)
 do Result:=Result+LatLng[cnt].GetXML;
Result:=Result+crlf+'</AREA>';
end;


function TAreaItem.LoadFromXML(const aXML : string; aPrevVersion : boolean = false) : boolean;
const
  BaseTag : array[boolean] of string = ('AREA', 'AREA_PREV') ;
var
 tmp        : string;
 XMLBody    : string;
 XML        : TXMLDocument;
 SetTag     : IDOMNode;
 ValueTag   : IDOMNode;
 AreaTag    : IDOMNode;
 LatLngTag  : IDOMNode;
 LatLngInd  : integer;
 ds         : char;
 errFile    : string;
 tagOpen    : string;
 tagClose   : string;
 posA       : integer;
 posB       : integer;
begin
//SetLength(LatLng,0);
//FillChar(self,SizeOf(TAreaItem),0);
Clear;
Result:=False;
XMLBody:='';
try
XMLBody:=aXML;
if XMLBody='' then Exit;

tagOpen:=Format('<%s',[BaseTag[aPrevVersion]]);
tagClose:=Format('</%s>',[BaseTag[aPrevVersion]]);
posA:=Pos(tagOpen,XMLBody);
posB:=Pos(tagClose,XMLBody);
if posB=0
   then posB:=Length(XMLBody)
   else posB:=posB+Length(tagClose);
XMLBody:=Copy(XMLBody,posA,posB-posA);
//CopyStringIntoClipboard(XMLBody);

CoInitialize(nil);
XML:=TXMLDocument.Create(nil);
try

XML.LoadFromXML(XMLBody);
SetTag:=XML.DOMDocument.firstChild;
while Assigned(SetTag) and (SetTag.localName<>BaseTag[aPrevVersion])
   do SetTag:=SetTag.nextSibling;
   while Assigned(SetTag) do
     begin
     if SetTag.localName=BaseTag[aPrevVersion]
        then begin
        AreaTag:=SetTag.firstChild;
        while Assigned(AreaTag)
         do begin
         ValueTag:=AreaTag.firstChild;
         if Assigned(ValueTag)
            then tmp:=ValueTag.nodeValue
            else tmp:='';
         with self do
           begin
           //if AreaTag.localName='ISEDITING'   then if tmp<>'' then aIsEditing:=(StrToInt(tmp)>0) else (*0*)             else
           if AreaTag.localName='ID'
              then begin
              if tmp<>'' then aID:=StrToInt(tmp) else (*0*)
              end
              else
           if AreaTag.localName='SESSIONID'   then if tmp<>'' then aSessionID:=shortstring(tmp) else (*'index_xxxx'*) else
           if AreaTag.localName='RECORDSTATE' then if tmp<>'' then aRecordState:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='LEVEL'       then if tmp<>'' then aLevel:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='PARENTID'    then if tmp<>'' then aParentID:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='NAME'        then aName:=shortstring(tmp) else
           if AreaTag.localName='RGBLINE'     then aRGBLine:=shortstring(tmp)else
           if AreaTag.localName='RGBFILL'     then aRGBFill:=shortstring(tmp) else
           if AreaTag.localName='ROUTENUM'    then if tmp<>'' then aRouteNum:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='GEOTYPE'     then if tmp<>'' then aGeoType:=shortstring(tmp) else (*0*) else
           if AreaTag.localName='GEONUM'      then if tmp<>'' then aGeoNum:=StrToIntDef(tmp,1) else (*0*)
                                     else
           //--20170525--if AreaTag.localName='DAYS'        then if tmp<>'' then aDays:=shortstring(tmp) else aDays:='0000000'          else
           if AreaTag.localName='LATLNG'
              then begin
              ds:=FormatSettings.DecimalSeparator;
              try
              FormatSettings.DecimalSeparator:='.';
              LatLngInd:=Length(LatLng);
              SetLength(LatLng,LatLngInd+1);
              LatLngTag:=AreaTag.firstChild;
              while Assigned(LatLngTag) do
                begin
                if LatLngTag.localName='LAT'
                   then begin
                   tmp:=LatLngTag.firstChild.nodeValue;
                   if tmp<>'' then LatLng[LatLngInd].Latitude:=StrToFloat(tmp);
                   end
                   else
                if LatLngTag.localName='LNG'
                   then begin
                   tmp:=LatLngTag.firstChild.nodeValue;
                   if tmp<>'' then  LatLng[LatLngInd].Longitude:=StrToFloat(tmp);
                   end;
                LatLngTag:=LatLngTag.nextSibling;
                end;
              finally
              FormatSettings.DecimalSeparator:=ds;
              end;
              end;
          end;
         AreaTag:=AreaTag.nextSibling;
         end;
        end
        else ;
     SetTag:=SetTag.nextSibling;
     end;

finally
FreeAndNil(XML);
CoUnInitialize;
end;
Result:=true;

except
on E : Exception do
   begin
   errFile:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'ErrXML\';
   if not ForceDirectories(errFile) then errFile:=SetTailBackSlash(GetTempFolder);
   errFile:=errFile+'onearea_'+FormatdateTime('yyyymmdd_hhnnss',now)+'.xml';
   SaveStringIntoFile(XMLBody,errFile);
   LogErrorMessage('TAreaItem.LoadFromXML',E,[errFile]);
   end;
end;
end;





procedure TAreaItem.LoadFromSource(const aSrcItem : TAreaItem);
var
 ln : integer;
begin
SetLength(LatLng,0);
FillChar(self,SizeOf(TAreaItem),0);
self.aID         := aSrcItem.aID         ;
self.aParentID   := aSrcItem.aParentID   ;
self.aLevel      := aSrcItem.aLevel      ;
// aRecordState --- not set here
self.aSessionID:=aSrcItem.aSessionID;
self.aName       := aSrcItem.aName       ;
self.aRGBLine    := aSrcItem.aRGBLine    ;
self.aRGBFill    := aSrcItem.aRGBFill    ;
self.aRouteNum   := aSrcItem.aRouteNum   ;
self.aGeoType    := aSrcItem.aGeoType;
self.aGeoNum     := aSrcItem.aGeoNum ;
ln:=Length(aSrcItem.LatLng) ;
SetLength(self.LatLng,ln);
if ln>0 then System.move(aSrcItem.LatLng[0],self.LatLng[0],ln*SizeOf(TFloatPoint));
end;



//--20170525--
//function TAreaItem.getStrObject : string;
//var
// cnt    : integer;
// points : string;
//begin
//points:='';
//for cnt := 0 to High(LatLng) do points := points + LatLng[cnt].GetLatLon + ';';
//points := Copy(points, 1, Length(points)- 1);
//// -- ВНИМАНИЕ! Здесь важно сохранять позицию каждого элемента -------------
//Result := points +                                                  //aPath
//      GroupDelimiter+'#' + string(aRGBLine)+                  //aBorderColor
//      GroupDelimiter+'#' + string(aRGBFill)+                  //aFillColor
//      GroupDelimiter+''  + StringToJavaUTF8Ex(string(aName))+ //aShortDescr
//      GroupDelimiter+''  + '' +                               //aFullDescr
//      GroupDelimiter+''  + IntToStr(aID)+                     //aID
//      GroupDelimiter+''  + IntToStr(0)+                       //aRecordState
//      GroupDelimiter+''  + IntToStr(aParentID)+               //aParentID
//      GroupDelimiter+''  + '' +                               //aName
//      GroupDelimiter+''  + IntToStr(aLevel)+                  //aLevel
//      GroupDelimiter+''  + IntToStr(aRouteNum)+               //aRouteNum
//      //--20170525--GroupDelimiter+''  + string(aDays)+                     //aDays
//      GroupDelimiter+''  + string('0000000')+                     //aDays
//      GroupDelimiter+''  + string(aSessionID)                 //aSessionID (*ATTENTION*) (*NEW*)
//      ;
//end;

function TAreaItem.getJSObject : string;
const
 Shablon : string =
'{'+
'id:%d'+
',parentid:%d'+
',level:%d'+
',name:%s'+
',rgbline:%s'+
',rgbfill:%s'+
',routenum:%d'+
//--20170525--',days:%s'+
',latlngarr:%s'+
',sessionid:%s'+'}';
var
 ll  : string;
 cnt : integer;
//--20170525-- tmpDays : string;
begin
ll:='';
for cnt:=0 to High(LatLng)
  do ll:=ll+LatLng[cnt].getJSObject+ArrayDelimiter;
ll:='['+Copy(ll,1,Length(ll)-Length(ArrayDelimiter))+']';
//--20170525--tmpDays:=Copy(string(aDays)+'0000000',1,7);
Result:=Format(Shablon,[aID
                       ,aParentID
                       ,aLevel
                       ,AnsiQuotedStr(StringToJavaUTF8Ex(string(aName)),'"')
                       ,AnsiQuotedStr(StringToJavaUTF8Ex(string(aRGBLine)),'"')
                       ,AnsiQuotedStr(StringToJavaUTF8Ex(string(aRGBFill)),'"')
                       ,aRouteNum
                       //--20170525--,AnsiQuotedStr(tmpDays,'"')
                       ,ll
                       ,AnsiQuotedStr(StringToJavaUTF8Ex(string(aSessionID)),'"')
                       ]);
end;


function TAreaItem.SaveIntoDB : integer;
var
 ADOSP : TADOStoredProc;
 XML   : string;
begin
Result:=0;
try
XML:=GetXML;
ADOSP:=TADOStoredProc.Create(nil);
try
with ADOSP do
  begin
  ConnectionString:=DBConnString;
  ProcedureName:='map_SaveOneArea;1';
  if not Parameters.Refresh
     then begin
     CopyStringIntoClipboard(XML);
     ShowMessageWarning('По какой-то причине не удалось получить список параметров процедуры сохранения областей в БД.'+crlf+'Сохранение областей остановлено.'+crlf+'Описание областей в формате XML скопировано в буфер обмена.','Внимание!');
     Exit;
     end;
  Parameters.ParamByName('@xmltext').Value:=XML;
  Prepared:=True;
  ExecProc;
  Result:=integer(Parameters[0].Value);
  end;
finally
FreeAndNil(ADOSP);
end;
except
on E : Exception do LogErrorMessage('TAreaItem.SaveIntoDB',E,[aID,getConnStrForErrorMessage]);
end;
end;




procedure TAreaItem.Clear;
begin
Setlength(LatLng,0);
FillChar(self,SizeOf(TAreaItem),0);
self.aLevel:=-1;
end;

(******************************************************************************)

function TAreaList.LoadFromDB(const aXMLFilter : string = '') : boolean;
var
 ADOSP   : TADOStoredProc;
 XMLBody : string;
begin
ShowSplash('Обновление списка областей (этап 1/2)', stInfo);
Result:=False;
try
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='map_GetAreasFullList_20181022';  (*DELETED AREAS*)
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
if aXMLFilter<>''
   then ADOSP.Parameters.ParamByName('@xmltext').Value:=aXMLFilter;
ADOSP.Active:=True;
XMLBody:=XMLTitleWIN1251+crlf+IfThen(ADOSP.Fields[0].AsString<>'',ADOSP.Fields[0].AsString,'<AREASET></AREASET>');
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
ShowSplash('Обновление списка областей (этап 2/2)', stInfo);
if XMLBody<>''
   then Result:=LoadFromXML(XMLBody)
   else Clear;
als:=alsNone;
except
on E : Exception do LogErrorMessage('TAreaList.LoadFromDB',E,[getConnStrForErrorMessage]);
end;
end;

function TAreaList.LoadFromXML(const aXML : string) : boolean;
var
 tmp        : string;
 XMLBody    : string;
 XML        : TXMLDocument;
 SetTag     : IDOMNode;
 ValueTag   : IDOMNode;
 AreaTag    : IDOMNode;
 LatLngTag  : IDOMNode;
 LatLngInd  : integer;
 ind        : integer;
 ds         : char;
 errFile    : string;
begin     (*DELETED AREAS*)
Result:=False;
Clear;
XMLBody:='';
try
if Pos('<',aXML)<>0
   then XMLBody:=aXML
   else
if FileExists(aXML)
   then XMLBody:=LoadStringFromFile(aXML);

if XMLBody=''
   then XMLBody:=LoadStringFromURL(aXML);

except
end;
if XMLBody='' then Exit;
CoInitialize(nil);
XML:=TXMLDocument.Create(nil);
try
try
XML.LoadFromXML(XMLBody);
SetTag:=XML.DOMDocument.firstChild;
while Assigned(SetTag) and (SetTag.localName<>'AREASET')
   do SetTag:=SetTag.nextSibling;
if not Assigned(SetTag) then Exit;
if Assigned(SetTag) and (SetTag.localName = 'AREASET')
   then begin
   SetTag:=SetTag.firstChild;
   while Assigned(SetTag) do
     begin
     if SetTag.localName='AREA'
        then begin
        ind:=Length(Items);
        SetLength(Items,ind+1);
        AreaTag:=SetTag.firstChild;
        while Assigned(AreaTag)
         do begin
         ValueTag:=AreaTag.firstChild;
         if Assigned(ValueTag)
            then tmp:=ValueTag.nodeValue
            else tmp:='';
         with Items[ind] do
           begin
           if AreaTag.localName='ID'          then if tmp<>'' then aID:=StrToInt(tmp) else (*0*)                        else
           if AreaTag.localName='SESSIONID'   then if tmp<>'' then aSessionID:=shortstring(tmp) else (*'index_xxx'*)    else
           if AreaTag.localName='RECORDSTATE' then if tmp<>'' then aRecordState:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='LEVEL'       then if tmp<>'' then aLevel:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='PARENTID'    then if tmp<>'' then aParentID:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='NAME'        then aName    := shortstring(tmp) else
           if AreaTag.localName='RGBLINE'     then aRGBLine := shortstring(tmp) else
           if AreaTag.localName='RGBFILL'     then aRGBFill := shortstring(tmp) else
           if AreaTag.localName='ROUTENUM'    then if tmp<>'' then aRouteNum:=StrToInt(tmp) else (*0*) else
           if AreaTag.localName='GEOTYPE'     then if tmp<>'' then aGeoType:=shortstring(tmp) else (*0*) else
           if AreaTag.localName='GEONUM'      then if tmp<>'' then aGeoNum:=StrToIntDef(tmp,1) (*0*) else

                            else
           //--20170525--if AreaTag.localName='DAYS'        then if tmp<>'' then aDays:=shortstring(tmp) else aDays:='0000000'          else
           if AreaTag.localName='LATLNG'
              then begin
              ds:=FormatSettings.DecimalSeparator;
              try
              FormatSettings.DecimalSeparator:='.';
              LatLngInd:=Length(LatLng);
              SetLength(LatLng,LatLngInd+1);
              LatLngTag:=AreaTag.firstChild;
              while Assigned(LatLngTag) do
                begin
                if LatLngTag.localName='LAT'
                   then begin
                   tmp:=LatLngTag.firstChild.nodeValue;
                   if tmp<>'' then LatLng[LatLngInd].Latitude:=StrToFloat(tmp);
                   end
                   else
                if LatLngTag.localName='LNG'
                   then begin
                   tmp:=LatLngTag.firstChild.nodeValue;
                   if tmp<>'' then  LatLng[LatLngInd].Longitude:=StrToFloat(tmp);
                   end;
                LatLngTag:=LatLngTag.nextSibling;
                end;
              finally
              FormatSettings.DecimalSeparator:=ds;
              end;
              end;
          end;
         AreaTag:=AreaTag.nextSibling;
         end;
        end
        else ;
     SetTag:=SetTag.nextSibling;
     end;
   end;
finally
FreeAndNil(XML);
CoUnInitialize;
end;
Result:=true;
except
on E : Exception do
   begin
   errFile:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'ErrXML\';
   if not ForceDirectories(errFile) then errFile:=SetTailBackSlash(GetTempFolder);
   errFile:=errFile+'areas_'+FormatdateTime('yyyymmdd_hhnnss',now)+'.xml';
   SaveStringIntoFile(XMLBody,errFile);
   LogErrorMessage('LoadAreasFromXMLFile',E,[errFile]);
   end;
end;
end;


function TAreaList.SaveIntoDB : boolean;
begin
Result:=false;
try
 (*ATTENTION*)
Result:=True;
except
on E : Exception do LogErrorMessage('TAreaList.LoadFromDB',E,[getConnStrForErrorMessage]);
end;
end;

//--20170525--
//function TAreaList.getStrObject(const aIDs : array of integer) : string;
//var
// cnt : integer;
// IDs : array of integer;
//begin
//Result:='';
//if Length(aIDs)=0
//   then begin
//   Setlength(IDs,Length(Items));
//   for cnt:=0 to High(Items)
//     do IDs[cnt]:=Items[cnt].aID;
//   end
//   else begin
//   Setlength(IDs,Length(aIDs));
//   System.Move(aIDs[0],IDs[0],Length(IDs)*SizeOf(integer));
//   end;
//
//(*DELETED AREAS*)
//for cnt:=0 to High(Items)
//  do if InnerBool(Items[cnt].aID, IDs)
//        then Result:=Result+Items[cnt].getStrObject+AreaDelimiter;
//Result:=Copy(Result,1,Length(Result)-Length(AreaDelimiter));
//end;


function TAreaList.getJSObject(const aIDs : array of integer) : string;
var
 cnt : integer;
 IDs : array of integer;
begin
Result:='';
if Length(aIDs)=0
   then begin
   Setlength(IDs,Length(Items));
   for cnt:=0 to High(Items)
     do IDs[cnt]:=Items[cnt].aID;
   end
   else begin
   Setlength(IDs,Length(aIDs));
   System.Move(aIDs[0],IDs[0],Length(IDs)*SizeOf(integer));
   end;
(*DELETED AREAS*)
for cnt:=0 to High(Items)
  do if InnerBool(Items[cnt].aID, IDs)
        then Result:=Result+Items[cnt].getJSObject+',';
Result:='['+Copy(Result,1,Length(Result)-1)+']';
end;

procedure TAreaList.DeleteAreaFromAreaList(aDelIndex : integer; aMarkOnly : boolean);
var
 cnt : integer;
begin
if (aDelIndex<Low(Items)) or (aDelIndex>High(Items)) then Exit;
if aDelIndex<High(Items)
   then begin
   for cnt:=aDelIndex+1 to High(Items)
      do begin
      Items[cnt-1].LoadFromSource(Items[cnt]);
(*20170811*)
//      Items[cnt-1].aID         :=  Items[cnt].aID        ;
//      Items[cnt-1].aParentID   :=  Items[cnt].aParentID  ;
//      Items[cnt-1].aName       :=  Items[cnt].aName      ;
//      Items[cnt-1].aRGBLine    :=  Items[cnt].aRGBLine   ;
//      Items[cnt-1].aRGBFill    :=  Items[cnt].aRGBFill   ;
//      Setlength(Items[cnt-1].LatLng,Length(Items[cnt].LatLng));
//      System.Move((@Items[cnt].LatLng[0])^,(@Items[cnt-1].LatLng[0])^,Length(Items[cnt].LatLng)*SizeOf(TFloatPoint));
      end;
   end;
SetLength(Items,Length(Items)-1);
end;

function TAreaList.GetAreaDataById(aAreaID : integer; var aAreaName : string;var aRouteNum : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
aAreaName:='';
aRouteNum:=0;
for cnt:=0 to High(Items)
  do if Items[cnt].aID = aAreaID
        then begin
        Result:=cnt;
        aAreaName:=string(Items[cnt].aName);
        aRouteNum:=Items[cnt].aRouteNum;
        Break;
        end;
except
on E : Exception do LogErrorMessage('TAreaList.GetAreaDataById',E,[aAreaID]);
end;
end;


function TAreaList.FillItem(const aSrc : TAreaItem) : integer;
var
 ind   : integer;
 _name : string;
 _rn   : integer;
begin
ind:=-2;
Result:=ind;
try
ind:=GetAreaDataById(aSrc.aID,_name,_rn);
if ind=-1
   then begin
   ind:=Length(Items);
   SetLength(Items,ind+1);
   end;
Items[ind].LoadFromSource(aSrc);
Result:=ind;
except
on E : Exception do LogErrorMessage('TAreaList.FillItem',E,[ind]);
end;
end;


procedure TAreaList.Arrange(mode : TAreaListSort);
var
 strl : TStringList;
 cnt  : integer;
 tmp  : array of TAreaItem;
// hg   : integer;
 step : string;
begin
try
step:='List.Create';
strl:=TStringList.Create;
try
step:='List.Fill';
 case mode of
  alsID        : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',Items[cnt].aID),TObject(@Items[cnt]));
  alsName      : for cnt:=0 to High(Items) do strl.AddObject(ansilowercase(string(Items[cnt].aName)),TObject(@Items[cnt]));
 end;
step:='List.Sort';
strl.Sort;
SetLength(tmp,strl.Count);
//hg:=high(tmp);
step:='TempList.Fill';
//if aDesc
//   then for cnt:=0 to strl.Count-1 do tmp[hg-cnt].LoadFromSource(PNeedCarItem(strl.Objects[cnt])^)
//   else for cnt:=0 to strl.Count-1 do tmp[cnt].LoadFromSource(PNeedCarItem(strl.Objects[cnt])^);
for cnt:=0 to strl.Count-1 do tmp[cnt].LoadFromSource(PAreaItem(strl.Objects[cnt])^);
step:='Main.Size';
SetLength(Items,0);
SetLength(Items,Length(tmp));
step:='MainList.Fill';
for cnt:=0 to High(tmp) do Items[cnt].LoadFromSource(tmp[cnt]);
als:=mode;
finally
FreeStringList(strl);
end;
except
on E : Exception do LogErrorMessage('TAreaList.Arrange',E,[step]);
end;
end;


function TAreaList.GetIndexByID(aAreaID : integer) : integer;
var
 cnt : integer;
 ind : integer;
begin
Result:=-1;
ind:=-2;
try
for cnt:=0 to High(Items)
  do begin
  ind:=cnt;
  if aAreaID = Items[cnt].aID
     then begin
     Result:=cnt;
     Exit;
     end;
  end;

except
on E : Exception do LogErrorMessage('TAreaList.GetIndexByID',E,[aAreaID,ind, High(Items)]);
end;
end;


function TAreaList.GetRegion(const aIDs : array of integer; var aRegion : TFloatRect) : string;
var
 cnt : integer;
 ind : integer;
 len : integer;
 ll  : array of TFloatPoint;
begin
Result:='[]';
FillChar(aRegion,0,SizeOf(TFloatRect));
try
SetLength(ll,0);
for cnt:=0 to High(aIDs)
  do begin
  ind:=GetIndexByID(aIDs[cnt]);
  if ind=-1 then Continue;
  len:=Length(ll);
  SetLength(ll,len+Length(Items[ind].LatLng));
  System.Move(Items[ind].LatLng[0],ll[len],SizeOf(TFloatPoint)*Length(Items[ind].LatLng));
  end;
TFloatRect.FillBorders(ll,aRegion);
Result:=
'['+
 TFloatPoint.Get(aRegion.Top,aRegion.Left).getJSObject+ArrayDelimiter+      // --Nord-West
 TFloatPoint.Get(aRegion.Top,aRegion.Right).getJSObject+ArrayDelimiter+     // --Nord-East
 TFloatPoint.Get(aRegion.Bottom,aRegion.Right).getJSObject+ArrayDelimiter+  // --South-East
 TFloatPoint.Get(aRegion.Bottom,aRegion.Left).getJSObject+                  // --South-West
']';
except
on E : Exception do LogErrorMessage('TAreaList.GetRegion',E,[]);
end;
end;


function TAreaList.getJSONForBound(const aIDs : array of integer) : string;
var
 cnt : integer;
 ind : integer;
 len : integer;
 ll  : array of TFloatPoint;
begin
try
SetLength(ll,0);
for cnt:=0 to High(aIDs)
  do begin
  ind:=GetIndexByID(aIDs[cnt]);
  if ind=-1 then Continue;
  len:=Length(ll);
  SetLength(ll,len+Length(Items[ind].LatLng));
  System.Move(Items[ind].LatLng[0],ll[len],SizeOf(TFloatPoint)*Length(Items[ind].LatLng));
  end;
Result:='';
for cnt:=0 to High(ll)
  do Result:=Result+ll[cnt].getJSObject+ArrayDelimiter;
Result:='['+Copy(Result,1,Length(Result)-Length(ArrayDelimiter))+']';
except
on E : Exception do LogErrorMessage('TAreaList.getJSONForBound',E,[]);
end;
end;

procedure TAreaList.ClearUnsaved;
var
 cnt : integer;
begin
for cnt:=High(Items) downto 0
  do if Items[cnt].aId=0
        then DeleteAreaFromAreaList(cnt,false);
end;


function TAreaList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
on E : Exception do LogErrorMessage('TAreaList.Clear',E,[]);
end;
end;

(******************************************************************************)

function TCarItem.LoadFromSource(const aCarItem : TCarItem) : boolean;
begin
Result:=false;
try
Clear;
Car_id:=aCarItem.Car_id;
StrCopy(PChar(@Car_Reg_Num[1]),PChar(@aCarItem.Car_Reg_Num[1]));
StrCopy(PChar(@Car_Model[1]),PChar(@aCarItem.Car_Model[1]));
Area_id:=aCarItem.Area_id;
StrCopy(PChar(@Area_Name[1]),PChar(@aCarItem.Area_Name[1]));
StrCopy(PChar(@Driver_FIO[1]),PChar(@aCarItem.Driver_FIO[1]));
if Assigned(aCarItem.NumPic) and (aCarItem.NumPic.Width>0)
   then begin
   NumPic:=TBitmap.Create;
   NumPic.Assign(aCarItem.NumPic);
   end;
_Points:=aCarItem._Points;
_Deliveries:=aCarItem._Deliveries;
_Return:=aCarItem._Return;
Result:=(aCarItem.Car_id=self.Car_id);
if Assigned(aCarItem.NumPic) and Assigned(self.NumPic)
   then Result:=Result and
        (aCarItem.NumPic.Width = self.NumPic.Width) and
        (aCarItem.NumPic.Height = self.NumPic.Height)
except
on E : Exception do LogErrorMessage('TCarsItem.LoadFromSource',E,[]);
end;
end;

procedure TCarItem.Clear;
begin
try
if (NumPic<>nil) then FreeAndNil(NumPic);
FillChar(Self,SizeOf(TCarItem),0);
except
  on E : Exception do LogErrorMessage('TCarsItem.Clear',E,[]);
end;
end;


(******************************************************************************)

procedure TCarList.Arrange(aMode : TCarListArrange; aDesc : boolean);
var
 strl : TStringList;
 cnt  : integer;
 tmp  : array of TCarItem;
 hg   : integer;
begin
clArr  := aMode;
clDesc := aDesc;
try
strl:=TStringList.Create;
try
case aMode of
claNone         : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',cnt),TObject(@Items[cnt]));
claCar_Model    : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(ArrayOfCharToString(Items[cnt].Car_Model)),TObject(@Items[cnt]));
claCar_Reg_Num  : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(ArrayOfCharToString(Items[cnt].Car_Reg_Num)),TObject(@Items[cnt]));
claDriver_FIO   : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(ArrayOfCharToString(Items[cnt].Driver_FIO)),TObject(@Items[cnt]));
claArea_Name    : for cnt:=0 to High(Items) do strl.AddObject(AreaNameForArrange(ArrayOfCharToString(Items[cnt].Area_name)),TObject(@Items[cnt]));
claOrders       : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000',Items[cnt]._Points)+FormatFloat('0000',Items[cnt]._Deliveries)+FormatFloat('0000',Items[cnt]._Return),TObject(@Items[cnt]));
end;
strl.Sort;
SetLength(tmp,strl.Count);
hg:=high(tmp);
if aDesc
   then for cnt:=0 to strl.Count-1 do tmp[hg-cnt].LoadFromSource(PCarItem(strl.Objects[cnt])^)
   else for cnt:=0 to strl.Count-1 do tmp[cnt].LoadFromSource(PCarItem(strl.Objects[cnt])^);
Clear;
SetLength(Items,Length(tmp));
for cnt:=0 to strl.Count-1 do Items[cnt].LoadFromSource(tmp[cnt]);
finally
for cnt:=0 to High(tmp) do tmp[cnt].NumPic.Free;
Setlength(tmp,0);
FreeStringList(strl);
end;
except
  on E : Exception do LogErrorMessage('TCarList.Arrange',E,[]);
end;
end;


function TCarList.Clear : boolean;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items)
 do if Assigned(Items[cnt].NumPic)
       then try Items[cnt].NumPic.Free; except end;
SetLength(Items,0);
Result:=true;
except
  on E : Exception do LogErrorMessage('TCarList.Clear',E,[]);
end;
end;

(******************************************************************************)

//

function TMarkerItem.getDescription : string;
const
    DescrShablon =
    '<html>'+
    '<meta content=\"text/html; charset=UTF-8\">'+
    '<body>'+
    '<table style=font-size:80%%>'+
    '<tr><td style=font-style:italic>Клиент</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Телефон</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Адрес</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Интервал</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Заказы</td><td>%s</td></tr>'+
    '</table>'+
    '</body></html>';
const
 div_clr : array[boolean] of string  = ('#FF0000','#004000');
// --  через if будет быстрее, но писать больше, да и не те объемы....
// div_ret  = '<div style=color:#FF0000>'  ;
// div_norm = '<div style=color:#008000>' ;
var
 af  : string;
 sda : TStringDynArray;
 cnt : integer;
begin
try
af:=AC2Str(AboutFull);
sda:=SplitString(af,';');
try
af:='';
for cnt:=0 to High(sda)
  do af:=af+'<div style=color:'+div_clr[Pos(')*',sda[cnt])=0]+'>'+trim(sda[cnt])+'</br></div>';
Result:=LatLng.LatitudeForRequest+FieldsDelimiter+
        LatLng.LongitudeForRequest+FieldsDelimiter+
        Format(DescrShablon,[StringToJavaUTF8Ex(AC2Str(Delivery_FIO))
                           (*HTML PHONES*)//, StringToJavaUTF8Ex(PrepareHTMLPhones(AC2Str(Phone)))
                           , StringToJavaUTF8Ex(AC2Str(Phone))
                           , StringToJavaUTF8Ex(AC2Str(Delivery_Addr))
                           , StringToJavaUTF8Ex(AC2Str(Interval))
                           , StringToJavaUTF8Ex(af)
                           ])+RecordsDelimiter;
finally
SetLength(sda,0);
end;
except
  on E : Exception do LogErrorMessage('TMarkerItem.getDescription',E,[]);
end;
end;


function TMarkerItem.getDescriptionObj : string;
const
    obj =
    '{lat:%s,lng:%s,descr:"%s"}' ;
    DescrShablon =
    '<html><body><table style=font-size:80%%>'+
    '<tr><td style=font-style:italic>Клиент</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Телефон</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Адрес</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Интервал</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Заказы</td><td>%s</td></tr>'+
    '</table></body></html>';
const
 div_clr : array[boolean] of string  = ('#FF0000','#004000');
// --  через if будет быстрее, но писать больше, да и не те объемы....
// div_ret  = '<div style=color:#FF0000>'  ;
// div_norm = '<div style=color:#008000>' ;
var
 af  : string;
 sda : TStringDynArray;
 cnt : integer;
begin
try
af:=AC2Str(AboutFull);
sda:=SplitString(af,';');
try
af:='';
for cnt:=0 to High(sda)
  do af:=af+'<div style=color:'+div_clr[Pos(')*',sda[cnt])=0]+'>'+trim(sda[cnt])+'</br></div>';
Result:=Format(obj,
        [
         LatLng.LatitudeForRequest
        ,LatLng.LongitudeForRequest
        ,Format(DescrShablon,[StringToJavaUTF8Ex(AC2Str(Delivery_FIO))
                           (*HTML PHONES*)//, StringToJavaUTF8Ex(PrepareHTMLPhones(AC2Str(Phone)))
                           , StringToJavaUTF8Ex(AC2Str(Phone))
                           , StringToJavaUTF8Ex(AC2Str(Delivery_Addr))
                           , StringToJavaUTF8Ex(AC2Str(Interval))
                           , StringToJavaUTF8Ex(af)
                           ])
        ]);
finally
SetLength(sda,0);
end;
except
  on E : Exception do LogErrorMessage('TMarkerItem.getDescription',E,[]);
end;
end;


(******************************************************************************)


procedure TMarkerList.CalculateForCar(aCarID : integer; out aPt, aDlv, aRet : integer); // -- считает точки, заказы и возвраты по AboutFull для машины
  function CalcSubStr(const aSubstr, aFullStr : string) : integer;
  var
   fs : string;
  begin
  fs:=StringReplace(aFullStr,aSubStr,#1,[rfReplaceAll]);
  Result:=Length(SplitString(fs,#1))-1;
  end;
var
 cnt : integer;
 AbF : string;
begin
try
aPt:=0;
aDlv:=0;
aRet:=0;
for cnt:=0 to High(Items)
  do if Items[cnt].Car_ID = aCarID
        then begin
        inc(aPt);
        AbF:=ArrayOfCharToString(Items[cnt].AboutFull)+';';
        aDlv:=aDlv+CalcSubStr(');', AbF);
        aRet:=aRet+CalcSubStr(')*;', AbF);
        end;
except
on E : Exception do LogErrorMessage('TMarkerList.CalculateForCar',E,[]);
end;
end;


function TMarkerList.MarkersForDisplay(aCarID : integer; out aMarkerList : TMarkerList) : boolean;
var
 cnt : integer;
 ind : integer;
begin
Result:=False;
try
aMarkerList.Clear;
for cnt:=0 to High(Items)
  do if Items[cnt].Car_ID = acarID
        then begin
        ind:=Length(aMarkerList.Items);
        Setlength(aMarkerList.Items, ind+1);
        System.Move(Items[cnt], aMarkerList.Items[ind], SizeOf(TMarkerItem));
        end;
Result:=Length(aMarkerList.Items)>0;
except
on E : Exception do LogErrorMessage('TMarkerList.MarkersForDisplay',E,[]);
end;
end;


function TMarkerList.getDescription : string;
var
 cnt : integer;
begin
Result:='';
try
for cnt:=0 to High(Items)
  do Result:=Result+Items[cnt].getDescription;
Result:=Copy(Result,1,Length(Result)-Length(RecordsDelimiter));
except
on E : Exception do LogErrorMessage('TMarkerList.getDescription',E,[]);
end;
end;

function TMarkerList.getDescriptionObj(aPack : boolean) : string;
var
 cnt : integer;
 pml : TPackedMarkerList;
begin
Result:='';
try
if aPack
   then begin
   try
   if pml.FillItems(Items)
      then Result:=pml.getDescriptionObj;
   finally
   pml.Clear;
   end;
   end
   else begin
   for cnt:=0 to High(Items)
      do Result:=Result+Items[cnt].getDescriptionObj+',';
   Result:='['+Copy(Result,1,Length(Result)-1)+']';
   end;
except
on E : Exception do LogErrorMessage('TMarkerList.getDescription',E,[]);
end;
end;


function TMarkerList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
on E : Exception do LogErrorMessage('TMarkerList.Clear',E,[]);
end;
end;

(******************************************************************************)

function  TPackedMarkerItem.IsIt(aLat,aLng : double) : boolean;
begin
Result:=false;
try
Result:=(LatLng.Latitude = aLat) and (LatLng.Longitude = aLng);
except
on E: Exception do LogErrorMessage('TPackedMarkerItem.IsIt',E,[]);
end;
end;

function TPackedMarkerItem.Add(aMI : TMarkerItem) : integer;
begin
Result:=-1;
try
Result:=Length(Markers.Items);
Setlength(Markers.Items,Result+1);
System.Move(aMI,Markers.Items[Result],SizeOf(TMarkerItem));
except
on E: Exception do LogErrorMessage('TPackedMarkerItem.Add',E,[]);
end;
end;

function TPackedMarkerItem.Clear : boolean;
begin
Result:=false;
try
Result:=Markers.Clear;
except
on E: Exception do LogErrorMessage('TPackedMarkerItem.Clear',E,[]);
end;
end;

(**************************************************************************************************)

function TPackedMarkerList.Getindex(aLat,aLng : double) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to high(Items)
  do if (Items[cnt].LatLng.Latitude = aLat) and
        (Items[cnt].LatLng.Longitude = aLng)
        then begin
        Result:=cnt;
        Exit;
        end;
except
on E: Exception do LogErrorMessage('TPackedMarkerList.Getindex',E,[]);
end;
end;

function TPackedMarkerList.AddItem(const aMI : TMarkerItem) : integer;
var
 ind   : integer;
begin
Result:=-2;
try
with aMI.LatLng do Result:=GetIndex(Latitude,Longitude);
if Result=-1
   then begin
   Result:=Length(Items);
   SetLength(Items,Result+1);
   System.Move(aMI.LatLng,Items[Result].LatLng,SizeOf(TFloatPoint));
   end;
ind:=Length(Items[Result].Markers.Items);
SetLength(Items[Result].Markers.Items,ind+1);
System.Move(aMI, Items[Result].Markers.Items[ind], SizeOf(TMarkerItem));
except
on E: Exception do LogErrorMessage('',E,[]);
end;
end;

function TPackedMarkerList.FillItems(const aML : array of TMarkerItem) : boolean;
var
 cnt : integer;
begin
Result:=false;
try
Clear;
for cnt:=0 to High(aML)
  do AddItem(aML[cnt]);
Result:=Length(aML)>=Length(Items);
except
on E: Exception do LogErrorMessage('',E,[]);
end;
end;

function TPackedMarkerList.getDescriptionObj : string;
const
    obj =
    '{lat:%s,lng:%s,descr:"%s"}' ;
    MarkerShablon =
    '<div class=\"fi80red\">\u0422\u043E\u0447\u043A\u0430\u0020\u2116%d.%d</div>'+
    //'<html><body>'+
    '<table border=\"1\" rules=\"none\" style=\"font-size:80%%;border-color:#606060;border-style:dotted\">'+
    '<tr><td style=font-style:italic>Клиент</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Телефон</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Адрес</td><td>%s</td></tr>'+
    '<tr><td style=font-style:italic>Интервал</td><td>%s</td></tr>'+
    '<tr><td valign=\"middle\" style=font-style:italic>Заказы</td><td valign=\"middle\">%s</td></tr>'+
    '</table>'+
    //+'</body></html>'+
    '</br>';
    div_clr : array[boolean] of string  = ('#FF0000','#004000');
var
 cntC : integer;
 cntI : integer;
 af   : string;
 sda  : TStringDynArray;
 cnt  : integer;
 descr: string;
begin
try
Result:='';
for cntC:=0 to High(Items)
  do begin
  descr:='';
  for cntI:=0 to High(Items[cntC].Markers.Items)
    do begin
    af:=AC2Str(Items[cntC].Markers.Items[cntI].AboutFull);
    sda:=SplitString(af,';');
    try
    af:='';
    for cnt:=0 to High(sda)
       do af:=af+'<div style=color:'+div_clr[Pos(')*',sda[cnt])=0]+'>'+trim(sda[cnt])+'</div>';
    finally
    Setlength(sda,0);
    end;
    with Items[cntC].Markers.Items[cntI] do
    descr:=descr+Format(MarkerShablon,
      [cntC+1
      ,cntI+1
      ,StringToJavaUTF8Ex(AC2Str(Delivery_FIO))
      (*HTML PHONES*)//, StringToJavaUTF8Ex(PrepareHTMLPhones(AC2Str(Phone)))
      , StringToJavaUTF8Ex(AC2Str(Phone))
      , StringToJavaUTF8Ex(AC2Str(Delivery_Addr))
      , StringToJavaUTF8Ex(AC2Str(Interval))
      , StringToJavaUTF8Ex(af)
      ]);
    end;
  with Items[cntC].LatLng do Result:=Result+Format(obj,[LatitudeForRequest, LongitudeForRequest, descr])+',';
  end;
Result:='['+Copy(Result,1,length(Result)-1)+']';
except
on E: Exception do LogErrorMessage('',E,[]);
end;
end;


function TPackedMarkerList.Clear : boolean;
var
 cnt : integer;
begin
Result:=False;
try
for cnt:=0 to High(items) do Items[cnt].Clear;
Setlength(Items,0);
Result:=true;
except
on E: Exception do LogErrorMessage('TPackedMarkerList.Clear',E,[]);
end;
end;


(******************************************************************************)

// = record
//   ShemeName : array[1..128] of char;
//   DateBegin : TDate;
//   DateEnd   : TDate;
//   Intervals : array of THourInterval;
function TIntervalSchemeItem.LoadFromDB(const aName : string) : boolean;
begin
Result:=false;
try
(*ATTENTION*)
Result:=true;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.LoadFromDB',E,[]);
end;
end;


function TIntervalSchemeItem.LoadFromXML(const aFileOrBody : string) : boolean;
begin
Result:=false;
try
(*ATTENTION*)
Result:=true;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.LoadFromXML',E,[]);
end;
end;


function TIntervalSchemeItem.LoadFromSource(const aSrc : TIntervalSchemeItem) : boolean;
var
 ln  :integer;
begin
Result:=false;
try
Clear;
ln:=length(aSrc.Intervals);
SetLength(Intervals,ln);
if ln>0 then System.Move(aSrc.Intervals[0], Intervals[0], ln*SizeOf(THourInterval));
StrCopy(PChar(@SchemeName[1]), PChar(@aSrc.SchemeName[1]));
DateBegin  := aSrc.DateBegin;
DateEnd    := aSrc.DateEnd;
Result:=true;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.LoadFromSource',E,[]);
end;
end;


function TIntervalSchemeItem.SaveIntoDB : boolean;
begin
Result:=false;
try
(*ATTENTION*)
Result:=true;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.SaveIntoDB',E,[]);
end;
end;

function TIntervalSchemeItem.SaveIntoXML(const aFileName : string) : boolean;
var
 res_body      : string;
 intervals_str : string;
 cnt           : integer;
begin
Result:=false;
try
if Length(Intervals)=0 then Exit;
intervals_str:='';
for cnt:=0 to High(Intervals)
  do with Intervals[cnt] do intervals_str:=intervals_str+Format(#9'<INTERVAL BEGIN="%d" END="%d" DAY_BEGIN="%d" DAY_END="%d" />'+crlf,[HourBegin, HourEnd, DayBegin, DayEnd]);
res_body:=Format('<SCHEME NAME="%s" DATEBEGIN="%s" DATEEND="%s">'+crlf+'%s</SCHEME>',[NormalizeNameXML(AC2Str(SchemeName)), FormatDateTime('yyyymmdd', DateBegin), FormatDateTime('yyyymmdd', DateEnd),intervals_str]);
SaveStringIntoFile(res_body, aFileName );
Result:=true;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.SaveIntoXML',E,[aFileName]);
end;
end;



function TIntervalSchemeItem.FillDateIntervalList(aDateBegin,aDateEnd : TDate; aAreaId : integer; aAreaType : TAreaIntervalIdType; var aAIL : TAreaIntervalList) : boolean;
var
 cnt     : integer;
 dt      : TDate;
 srcDTL  : TDatesIntervalList;
 resDTL  : TDatesIntervalList;
 srcStrl : TStringList;
 ind     : integer;
 minDate : TDate; // минимальная дата периода
 maxDate : TDate; // максимальная дата периода
 opsDate : TDate; // дата разрешенная для начала изменения
 intDate : TDate; // минимальная дата периода интервалов (для получения чистого смещения даты и времени), а потом как базовая
 durDays : integer;
 begDate : TDateTime;
 endDate : TDateTime;
 perCount: integer;
begin
Result:=false;
try
dt:=trunc(aDateBegin);
SetLength(srcDTL,Length(Intervals));
try
// -- закодировали время с опорой на сегодня
intDate:=EncodeDate(2099,12,31);
for cnt:=0 to High(Intervals)
   do begin
   srcDTL[cnt].DateBegin:=dt+Intervals[cnt].DayBegin+EncodeTime(Intervals[cnt].HourBegin,0,0,0);
   if srcDTL[cnt].DateBegin<intDate then intDate:=srcDTL[cnt].DateBegin;
   srcDTL[cnt].DateEnd:=dt+Intervals[cnt].DayEnd+EncodeTime(Intervals[cnt].HourEnd,0,0,0);
   if srcDTL[cnt].DateEnd<intDate then intDate:=srcDTL[cnt].DateEnd;
   end;
intDate:=Trunc(intDate);
// -- упорядочили полученные интервалы
srcStrl:=TStringList.Create;
try
srcStrl.Sorted:=true;
for cnt:=0 to High(srcDTL)
  do srcStrl.AddObject(FormatDateTime('yyymmdd_hhnn',srcDTL[cnt].DateBegin)+'-'+FormatDateTime('yyymmdd_hhnn',srcDTL[cnt].DateEnd),TObject(cnt+1));
SetLength(resDTL,srcStrl.Count);
for cnt:=0 to srcStrl.Count-1
  do begin
  ind:=integer(srcStrl.Objects[cnt])-1;
  resDTL[cnt].DateBegin:=srcDTL[ind].DateBegin;
  resDTL[cnt].DateEnd:=srcDTL[ind].DateEnd;
  end;
finally
srcStrl.Free;
end;
minDate:=EncodeDate(2099,12,31);
maxDate:=EncodeDate(2000,1,1);
SetLength(srcDTL,Length(resDTL));
for cnt:=0 to High(resDTL)
  do begin
  srcDTL[cnt].DateBegin:= resDTL[cnt].DateBegin - intDate;
  srcDTL[cnt].DateEnd  := resDTL[cnt].DateEnd - intDate;
  begDate:=Trunc(resDTL[cnt].DateBegin);
  if begDate<minDate then minDate:=begDate;
  begDate:=Trunc(resDTL[cnt].DateEnd);
  if begDate>maxDate then maxDate:=begDate;
  end;
durDays:=Trunc(maxDate)-Trunc(minDate);
if durDays=0 then durDays:=1;
minDate:=Trunc(aDateBegin);
maxDate:=Trunc(aDateEnd);
opsDate:=Date+5;
endDate:=minDate;
Setlength(resDTL,0);
cnt:=-1;
perCount:=0;
repeat
if cnt>=High(srcDTL)
   then begin
   cnt:=0;
   inc(perCount);
   end
   else inc(cnt);
if (cnt>=Low(srcDTL)) and (cnt<=High(srcDTL))
   then begin
   begDate:=minDate+durDays*perCount+(srcDTL[cnt].DateBegin);
   endDate:=minDate+durDays*perCount+(srcDTL[cnt].DateEnd);
   ind:=Length(resDTL);
   SetLength(resDTL,ind+1);
   resDTL[ind].DateBegin:=begDate;
   resDTL[ind].DateEnd:=endDate;
   resDTL[ind].isOn:= (begDate>=opsDate) and (endDate<maxDate+1);
   end
   else Break;
until endDate>maxDate+1;
aAIL.Clear;
for cnt:=0 to High(resDTL)
  do begin
  if not resDTL[cnt].IsOn then Continue;
  ind:=Length(aAIL.Items);
  SetLength(aAIL.Items,ind+1);
  aAIL.Items[ind].aiID     := 0;
  aAIL.Items[ind].aiAreaID := aAreaID;
  aAIL.Items[ind].aiStart  := resDTL[cnt].DateBegin;
  aAIL.Items[ind].aiLen    := resDTL[cnt].DateEnd-resDTL[cnt].DateBegin;
  aAIL.Items[ind].aiIdType := aAreaType;
  end;
Result:=true;
finally
SetLength(resDTL,0);
SetLength(srcDTL,0);
end;
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.Clear',E,[]);
end;
end;


procedure TIntervalSchemeItem.Clear;
begin
try
SetLength(Intervals,0);
FillChar(self,SizeOf(TIntervalSchemeItem),0);
except
on E : Exception do LogErrorMessage('TIntervalSchemeItem.Clear',E,[]);
end;
end;


function TIntervalSchemeList.LoadFromXML(const aFileOrBody : string) : boolean;
   procedure FreeInterface(var aInt : IUnknown);
   var
    ref : integer;
   begin
   try
   if Assigned(aInt)
      then begin
      ref:=aInt._Release;
      while ref>=0 do ref:=aInt._Release;
      aInt:=nil;
      end;
   except
    on E : Exception do ;
   end;
   end;
 const
  SchemeListNode  = 'SCHEME_LIST';
  SchemeNode      = 'SCHEME';
  IntNode         = 'INTERVAL';
var
 XML : TXMLDocument;
 shNode   : IDOMNode;
 attr     : IDOMNamedNodeMap;
 intNodes : IDOMNodeList;
 cntN : integer;
 cntA : integer;
 indL : integer;
 indI : integer;
begin
Result:=false;
try
Clear;
CoInitialize(nil);
XML:=TXMLDocument.Create(nil);
try
if FileExists(aFileOrBody)
   then XML.LoadFromFile(aFileOrBody)
   else XML.LoadFromXML(aFileOrBody);
shNode:=XML.DOMDocument.firstChild;
while Assigned(shNode) and (shNode.localname<>SchemeNode)
   do begin
   shNode:=shNode.nextSibling;
   if shNode.localname=SchemeListNode
      then shNode:=shNode.firstChild;
   end;

if not Assigned(shNode) then Exit;
while Assigned(shNode) and (shNode.localname=SchemeNode)
  do begin
  indL:=Length(Intervals);
  Setlength(Intervals,indL+1);
  attr:=shNode.attributes;
  for cntA:=0 to attr.length-1
    do begin
    if attr.item[cntA].localName='NAME' then Str2AC(attr.item[cntA].nodeValue,Intervals[indL].SchemeName) else
    if attr.item[cntA].localName='DATEBEGIN' then Intervals[indL].DateBegin:=StrToDateTimeByFormat(attr.item[cntA].nodeValue,'yyyymmdd') else
    if attr.item[cntA].localName='DATEEND' then Intervals[indL].DateEnd:=StrToDateTimeByFormat(attr.item[cntA].nodeValue,'yyyymmdd')else ;
    end;
  FreeInterface(IUnknown(attr));
  intNodes:=shNode.childNodes;
  for cntN:=0 to intNodes.length-1
    do begin
    indI:=Length(Intervals[indL].Intervals);
    SetLength(Intervals[indL].Intervals, IndI+1);
    if intNodes.item[cntN].nodeName = IntNode
       then begin
       attr:=intNodes.item[cntN].attributes;
       for cntA:=0 to attr.length-1
         do begin
         if attr.item[cntA].localName='BEGIN'
            then Intervals[indL].Intervals[IndI].HourBegin:=byte(StrToIntDef(attr.item[cntA].nodeValue, defHourBegin)) else
         if attr.item[cntA].localName='END'
            then Intervals[indL].Intervals[IndI].HourEnd:=byte(StrToIntDef(attr.item[cntA].nodeValue, defHourEnd)) else
         if attr.item[cntA].localName='DAY_BEGIN'
            then Intervals[indL].Intervals[IndI].DayBegin:=byte(StrToIntDef(attr.item[cntA].nodeValue, 0)) else
         if attr.item[cntA].localName='DAY_END'
            then Intervals[indL].Intervals[IndI].DayEnd:=byte(StrToIntDef(attr.item[cntA].nodeValue, 0)) else
            ;

         end;
       end;
    end;
  FreeInterface(IUnknown(attr));
  shNode:=shNode.nextSibling;
  end;
Result:=true;
finally
FreeInterface(IUnknown(intNodes));
FreeInterface(IUnknown(shNode));
XML.Free;
CoUninitialize;
end;
except
end;
end;


procedure TIntervalSchemeList.Clear;
var
 cnt : integer;
begin
try
for cnt:=0 to High(Intervals) do Intervals[cnt].Clear;
SetLength(Intervals,0);
except
on E : Exception do LogErrorMessage('TIntervalSchemeList.Clear',E,[]);
end;
end;

(*************************************************************************************************************)

function TUsedAreaList.LoadFromDB(const aXMLFilter : string = '') : boolean;
var
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=False;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='ae_AreaUsed_Load';  (*DELETED AREAS*)
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=aXMLFilter;
ADOSP.Active:=True;
while not ADOSP.EoF do
  begin
  ind:=Length(Items);
  SetLength(Items, ind+1);
  with ADOSP,Items[ind] do
    begin
    Str2AC(Fields[0].AsString, Date_Interval);
    Str2AC(Fields[1].AsString, AreaName);
    Str2AC(Fields[2].AsString, AreaOwnerName);
    Next;
    end;
  end;
Result:=True;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
on E : Exception do LogErrorMessage('TUsedAreaList.LoadFromDB',E,[]);
end;
end;

procedure TUsedAreaList.GetMaxLengths(var aMaxArea, aMaxOwner : integer);
var
 cnt : integer;
 tmp : integer;
begin
aMaxArea:=0;
aMaxOwner:=0;
try
for cnt:=0 to High(Items)
  do begin
  tmp:=Length(AC2Str(Items[cnt].AreaName));
  if tmp>aMaxArea then aMaxArea:=tmp;
  tmp:=Length(AC2Str(Items[cnt].AreaOwnerName));
  if tmp>aMaxOwner then aMaxOwner:=tmp;
  end;
except
on E : Exception do LogErrorMessage('TUsedAreaList.GetMaxLengths',E,[]);
end;
end;


function TUsedAreaList.GroupBy(aVM : TUsedAreasViewMode) : string;
var
 mA, mO : integer;
 cnt    : integer;
 hgt    : integer;
 unique : TStringList;
 cntU   : integer;
 tmp    : string;
 sda    : TStringDynArray;
begin
Result:='';
try
GetMaxLengths(mA, mO);
hgt:=High(Items);
case aVM of
uavmList :
 begin
 for cnt:=0 to High(Items)
   do with Items[cnt]
       do Result:=Result+Format('%s %-*s %-*s',[AC2Str(Date_Interval),mA,AC2Str(AreaName),mO,AC2Str(AreaOwnerName)])+DupeString(crlf,integer(cnt<hgt));
 end;
else begin
unique := TStringList.Create;
try
unique.Sorted:=true;
unique.Duplicates:=dupIgnore;
  case aVM of
  uavmInterval :
    begin
    //for cnt:=0 to High(Items) do with Items[cnt] do unique.Add(AC2Str(Date_Interval));
    for cnt:=0 to High(Items) do // -- иначе на нескольких месяцах сбивается сортировка !!!!
       with Items[cnt] do
        begin
        sda:=SplitString(AC2Str(Date_Interval),' ');
        tmp:=FormatDateTime('yyyymmdd',StrToDateTimeByFormat(sda[0],'dd.mm.yyyy'))+' '+sda[1];
        unique.Add(tmp);
        end;
    for cntU:=0 to unique.Count-1
      do begin
      //Result:=Result+unique[cntU]+crlf;
      sda:=SplitString(unique[cntU],' ');
      tmp:=FormatDateTime('dd.mm.yyyy',StrToDateTimeByFormat(sda[0],'yyyymmdd'))+' '+sda[1];
      Result:=Result+tmp+crlf;
      for cnt:=0 to High(Items) do with Items[cnt] do
        if Ac2Str(Items[cnt].Date_Interval) = tmp
           then Result:=Result+Format(#9'%-*s %-*s',[mA,AC2Str(AreaName),mO,AC2Str(AreaOwnerName)])+crlf;
      end;
    end;
  uavmArea :
    begin
    for cnt:=0 to High(Items) do with Items[cnt] do unique.Add(AC2Str(AreaName));
    for cntU:=0 to unique.Count-1
      do begin
      Result:=Result+unique[cntU]+crlf;
      for cnt:=0 to High(Items) do with Items[cnt] do
         if Ac2Str(Items[cnt].AreaName) = unique[cntU]
            then Result:=Result+Format(#9'%s',[AC2Str(Date_Interval)])+crlf;
      end;
    end;
  uavmOwner :
    begin
    for cnt:=0 to High(Items) do with Items[cnt]
      do unique.Add(AC2Str(AreaOwnerName));
    for cntU:=0 to unique.Count-1
      do begin
      Result:=Result+unique[cntU]+crlf;
      for cnt:=0 to High(Items) do with Items[cnt] do
          if Ac2Str(Items[cnt].AreaOwnerName) = unique[cntU]
             then Result:=Result+Format(#9'%s %-*s',[AC2Str(Date_Interval),mA,AC2Str(AreaName)])+crlf;
      end;
    end;
  end;
finally
FreeStringList(unique);
end;
end;
end;
except
on E : Exception do LogErrorMessage('TUsedAreaList.GroupBy',E,[integer(aVM)]);
end;
end;


procedure TUsedAreaList.IntoExcel(const aTitle : string);
var
  aVarArray2D : variant;
  rows        : integer;
  sda         : TStringDynArray;
  dt          : TDateTime;
  str         : string;
begin
try
aVarArray2D:=VarArrayCreate([0,Length(Items)+1,0,5],varVariant);
aVarArray2D[0,0]:='Дата';
aVarArray2D[0,1]:='';
aVarArray2D[0,2]:='Интервал';
aVarArray2D[0,3]:='Область';
aVarArray2D[0,4]:='Область-владелец';
for rows:=0 to High(Items)
   do begin
   sda:=SplitString(Trim(AC2Str(Items[rows].Date_Interval)),'(');
   //aVarArray2D[rows+1, 0]:=''''+AC2Str(Items[rows].Date_Interval);
   if Length(sda)>0
      then begin
      sda[0]:=Trim(sda[0]);
      aVarArray2D[rows+1, 0]:=''''+sda[0];
      dt:=StrToDateTimeByFormat(sda[0],'dd.mm.yyyy');
      if dt>0
         then aVarArray2D[rows+1, 1]:=''''+dwShort[DayOfWeekRus(dt)]
         else  aVarArray2D[rows+1, 1]:=''''+dwShort[DayOfWeekRus(dt)]
      end;
   if Length(sda)>1
      then begin
      str:=Trim(sda[1]);
      aVarArray2D[rows+1, 2]:=''' '+Copy(str,1,Length(str)-1);   // StringReplace(Trim(sda[1]),')','',[]);
      end;
   aVarArray2D[rows+1, 3]:=''''+AC2Str(Items[rows].AreaName);
   aVarArray2D[rows+1, 4]:=''''+AC2Str(Items[rows].AreaOwnerName);
   end;
try
ArrayVariantToExcelEx(aTitle,aVarArray2D,1);
finally
if not VarIsEmpty(aVarArray2D) then VarArrayRedim(aVarArray2D,0);
aVarArray2D:=Unassigned;
end;
except
on E : Exception do LogErrorMessage('TUsedAreaList.IntoExcel',E,[]);
end;
end;


procedure TUsedAreaList.Clear;
begin
try
SetLength(Items,0);
except
on E : Exception do LogErrorMessage('TUsedAreaList.Clear',E,[]);
end;
end;
(*************************************************************************************************************)

function TNoDeliveryList.LoadFromDB(aBegin, aEnd : TDate) : boolean;
var
 ADOSP     : TADOStoredProc;
 ind       : integer;
 XMLFilter : string;
begin
Result:=False;
ShowSplash('Подготовка данных для отчета '+Format('(с %s по %s)',[FormatDateTime('dd.mm.yyyy',aBegin), FormatDateTime('dd.mm.yyyy',aEnd)]),stInfo);
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
FnCommon.LoadString(baseSection,'spNoDeliveryReport',spNoDeliveryReport, AppParams.CFGCommonFileName);
ADOSP.ProcedureName:=spNoDeliveryReport;
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
XMLFilter:=Format('<REQUEST BEGIN="%s" END="%s"/>',[FormatDateTime('yyyymmdd',aBegin), FormatDateTime('yyyymmdd',aEnd)]);
ADOSP.Parameters.ParamByName('@xmltext').Value:=XMLFilter;
ADOSP.Active:=True;
while not ADOSP.EoF do
  begin
  ind:=Length(Items);
  SetLength(Items, ind+1);
  with ADOSP,Items[ind] do
    begin
    ndiDate     := Fields[0].AsDateTime;              // -- Дата
    Str2AC(Fields[1].AsString, Oper);                 // -- Оператор
    Str2AC(Fields[2].AsString, OrderNT);              // -- № заказа и Тип заказа
    Str2AC(Fields[3].AsString, OrderState);           // -- Состояние заказа
    Str2AC(Fields[4].AsString, StateAdditionalCode);  // -- StateAdditionalCode
    OrderAmount := Fields[5].AsCurrency;              // -- Сумма заказа
    Str2AC(Fields[6].AsString, RouteName);            // -- Маршрут
    Str2AC(Fields[7].AsString, Driver);               // -- Водитель
    Str2AC(Fields[8].AsString, CarRegNum);            // -- Гос. номер
    if Fields.Count>=10
       then _RealDate:=Fields[9].AsDateTime;
    if Fields.Count>=11
       then IsFirstOrder:=Fields[10].AsBoolean;
    Next;
    end;
  end;
Result:=True;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
FreeSplash;
end;
except
on E : Exception do LogErrorMessage('TNoDeliveryList.LoadFromDB',E,[]);
end;
end;


function TNoDeliveryList.IntoExcel(const aTitle  :string) : boolean;
var
  aVarArray2D : variant;
  rows        : integer;
begin
Result:=False;
ShowSplash('Формирование отчета', stInfo);
try
aVarArray2D:=VarArrayCreate([0,Length(Items)+1,0,10],varVariant);
aVarArray2D[0,0]:='Дата';
aVarArray2D[0,1]:='Оператор';
aVarArray2D[0,2]:='№ заказа';
aVarArray2D[0,3]:='FTB';
aVarArray2D[0,4]:='Состояние';
aVarArray2D[0,5]:='StateAdditionalCode';
aVarArray2D[0,6]:='Сумма заказа';
aVarArray2D[0,7]:='Маршрут';
aVarArray2D[0,8]:='Водитель';
aVarArray2D[0,9]:='Гос. номер';
for rows:=0 to High(Items)
   do begin
   aVarArray2D[rows+1, 0]:=(*''''+*)FormatDateTime('dd.mm.yyyy',Items[rows].ndiDate);
   aVarArray2D[rows+1, 1]:=''''+AC2Str(Items[rows].Oper);// --
   aVarArray2D[rows+1, 2]:=''''+AC2Str(Items[rows].OrderNT);// --  и Тип заказа
   aVarArray2D[rows+1, 3]:=IfThen(Items[rows].IsFirstOrder,'Да','');
   aVarArray2D[rows+1, 4]:=''''+AC2Str(Items[rows].OrderState);// --  заказа
   aVarArray2D[rows+1, 5]:=''''+AC2Str(Items[rows].StateAdditionalCode);// --
   aVarArray2D[rows+1, 6]:=FormatFloat('0',Items[rows].OrderAmount);// --
   aVarArray2D[rows+1, 7]:=''''+AC2Str(Items[rows].RouteName);// --
   aVarArray2D[rows+1, 8]:=''''+AC2Str(Items[rows].Driver);// --
   aVarArray2D[rows+1, 9]:=''''+AC2Str(Items[rows].CarRegNum);// --
   end;
try
ArrayVariantToExcelEx(aTitle,aVarArray2D,1);
finally
if not VarIsEmpty(aVarArray2D) then VarArrayRedim(aVarArray2D,0);
aVarArray2D:=Unassigned;
FreeSplash;
end;
except
on E : Exception do LogErrorMessage('TNoDeliveryList.IntoExcel',E,[]);
end;
end;


function TNoDeliveryList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
on E : Exception do LogErrorMessage('TNoDeliveryList.Clear',E,[]);
end;
end;

(*************************************************************************************************************)

procedure TAreaLogItem.LoadFromSource(aALI : TAreaLogItem);
begin
try
Clear;
//StrCopy(PChar(@AreaName[1]), PChar(@aALI.AreaName[1]));
//StrCopy(PChar(@fullname[1]), PChar(@aALI.fullname[1]));
//StrCopy(PChar(@xml[1]), PChar(@aALI.xml[1]));
//StrCopy(PChar(@user[1]), PChar(@aALI.user[1]));
//StrCopy(PChar(@ws[1]), PChar(@aALI.ws[1]));
//DateEdit:=aALI.DateEdit;
//AreaID:=aALI.AreaID;
//id:=aALI.id;
System.Move(aALI,self,SizeOf(TAreaLogItem));
except
on E : Exception do LogErrorMessage('TAreaLogItem.LoadFromSource',E,[]);
end;
end;

procedure TAreaLogItem.Clear;
begin
try
FillChar(self, SizeOf(TAreaLogItem),0);
except
on E : Exception do LogErrorMessage('TAreaLogItem.Clear',E,[]);
end;
end;

(***************************************************************************************************)

function TAreaLogList.LoadFromDB(const aXMLFilter : string) : boolean;
var
 ADOSP     : TADOStoredProc;
 ind       : integer;
 tmp       : string;
begin
Result:=False;
ShowSplash('Получение изменений областей',stInfo);//+Format('(с %s по %s)',[FormatDateTime('dd.mm.yyyy',aBegin), FormatDateTime('dd.mm.yyyy',aEnd)]),stInfo);
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='ae_AreaLogList_Load';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=aXMLFilter;
ADOSP.Active:=True;
while not ADOSP.EoF do
  begin
  ind:=Length(Items);
  SetLength(Items, ind+1);
  with ADOSP,Items[ind] do
    begin
    id:=Fields[0].AsInteger;
    AreaID:=Fields[1].AsInteger;
    DateEdit:=Fields[2].AsdateTime;
    Str2AC(Fields[3].AsString,user);
    tmp:=getUserName(Fields[3].AsString);
    Str2AC(tmp,fullname);
    Str2AC(Fields[4].AsString,ws);
    Str2AC(Fields[5].AsString,AreaName);
    Str2AC(Fields[6].AsString,xml);
    Next;
    end;
  end;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
FreeSplash;
end;
if allArr<>allaNone then Arrange(allArr, allDesc);
Result:=True;
except
on E : Exception do LogErrorMessage('TAreaLogList.LoadFromDB',E,[]);
end;
end;

function TAreaLogList.IntoExcel(const aTitle  :string) : boolean;
var
  aVarArray2D : variant;
  rows        : integer;
begin
Result:=False;
ShowSplash('Формирование отчета', stInfo);
try
aVarArray2D:=VarArrayCreate([0,Length(Items)+1,0,4],varVariant);
aVarArray2D[0,0]:='Дата';
aVarArray2D[0,1]:='ID области';
aVarArray2D[0,2]:='Наименование области';
aVarArray2D[0,3]:='Пользователь';
aVarArray2D[0,4]:='Рабочая станция';
for rows:=0 to High(Items)
   do begin
   aVarArray2D[rows+1, 0]:=(*''''+*)FormatDateTime('dd.mm.yyyy hh:nn:ss',Items[rows].DateEdit);
   aVarArray2D[rows+1, 1]:=(*''''+*)FormatFloat('0',Items[rows].AreaID);
    aVarArray2D[rows+1,2]:=''''+AC2Str(Items[rows].AreaName);
   aVarArray2D[rows+1, 3]:=''''+AC2Str(Items[rows].user);
   aVarArray2D[rows+1, 4]:=''''+AC2Str(Items[rows].ws);
   end;
try
ArrayVariantToExcelEx(aTitle,aVarArray2D,1);
finally
if not VarIsEmpty(aVarArray2D) then VarArrayRedim(aVarArray2D,0);
aVarArray2D:=Unassigned;
FreeSplash;
end;
except
on E : Exception do LogErrorMessage('TAreaLogList.IntoExcel',E,[]);
end;
end;


function TAreaLogList.getUserName(const aNetName  :string)  :string;
var
 cnt  : integer;
 tst  : string;
begin
Result:='';
try
tst:=AnsiUpperCase(aNetName);
for cnt:=0 to High(Items)
  do if (AnsiUpperCase(AC2Str(Items[cnt].user)) = tst) and (Ac2Str(Items[cnt].fullname)<>'')
        then begin
        Result:=Ac2Str(Items[cnt].fullname);
        Break;
        end;
if Result=''
   then Result:=GetUserFullname(aNetName, true);
except
on E : Exception do LogErrorMessage('TAreaLogList.getUserName',E,[aNetName]);
end;
end;


procedure TAreaLogList.Arrange(aMode : TAreaLogListArrange; aDesc : boolean);
var
 strl : TStringList;
 cnt  : integer;
 tmp  : array of TAreaLogItem;
 hg   : integer;
begin
allArr  := aMode;
allDesc := aDesc;
try
strl:=TStringList.Create;
try
case aMode of
allaNone    : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',cnt),TObject(@Items[cnt]));
allaAreaID  : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',Items[cnt].AreaID),TObject(@Items[cnt]));
allaDateEdit: for cnt:=0 to High(Items) do strl.AddObject(FormatDateTime('yyyymmdd_hhnnss',Items[cnt].DateEdit),TObject(@Items[cnt]));
allaAreaName: for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].AreaName)),TObject(@Items[cnt]));
allaUser    : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].user)),TObject(@Items[cnt]));
allaFullName: for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].fullname)),TObject(@Items[cnt]));
allaWS      : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].WS)),TObject(@Items[cnt]));
allaID      : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',Items[cnt].ID),TObject(@Items[cnt]));
end;
strl.Sort;
SetLength(tmp,strl.Count);
hg:=high(tmp);
if aDesc
   then for cnt:=0 to strl.Count-1 do tmp[hg-cnt].LoadFromSource(PAreaLogItem(strl.Objects[cnt])^)
   else for cnt:=0 to strl.Count-1 do tmp[cnt].LoadFromSource(PAreaLogItem(strl.Objects[cnt])^);
Clear;
SetLength(Items,Length(tmp));
for cnt:=0 to strl.Count-1 do Items[cnt].LoadFromSource(tmp[cnt]);
finally
Setlength(tmp,0);
FreeStringList(strl);
end;
except
  on E : Exception do LogErrorMessage('TAreaLogList.Arrange',E,[integer(aMode)]);
end;
end;



function TAreaLogList.Clear : boolean;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items) do Items[cnt].Clear;
SetLength(Items,0);
Result:=True;
except
on E : Exception do LogErrorMessage('TAreaLogList.Clear',E,[]);
end;
end;

(*************************************************************************************************************)

function TForPointAreaList.Fill(aPoint : TFloatPoint; const aAreaList : TAreaList) : integer;
var
 cnt : integer;
 ind : integer;
begin
Result:=-1;
try
Clear;
Point.X:=aPoint.X;
Point.Y:=aPoint.Y;
for cnt:=0 to High(aAreaList.Items)
   do if PointInArea(aAreaList.Items[cnt].LatLng,Point)
         then begin
         ind:=Length(Items);
         Setlength(Items,ind+1);
         Items[ind].AreaId:=aAreaList.Items[cnt].aID;
         StrPCopy(@Items[ind].AreaName[1],string(aAreaList.Items[cnt].aName));
         end;
Result:=Length(Items);
except
on E : Exception do LogErrorMessage('TForPointAreaList.Fill',E,[aPoint.LatitudeForRequest,aPoint.LongitudeForRequest]);
end;
end;


function TForPointAreaList.Clear : boolean;
begin
Result:=false;
try
Point.X:=0;
Point.Y:=0;
SetLength(Items,0);
Result:=True;
except
on E : Exception do LogErrorMessage('TForPointAreaList.Clear',E,[]);
end;
end;

(*************************************************************************************************************)


//begin
//Result:=-1;
//try
//Clear;
//if aAreaID>0
//   then xml:=Format('<XML AREAID="%d"/>', [aAreaID])
//   else xml:='<XML AREAID="0"/>';
//ADOSP:=TADOStoredProc.Create(nil);
//try
//ADOSP.ConnectionString:=DBConnString;
//case aIdType of
//aiitArea : ADOSP.ProcedureName:=spIntervalListLoad;
//aiitPVZ  : ADOSP.ProcedureName:=spIntervalListLoadPVZ;
//end;
//if not ADOSP.Parameters.Refresh
//   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
//ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
//ADOSP.Active:=True;
//
//if integer(ADOSP.Parameters[0].Value)<=0
//   then begin
//   Result:=0;
//   Exit;
//   end;
//while not ADOSP.Eof do
//  begin
//  with ADOSP do
//    begin
//    ind:=Length(Items);
//    SetLength(Items,ind+1);
//    with Items[ind] do
//      begin
//      {-$MESSAGE Hint 'Внимание!!! В таблице "map_AreaTime_Full" нет ID. Это поле нужно сделать в новой таблице!'}
//      aiID       := Fields[0].AsInteger;  (*ATTENTION*)
//      aiAreaID   := Fields[1].AsInteger;
//      aiStart    := RoundTo(Fields[2].AsDateTime,dtRnd);
//      aiLen      := RoundTo(Fields[3].AsDateTime  - sqlZeroDate,dtRnd);
//      if ADOSP.Fields.Count>4
//          then aiIdType:=TAreaIntervalIdType(Fields[4].AsInteger)
//          else aiIdType:=aiitArea;
//      //aiDate     := Fields[2].AsDateTime;
//      //aiBegin    := Fields[3].AsInteger;
//      //aiEnd      := Fields[4].AsInteger;
//      //aiPriority := Fields[5].AsInteger;
//      //aiActive   := Fields[6].AsBoolean;
//      // aiInterval:= Fields[7].AsString; в формате '00-00'
//      _Changed   := false;
//      end;
//    Next;
//    end;
//  end;
//Result:=Length(Items);
//finally
//if Assigned(ADOSP)
//   then begin
//   if ADOSP.Active then ADOSP.Active:=False;
//   FreeAndNil(ADOSP);
//   end;
//end;
//except
// on E : Exception do LogErrorMessage('TAreaIntervalList.LoadFromDB',E,[]);
//end;
//end;

function TPVZList.LoadFromDB : integer;
var
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=-1;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='pvz_GetList';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Length(Items);
    SetLength(Items,ind+1);
    with Items[ind] do
      begin
      id := Fields[0].AsInteger;
      Str2AC(Fields[1].asString,Description);
      Str2AC(Fields[2].asString,Region);
      end;
    Next;
    end;
  end;
Result:=Length(Items);
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
on E : Exception do LogErrorMessage('TPVZList.LoadFromDB',E,[]);
end;
end;


function TPVZList.GetDescriptionByID(aID  :integer) : string;
var
 cnt : integer;
begin
Result:='';
try
for cnt:=0 to High(Items)
 do if Items[cnt].id = aID
       then begin
       Result:=AC2Str(Items[cnt].Description);
       Exit;
       end;
except
on E : Exception do LogErrorMessage('TPVZList.GetDesriptionByID',E,[aID]);
end;
end;

function TPVZList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
Result:=true;
except
on E : Exception do LogErrorMessage('TPVZList.Clear',E,[]);
end;
end;

(*************************************************************************************************************)
procedure TCurObject.Fill(aID : integer; aType : TAreaIntervalIdType);
begin
id:=aID;
idType:=aType;
end;


(* ~~~~ ~~~~ *)

procedure TAreaPicList.Create;
begin
imageList:=TImageList.Create(nil);
imageList.Width:=16;
imageList.Height:=16;
end;

procedure TAreaPicList.Clear;
begin
imageList.Free;
end;

function TAreaPicList.GetIndex(aFill, aLine : TColor) : integer;
var
 cnt : integer;
begin
for cnt:=0 to High(items)
  do if (items[cnt].clrFill = aFill) and ((items[cnt].clrLine = aLine))
        then Exit(items[cnt].indexPic);
Result:=-1;
end;


function TAreaPicList.Add(aFill, aLine : TColor) : integer;
var
 ind : integer;
 _bmp: TBitmap;
 sz  : integer;
begin
Result:=GetIndex(aFill, aLine);
if Result=-1
   then begin
    _bmp:=TBitmap.Create;
    try
    with _bmp do
      begin
      sz:=imagelist.Width;
      Height:=sz;
      Width:=sz;
      Canvas.Brush.Color:=clFuchsia;
      Canvas.FillRect(Bounds(0,0,sz,sz));
      Canvas.Brush.Color:=LightColor(aFill,50);
      Canvas.Pen.Color:=aLine;
      Canvas.Rectangle(1,1,Width-2,Height-2);
      ind:=imagelist.AddMasked(_bmp, clFuchsia);
      Result:=Length(items);
      SetLength(items, Result+1);
      items[Result].clrFill:=aFill;
      items[Result].clrLine:=aLine;
      items[Result].indexPic:=ind;
      end;
    finally
    _bmp.Free;
    end;
   end;
end;

procedure TAreaPicList.DrawBitmap(const aFill,aLine : shortstring; var bmp : TBitmap);
var
 ind : integer;
 clrFill : TColor;
 clrLine : TColor;
begin
if not Assigned(bmp) // -- это когда её специально в нул установили....
   then bmp:=TBitmap.Create
   else begin
   try
   if bmp.Empty
      then ;
   except
     on E : Exception do
       begin
       bmp:=nil;
       bmp:=TBitmap.Create;
       end;
   end;
   end;
bmp.Width:=imageList.Width;
bmp.Height:=imageList.Height;
clrFill:=HTMLRGBtoColor(aFill);
clrLine:=HTMLRGBtoColor(aLine);
ind:=Add(clrFill, clrLine);
imageList.Draw(bmp.Canvas,0,0,ind);
end;

(* ~~~~ ~~~~ *)

function TH2Item.View(long : boolean) : string;
const
 shbView : array[boolean] of string = ('hh','hh:nn');
begin
Result:=Format('%s-%s',[FormatDateTime(shbView[long], TimeFrom),FormatDateTime(shbView[long], TimeTo)]);
end;

procedure TH2Item.Assign(const src : TH2Item);
begin
System.Move(src, self, SizeOf(TH2Item));
end;

(* ~~~~ ~~~~ *)

function TH2List.IndexOf(id : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if Items[cnt].id=id
        then Exit(cnt);
except
 on E : Exception do LogErrorMessage('TH2List.IndexOf(1)',E,[])
end;
end;

function TH2List.IndexOf(TimeFrom, TimeTo : TTime) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if (Items[cnt].TimeFrom=TimeFrom) and (Items[cnt].TimeTo=TimeTo)
        then Exit(cnt);
except
 on E : Exception do LogErrorMessage('TH2List.IndexOf(2)',E,[])
end;
end;

function TH2List.Add(const src : TH2Item) : integer;
begin
Result:=-1;
try
Result:=IndexOf(src.id);
if Result>-1 then Exit;
Result:=Length(items);
SetLength(Items, Result+1);
Items[Result].Assign(src);
except
 on E : Exception do LogErrorMessage('TH2List.Add(1)',E,[])
end;
end;

function TH2List.Add(id: integer; TimeFrom, TimeTo : TTime; Used : byte) : integer;
begin
Result:=-1;
try
if id<>0
   then begin
   Result:=IndexOf(id);
   if Result>-1 then Exit;
   end
   else begin
   Result:=IndexOf(TimeFrom, TimeTo);
   if Result>-1 then Exit;
   end;
Result:=Length(Items);
SetLength(Items, Result+1);
Items[Result].id:=id;
Items[Result].TimeFrom:=TimeFrom;
Items[Result].TimeTo:=TimeTo;
Items[Result].Used:=Used;
except
 on E : Exception do LogErrorMessage('TH2List.Add(2)',E,[])
end;
end;

function TH2List.LoadFromDB : integer;
var
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=-1;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='rt_PayLoadRefIntervalList';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Add(Fields[0].AsInteger, TTime(Fields[1].AsDateTime),TTime(Fields[2].AsDateTime),byte(Fields[3].AsInteger));
    if ind>=0
       then   // -- ok
       else ; // -- bad
    Next;
    end;
  end;
Result:=Length(Items);
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
 on E : Exception do LogErrorMessage('TH2List.LoadFromDB',E,[])
end;
end;


function TH2List.DisplayString(index, col : integer) : string;
begin
Result:='';
try
if (index<0) or (index>High(items)) then Exit;
if col<0
   then Result:=items[index].View(true)
   else
   case col of
   0 : Result:=IntToStr(items[index].id);
   1 : Result:=FormatDateTime('hh:nn',items[index].TimeFrom);
   2 : Result:=FormatDateTime('hh:nn',items[index].TimeTo);
   3 : Result:=boolRus[items[index].Used>0];
   end;
except
 on E : Exception do LogErrorMessage('TH2List.Add(2)',E,[])
end;
end;

function TH2List.Clear : boolean;
begin
SetLength(items,0);
Result:=Length(items)=0;
end;


(* ~~~~~ ~~~~~ *)
procedure TPayIntervalItem.Assign(const src : TPayIntervalItem);
begin
System.Move(src, self, SizeOf(TPayIntervalItem));
//   id : integer;
//   AreaId : integer;
//   IntervalId : integer;
//   DateBegin : TDateTime;
//   DateEnd : TDateTime;
//   Quota : integer;
end;

function TPayIntervalItem.GetXML : string;
const
 shablon : string = '<item id="%0:d" areaid="%1:d" intervalid="%2:d" datebegin="%3:s" dateend="%4:s" quota="%5:d"/>';
begin
Result:=Format(shablon , [
 id
,AreaId
,IntervalId
,FormatDateTime('yyyymmdd',DateBegin)
,ifThen(DateEnd>0,FormatDateTime('yyyymmdd',DateEnd),'')
,ifThen(Quota>=0,Quota,0)
])
end;

(* ~~~~~ ~~~~~ *)

function TPayIntervalList.IndexOf(id : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(items)
  do if items[cnt].id=id
        then Exit(cnt);
except
 on E : Exception do LogErrorMessage('TPayIntervalList.IndexOf',E,[])
end;
end;

function TPayIntervalList.IndexOf(AreaId, IntervalId : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(items)
  do if (items[cnt].AreaId=AreaId) and (items[cnt].IntervalId=IntervalId)
        then Exit(cnt);
except
 on E : Exception do LogErrorMessage('TPayIntervalList.IndexOf',E,[])
end;
end;


function TPayIntervalList.LoadFromDB : integer;
var
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=-1;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='rt_PayLoadIntervalListForAreas';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Add( Fields[0].AsInteger   // -- id
             ,Fields[1].AsInteger   // -- AreaId
             ,Fields[2].AsInteger   // -- IntervalId
             ,Fields[3].AsDateTime  // -- DateBegin
             ,Fields[4].AsDateTime  // -- DateEnd
             ,Fields[5].AsInteger   // -- Quota
             );
// -- поля реально есть, применяются для сортировки --
// Fields[6].AsDateTime , RDP.TimeFrom
// Fields[7].AsDateTime, RDP.TimeTo

    if ind>=0
       then   // -- ok
       else ; // -- bad
    Next;
    end;
  end;
Result:=Length(Items);
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
 on E : Exception do LogErrorMessage('TPayIntervalList.LoadFromDB',E,[])
end;
end;



function TPayIntervalList.GetXML : string;
var
 cnt : integer;
begin
Result:=crlf;
try
for cnt:=0 to High(items)
  do Result:=Result+items[cnt].GetXML+crlf;
Result:=Format('<%0:s>%1:s</%0:s>',['request',Result])
except
 on E : Exception do LogErrorMessage('TPayIntervalList.Add(2)',E,[])
end;
end;

function TPayIntervalList.SaveToDB : boolean;
var
 ADOSP : TADOStoredProc;
 xml   : string;
begin
Result:=false;
try
if length(items)=0
   then Exit;
xml:=GetXml;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='rt_PaySaveIntervalList';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
if Assigned(ADOSP.Parameters.FindParam('@xmltext'))
   then ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.ExecProc;
Result:=integer(ADOSP.Parameters[0].Value)>=0;
finally
if Assigned(ADOSP)
   then FreeAndNil(ADOSP);
end;
except
 on E : Exception do LogErrorMessage('TPayIntervalList.SaveToDB',E,[])
end;
end;



function TPayIntervalList.CheckValid(const Check : TPayIntervalItem) : TPILCheck;
var
 cnt : integer;
begin
Result:=pilcNotExists;
try
if Check.id=0
   then begin
   for cnt:=0 to High(Items)
      do begin
      // -- для области уже есть такой интервал....
      if (items[cnt].AreaId=Check.AreaId) and ((items[cnt].IntervalId=Check.IntervalId))
         then begin
         if (items[cnt].DateEnd=0) // -- есть с открытой датой и новый с датой начала большей(равной) существующему
           and (items[cnt].DateBegin<=Check.DateBegin)
           then Exit(pilcExisOpen)
           else
         if (items[cnt].DateEnd<>0) // -- есть с закрытой датой и новый с датой начала большей(равной) существующему
           and (items[cnt].DateBegin<=Check.DateBegin)
           and (items[cnt].DateEnd>=Check.DateEnd)
           then Exit(pilcOverlap)
           else ;
         end;

      end;
   end // --> Check.id=0

except
 on E : Exception do LogErrorMessage('TPayIntervalList.CheckValid',E,[])
end;
end;



function TPayIntervalList.Add(id, AreaId, IntervalId : integer; DateBegin,DateEnd:TDateTime;Quota:integer) : integer;
begin
Result:=-1;
try
if id<>0
   then Result:=IndexOf(id);
if Result=-1
   then Result:=IndexOf(AreaId, IntervalId);
if Result=-1
   then begin
   Result:=Length(items);
   SetLength(items, Result+1);
   items[Result].id:=id;
   items[Result].AreaId:=AreaId;
   items[Result].IntervalId:=IntervalId;
   items[Result].DateBegin:=DateBegin;
   items[Result].DateEnd:=DateEnd;
   items[Result].Quota:=Quota;
   end;
except
 on E : Exception do LogErrorMessage('TPayIntervalList.Add(1)',E,[])
end;
end;

function TPayIntervalList.Add(const src : TPayIntervalItem) : integer;
begin
Result:=-1;
try
if src.id<>0
   then Result:=IndexOf(src.id);
if Result=-1
   then Result:=IndexOf(src.AreaId, src.IntervalId);
if Result=-1
   then begin
   Result:=Length(items);
   SetLength(items, Result+1);
   items[Result].Assign(src);
   end;
except
 on E : Exception do LogErrorMessage('TPayIntervalList.Add(2)',E,[])
end;
end;


procedure TPayIntervalList.Sort;
var
 strl : TStringList;

begin
strl := TStringList.Create;
try


finally
FreeStringList(strl);
end;
end;

function TPayIntervalList.Delete(index : integer) : boolean;
begin
Result:=false;
try
if not ((index>=Low(items)) and (index<=High(items)))
   then Exit;
if (Index<High(items))
     then System.Move(items[index+1],items[index],(High(items)-Index) * SizeOf(TPayIntervalItem));
SetLength(items,Length(items)-1);
except
 on E : Exception do LogErrorMessage('TPayIntervalList.Delete',E,[])
end;
end;

procedure TPayIntervalList.Clear;
begin
SetLength(items,0);
end;

(* ~~~~~ ~~~~~ *)

function TAreaAgentList.LoadFromDB : integer;
var
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=-1;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='rt_GetAreaAgent';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Active:=True;
SetLength(items, ADOSP.RecordCount);
ind:=0;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    items[ind].AreaId:=Fields[0].AsInteger;
    items[ind].Agent:=Fields[1].AsInteger;
    inc(ind);
    Next;
    end;
  end;
Result:=Length(Items);
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
except
 on E : Exception do LogErrorMessage('TAreaAgentList.LoadFromDB',E,[])
end;
end;

function TAreaAgentList.IndexOf(AreaId : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
for cnt:=0 to High(items)
  do if items[cnt].AreaId = AreaId
        then Exit(cnt);
end;

function TAreaAgentList.CheckAreaAgent(AreaId, Agent : integer) : boolean;
var
 ind  :integer;
begin
ind:=IndexOf(AreaId);
Result:=(ind>-1) and (items[ind].Agent = Agent);
end;

function TAreaAgentList.GetAreas(Agent : integer; var Areas : TIntegerDynArray) : integer;
var
 cnt : integer;
begin
SetLength(Areas,0);
for cnt:=0 to High(items)
  do if items[cnt].Agent = Agent
        then AddValueIntoArray(Areas, items[cnt].AreaId);
Result:=Length(Areas);
end;

procedure TAreaAgentList.Clear;
begin
Setlength(items, 0);
end;


(*************************************************************************************************************)

(*************************************************************************************************************)

function AboutWorkMode : string;
const
 dlm = ', ';
var
 cntWM : TWorkModeType;
begin
Result:='';
for cntWM:=wmtUnknown to High(TWorkModeType)
  do if cntWM in WorkMode
        then Result:=Result+WorkModeTypeDescr[cntWM]+dlm;
Result:=Copy(Result,1,Length(Result) - Length(dlm));
end;


function ArrayOfFloatPointIntoString(const aArFP : TArrayOfFloatPoint) : string;
var
 coords : string;
 cnt    : integer;
begin
coords:='';
for cnt:=0 to High(aArFP)
  do //coords:=coords+Format('%s,%s;',[aArFP[cnt].LatitudeForRequest,aArFP[cnt].LongitudeForRequest]);
      coords:=coords+aArFP[cnt].GetLatLon+';';
Result:=Copy(coords,1,Length(coords)-1);
end;

(* ГЛАВНАЯ : Получение информации за день из таблицы rt_History ***********************************)
function GetFullData(aDate : TDateTime; aAgent: TDeliveryAgent) : boolean;
 const
  param = '<PARAMS DATE="%s" AGENT="%d"></PARAMS>';
  // -- rsXXXXX номера датасетов в ae_GetFullData
  rsXML     = 0;
  rsCars    = 1;
  rsPoints  = 2;
  DefRowHeight = 20;
var
 ADOSP   : TADOStoredProc;
 errFile : string;
 rsNum   : integer;
 RecCnt  : integer;
 XMLBody : string;
 tmpRS   : _Recordset;
 infStr  : string;
 ind     : integer;
 koe     : double;
 rct     : TRect;
 cnt     : integer;
begin
Result:=False;
infStr:=Format('%s, %d',[FormatDateTime('dd.mm.yyyy', aDate), integer(aAgent)]);
errFile:='';
rsNum:=-1;
RecCnt:=-1;
ShowSplash(Format('Получение данных [%s]',[infStr]), stInfo);
 HistoryAreaList.Clear;
 CarList.Clear;
 MarkerList.Clear;
try
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
ADOSP.ProcedureName:='ae_GetFullData';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
XMLBody:=Format(param,[FormatDateTime('yyyymmdd', aDate), integer(aAgent)]);
ADOSP.Parameters.ParamByName('@xmltext').Value:=XMLBody;
rsNum:=0;
ADOSP.Active:=True;
while Assigned(ADOSP.Recordset) and (ADOSP.Recordset.State<>0)
  do begin
  case rsNum of
  rsXML :
    begin
    XMLBody:=ADOSP.Fields[0].AsString;
    if XMLBody=''
       then begin
       LogInfoMessage(Format('По параметрам [%s] данные отсутствуют.',[infStr]));
       Exit;
       end;
    HistoryAreaList.LoadFromXML(XMLTitleWIN1251+CopyFromTo(XMLBody,'<AREASET>','</AREASET>',true,true));
    end;
  rsCars:
    begin
    RecCnt:=0;
    koe:=(DefRowHeight-2) / 89;
    rct:=Bounds(0,0,Round(400*koe)-1,Round(89*koe)-1);
    while not ADOSP.EoF do
      begin
      ind:=Length(CarList.Items);
      SetLength(CarList.Items, ind+1);
      with ADOSP, CarList.Items[ind] do
        begin
        Car_ID       := Fields[0].AsInteger;
        Str2AC(Fields[1].AsString, Car_Model);
        Str2AC(Fields[2].AsString, Car_Reg_Num);
        Str2AC(Fields[3].AsString, Driver_FIO);
        Area_ID      := Fields[4].AsInteger;
        Str2AC(Fields[5].AsString, Area_name);
        NumPic:=TBitmap.Create;
        if not GetRegNumber(AC2Str(Car_Reg_Num),rct,NumPic)
           then if Assigned(NumPic) then FreeAndNil(NumPic);
        end;
      inc(RecCnt);
      ADOSP.Next;
      end;
    LogInfoMessage(Format('Описаний автомобилей(%s): %d',[infStr,RecCnt]));
    end;
  rsPoints:
    begin
    RecCnt:=0;
    while not ADOSP.EoF do
      begin
      ind:=Length(MarkerList.Items);
      SetLength(MarkerList.Items, ind+1);
      with ADOSP, MarkerList.Items[ind] do
        begin
        Area_ID      := Fields[0].AsInteger;
        Car_ID       := Fields[1].AsInteger;
        Str2AC(Fields[2].AsString, Delivery_FIO);
        Str2AC(Fields[3].AsString, Customer_FIO);
        Str2AC(Fields[4].AsString, Delivery_Addr);
        Str2AC(Fields[5].AsString, Phone);
        Str2AC(Fields[6].AsString, Interval);
        Str2AC(Fields[7].AsString, AboutFull);
        with LatLng do
          begin
          Latitude   :=Fields[8].AsFloat;
          Longitude  :=Fields[9].AsFloat;
          end;
        end;
      inc(RecCnt);
      ADOSP.Next;
      end;
    LogInfoMessage(Format('Описаний точек доставки(%s): %d',[infStr,RecCnt]));
    end;
  end;
  RecCnt:=0;
  inc(rsNum);
  tmpRS:=ADOSP.NextRecordset(RecCnt);
  if not Assigned(tmpRS) or (tmpRS.State=0) then Break;
  ADOSP.Recordset:=tmpRS;
  end;
for cnt:=0 to High(CarList.Items)
  do with CarList.Items[cnt] do MarkerList.CalculateForCar(Car_ID, _Points, _Deliveries, _Return);
finally
FreeSplash;
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
Result:=True;
except
on E : Exception
   do begin
   if Pos('<PARAMS DATE',XMLBody)=0
      then begin
      errFile:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'ErrXML\';
      if not ForceDirectories(errFile) then errFile:=SetTailBackSlash(GetTempFolder);
      errFile:=errFile+'gfd_'+FormatdateTime('yyyymmdd_hhnnss',now)+'.xml';
      SaveStringIntoFile(XMLBody,errFile);
      end
      else errFile:=XMLBody;
   LogErrorMessage('GetFullData',E,[getConnStrForErrorMessage,errFile,rsNum,RecCnt]);
   end;
end;
end;

procedure ExecuteScript(aWebBrowser : TWebBrowser; aScript: string);
var
  Doc     : IHTMLDocument2;    // -- current HTML document
  HTMLWin : IHTMLWindow2;  // -- parent window of current HTML document
  errFile : string;
begin
try
Doc := IHTMLDocument2(aWebBrowser.ControlInterface.Document);
HTMLWin := Doc.parentWindow;
if Assigned(HTMLWin)
   then HTMLWin.ExecScript(aScript, 'JavaScript');// убирание этой строки приводит к нормальной работе (???)
except
   on E : Exception
     do begin
     errFile:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'ErrJS\';
     if not ForceDirectories(errFile) then errFile:=SetTailBackSlash(GetTempFolder);
     errFile:=errFile+'js_'+FormatdateTime('yyyymmdd_hhnnss',now)+'.js';
     SaveStringIntoFile(aScript,errFile);
     LogErrorMessage('ExecuteScript',E,[aWebBrowser.Name, errFile]);
     CanDelHTMLOnExit:=false;
     end;
end;
end;

(* Получение значения тэга (элемента) со страницы HTML ********************************************)
function GetIdValue(aWB  : TWebBrowser; const Id : string) : string;
var
  ADocument  : IHTMLDocument2;
  ABody      : IHTMLElement2;
  Tag      : IHTMLElement;
  TagsList : IHTMLElementCollection;
  Index    : Integer;
begin
  Result:='';
  ADocument := aWB.Document as IHTMLDocument2;
  if not Assigned(ADocument) then Exit;
  if not Supports(ADocument.body, IHTMLElement2, ABody) then exit;
  if not Assigned(ABody) then Exit;
  TagsList := ABody.getElementsByTagName('input');
  if not Assigned(TagsList) then Exit;
  for Index := 0 to TagsList.length-1
    do begin
    if Assigned(TagsList)
       then Tag:=TagsList.item(Index, EmptyParam) As IHTMLElement;
    if not Assigned(Tag) then Exit;
    if Assigned(Tag) and (CompareText(Tag.id,Id)=0)
       then Result := Tag.getAttribute('value', 0);
    end;
end;

(* Очистка значения тэга (элемента) со страницы HTML **********************************************)
procedure ClearIds(ABody : IHTMLElement2);
var
  Tag      : IHTMLElement;
  TagsList : IHTMLElementCollection;
  Index    : Integer;
begin
TagsList := ABody.getElementsByTagName('input');
for Index := 0 to TagsList.length-1 do
begin
Tag:=TagsList.item(Index, EmptyParam) As IHTMLElement;
Tag.setAttribute('value','',0);
end;
end;

(* Установка значения тэга (элемента) со страницы HTML **********************************************)
procedure SetIdValue(ABody  : IHTMLElement2; const Id, Value : string);
var
  Tag      : IHTMLElement;
  TagsList : IHTMLElementCollection;
  Index    : Integer;
begin
  TagsList := ABody.getElementsByTagName('input');
  for Index := 0 to TagsList.length-1 do
   begin
   Tag:=TagsList.item(Index, EmptyParam) As IHTMLElement;
   if CompareText(Tag.id,Id)=0 then Tag.setAttribute('value',Value, 0);
   end;
end;


(* Получение отображения регистрационного номера и подгонка по TRect ******************************)
function GetRegNumber(const aRegNumber  :string; const aRect : TRect; var aBMP : TBitmap) : boolean;
type
  TGetAutoNumber = procedure(withFlag: boolean;aNumber : PAnsiChar;aBitmap : TBitmap); stdcall;
var
 GetAutoNumber : TGetAutoNumber;
 Lib           : hModule;
 BMPN          : TBitmap;
 rct           : TRect;
 k             : double;
const
 AutoNumber = 'AutoNum.dll'; (*А ОНО НАДО?*) // -- Может вынести в глобальные настройки ?...
begin
Result:=False;
try
if not Assigned(aBMP) then Exit;
with aBMP,ARect do
 begin
 Width := Right  - Left;
 Height:= Bottom - Top;
 Canvas.Brush.Color:=clFuchsia;
 end;
BMPN :=TBitmap.Create;
Lib:=LoadLibrary(AutoNumber);
try
BMPN.Canvas.Brush.Color:=clFuchsia;
if Lib>32
   then begin
   GetAutoNumber:=GetProcAddress(Lib,'GetAutoNumber');
   if Assigned(GetAutoNumber)
      then GetAutoNumber(True,PAnsiChar(AnsiString(aRegNumber)),BMPN);
   if (BMPN.Width>1)
      then begin
      k:=aBMP.Height / BMPN.Height;
      if BMPN.Width * k > aBMP.Width
         then k:= aBMP.Width / BMPN.Width;
      rct:=Bounds(aRect.Left,aRect.Top,Round(BMPN.Width * k),Round(BMPN.Height * k));
      with aBMP do
       begin
       Width := rct.Right  - rct.Left;
       Height:= rct.Bottom - rct.Top;
       SetStretchBltMode(Canvas.Handle,STRETCH_HALFTONE);
       StretchBlt(Canvas.Handle,0,0,Width,Height,BMPN.Canvas.Handle,0,0,BMPN.Width,BMPN.Height,SRCCOPY);
       end;
      Result:=True;
      end;
   end;
if not Result
   then aBMP.Canvas.FillRect(Bounds(0,0,ARect.Right,ARect.Bottom));
finally
FreeLibrary(Lib);
FreeAndNil(BMPN);
end;
except
on E : Exception do LogErrorMessage('GetRegNumber',E,[aRegNumber]);
end;
end;

(* Подготовка наименования области для упорядочивания *********************************************)
function AreaNameForArrange(const aAreaname : string) : string;
var
 nms  : string;
 psn  : integer;
 num  : string;
 cap  : string;
begin
Result:='';
try
nms:=AnsiUpperCase(aAreaname);
psn:=Pos('.',nms);
Result:=nms;
if (psn<>0)
   then begin
   num:=Copy(nms,1,psn-1);
   cap:=Copy(nms,psn,Length(nms));
   if CheckValidInteger(num)
      then Result:=FormatFloat('0000000000',StrToInt(num))+cap;
   end;
except
on E : Exception do LogErrorMessage('AreaNameForArrange',E,[]);
end;
end;

(* Проверка вхождения точки в область *************************************************************)
function PointInArea(const aCont : array of TFloatPoint;aTestPoint : TFloatPoint) : boolean;
var
lineLat1   : Extended;
lineLon1   : Extended;
lineLat2   : Extended;
lineLon2   : Extended;
CrossCount : integer;
nvert      : integer;
i : integer;
j : integer;
begin
 CrossCount := -1;
 nvert := Length(aCont);
 i := 0;
 j := nvert - 1;
 while (i<nvert)
 do begin
 lineLat1:=aCont[i].Latitude;
 lineLon1:=aCont[i].Longitude;
 lineLat2:=aCont[j].Latitude;
 lineLon2:=aCont[j].Longitude;
 if ((((lineLon1>aTestPoint.Longitude) and (lineLon2<=aTestPoint.Longitude)) or ((lineLon1<aTestPoint.Longitude) and (lineLon2>aTestPoint.Longitude)))
	  and
      (aTestPoint.Latitude < ((lineLat2 - lineLat1) * (aTestPoint.Longitude - lineLon1) / (lineLon2 - lineLon1)    + lineLat1)))
	 then CrossCount := -1 * CrossCount;
 j := i;
 inc(i);
 end ;// while i
 if ((CrossCount>0) and ((CrossCount mod 2)<>0))
    then result:=true
    else result:=false;
end;

(* Получение набора точек, входящих в область (aIn  - область, aCont - контрольный набор) *********)
function GetInnerPoints(aIn, aCont : array of TFloatPoint; var aRes : TArrayOfFloatPoint) : integer;
var
  cnt : integer;
  ind : integer;
begin
Result:=0;
SetLength(aRes,0);
for cnt:=0 to High(aIn)
  do if PointInArea(aCont, aIn[cnt])
        then begin
        inc(Result);
        ind:=Length(aRes);
        Setlength(aRes, ind+1);
        aRes[ind].Longitude:=aIn[cnt].Longitude;
        aRes[ind].Latitude:=aIn[cnt].Latitude;
        end;
end;

(* Подготовка описания точек для отображения ******************************************************)
function GetPointsForDisplay(const aPoints : TArrayOfFloatPoint) : string;
var
 cnt : integer;
begin
Result:='';
for cnt:=0 to High(aPoints)
  do with aPoints[cnt]
       do begin
       Result:=Result+
               LatitudeForRequest+FieldsDelimiter+
               LongitudeForRequest+FieldsDelimiter+
               StringToJavaUTF8Ex(GetLongitudeIntoDMS)+'\n'+StringToJavaUTF8Ex(GetLatitudeIntoDMS)+RecordsDelimiter;
       end;
end;

(**********************************************************************)
const
  WM_COMMAND = $0111; (*module Message.pas*)

   procedure IE_PrintPreview;
   begin
   if IES_Handle<>0 then SendMessage(SDV_Handle, WM_COMMAND, MakeWParam(ID_IE_FILE_PRINTPREVIEW, IECMD_SDV),0);
   end;

   procedure IE_ImportExport;
   begin
   if IES_Handle<>0 then SendMessage(SDV_Handle, WM_COMMAND, MakeWParam(ID_IE_FILE_IMPORTEXPORT, IECMD_SDV),0);
   end;

   procedure IE_Refresh;
   begin
   if IES_Handle<>0 then SendMessage(IES_Handle, WM_COMMAND, MakeWParam(ID_IE_CONTEXTMENU_REFRESH, IECMD_IES),0);
   end;

//--from : http://parsing-and-i.blogspot.com/2009/04/twebbrowser-setfocus.html
procedure WebBrowserFocus(Wb : TWebBrowser);
begin
Application.MainForm.ActiveControl:=nil;
with Wb do
  if Document <> nil then
    with Application as IOleobject do
      DoVerb(OLEIVERB_UIACTIVATE, nil, Wb, 0, Handle,  Bounds(top,left,width,height));
end;

initialization InitTypes;
finalization FinalTypes;
end.








