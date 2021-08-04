unit U_NV_Main;

interface

uses
  Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Types, StrUtils
  , FnCommon, AppPrms
  , INIFiles
  , Buttons
  , StdCtrls
  , ComCtrls
  , Menus
  , ImgList, Grids


  ;


type
  TColDataType =
    (
      cdtText      = 0
     ,cdtInteger  = 1
     ,cdtDecimal  = 2
    );
  TColInfo = record
   //bsIndex  : integer;      // -- базовый индекс (порядковое в файле)
   //dspIndex : integer;      // -- отображаемый индекс
   navName  : string[32];   // -- наименование в Navision
   title    : string[64];   // -- заголовок в отображении
   datatype : TColDataType; // -- реальный тип данных (в Navision)
   width    : integer;      // -- ширина колонки (если видна, а если нет то -1, но перед сохранением восстанавливать)
   visible  : boolean;
  end;

(*  1 DATE_ROUTE     Text 19   >>  10.04.2012 0:00:00|*)
(*  2 ROUTE_NUM      Integer   >>  1|                 *)
(*  3 NAME           Text 50   >>   |                 *)
(*  4 LEN            Decimal   >>  113,05|            *)
(*  5 TIME_LEN       Text 19   >>  08:45|             *)
(*  6 TIME_START     Text 19   >>  07:30|             *)
(*  7 OGRSUM1        Decimal   >>  0,00|              *)
(*  8 OGRSUM2        Decimal   >>  0,00|              *)
(*  9 SUM3           Decimal   >>  0,00|              *)
(* 10 SUM4           Decimal   >>  0,00|              *)
(* 11 NUM_POINT      Integer   >>  44|                *)
(* 12 PROCM          Decimal   >>  0,00|              *)
(* 13 VOL_PROCM      Decimal   >>  0,00|              *)
(* 14 ZONE           Text 50   >>  1|                 *)
(* 15 ACTIVE         Integer   >>  3|                 *)
(* 16 ROUTE_COST     Decimal   >>  665,29|            *)
(* 17 STR1           Text 100  >>   |                 *)
(* 18 STR2           Text 100  >>   |                 *)
(* 19 TRIP_NO        Integer   >>  1|                 *)
(* 20 CAR_ID         Text 36   >>  480s|              *)
(* 21 STORE_ID       Integer   >>  1|                 *)
(* 22 ID             Integer   >>  35517|             *)
(* 23 DRIVER         Text 50   >>  Шестаков Максим|   *)
(* 24 DRIVER_ID      Text 36   >>  46d|               *)
(* 25 CAR_NAME       Text 30   >>  Шестаков Максим|   *)
(* 26 REG_NO_NUM     Text 6    >>  316732|            *)
(* 27 UDOSTOVERENIE  Text 15   >>  50ОТ687645|        *)
(* 28 REG_NO_SER     Text 4    >>  77уе|              *)
(* 29 REG_NO_NO      Text 6    >>  26|                *)
(* 30 ORGANIZATION   Text 30   >>  ООО "ПриватТрэйд"| *)
(* 31 CAR_NUM        Text 15   >>  в418кк197          *)

 TRouteCol = (
   rc_NUM_SEQUENCE =  0 // просто индекс в последовательности
  ,rcDATE_ROUTE    =  1 // Text 19   >>  10.04.2012 0:00:00|
  ,rcROUTE_NUM     =  2 // Integer   >>  1|
  ,rcNAME          =  3 // Text 50   >>   |
  ,rcLEN           =  4 // Decimal   >>  113,05|
  ,rcTIME_LEN      =  5 // Text 19   >>  08:45|
  ,rcTIME_START    =  6 // Text 19   >>  07:30|
  ,rcOGRSUM1       =  7 // Decimal   >>  0,00|
  ,rcOGRSUM2       =  8 // Decimal   >>  0,00|
  ,rcSUM3          =  9 // Decimal   >>  0,00|
  ,rcSUM4          = 10 // Decimal   >>  0,00|
  ,rcNUM_POINT     = 11 // Integer   >>  44|
  ,rcPROCM         = 12 // Decimal   >>  0,00|
  ,rcVOL_PROCM     = 13 // Decimal   >>  0,00|
  ,rcZONE          = 14 // Text 50   >>  1|
  ,rcACTIVE        = 15 // Integer   >>  3|
  ,rcROUTE_COST    = 16 // Decimal   >>  665,29|
  ,rcSTR1          = 17 // Text 100  >>   |
  ,rcSTR2          = 18 // Text 100  >>   |
  ,rcTRIP_NO       = 19 // Integer   >>  1|
  ,rcCAR_ID        = 20 // Text 36   >>  480s|
  ,rcSTORE_ID      = 21 // Integer   >>  1|
  ,rcID            = 22 // Integer   >>  35517|
  ,rcDRIVER        = 23 // Text 50   >>  Шестаков Максим|
  ,rcDRIVER_ID     = 24 // Text 36   >>  46d|
  ,rcCAR_NAME      = 25 // Text 30   >>  Шестаков Максим|
  ,rcREG_NO_NUM    = 26 // Text 6    >>  316732|
  ,rcUDOSTOVERENIE = 27 // Text 15   >>  50ОТ687645|
  ,rcREG_NO_SER    = 28 // Text 4    >>  77уе|
  ,rcREG_NO_NO     = 29 // Text 6    >>  26|
  ,rcORGANIZATION  = 30 // Text 30   >>  ООО "ПриватТрэйд"|
  ,rcCAR_NUM       = 31 // Text 15   >>  в418кк197
 );

 TRoute = record
   ArrIndex : integer;
   Desc     : boolean;
   Rows     : array of array[TRouteCol] of string[255];
 function LoadFromFile(const aFileName : string) : integer;
// function Arrange(aColIndex : integer; aDesc : boolean): boolean;
 procedure Clear;
 end;

