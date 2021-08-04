unit U_Main;
(*LEVEL-INTERVAL*)  // -- запрос на получение интервала доставки, свзяб уровня области с возможностью установки доставки
(*DELETED AREAS*)   // -- где-то надо (20140827) сделать переключатель отображения удаленных (Abs(aLevel)*-1)
(*FOR DELETE*)
(*CHECK OF INTERVALS OVERLAPING*)
interface

// --- основные процедуры -------------------------------
// FillAreaInfo(const aAreaXML : string); -- загрузка текущей области с карты или из БД

uses
  Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , INIFiles
  , ActnList
  , Menus
  , ToolWin
  , ComCtrls
  , ImgList
  , types
  , ExtCtrls
  , AppLogNew, FnADODB, FnCommon, AreaEditor_Types
  , OleCtrls, SHDocVw, MSHTML
  , StdCtrls
  , StrUtils
  , Panels
  , CheckLst
  , Buttons
  , Dialogs
  , Grids
  , Spin
  , DateUtils
  , CategoryButtons
  , InvDrawGrid
  , U_DTP_Editor
  , Clipbrd
  , Math
  , IntervalEx
  , DB, ADODB
  , Generics.Defaults, Generics.Collections
  , ExtShape




  ;


type
  PSpeedButtonMode = ^TSpeedButtonMode;
  TSpeedButtonMode = record
   IsEnabled  : boolean;
   IsClose    : boolean;
   ImageList  : TImageList;
   proc       : TNotifyEvent;
   glyphs     : array of integer;
  end;


// new
type
  TSzPanForm = class(TForm)
   procedure SzPanFormFormClose(Sender: TObject; var Action: TCloseAction);
  end;


  TSzPanPosItem = record
    Pan       : TSizedPanel;
    StdRect   : TRect; // -- стандартная позиция на главной форме
    ParentForm: TSzPanForm;
  end;



  TSzPanPosList = record
    Items : array of TSzPanPosItem; // -- without generics: no need in their methods
    function GetOutBtn(aSzPanel : TsizedPanel; const aName : string) : TSpeedButton;
    procedure Fill(aParent : TWinControl);
    function GetIndex(aHandle : cardinal) : integer;
    procedure UpdateStdRect(aIndex : integer); overload;
    function IsOut(aSzPanel : TSizedPanel) : boolean;
    procedure SetOut(aIndex : integer); overload;
    procedure SetOut(aSzPanel : TSizedPanel); overload;
    procedure SetIn(aIndex : integer); overload;
    procedure SetIn(aSzPanel : TSizedPanel);  overload;
    procedure ShowOutBtn(aSzPanel : TSizedPanel; aShow : boolean);
    procedure Restore;
    procedure Clear;
  end;


type
  T_Main = class(TForm)
    MM_Main: TMainMenu;
    ActList_Main: TActionList;
    IL_Enabled: TImageList;
    NMap: TMenuItem;
    Act_Сlose: TAction;
    IL_Disabled: TImageList;
    Act_Refresh: TAction;
    Act_Filter: TAction;
    Pan_WB: TPanel;
    WB: TWebBrowser;
    Act_LogShow: TAction;
    Lab_Coord: TLabel;
    SzPan_Filter: TSizedPanel;
    PC_Filter: TPageControl;
    TS_Filter_Names: TTabSheet;
    TS_Filter_Parents: TTabSheet;
    TS_Filter_Options: TTabSheet;
    ChLB_Areas_Names: TCheckListBox;
    BB_Filter_Close: TBitBtn;
    Ed_Filter_Find: TEdit;
    Lab_Filter_Find: TLabel;
    TV_Area: TTreeView;
    IL_Paint: TImageList;
    SpB_ChkAll: TSpeedButton;
    SpB_UnChkAll: TSpeedButton;
    SpB_RevAll: TSpeedButton;
    PM_Agent: TPopupMenu;
    N_Agent1: TMenuItem;
    N_Agent13: TMenuItem;
    IL_Gerb: TImageList;
    SzPan_Deliverys: TSizedPanel;
    DTP_DeliveryDate: TDateTimePicker;
    SpB_DeliveryAgent: TSpeedButton;
    LabT_DeliverysTitle: TLabel;
    DrGr_CarsList: TDrawGrid;
    Ed_CarListSearch: TEdit;
    SpB_DeliveryRefresh: TSpeedButton;
    Lab_Deliverys_Find: TLabel;
    SzPan_Area: TSizedPanel;
    Mem_XML: TMemo;
    Pan_ReqData: TPanel;
    SpB_Mode_Delivery: TSpeedButton;
    SpB_Mode_Map: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpB_ViewFiltered_Filter: TSpeedButton;
    Act_ShowFiltered: TAction;
    SpB_ShowMarkers: TSpeedButton;
    SpB_ShowRoute: TSpeedButton;
    BB_Delivery_Close: TBitBtn;
    GB_Intervals: TGroupBox;
    DrGr_AreaIntervalList: TDrawGrid;
    BB_Area_Close: TBitBtn;
    SpB_Area_DopFuncs: TSpeedButton;
    NClose: TMenuItem;
    NMap_Refresh: TMenuItem;
    NMap_PrintPreview: TMenuItem;
    PM_Area: TPopupMenu;
    NArea_Add: TMenuItem;
    NArea_Edit: TMenuItem;
    NArea_Del: TMenuItem;
    NArea_Save: TMenuItem;
    N1: TMenuItem;
    Lab_DeliveryDate: TLabel;
    Im_DeliveryAgent: TImage;
    Lab_DeliveryAgent: TLabel;
    SpB_IntervalList: TSpeedButton;
    Sh_DeliveryMode: TShape;
    PM_IntervalScheme: TPopupMenu;
    N_IntervalList_AddOne: TMenuItem;
    N_IntervalList: TMenuItem;
    N2: TMenuItem;
    NArea_ShowHideXML: TMenuItem;
    SzPan_Tools: TSizedPanel;
    BB_Tools_Close: TBitBtn;
    SpB_Mode_Tools: TSpeedButton;
    PC_Tools: TPageControl;
    TS_Tools_UsedAreas: TTabSheet;
    DTP_Tools_UsedAreas_Start: TDateTimePicker;
    DTP_Tools_UsedAreas_Finish: TDateTimePicker;
    SpB_Tools_UsedAreas_Load: TSpeedButton;
    Lab_Use_Days: TLabel;
    SpB_Tools_UsedAreas_ViewMode: TSpeedButton;
    PM_Tools_UsedAreas_ViewMode: TPopupMenu;
    TV_Tools_UsedAreas: TTreeView;
    Ed_Tools_UsedAreas_Search: TEdit;
    Lab_Use_Find: TLabel;
    N_Tools_uavmList: TMenuItem;
    N_Tools_uavmInterval: TMenuItem;
    N_Tools_uavmArea: TMenuItem;
    N_Tools_uavmOwner: TMenuItem;
    SpB_Tools_UsedAreas_Excel: TSpeedButton;
    TS_Tools_DTP: TTabSheet;
    SpB_Tools_DTP_Load: TSpeedButton;
    Lab_Accident_Days: TLabel;
    SpB_Tools_DTP_Edit: TSpeedButton;
    Lab_Accident_Find: TLabel;
    SpB_Tools_DTP_Excel: TSpeedButton;
    DTP_Tools_DTP_Start: TDateTimePicker;
    DTP_Tools_DTP_Finish: TDateTimePicker;
    Ed_Tools_DTP_Search: TEdit;
    SpB_Deliverys_Report: TSpeedButton;
    DrGr_AccidentList: TDrawGrid;
    TS_AreaLog: TTabSheet;
    Lab_AreaLog_Days: TLabel;
    DTP_Tools_AreaLog_Start: TDateTimePicker;
    DTP_Tools_AreaLog_Finish: TDateTimePicker;
    SpB_Tools_AreaLog_Load: TSpeedButton;
    Lab_AreaLog_Find: TLabel;
    Ed_Tools_AreaLog_Search: TEdit;
    SpB_Tools_AreaLog_View: TSpeedButton;
    DrGr_AreaLogList: TDrawGrid;
    SpB_Tools_AreaLog_Excel: TSpeedButton;
    NMap_Center: TMenuItem;
    NMap_Center_Moscow: TMenuItem;
    NMap_Center_SPb: TMenuItem;
    SpB_Tools_DTP_Filter: TSpeedButton;
    PM_Tools_DTP_Filter: TPopupMenu;
    N_Tools_DTP_Filter_Days: TMenuItem;
    N_Tools_DTP_Filter_Empty: TMenuItem;
    Lab_Accident_OnlyEmpty: TLabel;
    N_IntervalList_EditOne: TMenuItem;
    N_IntervalList_DelOne: TMenuItem;
    N3: TMenuItem;
    Lab_RefreshTimeOfAIL: TLabel;
    SzPan_IntervalSchemeEx: TSizedPanel;
    SpB_AddInterval: TSpeedButton;
    SpB_DelInterval: TSpeedButton;
    LabT_DTI_Start: TLabel;
    SpB_DelInterval_DrGr: TSpeedButton;
    LabT_Info: TLabel;
    SpB_SaveInterval: TSpeedButton;
    SpB_LoadInterval: TSpeedButton;
    SE_Days: TSpinEdit;
    BB_DTI_Close: TBitBtn;
    PC_IntervalView: TPageControl;
    TS_IntList: TTabSheet;
    DrGr_DTI: TDrawGrid;
    TS_Scheme: TTabSheet;
    Lab_Area: TLabel;
    Lab_Scheme_Period: TLabel;
    SpB_RefreshScheme: TSpeedButton;
    SpB_ApplyScheme: TSpeedButton;
    DTP_SchemeBegin: TDateTimePicker;
    DTP_SchemeEnd: TDateTimePicker;
    DrGr_DTL: TInvDrawGrid;
    IL_Interval: TImageList;
    N_IntervalList_Old: TMenuItem;
    N_IntervalList_New: TMenuItem;
    N_Agent8519: TMenuItem;
    NMap_Center_RnD: TMenuItem;
    SpB_Tools_UsedAreas_Download: TSpeedButton;
    SpB_Mode_PVZ: TSpeedButton;
    GB_Area: TGroupBox;
    SpB_Map_RefresAndShow: TSpeedButton;
    SpB_Map_Filter: TSpeedButton;
    SpB_ViewFiltered_Area: TSpeedButton;
    SpB_Area: TSpeedButton;
    Lab_AreaName: TLabel;
    Ed_AreaName: TEdit;
    Lab_Area_Level: TLabel;
    CB_Level: TComboBox;
    Lab_Inp: TLabel;
    Lab_Area_ParentAreaName: TLabel;
    CB_AreaParent: TComboBox;
    SpB_AreaParent_Clear: TSpeedButton;
    Lab_Area_ColorsSet: TLabel;
    Pan_RGBLine: TPanel;
    Pan_RGBFill: TPanel;
    GB_PVZ: TGroupBox;
    DrGr_PVZList: TDrawGrid;
    Lab_PVZ_List: TLabel;
    ChB_ShowPrevVersion: TCheckBox;
    NMap_HideAreas: TMenuItem;
    ChB_CheckChilds: TCheckBox;
    ExtSh_Intersect: TExtShape;
    PM_AreaDopFuncs: TPopupMenu;
    NAreaDopFuncs_Intersect: TMenuItem;
    TS_AreaTimeLog: TTabSheet;
    NArea_Cancel: TMenuItem;
    TS_Filter_Levels: TTabSheet;
    NArea_SendToBack: TMenuItem;
    PanAreaDopFilter: TPanel;
    ChB_UsedNow: TCheckBox;
    ChB_UsedAdm: TCheckBox;
    LabPanDopFilter: TLabel;
    ChB_UsedNo: TCheckBox;
    Bevel1: TBevel;
    ChB_DopAutoShow: TCheckBox;
    ExtShAreaDopFilter: TExtShape;
    LabFullAreaList: TLabel;
    SzPan_TwoHours: TSizedPanel;
    BB_TwoHours_Close: TBitBtn;
    LabTHAreaInfo: TLabel;
    CBTwoHoursArea: TComboBox;
    LabTHAreaID: TLabel;
    SpB_Mode_TwoHours: TSpeedButton;
    DrGrDisplayPIL: TDrawGrid;
    BBUpdPilSave: TBitBtn;
    BBUpdPilClear: TBitBtn;
    chbAgent0001: TCheckBox;
    chbAgent0013: TCheckBox;
    chbAgent8519: TCheckBox;
    Bevel2: TBevel;
    SpBFiltAtt: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    N_IntervalList_TimeQuantum: TMenuItem;
    N_IntervalList_TimeQuantum10: TMenuItem;
    N_IntervalList_TimeQuantum15: TMenuItem;
    N_IntervalList_TimeQuantum20: TMenuItem;
    N_IntervalList_TimeQuantum30: TMenuItem;
    N_IntervalList_TimeQuantum60: TMenuItem;
    BBPilInfo: TBitBtn;
    BBPilShow: TBitBtn;
    sbChangeAgentRules: TSpeedButton;
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure ShowWorkPanels(Sender: TObject);
    procedure SetAreaControls;
    procedure Act_СloseExecute(Sender: TObject);
    procedure Act_RefreshExecute(Sender: TObject);
    procedure Act_FilterExecute(Sender: TObject);
    procedure Act_LogShowExecute(Sender: TObject);
    procedure Act_ShowFilteredExecute(Sender: TObject);
    procedure NCloseClick(Sender: TObject);


    procedure DrGrEnter(Sender: TObject);
    //procedure WBTitleChange(ASender: TObject; const Text: WideString);
    procedure WBBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure WBClick(Sender: TObject);
    procedure IE_Procedures(Sender: TObject);

(* --- Области, интервалы ----------------------------------------------------------------------- *)
    procedure BB_Filter_CloseClick(Sender: TObject);
    procedure ChLB_Areas_NamesClickCheck(Sender: TObject);
    procedure ChLB_Areas_NamesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure Ed_Filter_FindChange(Sender: TObject);
    procedure PC_FilterChanging(Sender: TObject; var AllowChange: Boolean);
    procedure PC_FilterChange(Sender: TObject);
    procedure PC_ToolsChange(Sender: TObject);
    procedure TV_AreaClick(Sender: TObject);
    procedure TV_AreaAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure Filter_SelBtns_Click(Sender: TObject);
    procedure SetColor(Sender: TObject);
    procedure SzPan_AreaResize(Sender: TObject);

    procedure ShowIntervalEditor(Sender: TObject);
    procedure DrGr_AreaIntervalListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure Lab_CoordClick(Sender: TObject);
    procedure BB_Area_CloseClick(Sender: TObject);
    procedure SpB_AreaClick(Sender: TObject);
    procedure PM_AreaPopup(Sender: TObject);

       procedure MakeSaveArea;
       procedure MakeCancelArea;
    procedure CallEditArea(Sender: TObject);
    procedure Ed_AreaNameChange(Sender: TObject);
    procedure CB_LevelChange(Sender: TObject);
    procedure CB_AreaParentChange(Sender: TObject);
    procedure SpB_AreaParent_ClearClick(Sender: TObject);
    procedure SpB_IntervalListClick(Sender: TObject);
    procedure IntervalListProcessing(Sender: TObject);
    procedure PM_IntervalSchemePopup(Sender: TObject);
    procedure NAcceptModeClick(Sender: TObject);
    procedure SetMapCenter(Sender: TObject);

(* --- Машинки, маркеры, маршруты --------------------------------------------------------------- *)
    procedure DTP_DeliveryDateChange(Sender: TObject);
    procedure SpB_DeliveryAgentClick(Sender: TObject);
    procedure SetDeliveryAgent(Sender: TObject);
    procedure ShowDeliveryAreas(Sender: TObject);
    procedure DrGr_CarsListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure Ed_CarListSearchChange(Sender: TObject);
    procedure SpB_DeliveryRefreshClick(Sender: TObject);
    procedure SzPan_DeliverysResize(Sender: TObject);
    procedure CallShowMarkersOrRoute(Sender: TObject);
    procedure DrGr_CarsListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure DrGr_CarsListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure BB_Delivery_CloseClick(Sender: TObject);
    procedure LabT_DeliverysTitleClick(Sender: TObject);



(* --- Инструменты, отчеты, настройки ----------------------------------------------------------- *)
    procedure BB_Tools_CloseClick(Sender: TObject);
    procedure SzPan_ToolsResize(Sender: TObject);
    procedure SpB_Tools_UsedAreas_Click(Sender: TObject);
    procedure Ed_Tools_UsedAreas_SearchChange(Sender: TObject);
    procedure SetUsedAreasViewMode(Sender: TObject);
    procedure TV_Tools_UsedAreasAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure DrGr_CarsListEnter(Sender: TObject);
    procedure SpB_Deliverys_ReportClick(Sender: TObject);
    procedure SpB_Tools_DTP_Click(Sender: TObject);
    procedure DrGr_AccidentListDblClick(Sender: TObject);
    procedure DrGr_AccidentListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrGr_AccidentListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure DrGr_AccidentListSelectCell(Sender: TObject; ACol, ARow: Integer;var CanSelect: Boolean);
    procedure DrGr_AccidentListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DrGr_AccidentListTopLeftChanged(Sender: TObject);

    procedure SpB_Tools_AreaLog_Click(Sender: TObject);
    procedure DrGr_AreaLogListDblClick(Sender: TObject);
    procedure DrGr_AreaLogListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrGr_AreaLogListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure DrGr_AreaLogListSelectCell(Sender: TObject; ACol, ARow: Integer;var CanSelect: Boolean);
    procedure DrGr_AreaLogListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DrGr_AreaLogListTopLeftChanged(Sender: TObject);
    procedure PM_Tools_DTP_FilterPopup(Sender: TObject);
    procedure Tools_DTP_Filter_SelectMode(Sender: TObject);
    procedure N_IntervalList_EditOneClick(Sender: TObject);
    procedure NMap_HideAreasClick(Sender: TObject);


    (*NEW 20151001 : begin*)
    procedure DTI_Updated(Sender:TObject; aIndex : integer);
    procedure DTP_DTI_Change(Sender: TObject);
    procedure DTI_Edit(Sender: TObject);
    procedure DTI_Resize(Sender: TObject);
    procedure DrGr_DTIFixedCellClick(Sender: TObject; ACol, ARow: Integer);
    procedure DTI_DrGr_ShowDelButton;
    procedure DTI_ShowInfo;
    procedure DTI_SaveLocal(const aName, aXML : string);
    procedure DTI_LoadLocal;
    procedure DTI_Scale;
    procedure DrGr_DTIDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrGr_DTIMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrGr_DTISelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DrGr_DTITopLeftChanged(Sender: TObject);
    procedure DrGr_DTLDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrGr_DTLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrGr_DTLMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure DrGr_DTLTopLeftChanged(Sender: TObject);
    procedure TS_SchemeResize(Sender: TObject);
    function DTL_GetXML(*(aAreaID : integer)*) : string;
    function DTL_SaveIntoDB(*(aAreaID : integer)*) : boolean;
    procedure RefreshScheme(Sender: TObject);
    procedure ApplyScheme(Sender: TObject);
    (*NEW 20151001 : end*)
    procedure DrGr_PVZListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;  State: TGridDrawState);
    procedure DrGr_PVZListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure SzPanSetOut(Sender: TObject);
    procedure SzPanClick(Sender: TObject);
    procedure Pan_ReqDataClick(Sender: TObject);

    procedure SpB_Area_DopFuncsClick(Sender: TObject);
    procedure NAreaDopFuncs_IntersectClick(Sender: TObject);
    procedure ChBSelectShowedAreas(Sender: TObject);
    procedure LabPanDopFilterClick(Sender: TObject);
    procedure WBEnter(Sender: TObject);
    procedure BB_TwoHours_CloseClick(Sender: TObject);
    procedure SzPan_TwoHoursResize(Sender: TObject);
    procedure CBTwoHoursAreaDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure CBTwoHoursAreaChange(Sender: TObject);
    procedure DrGrDisplayPILDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure DrGrDisplayPILDblClick(Sender: TObject);
    procedure UpdPILClick(Sender: TObject);
    procedure SpBFiltAttClick(Sender: TObject);
    procedure sbChangeAgentRulesClick(Sender: TObject);







  private
     LastClickedCoord : TFloatPoint;
     SelectedAreas    : TIntegerDynArray;
     Area             : TAreaItem; // -- последняя выбранная(кликнутая, отредактированная) область
     CancelArea       : TAreaItem;
     EditArea         : TAreaItem;
     AreaXML          : string;  // -- описатель Area, можно Mem_XML использовать, но как-то так
     CurObject        : TCurObject; // -- Текущий объект для расписания (область, ПВЗ)
     (*NEW 20151001 : begin*)
     DTI : TDateTimeInterval;
     ralTime          : TdateTime; // -- затычка-костыль для отключения множественного вызова получения списка областей
     procedure DTI_Create(aDateStart, aDateFinish : TDateTime; aIntervals : array of TPairDateTime);
     procedure DTI_SetArea;
     (*NEW 20151001 : end*)

    function LoadSettings : boolean;
    function SaveSettings : boolean;
      procedure SetDeliveryBtn(aEnable , aClose : boolean);
      procedure SetMapBtn(aEnable , aClose : boolean);
      procedure SetPVZBtn(aEnable , aClose : boolean);
      procedure SetToolsBtn(aEnable , aClose : boolean);
      procedure SetTwoHoursBtn(aEnable , aClose : boolean);
    procedure SetModeButtons;
    procedure SetCtrlButtons;
    procedure ShowHideAreaXML(aXSM : TXMLShowMode = xsmUnknown);


    procedure FillFilter(UpdObject : TControl);
    procedure FillLastClickedCoord(const aValue : string);

      procedure Check_ChLB_Areas_Names;
      procedure Check_TV_Area;
    procedure FillAreaInfo(const aAreaXML : string);
    procedure FillSelectedAreas(const aIDs : array of integer);
    procedure ShowSelectedAreas;
    function AddAreaImage(aFill, aLine : TColor) : integer;

    procedure ShowMarkersOrRoute(aCarID : integer; asRoute : boolean);
    procedure ShowDeliveryControls(aVisible : boolean);
    (* добавление / редактирование единичного интервала (работает с Frm_Interval)*)
    procedure CallInputDateTimeInterval(aID  :integer; aStart : TDateTime; var aFrom, aTo: TDateTime; aActive: boolean; OnlyInterval : boolean = false);

    procedure ShowUsedAreas;
    procedure TV_Tools_UsedAreas_CheckScrollInfo;

    function CanSaveArea_CheckParams(aArea : TAreaItem) : boolean;
    function CanSaveArea_CheckPoints(aArea : TAreaItem) : boolean;

    procedure RefreshAreaIntervalList(aAreaID : integer; aAreaType : TAreaIntervalIdType);
    procedure DeleteCurrentInterval;

    function ProcessingId_Result(const avalue : string) : boolean;

    function AreaIntersectMessage(const ListOfAreas,DopMessage : string) : integer;
    procedure CheckIntersectAreas(var IDs : TIntegerDynArray; var ListOfAreas : string);

    //procedure FillTwoHoursData;

    function H2Data(const ARow : integer; var PILIndex, AreaId, IntervalId : integer) : boolean ;
    function EditH2Interval(var PII : TPayIntervalItem) : boolean;
    procedure PayIntervalInfo;

    function StateNode(Node : TTreeNode) : integer;

  public
    function LoadHTMLpage(const aPageURI : string) : boolean;
    function ExistsUnsaved : boolean;
    function ClearMap : boolean;
    function RefreshAreaList : boolean;
    function FillParentAreaList(const aArea : TAreaItem; aComboBox : TComboBox) : integer;
    function RefreshPVZList : boolean;
  end;

const
  baseSection = 'Settings';
  HTMLResourceName : string = 'HTML_WRITE_NEW';
  std_JS_Wait = 50; // -- время ожидания выполнения скрипта
  FontColor        : array[boolean] of TColor = (clWindowText, clHighlightText);
  BrushColor       : array[boolean] of TColor = (clWindow, clHighlight);
  FontColorSearch  : array[boolean, boolean] of TColor = ((clSilver, clPaleGray),(clWindowText, clHighlightText));
  BrushColorSearch : array[boolean, boolean] of TColor = ((clWindow, clGray)    ,(clWindow    , clHighlight));

  centerMsk_Lat = 55.755833 ;
  centerMsk_Lng = 37.617778 ;
  centerSPb_Lat = 59.95     ;
  centerSpb_Lng = 30.316667 ;
  centerRnD_Lat = 47.23132  ;
  centerRnD_Lng = 39.72326  ;

  viaJSObjects : boolean = true; (*20151223*)

var
  _Main: T_Main;
  MainWindow          : cardinal = 0;
  SetLastDeliveryDate : boolean = false;  // -- восстанавливать дату доставки крайнего сеанса
  DeliveryDate        : TDate = 0;        // -- сохраненная дата доставки с крайнего сеанса
  DeliveryAgent       : TDeliveryAgent = daMoscow;      // -- выбранный агент доставки

  sbDeliveryMode      : TSpeedButtonMode;
  sbMapMode           : TSpeedButtonMode;
  sbPVZMode           : TSpeedButtonMode;
  sbToolsMode         : TSpeedButtonMode;
  sbTwoHoursMode      : TSpeedButtonMode;

  // --- setting what can read|write

  dlvNeedShowAreas : boolean = false; // -- планируется для переключения отображения областей при отображении маркеров и(или) маршрута
  dlvClearEntitys  : boolean = false; // -- планируется для переключения очистки предыдущих отображений


  daysNoEditInterval  : integer = 4; // -- кол-во дней, на которое согласуется доставка

  AccidentList        : TAccidentList; // -- список инцедентов за период
  AccidentItem        : TAccidentItem; // -- текущий инцедент
(*20141110*)  WebBrowserSilent : boolean = true; // -- тихий обработчик ошибок (если нет сертификата и нет оповещения не грузится карта)

(*NEW 20151001 : begin*)
  dti_dateStart  : TdateTime;
  dti_DateFinish : TdateTime;
  dtInterval     : TDTInterval = dti15min;
  DTL            : TDatesIntervalList;
  dtlErrors      : TStringDynArray;
(*NEW 20151001 : end*)
 MaxDaysCount    : integer = 14; // -- максимальное кол-во дней в схеме интервалов
 MaxIntervalCount: integer = 28; // -- максимальное кол-во интервалов в схеме

 SzPanPosList    : TSzPanPosList;


implementation

uses Frm_Interval, U_Filter_GetDates, U_H2Interval,
ChangeAgentRulesFrm
;

{$R *.dfm}
(* ---  MODULE ------------------------------------------------------------------------------- *)

(*OVERLOADING*) // SysUtils.StringReplace
function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
// дает ошибку в конструкции
//Result:=DaggerChar+StringReplace(Copy(aSrc,Pos('[',aSrc)+1,Length(aSrc)),']',DaggerChar,[]);
// aSrc =  'HEAD [ID•{B4A43616-6263-4A68-8E13-EAAFCD301D42}†NAME•Тоже схема†DATE•20150930 14:26]'
//Result:=StringReplaceEx(S, OldPattern, NewPattern, Flags);
Result:=SysUtils.StringReplace(S, OldPattern, NewPattern, Flags);
end;


// -- НАЧАЛО : БЛОК проверки пересечения линий ------------
// ---- Взято полностью отсюда : http://himangi774.blogspot.ru/2013/07/how-to-check-if-two-given-line-segments.html ------------
type
  TPointF = record
   X : single;
   Y : single;
   class function FromLatLng(Latitude, Longitude : single) : TPointF; static;
   class function FromFloatPoint(P : TFloatPoint) : TPointF; static;
   function Equal(P : TPointF) : boolean;
  end;

  TPerimeterSegment = record
   No : integer;
   A  : TPointF;
   B  : TPointF;
  end;

  TPerimeter = record
   Segments : TList<TPerimeterSegment>;
   function Add(A,B : TPointF) : integer;
   function GetIndex(A,B : TPointF) : integer;
   function MakePerimeter(const FPA : array of TFloatPoint) : boolean;
   function GetIntersectCount : integer;
   function Clear : boolean;
  end;
//--------------------------------------------------------------

function onSegment(const a, b, c : TPointF) : boolean;
begin
Result:=(
         (b.x >= Math.min(a.x, c.x)) and (b.x <= Math.max(a.x, c.x)) and
         (b.y >= Math.min(a.y, c.y)) and (b.y <= Math.max(a.y, c.y))
         );
end;
// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
function GetOrientation(const a, b, c : TPointF) : int64;
var
 val : single;
begin
val := (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y);
if (val = 0)  // colinear
  then Result:=0
  else
if val>0 // clock or counterclock wise (В JS был изменен знак с > на < после проверки на нарисованных линиях)
   then Result:=1
   else Result:=2;
end;
//
function IsIntersect(const p1, q1, p2, q2 : TPointF) : boolean;
var
 o1: int64;
 o2: int64;
 o3: int64;
 o4: int64;
begin
// Find the four orientations needed for general and special cases
o1 := GetOrientation(p1, q1, p2);
o2 := GetOrientation(p1, q1, q2);
o3 := GetOrientation(p2, q2, p1);
o4 := GetOrientation(p2, q2, q1);
Result:=(((o1 <> o2) and (o3 <> o4)))             or     // General case
        (((o1 = 0) and (onSegment(p1, p2, q1))))  or     // p1, q1 and p2 are colinear and p2 lies on segment p1q1
        (((o2 = 0) and (onSegment(p1, q2, q1))))  or     // p1, q1 and q2 are colinear and q2 lies on segment p1q1
        (((o3 = 0) and (onSegment(p2, p1, q2))))  or     // p2, q2 and p1 are colinear and p1 lies on segment p2q2
        (((o4 = 0) and (onSegment(p2, q1, q2))))  ;      // p2, q2 and q1 are colinear and q1 lies on segment p2q2
end;

//---------------------------------------------------------------

class function TPointF.FromLatLng(Latitude, Longitude : single) : TPointF;
begin
with Result do
  begin
  X:=Longitude;
  Y:=90 - Latitude;
  end;
end;

class function TPointF.FromFloatPoint(P : TFloatPoint) : TPointF;
begin
with Result do
  begin
  X:=P.Longitude;
  Y:=90 - P.Latitude;
  end;
end;

function TPointF.Equal(P : TPointF) : boolean;
begin
Result:=(X=P.X) and (Y=P.Y);
end;

function TPerimeter.Add(A,B : TPointF) : integer;
var
 ps : TPerimeterSegment;
begin
if not Assigned(Segments) then Segments:=TList<TPerimeterSegment>.Create;
Result:=GetIndex(A,B);
if Result=-1
   then begin
   ps.No:=Segments.Count;
   ps.A:=A;
   ps.B:=B;
   Result:=Segments.Add(ps);
   end;
end;

function TPerimeter.GetIndex(A,B : TPointF) : integer;
var
 cnt : integer;
begin
if not Assigned(Segments) then Exit(-2);
for cnt:=0 to Segments.Count-1
  do if (Segments.Items[cnt].A.Equal(A) and Segments.Items[cnt].B.Equal(B)) or
        (Segments.Items[cnt].A.Equal(B) and Segments.Items[cnt].B.Equal(A))
        then Exit(cnt);
Result:=-1;
end;

function TPerimeter.MakePerimeter(const FPA : array of TFloatPoint) : boolean;
var
 cnt : integer;
begin
if not Assigned(Segments) then Segments:=TList<TPerimeterSegment>.Create;
for cnt:=1 to High(FPA)
   do Add(TPointF.FromFloatPoint(FPA[cnt-1]), TPointF.FromFloatPoint(FPA[cnt]));
Result:=Segments.Count = High(FPA);
end;

function TPerimeter.GetIntersectCount : integer;
var
 cntA : integer;
 cntB : integer;
begin
Result:=0;
for cntA:=0 to Segments.Count-1
   do begin
   if cntA+2>=Segments.Count then Break;
   for cntB:=cntA+2 to Segments.Count-1
     do inc(Result, integer(IsIntersect(Segments.Items[cntA].A,Segments.Items[cntA].B,
                                        Segments.Items[cntB].A,Segments.Items[cntB].B )))
   end;
end;

function TPerimeter.Clear : boolean;
begin
Segments.Clear;
Segments.Free;
Result:=true;
end;



// -- КОНЕЦ : БЛОК проверки пересечения линий ------------


(* ---  TYPE ------------------------------------------------------------------------------------ *)

(* ~~~ TSzPanForm ~~~ *)

procedure TSzPanForm.SzPanFormFormClose(Sender: TObject; var Action: TCloseAction);
begin
SzPanPosList.SetIn(Tag);
end;


(* ~~~ TSzPanPosList ~~~ *)

function TSzPanPosList.GetOutBtn(aSzPanel : TsizedPanel; const aName : string) : TSpeedButton;
var
 cnt : integer;
begin
Result:=nil;
try
for cnt:=0 to aSzPanel.ControlCount-1
  do if (aSzPanel.Controls[cnt].Name = aName) and (aSzPanel.Controls[cnt].InheritsFrom(TSpeedButton))
        then begin
        Result:=(aSzPanel.Controls[cnt] as TSpeedButton);
        Exit;
        end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.Fill(aParent : TWinControl);
var
 cnt    : integer;
 ind    : integer;
 //dop    : string;
 //btnOut : TSpeedButton;
begin
try
for cnt:=0 to aparent.ControlCount-1
  do if aParent.Controls[cnt] is TSizedPanel
        then begin
        ind:=Length(Items);
        SetLength(Items, ind+1);
        with aParent.Controls[cnt],Items[ind] do
          begin
          Pan:=(aParent.Controls[cnt] as TSizedPanel);
          with StdRect do
            begin
            Left:=aParent.Controls[cnt].Left;
            Top:=aParent.Controls[cnt].Top;
            Right:=Left+aParent.Controls[cnt].Width;
            Bottom:=Top+aParent.Controls[cnt].Height;
            end;
          //btnOut:=GetOutBtn(Pan,'SpB_SetOut_'+Pan.Name);
          //if not Assigned(Pan.OnClick) then
             Pan.OnClick:=_Main.SzPanClick;
          if not Assigned(Pan.OnDblClick)
             then begin
             Pan.OnDblClick:=_Main.SzPanSetOut;
             //btnOut.Free;
             Pan.Caption:='   '+Trim(Pan.Caption);
             end
             else begin
//             if Assigned(btnOut) and btnOut.InheritsFrom(TSpeedButton)
//                then begin
//                dop:=DupeString(' ',Round(30 / GetTextWidthByHeight(' ',Pan.Font,100))+1);
//                Pan.Caption:=''+Trim(Pan.Caption);
//                with (btnOut as TSpeedButton) do
//                   begin
//                   Left:=-1;
//                   Top:=-1;
//                   Anchors:=[akLeft, akTop];
//                   end;
//                end;
             end;
          ParentForm:=nil;
          end;
        end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


function TSzPanPosList.GetIndex(aHandle : cardinal) : integer;
var
 cnt     : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do begin
  if Items[cnt].Pan.Handle = aHandle
     then begin
     Result:=cnt;
     Exit;
     end;
  end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.UpdateStdRect(aIndex : integer);
begin
try
if (aIndex<Low(Items)) or (aIndex>High(Items)) or
   // если это не главная форма, то не надо изменять описание координат панели
   Assigned(Items[aIndex].ParentForm)
   then Exit;
with Items[aIndex] do
  begin
  StdRect.Left  := Pan.Left;
  StdRect.Top   := Pan.Top;
  StdRect.Right := Pan.Left+Pan.Width;
  StdRect.Bottom:= Pan.Top+Pan.Height;
  end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


function TSzPanPosList.IsOut(aSzPanel : TSizedPanel) : boolean;
var
 cnt     : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items)
  do begin
  if Items[cnt].Pan = aSzPanel
     then begin
     Result:=Assigned(Items[cnt].ParentForm);
     Exit;
     end;
  end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.SetOut(aIndex : integer);
var
 rct    : TRect;
begin
{$MESSAGE 'Тут создаются внешние формы для панелей'}
try
if (aIndex<Low(Items)) or (aIndex>High(Items)) or
   Assigned(Items[aIndex].ParentForm) and
   (Items[aIndex].ParentForm = Items[aIndex].Pan.Parent)
   then Exit;