(*  1 EXT_STRID    Text 36      //Номер заказа                                       >> 635382|                                                      *)
(*  2 CUST_ID      Text 36      //Идентификатор клиента                              >> 10274530|                                                    *)
(*  3 UNLOAD_TYP   Integer      //0                                                  >> 0|                                                           *)
(*  4 ORD_TYP      Integer      //0                                                  >> 0|                                                           *)
(*  5 CATEGORY_ID  Integer      //0                                                  >> 0|                                                           *)
(*  6 TIME_BEG     Text 19      // интервал доставки (начало)   hh:mm                >> 15:00|                                                       *)
(*  7 TIME_END     Text 19      // интервад доставки (окончание)hh:mm                >> 21:00|                                                       *)
(*  8 TIME_UNLOAD  Text 19      // время разгрузки hh:mm (00:10)                     >> 00:10|                                                       *)
(*  9 ACTIVE       Integer      //3                                                  >> 3|                                                           *)
(* 10 OGRSUM1      Decimal      //0.00                                               >> 0,00|                                                        *)
(* 11 OGRSUM2      Decimal      //0.00                                               >> 0,00|                                                        *)
(* 12 SUM3         Decimal      //0.00                                               >> 0,00|                                                        *)
(* 13 SUM4         Decimal      //0.00                                               >> 0,00|                                                        *)
(* 14 ADDR         Text 250     // Полный адрес доставки;КЛАДР                       >> Москва, г. Москва, Варшавское ш., д. 152; 77000000000047601| *)
(* 15 DISTR        Text 50      // Район                                             >> Москва|                                                      *)
(* 16 TOWN         Text 50      // Населенный пункт                                  >> Москва|                                                      *)
(* 17 STREET       Text 50      // Улица                                             >> Варшавское ш.|                                               *)
(* 18 HOUS         Text 20      // Дом                                               >> 152|                                                         *)
(* 19 CORP         Text 20      // Корпус                                            >> |                                                            *)
(* 20 STR1         Text 250     // ФИО клиента                                       >> ольга гончар|                                                *)
(* 21 STR2         Text 250     // КЛАДР                                             >> 77000000000047601|                                           *)
(* 22 STR3         Text 250     // Интервал + телефон клиента                        >> 15:00до21:00 +7 (985) 243-17-43 См. Заказ|                   *)
(* 23 STR4         Text 250     // #32                                               >> |                                                            *)
(* 24 STR5         Text 250     // #32                                               >> |                                                            *)
(* 25 STR6         Text 250     // Полный адрес с квартирой                          >> Москва, Варшавское,дом 152,корп.15,кв.80|                    *)
(* 26 INT1         Integer      // 0                                                 >> 0|                                                           *)
(* 27 INT2         Integer      // 0                                                 >> 0|                                                           *)
(* 28 INT3         Integer      // 0                                                 >> 0|                                                           *)
(* 29 MAX_CAR      Decimal      // 0.00                                              >> 0,00|                                                        *)
(* 30 MIN_CAR      Decimal      // 0.00                                              >> 0,00|                                                        *)
(* 31 DELIV_DATE   Text 19      // Дата доставки (dd.mm.yyyy 0:00:00)                >> 10.04.2012 0:00:00|                                          *)
(* 32 ROUTE_ID     Integer      // Маршрут (некое формируемое число) ***! см.выше    >> 35557| NAVCALC_ROUTE_ID                                      *)
(* 33 ROUTE_NUM    Integer      // Номер маршрута (в списке маршрутов по порядку)    >> 42|    NAVCLAC_ROUTE_NUM                                     *)
(* 34 NUM_INROUTE  Integer      // Видимо № точки в маршруте                         >> 12|                                                          *)
(* 35 DISTANC      Decimal      // ? дистанция от предыдущей? до следующей? общая?   >> 0,00|                                                        *)
(* 36 TIME_ARR     Text 19      // ориентировочное время прибытия                    >> 10:16|                                                       *)
(* 37 X            Integer      // координата X на карте "Антор" (%d)                >> 1875688|                                                     *)
(* 38 Y            Integer      // координата Y на карте "Антор" (%d)                >> 4344722|                                                     *)
(* 39 LINKED       Integer      // прикрепленность заказа к маршруту (1 всегда)      >> 1                                                            *)

 TOrderCol = (
  oc_NUM_SEQUENCE =  0 //
 ,ocEXT_STRID     =  1 //Номер заказа                                       >> 635382|                                                      *)
 ,ocCUST_ID       =  2 //Идентификатор клиента                              >> 10274530|                                                    *)
 ,ocUNLOAD_TYP    =  3 //0                                                  >> 0|                                                           *)
 ,ocORD_TYP       =  4 //0                                                  >> 0|                                                           *)
 ,ocCATEGORY_ID   =  5 //0                                                  >> 0|                                                           *)
 ,ocTIME_BEG      =  6 // интервал доставки (начало)   hh:mm                >> 15:00|                                                       *)
 ,ocTIME_END      =  7 // интервад доставки (окончание)hh:mm                >> 21:00|                                                       *)
 ,ocTIME_UNLOAD   =  8 // время разгрузки hh:mm (00:10)                     >> 00:10|                                                       *)
 ,ocACTIVE        =  9 //3                                                  >> 3|                                                           *)
 ,ocOGRSUM1       = 10 //0.00                                               >> 0,00|                                                        *)
 ,ocOGRSUM2       = 11 //0.00                                               >> 0,00|                                                        *)
 ,ocSUM3          = 12 //0.00                                               >> 0,00|                                                        *)
 ,ocSUM4          = 13 //0.00                                               >> 0,00|                                                        *)
 ,ocADDR          = 14 // Полный адрес доставки;КЛАДР                       >> Москва, г. Москва, Варшавское ш., д. 152; 77000000000047601| *)
 ,ocDISTR         = 15 // Район                                             >> Москва|                                                      *)
 ,ocTOWN          = 16 // Населенный пункт                                  >> Москва|                                                      *)
 ,ocSTREET        = 17 // Улица                                             >> Варшавское ш.|                                               *)
 ,ocHOUS          = 18 // Дом                                               >> 152|                                                         *)
 ,ocCORP          = 19 // Корпус                                            >> |                                                            *)
 ,ocSTR1          = 20 // ФИО клиента                                       >> ольга гончар|                                                *)
 ,ocSTR2          = 21 // КЛАДР                                             >> 77000000000047601|                                           *)
 ,ocSTR3          = 22 // Интервал + телефон клиента                        >> 15:00до21:00 +7 (985) 243-17-43 См. Заказ|                   *)
 ,ocSTR4          = 23 // #32                                               >> |                                                            *)
 ,ocSTR5          = 24 // #32                                               >> |                                                            *)
 ,ocSTR6          = 25 // Полный адрес с квартирой                          >> Москва, Варшавское,дом 152,корп.15,кв.80|                    *)
 ,ocINT1          = 26 // 0                                                 >> 0|                                                           *)
 ,ocINT2          = 27 // 0                                                 >> 0|                                                           *)
 ,ocINT3          = 28 // 0                                                 >> 0|                                                           *)
 ,ocMAX_CAR       = 29 // 0.00                                              >> 0,00|                                                        *)
 ,ocMIN_CAR       = 30 // 0.00                                              >> 0,00|                                                        *)
 ,ocDELIV_DATE    = 31 // Дата доставки (dd.mm.yyyy 0:00:00)                >> 10.04.2012 0:00:00|                                          *)
 ,ocROUTE_ID      = 32 // Маршрут (некое формируемое число) ***! см.выше    >> 35557| NAVCALC_ROUTE_ID                                      *)
 ,ocROUTE_NUM     = 33 // Номер маршрута (в списке маршрутов по порядку)    >> 42|    NAVCLAC_ROUTE_NUM                                     *)
 ,ocNUM_INROUTE   = 34 // Видимо № точки в маршруте                         >> 12|                                                          *)
 ,ocDISTANC       = 35 // ? дистанция от предыдущей? до следующей? общая?   >> 0,00|                                                        *)
 ,ocTIME_ARR      = 36 // ориентировочное время прибытия                    >> 10:16|                                                       *)
 ,ocX             = 37 // координата X на карте "Антор" (%d)                >> 1875688|                                                     *)
 ,ocY             = 38 // координата Y на карте "Антор" (%d)                >> 4344722|                                                     *)
 ,ocLINKED        = 39 // прикрепленность заказа к маршруту (1 всегда)      >> 1                                                            *)
 );

 TOrder = record
   ArrIndex : integer;
   Desc     : boolean;
   Rows     : array of array[TOrderCol] of string[255];
 function LoadFromFile(const aFileName : string) : integer;
// function Arrange(aColIndex : integer; aDesc : boolean): boolean;
// procedure Clear;
 end;











type
  T_Main = class(TForm)
    PC_Main: TPageControl;
    TS_Route: TTabSheet;
    TS_Orders: TTabSheet;
    Label8: TLabel;
    Ed_NavFolder: TEdit;
    SpB_NavFolder: TSpeedButton;
    SpB_FilesRefresh: TSpeedButton;
    IL_Gerb: TImageList;
    PM_Town: TPopupMenu;
    N_Town_Msc: TMenuItem;
    N_Town_SpB: TMenuItem;
    SpB_ShowColumns: TSpeedButton;
    DrGr_Route: TDrawGrid;
    SpB_ShowInExcel: TSpeedButton;
    DrGr_Order: TDrawGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Ed_NavFolderChange(Sender: TObject);
    procedure SpB_NavFolderClick(Sender: TObject);
    procedure SpB_FilesRefreshClick(Sender: TObject);

    procedure LoadFiles(Sender : TObject);
    procedure SpB_ShowInExcelClick(Sender: TObject);

    procedure DrGr_RouteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrGr_OrderDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);

  private
    function LoadSettings : boolean;
    function SaveSettings : boolean;

    procedure CheckReadyTowns;
    procedure ShowNavResFileInExcel(const aFileName : string);
  public
    { Public declarations }
  end;

const
  baseSection      : string = 'Settings';
  FontColor        : array[boolean] of TColor = (clWindowText, clHighlightText);
  BrushColor       : array[boolean] of TColor = (clWindow, clHighlight);
  FontColorSearch  : array[boolean, boolean] of TColor = ((clSilver, clPaleGray),(clWindowText, clHighlightText));
  BrushColorSearch : array[boolean, boolean] of TColor = ((clWindow, clInfoBk)  ,(clWindow    , clHighlight));
  dlmFields        : char = '|'; // -- разделитель полей
  dlmArr           : char = DegreeChar;

  fnRoute_Msc   : string = 'd__route0.txt';
  fnOrder_Msc   : string = 'd__orders0.txt';
  fnRoute_SpB   : string = 'd__route0_SpB.txt';
  fnOrder_SpB   : string = 'd__orders0_SpB.txt';

var
  _Main       : T_Main;
  MainWindow  : cardinal = 0;
(* -- Settings block. Begin --------------------- *)
  rcWidth   : array[TRouteCol] of integer;
  rcVisible : array[TRouteCol] of boolean;
  ocWidth   : array[TOrderCol] of integer;
  ocVisible : array[TOrderCol] of boolean;

(* -- Settings block. End ----------------------- *)
 Route : TRoute;
 RouteColumns : array[TRouteCol] of TColInfo = (
 ((*bsIndex  :  0; dspIndex :  0;*)  navName : ''              ; title : '№ п/п'         ; datatype : cdtInteger ; width : 25; visible: True),
 ((*bsIndex  :  1; dspIndex :  1;*)  navName : 'DATE_ROUTE'    ; title : 'Дата'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  2; dspIndex :  2;*)  navName : 'ROUTE_NUM'     ; title : '№ маршрута'    ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  :  3; dspIndex :  3;*)  navName : 'NAME'          ; title : 'NAME'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  4; dspIndex :  4;*)  navName : 'LEN'           ; title : 'LEN'           ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  :  5; dspIndex :  5;*)  navName : 'TIME_LEN'      ; title : 'TIME_LEN'      ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  6; dspIndex :  6;*)  navName : 'TIME_START'    ; title : 'TIME_START'    ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  7; dspIndex :  7;*)  navName : 'OGRSUM1'       ; title : 'OGRSUM1'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  :  8; dspIndex :  8;*)  navName : 'OGRSUM2'       ; title : 'OGRSUM2'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  :  9; dspIndex :  9;*)  navName : 'SUM3'          ; title : 'SUM3'          ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 10; dspIndex : 10;*)  navName : 'SUM4'          ; title : 'SUM4'          ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 11; dspIndex : 11;*)  navName : 'NUM_POINT'     ; title : 'NUM_POINT'     ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 12; dspIndex : 12;*)  navName : 'PROCM'         ; title : 'PROCM'         ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 13; dspIndex : 13;*)  navName : 'VOL_PROCM'     ; title : 'VOL_PROCM'     ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 14; dspIndex : 14;*)  navName : 'ZONE'          ; title : 'ZONE'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 15; dspIndex : 15;*)  navName : 'ACTIVE'        ; title : 'ACTIVE'        ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 16; dspIndex : 16;*)  navName : 'ROUTE_COST'    ; title : 'ROUTE_COST'    ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 17; dspIndex : 17;*)  navName : 'STR1'          ; title : 'STR1'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 18; dspIndex : 18;*)  navName : 'STR2'          ; title : 'STR2'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 19; dspIndex : 19;*)  navName : 'TRIP_NO'       ; title : 'TRIP_NO'       ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 20; dspIndex : 20;*)  navName : 'CAR_ID'        ; title : 'CAR_ID'        ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 21; dspIndex : 21;*)  navName : 'STORE_ID'      ; title : 'STORE_ID'      ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 22; dspIndex : 22;*)  navName : 'ID'            ; title : 'ID'            ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 23; dspIndex : 23;*)  navName : 'DRIVER'        ; title : 'DRIVER'        ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 24; dspIndex : 24;*)  navName : 'DRIVER_ID'     ; title : 'DRIVER_ID'     ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 25; dspIndex : 25;*)  navName : 'CAR_NAME'      ; title : 'CAR_NAME'      ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 26; dspIndex : 26;*)  navName : 'REG_NO_NUM'    ; title : 'REG_NO_NUM'    ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 27; dspIndex : 27;*)  navName : 'UDOSTOVERENIE' ; title : 'UDOSTOVERENIE' ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 28; dspIndex : 28;*)  navName : 'REG_NO_SER'    ; title : 'REG_NO_SER'    ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 29; dspIndex : 29;*)  navName : 'REG_NO_NO'     ; title : 'REG_NO_NO'     ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 30; dspIndex : 30;*)  navName : 'ORGANIZATION'  ; title : 'ORGANIZATION'  ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 31; dspIndex : 31;*)  navName : 'CAR_NUM '      ; title : 'CAR_NUM '      ; datatype : cdtText    ; width : 60; visible: True)
 );

 Order : TOrder;
 OrderColumns : array[TOrderCol] of TColInfo = (
 ((*bsIndex  :  0; dspIndex :  0;*) navName : ''              ; title : ''              ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  :  1; dspIndex :  1;*) navName : 'EXT_STRID'     ; title : 'EXT_STRID'     ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  2; dspIndex :  2;*) navName : 'CUST_ID'       ; title : 'CUST_ID'       ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  3; dspIndex :  3;*) navName : 'UNLOAD_TYP'    ; title : 'UNLOAD_TYP'    ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  :  4; dspIndex :  4;*) navName : 'ORD_TYP'       ; title : 'ORD_TYP'       ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  :  5; dspIndex :  5;*) navName : 'CATEGORY_ID'   ; title : 'CATEGORY_ID'   ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  :  6; dspIndex :  6;*) navName : 'TIME_BEG'      ; title : 'TIME_BEG'      ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  7; dspIndex :  7;*) navName : 'TIME_END'      ; title : 'TIME_END'      ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  8; dspIndex :  8;*) navName : 'TIME_UNLOAD'   ; title : 'TIME_UNLOAD'   ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  :  9; dspIndex :  9;*) navName : 'ACTIVE'        ; title : 'ACTIVE'        ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 10; dspIndex : 10;*) navName : 'OGRSUM1'       ; title : 'OGRSUM1'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 11; dspIndex : 11;*) navName : 'OGRSUM2'       ; title : 'OGRSUM2'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 12; dspIndex : 12;*) navName : 'SUM3'          ; title : 'SUM3'          ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 13; dspIndex : 13;*) navName : 'SUM4'          ; title : 'SUM4'          ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 14; dspIndex : 14;*) navName : 'ADDR'          ; title : 'ADDR'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 15; dspIndex : 15;*) navName : 'DISTR'         ; title : 'DISTR'         ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 16; dspIndex : 16;*) navName : 'TOWN'          ; title : 'TOWN'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 17; dspIndex : 17;*) navName : 'STREET'        ; title : 'STREET'        ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 18; dspIndex : 18;*) navName : 'HOUS'          ; title : 'HOUS'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 19; dspIndex : 19;*) navName : 'CORP'          ; title : 'CORP'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 20; dspIndex : 20;*) navName : 'STR1'          ; title : 'STR1'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 21; dspIndex : 21;*) navName : 'STR2'          ; title : 'STR2'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 22; dspIndex : 22;*) navName : 'STR3'          ; title : 'STR3'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 23; dspIndex : 23;*) navName : 'STR4'          ; title : 'STR4'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 24; dspIndex : 24;*) navName : 'STR5'          ; title : 'STR5'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 25; dspIndex : 25;*) navName : 'STR6'          ; title : 'STR6'          ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 26; dspIndex : 26;*) navName : 'INT1'          ; title : 'INT1'          ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 27; dspIndex : 27;*) navName : 'INT2'          ; title : 'INT2'          ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 28; dspIndex : 28;*) navName : 'INT3'          ; title : 'INT3'          ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 29; dspIndex : 29;*) navName : 'MAX_CAR'       ; title : 'MAX_CAR'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 30; dspIndex : 30;*) navName : 'MIN_CAR'       ; title : 'MIN_CAR'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 31; dspIndex : 31;*) navName : 'DELIV_DATE'    ; title : 'DELIV_DATE'    ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 32; dspIndex : 32;*) navName : 'ROUTE_ID'      ; title : 'ROUTE_ID'      ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 33; dspIndex : 33;*) navName : 'ROUTE_NUM'     ; title : 'ROUTE_NUM'     ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 34; dspIndex : 34;*) navName : 'NUM_INROUTE'   ; title : 'NUM_INROUTE'   ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 35; dspIndex : 35;*) navName : 'DISTANC'       ; title : 'DISTANC'       ; datatype : cdtDecimal ; width : 60; visible: True),
 ((*bsIndex  : 36; dspIndex : 36;*) navName : 'TIME_ARR'      ; title : 'TIME_ARR'      ; datatype : cdtText    ; width : 60; visible: True),
 ((*bsIndex  : 37; dspIndex : 37;*) navName : 'X'             ; title : 'X'             ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 38; dspIndex : 38;*) navName : 'Y'             ; title : 'Y'             ; datatype : cdtInteger ; width : 60; visible: True),
 ((*bsIndex  : 39; dspIndex : 39;*) navName : 'LINKED'        ; title : 'LINKED'        ; datatype : cdtInteger ; width : 60; visible: True)
 );