Items[aIndex].ParentForm:=TSzPanForm.CreateNew(Application);
with Items[aIndex].ParentForm do
  begin
  Caption:=Trim(Items[aIndex].Pan.Caption);
  Name:=Format('OutForm_%s',[Items[aIndex].Pan.Name]);
  BorderIcons:=[biSystemMenu];
  BorderStyle:=bsSizeToolWin;
  Position:=poDefaultSizeOnly;
  onClose:=SzPanFormFormClose;
  Windows.GetWindowRect(Items[aIndex].Pan.Handle, rct);
  ClientWidth:=Items[aIndex].Pan.Width;
  ClientHeight:=Items[aIndex].Pan.Height;
  Left:=rct.Left - (*Application.MainForm.Left+Items[aIndex].Pan.Left+*)GetSystemMetrics(SM_CXFRAME);
  Top:=rct.Top -  (*Application.MainForm.Top+Items[aIndex].Pan.Top*) (GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYFRAME));
  Constraints.MinWidth:=Items[aIndex].Pan.Constraints.MinWidth + (Width - ClientWidth);
  Constraints.MinHeight:=Items[aIndex].Pan.Constraints.MinHeight + (Height - ClientHeight);
  end;
ShowOutBtn(Items[aIndex].Pan, false);
with Items[aIndex].Pan do
  begin
  Parent          := Items[aIndex].ParentForm;
  Align           := alClient;
  Align           := alNone;
  Left            := 0;
  Top             := -18;
  //Width           := ClientWidth;
  Height          := Parent.ClientHeight - Top;
  Anchors         := [akLeft, akTop, akRight, akBottom];
  CanPanelMove    := false;
  CanPanelResize  := false;
  ShowCaption     := false;
  end;
Items[aIndex].ParentForm.Tag:=aIndex;
Items[aIndex].ParentForm.Show;
RestorePosition(Items[aIndex].ParentForm,AppParams.CFGUserFileName);
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.SetOut(aSzPanel : TSizedPanel);
begin
try
SetOut(GetIndex(aSzPanel.Handle));
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.SetIn(aIndex : integer);
begin
try
if (aIndex<Low(Items)) or (aIndex>High(Items)) or
   not Assigned(Items[aIndex].ParentForm)
   then Exit;
Application.MainForm.Canvas.Lock;
try
ALPHA_Window(Items[aIndex].ParentForm.Handle,00);
Items[aIndex].Pan.Align     := alNone;
Items[aIndex].Pan.Anchors   := [akLeft, akTop];
Items[aIndex].Pan.BoundsRect:= Items[aIndex].StdRect;
ShowOutBtn(Items[aIndex].Pan, true);
with Items[aIndex].Pan do
   begin
   CanPanelMove     := true;
   CanPanelResize   := true;
   ShowCaption      := true;
   Parent           := Application.MainForm;
   end;
FreeAndNil(Items[aIndex].ParentForm);
finally
Application.MainForm.Canvas.UnLock;
end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.SetIn(aSzPanel : TSizedPanel);
begin
try
SetIn(GetIndex(aSzPanel.Handle));
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.ShowOutBtn(aSzPanel : TSizedPanel; aShow : boolean);
var
 btnOut : TControl;
begin
try
btnOut:=GetOutBtn(aSzPanel,'SpB_SetOut_'+aSzPanel.Name);
if Assigned(btnOut) and btnOut.InheritsFrom(TSpeedButton)
   then (btnOut as TSpeedButton).Visible:=aShow;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.Restore;
var
 cnt     : integer;
begin
try
for cnt:=0 to High(Items)
  do begin
  if Assigned(Items[cnt].Pan.Parent) and (Items[cnt].Pan.Parent.InheritsFrom(TSzPanForm))
     then SetIn(cnt);
  end;
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;


procedure TSzPanPosList.Clear;
begin
try
SetLength(Items,0);
except
 on E : Exception do LogErrorMessage('TSzPanPosList.',E,[]);
end;
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)



(* ---  PRIVATE --------------------------------------------------------------------------------- *)

function T_Main.LoadSettings : boolean;
   procedure RestorePosIfNegative;
   var
    cnt  : integer;
    mHgt : integer;
   begin
   mHgt:=0;//GetSystemMetrics(SM_CYMENUSIZE);
   for cnt:=0 to ControlCount-1
     do if Controls[cnt] is TSizedPanel
           then begin
           with (Controls[cnt] as TSizedPanel)
             do begin
             if Top<mHgt then Top:=mHgt;
             if Left<0 then Left:=0;
             end;
           end;
   end;
var
 inm : string;
 cnt : integer;
 ne  : TNotifyEvent;
 bool : boolean;
begin
Result:=False;
try
inm:=AppParams.CFGCommonFileName;
with TINIFile.Create(inm) do
  try
// -- на 28.10.2014 параметры подключения загружаются и применяются в основном модуле приложения ---
//  DBiniSection  := ReadString(baseSection,DBCurrentSection,DBiniSection);
//  DBWinAutMode  := ReadBool(DBiniSection,'DBWinAutMode',DBWinAutMode);
//  DBName        := ReadString(DBiniSection,'DBName',DBName);
//  DBServer      := ReadString(DBiniSection,'DBServer',DBServer);
//  FnADODB.dbPrepareConnString;
  MapMode       := TMapMode(ReadInteger(baseSection,'MapMode', integer(mmYandex)));
  AreaListAccept:= TAreaListAccept(ReadInteger(baseSection,'AreaListAccept', integer(AreaListAccept)));
  CheckOutPoints:= ReadBool(baseSection,'CheckOutPoints',CheckOutPoints);
  (*20141110*)  WebBrowserSilent := ReadBool(baseSection   , 'WebBrowserSilent',  WebBrowserSilent);
  cnt           := ReadInteger(baseSection,'dtInterval',integer(dtInterval));
  if cnt in [5,10,15,20,30,60]
     then dtInterval:=TDTInterval(cnt);
//  dtInterval:=dti60min;
// что характерно можно задавать любой интервал....хоть 3 минуты, хоть 93
//  for dti:=Low(TDTInterval) to High(TDTInterval)
//     do if dti=TDTInterval(cnt)
//           then begin
//           dtInterval:=TDTInterval(cnt);
//           Break;
//           end;
  MaxDaysCount:= ReadInteger(baseSection,'MaxDaysCount',MaxDaysCount);
  MaxIntervalCount:= ReadInteger(baseSection,'MaxIntervalCount',MaxIntervalCount);
  finally
  Free;
  end;
WB.Silent:=WebBrowserSilent;
inm:=AppParams.CFGUserFileName;
SetDoubleBuffered(self);
RestorePosition(self,inm);
Pan_WB.Align:=alClient;


RestorePosition(SzPan_Area,inm);
RestorePageControl(self,PC_Tools,inm);
RestorePosition(SzPan_Filter,inm);
RestorePageControl(self,PC_Filter,inm);
RestorePosition(SzPan_Deliverys,inm);
RestoreColumns(self, DrGr_CarsList,inm);
RestoreColumns(self, DrGr_AreaIntervalList,inm);
RestorePosition(SzPan_Tools,inm);
RestoreColumns(self, DrGr_AccidentList,inm);
RestoreColumns(self, DrGr_AreaLogList,inm);
if DrGr_DTL.ColCount=1
   then RestoreColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'ErrorMode')
   else RestoreColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'NormalMode');
RestoreColumns(self, DrGr_DTI,inm);
DrGr_DTI.ColWidths[0]:=25;
RestorePageControl(self,PC_IntervalView,inm);
RestorePosition(SzPan_IntervalSchemeEx,inm);
RestorePosIfNegative;
RestoreColumns(self, DrGr_PVZList,inm);
RestorePosition(SzPan_TwoHours,inm);
RestoreColumns(self, DrGrDisplayPIL,inm);


DeliveryDate:=Date;
with TINIFile.Create(inm) do
  try
  SetLastDeliveryDate:=ReadBool(baseSection,'SetLastDeliveryDate',SetLastDeliveryDate);
  if SetLastDeliveryDate
     then DeliveryDate:=ReadDate(baseSection,'DeliveryDate',DeliveryDate);
  DeliveryAgent:=TDeliveryAgent(ReadInteger(baseSection,'DeliveryAgent',integer(DeliveryAgent)));

  lastUser:=ReadString(baseSection,'lastUser',lastUser);
  needMapMode:=ReadBool(baseSection,'needMapMode',needMapMode) ;
  needAreaType:=TAreaIntervalIdType(ReadInteger(baseSection,'needAreaType',integer(needAreaType)));
  needDeliveryMode:=ReadBool(baseSection,'needDeliveryMode',needDeliveryMode) ;
  needToolsMode:=ReadBool(baseSection,'needToolsMode',needToolsMode) ;
  needTwoHoursMode:=ReadBool(baseSection,'needTwoHoursMode',needTwoHoursMode) ;
  (*................*)
  if AreaListAccept=alaNone // -- не установлен в главном конфигураторе
     then AreaListAccept:= TAreaListAccept(ReadInteger(baseSection,'AreaListAccept', integer(AreaListAccept)));
  UsedAreasViewMode:=TUsedAreasViewMode(ReadInteger(baseSection,'UsedAreasViewMode',integer(UsedAreasViewMode)));

  for cnt:=0 to PanAreaDopFilter.ControlCount-1
    do if PanAreaDopFilter.Controls[cnt] is TCheckBox
          then with PanAreaDopFilter.Controls[cnt] as TCheckBox do
                  begin
                  ne:=onClick;
                  try
                  onClick:=nil;
                  bool:=Checked;
                  LoadBool('Settings',Name,bool,AppParams.CFGUserFileName);
                  Checked:=bool;

                  if PanAreaDopFilter.Controls[cnt]=ChB_UsedNow
                     then ChB_UsedNow.Checked:=true; // -- на загрузке принудительно!!!
                  finally
                  onClick:=ne;
                  end;
                  end;
  finally
  Free;
  end;



for cnt:=0 to PM_Agent.Items.Count-1
  do if PM_Agent.Items[cnt].Tag = integer(DeliveryAgent)
        then begin
        SetDeliveryAgent(PM_Agent.Items[cnt]);
        Break;
        end;
DTP_DeliveryDate.DateTime:=DeliveryDate;
for cnt:=0 to PM_Tools_UsedAreas_ViewMode.Items.Count-1
  do if PM_Tools_UsedAreas_ViewMode.Items[cnt].Tag = integer(UsedAreasViewMode)
        then begin
        PM_Tools_UsedAreas_ViewMode.Items[cnt].Checked:=True;
        Break;
        end;
if MaxDaysCount<2
   then MaxDaysCount:=2;
SE_Days.MaxValue:=MaxDaysCount;
if MaxIntervalCount<2
   then MaxIntervalCount:=2;

DrGrDisplayPIL.ColWidths[0]:=IL_Paint.Width+2;
DrGrDisplayPIL.ColWidths[1]:=DrGrDisplayPIL.Canvas.TextWidth(' 00:00 - 00:00 ');

ChBSelectShowedAreas(nil);
Result:=True;
except
  on E : Exception do LogErrorMessage('T_Main.LoadSettings',E,[inm]);
end
end;


function T_Main.SaveSettings : boolean;
var
 inm : string;
begin
Result:=False;
inm:='';
try
inm:=AppParams.CFGUserFileName;
with TINIFile.Create(inm) do
  try
  WriteString(baseSection,'lastUser',lastUser);
  WriteBool(baseSection,'needMapMode',needMapMode) ;  // -- SzPan_Area.Visible
  WriteInteger(baseSection,'needAreaType',integer(needAreaType)); // GB_Intervals.Tag
  WriteBool(baseSection,'needDeliveryMode',needDeliveryMode) ;
  WriteBool(baseSection,'needToolsMode',needToolsMode) ;
  WriteBool(baseSection,'needTwoHoursMode',needTwoHoursMode) ;

  finally
  Free;
  end;
SaveColumns(self, DrGrDisplayPIL,inm);
SavePosition(SzPan_TwoHours,inm);
SaveColumns(self, DrGr_PVZList,inm);
SavePosition(SzPan_IntervalSchemeEx,inm);
SavePageControl(self,PC_IntervalView,inm);
SaveColumns(self, DrGr_DTI,inm);
if DrGr_DTL.ColCount=1
   then SaveColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'ErrorMode')
   else SaveColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'NormalMode');
SaveColumns(self, DrGr_AreaLogList,inm);
SaveColumns(self, DrGr_AccidentList,inm);
SavePosition(SzPan_Tools,inm);
SaveColumns(self, DrGr_AreaIntervalList,inm);
SaveColumns(self, DrGr_CarsList,inm);
SavePosition(SzPan_Deliverys,inm);
SavePageControl(self,PC_Filter,inm);
SavePosition(SzPan_Filter,inm);
SavePageControl(self,PC_Tools,inm);
SavePosition(SzPan_Area,inm);
SavePosition(self,inm);
Result:=True;
except
  on E : Exception do LogErrorMessage('T_Main.SaveSettings',E,[inm]);
end
end;

procedure T_Main.sbChangeAgentRulesClick(Sender: TObject);
begin
  TChangeAgentRulesForm.Create(nil).Show;
end;

procedure T_Main.SetDeliveryBtn(aEnable , aClose : boolean);
  var
   sbm : PSpeedButtonMode;
  begin
  sbm:=PSpeedButtonMode(SpB_Mode_Delivery.Tag);
  with sbm^ do
    begin
    IsEnabled:=aEnable;
    IsClose:=aClose;
    ImageList:=IL_Paint;
    Setlength(glyphs,2);
    glyphs[0]:=ptpCarKupivip;
    if IsClose
       then glyphs[1]:=ptpClose
       else glyphs[1]:=-1;
    if IsEnabled
       then proc:=ShowWorkPanels
       else proc:=nil;
    SetGlyph(SpB_Mode_Delivery, ImageList,glyphs,IsEnabled);
    SpB_Mode_Delivery.OnClick:=proc;
    end;
  end;



  procedure T_Main.SetmapBtn(aEnable , aClose : boolean);
  var
   sbm : PSpeedButtonMode;
  begin
  sbm:=PSpeedButtonMode(SpB_Mode_Map.Tag);
  with sbm^ do
    begin
    IsEnabled:=aEnable;
    IsClose:=aClose;
    ImageList:=IL_Paint;
    Setlength(glyphs,3);
    glyphs[0]:=ptpMap;
    if wmtWrite in WorkMode
       then glyphs[1]:=ptpEditSign
       else glyphs[1]:=-1;
    if IsClose
       then glyphs[2]:=ptpClose
       else glyphs[2]:=-1;
    if IsEnabled
       then proc:=ShowWorkPanels
       else proc:=nil;
    SetGlyph(SpB_Mode_Map, ImageList,glyphs,IsEnabled);
    SpB_Mode_Map.OnClick:=proc;
    end;
  end;

  procedure T_Main.SetPVZBtn(aEnable , aClose : boolean);
  var
   sbm : PSpeedButtonMode;
  begin
  sbm:=PSpeedButtonMode(SpB_Mode_PVZ.Tag);
  with sbm^ do
    begin
    IsEnabled:=aEnable;
    IsClose:=aClose;
    ImageList:=IL_Paint;
    Setlength(glyphs,3);
    glyphs[0]:=ptpHome;
    if wmtWrite in WorkMode
       then glyphs[1]:=ptpEditSign
       else glyphs[1]:=-1;
    if IsClose
       then glyphs[2]:=ptpClose
       else glyphs[2]:=-1;
    if IsEnabled
       then proc:=ShowWorkPanels
       else proc:=nil;
    SetGlyph(SpB_Mode_PVZ, ImageList,glyphs,IsEnabled);
    SpB_Mode_PVZ.OnClick:=proc;
    end;
  end;


  procedure T_Main.SetToolsBtn(aEnable , aClose : boolean);
  var
   sbm : PSpeedButtonMode;
  begin
  sbm:=PSpeedButtonMode(SpB_Mode_Tools.Tag);
  with sbm^ do
    begin
    IsEnabled:=aEnable;
    IsClose:=aClose;
    ImageList:=IL_Paint;
    Setlength(glyphs,2);
    glyphs[0]:=ptpBoxes;
    if IsClose
       then glyphs[1]:=ptpClose
       else glyphs[1]:=-1;
    if IsEnabled
       then proc:=ShowWorkPanels
       else proc:=nil;
    SetGlyph(SpB_Mode_Tools, ImageList,glyphs,IsEnabled);
    SpB_Mode_Tools.OnClick:=proc;
    end;
  end;


  procedure T_Main.SetTwoHoursBtn(aEnable , aClose : boolean);
  var
   sbm : PSpeedButtonMode;
  begin
  sbm:=PSpeedButtonMode(SpB_Mode_TwoHours.Tag);
  with sbm^ do
    begin
    IsEnabled:=aEnable;
    IsClose:=aClose;
    ImageList:=IL_Paint;
    Setlength(glyphs,2);
    glyphs[0]:=ptpInterval;
    if IsClose
       then glyphs[1]:=ptpClose
       else glyphs[1]:=-1;
    if IsEnabled
       then proc:=ShowWorkPanels
       else proc:=nil;
    SetGlyph(SpB_Mode_TwoHours, ImageList,glyphs,IsEnabled);
    SpB_Mode_TwoHours.OnClick:=proc;
    end;
  end;


procedure T_Main.SetModeButtons;
begin
try
SpB_Mode_Delivery.Tag:=integer(Addr(sbDeliveryMode));
SetDeliveryBtn((wmtMarkers in WorkMode) or (wmtRoute in WorkMode), SzPan_Deliverys.Visible);
SpB_Mode_Map.Tag:=integer(Addr(sbMapMode));
SetMapBtn((wmtRead in WorkMode) or (wmtWrite in WorkMode), SzPan_Area.Visible and (TAreaIntervalIdType(GB_Intervals.Tag)=aiitArea));
SpB_Mode_PVZ.Tag:=integer(Addr(sbPVZMode));
SetPVZBtn((wmtRead in WorkMode) or (wmtWrite in WorkMode), SzPan_Area.Visible and (TAreaIntervalIdType(GB_Intervals.Tag)=aiitPVZ));
SpB_Mode_Tools.Tag:=integer(Addr(sbToolsMode));
SetToolsBtn((wmtRead in WorkMode) , SzPan_Tools.Visible);
if SpB_DelInterval_DrGr.Parent<>DrGr_DTI
   then begin
   SpB_DelInterval_DrGr.Hide;
   SpB_DelInterval_DrGr.Parent:=DrGr_DTI;
   end;
SpB_Mode_TwoHours.Tag:=integer(Addr(sbTwoHoursMode));
SetTwoHoursBtn((wmtRead in WorkMode) , SzPan_TwoHours.Visible);
except
  on E : Exception do LogErrorMessage('T_Main.SetModeButtons',E,[]);
end
end;


procedure T_Main.SetCtrlButtons;
begin
try
SetGlyph(SpB_IntervalList,IL_Paint,[ptpInterval, ptpSmallEdit], SpB_IntervalList.Enabled);

with Sh_DeliveryMode do
  begin
  Width:=SpB_DeliveryRefresh.Width-2;
  Height:=SpB_DeliveryRefresh.Height-2;
  Top:=SpB_DeliveryRefresh.Top+3;
  Left:=SpB_DeliveryRefresh.Left+3;
  end;
SetGlyph(SpB_AreaParent_Clear,IL_Paint,[ptpArea1, ptpClose], SpB_AreaParent_Clear.Enabled);
SetGlyph(SpB_Tools_DTP_Edit,IL_Paint,[ptpBigEdit],SpB_Tools_DTP_Edit.Tag<>0);
except
  on E : Exception do LogErrorMessage('T_Main.SetCtrlButtons',E,[]);
end
end;


procedure T_Main.ShowHideAreaXML(aXSM : TXMLShowMode = xsmUnknown);
var
 xsm : TXMLShowMode;
begin
try
xsm:=aXSM;
if xsm = xsmUnknown
   then if Mem_XML.Visible
           then xsm:=xsmHide
           else xsm:=xsmShow;

if xsm=xsmHide
   then begin
   GB_Intervals.Anchors:=[akLeft, akTop, akRight, akBottom];
   GB_Intervals.Height:=GB_Intervals.Parent.ClientHeight-4-GB_Intervals.Top;
   Mem_XML.Hide;
   end
   else begin
   GB_Intervals.Anchors:=[akLeft, akTop, akRight];
   GB_Intervals.Height:=Mem_XML.Top-4-GB_Intervals.Top;
   Mem_XML.Show;
   end;
except
  on E : Exception do LogErrorMessage('T_Main.ShowHideAreaXML',E,[]);
end
end;


procedure T_Main.FillFilter(UpdObject : TControl);
var
  extSA : boolean;

  procedure FillChild(SelID: integer; aParentNode : TTreeNode; aParentID : integer);
  var
   cnt : integer;
   Node : TTreeNode;
  begin
  for cnt:=0 to High(FullAreaList.Items)
  do if FullAreaList.Items[cnt].aParentID=aParentID
        then begin
        Node:= TV_Area.Items.AddChildObject(aParentNode,string(FullAreaList.Items[cnt].aname),TObject(@FullAreaList.Items[cnt]));
        with Node do
         begin
         ImageIndex:=AddAreaImage(HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBFill),HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBLine));
         SelectedIndex:=ImageIndex;
         if extSA and InnerBool(FullAreaList.Items[cnt].aID,SelectedAreas)
            then StateIndex:=ptpCheckedClr
            else StateIndex:=ptpUncheckedClr;
         end;
        Node.Selected:=(SelID = FullAreaList.Items[cnt].aID);
        FillChild(SelID,Node, FullAreaList.Items[cnt].aID);
        end;
  aParentNode.StateIndex:=StateNode(aParentNode);
  end;

  procedure FillChildForLevel(SelID: integer; aParentNode : TTreeNode; aLevel : integer);
  var
   cnt : integer;
   Node : TTreeNode;
  begin
  for cnt:=0 to High(FullAreaList.Items)
    do if (FullAreaList.Items[cnt].aLevel=aLevel) or
          ((aLevel=4) and (FullAreaList.Items[cnt].aLevel>=4))
          then begin
          Node:= TV_Area.Items.AddChildObject(aParentNode,string(FullAreaList.Items[cnt].aName),TObject(@FullAreaList.Items[cnt]));
          with Node do
            begin
            ImageIndex:=AddAreaImage(HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBFill),HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBLine));
            SelectedIndex:=ImageIndex;
            if extSA and InnerBool(FullAreaList.Items[cnt].aID,SelectedAreas)
                then StateIndex:=ptpCheckedClr
                else StateIndex:=ptpUncheckedClr;
            end;
          Node.Selected:=(SelID = FullAreaList.Items[cnt].aID);
          end;
  //aParentNode.StateIndex:=StateNode(aParentNode);
  end;

var
 cnt      : integer;
 ind      : integer;
 ID       : integer;
 ti       : integer;
 Node     : TTreeNode;
// topNode  : TTreeNode;
 lvl      : integer;
 indSel   : integer;
 indId    : integer;
begin
extSA:=Length(SelectedAreas)>0;
{$WARN SYMBOL_PLATFORM OFF}
  if DebugHook<>0 then LogInfoMessage('FillFilter: '+ifThen(Assigned(UpdObject),UpdObject.Name, 'NIL'));
{$WARN SYMBOL_PLATFORM ON}
try
if FullAreaList.als<>alsName
   then FullAreaList.Arrange(alsName);
try
// -- refresh CheckListBox -------------
ti:=-1;
if not Assigned(UpdObject) or (UpdObject = ChLB_Areas_Names)
then begin
ID:=-1;
if ChLB_Areas_Names.ItemIndex>-1
   then begin
   ID:=PAreaItem(ChLB_Areas_Names.Items.Objects[ChLB_Areas_Names.ItemIndex])^.aID;
   ti:=ChLB_Areas_Names.TopIndex;
   end;
ChLB_Areas_Names.Items.BeginUpdate;
try
ChLB_Areas_Names.Items.Clear;
ChLB_Areas_Names.ItemIndex:=-1;
//ChLB_Areas_Names.Items.AddStrings(strl);
for cnt:=0 to High(FullAreaList.Items)
  do begin
  ind:= ChLB_Areas_Names.Items.AddObject(string(FullAreaList.Items[cnt].aName), TObject(@FullAreaList.Items[cnt]));
  ChLB_Areas_Names.Checked[ind]:=extSA and InnerBool(FullAreaList.Items[cnt].aID, SelectedAreas);
  if FullAreaList.Items[cnt].aID=ID
     then ChLB_Areas_Names.ItemIndex:=ind;
  end;
finally
if (ChLB_Areas_Names.ItemIndex>-1) and (ti>-1)
   then ChLB_Areas_Names.TopIndex:=ti;
ChLB_Areas_Names.Items.EndUpdate;
end;
end;
// -- refresh TreeView -------------
if not Assigned(UpdObject) or (UpdObject = TV_Area)
then begin
ID:=-1;
//topNode:=nil;
if Assigned(TV_Area.Selected) and Assigned(TV_Area.Selected.Data) and (integer(TV_Area.Selected.Data)>integer(HInstance))
   then ID:=PAreaItem(TV_Area.Selected.Data)^.aID;
TV_Area.Items.BeginUpdate;
try
TV_Area.Selected:=nil;
TV_Area.Items.Clear;
{$MESSAGE 'Зполнение фильтра зон. Разведение по родителям, уровням'}
if PC_Filter.ActivePage=TS_Filter_Parents
   then begin
    for cnt:=0 to High(FullAreaList.Items)
      do if FullAreaList.Items[cnt].aParentID=0
            then begin
            Node:= TV_Area.Items.AddObject(nil,string(FullAreaList.Items[cnt].aName),TObject(@FullAreaList.Items[cnt]));
            with Node do
             begin
             ImageIndex:=AddAreaImage(HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBFill),HTMLRGBtoColor(FullAreaList.Items[cnt].aRGBLine));
             SelectedIndex:=ImageIndex;
             if extSA and InnerBool(FullAreaList.Items[cnt].aID,SelectedAreas)
                then StateIndex:=ptpCheckedClr
                else StateIndex:=ptpUncheckedClr;
             end;
            Node.Selected:=(ID = FullAreaList.Items[cnt].aID);
            FillChild(ID, Node, FullAreaList.Items[cnt].aID);
            end;
   end
   else
if PC_Filter.ActivePage=TS_Filter_Levels
   then begin
   for cnt:=0 to CB_Level.Items.Count-1
     do begin
     Node:= TV_Area.Items.AddObject(nil,CB_Level.Items[cnt],Ptr(cnt));
     with Node do
         begin
         ImageIndex:=AddAreaImage(clWhite, clBlack);
         SelectedIndex:=ImageIndex;
         StateIndex:=ptpUncheckedClr;
         lvl:=integer(Node.Data);
         end;
     FillChildForLevel(ID, Node, lvl);
     Node.StateIndex:=StateNode(Node);
     end;
   end;
finally
TV_Area.Items.EndUpdate;
end;
end;

// -- refresh TreeView -------------
if not Assigned(UpdObject) or (UpdObject = CBTwoHoursArea)
then begin
id:=LabTHAreaID.Tag;
indId:=-1;
indSel:=-1;
CBTwoHoursArea.Items.BeginUpdate;
try
CBTwoHoursArea.Clear;
for cnt:=0 to High(FullAreaList.Items)
  do if (FullAreaList.Items[cnt].aLevel=3)
         then begin
         ind:=CBTwoHoursArea.Items.AddObject(string(FullAreaList.Items[cnt].aName), TObject(@FullAreaList.Items[cnt]));
//                                                                              TObject(@FullAreaList.Items[cnt])
         if (id<>-1) and (indId=-1) and (FullAreaList.Items[cnt].aId=id)
            then indId:=ind;
         if (id=-1) and (FullAreaList.Items[cnt].aId = Area.aID)
            then indSel:=ind;
         end;
finally
CBTwoHoursArea.Items.EndUpdate;
end;
if indSel>-1
   then CBTwoHoursArea.ItemIndex:=indSel ; // -- сперва по выбранной
if indId>-1
   then CBTwoHoursArea.ItemIndex:=indId ; // -- но в приоритете та, которую пользователь выбрал
If Assigned(CBTwoHoursArea.onChange) then CBTwoHoursArea.onChange(CBTwoHoursArea);
end;

finally
//FreeStringList(strl);
end;
except
  on E : Exception do LogErrorMessage('T_Main.FillFilter',E,[]);
end
end;


procedure T_Main.FillLastClickedCoord(const aValue : string);
var
 cnt : integer;
begin
try
LastClickedCoord.FillFromSelfXML('<LAT>'+StringReplace(aValue,',','</LAT><LNG>',[])+'</LNG>');
Lab_Coord.Caption:=LastClickedCoord.GetLonLatIntoDMS+'('+LastClickedCoord.GetLatLon(2)+')';
Lab_Coord.Hint:='';
if ForPointAreaList.Fill(LastClickedCoord,FullAreaList)>0
   then begin
   Lab_Coord.Hint:='Области в этой точке:'+crlf;
   for cnt:=0 to High(ForPointAreaList.Items)
     do Lab_Coord.Hint:=Lab_Coord.Hint+Format('%3s. %s',[IntToStr(cnt+1),AC2Str(ForPointAreaList.Items[cnt].AreaName)])+crlf;
   end;
Lab_Coord.ShowHint:=Lab_Coord.Hint<>'';
except
  on E : Exception do LogErrorMessage('T_Main.FillLastClickedCoord',E,[aValue]);
end
end;


procedure T_Main.Check_ChLB_Areas_Names;
var
 cnt : integer;
begin
try
ChLB_Areas_Names.Items.BeginUpdate;
try
for cnt:=0 to ChLB_Areas_Names.Items.Count-1
  do ChLB_Areas_Names.Checked[cnt]:=InnerBool(PAreaItem(ChLB_Areas_Names.Items.Objects[cnt])^.aID, SelectedAreas);
finally
ChLB_Areas_Names.Items.EndUpdate;
end;
except
 on E : Exception do LogErrorMessage('T_Main.Check_ChLB_Areas_Names',E,[]);
end
end;


procedure T_Main.Check_TV_Area;
var
 cnt : integer;
// id  : integer;
begin
{$WARN SYMBOL_PLATFORM OFF}
  if DebugHook<>0 then LogInfoMessage('Check_TV_Area');
{$WARN SYMBOL_PLATFORM ON}
try
TV_Area.Items.BeginUpdate;
try
if (PC_Filter.ActivePage = TS_Filter_Parents)
   then begin
   for cnt:= TV_Area.Items.Count-1 downto 0
      do if(InnerBool(PAreaItem(TV_Area.Items[cnt].Data)^.aID, SelectedAreas))
            then begin
            TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
            TV_Area.Items[cnt].MakeVisible;
            end
            else TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr;
   end
   else
if (PC_Filter.ActivePage = TS_Filter_Levels)
   then begin
   for cnt:=TV_Area.Items.Count-1 downto 0
      do begin
      if (TV_Area.Items[cnt].Level>0) and (InnerBool(PAreaItem(TV_Area.Items[cnt].Data)^.aID, SelectedAreas))
         then begin
         TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
         TV_Area.Items[cnt].MakeVisible;
         end
         else TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr;
      // -- только тут, а то выше родитель может быть зоной, а подчиненные не отмечены и отметка сбросится
      //if Assigned(TV_Area.Items[cnt].GetFirstChild)
      if TV_Area.Items[cnt].Level=0
         then TV_Area.Items[cnt].StateIndex:=StateNode(TV_Area.Items[cnt]);
      end;
   end
   else ;

//for cnt:=TV_Area.Items.Count-1 downto 0
//    do if TV_Area.Items[cnt].StateIndex=ptpCheckedClr
//          then TV_Area.Items[cnt].MakeVisible;

finally
TV_Area.Items.EndUpdate;
end;
except
 on E : Exception do LogErrorMessage('T_Main.Check_TV_Area',E,[]);
end
end;


procedure T_Main.FillAreaInfo(const aAreaXML : string);
var
 ind  : integer;
 prm  : TPerimeter;
 tmp  : TAreaItem;
 cnt  : integer;
begin
try
tmp.LoadFromXML(aAreaXML);
if tmp.aSessionID=Area.aSessionID
   then
   else
   if ExistsUnsaved
       then Exit;
AreaXML:=aAreaXML;
//tmp.LoadFromXML(aAreaXML);
//if tmp.aSessionID = EditArea.aSessionID
//   then ;
// if (Length(CancelArea.LatLng)>0) and (EditArea.aSessionID<>tmp.aSessionID ) // -- т.е. какая-то область редактируется
//     then begin
//     if (Area.getJSObject<>CancelArea.getJSObject)
//         then begin
//         case MessageBox(Handle,PChar(Format('В настоящий момент времени редактируется зона "%s".'+crlf+'Сохранить изменения?',[CancelArea.aName])),'',MB_ICONQUESTION + MB_YESNOCANCEL) of
//         IDYES : MakeSaveArea;
//         IDNO  : MakeCancelArea;
//         else Exit;
//         end;
//         end
//         else begin
//         //CancelArea.Clear;
//         //ShowSelectedAreas;
//         end;
//     end
//     else begin
//     if tmp.aSessionID = EditArea.aSessionID
//        then EditArea.LoadFromSource(tmp);
//     end;
Area.LoadFromXML(aAreaXML);
if Area.aSessionID = EditArea.aSessionID
   then EditArea.LoadFromSource(Area)
   else
if Area.aID=0
   then begin
   EditArea.LoadFromSource(Area);
   EditArea.aRecordState:=1;
   CancelArea.aSessionId:=EditArea.aSessionID;
   end;
with Area do CurObject.Fill(aID,aiitArea);
Mem_XML.Text:=aAreaXML;
Mem_XML.Text:=StringReplace(Mem_XML.Text,lf,crlf,[rfReplaceAll]);
Lab_AreaName.Hint:=Format('ID : %d',[CurObject.id]);
Ed_AreaName.onChange:=nil;
try
Ed_AreaName.Text:=string(Area.aName);
finally
Ed_AreaName.onChange:=Ed_AreaNameChange;
end;

// -- выставляем уровень
CB_Level.onChange:=nil;
try
if Area.aSessionID<>''
   then CB_Level.ItemIndex:=Area.aLevel // -- в принципе, aLevel в Clear устанавливается в -1....
   else CB_Level.ItemIndex:=-1;
finally
CB_Level.onChange:=CB_LevelChange;
end;
// -- НЕ НАДО ВЫЗЫВАТЬ OnChange : бесконечный цикл ЕСЛИ передается Sender (см. конец этой процедуры)!
//if Assigned(CB_Level.OnChange) then CB_Level.OnChange(CB_Level);
// -- создаем список возможных владельцев
CB_AreaParent.onChange:=nil;
try
ind:=FillParentAreaList(Area, CB_AreaParent);
finally
CB_AreaParent.onChange:=CB_AreaParentChange;
end;
Pan_RGBLine.Color:=HTMLRGBtoColor(Area.aRGBLine);
Pan_RGBLine.Font.Color:=ContrastColor(Pan_RGBLine.Color);
Pan_RGBFill.Color:=HTMLRGBtoColor(Area.aRGBFill);
Pan_RGBFill.Font.Color:=ContrastColor(Pan_RGBFill.Color);
if Area.aRecordState>0
   then ind:=FullAreaList.FillItem(Area);
if ind<0
   then (**);
if Area.aLevel>=3 (*ATTENTION*) (*LEVEL-INTERVAL*) {$MESSAGE 'Проверка и отображение списка интервалов по уровню области'}
   then RefreshAreaIntervalList(CurObject.id, CurObject.idType)
   else begin
   AreaIntervalList.Clear;
   DrGr_AreaIntervalList.RowCount:=2;
   end;
Lab_AreaName.ShowHint:=true;

ExtSh_Intersect.Tag:=0;
ExtSh_Intersect.Hide;
prm.MakePerimeter(Area.LatLng);
try
ind:=prm.GetIntersectCount;
ExtSh_Intersect.Tag:=ind;
if ind>0
   then begin
   Ed_AreaName.Color:=clPaleRed;
   ExtSh_Intersect.Brush.Color:=clRed;
   ExtSh_Intersect.Show;
   end
   else begin
   Ed_AreaName.Color:=clWindow;
   ExtSh_Intersect.Brush.Color:=clLime;
   ExtSh_Intersect.Hide;
   end;
finally
prm.Clear;
end;

if Assigned(CB_AreaParent.onChange) then CB_AreaParent.onChange(nil);
DrGr_AreaIntervalList.Repaint;
DTI_SetArea;

if SzPan_TwoHours.Visible then  // -- можно и отключить, чтобы всегда искало....
for cnt:=0 to CBTwoHoursArea.Items.Count-1
   do begin
   if (integer(CBTwoHoursArea.Items.Objects[cnt])>integer(Hinstance))
     and (PAreaItem(CBTwoHoursArea.Items.Objects[cnt])^.aID = Area.aID)
      then begin
      CBTwoHoursArea.ItemIndex:=cnt;
      if Assigned(CBTwoHoursArea.onChange) then CBTwoHoursArea.onChange(CBTwoHoursArea);
      Break;
      end;
   end;


except
  on E : Exception do LogErrorMessage('T_Main.FillAreaInfo',E,[]);
end
end;


procedure T_Main.FillSelectedAreas(const aIDs : array of integer);
var
 ln : integer;
begin
ln:=-1;
try
ln:=Length(aIDs);
Setlength(SelectedAreas, ln);
try
if ln=0 then Exit;
System.Move(aIDs[0],SelectedAreas[0],SizeOf(integer)*ln);
finally
SzPan_Filter.Caption:=Format('  Выбор областей для отображения. Отобрано: %d',[ln]);
if SzPanPosList.IsOut(SzPan_Filter)
   then begin
   ln:=SzPanPosList.GetIndex(SzPan_Filter.Handle);
   if ln>-1
      then SzPanPosList.Items[ln].ParentForm.Caption:=Trim(SzPan_Filter.Caption);
   end;
end;
except
  on E : Exception do LogErrorMessage('T_Main.FillLastClickedCoord',E,[ln]);
end
end;


procedure T_Main.ShowSelectedAreas;
var
 areas : string;
begin
try
if viaJSObjects
   then begin
    areas:=FullAreaList.getJSObject(SelectedAreas);
   if areas<>''
      then ExecuteScript(WB, Format('SetArrayOfPolygonNew(%s)',[areas]))
      else (*can log why empty*);
//--20170525--
//   end
//   else begin
//   areas:=FullAreaList.getStrObject(SelectedAreas);
//   if areas<>''
//      then ExecuteScript(WB, Format('SetArrayOfPolygon(%s)',[AnsiQuotedStr(areas,'"')]))
//      else (*can log why empty*);
//--20170525--
   end;
if Length(SelectedAreas)>0
   then begin
   areas:=FullAreaList.getJSONForBound(SelectedAreas);
   ExecuteScript(WB, Format('SetBoundsForPoints(%s)',[areas]));
   end;
except
  on E : Exception do LogErrorMessage('T_Main.ShowSelectedAreas',E,[]);
end
end;

function T_Main.AddAreaImage(aFill, aLine : TColor) : integer;
//var
// _bmp : TBitmap;
// szBMP: integer;
begin
Result:=AreaPicList.Add(aFill, aLine);
//if Result>-1 then Exit;
////Exit;
//try
//_bmp:=TBitmap.Create;
//try
//with _bmp do
//  begin
//  szBMP:=AreaPicList. IL_Area.Width;
//  Height:=szBMP;
//  Width:=szBMP;
//  Canvas.Brush.Color:=clFuchsia;
//  Canvas.FillRect(Bounds(0,0,szBMP,szBMP));
//  Canvas.Brush.Color:=LightColor(aFill,50);
//  Canvas.Pen.Color:=aLine;
//  Canvas.Rectangle(1,1,Width-2,Height-2);
//  Result:=IL_Area.AddMasked(_bmp, clFuchsia);
//  end;
//finally
//_bmp.Free;
//end;
//except
//on E : Exception do LogErrorMessage('T_Main.AddAreaImage',E,[]);
//end;
end;


procedure T_Main.ShowMarkersOrRoute(aCarID : integer; asRoute : boolean);
var
 ML      : TMarkerList;
 cnt     : integer;
 ind     : integer;
 arIDs   : TIntegerDynArray;
 markers : string;
begin
try
ClearMap;
if ((wmtMarkers in WorkMode) and (not asRoute))
   then
   else
if ((wmtRoute in WorkMode) and (asRoute))
   then
   else begin
   if asRoute
      then ShowMessageInfo('В настоящий момент времени установлен запрет на просмотр маршрутов доставки.')
      else ShowMessageInfo('В настоящий момент времени установлен запрет на просмотр точек доставки на карте.');
   Exit;
   end;
if MarkerList.MarkersForDisplay(aCarID, ML)
   then begin
   for cnt:=0 to High(ML.Items)
     do begin
     if not InnerBool(ML.Items[cnt].Area_ID, arIDs)
           then begin
           ind:=Length(arIDs);
           SetLength(arIDs,ind+1);
           arIDs[ind]:=ML.Items[cnt].Area_ID;
           end;
     end;
   FillSelectedAreas(arIDs);
   ShowSelectedAreas;
   _sleep(std_JS_Wait);
   markers:=ML.getDescriptionObj(not asRoute);
   if markers<>''
      then begin
      if asRoute
         then markers:=Format('CreateRoute(%s)',[markers])
         else markers:=Format('SetArrayOfMarker(%s)',[markers]);
      //CopyStringIntoClipboard(markers);
      ExecuteScript(WB, markers);
      end
      else (*log empty string*);
   end;
except
on E : Exception do LogErrorMessage('T_Main.ShowMarkers',E,[aCarID]);
end;
end;


procedure T_Main.ShowDeliveryControls(aVisible : boolean);
const ptTown = 'городу ';
begin
try
DTP_DeliveryDate.Visible:=aVisible;
SpB_DeliveryAgent.Visible:=aVisible;
Lab_DeliveryDate.Visible:=not aVisible;
Im_DeliveryAgent.Visible:=not aVisible;
Lab_DeliveryAgent.Visible:=not aVisible;
Lab_DeliveryDate.Left:=DTP_DeliveryDate.Left;
Lab_DeliveryDate.Top:=LabT_DeliverysTitle.Top;
DTP_DeliveryDateChange(DTP_DeliveryDate);
Im_DeliveryAgent.Left:=Lab_DeliveryDate.Left+Lab_DeliveryDate.Width+4;
Im_DeliveryAgent.Top:=SpB_DeliveryAgent.Top;
Lab_DeliveryAgent.Caption:=Copy(Im_DeliveryAgent.Hint,AnsiPos(ptTown,Im_DeliveryAgent.Hint)+Length(ptTown),Length(Im_DeliveryAgent.Hint));
Lab_DeliveryAgent.Left:=Im_DeliveryAgent.Left+Im_DeliveryAgent.Width+4;
Lab_DeliveryAgent.Top:=Lab_DeliveryDate.Top;
except
on E : Exception do LogErrorMessage('T_Main.ShowDeliveryControls',E,[]);
end;
end;


procedure T_Main.CallInputDateTimeInterval(aID : integer; aStart : TDateTime; var  aFrom, aTo: TDateTime; aActive: boolean; OnlyInterval : boolean = false);
 var
 ind    : integer;
 d,h,m  : integer;
 strl   : TStringList;
 resind : integer;
 aii    : TAreaIntervalItem;
 cnt    : integer;
 msg    : string;
 anc    : string;
 dtS    : TDateTime;
 dtL    : TDateTime;
 res    : boolean;
begin
try
resind:=integer(aActive);
strl:=TStringList.Create;
try
if Trunc(aStart) = Trunc(aFrom)
   then res:=InputDateTimeInterval('Установка интервала','Дата',aFrom,aTo,strl,resind,OnlyInterval)
   else res:=InputDateTimeInterval('Установка интервала','Дата',aStart,aFrom,aTo,strl,resind,aStart,aStart+7,Trunc(aTo) - Trunc(aStart)+integer(Frac(aTo)>0),OnlyInterval);
if res
   then begin
   if OnlyInterval then Exit;
   dtS:=RoundTo( aFrom,dtRnd);
   dtL:=RoundTo(aTo - aFrom,dtRnd);
   if (aID=0) and (AreaIntervalList.GetIndexForAll(CurObject.id, dtS, dtL)>-1)
      then begin
      msg:=FormatDateTime('dd.mm.yyyy hh:nn', aFrom)+ ' - ' + FormatDateTime('dd.mm.yyyy hh:nn', aTo);
      if MessageBox(Handle,PChar(Format('Интервал "%s" для зоны "%s" уже существует. Изменить параметры?',[msg,Area.aName])),'Сохранение интервала',MB_ICONQUESTION + MB_YESNO)=IDYES
         then CallInputDateTimeInterval(aID, DateTime(Trunc(aFrom)),aFrom, aTo, aActive, OnlyInterval);
      Exit;
      end;
   Frm_Interval.CalcInterval(aFrom,aTo,d,h,m);
   FillChar(aii,SizeOf(TAreaIntervalItem),0);
   aii.aiID     := aID;
   aii.aiAreaID := CurObject.id;
   aii.aiIdType := CurObject.idType;
   aii.aiStart  := dtS;
   aii.aiLen    := dtL;
   aii._Changed := True;
   if aii.aiID>0
      then ind:=AreaIntervalList.GetIndexByID(aii.aiID)
      else ind:=AreaIntervalList.GetIndexForAll(CurObject.id, dtS, dtL);
   if ind=-1
      then msg:='ДОБАВЛЕНИЕ (будет): '
      else msg:='ИЗМЕНЕНИЕ (будет): ';
   {$WARN SYMBOL_PLATFORM OFF}
   if (debughook<>0) and (MessageBox(Handle,'Сейчас будет сохранен интервал.','Кстати!',MB_ICONQUESTION+MB_YESNO)=IDNO)
       then Exit;
   {$WARN SYMBOL_PLATFORM ON}
   if aii.SaveIntoDB
      then begin
      RefreshAreaIntervalList(CurObject.id, CurObject.idType);
      if aii.aiID=0
         then begin
         anc:=FormatFloat('0000000000',aii.aiAreaID)+FormatDateTime('_yyyymmdd_hhnnss',aii.aiStart)+FormatDateTime('_yyyymmdd_hhnnss',aii.aiLen);
         for cnt:=0 to High(AreaIntervalList.Items)
           do with AreaIntervalList.Items[cnt] do
                if FormatFloat('0000000000',aiAreaID)+FormatDateTime('_yyyymmdd_hhnnss',aiStart)+FormatDateTime('_yyyymmdd_hhnnss',aiLen) = anc
                   then begin
                   ind:=cnt;
                   aii.aiID:=aiID;
                   Break;
                   end;
         end;
      cnt:=Length(AreaIntervalList.Items);
      DrGr_AreaIntervalList.RowCount:=1+cnt+integer(cnt=0);
      DrGr_AreaIntervalList.Repaint;
      SetVisibleRow3(DrGr_AreaIntervalList,ind+1);
      end
      else (* ... всё плохо, ничего не сохранилось ...*);
   end;
finally
FreeStringList(strl);
end;
except
on E : Exception do LogErrorMessage('T_Main.CallInputDateTimeInterval',E,[aID]);
end;
end;


procedure T_Main.ShowUsedAreas;
var
 TV_Str : string;
 buf    : PAnsiChar;
 MS     : TMemoryStream;
begin
try
TV_Str:=UsedAreaList.GroupBy(UsedAreasViewMode);
TV_Tools_UsedAreas.Items.BeginUpdate;
MS:=TMemoryStream.Create;
buf:=AllocMem(Length(TV_Str)+1);
try
TV_Tools_UsedAreas.Canvas.Font:=TV_Tools_UsedAreas.Font;
TV_Tools_UsedAreas.Items.Clear;
StrPCopy(buf,AnsiString(TV_Str));
MS.Write(buf^,Length(TV_Str));
MS.Position:=0;
TV_Tools_UsedAreas.LoadFromStream(MS);
finally
FreeMem(buf);
MS.Free;
TV_Tools_UsedAreas.Items.EndUpdate;
end;
except
on E : Exception do LogErrorMessage('T_Main.CreateIntervalList',E,[]);
end;
end;


var  // -- используется ниже, для перерисовки TV_Tools_UsedAreas
 TV_Tools_UsedAreas_spH : integer = 0;

procedure T_Main.TV_Tools_UsedAreas_CheckScrollInfo;
var
 sp : integer;
begin
sp:=GetScrollPos(TV_Tools_UsedAreas.Handle,SB_HORZ);
if sp<>TV_Tools_UsedAreas_spH
  then begin
  TV_Tools_UsedAreas_spH:=sp;
  TV_Tools_UsedAreas.Repaint;
  end;
end;




function T_Main.CanSaveArea_CheckParams(aArea : TAreaItem) : boolean;
const
 strNoSave : string = crlf+'Сохранение невозможно!';
var
 msg : string;
begin
Result:=True;
try
try
if string(aArea.aName)=''
   then begin
   Result:=false;
   msg:=Format('Область должна иметь наименование',[]);
   end;
if Length(aArea.LatLng)<3
   then begin
   Result:=false;
   msg:=Format('Область "%s" не имеет достаточное кол-во точек для сохранения и отображения (%d, минимум 3).' ,[ string(aArea.aName),Length(aArea.LatLng)]);
   end;
if (aArea.aLevel=0)
   then begin
   Result:=false;
   msg:=Format('Для области "%s" не установлен тип.' ,[ string(aArea.aName)]);
   end;
if (aArea.aLevel>3) and (aArea.aParentID=0)
   then begin
   Result:=false;
   msg:=Format('Тип области "%s" установлен как временнОй, но родительская область доставки курьером отстутвует.' ,[ string(aArea.aName)]);
   end;
finally
if not Result
   then ShowMessageWarning('Проверка параметров области:'+crlf+msg+strNoSave,'Возможность сохранения области');
end;
except
on E : Exception do LogErrorMessage('T_Main.CanSaveArea_CheckParams',E,[]);
end;
end;


function T_Main.CanSaveArea_CheckPoints(aArea : TAreaItem) : boolean;
var
 parID    : integer;
 cnt      : integer;
 ind      : integer;
 childIDs : TIntegerDynArray;
 childRes : TBooleanDynArray;
 pts      : TArrayOfFloatPoint;
 msg      : string;
begin
if not CheckOutPoints
   then begin
   Result:=true;
   Exit;
   end;
msg:='';
Result:=true;
try
parID:=aArea.aParentID;
SetLength(childIDs,0);
if aArea.aID>0
   then begin
   for cnt:=0 to High(FullAreaList.Items)
      do if (FullAreaList.Items[cnt].aParentID = aArea.aID)
            then begin
            ind:=Length(childIDs);
            Setlength(childIDs,ind+1);
            childIDs[ind]:=FullAreaList.Items[cnt].aID;
            end;
   end;
SetLength(childRes,Length(childIDs));
for cnt:=0 to High(childRes) do childRes[cnt]:=false;
if parID>0
   then begin
   try
   ind:=FullAreaList.GetIndexByID(parID);
   if ind>-1
      then begin
      GetInnerPoints(aArea.LatLng, FullAreaList.Items[ind].LatLng, pts);
      if Length(pts)=Length(aArea.LatLng)
         then Result:=true
         else begin
         Result:=false;
         msg:=msg+Format('Область "%s". В родительскую область "%s" вошло точек: %d (из %d).'+crlf,[ string(aArea.aName), string(FullAreaList.Items[ind].aName), Length(pts),Length(aArea.LatLng)]);
         end;
      end;
   finally
   SetLength(pts,0);
   end;
   end;
if Length(childIDs)>0
   then begin
   for cnt:=0 to High(childIDs)
      do begin
      ind:= FullAreaList.GetIndexByID(childIDs[cnt]);
      try
      if ind>-1
         then begin
         GetInnerPoints(FullAreaList.Items[ind].LatLng, aArea.LatLng,  pts);
         if Length(pts)=Length(FullAreaList.Items[ind].LatLng)
            then childRes[cnt]:=true
            else begin
            childRes[cnt]:=false;
            msg:=msg+Format('Подчиненная область "%s". В проверяемую область "%s" вошло точек: %d (из %d).'+crlf,[ string(FullAreaList.Items[ind].aName), string(aArea.aName), Length(pts),Length(FullAreaList.Items[ind].LatLng)]);
            end;
         end;
      finally
      SetLength(pts,0);
      end;
      end;
   for cnt:=0 to High(childRes) do Result:=Result and childRes[cnt];
   end;
if not Result and (msg<>'')
   then ShowMessageWarning('Проверка вхождения точек:'+crlf+msg+crlf+'Сохранение невозможно!','Возможность сохранения области');
except
on E : Exception do LogErrorMessage('T_Main.CanSaveArea_CheckPoints',E,[]);
end;
end;
//    ind:=FullAreaList.GetAreaDataById(ParID,_nm,_rn);
//if ind<0 then Exit;
//Setlength(cont, Length(FullAreaList.Items[ind].LatLng));
//if Length(cont)=0 then Exit;
//System.Move(FullAreaList.Items[ind].LatLng[0], cont[0], Length(FullAreaList.Items[ind].LatLng)*SizeOf(TFloatPoint));
//res:=GetInnerPoints(Area.LatLng, cont, pts);

procedure T_Main.RefreshAreaIntervalList(aAreaID : integer; aAreaType : TAreaIntervalIdType);
var
 ind : integer;
 dt  : TDateTime;
 cnt : integer;
begin
try
ind:=AreaIntervalList.LoadFromDB(aAreaID,aAreaType);
DrGr_AreaIntervalList.RowCount:=1+ind+integer(ind=0);
if ind>0
   then begin
   ind:=-1;
   dt:=Date+daysNoEditInterval+1;
   for cnt:=High(AreaIntervalList.Items) downto 0
     do //if dt <= AreaIntervalList.Items[cnt].aiDate
          if dt <= AreaIntervalList.Items[cnt].aiStart
           then begin
           SetVisibleRow3(DrGr_AreaIntervalList,cnt+1);
           ind:=cnt;
           Break;
           end;
   case ind of
   -1 : (*новый добавлять нужно*) ;
    else (*редактировать будем*);
   end;
   end;
Lab_RefreshTimeOfAIL.Caption:=Format('%s (%d)',[FormatDateTime('hh:nn:ss.zzz',Time),Length(AreaIntervalList.Items)]);
DrGr_AreaIntervalList.Repaint;
except
on E : Exception do LogErrorMessage('T_Main.RefreshAreaIntervalList',E,[aAreaID]);
end;
end;


procedure T_Main.DeleteCurrentInterval;
var
 ind : integer;
 aii : TAreaIntervalItem;
 msg : string;
 id  : integer;
 an  : string;
begin
try
ind:=DrGr_AreaIntervalList.Row-1;
if (ind<Low(AreaIntervalList.Items)) or (ind>High(AreaIntervalList.Items))
   then Exit;
System.Move(AreaIntervalList.Items[ind], aii, SizeOf(TAreaIntervalItem));
msg:=FormatDateTime('dd.mm.yyyy hh:nn', DateTime(aii.aiStart))+ ' - ' + FormatDateTime('dd.mm.yyyy hh:nn', DateTime(aii.aiStart+aii.aiLen));
case aii.aiIdType of
aiitArea : an:=Format('зоны "%s"',[Area.aName]);
aiitPVZ  : an:=Format('ПВЗ "%s"',[PVZList.GetDescriptionByID(aii.aiAreaID)]);
end;
if MessageBox(Handle,PChar(Format('Интервал "%s" для %s будет удален безвозвратно. Продолжать?',[msg,an])),'Сохранение интервала',MB_ICONQUESTION + MB_YESNO)=IDYES
   then begin
   aii.aiID:=-1*Abs(aii.aiID);
   if aii.SaveIntoDB
      then begin
      if ind=0
         then ind:=1
         else ind:=ind-1;
      if (ind>=Low(AreaIntervalList.Items)) and (ind<=High(AreaIntervalList.Items))
         then id:=AreaIntervalList.Items[ind].aiID
         else id:=0;
      RefreshAreaIntervalList(CurObject.id, CurObject.idType);
      if id>0
        then for ind:=0 to High(AreaIntervalList.Items)
                do if AreaIntervalList.Items[ind].aiID=id
                      then begin
                      SetVisibleRow3(DrGr_AreaIntervalList,ind+1);
                      DrGr_AreaIntervalList.Repaint;
                      Break;
                      end;
      end;
   end;
except
on E : Exception do LogErrorMessage('T_Main.DeleteCurrentInterval',E,[]);
end;
end;


function T_Main.ProcessingId_Result(const avalue : string) : boolean;
begin
Result:=false;
try
if Pos('%20',avalue)<>0
   then LogInfoMessage('MessageFromHTML: '+StringReplace(avalue,'%20',' ',[rfReplaceAll]))
   else begin

   end;
except
  on E : Exception do LogErrorMessage('T_Main.InfoAboutPoints',E,[avalue]);
end
end;

function T_Main.AreaIntersectMessage(const ListOfAreas,DopMessage : string) : integer;
const
 _shb = 'Подготовлен список областей для отображения:%1:s'+
        'Эти области имеют пересченния линий периметра.%0:s'+
        'Это влияет на целостность данных и требует скорейшего исправления.%0:s%2:s';
begin
Result:=MessageBox(Handle,PChar(Format(_shb,[crlf,ListOfAreas,DopMessage])),'К сведению',MB_ICONWARNING + IfThen(DopMessage<>'',MB_YESNO,MB_OK));
end;




procedure T_Main.CheckIntersectAreas(var IDs : TIntegerDynArray; var ListOfAreas : string);
var
 cnt    : integer;
 ind    : integer;