implementation

{$R *.dfm}

(* --- TYPES ------------------------------------------------------------------------------------ *)


 function TRoute.LoadFromFile(const aFileName : string) : integer;
 var
  strl : TStringList;
  cnt  : integer;
  ind  : integer;
  sda  : TStringDynArray;
  rcCnt: TRouteCol;
 begin
 Result:=-1;
 try
 Clear;
 strl:=TStringList.Create;
 try
 strl.LoadFromFile(aFileName);
 for cnt:=0 to strl.count-1
   do begin
   sda:=SplitString(OEMtoAnsi(Ansistring(IntToStr(cnt+1)+dlmFields+strl[cnt])),dlmFields);
   if High(sda)=integer(High(TRouteCol))
      then begin
      ind:=Length(Rows);
      SetLength(Rows,ind+1);
      for rcCnt:=Low(TRouteCol) to High(TRouteCol)
         do Rows[ind,rcCnt]:=shortstring(sda[integer(rcCnt)]); // -- тут можно анализировать данные и подменять DecimalSeparator, где это нужно
      end;
   end;
 finally
 FreeStringList(strl);
 end;
 Result:=Length(Rows);
 except
 on E : Exception do LogErrorMessage('TRoute.LoadFromFile',E,[aFileName]);
 end;
 end;