begin
{$MESSAGE 'Проверка пересечения границ областей'}
SetLength(IDs,0);
ListOfAreas:=crlf;
for cnt:=0 to High(FullAreaList.Items)
  do if FullAreaList.Items[cnt].aGeoNum>1
        then begin
        ind:=Length(IDs);
        Setlength(IDs, ind+1);
        IDs[ind]:=FullAreaList.Items[cnt].aID;
        ListOfAreas:=ListOfAreas+Format(#9'%d. %s',[ind+1,string(FullAreaList.Items[cnt].aName)])+crlf;
        end;
end;
//
//
//var
// inFillData : boolean = false;
//
//procedure T_Main.FillTwoHoursData;
//var
// cnt    : integer;
// ind    : integer;
// indSel : integer;
// indId  : integer;
// id     : integer;
//begin
//if inFilldata
//   then begin
//   {$WARN SYMBOL_PLATFORM OFF}
//   if DebugHook<>0 then LogInfoMessage('Попытка повторного входа в процедуру.');
//   {$WARN SYMBOL_PLATFORM ON}
//   Exit;
//   end;
//try
//inFillData:=true;
//id:=LabTHAreaID.Tag;
//if Length(FullAreaList.Items)=0
//   then begin
//   RefreshAreaList;
//   Exit;
//   end;
//indId:=-1;
//indSel:=-1;
//CBTHArea.Items.BeginUpdate;
//try
//CBTHArea.Clear;
//for cnt:=0 to High(FullAreaList.Items)
//  do if (FullAreaList.Items[cnt].aLevel=3)
//         then begin
//         ind:=CBTHArea.Items.AddObject(string(FullAreaList.Items[cnt].aName), TObject(@FullAreaList.Items[cnt]));
////                                                                              TObject(@FullAreaList.Items[cnt])
//         if (id<>-1) and (indId=-1) and (FullAreaList.Items[cnt].aId=id)
//            then indId:=ind;
//         if (id=-1) and (FullAreaList.Items[cnt].aId = Area.aID)
//            then indSel:=ind;
//         end;
//finally
//CBTHArea.Items.EndUpdate;
//end;
//if indSel>-1
//   then CBTHArea.ItemIndex:=indSel ; // -- сперва по выбранной
//if indId>-1
//   then CBTHArea.ItemIndex:=indId ; // -- но в приоритете та, которую пользователь выбрал
//If Assigned(CBTHArea.onChange) then CBTHArea.onChange(CBTHArea);
//finally
//inFillData:=false;
//end;
//end;
//

function T_Main.H2Data(const ARow : integer; var PILIndex, AreaId, IntervalId : integer) : boolean ;
var
 ind : integer;
begin
Result:=false;
try
PILIndex:=-1;
AreaId:=LabTHAreaID.Tag;
if AreaId<=0 then Exit;
ind:=Arow-1;
if (ind>=Low(H2List.Items)) and (ind<=High(H2List.items))
   then IntervalId:=H2List.Items[ind].id
   else Exit;
PILIndex:=PayIntervalList.IndexOf(AreaId, IntervalId);
Result:=true;
except
end;
end;

function T_Main.EditH2Interval(var PII : TPayIntervalItem) : boolean;
var
  _H2Interval: T_H2Interval;
  cnt : integer;
  ind : integer;
  areaname : string;
begin
Result:=false;
if PII.AreaId=0
   then begin
   ShowMessageWarning('При редактировании описания интервала не указана область. Редактирование невозможно.');
   Exit;
   end;
FullAreaList.GetAreaDataById(PII.AreaId,areaname, ind);
_H2Interval:=T_H2Interval.Create(Application);
try
with _H2Interval.CBInterval do
 begin
 Items.BeginUpdate;
 try
 Clear;
 for cnt:=0 to High(H2List.items)
   do begin
   ind:=Items.AddObject(H2List.items[cnt].View(true),TObject(H2List.items[cnt].id));
   if PII.IntervalId=H2List.items[cnt].id
      then ItemIndex:=ind;
   end;
 finally
 Items.EndUpdate;
 end;
 if (ItemIndex>-1) and Assigned(onChange)
    then begin
    onChange(_H2Interval.CBInterval);
    Enabled:=false; // -- и отключаем на фиг выбор (перед вызовом выбрали уже)
    end
 end;
_H2Interval.BBDelete.Visible:=PII.id<>0;
if PII.id>0
   then begin
    with _H2Interval.BBDelete do
      begin
      Caption:='Удалить';
      Hint:='Установить отметку "на удаление"';
      SetGlyph(_H2Interval.BBDelete, IL_Paint, [ptpClose]);
      ShowHint:=true;
      end;
   end
   else
if PII.id<0
   then begin
   with _H2Interval.BBDelete do
      begin
      Caption:='Восстановить';
      Hint:='Снять отметку "на удаление"';
      SetGlyph(_H2Interval.BBDelete, IL_Paint, [ptpReturn]);
      ShowHint:=true;
      end;

   end;
SetGlyph(_H2Interval.BBcancel, IL_Paint, [ptpUndo]);
SetGlyph(_H2Interval.BBok, IL_Paint, [ptpHammerOfJudge]);

_H2Interval.LabAreaInfo.Tag:=PII.AreaId;
_H2Interval.LabAreaInfo.Caption:=areaname;
if PII.DateBegin<>0
   then _H2Interval.dtpDateBegin.dateTime:=Trunc(PII.DateBegin);
if PII.DateEnd<>0
   then begin
   _H2Interval.dtpDateEnd.Checked:=true;
   _H2Interval.dtpDateEnd.dateTime:=Trunc(PII.DateEnd);
   end;
_H2Interval.seQuota.Value:=PII.Quota;
case _H2Interval.ShowModal of
mrOk :
   begin
   if PII.IntervalId=0
      then PII.IntervalId:=integer(_H2Interval.CBInterval.Items.Objects[_H2Interval.CBInterval.ItemIndex]);
   PII.DateBegin:=trunc(_H2Interval.dtpDateBegin.Date);
   if _H2Interval.dtpDateEnd.Checked
      then PII.DateEnd:=trunc(_H2Interval.dtpDateEnd.Date)
      else PII.DateEnd:=0;
   PII.Quota:=_H2Interval.seQuota.Value;
   Result:=true; // -- оставляем в массиве изменений (на изменение)
   end;
mrAbort :
   begin
   ind:=H2List.IndexOf(PII.IntervalId);
   if (ind>-1)
      then begin
      if PII.id>0
         then begin
         if (MessageBox(Handle, PChar(Format('Интервал "%s" для "%s"(%d) будет помечен "на удаление". Продолжаем?',[H2List.items[ind].View(true),Areaname,PII.AreaId])),'Внимание!',MB_ICONWARNING+MB_YESNO)=IDYES)
            then begin
            PII.id:=Abs(PII.id)*-1;
            Result:=true; // -- оставляем в массиве изменений (на удаление)
            end;
         end
         else begin
         if (MessageBox(Handle, PChar(Format('С интервала "%s" для "%s"(%d) будет снята отметка "на удаление". Продолжаем?',[H2List.items[ind].View(true),Areaname,PII.AreaId])),'Внимание!',MB_ICONINFORMATION+MB_YESNO)=IDYES)
            then PII.id:=Abs(PII.id);
         end;
      end
      else ShowMessageInfo('Не укзан интервал.')
   end;
   else ;
end;
finally
_H2Interval.Free;
end;
DrGrDisplayPIL.Repaint;
end;


procedure T_Main.PayIntervalInfo;
const
 areaShablon = '<tr><td colspan="4" align="center">%s</td></tr>';
 rowShablon = '<tr bgcolor="%s"><td>%s</td><td>%s</td><td>%s</td><td align="center">%d</td><tr>';

var
 cnt   : integer;
 html  : string;
 areaId: integer;
 areaName : string;
 route  :integer;
begin
html:=
'<!DOCTYPE html>'
 +'<html xmlns="http://www.w3.org/1999/xhtml" xmlns:vml="urn:schemas-microsoft-com:vml">'
 +'<head>'
 +'<title>Области и платные интервалы</title>'
 +'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>'
 +'</head>'
 +'<body>'
 +'<table width="100%" border="1" cellspacing="0" cellpadding="4" bordercolor="#404040" style="font-size:90%">'
 +'<tr>'
 +'<th colspan="4">Область</th>'
 +'</tr>'
 +'<tr>'
 +'<th>Время</th>'
 +'<th>Начало</th>'
 +'<th>Окончание</th>'
 +'<th>Квота</th>'
 +'</tr>';


PayIntervalList.Sort; // -- пока только при получении из БД
areaId:=0;
for cnt:=0 to High(PayIntervalList.items)
  do begin
  if areaId<>PayIntervalList.items[cnt].AreaId
     then begin
     areaId:=PayIntervalList.items[cnt].AreaId;
     FullAreaList.GetAreaDataById(areaId, areaName, route);
     html:=html+ Format(areaShablon,[areaname]) ;
     end;
  html:=html+ Format(rowShablon,[
     IfThen(PayIntervalList.items[cnt].Quota<>0,'#FFFFFF','#FFCCCC')
    ,H2List.DisplayString(H2List.IndexOf(PayIntervalList.items[cnt].IntervalId),-1)
    ,FormatDateTime('dd.mm.yyyy',PayIntervalList.items[cnt].DateBegin)
    ,IfThen(PayIntervalList.items[cnt].DateEnd<>0,FormatDateTime('dd.mm.yyyy',PayIntervalList.items[cnt].dateEnd),'')
    ,PayIntervalList.items[cnt].Quota
  ]);
  end;
html:=html+'</table></body></html>';
ScrollMessageBox('Области и платные интервалы',html,'','Информация',MB_ICONINFORMATION, MB_OK, true);
end;


function T_Main.StateNode(Node : TTreeNode) : integer;
var
   cCnt : integer;
   uCnt : integer;
   cn : TTreeNode;
begin
Result:=Node.StateIndex;
cCnt := 0;
uCnt := 0;
cn:=Node.getFirstChild;
if not Assigned(cn) then Exit;
while Assigned(cn)
  do begin
  if cn.StateIndex=ptpCheckedClr
     then inc(cCnt)
     else
  if cn.StateIndex=ptpUncheckedClr
     then inc(uCnt);
  cn:=Node.GetNextChild(cn);
  end;
if (cCnt=0) and (uCnt<>0)
    then Result:=ptpUncheckedClr
    else
if (cCnt<>0) and (uCnt=0)
    then Result:=ptpCheckedClr
    else Result:=ptpPartCheck02;
end;










(* ---  PUBLIC ------------------------------------------------------------------------------- *)



function T_Main.LoadHTMLPage(const aPageURI : string) : boolean;
var
 body     : string;
 url      : string;
 err      : string;
 mxCnt    : integer;
begin
err:='';
Result:=false;
ShowSplash(Format('Загрузка HTML страницы [%s]',[aPageURI]), stInfo);
try
try
body:=LoadStringFromURI(aPageURI, err);
if body<>''
   then begin
   // -- !!! и только так, иначе не проходит инициализация....
   if HTMLResourceName<>'HTML_WRITE_NEW'
      then body:=StringReplace(body,'<body>','<body onload="'+Format('CallInitialize(%d, %d)',[integer(MapMode),integer(wmtWrite in WorkMode)])+'">',[]);
   HTMLFileName:=SetTailbackSlash(GetTempFolder)+'ae'+FormatDateTime('_yyyymmdd_hhnnss',Now)+'.HTML';
   SaveStringIntoFileWide(body, HTMLFileName);
   _sleep(100);
   url:='file://'+StringReplace(HTMLFileName,string('\'),string('/'),[rfReplaceAll]);
   WB.Navigate(url);
   mxCnt:=0;
   while WB.ReadyState = READYSTATE_LOADING
    do begin
    _sleep(10);
    sleep(10);
    inc(mxCnt);
    if mxCnt>500
       then begin
       LogInfoMessage(Format('Превышено ожидание необходимого статуса браузера (%s)',[url]));
       Break;
       end;
   end;
   while WB.Busy
      do begin
      _sleep(100);
      Caption:='Загрузка страницы....';
      Update;
      end;
   if Assigned(WB.Document)
      then begin
      LogInfoMessage(Format('Загрузка страницы "%s"',[HTMLFileName]));
      Result:=true;
      end
      else begin
      LogInfoMessage(Format('Сбой загрузки страницы "%s"',[HTMLFileName]));
      CanDelHTMLOnExit:=false;
      end;
   end;
LogInfoMessage(Format('LoadHTMLPage [%s, %s] ',[aPageURI, err]));
finally
FreeSplash;
end;
except
on E : Exception do LogErrorMessage('LoadHTMLPage',E,[aPageURI]);
end;
end;



function T_Main.ExistsUnsaved : boolean;
var
 cnt : integer;
begin
Result:=False;
try
if Area.aRecordState>0
   then begin
   Result:=true;
   Exit;
   end;
for cnt:=0 to High(FullAreaList.Items)
  do if FullAreaList.Items[cnt].aRecordState>0
        then begin
        Result:=true;
        Exit;
        end;
except
on E : Exception do LogErrorMessage('T_Main.ExistsUnsaved',E,[]);
end;
end;


function T_Main.ClearMap : boolean;
begin
Result:=False;
try
ExecuteScript(WB, 'ClearMarkerList()');
 _sleep(std_JS_Wait);
ExecuteScript(WB, 'ClearPolygonList()');
 _sleep(std_JS_Wait);
ExecuteScript(WB, 'ClearRouteList()');
 _sleep(std_JS_Wait);
Result:=true;
except
on E : Exception do LogErrorMessage('T_Main.ClearMap',E,[]);
end;
end;


function T_Main.RefreshAreaList : boolean;
var
 xml : string;
 ln  : integer;
 agent : string;

begin
Result:=False;
if Now - ralTime <= EncodeTime(0,0,2,0)
   then Exit;
ShowSplash('Обновление списка областей', stInfo);
try
try
xml:='<used>'
     +IntToStr(
     +integer(ChB_UsedNow.Checked)*$01
     +integer(ChB_UsedAdm.Checked)*$02
     +integer(ChB_UsedNo.Checked)*$04
     )
     +'</used>';
agent:='<agent>';
if chbAgent0001.Checked then agent:=agent+'<id>1</id>';
if chbAgent0013.Checked then agent:=agent+'<id>13</id>';
if chbAgent8519.Checked then agent:=agent+'<id>8519</id>';
agent:=agent+'</agent>';
xml:=xml+agent;
Result:=FullAreaList.LoadFromDB(xml);

LogInfoMessage('FullAreaList.LoadFromDB',[Length(FullAreaList.items),xml]);

if Result
   then begin
   FillFilter(nil);
   LogInfoMessage(Format('Получено описаний областей: %d',[Length(FullAreaList.Items)]));
   end;
ln:=Length(FullAreaList.Items);
LabFullAreaList.Caption:=Format('Всего областей загружено: %d (%s)',[ln,Trim(StringReplace(NumberToWords(ln,dfSecond),GetDefUnit(ln,dfSecond),'',[]))]);

ShowSplash('Список "область-агент', stInfo);
AreaAgentList.LoadFromDB;
ShowSplash('Двухчасовые интервалы: словарь', stInfo);
H2List.LoadFromDB;
ShowSplash('Двухчасовые интервалы: данные', stInfo);
PayIntervalList.LoadFromDB;
ShowSplash('Подготовка отображения областей', stInfo);

if FullAreaList.als<>alsName
   then FullAreaList.Arrange(alsName);

if SzPan_TwoHours.Visible
   then begin
   FillFilter(CBTwoHoursArea);
   DrGrDisplayPIL.Repaint;
   end;

if SzPan_Filter.Visible
   then begin
   if PC_Filter.ActivePage = TS_Filter_Names
      then FillFilter(ChLB_Areas_Names)
      else
   if (PC_Filter.ActivePage = TS_Filter_Parents) or
      (PC_Filter.ActivePage = TS_Filter_Levels)
      then FillFilter(TV_Area);
   end;

finally
FreeSplash;
ralTime:=Now;
end;
except
on E : Exception do LogErrorMessage('T_Main.RefreshAreaList',E,[]);
end;
end;


function T_Main.FillParentAreaList(const aArea : TAreaItem; aComboBox : TComboBox) : integer;
var
 cnt    : integer;
 tmp    : integer;
 ind    : integer;
 ifl    : integer;
 arName : string;
begin
ind:=-1;
Result:=ind;
try
aComboBox.Items.BeginUpdate;
try
aComboBox.Items.Clear;
for cnt:=0 to High(FullAreaList.Items)
  do with FullAreaList.Items[cnt] do
    if (1=1) // -- до условия отбора (типа проверка на закольцовку? и т.д.)
       and ((aArea.aLevel in [4,5,6]) and (aLevel=3)) or ((aArea.aLevel<=3) and (aLevel<aArea.aLevel))
       and (aID<>aArea.aID)
       then begin
       ifl:=FullAreaList.GetAreaDataById(aID, arname, tmp);
       tmp:=aComboBox.Items.AddObject(string(FullAreaList.Items[ifl].aName),TObject(@FullAreaList.Items[ifl]));
       if aArea.aParentID = FullAreaList.Items[ifl].aID
          then ind:=tmp;
       end;
finally
if ind>-1
   then aComboBox.ItemIndex:=ind;
aComboBox.Items.EndUpdate;
end;
if Assigned(aComboBox.onChange) then aComboBox.onChange(aComboBox);
Result:=ind;
except
on E : Exception do LogErrorMessage('T_Main.FillParentAreaList',E,[]);
end;
end;

function T_Main.RefreshPVZList : boolean;
var
 res : integer;
begin
Result:=false;
try
res:=PVZList.LoadFromDB;
if res>=0
   then begin
   DrGr_PVZList.RowCount:=res+1+integer(res=0);
   DrGr_PVZList.Invalidate;
   LogInfoMessage(Format('Получено описаний ПВЗ: %d',[Length(PVZList.Items)]));
   Result:=true;
   end
except
on E : Exception do LogErrorMessage('T_Main.FillParentAreaList',E,[]);
end;
end;

(* ---  VCL ------------------------------------------------------------------------------------- *)
procedure UpdateScreenShot;
var
 bmp    : TBitmap;
 inf    : TBitmap;
 rctW   : TRect;
 rct    : Trect;
 str    : string;
 cnt    : integer;
 wdtTxt : integer;
 wdt    : integer;
 sda    : TStringDynArray;
begin
bmp:=TBitmap.Create;
inf:=TBitmap.Create;
try
if Clipboard.HasFormat(CF_PICTURE)
   then bmp.Assign(Clipboard)
   else Exit;
ClipBoard.Clear;
bmp.PixelFormat:=pf32bit;
with inf do
  begin
  PixelFormat:=pf24bit;
  Canvas.Font.name:='Tahoma';
  Canvas.Font.Size:=10;
  Canvas.Font.Color:=clRed;
  Canvas.Brush.Color:=clWhite;
  Canvas.Pen.Color:=clRed;
  str:=StringReplace(Format('%1:s%0:s%2:s%0:s%3:s%0:s%4:s%0:sверсия %5:s%0:s%6:s',[#10,AppParams.UserName, AppParams.WSName, DbServer, DBName, AppParams.verDate ,FormatDateTime('dd.mm.yyyy hh:nn:ss', Now)]),#32,#160,[rfReplaceAll]);
  sda:=SplitString(str,#10);
  wdtTxt:=10;
 if Canvas.TextFlags<>0 then ;
  for cnt:=0 to high(sda)
    do begin
    rct:=Bounds(0,0,1,20);
    DrawText(Canvas.Handle,PChar(sda[cnt]),Length(sda[cnt]),rct,DT_CALCRECT or DT_LEFT or DT_TOP);
    wdt:=rct.Right - rct.Left;
    //wdt:=Canvas.TextWidth(sda[cnt]);
    if wdt>wdtTxt
       then wdtTxt:=wdt;
    end;
  wdtTxt:=wdtTxt+8;

  rct:=Bounds(0,0,wdtTxt,Canvas.TextHeight('ЙQ|')*Length(sda)+4);
  //rct.Right:=GetTextWidthByHeight(str,Canvas.Font,rct.Bottom,true);   //StringReplace(str,#10,crlf,[rfReplaceAll])
  //rct.Right:=GetTextWidthByHeight(StringReplace(str,#10,#13,[rfReplaceAll]),Canvas.Font,rct.Bottom,true);
  Width:=rct.Right-rct.Left;
  Height:=rct.Bottom - rct.Top;
  canvas.Rectangle(rct);
  rct.Left:=rct.Left+10;
  SetTextColor(Canvas.Handle,ColorToRGB(clNavy));
  DrawTransparentText(Canvas.Handle,str,rct,DT_LEFT or DT_TOP(* or DT_WORDBREAK*));
  end;
GetWindowRect(MainWindow, rctW);
//TransparentBlt(bmp.Canvas.Handle,rctW.Left+ ((rctW.Right - rctW.left) - inf.Width) div 2,rctW.Top+2,inf.Width,inf.Height,inf.Canvas.Handle,0,0,inf.Width,inf.Height,clWhite);
BitBlt(bmp.Canvas.Handle,rctW.Left+ ((rctW.Right - rctW.left) - inf.Width) div 2,rctW.Top+2,inf.Width,inf.Height,inf.Canvas.Handle,0,0,SRCCOPY);
ClipBoard.Clear;
CopyBitmapToClipBoard(bmp);
finally
inf.Free;
bmp.Free;
end;
end;

procedure T_Main.AppIdle(Sender: TObject; var Done: Boolean);
begin
if GetAsyncKeyState(VK_SNAPSHOT) <> 0
   then UpdateScreenShot;
Done := True;
end;

procedure T_Main.AppMessage(var Msg: TMsg; var Handled: Boolean);
var
 ind  :integer;

//var
// cls : string;
// rct : Trect;
// pt  : TPoint;
// bc  : TButtonCategory;
begin
try
// -- вот это очень аккуратно раскомментаривать нужно ----------------------------------------------
//if (Msg.message = WM_MOUSEMOVE) and (GetForegroundWindow = Handle)
//   then begin
//   cls:=GetWindowClassName(Msg.hwnd);
//   if (cls='Internet Explorer_Server')
//      then begin
//      IHTMLDocument2(WB.ControlInterface.Document).parentWindow.focus;
//      if IES_Handle=0 then IES_Handle:=Msg.hwnd;
//      end
//     else
//   if (cls='Shell DocObject View')
//      then begin
//      if SDV_Handle=0 then SDV_Handle:=Msg.hwnd;
//      end;
//   end;
// -------------------------------------------------------------------------------------------------
if Assigned(TV_Tools_UsedAreas) and (Msg.hwnd = TV_Tools_UsedAreas.Handle)  // -- убирает артефакты при гор. скролинге
   then begin
   //if Msg.hwnd in [WM_NCMOUSEMOVE, WM_NCLBUTTONDOWN, WM_NCLBUTTONUP]
   if Msg.message in [WM_NCMOUSEMOVE, WM_NCLBUTTONDOWN, WM_NCLBUTTONUP]
      then TV_Tools_UsedAreas.Repaint
      else TV_Tools_UsedAreas_CheckScrollInfo;
   end
   else
//if (Msg.message in [WM_SIZE])
//   then
   begin
   ind:=SzPanPosList.GetIndex(Msg.hwnd);
   if ind>-1
      then begin
      if Msg.message in [(*WM_NCMOUSEMOVE,*) WM_NCLBUTTONDOWN, WM_NCLBUTTONUP]
         then SzPanPosList.UpdateStdRect(ind);
      end;
   end;



//
//
//if (Msg.Message=WM_LBUTTONDBLCLK)
//   then begin
//   GetWindowRect(Msg.hwnd,rct);
//   cls:=GetWindowClassName(Msg.hwnd);
//   if cls<>'TCategoryButtons'
//      then begin
//      inherited;
//      Exit;
//      end;
//   ReplyMessage(0);
//   //mouse_event(MOUSEEVENTF_LEFTDOWN,rct.Left+2,rct.Top+2,0,0);
//   //_sleep(1);
//   //mouse_event(MOUSEEVENTF_LEFTUP,rct.Left+2,rct.Top+2,0,0);
//   SendMessage(CatBtns_IntervalScheme.Handle,WM_LBUTTONUP,0,MakeLParam(10,10));
//   _sleep(1);
//
//   CatBtns_IntervalScheme.EndDrag(false);
//
//   //pt:=Point(Lo(Msg.lParam), Hi(Msg.lParam));
//   pt:=Msg.Pt;
//   Windows.ScreenToClient(Msg.hwnd, pt);
//   bc:=CatBtns_IntervalScheme.GetCategoryAt(pt.X, pt.Y);
//   if Assigned(bc)
//      then begin
//      Application.ProcessMessages;
//      bc.EndEdit(true);
//      SendMessage(Handle,APP_INTERVAL,0,0);
//      _sleep(10);
//      end;
//  CatBtns_IntervalScheme.Cursor:=crDefault;
//  Screen.Cursor:=crDefault;
//  mouse_event(MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE,0,0,0,0);
//  _sleep(1);
//  mouse_event(MOUSEEVENTF_LEFTUP or MOUSEEVENTF_ABSOLUTE,0,0,0,0);
//  _sleep(1);
//
////
////   for cnt:=0 to CatBtns_IntervalScheme.Categories.Count-1
////      do if CatBtns_IntervalScheme.Categories.Items[cnt].
////   _sleep(1);
////
//   end;

except
on E : Exception do LogErrorMessage('T_Main.AppMessage',E,[AboutObjectByHandle(Msg.hwnd),Msg.hwnd, Msg.Message]);
end;
end;


procedure T_Main.FormCreate(Sender: TObject);
var
 Intervals : TPairDateTimeList;
begin

//try
//CheckFloatPolygon(LL);
//except
//end;
//Application.Terminate;
//Halt;


try
{$IFDEF MO2}
ShowMessageInfo('');
{$ENDIF}
try
CallCheckVersionIE(9999);
except
end;
MainWindow:=Handle;
LoadSettings;
RefreshAreaList;

//UpdatePanel(Pan_Filter);
if not LoadHTMLPage(HTMLResourceName)
   then begin
   Application.Terminate;
   end;
TV_Area.Canvas.Font:=TV_Area.Font;
TS_Filter_Options.TabVisible:=false;(*ATTENTION*)
TV_Tools_UsedAreas.Font.Name:='Courier New';
TV_Tools_UsedAreas.Font.Size:=10;
TV_Tools_UsedAreas.Canvas.Font:=TV_Tools_UsedAreas.Font;

SetModeButtons;
SetCtrlButtons;

//
//(*ATTENTION*)
//if not GetFullData(EncodeDate(2014,07,24)(*DeliveryDate*),daMoscow(*DeliveryAgent*))
//   then begin
//
//   end;

ShowDeliveryControls(false);
ShowHideAreaXML(xsmHide);

DTP_Tools_UsedAreas_Start.DateTime:=Date;
DTP_Tools_UsedAreas_Finish.DateTime:=Date;
TV_Tools_UsedAreas.Canvas.Font:=TV_Tools_UsedAreas.Font;

DTP_Tools_DTP_Start.DateTime:=Date-1;
DTP_Tools_DTP_Finish.DateTime:=Date;
DTP_Tools_DTP_Finish.MaxDate:=Date;

DTP_Tools_AreaLog_Start.DateTime:=Date-7;
DTP_Tools_AreaLog_Finish.DateTime:=Date;
DTP_Tools_AreaLog_Finish.MaxDate:=Date;
///TS_AreaLog.TabVisible:=(AnsiUpperCase(AppParams.UserName) = 'S.KHOLIN')
///                     or(AnsiUpperCase(AppParams.UserName) = 'A.RAMODIN') ;
DTI_Create(Date,Date+SE_days.Value-1,Intervals.Items);
Application.OnIdle:=AppIdle;
Application.OnMessage:=AppMessage;
SzPanPosList.Fill(self);

SpB_Mode_PVZ.Visible:=AppParams.ParamExists('showpvz') or TRUE (* lf djn <KZNM!!!! *);
if not SpB_Mode_PVZ.Visible and needMapMode and (needAreaType=aiitPVZ)
   then needAreaType:=aiitArea;

TV_Area.Images:=AreaPicList.imageList;
ChBSelectShowedAreas(nil);
//SetCheckBoxSize(ChB_UsedNow);
//ChB_UsedNow.Hint:=
//      'Отображать зоны уровней административного деления (0,1,2)'
//+crlf+'и доставки (3,4) ,которые имеют действующее расписание (сегодня и(или) позже)';



except
on E : Exception do LogErrorMessage('T_Main.FormCreate',E,[]);
end;
end;


procedure T_Main.FormActivate(Sender: TObject);
begin
try
if SzPan_Deliverys.Visible
   then begin
   DrGr_CarsList.RowCount:=1+Length(CarList.Items)+integer(Length(CarList.Items)=0);
   DrGr_CarsList.Repaint;

   end;
except
on E : Exception do LogErrorMessage('T_Main.FormActivate',E,[]);
end;
end;


procedure T_Main.FormShow(Sender: TObject);
var
 res    : TIntegerDynArray;
 resTxt : string;
begin
try
Application.ProcessMessages;
if needMapMode
   then begin
   Application.ProcessMessages;
   case needAreaType of
   aiitArea : ShowWorkPanels(SpB_Mode_Map);
   aiitPVZ  : ShowWorkPanels(SpB_Mode_PVZ);
   end;
   Application.ProcessMessages;
   if Length(FullAreaList.Items)>0
      then begin
      CheckIntersectAreas(res,resTxt);
      if Length(res)>0
         then AreaIntersectMessage(resTxt, '');
      end;

   end;
Application.ProcessMessages;
if needDeliveryMode
  then begin
  ShowWorkPanels(SpB_Mode_Delivery);
  Application.ProcessMessages;
  SpB_DeliveryRefreshClick(SpB_DeliveryRefresh);
  end;
Application.ProcessMessages;
if needToolsMode
  then begin
  ShowWorkPanels(SpB_Mode_Tools);
  Application.ProcessMessages;
  end;
if needTwoHoursMode
  then begin
  ShowWorkPanels(SpB_Mode_TwoHours);
  Application.ProcessMessages;
  end;
except
on E : Exception do LogErrorMessage('T_Main.FormShow',E,[]);
end;
end;



procedure T_Main.FormClick(Sender: TObject);
begin
try
ShowLog(AppParams.CFGUserFileName);
except
on E : Exception do LogErrorMessage('T_Main.FormClick',E,[]);
end;
end;


procedure T_Main.FormDblClick(Sender: TObject);
begin
try
//
except
on E : Exception do LogErrorMessage('T_Main.FormDblClick',E,[]);
end;
end;



procedure T_Main.FormMouseLeave(Sender: TObject);
begin
try
//
except
on E : Exception do LogErrorMessage('T_Main.FormMouseLeave',E,[]);
end;
end;


procedure T_Main.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
try
if (Key=VK_X) and (ssCtrl in Shift) and (ssAlt In Shift)
   then ShowHideAreaXML;
except
on E : Exception do LogErrorMessage('T_Main.FormKeyUp',E,[]);
end;
end;

procedure T_Main.FormPaint(Sender: TObject);
//const
// txt = 'работа со схемой' ;
//var
// dltY : integer;
// dc   : hDC;
// pn   : hPen;
// br   : hBrush;
// rct  : TRect;
begin
try
//if SzPan_IntervalSchemeEx.Visible
//   then begin
// -- рамка с надписью вокруг кнопок редактирования схемы --
//   dltY:=GetSystemMetrics(SM_CYFRAME);
//   pn:=CreatePen(PS_SOLID,1,clGray);
//   br:=CreateSolidBrush(ColorToRGB(SzPan_IntervalSchemeEx.Color));
//   dc:=GetWindowDC(SzPan_IntervalSchemeEx.Handle);
//   try
//   SelectObject(dc,pn);
//   SelectObject(dc,br);
//   SelectObject(dc,SzPan_IntervalSchemeEx.Font.Handle);
//   MoveToEx(dc, SpB_AddInterval.Left+dltY-4, SpB_AddInterval.Top-2,nil);
//   LineTo(dc,   SpB_LoadInterval.Left+SpB_LoadInterval.Width+dltY+2, SpB_LoadInterval.Top-2);
//   LineTo(dc,   SpB_LoadInterval.Left+SpB_LoadInterval.Width+dltY+2, SpB_LoadInterval.Top+SpB_LoadInterval.Height+dltY);
//   LineTo(dc,   SpB_AddInterval.Left+dltY-4, SpB_AddInterval.Top+SpB_AddInterval.Height+dltY);
//   LineTo(dc,   SpB_AddInterval.Left+dltY-4, SpB_AddInterval.Top-2);
//   rct:=Rect(0,0,1,0);
//   DrawText(dc,txt,length(txt),rct,DT_LEFT_CALC);
//   rct.Bottom:=rct.Bottom+4;
//   offsetrect(rct
//           , SpB_AddInterval.Left+(SpB_LoadInterval.Left-SpB_AddInterval.Left+SpB_AddInterval.Width - (rct.Right-rct.Left)) div 2(*  - (rct.Right-rct.Left)) div 2*)
//           , SpB_AddInterval.Top-dltY);
//   rct.Left:=rct.Left-4;
//   rct.Right:=rct.Right+4;
//   Rectangle(dc,rct.Left-1,rct.Top-1,rct.Right+1, rct.Bottom+2);
//   SetBkColor(dc,ColorToRGB(SzPan_IntervalSchemeEx.Color));
//   DrawText(dc,txt,length(txt),rct,DT_CENTER_ALIGN);
//   finally
//   ReleaseDC(SzPan_IntervalSchemeEx.Handle,dc);
//   DeleteObject(pn);
//   DeleteObject(br);
//   end;
//   end;
except
on E : Exception do LogErrorMessage('T_Main.FormPaint',E,[]);
end;
end;

procedure T_Main.FormResize(Sender: TObject);
begin
try
//
except
on E : Exception do LogErrorMessage('T_Main.FormResize',E,[]);
end;
end;


procedure T_Main.FormDeactivate(Sender: TObject);
begin
try
//
except
on E : Exception do LogErrorMessage('T_Main.FormDeactivate',E,[]);
end;
end;

procedure T_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
try
//
except
on E : Exception do LogErrorMessage('T_Main.FormCloseQuery',E,[]);
end;
end;


procedure T_Main.FormClose(Sender: TObject; var Action: TCloseAction);
var
 errFile : string;
begin
try
MainWindow:=0;
SzPanPosList.Restore;
SzPanPosList.Clear;

Application.onMessage:=nil;
Application.onIdle:=nil;
WB.Navigate('about:blank');
_sleep(100);
if CanDelHTMLOnExit and (FileExists(HTMLFileName))
   then ShellDeleteFile(Handle,HTMLFileName,true,false)
   else begin
   errFile:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'ErrHTML\';
   if not ForceDirectories(errFile) then errFile:=SetTailBackSlash(GetTempFolder);
   errFile:=errFile+ExtractFileName(HTMLFilename);
   FnCommon.ShellMoveCopyFileNT(false,HTMLFilename,errFile,errFile,false,false);
   end;
AccidentItem.Clear;
AccidentList.Clear;

SaveSettings;
except
on E : Exception do LogErrorMessage('T_Main.FormClose',E,[]);
end;
end;



(* --- ACTIONS ------------------------------------------------------------------------- *)
procedure T_Main.ShowWorkPanels(Sender: TObject);
var
 spb     : TSpeedButton;
 aiitOld ,
 aiitNew : TAreaIntervalIdType;
// ind     : integer;
begin
if Sender.InheritsFrom(TSpeedButton)
   then spb := Sender as TSpeedButton
   else Exit;
if spb=SpB_Mode_Delivery
   then begin
   SzPan_Deliverys.SendToBack;
   SzPan_Deliverys.Visible:=not SzPan_Deliverys.Visible;
   if SzPan_Deliverys.Visible
      then SzPan_Deliverys.BringToFront
      else SzPan_Deliverys.SendToBack;
   SetDeliveryBtn(sbDeliveryMode.IsEnabled, SzPan_Deliverys.Visible);
   needDeliveryMode:= SzPan_Deliverys.Visible;
   if not needDeliveryMode and SzPanPosList.IsOut(SzPan_Deliverys)
      then SzPanPosList.SetIn(SzPan_Deliverys);
   end
   else
if (spb=SpB_Mode_Map) or
   (spb=SpB_Mode_PVZ)
   then begin
   aiitOld:=TAreaIntervalIdType(GB_Intervals.Tag);
   if (spb=SpB_Mode_Map)
       then begin
       aiitNew:=aiitArea;
       SzPan_Area.Caption:='Просмотр / Редактирование описания области';
       end
       else
   if (spb=SpB_Mode_PVZ)
       then begin
       aiitNew:=aiitPVZ;
       SzPan_Area.Caption:='Просмотр описания ПВЗ';
       end
       else Exit;
   GB_Intervals.Tag:=integer(aiitNew);
   SzPan_Area.SendToBack;
   if aiitOld=aiitNew
      then SzPan_Area.Visible:=not SzPan_Area.Visible
      else SzPan_Area.Visible:=True;
   RefreshAreaIntervalList(0,aiitNew);
   if not SzPan_Area.Visible
      then begin
      if Act_Filter.Checked
         then Act_FilterExecute(Act_Filter)
         else SzPan_Filter.Hide;
      SzPan_Area.SendToBack;
      SzPan_Filter.SendToBack;
      end
      else begin
      case aiitNew of
      aiitArea :
         begin
         if RefreshAreaList
            then ;
         SzPan_Area.Update;
         SzPan_Area.Repaint;
          _sleep(10);
         SzPan_Area.BringToFront;
         end;
      aiitPVZ :
         begin
         if RefreshPVZList
            then ;
         SzPan_Area.Update;
         SzPan_Area.Repaint;
          _sleep(10);
         SzPan_Area.BringToFront;
         //SetPVZBtn(sbPVZMode.IsEnabled, SzPan_Area.Visible and (aiitNew=aiitPVZ));
         end
      end;
      end;
   SetAreaControls;
   SetMapBtn(sbMapMode.IsEnabled, SzPan_Area.Visible and (aiitNew=aiitArea));
   SetPVZBtn(sbPVZMode.IsEnabled, SzPan_Area.Visible and (aiitNew=aiitPVZ));
   needMapMode  := SzPan_Area.Visible ;
   needAreaType := TAreaIntervalIdType(GB_Intervals.Tag) ;
   if not needMapMode and SzPanPosList.IsOut(SzPan_Area)
      then SzPanPosList.SetIn(SzPan_Area);
   end
   else
if spb=SpB_Mode_Tools
   then begin
   SzPan_Tools.SendToBack;
   SzPan_Tools.Visible:=not SzPan_Tools.Visible;
   if SzPan_Tools.Visible
      then SzPan_Tools.BringToFront
      else SzPan_Tools.SendToBack;
   SetToolsBtn(sbToolsMode.IsEnabled, SzPan_Tools.Visible);
   needToolsMode:= SzPan_Tools.Visible;
    if not needToolsMode and (SzPanPosList.IsOut(SzPan_Tools))
      then SzPanPosList.SetIn(SzPan_Tools);
   end
   else
if spb=SpB_Mode_TwoHours
   then begin
   SzPan_TwoHours.SendToBack;
   SzPan_TwoHours.Visible:=not SzPan_TwoHours.Visible;
   if SzPan_TwoHours.Visible
      then begin
      FillFilter(CBTwoHoursArea);
      SzPan_TwoHours.BringToFront;
      end
      else SzPan_TwoHours.SendToBack;
   SetTwoHoursBtn(sbTwoHoursMode.IsEnabled, SzPan_TwoHours.Visible);
   needTwoHoursMode:= SzPan_TwoHours.Visible;
   if not needTwoHoursMode and (SzPanPosList.IsOut(SzPan_TwoHours))
      then SzPanPosList.SetIn(SzPan_TwoHours);
   end
   else
   ;
end;


procedure T_Main.SetAreaControls;
var
 GrB : TGroupBox;
 cnt : integer;
begin
for cnt:=0 to SzPan_Area.ControlCount-1
  do if (SzPan_Area.Controls[cnt] is TGroupBox) and
        (SzPan_Area.Controls[cnt]<>GB_Intervals)
        then  (SzPan_Area.Controls[cnt] as TGroupBox).Hide;
GrB:=nil;
case TAreaIntervalIdType(GB_Intervals.Tag) of
aiitArea : GrB:=GB_Area;
aiitPVZ  : GrB:=GB_PVZ;
end;
if not Assigned(GrB) then Exit;
with GrB do
  begin
  Left:=GB_Intervals.Left;
  Top:=GetSystemMetrics(SM_CYBORDER)+Canvas.TextHeight('QЙ')+2;
  Width:=GB_Intervals.Width;
  Height:=GB_Intervals.Top - Top;
  Color:=SzPan_Area.Color;
  GrB.Show;
  GrB.SendToBack;
  end;
end;

procedure T_Main.Act_СloseExecute(Sender: TObject);
begin
Close;
end;

procedure T_Main.Act_RefreshExecute(Sender: TObject);
begin
try
try
if ExistsUnsaved
  then case MessageBox(Handle,'Существуют несохраненные описания областей. Обновить области?','Предупреждение',MB_ICONQUESTION + MB_YESNOCANCEL) of
       IDYES    : FullAreaList.SaveIntoDB;
       IDNO     : ;
       IDCANCEL : Exit;
       end;
FillAreaInfo('');
//SpB_IntervalList.Enabled:=false;
//SetCtrlButtons;
if not ClearMap
   then begin
   end;
if RefreshAreaList
 then ShowSelectedAreas;   (*DELETED AREAS*)
finally
end;
except
on E : Exception do LogErrorMessage('T_Main.Act_RefreshExecute',E,[]);
end;
end;

procedure T_Main.Act_FilterExecute(Sender: TObject);
var
 needOutForm : boolean;
begin
Act_Filter.Checked:=not Act_Filter.Checked;
SzPan_Filter.Visible:=Act_Filter.Checked;
needOutForm:=SzPan_Filter.Tag=1;
SzPan_Filter.Tag:=0;
if SzPan_Filter.Parent.InheritsFrom(TForm)
   then begin
   if Assigned(SzPan_Filter.Parent) and (SzPan_Filter.Parent<>Application.MainForm) and not SzPan_Filter.Visible
      then begin
      SavePosition((SzPan_Filter.Parent as TForm),AppParams.CFGUserFileName);
      (SzPan_Filter.Parent as TForm).Close;
      SzPan_Filter.Tag:=1;
      end;
   end;
if Act_Filter.Checked
   then begin
   SetGlyph(SpB_Map_Filter,IL_Paint, [ptpFilter, ptpCheckSign]);
   end
   else begin
   SetGlyph(SpB_Map_Filter,IL_Paint, [ptpFilter, ptpUnCheckSign]);
   end;
SzPan_Filter.BringToFront;
if SzPan_Filter.Visible and (Length(SelectedAreas)>0)
   then PC_FilterChange(PC_Filter.ActivePage);
if SzPan_Filter.Visible and ((SzPanPosList.IsOut(SzPan_Filter)) or needOutForm)
   then SzPanPosList.SetOut(SzPan_Filter);
end;

procedure T_Main.Act_LogShowExecute(Sender: TObject);
begin
ShowLog(AppParams.CFGUserFileName);
end;


procedure T_Main.Act_ShowFilteredExecute(Sender: TObject);
begin
ShowSelectedAreas;
end;


procedure T_Main.NCloseClick(Sender: TObject);
begin
Close;
end;

procedure T_Main.NMap_HideAreasClick(Sender: TObject);
begin
try
if viaJSObjects
   then ExecuteScript(WB, 'SetArrayOfPolygonNew([])')
   else ExecuteScript(WB, 'SetArrayOfPolygon("")')
except
  on E : Exception do LogErrorMessage('T_Main.NMap_HideAreasClick',E,[]);
end
end;

procedure T_Main.N_IntervalList_EditOneClick(Sender: TObject);
begin

end;

(*************************************************************************************)



procedure T_Main.DrGrEnter(Sender: TObject);
var
 ctrl : TWinControl;
begin
if not (Sender is TDrawGrid) then Exit;
ctrl:=(Sender as TWinControl);
while not (ctrl is TSizedPanel)
 do ctrl:=ctrl.Parent;
if not Assigned(ctrl) then Exit;
ActiveControl:=ctrl;
(Sender as TDrawGrid).SetFocus;
end;
// -- это работает через заголовок окна (document.title="TITLE_NEW")
//procedure T_Main.WBTitleChange(ASender: TObject; const Text: WideString);
//var
// title : string;
// value : string;
//begin
//title:=Text;
//value:='';
//if (Pos('ae_',title)=0) and
//   (Pos('about',title)=0)
//   then begin
//   WB.OnTitleChange:=nil;
//   try
//   value:=GetIdValue(WB,title) ;
//   finally
//   WB.OnTitleChange:=WBTitleChange;
//   end;
//   end;
//if value<>''
//   then Memo1.Text:=value;
//end;

{$MESSAGE 'Прием данных от браузера здесь'}
procedure T_Main.WBBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
var
 spl   : TStringDynArray;
 id    : string;
 value : string;
 ps    : integer;
begin
id:='';
value:='';
spl:=SplitString(URL,'#');
if (Length(spl)>=2) and (spl[1]<>'')
   then begin
   ps:=Pos('|',spl[1]);
   if ps>0
      then begin
      id:=Copy(spl[1],1,ps-1);
      value:=Copy(spl[1],ps+1,Length(spl[1]))
      end
      else begin
      id:=AnsiUpperCase(spl[1]);
      value:=GetIdValue(WB,spl[1]) ;
      Cancel:=true;
      end;
   end;
if id='' then Exit;
if value<>''
  then begin
  if id='AREAXML'
     then begin
     FillAreaInfo(value);
     PanAreaDopFilter.Hide;
     WebBrowserFocus(Wb);
     end
     else
  if id='CLICKCOORD'
     then begin
     FillLastClickedCoord(value);
     PanAreaDopFilter.Hide;
     WebBrowserFocus(Wb);
     end
     else
  if id='ERROR'
     then LogErrorMessage('MessageFromHTML: '+StringReplace(value,'%20',' ',[rfReplaceAll]),[])
     else
  if id='INFO'
     then begin
     if value='READY' then LogInfoMessage('Карта загружена');
     end
     else
  if id='RESULT'
     then ProcessingId_Result(value)
     else LogInfoMessage(Format('Неизвестный идентификатор [%s]',[id]))
  end;
end;

procedure T_Main.WBClick(Sender: TObject);
begin
if TWinControl(WB).Visible
   then TWinControl(WB).SetFocus;
end;


procedure T_Main.WBEnter(Sender: TObject);
begin
WBClick(Sender);
end;

procedure T_Main.IE_Procedures(Sender: TObject);
begin
if Sender=NMap_Refresh then IE_Refresh else
if Sender=NMap_PrintPreview then IE_PrintPreview  else
end;


(****************************************************************************)


(*** FILTER FUNCTIONS ***************************************************************)
procedure T_Main.BB_Filter_CloseClick(Sender: TObject);
begin
if Act_Filter.Checked
   then Act_FilterExecute(Act_Filter)
   else begin
   if SzPanPosList.IsOut(SzPan_Filter) then SzPanPosList.SetIn(SzPan_Filter);
   SzPan_Filter.Hide;
   end;
end;





procedure T_Main.ChLB_Areas_NamesClickCheck(Sender: TObject);
var
 cnt : integer;
 ind : integer;
 tmp : TIntegerDynArray;
begin
for cnt:=0 to ChLB_Areas_Names.Items.Count-1
  do if ChLB_Areas_Names.Checked[cnt]
        then begin
        ind:=Length(tmp);
        SetLength(tmp,ind+1);
        tmp[ind]:=PAreaItem(ChLB_Areas_Names.Items.Objects[cnt])^.aID;
        end;
FillSelectedAreas(tmp);
end;

procedure T_Main.ChLB_Areas_NamesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 _bmp   : TBitmap;
// szBMP  : integer;
 str    : string;
 rct    : TRect;
 sel    : boolean;
begin
str:=ChLB_Areas_Names.Items[Index];
_bmp:=TBitmap.Create;
try
with PAreaItem(ChLB_Areas_Names.Items.Objects[Index])^
  do AreaPicList.DrawBitmap(aRGBFill, aRGBLine, _bmp);
//with _bmp do
//  begin
//  szBMP:=Rect.Bottom-Rect.Top;
//  Height:=szBMP;
//  Width:=szBMP;
//  Canvas.Brush.Color:=LightColor(HTMLRGBtoColor(PAreaItem(ChLB_Areas_Names.Items.Objects[Index])^.aRGBFill),50);
//  Canvas.Pen.Color:=HTMLRGBtoColor(PAreaItem(ChLB_Areas_Names.Items.Objects[Index])^.aRGBLine);
//  Canvas.Rectangle(1,1,Width-2,Height-2);
//  end;
with ChLB_Areas_Names.Canvas do
  begin
  sel:=(odSelected in State) or (odFocused in State);
  Font.Color:=FontColor[sel];
  Brush.Color:=BrushColor[sel];
  FillRect(Rect);
  System.Move(Rect, rct, SizeOf(TRect));
  rct.Left:=rct.Left + _bmp.Width + 2;
  Draw(Rect.Left, Rect.Top, _bmp);
  if AnsiPos(Ed_Filter_Find.Hint,AnsiUpperCase(str))<>0
     then Font.Style:=[fsBold]
     else Font.Style:=[];
  DrawTransparentText(Handle,str,rct,DT_LEFT_ALIGN);
  end;
finally
_bmp.Free;
end;
end;

procedure T_Main.Ed_Filter_FindChange(Sender: TObject);
begin
Ed_Filter_Find.Hint:= AnsiUpperCase(Ed_Filter_Find.Text);
ChLB_Areas_Names.Repaint;
TV_Area.Repaint;
end;



procedure T_Main.PC_FilterChanging(Sender: TObject; var AllowChange: Boolean);
begin
// -- создаем отобранные области по текущему контролу
//if PC_Filter.ActivePage = TS_Filter_Names then ChLB_Areas_NamesClickCheck(ChLB_Areas_Names) else
//if (PC_Filter.ActivePage = TS_Filter_Parents) or
//   (PC_Filter.ActivePage = TS_Filter_Levels)
//   then TV_AreaClick(nil)
//   else
//
end;



procedure T_Main.PC_ToolsChange(Sender: TObject);
var
 TS : TTabSheet;
begin
if (PC_Tools.ActivePage=TS_AreaLog) or
   (PC_Tools.ActivePage=TS_AreaTimeLog)
   then begin
   TS:=PC_Tools.ActivePage;
   Lab_AreaLog_Days.Parent:=TS;
   DTP_Tools_AreaLog_Start.Parent:=TS;
   DTP_Tools_AreaLog_Finish.Parent:=TS;
   SpB_Tools_AreaLog_Load.Parent:=TS;
   Lab_AreaLog_Find.Parent:=TS;
   Ed_Tools_AreaLog_Search.Parent:=TS;
   SpB_Tools_AreaLog_Excel.Parent:=TS;
   end;
end;

procedure T_Main.PC_FilterChange(Sender: TObject);
begin
if PC_Filter.ActivePage = TS_Filter_Names
   then begin
   Check_ChLB_Areas_Names ;
   end
   else
if (PC_Filter.ActivePage = TS_Filter_Parents) or
   (PC_Filter.ActivePage = TS_Filter_Levels)
   then begin
   ChB_CheckChilds.Parent:=PC_Filter.ActivePage;
   TV_Area.Parent:=PC_Filter.ActivePage;
   FillFilter(TV_Area);
   Check_TV_Area;
   end
   else ;
end;

procedure T_Main.TV_AreaClick(Sender: TObject);
var
 X,Y : integer;
  procedure CheckChildNodes(const ParentNode : TTreeNode; DoCheck : boolean);
  var
   cnt     : integer;
   aNode   : TTreeNode;
   HitTest : THitTests;
  begin
  try
  HitTest:=TV_Area.GetHitTestInfoAt(X,Y);
  if (htOnStateIcon in HitTest) then ParentNode.Expand(False);
  aNode:=ParentNode.getFirstChild;
  if not Assigned(aNode) then Exit;
  for cnt:=0 to ParentNode.Count-1
    do begin
    if cnt>0 then aNode:=ParentNode.GetNextChild(aNode);
    if DoCheck
       then aNode.StateIndex:=ptpCheckedClr
       else aNode.StateIndex:=ptpUncheckedClr;
    CheckChildNodes(aNode,DoCheck);
    end;
  except
  on E : Exception do LogErrorMessage('T_Main.TV_AreaClick.CheckChildNodes',E,[]);
  end;
  end;
var
 Node       : TTreeNode;
 Rct        : TRect;
 HitTest    : THitTests;
 pt         : TPoint;
 tmp        : TIntegerDynArray;
 cnt        : integer;
 ind        : integer;
begin
try
Windows.GetCursorPos(pt);
//Windows.ScreenToClient(TV_Area.Handle, pt);
pt:=TV_Area.ScreenToClient(pt);
X:=pt.X; Y:=pt.Y;
if Assigned(Sender) and (Sender.InheritsFrom(TTreeView))
   then Node:=(Sender as TTreeView).GetNodeAt(X,Y)
   else Node:=nil;
if Assigned(Node)
   then begin
   Rct:=Node.DisplayRect(True);
   Rct.Left:=Rct.Left-34;
   Rct.Right:=Rct.Left+14;
   if PtInRect(Rct,Point(X,Y))
      then if (Node.StateIndex<>0) and (Node.StateIndex<>ptpDisabled)
              then if Node.StateIndex<>ptpUncheckedClr//ptpCheckedClr
                      then Node.StateIndex:=ptpUncheckedClr
                      else Node.StateIndex:=ptpCheckedClr;
   //if (Node.Level>0) and (Node.StateIndex=ptpUncheckedClr) and Assigned(Node.Parent) then Node.Parent.StateIndex:=ptpUncheckedClr;
   HitTest:=TV_Area.GetHitTestInfoAt(X,Y);
   if ChB_CheckChilds.Checked and assigned(Node) and (htOnStateIcon in HitTest) then CheckChildNodes(Node,Node.StateIndex=ptpCheckedClr);
//   if Assigned(Node.getFirstChild)
//      then StateNode(Node)
//      else
//    if Assigned(Node.Parent)
//      then StateNode(Node.Parent)
//      else
   if Node.Parent<>nil
      then begin
      Node:=Node.Parent;
      Node.StateIndex:=StateNode(Node)
      end;
   end;

if (PC_Filter.ActivePage = TS_Filter_Parents)
    then begin
    for cnt:=0 to TV_Area.Items.Count-1
      do if TV_Area.Items[cnt].StateIndex=ptpCheckedClr
            then begin
            ind:=Length(tmp);
            SetLength(tmp, ind+1);
            tmp[ind]:=PAreaItem(TV_Area.Items[cnt].Data)^.aID;
            end;
    end
    else
if (PC_Filter.ActivePage = TS_Filter_Levels)
    then begin
    for cnt:=0 to TV_Area.Items.Count-1
      do if (TV_Area.Items[cnt].Level>0) and (TV_Area.Items[cnt].StateIndex=ptpCheckedClr)
            then begin
            ind:=Length(tmp);
            SetLength(tmp, ind+1);
            tmp[ind]:=PAreaItem(TV_Area.Items[cnt].Data)^.aID;
            end;
    end;
FillSelectedAreas(tmp);
except
on E : Exception do LogErrorMessage('T_Main.TV_AreaClick',E,[]);
end;
end;





procedure T_Main.TV_AreaAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages,
  DefaultDraw: Boolean);
var
 rct : TRect;
 sel : boolean;
begin
//DefaultDraw:=false;
try
with TV_Area.Canvas do
   begin
   rct:=Node.DisplayRect(true);
   sel:=(cdsSelected in State) or (cdsFocused in State);
   Font.Color:=FontColor[sel];
   Brush.Color:=BrushColor[sel];
   FillRect(rct);
   if AnsiPos(Ed_Filter_Find.Hint,AnsiUpperCase(Node.Text))<>0
      then Font.Style:=[fsBold]
      else Font.Style:=[];
   DrawTransparentText(Handle,Node.Text,rct,DT_LEFT_ALIGN);
   end;
finally
//DefaultDraw:=true;
end;
end;

procedure T_Main.Filter_SelBtns_Click(Sender: TObject);
type
  TSelMode = (smNull, smAll, smNone, smRevers);

//  function InFilter(index : integer) : boolean;
//  begin
//  Agent
//  Result:=
//     PAreaItem(ChLB_Areas_Names.Items.Objects[index])^.aID;
//  end;


var
 SelMode : TSelMode;
 cnt     : integer;
 srch    : string;
begin
SelMode:=smNull;
try
if Sender=SpB_ChkAll then SelMode:=smAll else
if Sender=SpB_UnChkAll then SelMode:=smNone else
if Sender=SpB_RevAll then SelMode:=smRevers;
srch:=Ed_Filter_Find.Hint;
if PC_Filter.ActivePage = TS_Filter_Names
   then begin
   ChLB_Areas_Names.Items.BeginUpdate;
   try
   if srch=''
      then begin
      case SelMode of
      smAll    : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do ChLB_Areas_Names.Checked[cnt]:=true;
      smNone   : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do ChLB_Areas_Names.Checked[cnt]:=false;
      smRevers : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do ChLB_Areas_Names.Checked[cnt]:=not ChLB_Areas_Names.Checked[cnt];
      end;
      end
      else begin
      case SelMode of
      smAll    : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(ChLB_Areas_Names.Items[cnt]))<>0 then ChLB_Areas_Names.Checked[cnt]:=true;
      smNone   : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(ChLB_Areas_Names.Items[cnt]))<>0 then ChLB_Areas_Names.Checked[cnt]:=false;
      smRevers : for cnt:=0 to ChLB_Areas_Names.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(ChLB_Areas_Names.Items[cnt]))<>0 then ChLB_Areas_Names.Checked[cnt]:=not ChLB_Areas_Names.Checked[cnt];
      end;
      end;
   finally
   ChLB_Areas_Names.Items.EndUpdate;
   end;
   ChLB_Areas_NamesClickCheck(ChLB_Areas_Names);
   end
   else
if (PC_Filter.ActivePage = TS_Filter_Parents) or
   (PC_Filter.ActivePage = TS_Filter_Levels)
   then begin
   TV_Area.Items.BeginUpdate;
   try
   if srch=''
      then begin
      case SelMode of
      smAll    : for cnt:=0 to TV_Area.Items.Count-1 do TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
      smNone   : for cnt:=0 to TV_Area.Items.Count-1 do TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr;
      smRevers : for cnt:=0 to TV_Area.Items.Count-1 do if TV_Area.Items[cnt].StateIndex=ptpCheckedClr then TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr else TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
      end;
      end
      else begin
      case SelMode of
      smAll    : for cnt:=0 to TV_Area.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(TV_Area.Items[cnt].Text))<>0 then TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
      smNone   : for cnt:=0 to TV_Area.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(TV_Area.Items[cnt].Text))<>0 then TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr;
      smRevers : for cnt:=0 to TV_Area.Items.Count-1 do if AnsiPos(srch, AnsiUpperCase(TV_Area.Items[cnt].Text))<>0 then if TV_Area.Items[cnt].StateIndex=ptpCheckedClr then TV_Area.Items[cnt].StateIndex:=ptpUncheckedClr else TV_Area.Items[cnt].StateIndex:=ptpCheckedClr;
      end;
      end;
   finally
   TV_Area.Items.EndUpdate;
   end;
   TV_AreaClick(nil);
   end
   else
if PC_Filter.ActivePage = TS_Filter_Options
   then begin
   case SelMode of
   smAll    : ;
   smNone   : ;
   smRevers : ;
   end;
   end
   else

except
on E : Exception do LogErrorMessage('T_Main.Filter_SelBtns_Click',E,[AboutObject(Sender)]);
end;
end;


procedure T_Main.SetColor(Sender: TObject);
var
 pan     : TPanel;
 CD      : TColorDialog;
 indProp : integer;
begin
if Sender.InheritsFrom(TPanel)
   then pan:=Sender as TPanel
   else Exit;
CD:=TColorDialog.Create(nil);
try
CD.Color:=pan.Color;
if CD.Execute(Handle)
   then pan.Color:=CD.Color;
finally
CD.Free;
end;
if Assigned(pan)
   then begin
   if pan = Pan_RGBLine
      then indProp:= ipLineColor
      else indProp:=ipFillColor;
   ExecuteScript(WB, Format('ChangeProps_BySessionID("%s", %d, "%s")',[Area.aSessionID,indProp,ColorToHTMLColor(pan.Color)]));
   end;

end;




procedure T_Main.SzPan_AreaResize(Sender: TObject);
var
 cnt : integer;
begin
for cnt:=0 to SzPan_Area.ControlCount-1
  do begin
    with SzPan_Area.Controls[cnt]
      do begin
      if InheritsFrom(TCustomPanel) or
         InheritsFrom(TCustomComboBox) or
         InheritsFrom(TCustomEdit) or
         InheritsFrom(TCustomGroupBox)
         then Width:=parent.ClientWidth-Left-4;
     if SzPan_Area.Controls[cnt] = CB_AreaParent
        then Width:=Width - SpB_AreaParent_Clear.Width;
      end;
  end;
//BB_Area_Close.Left:=BB_Area_Close.parent.ClientWidth-BB_Area_Close.Width-4;//-GetSystemMetrics(SM_CXFRAME);
with BB_Area_Close do
  begin
  Left:=(GB_Area.Left+GB_Area.Width)-BB_Area_Close.Width;
  Top:=(GB_Area.Top);
  end;

end;

procedure T_Main.ShowIntervalEditor(Sender: TObject);
var
 ind    : integer;
 dbID   : integer;
 Start  : TDateTime;
 Finish : TDateTime;
 resind : integer;
begin
if (CurObject.idType=aiitArea) and (Length(Area.LatLng) < 3)
   then Exit;
dbID:=0;
Start  := Date+daysNoEditInterval + 1 + EncodeTime(defHourbegin,0,0,0);
Finish := Date+daysNoEditInterval + 1 + EncodeTime(defHourEnd,0,0,0);
resind := 1;
ind:=DrGr_AreaIntervalList.Row-1;
if (ind>=Low(AreaIntervalList.Items)) and (ind<=High(AreaIntervalList.Items))
   then begin
   with AreaIntervalList.Items[ind] do
      begin
      (**)//Start  := aiDate+EncodeTime(word(aiBegin),0,0,0);
      (**)//Finish := aiDate+EncodeTime(word(aiEnd),0,0,0);
      dbID   := aiID;
      //Start  := aiDate+MinutesToDateTime(aiBegin*60) ;
      //Finish := aiDate+MinutesToDateTime(aiEnd*60);
      //resind:=integer(aiActive);
      Start  := RoundTo(aiStart,dtRnd) ;
      Finish := RoundTo(aiStart + aiLen,dtRnd);
      resind:=1;
      end;
   end;
if Trunc(Start)<=Date+daysNoEditInterval
   then begin
   Beep;
   ShowMessageInfo(Format('Допускается редактирование интервала начиная с %s(включительно).'+crlf+'Данное ограничение установлено функционалом подтверждения доставки.',[FormatDateTime('dd.mm.yyyy',Date+daysNoEditInterval+1)]), 'К сведению');
   Exit;
   end;
///Finish:=Finish+1;
CallInputDateTimeInterval(dbID,DateTime(Trunc(Start)),Start, Finish, resind=1);
end;


procedure T_Main.DrGr_AreaIntervalListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  rct    : TRect;
  ind    : integer;
//  alg    : integer;
  str    : string;
  strDop : string;
  sel    : boolean;
  tdt    : TDate;
  dt     : TDate;
  actInd : integer;
  dw     : integer;
  sz     : TSize;
const
  //Titles: array[0 .. 2] of string =('Дата', 'Интервал', '' );
  Titles: array[0 .. 1] of string =('Начало', 'Окончание' );
begin
try
actInd:=ptpDisabled;
tdt:=Date+daysNoEditInterval+1;
///dt:=100000;
///sel:=true;
///ind:=-1;
str := '';
dw:=0;
strDop:='';
//rct := Classes.Rect(Rect.left + 2, Rect.Top + 1, Rect.Right - 2, Rect.Bottom - 1);
rct := Classes.Rect(Rect.left + 2, Rect.Top + 4, Rect.Right - 2, Rect.Bottom);
//alg := DT_LEFT_ALIGN;
try
case ARow of
  0: str := Titles[ACol];
  else begin
  ind := ARow - 1;
  sel:=(gdSelected in State)or(gdFocused in State);
  with DrGr_AreaIntervalList.Canvas do
    begin
    Font.Color := FontColor[sel];
    Brush.Color := BrushColor[sel];
    end;
   if(ind < Low(AreaIntervalList.Items))or(ind > High(AreaIntervalList.Items))
      then begin
      ///ind:=-1;
      exit;
      end;
   dt:=AreaIntervalList.Items[ind].aiStart;
   with AreaIntervalList.Items[ind] do
     case ACol of
     0 : begin
         str := FormatDateTime('dd.mm.yyyy hh:nn',aiStart);
         dw:=DayOfWeekRus(aiStart);
         strDop:=dwShort[dw];
         end;
     1 : begin
         str := FormatDateTime('dd.mm.yyyy hh:nn',aiStart+aiLen);
         dw:=DayOfWeekRus(aiStart+aiLen);
         strDop:=dwShort[dw];
         end;
     end;
  end;
  if not sel and (dt<tdt)
     then DrGr_AreaIntervalList.Canvas.Brush.Color:=clPaleBlue;
end;
finally
  with DrGr_AreaIntervalList.Canvas
     do begin
     Windows.FillRect(Handle, Rect, Brush.Handle);
     if (ARow>0) and (ACol=2)
        then IL_Paint.Draw(DrGr_AreaIntervalList.Canvas,Rect.Left + (Rect.Right-Rect.Left-IL_Paint.Width) div 2, Rect.Top, actInd,dsTransparent, itImage)
        else begin
//        if (dw>0)
//           then begin
//           if dw in [6,7]
//              then Font.Color:=clRed
//              else Font.Color:=clNavy;
//           end;
//        DrawTransparentText(Handle, str, rct, alg);
        DrawTransparentText(Handle, str, rct, DT_BOTTOM or DT_LEFT);
        if (dw>0) and (strDop<>'')
           then begin
           ind:=Font.Size;
           Font.Size:=6;
           try
           sz:=TextExtent(strDop+' ');
           rct:=Bounds(Rect.Right-sz.cx, Rect.Top,sz.cx, sz.cy);
           if dw in [6,7]
              then Font.Color:=clRed
              else Font.Color:=clNavy;
           DrawTransparentText(Handle, strDop, rct, DT_TOP or DT_RIGHT);
           finally
           Font.Size:=ind;
           end;
           end
        end
     end;
end;
except
  on E : Exception do LogErrorMessage('_Main.DrGr_AreaIntervalListDrawCell',E,[ACol, ARow]);
end;
end;

procedure T_Main.Lab_CoordClick(Sender: TObject);
var
 cnt : integer;
 IDs : TIntegerDynArray;
 ind : integer;
begin
if Length(FullAreaList.Items)=0
   then begin
   ShowMessageInfo('Список областей пуст.'+crlf+'Загрузите список областей и повторите операцию','отображение областей');
   Exit;
   end;

try
SetLength(IDs,0);
try
for cnt:=0 to High(FullAreaList.Items)
do if (FullAreaList.Items[cnt].aLevel>=3) and
       PointInArea(FullAreaList.Items[cnt].LatLng,LastClickedCoord)
       then begin
       ind:=Length(IDs);
       Setlength(IDs, ind+1);
       IDs[ind]:=FullAreaList.Items[cnt].aID;
       end;
if (Length(IDs)>0)
   then begin
   if (MessageBox(Handle, PChar(Lab_Coord.Hint+crlf+'Показать эти области?'),'Точка на карте', MB_ICONQUESTION + MB_YESNO)=IDYES)
      then begin
      FillSelectedAreas(IDs);
      ShowSelectedAreas;
      end;
   end
   else MessageBox(Handle, PChar('Не найдены области для указанной точки.'),'Точка на карте', MB_ICONINFORMATION);
finally
SetLength(IDs,0);
end;
except
on E : Exception do ;
end;
end;

procedure T_Main.BB_Area_CloseClick(Sender: TObject);
begin
case TAreaIntervalIdType(GB_Intervals.Tag) of
aiitArea : ShowWorkPanels(SpB_Mode_Map);
aiitPVZ  : ShowWorkPanels(SpB_Mode_PVZ);
end;
end;



procedure T_Main.SpB_AreaClick(Sender: TObject);
begin
ShowPopupMenu(SpB_Area,PM_Area);
end;

procedure T_Main.PM_AreaPopup(Sender: TObject);
var
 canWrite   : boolean;
 canAdd     : boolean;
 canEdit    : boolean;
 canSave    : boolean;
 canCancel  : boolean;
begin
canWrite := (wmtWrite in WorkMode);
canAdd:=(LastClickedCoord.X*LastClickedCoord.Y<>0) // -- есть  точка
        and canWrite // -- общее разрешение на редактирование
        and (CancelArea.aSessionID='') // -- нет уже редактируемой зоны
        and (FullAreaList.GetIndexById(0)=-1)
        ;
canEdit:=(CurObject.id<>0) // -- есть сохраненный текущий объект ...
     and (CurObject.idType=aiitArea) // -- ... и этот лобъект "зона"
     and canWrite // -- общее разрешение на редактирование
     and (CancelArea.aSessionID='') // -- нет уже редактируемой зоны
     ;
//canSave:=(Area.aRecordState<>0) and canWrite and (ExtSh_Intersect.Tag=0);
canSave:=((EditArea.aSessionID<>'') or (FullAreaList.GetIndexById(0)<>-1))// -- указана редактируемая зона
      and canWrite // -- общее разрешение на редактирование
      and (ExtSh_Intersect.Tag=0) // -- нет пересечений в указании границ
      ;
canCancel:=(EditArea.aSessionID<>'') // -- указана редактируемая зона
      and canWrite // -- общее разрешение на редактирование
      ;
NArea_Add.Enabled:=canAdd and not canSave;
NArea_Edit.Enabled:=canEdit and not canSave;
NArea_Del.Visible:=False;
NArea_Save.Enabled:=canSave;
NArea_Cancel.Enabled:=canCancel;
NArea_SendToBack.Enabled:=Area.aSessionID<>'';
end;


 procedure T_Main.MakeSaveArea;
  var
    resID : integer;
    ind   : integer;
  begin
  if not CanSaveArea_CheckParams(Area) or
     not CanSaveArea_CheckPoints(Area)
     then Exit;
  resId:=0;
  if (Area.aRecordState<>0)
   then begin
   resID:=Area.SaveIntoDB;
   FullAreaList.FillItem(Area);
   if resID>0
      then begin
       ExecuteScript(WB, Format('SaveAreaBySessionID("%s",%d)',[EditArea.aSessionID, resID]));
      _sleep(std_JS_Wait);
      end;
   end;
  EditArea.Clear;
  CancelArea.Clear;
  ind:=FullAreaList.GetIndexByID(resID);
  if ind>-1 then ;
  end;

  procedure T_Main.MakeCancelArea;
  var
   cnt : integer;
  begin
  if CancelArea.aID>0
     then FullAreaList.FillItem(CancelArea)
     else FullAreaList.ClearUnsaved;
  ExecuteScript(WB, Format('SaveAreaBySessionID("%s",%d)',[Area.aSessionID, Area.aId]));
  _sleep(std_JS_Wait);
  EditArea.Clear;
  CancelArea.Clear;
  for cnt:=0 to High(FullAreaList.Items) do FullAreaList.Items[cnt].aRecordState:=0;
  ShowSelectedAreas;
  end;

procedure T_Main.CallEditArea(Sender: TObject);
begin
try
if Sender=NArea_Add
   then begin
   Area.Clear;
   Area.aName:=shortstring('Новая область '+FormatdateTime('dd.mm.yyyy hh:nn:ss',Now));
   Area.aLevel:=defAreaLevel;
   Area.aRGBLine:=defColorLine;
   Area.aRGBFill:=defColorFill;
   Area.aSessionID:=shortstring(CreateGuid());
   ExecuteScript(WB, Format('CreateNewArea(%s,%s,%d,%d,"%s","%s","%s","%s")',[
                                                LastClickedCoord.LatitudeForRequest
                                              , LastClickedCoord.LongitudeForRequest
                                              , 5
                                              , 5000
                                              , Area.aRGBLine
                                              , Area.aRGBFill
                                              , StringToJavaUTF8Ex(string(Area.aName))
                                              , StringToJavaUTF8Ex(string(Area.aSessionID))  ]));
   _sleep(std_JS_Wait);
   end
   else
if Sender = NArea_Edit
   then begin
   (*ATTENTION*) // после редактирования области на всех заказах,
                 // где была согласована доставка по этой области будет сброшен
                 // идентификатор области в NULL
   EditArea.LoadFromSource(Area);
   EditArea.aRecordState:=1; // -- принудительно устанвливаем : редактируемая же!!!
   CancelArea.LoadFromSource(Area); // -- делаем backup
   ExecuteScript(WB, Format('EditAreaBySessionID("%s")',[Area.aSessionID]));
   _sleep(std_JS_Wait);
   end
   else
if Sender = NArea_Save
   then MakeSaveArea
   else
if Sender = NArea_Cancel
   then MakeCancelArea
   else
if Sender = NArea_Del
   then ShowMessageInfo('В настоящий версии возможность удаления описания области отключено.')
   else
if Sender = NArea_ShowHideXML
   then ShowHideAreaXML
   else
if Sender = NArea_SendToBack
   then begin
   ExecuteScript(WB, Format('SendToBack("%d")',[Area.aID]));
   _sleep(std_JS_Wait);
   end
   else
   ;
except
on E : Exception do LogErrorMessage('T_Main.CallEditArea',E,[AboutObject(Sender)]);
end;
end;

procedure T_Main.Ed_AreaNameChange(Sender: TObject);
var
 readyname : string;
 ss, sl    : integer;
begin
readyname:=StringToJavaUTF8Ex(Ed_AreaName.Text);
sl:=Ed_AreaName.SelLength;
ss:=Ed_AreaName.SelStart;
try
ExecuteScript(WB, Format('ChangeProps_BySessionID("%s", %d, "%s")',[Area.aSessionID,ipName,readyname]));
finally
Ed_AreaName.SetFocus;
Ed_AreaName.SelStart:=ss;
Ed_AreaName.SelLength:=sl;
end;

end;

procedure T_Main.CB_LevelChange(Sender: TObject);
var
 ind : integer;
begin
Area.aLevel:=CB_Level.ItemIndex;
try
ExecuteScript(WB, Format('ChangeProps_BySessionID("%s", %d, %d)',[Area.aSessionID,ipLevel,Area.alevel]));
ind:=_Main.FillParentAreaList(Area, CB_AreaParent);
if ind<0 then ;
finally
CB_Level.SetFocus;
end;
end;



procedure T_Main.CB_AreaParentChange(Sender: TObject);
var
 ind    : integer;
 ParID  : integer;
 _nm    : string;
 _rn    : integer;
 res    : integer;
 pts    : TArrayOfFloatPoint;
begin
Lab_Inp.Caption:='Вхождение точек : ?%';
Lab_Inp.Hint:='';
Lab_Area_ParentAreaName.Hint:='';
CB_AreaParent.Enabled:=false;
Screen.Cursor:=crAppStart;
try
if CB_AreaParent.ItemIndex=-1
   then ParID:=0
   else ParID:=PAreaItem(CB_AreaParent.Items.Objects[CB_AreaParent.ItemIndex])^.aID;
Lab_Area_ParentAreaName.Hint:=Format('ID : %d (область-владелец)',[ParID]);
Area.aParentID:=ParID;
if Assigned(Sender) then ExecuteScript(WB, Format('ChangeProps_BySessionID("%s", %d, %d)',[Area.aSessionID,ipParentID,Area.aParentID]));
// -- а вот дальше начинаем считать...
ind:=FullAreaList.GetAreaDataById(ParID,_nm,_rn);
if ind<0 then Exit;
res:=GetInnerPoints(Area.LatLng, FullAreaList.Items[ind].LatLng, pts);
Lab_Inp.Caption:=Format('Вхождение точек : %3.2f%%',[res/Length(Area.LatLng)*100]);
Lab_Inp.Hint:=Format('Вхождение точек по кол-ву : %d из %d',[res,Length(Area.LatLng)]);
finally
Lab_Inp.ShowHint:=true;
CB_AreaParent.Enabled:=true;
Screen.Cursor:=crDefault;
end;
(*ATTENTION*)
Exit;
if Length(pts)>0
   then begin
   _nm:=GetPointsForDisplay(pts);
   ExecuteScript(WB,'ClearMarkerList()');
   _sleep(std_JS_Wait);
   ExecuteScript(WB, Format('SetArrayOfMarker(%s)',[AnsiQuotedStr(_nm,'"')]));
   end;
end;

procedure T_Main.SpB_AreaParent_ClearClick(Sender: TObject);
begin
CB_AreaParent.ItemIndex:=-1;
if Assigned(CB_AreaParent.onChange) then CB_AreaParent.OnChange(CB_AreaParent);
CallEditArea(NArea_Save);
end;



procedure T_Main.SpB_IntervalListClick(Sender: TObject);
begin
ShowPopupMenu((Sender as TSpeedButton),PM_IntervalScheme);
end;

procedure T_Main.IntervalListProcessing(Sender: TObject);
const
 setAfterLast : boolean = false;
var
 cnt     : integer;
 maxDate : TDateTime;
 dtA     : TDateTime;
 dtB     : TdateTime;
begin
maxDate:=Date+daysNoEditInterval;
maxDate:=maxDate+1;
if SetAfterLast
   then begin
   for cnt:=0 to High(AreaIntervalList.Items)
     do begin
     dtA:=Trunc(AreaIntervalList.Items[cnt].aiStart);
     if dtA>maxDate
        then maxDate:=dtA;
     end;
   end
   else begin
   cnt:=DrGr_AreaIntervalList.Row-1;
   if (cnt>=Low(AreaIntervalList.Items)) and (cnt<=High(AreaIntervalList.Items))
      then begin
      dtA:=DateTime(Trunc(AreaIntervalList.Items[cnt].aiStart));
      if dtA>=maxDate
         then maxDate:=dtA;
      end;
   end;
if Sender=N_IntervalList_AddOne
   then begin
   dtA:=maxDate + EncodeTime(defHourbegin,0,0,0);
   dtB:=maxDate + EncodeTime(defHourEnd,0,0,0);
   CallInputDateTimeInterval(0,DateTime(Trunc(dtA)),dtA, dtB, True);
   end
   else
if Sender=N_IntervalList_New
   then begin
   DTI_SetArea;
   SzPan_IntervalSchemeEx.Show;
   SzPan_IntervalSchemeEx.BringToFront;
   end
   else
if Sender=N_IntervalList_EditOne
   then ShowIntervalEditor(DrGr_AreaIntervalList)
   else
if Sender=N_IntervalList_DelOne
   then DeleteCurrentInterval
   else
if  (Sender=N_IntervalList_TimeQuantum10) or
    (Sender=N_IntervalList_TimeQuantum15) or
    (Sender=N_IntervalList_TimeQuantum20) or
    (Sender=N_IntervalList_TimeQuantum30) or
    (Sender=N_IntervalList_TimeQuantum60)
    then begin
    dtInterval:=TDTInterval((Sender as TMenuItem).Tag);
    if Assigned(DTI)
       then begin
       DTI.IntervalType:=dtInterval;
       DTI.Repaint;
       end;
    try
    SaveInteger(baseSection,'dtInterval',integer(dtInterval),AppParams.CFGCommonFileName);
    except
    on E : Exception
      do ShowMessageWarning(
           'Увы! Не удалось сохранить выбранный квант времени для установки интервалов в схемах.'
     +crlf+'Получено сообщение об ошибке:'
     +crlf+E.Message
     ,'Квант времени');
    end
    end
    else

   ;
end;


procedure T_Main.PM_IntervalSchemePopup(Sender: TObject);
var
 canWrite : boolean;
 ind      : integer;
begin
canWrite:=wmtWrite in WorkMode;
N_IntervalList_AddOne.Enabled:=(CurObject.id>0) and canWrite;
ind:=DrGr_AreaIntervalList.Row-1;
if (ind>=Low(AreaIntervalList.Items)) and (ind<=High(AreaIntervalList.Items))
   then
   else ind:=-1;
N_IntervalList_EditOne.Enabled:=(CurObject.id>0) and canWrite and (ind<>-1);

case dtInterval of
   dti10min  : N_IntervalList_TimeQuantum10.Checked:=true;
   dti15min  : N_IntervalList_TimeQuantum15.Checked:=true;
   dti20min  : N_IntervalList_TimeQuantum20.Checked:=true;
   dti30min  : N_IntervalList_TimeQuantum30.Checked:=true;
   dti60min  : N_IntervalList_TimeQuantum60.Checked:=true;
end;

{$WARN SYMBOL_PLATFORM OFF}
//N_IntervalList_IntervalScheme.Visible:=(debughook<>0);
{$WARN SYMBOL_PLATFORM ON}
end;







procedure T_Main.NAcceptModeClick(Sender: TObject);
var
 ala : TAreaListAccept;
begin
try
ala:=TAreaListAccept((Sender as TMenuItem).tag);
except
ala:=alaNone;
end;
AreaListAccept:= ala;
SaveInteger(baseSection,'AreaListAccept',integer(AreaListAccept),AppParams.CFGUserFileName);
end;




procedure T_Main.SetMapCenter(Sender: TObject);
const _MenuSign = 'NMAP_CENTER_';
var
 lat : double;
 lng : double;
 ds  : char;
 ind : integer;
begin
try
lat := 0;
lng := 0;
if Sender = NMap_Center_Moscow
   then begin
   lat := centerMsk_Lat;
   lng := centerMsk_Lng;
   end
   else
if Sender = NMap_Center_Spb
   then begin
   lat := centerSPb_Lat;
   lng := centerSpb_Lng;
   end
   else
if Sender = NMap_Center_RnD
   then begin
   lat := centerRnD_Lat;
   lng := centerRnD_Lng;
   end
   else
if (Sender is TMenuItem) // -- на будущее, для работы с сохраненными центрами
  and (Pos(_MenuSign,AnsiUpperCase((Sender as TMenuItem).Name))=1)
  and (CheckValidInteger(StringReplace((Sender as TMenuItem).Name, _MenuSign,'',[rfIgnoreCase])))
  then begin
  ind:=StrToIntDef(StringReplace((Sender as TMenuItem).Name, _MenuSign,'',[rfIgnoreCase]),-1);
  if ind=-1 then Exit;

 //TFloatPoint
  end
  else Exit;
if (lat<>0) and (lng<>0)
   then begin
   ds:=FormatSettings.DecimalSeparator;
   try
   FormatSettings.DecimalSeparator:='.';
   ExecuteScript(WB,Format('yandex_SetCenter(%f,%f)',[lat,lng]));
   finally
   FormatSettings.DecimalSeparator:=ds;
   end;
   end

except

end;
end;

(***************************************************************************************)


procedure T_Main.DTP_DeliveryDateChange(Sender: TObject);
begin
DeliveryDate:=Trunc(DTP_DeliveryDate.date);
SaveDateTime(baseSection,'DeliveryDate',DeliveryDate,AppParams.CFGUserFileName );
Lab_DeliveryDate.Caption:=FnCommon.GetLongDateY(DeliveryDate);
end;

procedure T_Main.SpB_DeliveryAgentClick(Sender: TObject);
begin
ShowPopupMenu((Sender as TSpeedButton),PM_Agent);
end;

procedure T_Main.SetDeliveryAgent(Sender: TObject);
var
 mi : TMenuItem;
begin
if Sender.InheritsFrom(TMenuItem)
   then mi:=(Sender as TMenuItem)
   else Exit;
SetGlyph(SpB_DeliveryAgent,TImageList(PM_Agent.Images),mi.ImageIndex);
SpB_DeliveryAgent.Hint:='Установлен агент доставки по городу '+mi.Caption;
SpB_DeliveryAgent.Tag:=mi.Tag;
DeliveryAgent:=TDeliveryAgent(mi.Tag);
SaveInteger(baseSection,'DeliveryAgent',integer(DeliveryAgent),AppParams.CFGUserFileName ) ;
Im_DeliveryAgent.Transparent:=true;
Im_DeliveryAgent.Picture.Assign(SpB_DeliveryAgent.Glyph);
Im_DeliveryAgent.Hint:=SpB_DeliveryAgent.Hint;
Im_DeliveryAgent.SHowHint:=true;
end;



procedure T_Main.ShowDeliveryAreas(Sender: TObject);
var
 cnt     : integer;
 ind     : integer;
 tmp     : TIntegerDynArray;
begin
ClearMap;
SetLength(tmp,0);
for cnt:=0 to High(HistoryAreaList.Items)
  do begin
  ind:=Length(tmp);
  SetLength(tmp,ind+1);
  tmp[ind]:=HistoryAreaList.Items[ind].aID;
  end;
FillSelectedAreas(tmp);
ShowSelectedAreas;
end;






procedure T_Main.DrGr_CarsListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
type  TItemColors = array[0 .. 3]of TColor;
const
    UnkColors   : TItemColors =(clWindow, clWindowText, clHighlight, clHighlightText);
    GoodColors  : TItemColors =(clPaleGreen, clNavy, clGreen, clYellow);
    BadColors   : TItemColors =(clPaleRed, clNavy, clRed, clYellow);
    WarnColors  : TItemColors =(clPaleYellow, clNavy, clYellow, clNavy);

var
  rct: TRect;
  rctS:Trect;
  ind: integer;
  alg: integer;
  str: string;
  CurColors : TItemColors;
  bmp: TBitmap;
const
  Titles: array[0 .. 4] of string =('Модель', 'Гос.номер' , 'Водитель', 'Зона доставки','Точек(Заказов, Возвратов(из них))');
begin
try
str := '';
rct := Classes.Rect(Rect.left + 2, Rect.Top + 1, Rect.Right - 2,
  Rect.Bottom - 1);
alg := DT_LEFT_ALIGN;
bmp:=nil;
try
  case ARow of
    0:
      str := Titles[ACol];
  else
    begin
      ind := ARow - 1;
      with DrGr_CarsList.Canvas do
        if(gdSelected in State)or(gdFocused in State)then
        begin
          Font.Color := clHighlightText;
          Brush.Color := clHighlight;
        end
        else
        begin
          Font.Color := clWindowText;
          Brush.Color := clWindow;
        end;
      if(ind < Low(CarList.Items))or(ind > High(CarList.Items))
         then exit;
  if AC2Str(CarList.Items[ind].Driver_FIO)=''
     then System.Move(BadColors, CurColors, SizeOf(TItemColors))
     else
  if CarList.Items[ind].Area_ID=0
     then System.Move(WarnColors, CurColors, SizeOf(TItemColors))
     else System.Move(GoodColors, CurColors, SizeOf(TItemColors)) ;
  with DrGr_CarsList.Canvas do
    if(gdSelected in State)or(gdFocused in State)
       then begin
       Brush.Color := CurColors[2];
       Font.Color  := CurColors[3];
       end
       else begin
       Brush.Color := CurColors[0];
       Font.Color  := CurColors[1];
       end;
      case ACol of
        0:str := ArrayOfCharToString(CarList.Items[ind].Car_Model);
        1:begin
          bmp:=nil;
          if Assigned(CarList.Items[ind].NumPic)
             then begin
             bmp := TBitmap.Create;
             bmp.Assign(CarList.Items[ind].NumPic);
             end
             else str := ArrayOfCharToString(CarList.Items[ind].Car_Reg_Num);
          end;
        2: str:=ArrayOfCharToString(CarList.Items[ind].Driver_FIO);
        3: str := Format('%s',[ArrayOfCharToString(CarList.Items[ind].Area_name)]);
        4 : str:=Format('%d (%d, %d)',[CarList.Items[ind]._Points,CarList.Items[ind]._Deliveries,CarList.Items[ind]._Return]);
      end;
    end;
  end;
finally
  with DrGr_CarsList.Canvas do
  begin
    Windows.FillRect(Handle, Rect, Brush.Handle);
    if ARow=0
       then begin
       FillChar(rctS,SizeOf(TRect),0);
       case CarList.clArr of
       claNone           : ;
       claCar_Model      : rctS:=DrGr_CarsList.CellRect(0,0);
       claCar_Reg_Num    : rctS:=DrGr_CarsList.CellRect(1,0);
       claDriver_FIO     : rctS:=DrGr_CarsList.CellRect(2,0);
       claArea_Name      : rctS:=DrGr_CarsList.CellRect(3,0);
       claOrders         : rctS:=DrGr_CarsList.CellRect(4,0);

       end;
       if (rctS.Left<>0) and (rctS.Right<>0)
          then begin
          rctS.Left:=rctS.Right - 19; rctS.Right:=rct.Right-2;
          FnCommon.SimpleTriAngleOrder(DrGr_CarsList.Canvas,rctS.Left,rctS.Top+3,not CarList.clDesc,FnCommon.ttobcGray,15);
          end;
       end;

    if(str = '')and Assigned(bmp)then
    begin
      TransparentBlt(Handle, Rect.left +(Rect.Right - Rect.left)div 2 -
        bmp.Width div 2, Rect.Top +(Rect.Bottom - Rect.Top)div 2 -
        bmp.Height div 2, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0,
        bmp.Width, bmp.Height, ColorToRGB(clFuchsia));
      //FreeAndNil(bmp);
    end;
    if(ARow > 0)and(AnsiPos(Ed_CarListSearch.Hint, AnsiUpperCase(str))> 0)
       then Font.Style :=[fsBold]
       else Font.Style :=[];
    SetBkMode(Handle, TRANSPARENT);
    DrawText(Handle, str, Length(str), rct, alg);
    SetBkMode(Handle, OPAQUE);
  end;
if Assigned(bmp) then bmp.Free;
end;
except
  on E : Exception do LogErrorMessage('_Main.DrGr_CarsListDrawCell',E,[ACol, ARow]);
end;
end;




procedure T_Main.DrGr_CarsListEnter(Sender: TObject);
begin



//self.SetFocusedControl(DrGr_CarsList);
//sleep(1);
//Application.ProcessMessages;
//DrGr_CarsList.SetFocus;
//DrGr_CarsList.Perform(WM_SETFOCUS,0,0);
//ActiveControl:=DrGr_CarsList;
//SendMessage(DrGr_CarsList.Handle, WM_SETFOCUS,0,0);
//sleep(1);
//   end;

end;

procedure T_Main.Ed_CarListSearchChange(Sender: TObject);
begin
Ed_CarListSearch.Hint:=AnsiUpperCase(Ed_CarListSearch.Text);
DrGr_CarsList.Repaint;
end;


procedure T_Main.SpB_DeliveryRefreshClick(Sender: TObject);
begin
ShowDeliveryControls(false);
Update;
if not GetFullData(DeliveryDate,DeliveryAgent)
   then begin
   FormActivate(self);
   end;
DeliveryShowMode:=dsmUndefined;
Sh_DeliveryMode.Left:=SpB_DeliveryRefresh.Left+3;
end;



procedure T_Main.SpB_Deliverys_ReportClick(Sender: TObject);
var
 ndl     : TNoDeliveryList;
 step    : string;
 dtBegin : TDateTime;
 dtEnd   : TDateTime;
begin
try
try
step:='Prepare dates';
dtBegin:=Date; dtEnd:=Date;
if not Filter_GetDates(SpB_Deliverys_Report, dtBegin, dtEnd)
   then begin
   //ShowMessageInfo(Format('%s  - %s',[FormatDateTime('dd.mm.yyyy',dtBegin),FormatDateTime('dd.mm.yyyy',dtEnd)]));
   Exit;
   end;
step:='Load from DB';
ndl.LoadFromDB(dtBegin,dtEnd);
step:='IntoExcel';
ndl.IntoExcel('Отчет по переносам/отказам');
finally
ndl.Clear;
end;

except
on E : Exception do LogErrorMessage('T_Main.SpB_Deliverys_ReportClick',E,[step, dtBegin, dtEnd]);
end;

end;

procedure T_Main.SzPan_DeliverysResize(Sender: TObject);
begin
DrGr_CarsList.Repaint;
end;

procedure T_Main.CallShowMarkersOrRoute(Sender: TObject);
var
 ind       : integer;
 ShowRoute : boolean;
begin
ind:=DrGr_CarsList.Row-1;
if (ind>=Low(CarList.Items)) and (ind<=High(CarList.Items))
   then begin
   ShowRoute:=(Sender=SpB_ShowRoute);
   if ShowRoute
      then begin
      DeliveryShowMode:=dsmRoute;
      Sh_DeliveryMode.Left:=SpB_ShowRoute.Left+3;
      end
      else begin
      DeliveryShowMode:=dsmMarker;
      Sh_DeliveryMode.Left:=SpB_ShowMarkers.Left+3;
      end;
   ShowMarkersOrRoute(CarList.Items[ind].Car_ID, ShowRoute);
   _sleep(std_JS_Wait);
   end;
end;








procedure T_Main.DrGr_CarsListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
var
 newCLA : TCarListArrange;
 cs     : boolean;
 CurLicPlate: string;
 CurInd:integer;
begin
try
CurLicPlate:='';
CurInd:=DrGr_CarsList.Row-1;
if (CurInd>=Low(CarList.Items)) and (CurInd<=High(CarList.Items))
   then CurLicPlate:=AC2Str(CarList.Items[CurInd].Car_Reg_Num);
case ACol of
  0  : newCLA:=claCar_Model;
  1  : newCLA:=claCar_Reg_Num;
  2  : newCLA:=claDriver_FIO;
  3  : newCLA:=claArea_Name;
  4  : newCLA:=claOrders;
else newCLA:=claNone;
end;
if newCLA=claNone then Exit;
if newCLA=CarList.clArr
   then CarList.clDesc:=not CarList.clDesc
   else CarList.clArr:=newCLA;
CarList.Arrange(CarList.clArr,CarList.clDesc);
if (CurLicPlate<>'')
   then begin
   for CurInd:=0 to High(CarList.Items)
      do if (AC2Str(CarList.Items[CurInd].Car_Reg_Num)=CurLicPlate)
            then begin
            DrGr_CarsList.Row:=CurInd+1;
            SetVisibleRow3(DrGr_CarsList,DrGr_CarsList.Row);
            Break;
            end;
   end;
if Assigned(DrGr_CarsList.OnSelectCell)
   then DrGr_CarsList.OnSelectCell(DrGr_CarsList,DrGr_CarsList.Col,DrGr_CarsList.Row,cs);
DrGr_CarsList.Repaint;
except
  on E : Exception do LogErrorMessage('_Main.DrGr_CarsListFixedCellClick',E,[ACol, ARow]);
end;
end;


procedure T_Main.DrGr_CarsListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
CanSelect:=true;
DrGr_CarsList.onSelectCell:=nil;
// -- вот таким тупым методом можно четко поймать фокус на TDrawGrid из TwebBrowser
Ed_CarListSearch.SetFocus;sleep(1);
DrGr_CarsList.SetFocus; sleep(1);

try
DrGr_CarsList.Row:=aRow;
case DeliveryShowMode of
dsmUndefined : ;
dsmMarker    : CallShowMarkersOrRoute(SpB_ShowMarkers);
dsmRoute     : CallShowMarkersOrRoute(SpB_ShowRoute);
end;
finally
DrGr_CarsList.onSelectCell:=DrGr_CarsListSelectCell;
end;
end;


procedure T_Main.BB_Delivery_CloseClick(Sender: TObject);
begin
ShowWorkPanels(SpB_Mode_Delivery);
end;




procedure T_Main.LabT_DeliverysTitleClick(Sender: TObject);
begin
ShowDeliveryControls(not DTP_DeliveryDate.Visible);
end;





(**************************************************************************************************)


procedure T_Main.BB_Tools_CloseClick(Sender: TObject);
begin
ShowWorkPanels(SpB_Mode_Tools);
end;




procedure T_Main.SzPan_ToolsResize(Sender: TObject);
begin
//BB_Tools_Close.Left:=BB_Tools_Close.parent.ClientWidth-BB_Tools_Close.Width;
BB_Tools_Close.Left:=(PC_Tools.Left+PC_Tools.Width)- BB_Tools_Close.Width;
end;




procedure T_Main.SpB_Tools_UsedAreas_Click(Sender: TObject);
   function PrepareXML(var aInfo : string) : string;
   var
     dtStart  : TDateTime;
     dtFinish : TDateTime;
   begin
   dtStart:=Trunc(DTP_Tools_UsedAreas_Start.Date);
   dtFinish:=Trunc(DTP_Tools_UsedAreas_Finish.Date);
   if dtStart>dtFinish
      then begin
      dtStart:=dtStart+dtFinish;
      dtFinish:=dtStart-dtFinish;
      dtStart:=dtStart-dtFinish;
      end;
   Result:=Format('<REQUEST BEGIN="%s" END="%s"></REQUEST>',[FormatDateTime('yyyymmdd',dtStart),FormatDateTime('yyyymmdd',dtFinish)]);
   aInfo:=Format('%s-%s',[FormatDateTime('dd.mm.yyyy',dtStart),FormatDateTime('dd.mm.yyyy',dtFinish)]);
   end;
var
 xml  : string;
 info : string;
 cnt  : integer;
 fn   : string;
begin
if Sender=SpB_Tools_UsedAreas_Load
   then begin
   xml:=PrepareXML(info);
   if not UsedAreaList.LoadFromDB(xml) then Exit;
   ShowUsedAreas;
   end
   else
if Sender=SpB_Tools_UsedAreas_ViewMode
   then ShowPopupMenu(SpB_Tools_UsedAreas_ViewMode, PM_Tools_UsedAreas_ViewMode)
   else
if Sender=SpB_Tools_UsedAreas_Excel
   then begin
   xml:=PrepareXML(info);
   if Length(UsedAreaList.Items)=0
      then if not UsedAreaList.LoadFromDB(xml) then Exit;
   UsedAreaList.IntoExcel(info);
   end
   else
if Sender=SpB_Tools_UsedAreas_Download
   then begin
   if TV_Tools_UsedAreas.Items.Count=0
      then begin
      xml:=PrepareXML(info);
      if not UsedAreaList.LoadFromDB(xml) then Exit;
      ShowUsedAreas;
      end;
   info:='';
   for cnt:=0 to PM_Tools_UsedAreas_ViewMode.Items.Count-1
     do if PM_Tools_UsedAreas_ViewMode.Items[cnt].Checked
           then begin
           info:=PM_Tools_UsedAreas_ViewMode.Items[cnt].Caption;
           Break;
           end;
   info:=Format('%s за %s-%s',[info, FormatDateTime('dd.mm.yyyy',Trunc(DTP_Tools_UsedAreas_Start.Date)),FormatDateTime('dd.mm.yyyy',Trunc(DTP_Tools_UsedAreas_Finish.Date))]);
   fn:=ChangeFileExt(SettailBackSlash(GetTempFolder)+info,'.txt');
   TV_Tools_UsedAreas.SaveToFile(fn);
   FileOpenNT(fn);
   end

   ;
end;





procedure T_Main.Ed_Tools_UsedAreas_SearchChange(Sender: TObject);
begin
if not (Sender is TEdit) then Exit;
(Sender as TEdit).ShowHint:=false;
(Sender as TEdit).Hint:=AnsiUpperCase((Sender as TEdit).Text);
if (Sender = Ed_Tools_UsedAreas_Search)
   then TV_Tools_UsedAreas.Invalidate
   else
if (Sender = Ed_Tools_DTP_Search)
   then DrGr_AccidentList.Invalidate
   else
if (Sender = Ed_Tools_AreaLog_Search)
   then DrGr_AreaLogList.Invalidate;

end;

procedure T_Main.TV_Tools_UsedAreasAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
  State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
 rct : TRect;
 sel : boolean;
begin
//DefaultDraw:=false;
try
with TV_Tools_UsedAreas.Canvas do
   begin
   //rct:=Node.DisplayRect(false);
   //rct.Left:=-TV_Tools_UsedAreas_spH+24;
   rct:=Node.DisplayRect(true);
   rct.Right:=Screen.Width;

   sel:=(cdsSelected in State) or (cdsFocused in State);
   Font.Color:=FontColor[sel];
   Brush.Color:=BrushColor[sel];
   FillRect(rct);
   if (Ed_Tools_UsedAreas_Search.Hint<>'')
      then if (AnsiPos(Ed_Tools_UsedAreas_Search.Hint,AnsiUpperCase(Node.Text))=0)
             then Font.Color:=clGray
             else Font.Color:=clWindowText
      else Font.Color:=clWindowText;
   DrawTransparentText(Handle,Node.Text,rct,DT_LEFT_ALIGN);
   end;
finally
//DefaultDraw:=true;
end;

end;

procedure T_Main.SetUsedAreasViewMode(Sender: TObject);
begin
(Sender as TMenuItem).Checked:=true;
UsedAreasViewMode:=TUsedAreasViewMode((Sender as TMenuItem).Tag);
try
SaveInteger(baseSection,'UsedAreasViewMode',integer(UsedAreasViewMode),AppParams.CFGUserFileName);
except
end;
ShowUsedAreas;
end;


(*************************************************************************************************)

procedure T_Main.SpB_Tools_DTP_Click(Sender: TObject);
   function PrepareXML(var aInfo : string) : string;
   const empty : array[boolean] of string = ('0','1');
   var
     dtStart  : TDateTime;
     dtFinish : TDateTime;
   begin
   dtStart:=Trunc(DTP_Tools_DTP_Start.Date);
   dtFinish:=Trunc(DTP_Tools_DTP_Finish.Date);
   if dtStart>dtFinish
      then begin
      dtStart:=dtStart+dtFinish;
      dtFinish:=dtStart-dtFinish;
      dtStart:=dtStart-dtFinish;
      end;

   if N_Tools_DTP_Filter_Days.Checked
      then begin
      aInfo:=Format('%s-%s',[FormatDateTime('dd.mm.yyyy',dtStart),FormatDateTime('dd.mm.yyyy',dtFinish)]);
      Result:=Format('<REQUEST BEGIN="%s" END="%s" EMPTY="0"></REQUEST>',[FormatDateTime('yyyymmdd',dtStart),FormatDateTime('yyyymmdd',dtFinish)]);
      end
      else
   if N_Tools_DTP_Filter_Empty.Checked
      then begin
      aInfo:='все необработанные';
      Result:=Format('<REQUEST BEGIN="%s" END="%s" EMPTY="1"></REQUEST>',[FormatDateTime('yyyymmdd',EncodeDate(2014,1,1)),FormatDateTime('yyyymmdd',Date)]);
      end
      else ;
   end;
const
 DataEdit  : boolean = false;
 ResEdit   : boolean = true;
var
 xml   : string;
 info  : string;
 ln    : integer;
 prvID : integer;
 AI    : TAccidentItem;
 resID : integer;
 ind   : integer;
 cnt   : integer;
 cs    : boolean;
 _acID : integer;
begin
if Sender=SpB_Tools_DTP_Load
   then begin
   prvID:=AccidentItem.ID;
   AccidentItem.Clear;
   SpB_Tools_DTP_Edit.Tag:=0;
   SetCtrlButtons;
   xml:=PrepareXML(info);
   if not AccidentList.LoadFromDB(DBConnString, xml) then prvID:=-1;
   if not acTypeList.LoadFromDB(DBConnString) then ;
   ln:= Length(AccidentList.Items);
   DrGr_AccidentList.RowCount:=1+ln+integer(ln=0);
   if prvID>0
    then for ln:=0 to High(AccidentList.Items)
           do if AccidentList.Items[ln].ID = prvID
                 then begin
                 SetVisibleRow3(DrGr_AccidentList,ln+1);
                 Exit;
                 end;
   DrGr_AccidentList.Repaint;
   end
   else
if Sender=SpB_Tools_DTP_Edit
   then begin
   if SpB_Tools_DTP_Edit.Tag=0 // -- это идентификатор инцедента
      then Exit;
   FillChar(AI,SizeOf(TAccidentItem),0);
   AI.NumPic:=nil;
   if not Assigned(_DTP_Editor)
     then _DTP_Editor:=T_DTP_Editor.CreateWithParams(Application,DBConnString,AccidentItem,DataEdit, ResEdit);
   try
   if _DTP_Editor.ShowModal = mrOk
      then begin
      with AI, _DTP_Editor do
        begin
        ID         := Tag;
        acDate     := DTP_Date.Datetime;              // -- дата события
        Str2AC(Trim(Ed_acPlace.Text), acPlace);       // -- место события
        Str2AC(Trim(dtp_Car), acCar);                 // -- по Navision (выбирается по дате)
        Str2AC(Trim(dtp_Driver), acDriver);           // -- по Navision (оператору не показывается, выбирается при выборе автомобиля)
        _acID:=0;
        if (CB_acType.ItemIndex>-1) and Assigned(CB_acType.Items.Objects[CB_acType.ItemIndex])
           then _acID:=integer(CB_acType.Items.Objects[CB_acType.ItemIndex]);
        acType     :=_acID;                           (*LIST(lst_Value(Task:1, Entity:1))*) // -- тип (словарь, HardCode (20141015))
        Str2AC(Trim(Mem_acNote.Text), acNote);         // -- описание (если тип "Другое" или уточнение)
        clType     := TclType(CB_clType.ItemIndex+1); // -- тип (словарь, HardCode (20141015))
        Str2AC(Trim(Ed_clFIO.Text), clFIO);           // -- ФИО звонившего
        Str2AC(Trim(Ed_clPhone.Text), clPhone);       // -- телефон звонившего
        Str2AC(Trim(Mem_resNote.Text), resNote);      // -- заключение по случаю
//        case ChB_resGuilty.State of
//        cbGrayed    : resGuilty  := rgUnknown;
//        cbUnchecked : resGuilty  := rgNotGuilty;
//        cbChecked   : resGuilty  := rgGuilty;
//        end;
        resGuilty  := TResGuilty(CB_resGuilty.ItemIndex);
        NumPic:=TBitmap.Create;
        with NumPic do
           begin
           Width:=DefRegNumRct.Right;
           Height:=DefRegNumRct.Bottom;
           end;
        GetRegNumber(Ac2Str(acCar), DefRegNumRct, NumPic)
        end;
      try
      resID:=AI.SaveIntoDB;
      prvID:=0;
      if resID>0
         then begin
         if Ai.ID=0  // -- это новый, здесь вряд ли возможно, но тем не менее
            then begin
            AI.ID:=resID;
            ind:=Length(AccidentList.Items);
            SetLength(AccidentList.Items,ind+1);
            AccidentList.Items[ind].NumPic:=nil;
            end
            else ind:=AccidentList.GetIndexByID(AI.ID);

         if AI.LoadFromDB(DBConnString) and (ind>-1)
            then begin
            AccidentList.Items[ind].LoadFromSource(AI);
            prvID:=AI.ID
            end;
         AccidentList.Arrange(AccidentList.alArr, AccidentList.alDesc);
         for cnt:=0 to High(AccidentList.Items)
           do if prvID=AccidentList.Items[cnt].ID
                 then begin
                 SetVisibleRow3(DrGr_AccidentList, cnt+1);
                 if Assigned(DrGr_AccidentList.OnSelectCell)
                    then DrGr_AccidentList.OnSelectCell(DrGr_AccidentList,DrGr_AccidentList.Col,DrGr_AccidentList.Row, cs);
                 Break;
                 end;
         end
         else (*что-то пошло не так!!!*);
      DrGr_AccidentList.Repaint;
      except
      on E : Exception do ;
      end;


      end;
   finally
   _DTP_Editor.Close;
   FreeAndNil(_DTP_Editor);
   AI.Clear;
   end;
   end
   else
if Sender=SpB_Tools_DTP_Excel
   then begin
   xml:=PrepareXML(info);
   if Length(UsedAreaList.Items)=0
      then begin
      if not AccidentList.LoadFromDB(DBConnString, xml) then Exit;
      if not acTypeList.LoadFromDB(DBConnString) then Exit;
      end;
   AccidentList.IntoExcel(info);
   end
   else
if Sender=SpB_Tools_DTP_Filter
   then begin
   ShowPopupMenu(SpB_Tools_DTP_Filter,PM_Tools_DTP_Filter);
   end
   ;
end;

procedure T_Main.DrGr_AccidentListDblClick(Sender: TObject);
var
 pt : TPoint;
 gc : TGridCoord;
begin
GetCursorPos(pt);
Windows.ScreenToClient(DrGr_AccidentList.Handle,pt);
gc:=DrGr_AccidentList.MouseCoord(pt.X, pt.Y);
if gc.Y=0 then Exit;
SpB_Tools_DTP_Click(SpB_Tools_DTP_Edit);
end;

procedure T_Main.DrGr_AccidentListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
 Titles : array[0..13] of string = ('Дата','Место','Гос.номер','Водитель','Нарушение','Описание','Звонивший','Тип','Телефон','Резолюция','Добавлено', 'Оператор', 'Решено', 'Логист');
var
 str      : string;
 ind      : integer;
 rct      : Trect;
 alg      : integer;
 sel      : boolean;
 fnd      : boolean;
 bmp      : TBitmap;
 rctA     : Trect;
 bmp_res  : TBitmap;
begin
try
str:='';
alg:=DT_LEFT_ALIGN;
ind:=-1;
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
bmp:=nil;
bmp_res:=nil;
fnd:=true;
try
case ARow of
 0 : str:=Titles[aCol];
else begin
ind:=ARow-1;
if (ind<Low(AccidentList.Items)) or ((ind>High(AccidentList.Items)))
   then begin

   Exit;
   end;
case ACol of
0 : str:=FormatDateTime('dd.mm.yyyy',AccidentList.Items[ind].acDate);
1 : str:=AC2Str(AccidentList.Items[ind].acPlace);
2 : if Assigned(AccidentList.Items[ind].NumPic)
       then begin
       bmp := TBitmap.Create;
       bmp.Assign(AccidentList.Items[ind].NumPic) ;
       str := AC2Str(AccidentList.Items[ind].acCar);  // --для поиска, после отрисовки обнуляется
       end
       else str := AC2Str(AccidentList.Items[ind].acCar);
3 : str:=AC2Str(AccidentList.Items[ind].acDriver);
4 : str:=acTypeList.acTypeDescr(AccidentList.Items[ind].acType);
5 : str:=AC2Str(AccidentList.Items[ind].acNote);
6 : str:=AC2Str(AccidentList.Items[ind].clFIO);
7 : str:=clTypeDescr[(AccidentList.Items[ind].clType)];
8 : str:=AC2Str(AccidentList.Items[ind].clPhone);
9 : begin
    str:=AC2Str(AccidentList.Items[ind].resNote); (*ATTENTION*)
    bmp_res:=TBitmap.Create;
    with bmp_res do
      begin
      Width:=IL_Paint.Width;
      Height:=IL_Paint.Height;
      TransparentColor:=clFuchsia;
      Canvas.Brush.Color:=TransparentColor;
      Canvas.FillRect(Bounds(0,0,Width,Height));
      case AccidentList.Items[ind].resGuilty of
      rgUnknown   : IL_Paint.Draw(Canvas,0,0,ptpListEmpty);
      rgNotGuilty : IL_Paint.Draw(Canvas,0,0,ptpListGreen);
      rgGuilty    : IL_Paint.Draw(Canvas,0,0,ptpListRed);
      end;
      end;
    end;
10 : if AccidentList.Items[ind]._addDate>0
        then str:=FormatDateTime('dd.mm.yyyy hh:nn:ss',AccidentList.Items[ind]._addDate);
11 : str:=AC2Str(AccidentList.Items[ind]._addEditor);

12 : if AccidentList.Items[ind]._logDate>0
        then str:=FormatDateTime('dd.mm.yyyy hh:nn:ss',AccidentList.Items[ind]._logDate);
13 : str:=AC2Str(AccidentList.Items[ind]._logEditor);
end;

sel:=(gdSelected in State) or (gdFocused in State);
fnd:=(AnsiPos(Ed_Tools_DTP_Search.Hint,AnsiUpperCase(str))>0) or (Ed_Tools_DTP_Search.Hint='');
DrGr_AccidentList.Canvas.Font.Color:=FontColorSearch[fnd, sel];
DrGr_AccidentList.Canvas.Brush.Color:=BrushColorSearch[fnd, sel];
end;
end;


finally
with DrGr_AccidentList.Canvas do
  begin
  Windows.FillRect(Handle, Rect, Brush.Handle);
    if ARow=0
       then begin
       FillChar(rctA,SizeOf(TRect),0);
       case AccidentList.alArr of
       aclaDate     : rctA:=DrGr_AccidentList.CellRect( 0,0);
       aclaPlace    : rctA:=DrGr_AccidentList.CellRect( 1,0);
       aclaCar      : rctA:=DrGr_AccidentList.CellRect( 2,0);
       aclaDriver   : rctA:=DrGr_AccidentList.CellRect( 3,0);
       aclaAType    : rctA:=DrGr_AccidentList.CellRect( 4,0);
       aclaFIO      : rctA:=DrGr_AccidentList.CellRect( 6,0);
       aclaCType    : rctA:=DrGr_AccidentList.CellRect( 7,0);
       aclaPhone    : rctA:=DrGr_AccidentList.CellRect( 8,0);
       aclaGuilty   : rctA:=DrGr_AccidentList.CellRect( 9,0);
       aclaAddDate  : rctA:=DrGr_AccidentList.CellRect(10,0);
       aclaAddEditor: rctA:=DrGr_AccidentList.CellRect(11,0);
       aclaLogDate  : rctA:=DrGr_AccidentList.CellRect(12,0);
       aclaLogEditor: rctA:=DrGr_AccidentList.CellRect(13,0);
       end;
       if (*(rctA.Left<>0) and *)(rctA.Right<>0)
          then begin
          rctA.Left:=rctA.Right - 19; rctA.Right:=rct.Right-2;
          SimpleTriAngleOrder(Handle,rctA.Left,rctA.Top+3,not AccidentList.alDesc,FnCommon.ttobcGray,15);
          end;
       end;
  if ind=-1 then ;
  if Assigned(bmp)then
    begin
    if fnd
       then TransparentBlt(Handle, Rect.left +(Rect.Right - Rect.left)div 2 -
        bmp.Width div 2, Rect.Top +(Rect.Bottom - Rect.Top)div 2 -
        bmp.Height div 2, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0,
        bmp.Width, bmp.Height, ColorToRGB(clFuchsia))
       else
      AlphaBlt(Handle, Rect.left +(Rect.Right - Rect.left)div 2 -
        bmp.Width div 2, Rect.Top +(Rect.Bottom - Rect.Top)div 2 -
        bmp.Height div 2, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0,
        bmp.Width, bmp.Height,80);
    str:='';
    end;
  if Assigned(bmp_res)then
    begin
    TransparentBlt(Handle
       , rct.left //+(Rect.Right - Rect.left)div 2 - bmp_res.Width div 2
       , rct.Top //+(Rect.Bottom - Rect.Top)div 2 -  bmp_res.Height div 2
       , bmp_res.Width
       , bmp_res.Height
       , bmp_res.Canvas.Handle
       , 0
       , 0
       , bmp_res.Width
       , bmp_res.Height
       , ColorToRGB(clFuchsia));
    rct.Left:=rct.Left+bmp_res.Width+4;
    end;
  DrawTransparentText(Handle, str, rct, alg);
  if Assigned(bmp) then bmp.Free;
  if Assigned(bmp_res) then bmp_res.Free;
  end;
end;
except
on E : Exception do LogErrorMessage('T_Main.DrGr_AccidentListDrawCell',E,[ACol,ARow]);
end;
end;

procedure T_Main.DrGr_AccidentListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
var
 newAcLA     : TAccidentListArrange;
 cs          : boolean;
 CurID       : integer;
 CurInd      : integer;
begin
try
CurID:=0;
CurInd:=DrGr_AccidentList.Row-1;
if (CurInd>=Low(AccidentList.Items)) and (CurInd<=High(AccidentList.Items))
   then CurID:=AccidentList.Items[CurInd].ID; // -- в принципе, есть AccidentItem...
case ACol of
   0  : newAcLA:=aclaDate;
   1  : newAcLA:=aclaPlace;
   2  : newAcLA:=aclaCar;
   3  : newAcLA:=aclaDriver;
   4  : newAcLA:=aclaAType;
//  5  : newAcLA:=acla;
   6  : newAcLA:=aclaFIO;
   7  : newAcLA:=aclaCType;
   8  : newAcLA:=aclaPhone;
   9  : newAcLA:=aclaGuilty;
  10  : newAcLA:=aclaAddDate;
  11  : newAcLA:=aclaAddEditor;
  12  : newAcLA:=aclaLogDate;
  13  : newAcLA:=aclaLogEditor;
else newAcLA:=aclaNone;
end;
if newAcLA=aclaNone then Exit;
if newAcLA=AccidentList.alArr
   then AccidentList.alDesc:=not AccidentList.alDesc
   else AccidentList.alArr:=newAcLA;
AccidentList.Arrange(AccidentList.alArr,AccidentList.alDesc);
if (CurID<>0)
   then begin
   for CurInd:=0 to High(AccidentList.Items)
      do if (AccidentList.Items[CurInd].ID=CurID)
            then begin
            SetVisibleRow3(DrGr_AccidentList,CurInd+1);
            Break;
            end;
   end;
if Assigned(DrGr_AccidentList.OnSelectCell)
   then DrGr_AccidentList.OnSelectCell(DrGr_AccidentList,DrGr_AccidentList.Col,DrGr_AccidentList.Row,cs);
DrGr_AccidentList.Repaint;
except
  on E : Exception do LogErrorMessage('_Main.DrGr_AccidentListFixedCellClick',E,[ACol, ARow]);
end;
end;


procedure T_Main.DrGr_AccidentListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
 ind : integer;
begin
AccidentItem.Clear;
ind:=ARow-1;
if (ind>=Low(AccidentList.Items)) and (ind<=High(AccidentList.Items))
   then AccidentItem.LoadFromSource(AccidentList.Items[ind]);
SpB_Tools_DTP_Edit.tag:=AccidentItem.ID;
SetCtrlButtons;
end;

procedure T_Main.DrGr_AccidentListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure T_Main.DrGr_AccidentListTopLeftChanged(Sender: TObject);
begin
//
end;

(**************************************************************************************************)

procedure T_Main.SpB_Tools_AreaLog_Click(Sender: TObject);
   function PrepareXML(var aInfo : string) : string;
   var
     dtStart  : TDateTime;
     dtFinish : TDateTime;
   begin
   dtStart:=Trunc(DTP_Tools_AreaLog_Start.Date);
   dtFinish:=Trunc(DTP_Tools_AreaLog_Finish.Date);
   if dtStart>dtFinish
      then begin
      dtStart:=dtStart+dtFinish;
      dtFinish:=dtStart-dtFinish;
      dtStart:=dtStart-dtFinish;
      end;
   Result:=Format('<REQUEST BEGIN="%s" END="%s"></REQUEST>',[FormatDateTime('yyyymmdd',dtStart),FormatDateTime('yyyymmdd',dtFinish)]);
   aInfo:=Format('%s-%s',[FormatDateTime('dd.mm.yyyy',dtStart),FormatDateTime('dd.mm.yyyy',dtFinish)]);
   end;

   procedure LoadAreaLog;
   var
     prvID: integer;
     xml  : string;
     info : string;
     ln   : integer;
     cs   : boolean;
   begin
   prvID:=AreaLogItem.ID;
   AreaLogItem.Clear;
   SpB_Tools_AreaLog_View.Tag:=0;
   SetCtrlButtons;
   xml:=PrepareXML(info);
   if not AreaLogList.LoadFromDB(xml) then prvID:=-1;
   ln:= Length(AreaLogList.Items);
   if AreaLogList.allArr = allaNone
      then   AreaLogList.Arrange(allaDateEdit, true);
   DrGr_AreaLogList.RowCount:=1+ln+integer(ln=0);
   if prvID>0
    then for ln:=0 to High(AreaLogList.Items)
           do if AreaLogList.Items[ln].ID = prvID
                 then begin
                 SetVisibleRow3(DrGr_AreaLogList,ln+1);
                 if Assigned(DrGr_AreaLogList.OnSelectCell)
                    then DrGr_AreaLogList.OnSelectCell(DrGr_AreaLogList,DrGr_AreaLogList.Col,DrGr_AreaLogList.Row, cs);
                 Exit;
                 end;
   DrGr_AreaLogList.Invalidate;
   end;

   procedure LoadAreaTimeLog;
   begin
   {$MESSAGE 'AreaTimeLog - call load'}
   end;

   procedure AreaLogIntoExel;
   var
    xml  : string;
    info : string;
   begin
   xml:=PrepareXML(info);
   if Length(AreaLogList.Items)=0
      then if not AreaLogList.LoadFromDB(xml) then Exit;
   AreaLogList.IntoExcel(info);
   end;

   procedure AreaTimeLogIntoExel;
   begin
   {$MESSAGE 'AreaTimeLog - into Excel'}
   end;

const
 DataEdit  : boolean = true;
 ResEdit   : boolean = true;
var
 area : string;
 AI   : TAreaItem;
begin
if Sender=SpB_Tools_AreaLog_Load
   then begin
   if SpB_Tools_AreaLog_Load.Parent=TS_AreaLog
      then LoadAreaLog
      else LoadAreaTimeLog ;
   end
   else
if Sender=SpB_Tools_AreaLog_View
   then begin
   if SpB_Tools_AreaLog_View.Tag=0 then Exit;
   try
   if Pos('<AREA_PREV>',Ac2Str(AreaLogItem.xml))>0
      // 20170130 (задалбливает этот messagebox!!!)//then AI.LoadFromXML(Ac2Str(AreaLogItem.xml),MessageBox(Handle,'Есть возможность просмотра предыдущей версии описания области. Использовать эту возможность?','Просмотр области',MB_ICONQUESTION + MB_YESNO)=IDYES)
      then AI.LoadFromXML(Ac2Str(AreaLogItem.xml),ChB_ShowPrevVersion.Checked)
      else AI.LoadFromXML(Ac2Str(AreaLogItem.xml));
   if viaJSObjects
   then begin
   area:=AI.getJSObject;
   if area<>''
      then ExecuteScript(WB, Format('SetArrayOfPolygonNew([%s])',[area]))
      else (*can log why empty*);
   end;
   except
    on E : Exception do LogErrorMessage('T_Main.SpB_Tools_AreaLog_Click',E,['Show Area from Log']);
   end
   end
   else
if Sender=SpB_Tools_AreaLog_Excel
   then begin
   if SpB_Tools_AreaLog_Excel.Parent=TS_AreaLog
      then AreaLogIntoExel
      else AreaTimeLogIntoExel ;
   end
   else ;
end;

procedure T_Main.DrGr_AreaLogListDblClick(Sender: TObject);
begin
SpB_Tools_AreaLog_Click(SpB_Tools_AreaLog_View);
end;

procedure T_Main.DrGr_AreaLogListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
 fc : array[boolean, boolean] of TColor = ((clSilver, clPaleGray),(clWindowText, clHighlightText));
 bc : array[boolean, boolean] of TColor = ((clWindow, clGray)    ,(clWindow    , clHighlight));
 Titles : array[0..6] of string = ('Дата','ID области','Область','User','ФИО','WorkStation','ID');
var
 str : string;
 ind : integer;
 rct : Trect;
 alg : integer;
 sel : boolean;
 fnd : boolean;
 bmp : TBitmap;
 rctA: Trect;
begin
str:='';
alg:=DT_LEFT_ALIGN;
ind:=-1;
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
bmp:=nil;
fnd:=true;
try
case ARow of
 0 : str:=Titles[aCol];
else begin
ind:=ARow-1;
if (ind<Low(AreaLogList.Items)) or ((ind>High(AreaLogList.Items)))
   then begin

   Exit;
   end;
case ACol of
0 : str:=FormatDateTime('dd.mm.yyyy hh:nn:ss',AreaLogList.Items[ind].DateEdit);
1 : str:=FormatFloat('0',AreaLogList.Items[ind].AreaID);
2 : str:=AC2Str(AreaLogList.Items[ind].AreaName);
3 : str:=AC2Str(AreaLogList.Items[ind].user);
4 : str:=AC2Str(AreaLogList.Items[ind].fullname);
5 : str:=AC2Str(AreaLogList.Items[ind].ws);
6 : str:=FormatFloat('0',AreaLogList.Items[ind].ID);
end;

sel:=(gdSelected in State) or (gdFocused in State);
fnd:=(AnsiPos(Ed_Tools_AreaLog_Search.Hint,AnsiUpperCase(str))>0) or (Ed_Tools_AreaLog_Search.Hint='');
DrGr_AreaLogList.Canvas.Font.Color:=fc[fnd, sel];
DrGr_AreaLogList.Canvas.Brush.Color:=bc[fnd, sel];
end;
end;


finally
with DrGr_AreaLogList.Canvas do
  begin
  Windows.FillRect(Handle, Rect, Brush.Handle);
    if ARow=0
       then begin
       FillChar(rctA,SizeOf(TRect),0);
       case AreaLogList.allArr of
       allaDateEdit : rctA:=DrGr_AreaLogList.CellRect(0,0);
       allaAreaID   : rctA:=DrGr_AreaLogList.CellRect(1,0);
       allaAreaName : rctA:=DrGr_AreaLogList.CellRect(2,0);
       allaUser     : rctA:=DrGr_AreaLogList.CellRect(3,0);
       allaFullname : rctA:=DrGr_AreaLogList.CellRect(4,0);
       allaWS       : rctA:=DrGr_AreaLogList.CellRect(5,0);
       allaID       : rctA:=DrGr_AreaLogList.CellRect(6,0);
       end;
       if (*(rctA.Left<>0) and *)(rctA.Right<>0)
          then begin
          rctA.Left:=rctA.Right - 19; rctA.Right:=rct.Right-2;
          SimpleTriAngleOrder(Handle,rctA.Left,rctA.Top+3,not AreaLogList.allDesc,FnCommon.ttobcGray,15);
          end;
       end;
  if ind=-1 then ;
  if Assigned(bmp)then
    begin
    if fnd
       then TransparentBlt(
              Handle
            , Rect.left +(Rect.Right - Rect.left)div 2 - bmp.Width div 2
            , Rect.Top +(Rect.Bottom - Rect.Top)div 2 -  bmp.Height div 2
            , bmp.Width
            , bmp.Height
            , bmp.Canvas.Handle
            , 0
            , 0
            , bmp.Width
            , bmp.Height
            , ColorToRGB(clFuchsia)
            )
       else AlphaBlt(
              Handle
            , Rect.left +(Rect.Right - Rect.left)div 2 - bmp.Width div 2
            , Rect.Top +(Rect.Bottom - Rect.Top)div 2 - bmp.Height div 2
            , bmp.Width
            , bmp.Height
            , bmp.Canvas.Handle
            , 0
            , 0
            , bmp.Width
            , bmp.Height
            ,80
            );
    str:='';
    end;
  DrawTransparentText(Handle, str, rct, alg);
  end;
bmp.Free;
end;
end;

procedure T_Main.DrGr_AreaLogListFixedCellClick(Sender: TObject; ACol, ARow: Integer);
var
 newALLA     : TAreaLogListArrange;
 cs          : boolean;
 CurID       : integer;
 CurInd      : integer;
begin
try
CurID:=0;
CurInd:=DrGr_AreaLogList.Row-1;
if (CurInd>=Low(AreaLogList.Items)) and (CurInd<=High(AreaLogList.Items))
   then CurID:=AreaLogList.Items[CurInd].ID; // -- в принципе, есть AreaLogItem...
case ACol of
  0  : newALLA:=allaDateEdit;
  1  : newALLA:=allaAreaID;
  2  : newALLA:=allaAreaname;
  3  : newALLA:=allaUser;
  4  : newALLA:=allaFullName;
  5  : newALLA:=allaWS;
  6  : newALLA:=allaID;
else newALLA:=allaNone;
end;
if newALLA=allaNone then Exit;
if newALLA=AreaLogList.allArr
   then AreaLogList.allDesc:=not AreaLogList.allDesc
   else AreaLogList.allArr:=newALLA;
AreaLogList.Arrange(AreaLogList.allArr,AreaLogList.allDesc);
if (CurID<>0)
   then begin
   for CurInd:=0 to High(AreaLogList.Items)
      do if (AreaLogList.Items[CurInd].ID=CurID)
            then begin
            SetVisibleRow3(DrGr_AreaLogList,CurInd+1);
            Break;
            end;
   end;
if Assigned(DrGr_AreaLogList.OnSelectCell)
   then DrGr_AreaLogList.OnSelectCell(DrGr_AreaLogList,DrGr_AreaLogList.Col,DrGr_AreaLogList.Row,cs);
DrGr_AreaLogList.Repaint;
except
  on E : Exception do LogErrorMessage('_Main.DrGr_AreaLogListFixedCellClick',E,[ACol, ARow]);
end;
end;

procedure T_Main.DrGr_AreaLogListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
 ind : integer;
begin
AreaLogItem.Clear;
ind:=ARow-1;
if (ind>=Low(AreaLogList.Items)) and (ind<=High(AreaLogList.Items))
   then AreaLogItem.LoadFromSource(AreaLogList.Items[ind]);
SpB_Tools_AreaLog_View.tag:=AreaLogItem.ID;
SetCtrlButtons;
end;

procedure T_Main.DrGr_AreaLogListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure T_Main.DrGr_AreaLogListTopLeftChanged(Sender: TObject);
begin
//
end;


procedure T_Main.PM_Tools_DTP_FilterPopup(Sender: TObject);
begin
N_Tools_DTP_Filter_Empty.Checked:=Lab_Accident_OnlyEmpty.Visible;
N_Tools_DTP_Filter_Days.Checked:=DTP_Tools_DTP_Start.Visible;
end;


procedure T_Main.Tools_DTP_Filter_SelectMode(Sender: TObject);
var
 mi      : TMenuItem;
 byDays  : boolean;
 byEmpty : boolean;
begin
mi:=nil;
if Sender is TMenuItem
   then mi:=(Sender as TMenuItem);
if not Assigned(mi) then Exit;
byDays:=(mi = N_Tools_DTP_Filter_Days);
byEmpty:=(mi = N_Tools_DTP_Filter_Empty);
Lab_Accident_Days.Visible:=byDays;
DTP_Tools_DTP_Start.Visible:=byDays;
DTP_Tools_DTP_Finish.Visible:=byDays;
Lab_Accident_OnlyEmpty.Visible:=byEmpty;
mi.Checked:=True;
end;


(*** IntervalEx procedures ************************************************************************)

type
 TIntNoteItem = record
  osStart  : integer;
  osFinish : integer;
 end;

 PSchemeNoteItem = ^TSchemeNoteItem;
 TSchemeNoteItem = record
   id      : array[1..39] of char; // +1 for tail zero-char
   Name    : array[1..250] of char;
   Date    : TDateTime;
   Days    : integer;
   Step    : TDTInterval;
   Items   : array of TIntNoteItem;
 end;


var
 colDelBtn : integer = 4;
 prevName  : string = 'Новая схема';
procedure T_Main.DTI_Create(aDateStart, aDateFinish : TDateTime; aIntervals : array of TPairDateTime);
var
 cnt : integer;
 cs  : boolean;
begin
dti_DateStart:=aDateStart; // std
if dti_DateStart<date+5
   then dti_DateStart:=date+5;
if aDateFinish<dti_DateStart
   then aDateFinish:=dti_DateStart;
if Trunc(aDateFinish)-Trunc(dti_DateStart)<SE_days.Value
   then dti_DateFinish:=Trunc(aDateFinish)+SE_days.Value-1;
dti_DateFinish:=Trunc(dti_DateFinish)+EncodeTime(23,59,59,997); // std
DTI:=TDateTimeInterval.CreateMain(
       self
      ,dti_DateStart
      ,dti_DateFinish
      ,dtInterval
      ,MaxIntervalCount
);
with DTI do
 begin
 Parent:=SzPan_IntervalSchemeEx;
 Left:=4;
 Top:=LabT_Info.Top+LabT_Info.Height+4;
 Width:=Parent.ClientWidth - Left*2;
 Height:=sliderSize*5;// -- рекомендуемый размер
 Anchors:=[akLeft,akTop,akRight];
 DTI.DoubleBuffered:=true;
 for cnt:=0 to High(aIntervals)
   do begin
   if aIntervals[cnt].Direct
      then DTI.AddInterval(aIntervals[cnt].Start
                         , aIntervals[cnt].Finish)
      else DTI.AddInterval(aIntervals[cnt].Anchor+MinutesToDateTime(aIntervals[cnt].offsetStartMin)
                        , aIntervals[cnt].Anchor+MinutesToDateTime(aIntervals[cnt].offsetFinishMin));
   end;
 DTI.onUpdated:=DTI_Updated;
 DTI_Updated(DTI,DTI.LastUpdated);
 end;
with PC_IntervalView do
  begin
  Left:=DTI.Left;
  Top:=DTI.Top+DTI.Height+4;
  Height:=Parent.ClientHeight-Top;
  Width:=Parent.ClientWidth-Left*2;
  end;
DrGr_DTISelectCell(DrGr_DTI,DrGr_DTI.Col,DrGr_DTI.Row,cs);
DTP_SchemeBegin.MinDate:=date+5;
DTP_SchemeBegin.DateTime:=dti_dateStart;
DTP_SchemeEnd.DateTime:=dti_dateStart;
DTP_SchemeEnd.MinDate:=DTP_SchemeBegin.MinDate;
end;


procedure T_Main.DTI_SetArea;
begin
case CurObject.idType of
aiitArea : Lab_Area.Caption:=IfThen(CurObject.id=0,'Область не выбрана',string(Area.aName));
aiitPVZ  : Lab_Area.Caption:=IfThen(CurObject.id=0,'ПВЗ не выбран',PVZList.GetDescriptionByID(CurObject.id));
end;
RefreshScheme(Lab_Area);
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure T_Main.DTI_Updated(Sender : TObject; aIndex : integer);
var
 ln : integer;
 cs : boolean;
begin
ln:=Length(DTI.Sliders);
DrGr_DTI.RowCount:=1+ln+integer(ln=0);
DrGr_DTI.Invalidate;
SpB_DelInterval.Enabled:=(aIndex>=Low(DTI.Sliders)) and (aIndex<=High(DTI.Sliders));
if SpB_DelInterval.Enabled and DrGr_DTI.CanFocus and SetFocusedControl(DrGr_DTI)
   then begin
   DrGr_DTI.SetFocus;
   cs:=true;
   DrGr_DTISelectCell(DrGr_DTI,DrGr_DTI.Col,DrGr_DTI.Row,cs);
   end;
DTI_ShowInfo;
end;


procedure T_Main.DTP_DTI_Change(Sender: TObject);
begin
if Assigned(DTI)
   then begin
   dti_DateFinish:=dti_DateStart+SE_days.Value-1;
   DTI.CallRecalcIntervals(dti_DateStart,Trunc(dti_DateFinish)+EncodeTime(23,59,59,997),dtInterval);
   DTI_Updated(DTI,-1);
   RefreshScheme(Sender);
   end;
DTI_ShowInfo;
end;


procedure T_Main.DTI_Edit(Sender: TObject);
var
 ind : integer;
 dlt : TTime;
 dtS : TDateTime;
 dtF : TDateTime;
 msg : string;
begin
if not Assigned(DTI) then Exit;
if Sender=SpB_AddInterval
   then begin
   if Length(DTI.Sliders)=DTI.MaxCount
      then begin
      ShowMessageInfo(Format('Достигнуто максимальное количество интервалов (%d).'#13'Дальнейшее добавление невозможно',[DTI.MaxCount]),'Добавление интервала');
      Exit;
      end;
   dlt:=MinutesToTime(cardinal(DTI.IntervalType)*3);
   dtS:=MinutesToDateTime(DTI.MinValue) + dlt;
   dtF:=MinutesToDateTime(DTI.MaxValue) - dlt;
   ind:=DTI.AddInterval(dtS,dtF);
   DTI.UpdateCrossList;
   DTI_Updated(DTI,ind);
   end
   else
if (Sender=SpB_DelInterval) or (Sender=SpB_DelInterval_DrGr)
  then begin
  if Sender=SpB_DelInterval       then ind:=DTI.LastUpdated else
  if Sender=SpB_DelInterval_DrGr  then ind:=DrGr_DTI.Row-1 else ind:=-1;
  if (ind>=Low(DTI.Sliders)) and (ind<=High(DTI.Sliders))
     then begin
     with DTI.Sliders[ind] do
     msg:=IntToStr(Trunc(Start.DateTime - dti_dateStart)+1)+'»' + FormatDateTime(' hh:nn',Start.DateTime)+' - '+
          IntToStr(Trunc(Finish.DateTime - dti_dateStart)+1)+'»' + FormatDateTime(' hh:nn',Finish.DateTime);
     end
     else Exit;
  if MessageBox(Handle,PChar(Format('Интервал №%d (%s) будет удален. Подтверждаете?',[ind+1,msg])),'Удаление интервала',MB_ICONQUESTION+MB_YESNO+MB_DEFBUTTON2)=IDNO
     then Exit;
  DTI.DeleteInterval(ind);
  if Length(DTI.Sliders)>0
     then begin
     DTI_Scale;
     DTI_Updated(DTI,0);
     end
     else DTI_Updated(DTI,-1);
  RefreshScheme(self);
  end
  else
if Sender=SpB_SaveInterval
  then begin
  msg:=prevName;
  if InputQuery('Сохранение схемы','Наименование',msg)
     then DTI_SaveLocal(msg, DTI.getXML);
  end
 else
if Sender=SpB_LoadInterval
  then begin
  DTI_LoadLocal;
  end
 else
if Sender=BB_DTI_Close
  then begin
  SaveSize(SzPan_IntervalSchemeEx,AppParams.CFGUserFileName);
  if SzPanPosList.IsOut(SzPan_IntervalSchemeEx)
     then SzPanPosList.SetIn(SzPan_IntervalSchemeEx);
  SzPan_IntervalSchemeEx.Hide;
  end;
;
DTI_ShowInfo;
RefreshScheme(DTI);
end;


procedure T_Main.DTI_Resize(Sender: TObject);
begin
LockWindowUpdate(SzPan_IntervalSchemeEx.Handle);
try
if Assigned(DTI) then DTI_Scale;
finally
LockWindowUpdate(0);
end;
end;


procedure T_Main.DrGr_DTIDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
 fc : array[boolean] of TColor    = (clWindowText, clHighlightText);
 bc : array[boolean] of TColor    = (clWindow, clHighlight);
 titles : array[0..4] of string   = ('','Начало','Окончание','Длительность','');
 szInd : integer = 13;
var
 ind : integer;
 str : string;
 rct : TRect;
 sel : boolean;
 alg : integer;
 _d  : integer;
 _t  : TTime;
 ndt : TDate;
begin
ndt:=Trunc(MinutesToDateTime(DTI.MinValue));
ind:=-1;
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
str:='';
alg:=DT_LEFT_ALIGN;
try

case ARow of
0  :str:=titles[ACol];
else begin
sel:=(gdFocused in State) or (gdSelected in State);
with DrGr_DTI.Canvas
  do begin
  Font.Color:=fc[sel];
  Brush.Color:=bc[sel];
  end;
ind:=ARow-1;
if not Assigned(DTI) or (Assigned(DTI) and ((ind<Low(DTI.Sliders)) or (ind>High(DTI.Sliders))))
   then begin
   ind:=-1;
   Exit;
   end;
with DTI.Sliders[ind] do
case ACol of
0 : ;
1 : str:=Format('%d>> %s',[trunc(Start.DateTime-ndt+1), FormatdateTime('hh:nn',Start.DateTime)]); //str:=FormatdateTime('dd.mm.yyyy hh:nn',DTI.Sliders[ind].Start.DateTime);
2 : str:=Format('%d>> %s',[trunc(Finish.DateTime-ndt+1), FormatdateTime('hh:nn',Finish.DateTime)]);//str:=FormatdateTime('dd.mm.yyyy hh:nn',DTI.Sliders[ind].Finish.DateTime);
3 : begin
    GetWorkTime(0,Duration,_d,_t,str);
    alg:=DT_RIGHT_ALIGN;
    end;
end;
end
end;

finally
with DrGr_DTI.Canvas do
  begin
  Windows.FillRect(Handle,Rect,Brush.Handle);
  DrawTransparentText(Handle,str,rct,alg);
  if (ACol=0) and (ARow=0)
     then begin
     IL_Paint.DrawingStyle:=dsTransparent;
     IL_Paint.Draw(DrGr_DTI.Canvas
                  ,Rect.Left + (Rect.Right - Rect.Left - IL_Paint.Width) div 2
                  ,Rect.Top + (Rect.Bottom - Rect.Top - IL_Paint.Height) div 2
                  ,17);
     end
     else
  if (ind>-1) and (ARow>0) and (ACol=0)
     then begin
     if ind=DTI.LastUpdated
        then begin
        rct:=Bounds(Rect.Left+(Rect.Right-Rect.Left-szInd) div 2, Rect.Top+(Rect.Bottom-Rect.Top-szInd) div 2, szInd, szInd);
        GradientFigure(Handle,gfTriangleRight,rct,clBlue,'',clYellow,false);
        end;
     end;

  end;
end;
end;


procedure T_Main.DrGr_DTIFixedCellClick(Sender: TObject; ACol, ARow: Integer);
var
 cnt  : integer;
 ndt  : TDate;
 strl : TStringList;
 ind  : integer;
 res  : string;
 sday : integer;
 fday : integer;
begin
if (ACol=0) and (ARow=0)
   then begin
   res:='';
   ndt:=Date;
   strl:=TStringList.Create;
   try
   strl.Sorted:=true;
   for cnt:=0 to High(DTI.Sliders)
     do with DTI.Sliders[cnt]
         do strl.AddObject(Format('%s.%s-%s.%s',[
                             FormatFloat('00', trunc(Start.DateTime-ndt+1))
                            ,FormatDateTime('hhnnss',Start.DateTime)
                            ,FormatFloat('00', trunc(Finish.DateTime-ndt+1))
                            ,FormatDateTime('hhnnss',Finish.DateTime)
                            ]),TObject(cnt+1));

   for cnt:=0 to strl.Count-1
     do begin
     ind:=integer(strl.Objects[cnt])-1;

     with DTI.Sliders[ind]
       do begin
       sday := trunc(Start.DateTime-ndt+1);
       fday := trunc(Finish.DateTime-ndt+1);
       res:=res+Format('   * %s %s - %s %s',[
                             FormatFloat('0',sday)+GetDefUnit(sday,dfOrder)+' день'
                            ,FormatDateTime('hh:nn',Start.DateTime)
                            ,FormatFloat('0',fday)+GetDefUnit(fday,dfOrder)+' день'
                            ,FormatDateTime('hh:nn',Finish.DateTime)
                            ])+crlf;
       end;
     end;
   res:=Lab_Area.Caption+crlf+
        Format('Период %d %s',[SE_Days.Value, GetDefUnit(SE_Days.Value, dfDay)])+crlf+
        'Список интервалов:'+crlf+
        res;
   ShowMessageInfo(res,'Описание схемы');
   finally
   FreeStringList(strl);
   end;
   end;
end;

procedure T_Main.DTI_DrGr_ShowDelButton;
var
 ARow : integer;
 ind : integer;
 rct : TRect;
begin
if SpB_DelInterval_DrGr.Parent<>DrGr_DTI
   then SpB_DelInterval_DrGr.Parent:=DrGr_DTI;
ARow:=DrGr_DTI.Row;
ind:=ARow-1;
if (ind>=Low(DTI.Sliders)) and (ind<=High(DTI.Sliders))
   then begin
   rct:=DrGr_DTI.CellRect(colDelBtn,ARow);
   rct:=Bounds(rct.Left, rct.Top, 25, rct.Bottom - rct.Top);
   SpB_DelInterval_DrGr.BoundsRect:=rct;
   if not SpB_DelInterval_DrGr.Visible
      then SpB_DelInterval_DrGr.Show;
   end;
SpB_DelInterval_DrGr.Hint:='Удаление текущего интервала';
SpB_DelInterval_DrGr.ShowHint:=true;
end;


procedure T_Main.DTI_ShowInfo;
var
 cnt    : integer;
 cntInt : integer;
 dtInt  : TDateTime;
 _days  : integer;
 _time  : TTime;
 _msg   : string;
begin
cntInt:= 0;
dtInt := 0;
if Assigned(DTI)
   then begin
   for cnt:=0 to High(DTI.Sliders)
     do begin
     dtInt:=dtInt+DTI.Sliders[cnt].Duration;
     inc(cntInt);
     end;
   GetWorkTime(0,dtInt,_days,_time,_msg);
   end;
SpB_SaveInterval.Enabled:=(cntInt>0);
LabT_Info.Caption:=Format('Полных суток: %d, Интервалов: %d (%s)',[
     Trunc(dti_DateFinish) - Trunc(dti_DateStart)+1
    ,cntInt
    ,_msg
    ]);
if (DTI.LastUpdated>=low(DTI.Sliders)) and (DTI.LastUpdated<=high(DTI.Sliders))
   then RefreshScheme(DTI.Sliders[DTI.LastUpdated].Start)
   else RefreshScheme(DTI);
end;

procedure T_Main.DTI_SaveLocal(const aName, aXML : string);
var
 dts     : TDateTime;
 dir     : string;
 xmlBody : string;
 xmlFile : string;
begin
dts:=Now;
try
xmlBody:= XMLTitleWIN1251+'<SCHEME>'+crlf+Format('<HEAD ID="%s" NAME="%s" DATE="%s"/>'+crlf,[CreateUUID, Str2XML(aName),FormatDateTime('yyyymmdd hh:nn',dts)])+aXML+crlf+'</SCHEME>';
dir:= SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'Schemes2\';
if not DirectoryExists(dir)
   then if not ForceDirectories(dir)
           then dir:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName));
xmlFile:=dir+Format('%s от %s',[NormalizeStringSysPath(aName), FormatDateTime('ddmmyyyy hhnn',dts)])+'.xml';
SaveStringIntoFileStream(xmlBody,xmlFile);
except
  on E : Exception do
     begin
     CopyStringIntoClipboard(xmlBody);
     LogErrorMessage('T_Main.DTI_SaveLocal',E,[aName, FormatDateTime('yyyymmdd hh:nn',dts)]);
     ShowMessageError(Format('Не удалось сохранить схему интервалов "%s" (Ошибка "%s").'+crlf+'Описание схемы в формате XML находится в буфере обмена.',[aName,E.Message]),'Ошибка при сохранении схемы');
     end;
end;
end;


procedure T_Main.DTI_LoadLocal;
  function ClearParamStr(const aSrc : string) : string;
  begin
  Result:=DaggerChar+StringReplace(Copy(aSrc,Pos('[',aSrc)+1,Length(aSrc)),']',DaggerChar,[]);
  end;

  function GetStringValue(const aSrc,aParam : string) : string;
  var
   psA,psB : integer;
  begin
  psA:=Pos(DaggerChar+aParam+BulletChar, aSrc)+Length(aParam)+2;
  psB:=PosEx(DaggerChar,aSrc,psA);
  Result:=Copy(aSrc,psA,psB-psA);
  end;

  function GetIntegerValue(const aSrc,aParam : string)  :integer;
  var
   psA,psB : integer;
  begin
  psA:=Pos(DaggerChar+aParam+BulletChar, aSrc)+Length(aParam)+2;
  psB:=PosEx(DaggerChar,aSrc,psA);
  Result:=StrToIntDef(Copy(aSrc,psA,psB-psA),0);
  end;

var
 dir     : string;
 xmlFile : string;
 xmlBody : string;
 sda     : TStringDynArray;
 cnt     : integer;
 SNI     : TSchemeNoteItem;
 dtS     : TDateTime;
 dtF     : TDateTime;
 ind     : integer;
begin
try
dir:= SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'Schemes2\';
if not DirectoryExists(dir)
   then if not ForceDirectories(dir)
           then dir:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName));