// function TRoute.Arrange(aColIndex  :integer; aDesc : boolean): boolean;
//
 procedure TRoute.Clear;
 begin
 try
 SetLength(Rows,0);
 except
 on E : Exception do LogErrorMessage('TRoute.Clear',E,[]);
 end;
 end;

function TOrder.LoadFromFile(const aFileName : string) : integer;
 var
  strl : TStringList;
  cnt  : integer;
  sda  : TStringDynArray;
 begin
 Result:=-1;
 try
 strl:=TStringList.Create;
 try
 for cnt:=0 to strl.count-1
   do begin
   sda:=SplitString(strl[cnt],'|');
   if High(sda)=integer(High(TOrderCol))
      then begin


      end;
   end;



 finally
 FreeStringList(strl);
 end;
 Result:=Length(Rows);
 except
 on E : Exception do LogErrorMessage('TOrder.LoadFromFile',E,[aFileName]);
 end;
 end;



(* ---  PRIVATE --------------------------------------------------------------------------------- *)






function T_Main.LoadSettings : boolean;
var
 inm   : string;
 fld   : string;
 cnt   : integer;
 sda   : TStringDynArray;
 rcCnt       : TRouteCol;
 str_rcWidth : string;
 str_rcVis   : string;
 ocCnt       : TOrderCol;
 str_ocWidth : string;
 str_ocVis   : string;
begin
Result:=False;
try

inm:=AppParams.CFGCommonFileName;
with TINIFile.Create(inm) do
  try
  (*......*)
  finally
  Free;
  end;

inm:=SetTailBackSlash(UpDirectoryN(ExtractFilePath(AppParams.CFGUserFileName),1))+'Router\Router.ini';
fld:='';
if FileExists(fld)
   then LoadString('Settings','NAV_ExportFolder',fld,inm)
   else fld:=GetDesktopFolder;

inm:=AppParams.CFGUserFileName;
SetDoubleBuffered(self);
RestorePosition(self,inm);
RestorePageControl(self, PC_Main, inm);



// -- заполняем по умолчанию (Route)
DrGr_Route.ColCount := Length(RouteColumns);
str_rcWidth:='';
str_rcVis:='';
for rcCnt:=Low(TRouteCol) to High(TRouteCol)
  do begin
  rcWidth[rcCnt]:=60;
  str_rcWidth:=str_rcWidth+IntToStr(rcWidth[rcCnt])+dlmArr;
  rcVisible[rcCnt]:=true;
  str_rcVis:=str_rcVis+IntToStr(integer(rcVisible[rcCnt]))+dlmArr;
  end;
SetLength(str_rcWidth,Length(str_rcWidth)-1);
SetLength(str_rcVis,Length(str_rcVis)-1);

// -- заполняем по умолчанию (Order)
DrGr_Order.ColCount := Length(OrderColumns);
str_ocWidth:='';
str_ocVis:='';
for ocCnt:=Low(TOrderCol) to High(TOrderCol)
  do begin
  ocWidth[ocCnt]:=60;
  str_ocWidth:=str_ocWidth+IntToStr(ocWidth[ocCnt])+dlmArr;
  ocVisible[ocCnt]:=true;
  str_ocVis:=str_ocVis+IntToStr(integer(ocVisible[ocCnt]))+dlmArr;
  end;
SetLength(str_ocWidth,Length(str_ocWidth)-1);
SetLength(str_ocVis,Length(str_ocVis)-1);

with TINIFile.Create(inm) do
  try
  sda:=SplitString(ReadString(baseSection,'rcWidth',str_rcWidth),dlmArr);
  for cnt:=0 to High(sda)
    do if CheckValidInteger(sda[cnt]) and
          ((cnt>=integer(Low(TRouteCol))) and (cnt<=integer(High(TRouteCol))))
          then rcWidth[TRouteCol(cnt)]:=strToInt(sda[cnt]);
  sda:=SplitString(ReadString(baseSection,'rcVisible',str_rcVis),dlmArr);
  for cnt:=0 to High(sda)
    do if CheckValidInteger(sda[cnt]) and
          ((cnt>=integer(Low(TRouteCol))) and (cnt<=integer(High(TRouteCol))))
          then rcVisible[TRouteCol(cnt)]:=boolean(strToInt(sda[cnt]));
  sda:=SplitString(ReadString(baseSection,'ocWidth',str_ocWidth),dlmArr);
  for cnt:=0 to High(sda)
    do if CheckValidInteger(sda[cnt]) and
          ((cnt>=integer(Low(TOrderCol))) and (cnt<=integer(High(TOrderCol))))
          then ocWidth[TOrderCol(cnt)]:=strToInt(sda[cnt]);
  sda:=SplitString(ReadString(baseSection,'ocVisible',str_ocVis),dlmArr);
  for cnt:=0 to High(sda)
    do if CheckValidInteger(sda[cnt]) and
          ((cnt>=integer(Low(TOrderCol))) and (cnt<=integer(High(TOrderCol))))
          then ocVisible[TOrderCol(cnt)]:=boolean(strToInt(sda[cnt]));
  (*......*)
  finally
  Free;
  end;