xmlFile:=dir;
if SelectFileName(xmlFile,'XML файлы(*.xml)|*.xml|Все файлы(*.*)|*.*',false)
   then xmlBody:=LoadStringFromFile(xmlFile)
   else Exit;
if xmlBody='' then Exit;
if pos('<?xml',xmlBody)=0 then xmlBody:=XMLTitleWIN1251+xmlBody;

ExtractTagStrings(xmlBody,'HEAD',sda);
if Length(sda)>0
   then begin
   sda[0]:=ClearParamStr(sda[0]);
   Str2AC(GetStringValue(sda[0],'ID'),SNI.id);
   Str2AC(GetStringValue(sda[0],'NAME'),SNI.Name);
   SNI.Date:=StrToDateTimeByFormat(GetStringValue(sda[0],'DATE'),'yyyymmdd hh:nn');
   end;
Setlength(sda,0);
if (AC2Str(SNI.id)='') and (AC2Str(SNI.Name)='')
   then begin
   ShowMessageInfo(Format('В выбранном файле "%s" отсутвуют необходимые данные',[xmlFile])+crlf+
                   'Вероятно это файл со схемой предыдущей версии.'+crlf+
                   'Загрузка схемы остановлена.','Загрузка схемы');
   Exit;
   end;

ExtractTagStrings(xmlBody,'INTERVALS',sda);
if Length(sda)>0
   then begin
   sda[0]:=ClearParamStr(sda[0]);
   SNI.Days:=GetIntegerValue(sda[0],'DAYS');
   SNI.Step:=TDTInterval(GetIntegerValue(sda[0],'STEP'));
   end;