// -- устанавливаем загруженные (Route)
rcWidth[rc_NUM_SEQUENCE]:= 20;
rcVisible[rc_NUM_SEQUENCE]:= true;
for rcCnt:=Low(TRouteCol) to High(TRouteCol)
  do begin
  RouteColumns[rcCnt].width:= rcWidth[rcCnt];
  RouteColumns[rcCnt].visible:= rcVisible[rcCnt];
  if RouteColumns[rcCnt].visible
     then DrGr_Route.ColWidths[integer(rcCnt)]:=RouteColumns[rcCnt].width
     else DrGr_Route.ColWidths[integer(rcCnt)]:=-1;
  end;
ocWidth[oc_NUM_SEQUENCE]:= 20;
ocVisible[oc_NUM_SEQUENCE]:= true;
for ocCnt:=Low(TOrderCol) to High(TOrderCol)
  do begin
  OrderColumns[ocCnt].width:= ocWidth[ocCnt];
  OrderColumns[ocCnt].visible:= ocVisible[ocCnt];
  if OrderColumns[ocCnt].visible
     then DrGr_Order.ColWidths[integer(ocCnt)]:=OrderColumns[ocCnt].width
     else DrGr_Order.ColWidths[integer(ocCnt)]:=-1;
  end;

Ed_NavFolder.Text:=fld;
Result:=True;
except
  on E : Exception do LogErrorMessage('T_Main.LoadSettings',E,[inm]);
end
end;


function T_Main.SaveSettings : boolean;
var
 inm : string;
 cnt : integer;
 rcCnt       : TRouteCol;
 str_rcWidth : string;
 str_rcVis   : string;
 ocCnt       : TOrderCol;
 str_ocWidth : string;
 str_ocVis   : string;
begin
Result:=False;
inm:='';
try

// -- сохранение настроек DrGr_Route
str_rcWidth:='';
str_rcVis:='';
for cnt:=0 to DrGr_Route.ColCount-1
  do begin
  RouteColumns[TRouteCol(cnt)].visible:=true;
  if DrGr_Route.ColWidths[cnt]=-1
     then begin
     DrGr_Route.ColWidths[cnt]:=RouteColumns[TRouteCol(cnt)].width;
     RouteColumns[TRouteCol(cnt)].visible:=false;
     end;
  RouteColumns[TRouteCol(cnt)].width:=DrGr_Route.ColWidths[cnt];
  end;
for rcCnt:=Low(TRouteCol) to High(TRouteCol)
  do begin
  str_rcWidth:=str_rcWidth+IntToStr(RouteColumns[rcCnt].width)+dlmArr;
  str_rcVis:=str_rcVis+IntToStr(integer(RouteColumns[rcCnt].visible))+dlmArr;
  end;

// -- сохранение настроек DrGr_Order
str_ocWidth := '';
str_ocVis   := '';
for cnt:=0 to DrGr_Order.ColCount-1
  do begin
  OrderColumns[TOrderCol(cnt)].visible:=true;
  if DrGr_Order.ColWidths[cnt]=-1
     then begin
     DrGr_Order.ColWidths[cnt]:=OrderColumns[TOrderCol(cnt)].width;
     OrderColumns[TOrderCol(cnt)].visible:=false;
     end;
  OrderColumns[TOrderCol(cnt)].width:=DrGr_Order.ColWidths[cnt];
  end;
for ocCnt:=Low(TOrderCol) to High(TOrderCol)
  do begin
  str_ocWidth:=str_ocWidth+IntToStr(OrderColumns[ocCnt].width)+dlmArr;
  str_ocVis:=str_ocVis+IntToStr(integer(OrderColumns[ocCnt].visible))+dlmArr;
  end;

inm:=AppParams.CFGUserFileName;
with TINIFile.Create(inm) do
  try
  WriteString(baseSection,'rcWidth',str_rcWidth);
  WriteString(baseSection,'rcVisible',str_rcVis);
  WriteString(baseSection,'ocWidth',str_ocWidth);
  WriteString(baseSection,'ocVisible',str_ocVis);
  finally
  Free;
  end;

//SaveColumns(self,DrGr_UserList,inm);
//SavePosition(GrB_Perm_UserList,inm);
//
//SaveColumns(self,DrGr_UFL,inm);
SavePageControl(self, PC_Main, inm);
SavePosition(self,inm);
Result:=True;
except
  on E : Exception do LogErrorMessage('T_Main.SaveSettings',E,[inm]);
end
end;


procedure T_Main.CheckReadyTowns;
begin
try
N_Town_Msc.Visible:=FileExists(Ed_NavFolder.Text+fnRoute_Msc) or FileExists(Ed_NavFolder.Text+fnOrder_Msc);
N_Town_Spb.Visible:=FileExists(Ed_NavFolder.Text+fnRoute_SpB) or FileExists(Ed_NavFolder.Text+fnOrder_SpB);
except
  on E : Exception do LogErrorMessage('T_Main.CheckReadyTowns',E,[]);
end
end;


procedure T_Main.ShowNavResFileInExcel(const aFileName : string);
var
 str    : string;
 strl   : TStringList;
 src    : array of TStringDynArray;
 ind    : integer;
 cnt    : integer;
 rcCnt  : TRouteCol;
 ocCnt  : TOrderCol;
 col    : integer;
 dest   : variant;
 cntCol : integer;
 ds     : char;
 title  : string;
 errstr : string;
begin
errstr:='';
try
if not FileExists(aFileName) then Exit;
str:=LoadStringFromFileStream(aFileName);
str:=OEMToAnsi(AnsiString(str));
ds:=FormatSettings.DecimalSeparator;
strl:=TStringList.Create;
try
strl.Text:=str;
SetLength(src, 0);
col:=0;
for cnt:=0 to strl.Count-1
 do begin
 if trim(strl[cnt])='' then Continue;
 ind:=Length(src);
 SetLength(src,ind+1);
 src[ind]:=SplitString(IntToStr(ind+1)+dlmFields+trim(strl[cnt]),dlmFields);
 if col<Length(src[ind]) then col:=Length(src[ind]);
 end;
title:=AnsiUpperCase(ExtractFileName(aFileName));
dest:=VarArrayCreate([0,1+Length(src),0,col],varVariant);

if (Pos(UpperCase(fnRoute_Msc), Title)<>0) or (Pos(UpperCase(fnRoute_SpB), Title)<>0)
   then for rcCnt:=Low(TRouteCol) to High(TRouteCol)
         do dest[0,integer(rcCnt)]:=RouteColumns[rcCnt].navName
   else
if (Pos(UpperCase(fnOrder_Msc), Title)<>0) or (Pos(UpperCase(fnOrder_SpB), Title)<>0)
   then for ocCnt:=Low(TOrderCol) to High(TOrderCol)
         do dest[0,integer(ocCnt)]:=OrderColumns[ocCnt].navName
   else for cntCol:=0 to col-1
         do dest[0,cntCol]:='Column '+FormatFloat('000',cntCol+1);
ind:=1;
FormatSettings.DecimalSeparator:=',';
for cnt:= Low(src) to High(Src)
  do begin
  for cntCol:=0 to High(src[cnt])
    do try
        if CheckValidInteger(src[cnt,cntCol])
          then dest[ind, cntCol]:=StrToInt64(src[cnt,cntCol])
          else
        if CheckValidFloat(src[cnt,cntCol])
          then dest[ind, cntCol]:=StrToFloat(src[cnt,cntCol])
          else dest[ind, cntCol]:=src[cnt,cntCol];
        except
        on E : Exception do errstr:=errstr+src[cnt,cntCol]+';';
        end;
  inc(ind);
  end;


ArrayVariantToExcelEx(ExtractFileName(aFileName),dest,1);
finally
if not VarIsEmpty(dest) then VarArrayRedim(dest,0);
dest:=Unassigned;
FreeStringList(strl);
FormatSettings.DecimalSeparator:=ds;
end;
if errstr<>'' then raise Exception.Create('Заполнение массива значений.');
except
on E : Exception do LogErrorMessage('T_Main.ShowNavResFileInExcel',E,[aFileName, errstr]);
end;
end;



(* ---  PUBLIC ---------------------------------------------------------------------------------- *)


(* --- FORM ------------------------------------------------------------------------------------- *)



procedure T_Main.FormCreate(Sender: TObject);
begin
try
MainWindow:=Handle;
LoadSettings;

except
  on E : Exception do LogErrorMessage('T_Main.FormCreate',E,[]);
end
end;


procedure T_Main.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
try
case Key of
VK_ESCAPE : Close;
end;

except
  on E : Exception do LogErrorMessage('T_Main.FormKeyUp',E,[]);
end
end;

procedure T_Main.FormPaint(Sender: TObject);
var
 dc : hDC;
begin
try
dc:=GetWindowDC(MainWindow);
try
{......}
finally
ReleaseDC(MainWindow, dc);
end;
except
  on E : Exception do LogErrorMessage('T_Main.FormPaint',E,[]);
end
end;

procedure T_Main.FormResize(Sender: TObject);
begin
try
if not ReportMemoryLeaksOnShutdown
   then begin
   Height:=(Height-ClientHeight)+Ed_NavFolder.Top+Ed_NavFolder.Height+4;
   Constraints.MinHeight:=Height;
   Constraints.MaxHeight:=Height;
   end
   else begin
   PC_Main.Height:=ClientHeight - PC_main.Top -4;
   end;
Invalidate;
except
  on E : Exception do LogErrorMessage('T_Main.FormResize',E,[]);
end
end;



procedure T_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
try
CanClose:=false;
try

finally
CanClose:=True;
end;
except
  on E : Exception do LogErrorMessage('T_Main.FormCloseQuery',E,[]);
end
end;



procedure T_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
try
if MainWindow=0 then Exit;
MainWindow:=0;


SaveSettings;
except
  on E : Exception do LogErrorMessage('T_Main.FormClose',E,[]);
end
end;
(* --- VCL -------------------------------------------------------------------------------------- *)




procedure T_Main.Ed_NavFolderChange(Sender: TObject);
var
 nt : TNotifyEvent;