Setlength(sda,0);

SE_Days.onChange:=nil;
try
SE_Days.Value:=SNI.Days;
finally
SE_Days.onChange:=DTP_DTI_Change;
end;

ExtractTagStrings(xmlBody,'I',sda);
Setlength(SNI.Items, Length(sda));
for cnt:=0 to High(sda)
  do begin
  sda[cnt]:=ClearParamStr(sda[cnt]);
  SNI.Items[cnt].osStart:=GetIntegerValue(sda[cnt],'OS');
  SNI.Items[cnt].osFinish:=GetIntegerValue(sda[cnt],'OF');
  if (SNI.Items[cnt].osStart>0) and (SNI.Items[cnt].osFinish>0) then ;
  end;
Setlength(sda,0);

for cnt:=High(DTI.Sliders) downto 0
  do DTI.DeleteInterval(cnt);
DTI_Updated(DTI,-1);
dtInterval:=SNI.Step;
dti_DateStart:=Date;
dti_DateFinish:=dti_DateStart+SNI.Days-EncodeTime(0,0,0,3);
DTI.CallRecalcIntervals(dti_DateStart,dti_DateFinish,dtInterval);
for cnt:=0 to High(SNI.Items)
  do begin
  dtS:=dti_DateStart+MinutesToDateTime(SNI.Items[cnt].osStart);
  dtF:=dti_DateStart+MinutesToDateTime(SNI.Items[cnt].osFinish);
  ind:=DTI.AddInterval(dtS,dtF);
  DTI.UpdateCrossList;
  DTI_Updated(DTI,ind);
  end;
DTI_Updated(DTI,-1);

except
  on E : Exception do  LogErrorMessage('T_Main.DTI_LoadLocal',E,[]);
end;
end;

procedure T_Main.DTI_Scale;
  function ClearParamStr(const aSrc : string) : string;
  begin
  Result:=DaggerChar+StringReplace(Copy(aSrc,Pos('[',aSrc)+1,Length(aSrc)),']',DaggerChar,[]);
  end;

  function GetStringValue(const aSrc,aParam : string) : string;
  var
   psA,psB : integer;
  begin
  psA:=Pos(DaggerChar+aParam+BulletChar, aSrc)+Length(aParam)+2;
  psB:=PosEx(DaggerChar,aSrc,psA);
  Result:=Copy(aSrc,psA,psB-psA);
  end;

  function GetIntegerValue(const aSrc,aParam : string)  :integer;
  var
   psA,psB : integer;
  begin
  psA:=Pos(DaggerChar+aParam+BulletChar, aSrc)+Length(aParam)+2;
  psB:=PosEx(DaggerChar,aSrc,psA);
  Result:=StrToIntDef(Copy(aSrc,psA,psB-psA),0);
  end;

var
 xmlBody : string;
 sda     : TStringDynArray;
 cnt     : integer;
 SNI     : TSchemeNoteItem;
 dtS     : TDateTime;
 dtF     : TDateTime;
 ind     : integer;
begin
try
xmlBody:= XMLTitleWIN1251+'<SCHEME>'+crlf+Format('<HEAD ID="%s" NAME="%s" DATE="%s"/>'+crlf,[CreateUUID, Str2XML('ResizeProcess'),FormatDateTime('yyyymmdd hh:nn',now)])+DTI.GetXML+crlf+'</SCHEME>';
//ExtractTagStrings(xmlBody,'HEAD',sda);
//if Length(sda)>0
//   then begin
//   sda[0]:=ClearParamStr(sda[0]);
//   Str2AC(GetStringValue(sda[0],'ID'),SNI.id);
//   Str2AC(GetStringValue(sda[0],'NAME'),SNI.Name);
//   SNI.Date:=StrToDateTimeByFormat(GetStringValue(sda[0],'DATE'),'yyyymmdd hh:nn');
//   end;
//Setlength(sda,0);
ExtractTagStrings(xmlBody,'INTERVALS',sda);
if Length(sda)>0
   then begin
   sda[0]:=ClearParamStr(sda[0]);
   SNI.Days:=GetIntegerValue(sda[0],'DAYS');
   SNI.Step:=TDTInterval(GetIntegerValue(sda[0],'STEP'));
   end;
Setlength(sda,0);
ExtractTagStrings(xmlBody,'I',sda);
Setlength(SNI.Items, Length(sda));
for cnt:=0 to High(sda)
  do begin
  sda[cnt]:=ClearParamStr(sda[cnt]);
  SNI.Items[cnt].osStart:=GetIntegerValue(sda[cnt],'OS');
  SNI.Items[cnt].osFinish:=GetIntegerValue(sda[cnt],'OF');
  if (SNI.Items[cnt].osStart>0) and (SNI.Items[cnt].osFinish>0) then ;
  end;
Setlength(sda,0);
LockWindowUpdate(DTI.Handle);
try
for cnt:=High(DTI.Sliders) downto 0
  do DTI.DeleteInterval(cnt);
DTI_Updated(DTI,-1);
dtInterval:=SNI.Step;
dti_DateStart:=Date;
dti_DateFinish:=dti_DateStart+SNI.Days-EncodeTime(0,0,0,3);
DTI.CallRecalcIntervals(dti_DateStart,dti_DateFinish,dtInterval);
for cnt:=0 to High(SNI.Items)
  do begin
  dtS:=dti_DateStart+MinutesToDateTime(SNI.Items[cnt].osStart);
  dtF:=dti_DateStart+MinutesToDateTime(SNI.Items[cnt].osFinish);
  ind:=DTI.AddInterval(dtS,dtF);
  if ind>-1 then ;
  end;
DTI.UpdateCrossList;
DTI_Updated(DTI,-1);
finally
LockWindowUpdate(0);
end;
except
  on E : Exception do  LogErrorMessage('T_Main.DTI_Scale',E,[]);
end;
end;


procedure T_Main.DrGr_DTIMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
if DrGr_DTI.ColWidths[colDelBtn]<>25 then DrGr_DTI.ColWidths[colDelBtn]:=25;
DTI_DrGr_ShowDelButton;
end;


procedure T_Main.DrGr_DTISelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
 ind : integer;
 rct : TRect;
begin
if not Assigned(DTI)
   then Exit;
ind:=ARow-1;
if (ind>=Low(DTI.Sliders)) and (ind<=High(DTI.Sliders))
   then begin
   if SpB_DelInterval_DrGr.Parent<>DrGr_DTI
      then SpB_DelInterval_DrGr.Parent:=DrGr_DTI;
   rct:=DrGr_DTI.CellRect(colDelBtn,ind+1);
   rct:=Bounds(rct.Left, rct.Top, 25, rct.Bottom - rct.Top);
   SpB_DelInterval_DrGr.BoundsRect:=rct;
   if not SpB_DelInterval_DrGr.Visible
      then SpB_DelInterval_DrGr.Show;
   end;
end;


procedure T_Main.DrGr_DTITopLeftChanged(Sender: TObject);
begin
DTI_DrGr_ShowDelButton;
end;



procedure T_Main.DrGr_DTLDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
 BrErr    : array[boolean] of TColor = (clWhite     , clinfoBk);
 FnErr    : array[boolean] of TColor = (clRed       , clRed);
 Br       : array[boolean] of TColor = (clWindow    , clHighlight);
 Fn       : array[boolean] of TColor = (clWindowText, clHighlightText);
 TitleErr : array[0..0] of string = ('Описание ошибки');
 Title    : array[0..2] of string = ('Начало','Окончание','Ok');
var
 str  :string;
 rct : TRect;
 txt : TRect;
 alg : integer;
 ind : integer;
 err : boolean;
 sel : boolean;
 bmp : TBitmap;
 dc  : hDC;

begin
bmp:=nil;
err:=Length(dtlErrors)>0;
str:='';
if err
   then begin
   rct:=DrGr_DTL.CellRect(DrGr_DTL.LeftCol,ARow);
   ind:=0;
   alg:=DrGr_DTL.LeftCol;
   while alg>0
     do begin
     ind:=ind+DrGr_DTL.ColWidths[alg];
     dec(alg);
     end;
   rct.Left:=rct.Left-ind;
   rct.Right:=rct.Left+DrGr_DTL.GridWidth;
   end
   else System.Move(Rect,rct,SizeOf(TRect));
txt:=Classes.Rect(rct.Left+2, rct.Top+1, rct.Right-2, rct.Bottom-1);
alg:=DT_LEFT_ALIGN;
try
sel:=(gdSelected in State) or (gdFocused in State);
DrGr_DTL.Canvas.Font.Color:=clWindowText;
if err
   then begin
   case ARow of
   0 : str:=TitleErr[0];
   else begin
   with DrGr_DTL.Canvas do
     begin
     Brush.Color:=BrErr[sel];
     Font.Color:=FnErr[sel];
     end;
   ind:=Arow-1;
   if (ind>=Low(dtlErrors)) and (ind<=High(dtlErrors))
      then str:=dtlErrors[ind];
   end;
   end;

   end
   else begin
   case ARow of
   0 : str:=Title[aCol];
   else begin
   with DrGr_DTL.Canvas do
     begin
     Brush.Color:=Br[sel];
     Font.Color:=Fn[sel];
     end;
   ind:=Arow-1;
   if (ind>=Low(DTL)) and (ind<=High(DTL))
      then begin
      case ACol of
      0 : str:=FormatDateTime('dd.mm.yyyy hh:nn',DTL[ind].DateBegin);
      1 : str:=FormatDateTime('dd.mm.yyyy hh:nn',DTL[ind].DateEnd);
      2 : begin
          str:='';
          bmp:=TBitmap.Create;
          IL_Interval.GetBitmap(8 +integer(DTL[ind].IsOn),bmp);
          end;
      end;
      end;
   end;
   end;
   end;