begin
try
if (Ed_NavFolder.Text<>'') and (Ed_NavFolder.Text[Length(Ed_NavFolder.Text)]<>'\')
   then begin
   nt:=Ed_NavFolder.OnChange;
   Ed_NavFolder.OnChange:=nil;
   try
   Ed_NavFolder.Text:=SetTailbackSlash(Ed_NavFolder.Text);
   finally
   Ed_NavFolder.OnChange:=nt;
   end;
   end;
if DirectoryExists(Ed_NavFolder.Text)
   then begin
   if FileExists(Ed_NavFolder.Text+fnRoute_Msc) or
      FileExists(Ed_NavFolder.Text+fnOrder_Msc) or
      FileExists(Ed_NavFolder.Text+fnRoute_SpB) or
      FileExists(Ed_NavFolder.Text+fnOrder_SpB)
      then Ed_NavFolder.Color:=clPaleGreen
      else Ed_NavFolder.Color:=clPaleYellow
   end
   else Ed_NavFolder.Color:=clPaleRed;
CheckReadyTowns;
except
  on E : Exception do LogErrorMessage('T_Main.Ed_NavFolderChange',E,[]);
end
end;




procedure T_Main.SpB_NavFolderClick(Sender: TObject);
var
 fld : string;
begin
try
LoadString('Settings','NavisionFolder',fld,AppParams.CFGUserFileName);
if ((fld='') and (Ed_NavFolder.Text=''))then fld:=GetTempFolder else
if ((fld='') and (DirectoryExists(Ed_NavFolder.Text)))then fld:=Ed_NavFolder.Text else
if ((fld<>'') and (not DirectoryExists(fld)))then fld:=GetFirstExistsFolder(fld) else ;
fld:=SetFolder(Handle,'',PChar(fld),'Папка с файлами для Navision');
if fld<>''
   then begin
   fld:=SetTailBackSlash(fld);
   Ed_NavFolder.Text:=fld;
   SaveString('Settings','NavisionFolder',fld,AppParams.CFGUserFileName);
   end;
except
  on E : Exception do LogErrorMessage('T_Main.SpB_NavFolderClick',E,[]);
end
end;




procedure T_Main.SpB_FilesRefreshClick(Sender: TObject);
begin
if N_Town_Msc.Visible and N_Town_SpB.Visible
   then ShowPopupMenu(SpB_FilesRefresh,PM_Town)
   else
if N_Town_Msc.Visible
   then LoadFiles(N_Town_Msc)
   else
if N_Town_SpB.Visible
   then LoadFiles(N_Town_SpB)
   else ShowMessageInfo(Format('В папке "%s" файлов для загрузки не обнаружено.',[Ed_NavFolder.Text]),'Сообщение')
end;

procedure T_Main.LoadFiles(Sender : TObject);
var
 res : integer;
begin
try
if Sender=N_Town_Msc
   then begin
   res:=Route.LoadFromFile(Ed_NavFolder.Text+fnRoute_Msc);
   DrGr_Route.RowCount:=1+res+integer(res=0);
   DrGr_Route.Repaint;



   Order.LoadFromFile(Ed_NavFolder.Text+fnOrder_Msc);
   end
else
if Sender = N_Town_SpB
   then begin

   end
else ;
except
on E : Exception do LogErrorMessage('T_Main.LoadFiles',E,[AboutObject(Sender)]);
end;
end;

procedure T_Main.SpB_ShowInExcelClick(Sender: TObject);
var
 fn : string;
begin
fn:=Ed_NavFolder.Text+'d__*.txt';
try
if not SelectFileName(fn,'d__*.txt',false) then Exit;
ShowNavResFileInExcel(fn);
except
on E : Exception do LogErrorMessage('T_Main.SpB_ShowInExcelClick',E,[fn]);
end;
end;


procedure T_Main.DrGr_RouteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
 str : string;
 rct : Trect;
 alg : integer;
 sel : boolean;
// fnd : boolean;
 ind : integer;
begin
ind:=-1;
str:='';
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
alg:=DT_LEFT_ALIGN;
try
try
case ARow of
0 :
  begin
  if (ACol>=integer(Low(TRouteCol))) and (ACol<=integer(High(TRouteCol)))
     then str:=IntToStr(ACol)+'. '+string(RouteColumns[TRouteCol(ACol)].navName);
  end;
else begin
sel:=(gdSelected in State) or (gdFocused in State);
with DrGr_Route.Canvas do
  begin
  Font.Color:=FontColor[sel];
  Brush.Color:=BrushColor[sel];
  end;
ind:=ARow-1;
if (ind<Low(Route.Rows)) or (ind>High(Route.Rows)) then Exit;
if (ACol>=integer(Low(TRouteCol))) and (ACol<=integer(High(TRouteCol)))
   then begin
   // -- можно тип данных проанализировать и конвертнуть.....
   str:=string(Route.Rows[ind,TRouteCol(ACol)]);
   if (RouteColumns[TRouteCol(ACol)].datatype=cdtInteger) or
      (RouteColumns[TRouteCol(ACol)].datatype=cdtDecimal)
      then alg:=DT_RIGHT_ALIGN;
   end;
end;
end;
finally
with DrGr_Route.Canvas do
  begin
  if ARow=0
     then
     else begin
//     if Ed_Search.Hint<>''
//        then begin
//        sel:=(gdSelected in State) or (gdFocused in State);
//        fnd:=(AnsiPos(Ed_Search.Hint,AnsiUpperCase(str))>0);
//        with DrGr_UserList.Canvas do
//          begin
//          Font.Color:=FontColorSearch[sel,fnd];
//          Brush.Color:=BrushColorSearch[sel,fnd];
//          end;
//        end;
     end;
  Windows.FillRect(Handle, Rect, Brush.Handle);
  if ind>-1 then ;
  DrawTransparentText(Handle, str, rct, alg);
  end;
end;

except
on E : Exception
   do begin
   LogErrorMessage('T_Main.DrGr_RouteDrawCell', E, [ACol, ARow])
   end
end;
end;



procedure T_Main.DrGr_OrderDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
 str : string;
 rct : Trect;
 alg : integer;
 sel : boolean;
// fnd : boolean;
 ind : integer;
begin
ind:=-1;
str:='';
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
alg:=DT_LEFT_ALIGN;
try
try
case ARow of
0 :
  begin
  if (ACol>=integer(Low(TOrderCol))) and (ACol<=integer(High(TOrderCol)))
     then str:=IntToStr(ACol)+'. '+string(OrderColumns[TOrderCol(ACol)].navName);
  end;
else begin
sel:=(gdSelected in State) or (gdFocused in State);
with DrGr_Order.Canvas do
  begin
  Font.Color:=FontColor[sel];
  Brush.Color:=BrushColor[sel];
  end;
ind:=ARow-1;
if (ind<Low(Order.Rows)) or (ind>High(Order.Rows)) then Exit;
if (ACol>=integer(Low(TOrderCol))) and (ACol<=integer(High(TOrderCol)))
   then begin
   // -- можно тип данных проанализировать и конвертнуть.....
   str:=string(Order.Rows[ind,TOrderCol(ACol)]);
   if (OrderColumns[TOrderCol(ACol)].datatype=cdtInteger) or
      (OrderColumns[TOrderCol(ACol)].datatype=cdtDecimal)
      then alg:=DT_RIGHT_ALIGN;
   end;
end;
end;
finally
with DrGr_Order.Canvas do
  begin
  if ARow=0
     then
     else begin
//     if Ed_Search.Hint<>''
//        then begin
//        sel:=(gdSelected in State) or (gdFocused in State);
//        fnd:=(AnsiPos(Ed_Search.Hint,AnsiUpperCase(str))>0);
//        with DrGr_UserList.Canvas do
//          begin
//          Font.Color:=FontColorSearch[sel,fnd];
//          Brush.Color:=BrushColorSearch[sel,fnd];
//          end;
//        end;
     end;
  Windows.FillRect(Handle, Rect, Brush.Handle);
  if ind>-1 then ;
  DrawTransparentText(Handle, str, rct, alg);
  end;
end;

except
on E : Exception
   do begin
   LogErrorMessage('T_Main.DrGr_OrderDrawCell', E, [ACol, ARow])
   end
end;
end;
end.