finally
with DrGr_DTL do
  begin
  Windows.FillRect(Canvas.Handle,rct,Canvas.Brush.Handle);
  DrawTransparentText(Canvas.Handle,str,txt,alg);
  if Assigned(bmp)
     then begin
     txt:=Bounds(txt.Left + (txt.Right-txt.Left - bmp.Width) div 2, txt.Top + (txt.Bottom-txt.Top - bmp.Height) div 2, bmp.Width, bmp.Height);
     TransparentBlt(Canvas.Handle, txt.Left, txt.Top, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0,0,bmp.Width, bmp.Height, bmp.Canvas.Pixels[0,bmp.Height-1]);
     bmp.Free;
     end;
  end;
end;


   dc:=GetDC(DrGr_DTL.Handle);
   try
   DrGr_DTL.Canvas.Brush.Color:=clWindow;
   //rct:=Classes.Rect(DrGr_DTL.GridWidth,0,DrGr_DTL.ClientWidth,DrGr_DTL.ClientHeight);
   //DrawFrameControl(dc,rct,DFC_BUTTON,DFCS_BUTTONPUSH) ;
   rct:=DrGr_DTL.CellRect(DrGr_DTL.ColCount-1,ARow);
   rct.Left:=DrGr_DTL.GridWidth;
   rct.Right:=DrGr_DTL.ClientWidth;
   //FnCommon.SimpleTriAngleRight(dc,rct.Top, rct.Left, true);
   if ARow=DrGr_DTL.Row
    then DrawFrameControl(dc,rct,DFC_BUTTON,DFCS_BUTTONPUSH (*or DFCS_MONO or DFCS_PUSHED*))
    else FillRect(dc,rct,DrGr_DTL.Canvas.Brush.Handle);
    //InvalidateRect(DrGr_DTL.Handle,rct,longbool(true));
   finally
   ReleaseDC(DrGr_DTL.Handle,dc);
   end;

end;


var
 colwidths : array of integer;

procedure T_Main.DrGr_DTLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
 gc  : TGridCoord;
 cnt : integer;
begin
if ssLeft in Shift
   then begin
   gc:=DrGr_DTL.MouseCoord(X,Y);
   if gc.Y=0
     then begin
     SetLength(colwidths,DrGr_DTL.ColCount);
     for cnt:=0 to High(colwidths)
        do colwidths[cnt]:=DrGr_DTL.ColWidths[cnt];
     end;
   end;
end;

procedure T_Main.DrGr_DTLMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 gc  : TGridCoord;
 cnt : integer;
 nsv : boolean;
begin
gc:=DrGr_DTL.MouseCoord(X,Y);
if gc.Y=0
   then begin
   nsv:=Length(colwidths)<>DrGr_DTL.ColCount;
   if not nsv
      then for cnt:=0 to High(colwidths)
             do if colwidths[cnt]<>DrGr_DTL.ColWidths[cnt]
                   then begin
                   nsv:=true;
                   Break;
                   end;
   if nsv
      then if DrGr_DTL.ColCount=1
              then SaveColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'ErrorMode')
              else SaveColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'NormalMode');
   end;
DrGr_DTL.Repaint;
end;

procedure T_Main.DrGr_DTLTopLeftChanged(Sender: TObject);
begin
DrGr_DTL.Repaint;
end;


procedure T_Main.TS_SchemeResize(Sender: TObject);
begin
DrGr_DTL.Repaint;
end;



function T_Main.DTL_GetXML(*(aAreaID : integer)*) : string;
type
 TOffsetInterval = record
   Start    : TDateTime;
   Length   : TDateTime;
 end;
const
 bool : array[boolean] of char = ('0','1');
 sqlZeroDate : integer = 2;   // 01.01.1900
 dtRnd       : integer = -10; // округление TdateTime для последующего сравнения
var
 cnt     : integer;
 OIL     : array of TOffsetInterval;
 BaseDate: TDate;
 minDate : TDate;
 maxDate : TDate;
 ind     : integer;
 AreaID  : integer;
 AreaType: TAreaIntervalIdType;
begin
Result:='';
try
AreaID:=CurObject.id;
AreaType:=CurObject.idType;
SetLength(OIL, 0);
minDate:=EncodeDate(2099,12,31);
maxDate:=EncodeDate(2000,1,1);
for cnt:=0 to High(DTL)
  do begin
  if not DTL[cnt].IsOn then Continue;
  ind:=Length(OIL);
  SetLength(OIL,ind+1);
  BaseDate:=Trunc(DTL[cnt].DateBegin);
  if BaseDate>maxDate then maxDate:=BaseDate;
  if BaseDate<minDate then minDate:=BaseDate;
  OIL[ind].Start := DTL[cnt].DateBegin;
  OIL[ind].Length:= DTL[cnt].DateEnd-DTL[cnt].DateBegin;
  end;
for cnt:=0 to High(OIL)
    do Result:=Result+Format(AIL_xmlItemNew,[
      0
     ,AreaID
     ,FormatDateTime('yyyymmdd hh:nn',RoundTo(OIL[cnt].Start,dtRnd))
     ,FormatDateTime('yyyymmdd hh:nn',RoundTo(sqlZeroDate+OIL[cnt].Length, dtRnd))
     ,integer(AreaType)
     ]);
Result:=Format(AIL_xmlHeader,[AIL_xmlBase, AppParams.UserName, FormatDateTime('yyyymmdd',minDate), FormatDateTime('yyyymmdd',maxDate),AreaID, integer(AreaType)])+crlf+Result+Format('</%s>',[AIL_xmlBase]);
except
 on E : Exception do LogErrorMessage('T_Main.DTL_GetXML',E,[]);
end;
end;

function T_Main.DTL_SaveIntoDB(*(aAreaID : integer)*) : boolean;
var
 xml   : string;
 ADOSP : TADOStoredProc;
begin
{$MESSAGE 'Запись интервалов для зоны'}
Result:=false;
try
xml:=DTL_GetXML(*(aAreaID)*);
//CopyStringIntoClipboard(xml);
//Exit;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=DBConnString;
case CurObject.idType of
aiitArea: ADOSP.ProcedureName:=spIntervalListSave;
aiitPVZ : ADOSP.ProcedureName:=spIntervalListSavePVZ;
end;
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
{$WARN SYMBOL_PLATFORM OFF}
  if (DebugHook=0)
     or ((DebugHook<>0) and (MessageBox(Handle,PChar('Схема интервалов готова к сохранению. Сохраняем?'),'ВНИМАНИЕ!!!',MB_ICONWARNING + MB_YESNO)=IDYES))
   then  ADOSP.ExecProc;
{$WARN SYMBOL_PLATFORM ON}
Result:=integer(ADOSP.Parameters[0].Value)>0;
finally
if Assigned(ADOSP)then FreeAndNil(ADOSP);
end;
Result:=true;
except
 on E : Exception do LogErrorMessage('T_Main.DTL_SaveIntoDB',E,[]);
end;
end;

procedure T_Main.RefreshScheme(Sender: TObject);
var
 minDate : TDate; // минимальная дата периода
 maxDate : TDate; // максимальная дата периода
 opsDate : TDate; // дата разрешенная для начала изменения
 intDate : TDate; // минимальная дата периода интервалов (для получения чистого смещения даты и времени), только в сортировке
 durDays : integer;
 begDate : TDateTime;
 endDate : TDateTime;
 perCount: integer;
 cnt     : integer;
 ind     : integer;
 srcStrl : TStringList;
 dtlSrc  : TDatesIntervalList;
 errmsg  : string;
begin
try
SetLength(dtlErrors,0);
try
if CurObject.id=0
   then begin
   ind:=Length(dtlErrors);
   SetLength(dtlErrors,ind+1);
   dtlErrors[ind]:='Не указана область для установки схемы.'
   end;
if Length(DTI.Sliders)=0
   then begin
   ind:=Length(dtlErrors);
   SetLength(dtlErrors,ind+1);
   dtlErrors[ind]:='Интервалы отсутствуют.'
   end;
durDays:=Trunc(MinutesToDateTime(DTI.MaxValue))-Trunc(MinutesToDateTime(DTI.MinValue));
if durDays<=0
   then begin
   ind:=Length(dtlErrors);
   SetLength(dtlErrors,ind+1);
   dtlErrors[ind]:='Проверьте длительность периода интервалов.';
   end;

///// (*ATTENTION*) flip-flop date begin
//if DTP_SchemeBegin.Date>DTP_SchemeEnd.Date
//   then begin
//   minDate:=DTP_SchemeEnd.Date;
//   DTP_SchemeEnd.Date:=DTP_SchemeBegin.Date;
//   DTP_SchemeBegin.Date:=minDate;
//   end;
opsDate:=Trunc(Date)+5;
intDate:=trunc(MinutesToDateTime(DTI.MinValue));
minDate:=trunc(DTP_SchemeBegin.Date);
maxDate:=trunc(DTP_SchemeEnd.Date);

if maxDate<minDate   // (*20151228*) было <= (больше 1 дня), а так можно на 1 день
   then begin
   ind:=Length(dtlErrors);
   SetLength(dtlErrors,ind+1);
   dtlErrors[ind]:='Проверьте начало и окончание периода применения схемы.';
   end;
if Length(dtlErrors)>0
   then begin
   errmsg:='';
   for cnt:=0 to High(dtlErrors)
      do begin
      dtlErrors[cnt]:=Format('%d. %s',[cnt+1,dtlErrors[cnt]]);
      errmsg:=errmsg+dtlErrors[cnt]+crlf;
      end;
   //if Sender=SpB_RefreshScheme then ShowMessageInfo(Trim(errmsg),'Ошибка в базовых установках');
   Exit;
   end;

srcStrl:=TStringList.Create;
try
srcStrl.Sorted:=true;
for cnt:=0 to High(DTI.Sliders)
  do srcStrl.AddObject(FormatDateTime('yyymmdd_hhnn',DTI.Sliders[cnt].Start.dateTime)+'-'+FormatDateTime('yyymmdd_hhnn',DTI.Sliders[cnt].Finish.dateTime),TObject(cnt+1));
SetLength(dtlSrc,srcStrl.Count);
for cnt:=0 to srcStrl.Count-1
  do begin
  ind:=integer(srcStrl.Objects[cnt])-1;
  dtlSrc[cnt].DateBegin:=DTI.Sliders[ind].Start.dateTime - intDate;
  dtlSrc[cnt].DateEnd:=DTI.Sliders[ind].Finish.dateTime - intDate;
  end;
finally
srcStrl.Free;
end;

if Length(dtlSrc)=0 then Exit;
endDate:=minDate;
Setlength(DTL,0);
cnt:=-1;
perCount:=0;
repeat
if cnt>=High(dtlSrc)
   then begin
   cnt:=0;
   inc(perCount);
   end
   else inc(cnt);
if (cnt>=Low(dtlSrc)) and (cnt<=High(dtlSrc))
   then begin
   begDate:=minDate+durDays*perCount+(dtlSrc[cnt].DateBegin);
   if begDate>maxDate
      then Break;
   endDate:=minDate+durDays*perCount+(dtlSrc[cnt].DateEnd);
   ind:=Length(DTL);
   SetLength(DTL,ind+1);
   DTL[ind].DateBegin:=begDate;
   DTL[ind].DateEnd:=endDate;
   DTL[ind].isOn:= (begDate>=opsDate) and (endDate<maxDate+1);
   end
   else Break;
until endDate>maxDate;
//ShowMessageInfo(Formatdatetime('dd.mm.yyyy hh:nn',endDate)+crlf+Formatdatetime('dd.mm.yyyy hh:nn',maxDate+1))
finally
SpB_ApplyScheme.Enabled:=Length(dtlErrors)=0;
if not SpB_ApplyScheme.Enabled
   then begin
   DrGr_DTL.ColCount:=1;
   RestoreColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'ErrorMode');
   DrGr_DTL.RowCount:=1+Length(dtlErrors)
   end
   else begin
   DrGr_DTL.ColCount:=3;
   RestoreColumns(self, DrGr_DTL, AppParams.CFGUserFileName, 'NormalMode');
   DrGr_DTL.RowCount:=1+Length(DTL)+integer(Length(DTL)=0);
   end;
DrGr_DTL.Repaint;
SetLength(dtlSrc,0);
end;
except
 on E : Exception do LogErrorMessage('T_Main.RefreshScheme',E,[]);
end;
end;


procedure T_Main.ApplyScheme(Sender: TObject);
begin
if DTL_SaveIntoDB
   then RefreshAreaIntervalList(CurObject.id, CurObject.idType)
   else (* ... всё плохо, ничего не сохранилось ...*);
end;

(**************************************************************************************************)

procedure T_Main.DrGr_PVZListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
const
 fn : array[boolean] of TColor = (clNavy, clAqua);
 br : array[boolean] of TColor = (clWhite, clNavy);
 titles : array [-0..1] of string = ('Регион','Наименование');
var
 rct  : TRect;
 str  : string;
 sel  : boolean;
 ind  : integer;
 alg  : integer;
 pic  : integer;
begin
try
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
str:='';
ind:=-1;
alg:=DT_LEFT_ALIGN;
try
case ARow of
0 : str:=titles[ACol];
  else begin
  sel:=(gdSelected in State) or (gdFocused in State);
  with DrGr_PVZList.Canvas do
    begin
    Font.Color:=fn[sel];
    Brush.Color:=br[sel];
    end;
  ind:=ARow-1;
  if (ind<Low(PVZList.Items)) or (ind>High(PVZList.Items))
     then begin
     ind:=-1;
     Exit;
     end;
  case ACol of
  0 : str:=AC2Str(PVZList.Items[ind].Region);
  1 : str:=AC2Str(PVZList.Items[ind].Description);
  end;
  end;
end;
finally
with DrGr_PVZList.canvas do
  begin
  Windows.FillRect(Handle, Rect,Brush.Handle);
  if (ARow>0) and (ACol=0) and (ind>-1)
     then begin
     if str='77' then pic:=ptpMoscow else
     if str='78' then pic:=ptpSPb else
     if str='61' then pic:=ptpRostov else  pic:=ptpAttention;
     IL_Paint.DrawingStyle:=dsTransparent;
     IL_Paint.Draw(DrGr_PVZList.canvas, rct.Left, rct.Top,pic );
     rct.Left:=rct.Left+IL_Paint.Width+2;
     end;
  DrawTransparentText(Handle,str,rct,alg);
  end;
end;
except
 on E : Exception do LogErrorMessage('T_Main.DrGr_PVZListDrawCell',E,[]);
end;
end;

procedure T_Main.DrGr_PVZListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
 ind : integer;
begin
try
ind:=ARow-1;
if (ind>=Low(PVZList.Items)) and (ind<=High(PVZList.Items))
   then begin
   CurObject.Fill(PVZList.Items[ind].id, aiitPVZ);
   Lab_PVZ_List.Hint:=Format('PVZ id: %d',[CurObject.id]);
   Lab_PVZ_List.ShowHint:=True;
   RefreshAreaIntervalList(CurObject.id, CurObject.idType);
   end;
except
 on E : Exception do LogErrorMessage('T_Main.DrGr_PVZListSelectCell',E,[]);
end;
end;

procedure T_Main.SzPanSetOut(Sender: TObject);
var
 ind : integer;
 SP  : TSizedPanel;
begin
if (Sender is TSizedPanel)
   then SP:=(Sender as TSizedPanel)
   else
if (Sender is TSpeedButton) and
   ((Sender as TSpeedButton).Parent is TSizedPanel)
   then SP:=((Sender as TSpeedButton).Parent as TSizedPanel)
   else exit;
ind:=SzPanPosList.GetIndex(SP.Handle);
if ind>-1
   then begin
   if (SzPanPosList.Items[ind].Pan.Parent<>Application.MainForm) and
      Assigned(SzPanPosList.Items[ind].ParentForm)
      then SzPanPosList.SetIn(ind)
      else SzPanPosList.SetOut(ind);
   end;
end;

procedure T_Main.SzPanClick(Sender: TObject);
begin
if Sender is TSizedPanel
   then (Sender as TSizedPanel).BringToFront;
end;

procedure T_Main.Pan_ReqDataClick(Sender: TObject);
//const
// Shablon : string =
//'{'+
//'id:%d'+
//',parentid:%d'+
//',level:%d'+
//',name:%s'+
//',rgbline:%s'+
//',rgbfill:%s'+
//',routenum:%d'+
//',days:%s'+
//',latlngarr:%s'+
//',sessionid:%s'+'}';
//var
// ids  : TIntegerDynArray;
// fr   : TFloatRect;
// json : string;
begin
{$MESSAGE 'Данные и Скрипты для отладки живут здесь!'}
//SetLength(ids,1);
//ids[0]:=504;
//
//json:=FullAreaList.GetRegion(ids,fr);
//ExecuteScript(WB, Format('SetBoundsForPoints(%s)',[json]));
//
//json:=Format(Shablon,[ 0
//                     , 0
//                     , 0
//                     , AnsiQuotedStr(StringToJavaUTF8Ex('Тестовый регион'),'"')
//                     , '"FF0000"'
//                     , '"00FF00"'
//                     , 0
//                     , '"0000000"'
//                     , json
//                     , '"test"'
//                     ]);
//ExecuteScript(WB, Format('SetArrayOfPolygonNew([%s])',[json]));
end;


procedure T_Main.SpB_Area_DopFuncsClick(Sender: TObject);
begin
ShowPopupMenu(SpB_Area_DopFuncs, PM_AreaDopFuncs);
end;

procedure T_Main.NAreaDopFuncs_IntersectClick(Sender: TObject);
var
 res    : TIntegerDynArray;
 resTxt : string;
begin
CheckIntersectAreas(res,resTxt);
if Length(res)=0 then Exit;
FillSelectedAreas(res);
SetLength(res,0);
Check_ChLB_Areas_Names;
Check_TV_Area;
if AreaIntersectMessage(resTxt, 'Эти области будут отображены на карте.')=IDYES
   then SpB_ViewFiltered_Filter.Click;
end;

procedure T_Main.ChBSelectShowedAreas(Sender: TObject);
var
 str : string;
begin
str:='';
if ChB_UsedNow.Checked then str:=str+','+'Используемые';
if ChB_UsedAdm.Checked then str:=str+','+'Территориальные';
if ChB_UsedNo.Checked then str:=str+','+'Недействующие';
LabPanDopFilter.Caption:='Список областей: ' +IfThen(str<>'',Copy(str,2,Length(str)),'.....');
if Sender <> nil
   then RefreshAreaList;
if ChB_DopAutoShow.Checked
   then Act_ShowFilteredExecute(Act_ShowFiltered);
if Sender is TCheckBox
   then with Sender as TCheckBox do
          SaveBool('Settings',Name,Checked,AppParams.CFGUserFileName);
ExtShAreaDopFilter.Visible:=not ChB_UsedNow.Checked or
                            not ChB_UsedAdm.Checked or
                            not ChB_UsedNo.Checked;

end;

procedure T_Main.LabPanDopFilterClick(Sender: TObject);
begin
PanAreaDopFilter.Visible:=not PanAreaDopFilter.Visible;
end;

(*** TWO HOURS ************************************************************************************)

procedure T_Main.BB_TwoHours_CloseClick(Sender: TObject);
begin
//if SzPanPosList.IsOut(SzPan_TwoHours) then SzPanPosList.SetIn(SzPan_TwoHours);
//SetGlyph(SpB_Mode_TwoHours,IL_Paint, [ptpInterval]);
//SzPan_TwoHours.Hide;
ShowWorkPanels(SpB_Mode_TwoHours);
end;

procedure T_Main.SzPan_TwoHoursResize(Sender: TObject);
begin
BB_TwoHours_Close.Left:=BB_TwoHours_Close.Parent.ClientWidth  - BB_TwoHours_Close.Width;
BBUpdPilSave.Left:=BBUpdPilSave.Parent.ClientWidth  - BBUpdPilSave.Width;
BBUpdPilClear.Left:=BBUpdPilSave.Left;
with DrGrDisplayPIL do
 begin
 Width:=BBUpdPilClear.Left - Left - 4;
 Height:=Parent.ClientHeight - Top - 4;
 end;
end;



procedure T_Main.CBTwoHoursAreaDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
 _bmp   : TBitmap;
 str    : string;
 rct    : TRect;
 sel    : boolean;
begin
str:=CBTwoHoursArea.Items[Index];
_bmp:=TBitmap.Create;
try
with PAreaItem(CBTwoHoursArea.Items.Objects[Index])^
  do AreaPicList.DrawBitmap(aRGBFill, aRGBLine, _bmp);
with CBTwoHoursArea.Canvas do
  begin
  sel:=(odSelected in State) or (odFocused in State);
  Font.Color:=FontColor[sel];
  Brush.Color:=BrushColor[sel];
  FillRect(Rect);
  System.Move(Rect, rct, SizeOf(TRect));
  rct.Left:=rct.Left + _bmp.Width + 2;
  Draw(Rect.Left, Rect.Top, _bmp);
  //if AnsiPos(Ed_Filter_Find.Hint,AnsiUpperCase(str))<>0
  //   then Font.Style:=[fsBold]
  //   else Font.Style:=[];
  DrawTransparentText(Handle,str,rct,DT_LEFT_ALIGN);
  end;
finally
_bmp.Free;
end;
end;


procedure T_Main.CBTwoHoursAreaChange(Sender: TObject);
begin
if (CBTwoHoursArea.ItemIndex>-1) and (integer(CBTwoHoursArea.Items.Objects[CBTwoHoursArea.ItemIndex])>integer(Hinstance))
   then LabTHAreaID.Tag:=PAreaItem(CBTwoHoursArea.Items.Objects[CBTwoHoursArea.ItemIndex])^.aID
   else LabTHAreaID.Tag:=-1;
LabTHAreaID.caption:=IfThen(LabTHAreaID.Tag>-1, IntToStr(LabTHAreaID.Tag), '?');
//if LabTHAreaID.Tag>0
//   then PayIntervalList.FillForArea(LabTHAreaID.Tag, DisplayPIL)
//   else DisplayPIL.Clear(true);
DrGrDisplayPIL.Repaint;
BBPilShow.Enabled:=LabTHAreaID.Tag<>-1;
end;

// <request><item areaid="%d" intervalid="%d" datebegin="%s" dateend="%s" quota="%d"></request>'


procedure T_Main.DrGrDisplayPILDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
const
 FontColors       : array[boolean] of TColor = (clNavy , clAqua);
 BrushColors      : array[boolean] of TColor = (clWhite, clNavy);
 BrushColorsSearch: array[boolean] of TColor = (clAqua, clAqua);
 FontColorsSearch : array[boolean] of TColor = (clNavy , clNavy);
 Title            : array[0..4] of string = ('', 'Интервал', ' Начало','Окончание', 'Квота');
 szOrd            : integer = 13;
 updColors        : array[TUpdPIL ,boolean ] of TColor =
 ( (clWhite, clNavy)
  ,(clPaleGreen   , clGreen)
  ,(clPaleYellow  , clYellow)
  ,(clPaleRed     , clRed))
  ;
  updFontColors   : array[TUpdPIL ,boolean ] of TColor =
 ( (clNavy , clAqua)
  ,(clBlack  , clLime)
  ,(clBlack  , clNavy)
  ,(clBlack  , clYellow))
  ;
var
 DrGr   : TDrawGrid;
 bmp    : TBitmap;
 sel    : boolean;
 rct    : TRect;
 str    : string;
 strDop : string;
 alg    : integer;
 algDop : integer;
 ind    : integer;
 indInt : integer;
 indUpd : integer;
 upd    : TUpdPIL;
 rctOrd : TRect;
 // -- highlight selected block --
 psS    : integer;
 rctS   : TRect;
 lft    : integer;
 strS   : string;
 SrchStr: string;
 pnStyle  : TPenStyle;
 pnColor  : TColor;
begin
//DrGr:=nil;

bmp:=nil;
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
str:='';
alg:=DT_LEFT_ALIGN;
sel:=false;
FillChar(rctOrd,SizeOf(TRect),0);
// -- подготовка объектов для работы общей процедуры отрисовки (см SMSSender.dpr)
//if not VocList_Prepare(Sender, DrGr, Lst) then Exit;
//SrchStr:=Lst.SearchString;
// --
DrGr:=DrGrDisplayPIL;
ind:=Length(H2List.items)+1+integer(Length(H2List.items)=0);
if DrGr.RowCount<>ind
   then DrGr.RowCount:=ind;
// --
ind:=-1;
//indInt:=-1;
indUpd:=-1;
if not Assigned(DrGr) then Exit;
try
try
sel:=(gdSelected in State) or (gdFocused in State);
with DrGr.Canvas do
  begin
  Font.Color:=FontColors[sel];
  Brush.Color:=BrushColors[sel];
  end;
case ARow of
0 : if (ACol>=0) and (ACol<=High(Title)) then str:=Title[ACol];
else begin
ind:=ARow-1;
if not ((ind>=0) and (ind<=High(H2List.items))) then Exit;
indInt:=PayIntervalList.IndexOf(LabTHAreaID.Tag, H2List.items[ind].id);
indUpd:=UpdatePIL.IndexOf(LabTHAreaID.Tag, H2List.items[ind].id);
upd:=updNone;
if (indUpd>-1)
   then begin
   if UpdatePIL.items[indUpd].id=0
      then upd := updInsert
      else
   if UpdatePIL.items[indUpd].id>0
      then upd := updUpdate
      else upd := updDelete;
   end;

with DrGr.Canvas do
  begin
  Font.Color:=updFontColors[upd, sel];
  Brush.Color:=updColors[upd, sel];
  end;

case ACol of
0 :
  begin
  bmp:=TBitmap.Create;
  with bmp do
    begin
    IL_Paint.DrawingStyle:=dsTransparent;
    Height:=IL_Paint.Height;
    Width:=IL_Paint.Width;
    Canvas.Brush.Color:=clFuchsia;
    Canvas.FillRect(Bounds(0,0,Width,Height));
    if LabTHAreaID.Tag<=0
       then IL_Paint.Draw(Canvas,0,0,ptpDisabled)
       else begin
       case upd of
       updInsert : IL_Paint.Draw(Canvas, 0, 0, ptpBigAdd);
       updUpdate : IL_Paint.Draw(Canvas, 0, 0, ptpBigEdit);
       updDelete : IL_Paint.Draw(Canvas, 0, 0, ptpBigDelete);
       else IL_Paint.Draw(Canvas,0, 0,ptpUncheckedClr+integer(indInt<>-1));
       end;
       end;
    end;
  end;
1 :
  begin
  str:=H2List.items[ind].View(true);
  alg:=DT_CENTER_ALIGN;
  end;
2:
  begin
  if indInt>-1
     then str:=FormatDateTime('dd.mm.yyyy',PayIntervalList.items[indInt].DateBegin);

  alg:=DT_CENTER_ALIGN;
  end;
3:
  begin
  if indInt>-1
     then str:=IfThen(PayIntervalList.items[indInt].DateEnd<>0, FormatDateTime('dd.mm.yyyy',PayIntervalList.items[indInt].DateEnd),'...');
  alg:=DT_CENTER_ALIGN;
  end;
4 :
  begin
  if indInt>-1
     then str:=IntToStr(PayIntervalList.items[indInt].Quota);
  alg:=DT_RIGHT_ALIGN;
  end;
end;
end;
end;
finally
if Assigned(DrGr) then
with DrGr.Canvas do
  begin
  if ARow=0
     then begin
// -- рисование направления сортировки по условиям (SortMode в данном случае коррелирует с Col)
//     if (integer(Lst.SortMode)>=0) and (integer(Lst.SortMode)<DrGr.ColCount)
//        then begin
//        rctOrd:=DrGr.CellRect(integer(Lst.SortMode),0);
//        rctOrd:=Bounds(rctOrd.Right - szOrd - 2, rctOrd.Top + (rct.Bottom-rct.Top - szOrd) div 2, szOrd, szOrd);
//        DrawOrder(Handle, rctOrd, Lst.SortDirect = vsdDesc);
//        end;
     DrawTransparentText(Handle, str, rct, alg);
     end
     else begin
     Windows.FillRect(Handle, Rect, Brush.Handle);
     if (ACol = 0) and Assigned(bmp)
        then begin  // -- отрисовка некой картинки (напрмер, Check - UnCheck)
//        ind:=ILCheck.Width;
        rctOrd:=Bounds(Rect.Left + Round(((Rect.Right-Rect.Left) - bmp.Width) / 2),
                       Rect.Top + Round(((Rect.Bottom-Rect.Top) - bmp.height) / 2),  ind, ind);
        TransparentBlt(Handle,rctOrd.Left,rctOrd.Top,bmp.Width,bmp.Height,bmp.Canvas.Handle,0,0,bmp.Width,bmp.Height,ColorToRGB(clFuchsia));
        bmp.Free;
        end
        else begin
        if ACol>1
           then begin
           strDop:='';
           algDop:=DT_SINGLELINE + DT_BOTTOM + DT_RIGHT + DT_END_ELLIPSIS ;
           if (indUpd>-1) then
              if (UpdatePIL.items[indUpd].id>=0)
                  then begin
                  alg:=DT_SINGLELINE + DT_TOP + DT_LEFT + DT_END_ELLIPSIS ;
                  case ACol of
                  2: strDop:=FormatDateTime('dd.mm.yyyy',UpdatePIL.items[indUpd].DateBegin);
                  3: strDop:=IfThen(UpdatePIL.items[indUpd].DateEnd<>0, FormatDateTime('dd.mm.yyyy',UpdatePIL.items[indUpd].DateEnd),'...');
                  4: strDop:=IntToStr(UpdatePIL.items[indUpd].Quota);
                  end;
                  end
                  else begin

                  end;
          DrawTransparentText(Handle, str, rct, alg);
          if strDop<>''
             then DrawTransparentText(Handle, strDop, rct, algDop);
          end
          else DrawTransparentText(Handle, str, rct, alg);
        end;




     // -- display block of results of searching : begin (highlight selected block) ----------------
     // -- отрисовка (обводка) результатов поиска
     if SrchStr(*Lst.SearchString*)<>''
        then begin
        psS:=AnsiPos(SrchStr(*Lst.SearchString*),AnsiLowerCase(str));
        strS:=Copy(str,psS,Length(SrchStr(*Lst.SearchString*)));
        if (ARow>0) and (psS>0)
           then begin
           case alg of  // -- calculation of rectangle for display of the search phrase
           DT_RIGHT_ALIGN:
              begin
              lft:=rct.Right-TextWidth(str)-2;
              rctS.Left:=(rct.Left-Rect.Left)+TextWidth(Copy(str,1,psS-1))+lft;
              rctS.Right:=rctS.Left+TextWidth(strS);
              rctS.Top:=Rect.Top;
              rctS.Bottom:=Rect.Bottom;
              alg:=DT_LEFT_ALIGN;
              end;
           DT_CENTER_ALIGN:
              begin
              rct:=Bounds(0,0,0,1);
              alg:=DT_LEFT_CALC;
              DrawText(Handle,str,Length(str),rct,alg);
              rct.Bottom:=Rect.Bottom-Rect.Top;
              OffsetRect(rct,Rect.Left+((Rect.Right-Rect.Left) - (rct.Right-rct.Left))div 2, Rect.Top);
              System.Move(rct,rctS,SizeOf(TRect));
              OffsetRect(rctS,TextWidth(Copy(str,1,psS-1)),0);
              rctS.Right:=rctS.Left+TextWidth(strS);
              alg:=DT_LEFT_ALIGN;
              end;
           else begin
           rctS.Left:=rct.Left+TextWidth(Copy(str,1,psS-1));
           rctS.Right:=rctS.Left+TextWidth(strS);
           rctS.Top:=Rect.Top;
           rctS.Bottom:=Rect.Bottom;
           end
           end;
           if (rctS.Right>0) and (rctS.Left>0)
              then begin
              Brush.Color:=BrushColorsSearch[sel];
              Font.Color:=FontColorsSearch[sel];
              Windows.FillRect(Handle,rctS,Brush.Handle);
              SetBkMode(Handle,TRANSPARENT);
              DrawText(Handle,strS,Length(strS),rctS,alg);
              SetBkMode(Handle,OPAQUE);
              // -- это для обводки --
              //Pen.Color:=InvertColor(Brush.Color);
              //Brush.Style:=bsClear;
              //Windows.Rectangle(Handle,rctS.Left, rctS.Top, rctS.Right, rctS.Bottom);
              end;
           end;
         end;
      // -- display block of results of searching : end (highlight selected block) -----------------
      end; //-->-- Row>0
end; // -->-- with DrGr.Canvas do
end; // -->-- finally
except
 on E : Exception do LogErrorMessage(Format('%s(%s)',[AOS(Sender),GMN(Sender)]),E,[]);
end;
end;

procedure T_Main.DrGrDisplayPILDblClick(Sender: TObject);
var
 pt         : TPoint;
 gc         : TGridCoord;
 AreaId     : integer;
 Areaname   : string;
 _route     : integer;
 H2str      : string;
 IntervalId : integer;
 indMain    : integer;  // -- индекс в основнм списке интервалов
 indUpd     : integer;  // -- индекс в списке интервалов на изменение (insert, update, delete)
begin
Windows.GetCursorPos(pt);
pt:=DrGrDisplayPIL.ScreenToClient(pt);
gc:=DrGrDisplayPIL.MouseCoord(pt.X, pt.Y);
if not H2Data(gc.Y, indMain, AreaId, IntervalId)
   then Exit;
FullAreaList.GetAreaDataById(AreaId, Areaname, _route);
H2str:=H2List.items[H2List.IndexOf(IntervalId)].View(true);
   if indMain>-1  // -- CHECKED , есть в главном, можно update(id<>0), delete(id<0)
      then begin
      indUpd:=UpdatePIL.IndexOf(AreaId, IntervalId);
      if indUpd=-1
         then indUpd:=UpdatePIL.Add(PayIntervalList.items[indMain]);
      end
      else indUpd:=UpdatePIL.Add(0, AreaId, IntervalId,0,0,0);
    if (indUpd>-1)
        then if not EditH2Interval(UpdatePIL.items[indUpd])
                then UpdatePIL.Delete(indUpd);
BBUpdPilSave.Enabled:=Length(UpdatePIL.items)>0;
BBUpdPilClear.Enabled:=BBUpdPilSave.Enabled;
DrGrDisplayPIL.Repaint;
end;


procedure T_Main.UpdPILClick(Sender: TObject);
begin
if Sender=BBUpdPilSave
   then begin
   if UpdatePIL.SaveToDB
      then begin
      UpdatePIL.Clear;
      PayIntervalList.LoadFromDB;
      end;
   end
   else
if Sender=BBUpdPilClear
   then begin
   UpdatePIL.Clear;
   end
   else
if Sender=BBPilInfo
   then begin
   PayIntervalInfo;
   end
   else
if Sender=BBPilShow
   then begin
   if LabTHAreaID.Tag<>-1
      then ExecuteScript(WB, Format('SetArrayOfPolygonNew(%s)',[FullAreaList.getJSObject([LabTHAreaID.Tag])]))
   end
   else


   ;
BBUpdPilSave.Enabled:=Length(UpdatePIL.items)>0;
BBUpdPilClear.Enabled:=BBUpdPilSave.Enabled;
DrGrDisplayPIL.Repaint;
end;


procedure T_Main.SpBFiltAttClick(Sender: TObject);
begin
ShowMessageWarning(
'Если есть подозрение, что какая-то область не отображается, то проверьте все фильтры:'+crlf+
' 1. Отображение по городу'+crlf+
' 2. Отображение по активности ("действительности")'+crlf+
' 3. Отобранные области для отображения по различным условиям и поиску'+crlf+
''+crlf+
''
,'Отображение областей')
end;




end.
