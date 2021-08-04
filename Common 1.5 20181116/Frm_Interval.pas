unit Frm_Interval;
{$DEFINE ALONE}

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
  , Menus
  , ComCtrls
  , StdCtrls
  , AppLogNew
  , FnCommon, Buttons;

const
 FRM_OVERSLIDER    = WM_APP + $01;
 FRM_TIMEPAIR      = WM_APP + $02;
 FRM_FIRSTVALUES   = WM_APP + $03; // -- передача начального времени (WParam реальное, LParam округленное (RoundToNimutes>1))
 FRM_SECONDVALUES  = WM_APP + $04; // -- передача конечного времени (WParam реальное, LParam округленное (RoundToNimutes>1))
 FRM_SELFUPDATE    = WM_APP + $05;

 SliderHeight      = 17;
 SliderHeightHalf  = SliderHeight div 2 + 1;
 ScaleHeight      : integer = 8; // высота линии шкалы
 clPaleGreen       = TColor($CCFFCC);
 clPaleRed         = TColor($CCCCFF);
 figPlus          : TGradientFigure = gfTriangleRight;
 figMinus         : TGradientFigure = gfTriangleLeft;
 MaxDays          : integer = 7;


 {$IFDEF ALONE}
  cr = #13;
  lf = #10;
  crlf = cr + lf;
 {$ENDIF}


type
  TFocusedSlider = (fsNone, fsFirst, fsSecond, fsInterval);
{$IFDEF ALONE}
  TTriangleOrderBaseColorInt = (ttobcGray,ttobcRed,ttobcGreen,ttobcBlue,ttobcYellow);
{$ENDIF}
  TDatePart = (dpYear,            // yy,yyyy Year
               dpQuart,           // qq, q      Quarter
               dpMonth,           // mm, m      Month
               dpDayOfYear,       // dy, y      DayOfYear
               dpDay,             // dd, d      Day
               dpWeek,            // wk, ww     Week
               dpHour,            // hh,        Hour
               dpMinute,          // mi, n      Minute
               dpSecond,          // ss, s      Second
               dpMSecond);        // ms     MilliSecond

type
  TInterval = class(TFrame)
    PM_Color: TPopupMenu;
    NClr_Gray: TMenuItem;
    NClr_Red: TMenuItem;
    NClr_Yellow: TMenuItem;
    NClr_Green: TMenuItem;
    NClr_Blue: TMenuItem;
    NClr_About: TMenuItem;
    PM_Interval: TPopupMenu;
    NInt_SetInterval: TMenuItem;
    procedure FrameResize(Sender: TObject);
      procedure RoundMin;
      procedure RoundMax;
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure FrameMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetSliderColor(Sender: TObject);
    procedure FrameClick(Sender: TObject);
    procedure NInt_SetIntervalClick(Sender: TObject);
  private
    // Все переменные помеченные "(PUBLIC)" в конце комментария могут быть перенесены в соответствующую область видимости для удобства работы
    dc     : hDC;
    bmp    : TBitmap;
    ParentFormHandle : cardinal;                // -- Handle окна для получения сообщений (вычисляется, но может быть установлен) (PUBLIC)
    MinPos           : integer;                 // -- MIN время интервала в минутах (PUBLIC)
    MaxPos           : integer;                 // -- MAX время интервала в минутах , но не больше 24*60-1 (PUBLIC)
    ScaleWidth       : integer;                 // Ширина линейки шкалы (см. ScaleHeight выше)
    FirstPos         : integer;                 // Позиция первого(левого) указателя (часы*60+минуты)
    FirstRgn         : hRGN;                    // Регион первого(левого) указателя
    FirstClr         : TTriangleOrderBaseColorInt; // Цветовой тип первого(левого) указателя
    SecondPos        : integer;                 // Позиция второго(правого) указателя (часы*60+минуты)
    SecondRgn        : hRGN;                    // Регион второго(правого) указателя
    SecondClr        : TTriangleOrderBaseColorInt; // Цветовой тип второго(правого) указателя
    WidthKoef        : extended;                // Коэффициент преобразования точек в минуты
    RevWidthKoef     : extended;                // Кэффициент преобразования минут в точки
    FocusedSlider    : TFocusedSlider;          // Текущий перемещаемый указатель
    MinInterval      : integer;                 // -- Минимально допустимый интервал в минутах (PUBLIC)
    RoundToMinutes   : integer;                 // -- Шаг(дискретность) в минутах (0 - дискретность не используется ) (PUBLIC)
    IntervalRgn      : hRGN;                    // Регион установленного интервала для перемещения
    fHour            : word;                    // -- Часы начала интервала (PUBLIC) * рекомендуется использовать try..except end при EncodeTime
    fMinute          : word;                    // -- Минуты начала интервала (PUBLIC) * рекомендуется использовать try..except end при EncodeTime
    sHour            : word;                    // -- Часы окончания интервала (PUBLIC) * рекомендуется использовать try..except end при EncodeTime
    sMinute          : word;                    // -- Минуты окончания интервала (PUBLIC) * рекомендуется использовать try..except end при EncodeTime
    CanMoveInterval  : boolean;
    rctPlus          : TRect;
    rgnPlus          : hRgn;
    rctMinus         : TRect;
    rgnMinus         : hRgn;
//(*unnecessary*)    fDateDay         : TDateTime;               // -- Дата(день, целое) для формирования даты и времени начала интервала (PUBLIC)
//(*unnecessary*)    sDateDay         : TDateTime;               // -- Дата(день, целое) для формирования даты и времени окончания интервала (PUBLIC)
    procedure CheckAndRepair;
    procedure PaintHandler(var Msg : TMessage); message WM_PAINT;
    procedure CheckInputData(Sender : TObject);
    procedure SetInterval(aForceStart : boolean = False);
    procedure FRM_SELFUPDATE_Handler(var aMSG : TMessage); message FRM_SELFUPDATE;
   
  public
    constructor Create(AOwner : TComponent); override;
    constructor CreateDynamic(AOwner : TComponent;aMinMinutes,aMaxMinutes,aMinInterval,aStep : integer;aFrom,aTo : TDateTime;aReceiverWnd : cardinal = 0);overload;
    constructor CreateDynamic(AOwner : TComponent;aMinMinutes,aMaxMinutes,aMinInterval,aStep : integer;aBase,aFrom,aTo : TDateTime;aReceiverWnd : cardinal = 0);overload;
    destructor Destroy;override;
    procedure GetDateTimes(const aDateFrom,aDateTo : TDateTime; var aResDateTimeFrom,aResDateTimeTo : TDateTime);
    procedure UpdateView;
  end;

procedure CalcInterval(aDateFrom,aDateTo : TDateTime;var aDays,aHours,aMinutes : integer);
function InputDateTimeInterval(const ACaption, APrompt : string; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aOnlyInterval : boolean): boolean; overload;
function InputDateTimeInterval(const ACaption, APrompt : string; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aMinDate,aMaxDate : TDateTime; aDays : integer; aOnlyInterval : boolean): boolean; overload;
function InputDateTimeInterval(const ACaption, APrompt : string;aBaseDate: TDateTime; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aMinDate,aMaxDate : TDateTime; aDays : integer; aOnlyInterval : boolean): boolean; overload;

function NewIntervalResponse(aForm : TForm; aFirstMins, aSecondMins : int64; var aDateA, aDateB : TDateTime) : string;

var
 FullDays     : integer = 2 ;//full days count
 ShowDaysCtrl : boolean = true;

implementation

//procedure LogErrorMessage(const aProcName : string; aException  :Exception ; aParams : array of const);
//var
// errstring : string;
//begin
//CreateErrorMessage(aProcName, aException, aParams, errstring);
//if errstring<>'' then ;
//end;


{$R *.dfm}
(******************************************************************************)
procedure SimpleTriAngleOrderRGN(aCanvas : Tcanvas;aLeft,aTop,aHeight : integer;TriangleOrderBaseColor : TTriangleOrderBaseColorInt; var aRegion : hRGN);
var
 cnt         : integer;
 pnClr,brClr : TColor;
 pnStyle     : TPenStyle;
 pnWdt       : integer;
 deltaClr    : byte;
 ColorByte   : byte;
 Desc        : boolean;
 Points      : array[0..3] of TPoint;
begin
Desc:=True;
pnClr:=aCanvas.Pen.Color;
pnStyle:=aCanvas.Pen.Style;
pnWdt:=aCanvas.Pen.Width;
brClr:=aCanvas.Brush.Color;
aCanvas.Pen.Color:=clBlack;
aCanvas.Pen.Style:=psSolid;
aCanvas.Pen.Width:=1;
deltaClr:=Round((255-(127 / aHeight)) / aHeight);
for cnt:=0 to aHeight div 2
   do begin
   if cnt=0
      then begin
      aCanvas.Pen.Color:=clBlack;
      if Desc
      then begin
      Points[0].X:= aLeft               ; Points[0].Y:=aTop+aHeight;
      Points[1].X:= aLeft+aHeight div 2 ; Points[1].Y:=aTop;
      Points[2].X:= aLeft+aHeight       ; Points[2].Y:=aTop+aHeight;
      end
      else begin
      Points[0].X:=aLeft+cnt           ; Points[0].Y:=aTop+cnt;
      Points[1].X:=aLeft+aHeight div 2 ; Points[1].Y:=aTop+aHeight-cnt;
      Points[2].X:=aLeft+aHeight-cnt   ; Points[2].Y:=aTop+cnt;
      end;
      System.Move(Points[0],Points[3],SizeOf(TPoint));
      end
   else begin
   ColorByte:=128+deltaClr*cnt;
   case TriangleOrderBaseColor of
   ttobcRed    : aCanvas.Pen.Color:=RGB(ColorByte,0,0);
   ttobcGreen  : aCanvas.Pen.Color:=RGB(0,ColorByte,0);
   ttobcBlue   : aCanvas.Pen.Color:=RGB(0,0,ColorByte);
   ttobcYellow : aCanvas.Pen.Color:=RGB(ColorByte,ColorByte,0);
   else aCanvas.Pen.Color:=RGB(ColorByte,ColorByte,ColorByte); // ttobcGray
   end;
   end;
   if Desc
      then begin
      aCanvas.MoveTo(aLeft+cnt,aTop+aHeight-cnt);
      aCanvas.LineTo(aLeft+aHeight div 2,aTop+cnt);
      aCanvas.LineTo(aLeft+aHeight-cnt,aTop+aHeight-cnt);
      aCanvas.LineTo(aLeft+cnt,aTop+aHeight-cnt);
      end
      else begin
      aCanvas.MoveTo(aLeft+cnt,aTop+cnt);
      aCanvas.LineTo(aLeft+aHeight div 2,aTop+aHeight-cnt);
      aCanvas.LineTo(aLeft+aHeight-cnt,aTop+cnt);
      aCanvas.LineTo(aLeft+cnt,aTop+cnt);
      end;
   end;
acanvas.Pen.Color   :=pnClr;
aCanvas.Pen.Style   :=pnStyle;
aCanvas.Pen.Width   :=pnWdt;
acanvas.Brush.Color :=brClr;
if aRegion<>0
  then begin
  DeleteObject(aRegion);
  aRegion:=0;
  end;
aRegion:=CreatePolygonRgn((@Points[0])^,Length(Points),WINDING);
end;

{$IFDEF ALONE}
procedure TextRotateDC(DC : hDC; hfntDC: hFont; aRct : Trect ;ShowStr : PChar; angle : integer);
var
hfnt     : hFont;
hfntPrev : hFont;
LF       : TLogFont ;
begin
GetObject(hfntDC,SizeOf(TLogFont),@LF);
lf.lfEscapement:= angle;
hfnt:=CreateFontIndirect(lf);
hfntPrev:= SelectObject(dc, hfnt);
try
SetBkMode(dc, TRANSPARENT);
DrawText(DC,ShowStr,StrLen(ShowStr),aRct,DT_SINGLELINE+DT_BOTTOM+DT_LEFT+DT_END_ELLIPSIS);
finally
SelectObject(dc, hfntPrev);
DeleteObject(hfnt);
SetBkMode(dc, OPAQUE);
end;
end;
{$ENDIF}

function RoundByStep(aValue,aStep : integer): integer;
var
 delta   : integer;
 Rounded : integer;
begin
delta:=aValue mod aStep;
Rounded:=aValue - delta;
Result:=Rounded;
if delta=0 then Exit;
if delta>Round(aStep / 2)
   then Result:=Rounded+aStep;
end;

function GetQuart(const aMonth : integer): integer;
begin
Result:=aMonth div 3 + integer(aMonth mod 3 <> 0);
end;

function DateDiff(aDatePart : TDatePart; const aStartDate, aEndDate : TDateTime) : integer;
var
  _sy,_sm,_sd,_sh,_sn,_ss,_sz : word;
  _ey,_em,_ed,_eh,_en,_es,_ez : word;
  _ry,_rm,_rd,_rh,_rn,_rs,_rz : word;
begin
Result:=0;
DecodeDate(aStartDate,_sy,_sm,_sd); DecodeTime(aStartDate,_sh,_sn,_ss,_sz);
DecodeDate(aEndDate,_ey,_em,_ed)  ; DecodeTime(aEndDate,_eh,_en,_es,_ez);
DecodeDate(Trunc(aEndDate) - Trunc(aStartDate)-EncodeDate(1899,12,30),_ry,_rm,_rd); DecodeTime(aEndDate-aStartDate,_rh,_rn,_rs,_rz);
case aDatePart of
dpYear      : Result:=_ry -1900;
dpQuart     : Result:=4*(_ey -_sy) - GetQuart(_sm) + GetQuart(_em);
dpMonth     : Result:=12*(_ey -_sy) - _sm + _em;
dpDay,
dpDayOfYear : Result:=(Trunc(aEndDate)  - Trunc(aStartDate));
dpWeek      : Result:=(Trunc(aEndDate)  - Trunc(aStartDate)) div 7;
dpHour      : Result:=(Trunc(aEndDate)  - Trunc(aStartDate)) * 24 + _rh;
dpMinute    : Result:=(Trunc(aEndDate)  - Trunc(aStartDate)) * 24 * 60 - _sh * 60 - _sn + _eh * 60 + _en;
dpSecond    : Result:=((Trunc(aEndDate) - Trunc(aStartDate)) * 24 * 60 - _sh * 60 - _sn + _eh * 60 + _en)*60 - _ss + _es;
end;
end;

(********************************************************************************)

procedure CalcInterval(aDateFrom,aDateTo : TDateTime;var aDays,aHours,aMinutes : integer);
begin
aDays:=DateDiff(dpDay,aDateFrom,aDateTo);
aHours:=DateDiff(dpHour,aDateFrom,aDateTo)- aDays*24;
aMinutes:=DateDiff(dpMinute,aDateFrom,aDateTo)- aDays*24*60 - aHours*60;
end;

function GetAveCharSize(Canvas: TCanvas): TPoint;
{used by InputQueryPW}
var
I: Integer;
Buffer: array[0..51] of Char;
begin
for I := 0 to 25 do Buffer[i] := Chr(I + Ord('A'));
for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
Result.X := Result.X div 52;
end;


function InputDateTimeInterval(const ACaption, APrompt : string; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aOnlyInterval : boolean): boolean;
var
 stDate      : TDateTime;
 //fiDate      : TDateTime;
 baseDate    : TDate;
 DialogUnits : TPoint;
 _Form       : TForm;
 _LabDTP     : TLabel;
 _DTP        : TDateTimePicker;
 _Frm        : TInterval;
 _BBOk       : TButton;
 _BBcancel   : TButton;
 _LabInfo    : TLabel;
 _LabPrice   : TLabel;
 _CBPrice    : TComboBox;
begin
Result:=False;
_CBPrice:=nil;
_Form:=TForm.CreateNew(Application);
try
try
if trunc(aFrom)=0
   then stDate:=Date
   else stDate:=Trunc(aFrom);
//if trunc(aTo)=0
//   then fiDate:=Date
//   else fiDate:=Trunc(aTo);
baseDate:=Trunc(stDate);
with _Form do
  begin
  Canvas.Font := Font;
  DialogUnits := GetAveCharSize(Canvas);
  BorderStyle := bsSizeToolWin;
  Caption := ACaption;
  ClientWidth := MulDiv(180, DialogUnits.X, 4);
  Position := poScreenCenter;
  AutoScroll:=False;
  Height:=100;
  end;
_LabDTP:=TLabel.Create(_Form);
_DTP:=TDateTimePicker.Create(_Form);
with _LabDTP do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := MulDiv(8, DialogUnits.Y, 8);
  if Assigned(_DTP)
     then begin
     Caption:=APrompt;
     _Form.Width:= Width+_DTP.Width+Left*2+10;
     Hint:='Выбор даты для использования в установке интервала';
     end;
  ShowHint:=True;
  end;
if Assigned(_DTP)
   then with (_DTP)
          do begin
          Parent:=_Form;
          Top:=_LabDTP.Top-(Height div 2 - _LabDTP.Height div 2);
          Left:=_LabDTP.Left+_LabDTP.Width+10;
          Width:=Parent.ClientWidth - Left - 4;
          DateFormat:=dfLong;
          DateTime:=baseDate;
          Anchors:=[akLeft,akTop,akRight];
          end;
FullDays:=DateDiff(dpDay,aFrom,aTo)+1;
_Frm:=TInterval.CreateDynamic(_Form,0    // Min time of interval
                                   ,1440*FullDays   // Max time ..... 1441
                                   ,0     // Min duration of interval
                                   ,60      // Inc/Dec step
                                   ,aFrom   // Begin Datetime( used time part)
                                   ,aTo);  // End Datetime (....)
with _Frm do
  begin
  Parent:=_Form;
  Left:=4;
  if Assigned(_DTP)
     then Top:=_DTP.Top+_DTP.Height+8
     else Top:=_LabDTP.Top+_LabDTP.Height+8;
  Width:=Parent.ClientWidth - Left*2;
  //Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')*3 + 4;
  Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')+Round(SliderHeight*3.5)+2;
  Anchors:=[akLeft,akTop,akRight];
  if Assigned(_Frm.OnMouseMove) then _Frm.OnMouseMove(_Frm,[],0,0);
  end;

_LabInfo:=TLabel.Create(_Form);
with _LabInfo do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _frm.Top+_frm.Height+4;
  AutoSize:=False;
  Width:=Parent.ClientWidth - Left*2;
  Caption:='...';
  Anchors:=[akLeft,akTop,akRight];
  Tag:=100500;
  ShowHint:=True;
  end;

if (Assigned(aItems) and (aItems.Count>0)) and not aOnlyInterval
then begin
_LabPrice:=TLabel.Create(_Form);
_CBPrice:=TComboBox.Create(_Form);
with _LabPrice do
  begin
  Parent:=_Form;
  FocusControl:=_CBPrice;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _LabInfo.Top+_LabInfo.Height+4+(FocusControl.Height div 2 - Height div 2);
  Caption:='Статус интервала';
  Hint:=Caption;
  Anchors:=[akLeft,akTop];
  ShowHint:=True;
  end;
_CBPrice:=TComboBox.Create(_Form);
with _CBPrice do
 begin
 Parent:=_Form;
 Left:=_LabPrice.Left+_LabPrice.Width+4;
 Top:=_LabPrice.Top - (Height div 2 - _LabPrice.Height div 2);
 Width:=Parent.ClientWidth - Left - 4;
 Anchors:=[akLeft,akTop,akRight];
 Style:=csDropDownList;
 Items.AddStrings(aItems);
 if aItemIndex=-1
    then aItemIndex:=0
    else ItemIndex:=aItemIndex;
 end;
end;
_BBCancel:=TButton.Create(_Form);
with _BBCancel do
 begin
 Parent:=_Form;
 Left:=4;
{$WARNINGS OFF}
 if Assigned(_CBPrice)
    then Top:=_CBPrice.Top+_CBPrice.Height+6
    else Top:=_LabInfo.Top+_LabInfo.Height+4;
{$WARNINGS ON}
 Width:=(Parent.ClientWidth - 8) div 2;
 Caption:='Отменить';
 ModalResult:=mrCancel;
 end;
_BBOk:=TButton.Create(_Form);
with _BBOk do
 begin
 Parent:=_Form;
 Left:=_BBCancel.Left+_BBCancel.Width;
 Top:=_BBCancel.Top;
 Width:=_BBCancel.Width;
 Caption:='Принять';
 ModalResult:=mrOk;
 end;
with _Form do
 begin
 Height:=_BBOk.Top+_BBOk.Height+(Height-ClientHeight)+4;
 Constraints.MinHeight:=Height;
 Constraints.MaxHeight:=Height;
 Constraints.MinWidth :=Width;
 end;
_BBCancel.Anchors:=[akBottom];
_BBOk.Anchors:=[akBottom];
if aOnlyInterval
   then begin
   _LabDTP.Caption:='Временнóй интервал';
   _LabDTP.Hint:='Установка временнóго интервала без указания даты';
   _DTP.Hide;
   end;
if _Form.ShowModal = mrOk
  then begin
  Result:=True;
  if Assigned(_CBPrice)
     then aItemIndex:=_CBPrice.ItemIndex
     else aItemIndex:=-1;
  _LabInfo.Caption:=NewIntervalResponse(_Form,_Frm.FirstPos,_Frm.SecondPos,aFrom,aTo);
  //if Assigned(_DTP)
  //   then _Frm.GetDateTimes(_DTP.DateTime,_DTP.DateTime,aFrom,aTo)
  //   else _Frm.GetDateTimes(stDate,fiDate,aFrom,aTo);
  end;
except
on E : Exception do
  begin
  LogErrorMessage('InputDateTimeInterval(1)',E,[]);
  end;
end;
finally
FreeAndNil(_Form);
end;
end;


function InputDateTimeInterval(const ACaption, APrompt : string; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aMinDate, aMaxDate: TDateTime; aDays : integer; aOnlyInterval : boolean): boolean;
var
 stDate      : TDateTime;
 //fiDate      : TDateTime;
 baseDate    : TDate;
 DialogUnits : TPoint;
 _Form       : TForm;
 _LabDTP     : TLabel;
 _DTP        : TDateTimePicker;
 _Frm        : TInterval;
 _BBOk       : TButton;
 _BBcancel   : TButton;
 _LabInfo    : TLabel;
 _LabPrice   : TLabel;
 _CBPrice    : TComboBox;
begin
Result:=False;
_CBPrice:=nil;
_Form:=TForm.CreateNew(Application);
try
try
if trunc(aFrom)=0
   then stDate:=Date
   else stDate:=Trunc(aFrom);
//if trunc(aTo)=0
//   then fiDate:=Date
//   else fiDate:=Trunc(aTo);
baseDate:=Trunc(stDate);
with _Form do
  begin
  Canvas.Font := Font;
  DialogUnits := GetAveCharSize(Canvas);
  BorderStyle := bsSizeToolWin;
  Caption := ACaption;
  ClientWidth := MulDiv(180, DialogUnits.X, 4);
  Position := poScreenCenter;
  AutoScroll:=False;
  Height:=100;
  end;
_LabDTP:=TLabel.Create(_Form);
_DTP:=TDateTimePicker.Create(_Form);
with _LabDTP do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := MulDiv(8, DialogUnits.Y, 8);
  if Assigned(_DTP)
     then begin
     Caption:=APrompt;
     _Form.Width:= Width+_DTP.Width+Left*2+10;
     Hint:='Выбор даты для использования в установке интервала';
     end;
  ShowHint:=True;
  end;
if Assigned(_DTP)
   then with (_DTP)
          do begin
          Parent:=_Form;
          Top:=_LabDTP.Top-(Height div 2 - _LabDTP.Height div 2);
          Left:=_LabDTP.Left+_LabDTP.Width+10;
          Width:=Parent.ClientWidth - Left - 4;
          DateFormat:=dfLong;
          MinDate:=aMinDate;
          MaxDate:=aMaxDate;
          DateTime:=baseDate;
          Anchors:=[akLeft,akTop,akRight];
          end;
FullDays:=aDays;
_Frm:=TInterval.CreateDynamic(_Form,0               // Min time of interval
                                   ,1440*FullDays   // Max time ..... 1440
                                   ,0               // Min duration of interval
                                   ,60              // Inc/Dec step
                                   ,aFrom           // Begin Datetime( used time part)
                                   ,aTo);           // End Datetime (....)
with _Frm do
  begin
  Parent:=_Form;
  Left:=4;
  if Assigned(_DTP)
     then Top:=_DTP.Top+_DTP.Height+8
     else Top:=_LabDTP.Top+_LabDTP.Height+8;
  Width:=Parent.ClientWidth - Left*2;
  //Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')*3;
  Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')+Round(SliderHeight*3.5)+2;
  Anchors:=[akLeft,akTop,akRight];
  if Assigned(_Frm.OnMouseMove) then _Frm.OnMouseMove(_Frm,[],0,0);
  end;

_LabInfo:=TLabel.Create(_Form);
with _LabInfo do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _frm.Top+_frm.Height+4;
  AutoSize:=False;
  Width:=Parent.ClientWidth - Left*2;
  Caption:='...';
  Anchors:=[akLeft,akTop,akRight];
  Tag:=100500;
  ShowHint:=True;
  end;

if (Assigned(aItems) and (aItems.Count>0)) and not aOnlyInterval
then begin
_LabPrice:=TLabel.Create(_Form);
_CBPrice:=TComboBox.Create(_Form);
with _LabPrice do
  begin
  Parent:=_Form;
  FocusControl:=_CBPrice;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _LabInfo.Top+_LabInfo.Height+(FocusControl.Height div 2 - Height div 2);
  Caption:='Статус интервала';
  Hint:=Caption;
  Anchors:=[akLeft,akTop];
  ShowHint:=True;
  end;
_CBPrice:=TComboBox.Create(_Form);
with _CBPrice do
 begin
 Parent:=_Form;
 Left:=_LabPrice.Left+_LabPrice.Width+4;
 Top:=_LabPrice.Top - (Height div 2 - _LabPrice.Height div 2);
 Width:=Parent.ClientWidth - Left - 4;
 Anchors:=[akLeft,akTop,akRight];
 Style:=csDropDownList;
 Items.AddStrings(aItems);
 if aItemIndex=-1
    then aItemIndex:=0
    else ItemIndex:=aItemIndex;
 end;
end;
_BBCancel:=TButton.Create(_Form);
with _BBCancel do
 begin
 Parent:=_Form;
 Left:=4;
{$WARNINGS OFF}
 if Assigned(_CBPrice)
    then Top:=_CBPrice.Top+_CBPrice.Height+6
    else Top:=_LabInfo.Top+_LabInfo.Height+4;
{$WARNINGS ON}
 Width:=(Parent.ClientWidth - 8) div 2;
 Caption:='Отменить';
 ModalResult:=mrCancel;
 end;
_BBOk:=TButton.Create(_Form);
with _BBOk do
 begin
 Parent:=_Form;
 Left:=_BBCancel.Left+_BBCancel.Width;
 Top:=_BBCancel.Top;
 Width:=_BBCancel.Width;
 Caption:='Принять';
 ModalResult:=mrOk;
 end;
with _Form do
 begin
 Height:=_BBOk.Top+_BBOk.Height+(Height-ClientHeight)+4;
 Constraints.MinHeight:=Height;
 Constraints.MaxHeight:=Height;
 Constraints.MinWidth :=Width;
 end;
_BBCancel.Anchors:=[akBottom];
_BBOk.Anchors:=[akBottom];
if aOnlyInterval
   then begin
   _LabDTP.Caption:='Временнóй интервал';
   _LabDTP.Hint:='Установка временнóго интервала без указания даты';
   _DTP.Hide;
   end;
if _Form.ShowModal = mrOk
  then begin
  Result:=True;
  if Assigned(_CBPrice)
     then aItemIndex:=_CBPrice.ItemIndex
     else aItemIndex:=-1;
  _LabInfo.Caption:=NewIntervalResponse(_Form,_Frm.FirstPos,_Frm.SecondPos,aFrom,aTo);
  //if Assigned(_DTP)
  //   then _Frm.GetDateTimes(_DTP.DateTime,_DTP.DateTime,aFrom,aTo)
  //   else _Frm.GetDateTimes(stDate,fiDate,aFrom,aTo);
  end;
except
on E : Exception do
  begin
  LogErrorMessage('InputDateTimeInterval(2)',E,[]);
  end;
end;
finally
FreeAndNil(_Form);
end;
end;

function InputDateTimeInterval(const ACaption, APrompt : string; aBaseDate: TDateTime; var aFrom, aTo: TDateTime; const aItems:TStringList; var aItemIndex: integer; aMinDate, aMaxDate: TDateTime; aDays : integer; aOnlyInterval : boolean): boolean;
var
 stDate      : TDateTime;
 //fiDate      : TDateTime;
 baseDate    : TDate;
 DialogUnits : TPoint;
 _Form       : TForm;
 _LabDTP     : TLabel;
 _DTP        : TDateTimePicker;
 _Frm        : TInterval;
 _BBOk       : TButton;
 _BBcancel   : TButton;
 _LabInfo    : TLabel;
 _LabPrice   : TLabel;
 _CBPrice    : TComboBox;
begin
Result:=False;
_CBPrice:=nil;
_Form:=TForm.CreateNew(Application);
try
try
if aBaseDate=0
   then begin
   if trunc(aFrom)=0
      then stDate:=Date
      else stDate:=Trunc(aFrom);
   baseDate:=Trunc(stDate);
   end
   else baseDate:=Trunc(aBaseDate);
with _Form do
  begin
  Canvas.Font := Font;
  DialogUnits := GetAveCharSize(Canvas);
  BorderStyle := bsSizeToolWin;
  Caption := ACaption;
  ClientWidth := MulDiv(180, DialogUnits.X, 4);
  Position := poScreenCenter;
  AutoScroll:=False;
  Height:=100;
  end;
_LabDTP:=TLabel.Create(_Form);
_DTP:=TDateTimePicker.Create(_Form);
with _LabDTP do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := MulDiv(8, DialogUnits.Y, 8);
  if Assigned(_DTP)
     then begin
     Caption:=APrompt;
     _Form.Width:= Width+_DTP.Width+Left*2+10;
     Hint:='Выбор даты для использования в установке интервала';
     end;
  ShowHint:=True;
  end;
if Assigned(_DTP)
   then with (_DTP)
          do begin
          Parent:=_Form;
          Top:=_LabDTP.Top-(Height div 2 - _LabDTP.Height div 2);
          Left:=_LabDTP.Left+_LabDTP.Width+10;
          Width:=Parent.ClientWidth - Left - 4;
          DateFormat:=dfLong;
          MinDate:=aMinDate;
          MaxDate:=aMaxDate;
          DateTime:=baseDate;
          Anchors:=[akLeft,akTop,akRight];
          end;
FullDays:=aDays;
_Frm:=TInterval.CreateDynamic(_Form,0               // Min time of interval
                                   ,1440*FullDays   // Max time ..... 1440
                                   ,0               // Min duration of interval
                                   ,60              // Inc/Dec step
                                   ,baseDate
                                   ,aFrom           // Begin Datetime( used time part)
                                   ,aTo);           // End Datetime (....)
with _Frm do
  begin
  Parent:=_Form;
  Left:=4;
  if Assigned(_DTP)
     then Top:=_DTP.Top+_DTP.Height+8
     else Top:=_LabDTP.Top+_LabDTP.Height+8;
  Width:=Parent.ClientWidth - Left*2;
  //Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')*3;
  Height:=_Form.Canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88')+Round(SliderHeight*3.5)+2;
  Anchors:=[akLeft,akTop,akRight];
  if Assigned(_Frm.OnMouseMove) then _Frm.OnMouseMove(_Frm,[],0,0);
  end;

_LabInfo:=TLabel.Create(_Form);
with _LabInfo do
  begin
  Parent:=_Form;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _frm.Top+_frm.Height+4;
  AutoSize:=False;
  Width:=Parent.ClientWidth - Left*2;
  Caption:='...';
  Anchors:=[akLeft,akTop,akRight];
  Tag:=100500;
  ShowHint:=True;
  end;

if (Assigned(aItems) and (aItems.Count>0)) and not aOnlyInterval
then begin
_LabPrice:=TLabel.Create(_Form);
_CBPrice:=TComboBox.Create(_Form);
with _LabPrice do
  begin
  Parent:=_Form;
  FocusControl:=_CBPrice;
  Left := MulDiv(8, DialogUnits.X, 4);
  Top := _LabInfo.Top+_LabInfo.Height+(FocusControl.Height div 2 - Height div 2);
  Caption:='Статус интервала';
  Hint:=Caption;
  Anchors:=[akLeft,akTop];
  ShowHint:=True;
  end;
_CBPrice:=TComboBox.Create(_Form);
with _CBPrice do
 begin
 Parent:=_Form;
 Left:=_LabPrice.Left+_LabPrice.Width+4;
 Top:=_LabPrice.Top - (Height div 2 - _LabPrice.Height div 2);
 Width:=Parent.ClientWidth - Left - 4;
 Anchors:=[akLeft,akTop,akRight];
 Style:=csDropDownList;
 Items.AddStrings(aItems);
 if aItemIndex=-1
    then aItemIndex:=0
    else ItemIndex:=aItemIndex;
 end;
end;
_BBCancel:=TButton.Create(_Form);
with _BBCancel do
 begin
 Parent:=_Form;
 Left:=4;
{$WARNINGS OFF}
 if Assigned(_CBPrice)
    then Top:=_CBPrice.Top+_CBPrice.Height+6
    else Top:=_LabInfo.Top+_LabInfo.Height+4;
{$WARNINGS ON}
 Width:=(Parent.ClientWidth - 8) div 2;
 Caption:='Отменить';
 ModalResult:=mrCancel;
 end;
_BBOk:=TButton.Create(_Form);
with _BBOk do
 begin
 Parent:=_Form;
 Left:=_BBCancel.Left+_BBCancel.Width;
 Top:=_BBCancel.Top;
 Width:=_BBCancel.Width;
 Caption:='Принять';
 ModalResult:=mrOk;
 end;
with _Form do
 begin
 Height:=_BBOk.Top+_BBOk.Height+(Height-ClientHeight)+4;
 Constraints.MinHeight:=Height;
 Constraints.MaxHeight:=Height;
 Constraints.MinWidth :=Width;
 end;
_BBCancel.Anchors:=[akBottom];
_BBOk.Anchors:=[akBottom];
if aOnlyInterval
   then begin
   _LabDTP.Caption:='Временнóй интервал';
   _LabDTP.Hint:='Установка временнóго интервала без указания даты';
   _DTP.Hide;
   end;
if _Form.ShowModal = mrOk
  then begin
  Result:=True;
  if Assigned(_CBPrice)
     then aItemIndex:=_CBPrice.ItemIndex
     else aItemIndex:=-1;
  _LabInfo.Caption:=NewIntervalResponse(_Form,_Frm.FirstPos,_Frm.SecondPos,aFrom,aTo);
  //if Assigned(_DTP)
  //   then _Frm.GetDateTimes(_DTP.DateTime,_DTP.DateTime,aFrom,aTo)
  //   else _Frm.GetDateTimes(stDate,fiDate,aFrom,aTo);
  end;
except
on E : Exception do
  begin
  LogErrorMessage('InputDateTimeInterval(2)',E,[]);
  end;
end;
finally
FreeAndNil(_Form);
end;
end;


function NewIntervalResponse(aForm : TForm; aFirstMins, aSecondMins : int64; var aDateA, aDateB : TDateTime) : string;
const dtShb : string = 'dd.mm.yyyy hh:nn';
var
 cnt           : integer;
 baseDate      : TDate;
 baseMinutes   : int64;
begin
(*ATTENTION*) // -- возможно нужно округлять TDateTime до 10 знаков после запятой (для сравнения TDateTime)
baseDate:=0;
for cnt:=0 to aForm.ControlCount-1
  do if aForm.Controls[cnt] is TDateTimePicker
        then begin
        baseDate:=Trunc((aForm.Controls[cnt] as TDateTimePicker).Date);
        Break;
        end;
baseMinutes:=DateTimeToMinutes(baseDate);
aDateA  := MinutesToDateTime(baseMinutes+aFirstMins);
aDateB := MinutesToDateTime(baseMinutes+aSecondMins);
Result:=Format('с %s по %s',[FormatdateTime(dtShb,aDateA),FormatdateTime(dtShb,aDateB)]);
end;



(******************************************************************************)

constructor TInterval.Create(AOwner : TComponent);
begin
inherited Create(AOwner);
bmp:=TBitmap.Create;
bmp.Dormant;
bmp.FreeImage;
DoubleBuffered:=True;
MinPos:=0;
  MinPos:=9*60+2;
MaxPos:=24*60-1;
  MaxPos:=21*60;
RoundToMinutes:=0;
//  RoundToMinutes:=15;
RoundToMinutes:=7;
MinInterval:=0;
//  MinInterval:=120;
FirstPos:=9*60+2;
SecondPos:=18*60;
if (Assigned(AOwner) and (AOwner.InheritsFrom(TCustomForm)))
   then ParentFormHandle:=(AOwner as TCustomForm).Handle
   else ParentFormHandle:=0;
FirstClr  := ttobcRed;
SecondClr := ttobcGreen;
CanMoveInterval:=(Pos('MO2.exe',UpperCase(Application.ExeName))=0);
CheckAndRepair;
end;

constructor TInterval.CreateDynamic(AOwner : TComponent;aMinMinutes,aMaxMinutes,aMinInterval,aStep : integer;aFrom,aTo : TDateTime;aReceiverWnd : cardinal = 0);
var
 h,m,s,z : word;
 tmpMins : integer;
begin
inherited Create(AOwner);
bmp:=TBitmap.Create;
bmp.Dormant;
bmp.FreeImage;
DoubleBuffered:=True;
MinPos:=aMinMinutes;
if MinPos<0 then MinPos:=0;
MaxPos:=aMaxMinutes;
//if MaxPos>1439 then MaxPos:=1439;

RoundToMinutes:=aStep;
if RoundToMinutes=0 then RoundToMinutes:=1;
MinInterval:=aMinInterval;
DecodeTime(aFrom,h,m,s,z);
tmpMins:=h*60+m;
if tmpMins>=aMinMinutes
   then FirstPos:=tmpMins
   else FirstPos:=aMinMinutes;

DecodeTime(aTo,h,m,s,z);
tmpMins:=h*60+m + (Trunc(aTo) - Trunc(aFrom)) * 1440;
if tmpMins<=aMaxMinutes
   then SecondPos:=tmpMins
   else SecondPos:=aMaxMinutes;
ParentFormHandle:=aReceiverWnd;
FirstClr  := ttobcBlue;
SecondClr := ttobcBlue;
CanMoveInterval:=(Pos('MO2.exe',UpperCase(Application.ExeName))=0);
CheckAndRepair;
end;

constructor TInterval.CreateDynamic(AOwner : TComponent;aMinMinutes,aMaxMinutes,aMinInterval,aStep : integer;aBase,aFrom,aTo : TDateTime;aReceiverWnd : cardinal = 0);
var
 h,m,s,z : word;
 tmpMins : integer;
 days    : integer;
begin
inherited Create(AOwner);
bmp:=TBitmap.Create;
bmp.Dormant;
bmp.FreeImage;
DoubleBuffered:=True;
MinPos:=aMinMinutes;
if MinPos<0 then MinPos:=0;
MaxPos:=aMaxMinutes;
//if MaxPos>1439 then MaxPos:=1439;

if aBase>0
   then days:=Abs(Trunc(aBase) - Trunc(aFrom))
   else days:=0;

RoundToMinutes:=aStep;
if RoundToMinutes=0 then RoundToMinutes:=1;
MinInterval:=aMinInterval;
DecodeTime(aFrom,h,m,s,z);
tmpMins:=h*60+m+days*1440;
if tmpMins>=aMinMinutes
   then FirstPos:=tmpMins
   else FirstPos:=aMinMinutes;

DecodeTime(aTo,h,m,s,z);
tmpMins:=h*60+m + (Trunc(aTo) - Trunc(aFrom)) * 1440+days*1440;
if tmpMins<=aMaxMinutes
   then SecondPos:=tmpMins
   else SecondPos:=aMaxMinutes;
ParentFormHandle:=aReceiverWnd;
FirstClr  := ttobcBlue;
SecondClr := ttobcBlue;
CanMoveInterval:=(Pos('MO2.exe',UpperCase(Application.ExeName))=0);
CheckAndRepair;
end;



destructor TInterval.Destroy;
begin
bmp.Free;
DeleteObject(rgnPlus);
DeleteObject(rgnMinus);
DeleteObject(FirstRgn);
DeleteObject(SecondRgn);
DeleteObject(IntervalRgn);
inherited Destroy;
end;

procedure TInterval.GetDateTimes(const aDateFrom,aDateTo : TDateTime; var aResDateTimeFrom,aResDateTimeTo : TDateTime);
begin
aResDateTimeFrom:=Trunc(aDateFrom)+EncodeTime(fHour,fMinute,0,0);
aResDateTimeTo:=Trunc(aDateTo)+EncodeTime(sHour,sMinute,0,0);
end;

procedure TInterval.UpdateView;
begin
FrameResize(self);
CheckAndRepair;
end;

(******************************************************************************)

var
 PrevIntX        : integer;
 PrevIntX_OnDown : integer;

procedure TInterval.FrameResize(Sender: TObject);
begin
bmp.Width:=Width;
bmp.Height:=Height;
bmp.Canvas.Brush.Color:=Color;
bmp.Canvas.Font:=Font;
bmp.Canvas.FillRect(Rect(0,0,Width,Height));
ScaleWidth:=ClientWidth - SliderHeight;//Half * 2;
WidthKoef:=ScaleWidth / (1440 * FullDays - 1);
RevWidthKoef:= (1440 * FullDays - 1) / ScaleWidth;
if ShowDaysCtrl
   then begin
   rctPlus  := Bounds(ClientWidth-SliderHeight-2,ClientHeight-SliderHeight-2,SliderHeight,SliderHeight);
   GradientFigureRegion(rctPlus, figPlus, rgnPlus);
   rctMinus := Bounds(rctPlus.Left - SliderHeight-2, rctPlus.Top, SliderHeight,SliderHeight);
   GradientFigureRegion(rctMinus, figMinus, rgnMinus);
   end
   else begin
   rctPlus  := Bounds(Width+1,Height+1,0,0);
   if rgnPlus>0
      then DeleteObject(rgnPlus);
   rgnPlus:=0;
   rctMinus := Bounds(Width+1,Height+1,0,0);
   if rgnMinus>0
      then DeleteObject(rgnMinus);
   rgnMinus:=0;
   end;
Repaint;
end;

var
 InPlus  : boolean = false;
 InMinus : boolean = false;

procedure TInterval.FrameMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 InFirst   : boolean;
 InSecond  : boolean;
 InInterval: boolean;
begin
FocusedSlider:=fsNone;
if (Button=mbLeft)
   then begin
   if (ssLeft in Shift)
      then begin
      InFirst := PtInRegion(FirstRgn,X,Y);
      InSecond:= PtInRegion(SecondRgn,X,Y);
      InInterval:= PtInRegion(IntervalRgn,X,Y);
      InPlus:=PtInRegion(rgnPlus,X,Y);
      InMinus:=PtInRegion(rgnMinus,X,Y);
      if InFirst or InSecond
         then begin
         FocusedSlider:=fsSecond;
         if not InSecond and InFirst
            then FocusedSlider:=fsFirst;
         end
         else
      if InInterval
         then begin
         PrevIntX:=X;
         if CanMoveInterval
            then FocusedSlider:=fsInterval
            else FocusedSlider:=fsNone;
         end;
      end
      else begin

      end;
   end;
PrevIntX_OnDown:=X;
end;


  procedure TInterval.RoundMin;
  var
    RndPos      : integer;
    h,m,s,z     : word;
  begin
  RndPos:=FirstPos-MinPos;
  RndPos:=RoundByStep(RndPos,RoundToMinutes);
  //if RndPos<MinPos
  //   then RndPos:=MinPos;
  FirstPos:=RndPos+MinPos;
  DecodeTime(MinutesToDateTime(FirstPos),h,m,s,z);
  fHour:=h;
  fMinute:=m;
  (**)//fHour:=FirstPos div 60;
  (**)//fMinute:=FirstPos - fHour*60;
  end;

  procedure TInterval.RoundMax;
  var
    RndPos      : integer;
    h,m,s,z     : word;
  begin
  RndPos:=SecondPos;
  RndPos:=RoundByStep(RndPos,RoundToMinutes);
  if RndPos>MaxPos
     then RndPos:=MaxPos;
  SecondPos:=RndPos;
  DecodeTime(MinutesToDateTime(SecondPos),h,m,s,z);
  sHour:=h;
  sMinute:=m;
  (**)//sHour:=SecondPos div 60;
  (**)//sMinute:=SecondPos - sHour*60;
  end;


procedure TInterval.FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
 SliderIndex : integer;
 pos         : integer;
 pos1        : integer;
 pos2        : integer;
 delta       : integer;
 h,m,s,z     : word;
begin
if (FocusedSlider<>fsNone) and (ssLeft in Shift)
   then begin
   pos:=Round(RevWidthKoef * (x-SliderHeightHalf));
   if pos<MinPos then pos:=MinPos else
   if pos>integer(MaxPos) then pos:=MaxPos;
     case FocusedSlider of
     fsFirst  :
        begin
        if pos>=integer(SecondPos)
          then if (SecondPos=MaxPos)
                  then pos:=SecondPos-20// -- вот так захотелось, именно 20' (иначе потом не достанешь движок из-под правого)
                  else pos:=SecondPos
          else ;
        FirstPos :=pos;
        end;
     fsSecond :
        begin
        if pos<integer(FirstPos) then pos:=FirstPos+MinInterval;
        if pos>integer(MaxPos)
           then begin
           FirstPos:=MaxPos-60;
           pos:=MaxPos;
           end;
        SecondPos:=pos;
        end;
     fsInterval :
       begin
       delta:=SecondPos-FirstPos;
(*mode2 interval*) // -- begin --
       pos1:=Round(RevWidthKoef * Abs(PrevIntX));
       pos2:=Round(RevWidthKoef * Abs(X));
       if pos1 > pos2
          then begin
          FirstPos:=FirstPos - Abs(pos2-pos1);
          SecondPos:=FirstPos+delta;
          end
          else begin
          FirstPos:=FirstPos + Abs(pos2-pos1);
          SecondPos:=FirstPos+delta;
          end;
       PrevIntX:=X;
(*mode2 interval*) // -- end --
(*mode1 interval*) // -- begin --
//       if pos-Round(RevWidthKoef * Abs(X-PrevIntX))+delta<=MaxPos
//          then begin
//          FirstPos:=pos-Round(RevWidthKoef * Abs(X-PrevIntX));
//          SecondPos:=FirstPos+delta;
//          PrevIntX:=X;
//          end;
//       RoundMin;
//       RoundMax;
(*mode1 interval*) // -- end --
       end;
     end;
   if (MinInterval>0)
      then if SecondPos-FirstPos<=MinInterval
              then begin
              case FocusedSlider of
              fsFirst  : if SecondPos - MinInterval<MinPos
                            then begin
                            FirstPos := MinPos;
                            SecondPos:= FirstPos+MinInterval+1;
                            end
                            else begin
                            if FirstPos+MinInterval<MaxPos
                               then SecondPos:=FirstPos+MinInterval
                               else begin
                               SecondPos:=MaxPos;
                               FirstPos:= SecondPos - MinInterval;
                               end;
                            end;
              fsSecond : if FirstPos+MinInterval>MaxPos
                            then begin
                            FirstPos := MaxPos - MinInterval-RoundToMinutes-1;
                            SecondPos:= MaxPos-1;
                            end
                            else begin
                            if SecondPos-MinInterval>MinPos
                               then FirstPos:=SecondPos-MinInterval
                               else begin
                               FirstPos:=MinPos;
                               SecondPos:=FirstPos+MinInterval;
                               end;
                            end;
              fsInterval : ;
              end;
              end;
   PrevIntX_OnDown:=-1000; // это показатель того, что что-то двигали
   Invalidate;
   end
   else pos:=-1;
(**)//fHour   := FirstPos div 60;
(**)//fMinute := FirstPos - fHour*60;
(**)//sHour   := SecondPos div 60;
(**)//sMinute := SecondPos - sHour*60;

DecodeTime(MinutesToDateTime(FirstPos),h,m,s,z);
fHour:=h;
fMinute:=m;
DecodeTime(MinutesToDateTime(SecondPos),h,m,s,z);
sHour:=h;
sMinute:=m;

if RoundToMinutes>1
   then begin
case FocusedSlider of
fsFirst,fsSecond:
   begin
   delta:=SecondPos-FirstPos;
   if (MinInterval>0) and (delta<MinInterval)
      then delta:=MinInterval;
   SecondPos:=FirstPos+delta;
   RoundMin;
   RoundMax;
   end;
fsInterval :
   begin
   (*mode1 interval*) // -- begin --
   //RoundMin;
   //RoundMax;
   (*mode1 interval*) // -- end --
(**)//   SecondPos:=FirstPos+delta;
(**)//   sHour   := SecondPos div 60;
(**)//   sMinute := SecondPos - sHour*60;
   end;
end;
end;
if not (fHour in [0..23])  then fHour:=0;
if not (fMinute in [0..59])then fMinute:=0;

(**)//if sHour*60+sMinute>=1440 // -- проверка (на всякий случай, а то были прецеденты...) да и 24:00 не этично
(**)//     then begin
(**)//     sHour:=0;
(**)//     sMinute:=0;
(**)//     end;

SliderIndex:=integer(fsNone);
if PtInRegion(FirstRgn,X,Y)
   then SliderIndex:=integer(fsFirst)
   else
if PtInRegion(SecondRgn,X,Y)
   then SliderIndex:=integer(fsSecond)
   else
if PtInRegion(IntervalRgn,X,Y)
   then SliderIndex:=integer(fsInterval)
   ;

//Hint:='';
//case SliderIndex of
//integer(fsFirst) :
//  begin
//  if pos>-1
//     then begin
//     delta:=pos div 60;
//     Hint:='Реальное время : '+FormatDateTime('hh:nn',EncodeTime(delta,pos-delta*60,0,0))+#13#10;
//     end;
//  Hint:=Hint+'Уточненное время : '+FormatDateTime('hh:nn',EncodeTime(fHour,fMinute,0,0));
//  ShowHint:=True;
//  end;
//integer(fsSecond) :
//  begin
//   if pos>-1
//     then begin
//     delta:=pos div 60;
//     Hint:='Реальное время : '+FormatDateTime('hh:nn',EncodeTime(delta,pos-delta*60,0,0))+#13#10;
//     end;
//  Hint:=Hint+'Уточненное время : '+FormatDateTime('hh:nn',EncodeTime(sHour,sMinute,0,0));
//  ShowHint:=True;
//  end;
//integer(fsInterval):
//  begin
//
//  end;
//else self.Hint:='';
//end;
//Application.ActivateHint(Mouse.CursorPos);

if (ParentFormHandle>0) and (ParentFormHandle<>self.Handle)
   then begin
   SendMessage(ParentFormHandle,FRM_OVERSLIDER,FirstPos,pos);
   SendMessage(ParentFormHandle,FRM_FIRSTVALUES,pos*integer(SliderIndex=integer(fsFirst)),FirstPos);
   SendMessage(ParentFormHandle,FRM_SECONDVALUES,pos*integer(SliderIndex=integer(fsSecond)),SecondPos);
   SendMessage(ParentFormHandle,FRM_TIMEPAIR,MakeWParam(fHour,fMinute),MakeLParam(sHour,sMinute));
   sleep(1);
   end
   else SendMessage(self.Handle,FRM_SELFUPDATE,FirstPos,SecondPos);
end;

(******************************************************************************)

procedure TInterval.FrameMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 InFirst    : boolean;
 InSecond   : boolean;
 InInterval : boolean;
 pt         : TPoint;
 Clr        : TTriangleOrderBaseColorInt;
begin
Clr:=ttobcGray;
FocusedSlider:=fsNone;
if (Button=mbRight)
   then begin
   InFirst   := PtInRegion(FirstRgn,X,Y);
   InSecond  := PtInRegion(SecondRgn,X,Y);
   InInterval:= PtInRegion(IntervalRgn,X,Y);
   if InFirst or InSecond
      then begin
      FocusedSlider:=fsSecond;
      if not InSecond and InFirst
         then FocusedSlider:=fsFirst;
      end
      else
   if InInterval
      then FocusedSlider:=fsInterval;
   NClr_About.Tag:=integer(FocusedSlider);
   case FocusedSlider of
   fsNone   :
     begin
     NClr_About.Caption:='' ;
     end;
   fsFirst  :
     begin
     NClr_About.Caption:='Первый(левый) указатель. Скрыть меню' ;
     Clr:=FirstClr;
     end;
   fsSecond :
     begin
     NClr_About.Caption:='Второй(правый) указатель. Скрыть меню';
     Clr:=SecondClr;
     end;
   end;
   pt:=Point(X,Y);
   NClr_Gray.Checked  := (Clr=ttobcGray);
   NClr_Red.Checked   := (Clr=ttobcRed);
   NClr_Yellow.Checked:= (Clr=ttobcYellow);
   NClr_Green.Checked := (Clr=ttobcGreen);
   NClr_Blue.Checked  := (Clr=ttobcBlue);
   Windows.ClientToScreen(Handle,pt);
   if FocusedSlider in [fsFirst,fsSecond] then PM_Color.Popup(pt.X,pt.Y) else
   if FocusedSlider in [fsInterval] then PM_Interval.Popup(pt.X,pt.Y);
   end
   else
if (Button=mbLeft)
   then begin
   if PtInRegion(rgnPlus,X,Y) and inPlus
      then begin
      if FullDays<MaxDays then inc(FullDays);
      UpdateView;
      end
      else
  if PtInRegion(rgnMinus,X,Y) and inMinus
      then begin
      if FullDays>1 then dec(FullDays);
      UpdateView;
      end ;
   inPlus:=false;
   inMinus:=false;
   (*mode2 interval*) // -- begin--
   RoundMin;
   RoundMax;
   UpdateView;
   (*mode2 interval*) //-- end --
   end;

end;


procedure TInterval.SetSliderColor(Sender: TObject);
var
 Clr       : TTriangleOrderBaseColorInt;
 NeedSetClr: boolean;
begin
NeedSetClr:=True;
Clr:=ttobcGray;
if Sender=NClr_About  then  NeedSetClr:=False else
if Sender=NClr_Gray   then  Clr:=ttobcGray   else
if Sender=NClr_Red    then  Clr:=ttobcRed    else
if Sender=NClr_Yellow then  Clr:=ttobcYellow else
if Sender=NClr_Green  then  Clr:=ttobcGreen  else
if Sender=NClr_Blue   then  Clr:=ttobcBlue   else;
if NeedSetClr and (NClr_About.Tag>0)
   then case NClr_About.Tag of
        1 : FirstClr:=Clr;
        2 : SecondClr:=Clr;
        end;
Invalidate;
end;


procedure TInterval.FrameClick(Sender: TObject);
var
 pt : TPoint;
begin
GetCursorPos(pt);
Windows.ScreenToClient(self.Handle,pt);
if PtInRegion(IntervalRgn,pt.X,pt.Y) //and PrevIntX
   then SetInterval;
end;


procedure TInterval.NInt_SetIntervalClick(Sender: TObject);
begin
SetInterval(True);
end;





(******************************************************************************)
//procedure TInterval.CheckAndRepair;
//begin
//if MinPos<0 then MinPos:=0;
////if MaxPos>1439 then MaxPos:=1439;
//if RoundToMinutes<=0 then RoundToMinutes:=1;
//if MinInterval<0
//   then MinInterval:=0
//   else
//if MinInterval>1439
//   then MinInterval:=1439;
//if FirstPos<MinPos then FirstPos:=MinPos;
//if SecondPos>MaxPos then SecondPos:=MaxPos;
//if MinInterval>SecondPos-FirstPos then MinInterval:=SecondPos-FirstPos;
//end;

procedure TInterval.CheckAndRepair;
var
 h,m,s,z : word;
 prvMP   : integer;
begin
if MinPos<0 then MinPos:=0;
// mode_1
//MaxPos:=1440*FullDays;
// mode_2
prvMP:=MaxPos - 1440 * (MaxPos div 1440);
//MaxPos:=1440*(FullDays-1)+prvMP;
MaxPos:=1440*FullDays+prvMP;


if RoundToMinutes<=0 then RoundToMinutes:=1;
if MinInterval<0
   then MinInterval:=0
   else
if MinInterval>1439
   then MinInterval:=1439;
if SecondPos-FirstPos<MinInterval
   then SecondPos:=FirstPos+MinInterval;
if (FirstPos<MinPos) or
   (FirstPos>MaxPos) then FirstPos:=MinPos;
if (SecondPos<MinPos) or
   (SecondPos>MaxPos)
   then SecondPos:=MaxPos;
if SecondPos-FirstPos<MinInterval
   then SecondPos:=FirstPos+MinInterval;
DecodeTime(MinutesToDateTime(FirstPos),h,m,s,z);
  fHour:=h;
  fMinute:=m;
DecodeTime(MinutesToDateTime(SecondPos),h,m,s,z);
  sHour:=h;
  sMinute:=m;
Repaint;
end;


procedure TInterval.PaintHandler(var Msg : TMessage);
var
 rct    : TRect ;
 rctTxt : TRect ;
 wdtTxt : integer;
 tmp    : string;
 Hour   : integer;
 ps     : TPaintStruct;
 cntD   : integer;
 posX   : integer;
 posYa  : integer;
 posYb  : integer;
begin
//inherited;
//dc:=GetWindowDC(Handle);
dc:=BeginPaint(Handle,ps);
try

wdtTxt:=bmp.canvas.TextWidth('88'+FormatSettings.TimeSeparator+'88');
rct:=Bounds(SliderHeightHalf,wdtTxt+wdtTxt div 2,ClientWidth - SliderHeight,ScaleHeight);

bmp.Canvas.Brush.Color:=Color;
FillRect(bmp.Canvas.Handle,Rect(0,rct.Top,rct.Left,rct.Bottom),bmp.Canvas.Brush.Handle); // левее поля движка
FillRect(bmp.Canvas.Handle,Rect(rct.Right,rct.Top,ClientWidth,rct.Bottom),bmp.Canvas.Brush.Handle); // правее поля движка
FillRect(bmp.Canvas.Handle,Bounds(0,0,ClientWidth,rct.Top),bmp.Canvas.Brush.Handle); // выше поля движка
DrawFrameControl(bmp.Canvas.Handle,rct,DFC_BUTTON,DFCS_BUTTONPUSH or DFCS_PUSHED);
FillRect(bmp.Canvas.Handle,Bounds(0,rct.Bottom,ClientWidth,Sliderheight+1),bmp.Canvas.Brush.Handle);
if FullDays>1
   then begin
   posYa:=rct.top-SliderHeight-SliderHeightHalf;
   posYb:=rct.bottom+SliderHeight+SliderHeightHalf;
   for cntD:=0 to FullDays
     do begin
     bmp.Canvas.Pen.Color:=clGray;
     posX:=rct.Left+Round(1440*WidthKoef*cntD)-1;
     bmp.Canvas.MoveTo(posX, posYa);
     bmp.Canvas.LineTo(posX, posYb);
     end;
   end;


// -- first (start) slider draw
SimpleTriAngleOrderRGN(bmp.Canvas,Round(FirstPos*WidthKoef),rct.bottom,SliderHeight,FirstClr,FirstRgn);
 try
 //tmp:=FormatFloat('0',FirstPos);
 tmp:=FormatDateTime('hh:nn',EncodeTime(fHour,fMinute,0,0));
 except // -- этого в принципе быть не должно...., но тем не менее... и еще при отправке сообщения ...
 tmp:='--:--';
 if FirstPos<MinPos
    then begin
    FirstPos:=MinPos;
    SecondPos:=MinPos+MinInterval;
    end;
 end;
 bmp.canvas.Font.Color:=clBlack;
 rctTxt:=Bounds(Round(FirstPos*WidthKoef),ScaleHeight,wdtTxt,rct.Top);
 TextRotateDC(bmp.canvas.handle,bmp.canvas.Font.Handle,rctTxt,PWideChar(tmp),900);

// -- second (finish) slider draw
SimpleTriAngleOrderRGN(bmp.Canvas,Round(SecondPos*WidthKoef),rct.bottom,SliderHeight,SecondClr,SecondRgn);
 try
 //tmp:=FormatFloat('0',SecondPos);
 tmp:=FormatDateTime('hh:nn',EncodeTime(sHour,sMinute,0,0));
 except // -- этого в принципе быть не должно...., но тем не менее... и еще при отправке сообщения ...
 tmp:='xx:xx';
 if (SecondPos>MaxPos)
    then begin
    SecondPos:=MaxPos;
    FirstPos:=SecondPos-MinInterval;
    end;
 end;
 bmp.canvas.Font.Color:=clBlack;
 rctTxt:=Bounds(Round(SecondPos*WidthKoef),ScaleHeight,wdtTxt,rct.Top);
 //if tmp='23:59' then tmp:='00:00';
 TextRotateDC(bmp.canvas.handle,bmp.canvas.Font.Handle,rctTxt,PWideChar(tmp),900);

if MinPos>0
   then begin
   bmp.Canvas.Pen.Color:= clPaleRed;
   bmp.Canvas.Brush.Color:= clPaleRed;
   bmp.Canvas.Rectangle(rct.Left+2,rct.Top+2,Round(MinPos*WidthKoef)+rct.Left,rct.Top+ScaleHeight-2);
   end;
bmp.Canvas.Pen.Color:= clPaleGreen;
bmp.Canvas.Brush.Color:= clPaleGreen;
bmp.Canvas.Rectangle(Round(MinPos*WidthKoef)+rct.Left+2*Integer(MinPos=0),rct.Top+2,Round(MaxPos*WidthKoef)+rct.Left-Integer(MinPos=0),rct.Top+ScaleHeight-2);
if MaxPos<1440*FullDays // 1439
   then begin
   bmp.Canvas.Pen.Color:= clPaleRed;
   bmp.Canvas.Brush.Color:= clPaleRed;
  // bmp.Canvas.Rectangle(Round(MaxPos*WidthKoef)+rct.Left,rct.Top+2,Round(1439*WidthKoef)+rct.Left-1,rct.Top+ScaleHeight-2);
   bmp.Canvas.Rectangle(Round(MaxPos*WidthKoef)+rct.Left,rct.Top+2,Round((1440*FullDays)*WidthKoef)+rct.Left-1,rct.Top+ScaleHeight-2);
   end;

Hour:=MinPos div 60;
tmp:=FormatDateTime('hh:nn',EncodeTime(Hour,MinPos-Hour*60,0,0));
bmp.canvas.Font.Color:=clRed;
rctTxt:=Bounds(Round(MinPos*WidthKoef),ScaleHeight,wdtTxt,rct.Top);
//TextRotateDC(bmp.canvas.handle,bmp.canvas.Font.Handle,rctTxt,PWideChar(tmp),900);

(**)//Hour:=MaxPos div 60;
(**)//tmp:=FormatDateTime('hh:nn',EncodeTime(Hour,MaxPos-Hour*60,0,0));
tmp:=FormatDateTime('hh:nn',FnCommon.MinutesToDateTime(MaxPos));
bmp.canvas.Font.Color:=clRed;
rctTxt:=Bounds(Round(MaxPos*WidthKoef),ScaleHeight,wdtTxt,rct.Top);
//TextRotateDC(bmp.canvas.handle,bmp.canvas.Font.Handle,rctTxt,PWideChar(tmp),900);



rct:=Rect(Round(FirstPos*WidthKoef)+SliderheightHalf,rct.Top+1,Round(SecondPos*WidthKoef)+SliderheightHalf,rct.Bottom-1);
DrawFrameControl(bmp.Canvas.Handle,rct,DFC_BUTTON,DFCS_BUTTONPUSH);
if IntervalRgn>0
   then DeleteObject(IntervalRgn);
IntervalRgn:=CreateRectRgnIndirect(rct);
bmp.Canvas.Pen.Color:=clNavy;
bmp.Canvas.MoveTo(rct.Left-1,rct.Bottom);
bmp.Canvas.LineTo(rct.Left-1,rct.Top-7);
bmp.Canvas.MoveTo(rct.Right-1,rct.Bottom);
bmp.Canvas.LineTo(rct.Right-1,rct.Top-7);

if ShowDaysCtrl
   then begin
   bmp.Canvas.Brush.Color:=Color;
   bmp.Canvas.Pen.Color:=clBlack;
   //bmp.Canvas.FillRect(Rect(rctMinus.Left-2,rctMinus.Top-4,rctPlus.Right+2,rctPlus.Bottom+2));
   //bmp.Canvas.Rectangle(Rect(rctMinus.Left-2,rctMinus.Top-2,rctPlus.Right+2,rctPlus.Bottom+2));
   bmp.Canvas.FillRect(Rect(rctMinus.Left-2,rctMinus.Top-2,rctPlus.Right+2,rctPlus.Bottom+2));
   GradientFigure(bmp.Canvas,figPlus,rctPlus,clLime,'',clNavy,False);
   GradientFigure(bmp.Canvas, figMinus,rctMinus,clRed,'',clYellow,False);
   end;
finally
TransparentBlt(dc,0,0,bmp.Width,bmp.Height,bmp.Canvas.handle,0,0,bmp.Width,bmp.Height,Color);
//ReleaseDC(Handle,dc);
EndPaint(Handle,ps);
end;
end;


var
 _Form : TForm;
 _LInf : TLabel;
 _LfHM : TLabel;
 _EfH  : TEdit;
 _EfM  : TEdit;
 _LsHM : TLabel;
 _EsH  : TEdit;
 _EsM  : TEdit;
 _BBCn : TButton;
 _BBOk : TButton;


procedure TInterval.CheckInputData(Sender : TObject);
var
 Edit   : TEdit;
 tmpInt : integer;
begin
if (Sender is TEdit)
  then Edit:=(Sender as TEdit)
  else Edit:=nil;
if Assigned(Edit) and (Pos('HOUR',UpperCase(Edit.Name))<>0)
   then begin
   if Edit.Text<>''
      then tmpInt:=StrToInt(Edit.Text)
      else tmpInt:=-1;
   if not (tmpInt in [0..23])
      then Edit.Color:=clPaleRed
      else Edit.Color:=clPaleGreen;
   end
   else
if Assigned(Edit) and (Pos('MINUTE',UpperCase(Edit.Name))<>0)
   then begin
   if Edit.Text<>''
      then tmpInt:=StrToInt(Edit.Text)
      else tmpInt:=-1;
   if not (tmpInt in [0..59])
      then Edit.Color:=clPaleRed
      else Edit.Color:=clPaleGreen;
   end
   else ;
if Assigned(_Form) and Assigned(_BBOk)
   then begin
   _BBOk.Enabled:=False;
   for tmpInt:=0 to _Form.ControlCount-1
     do if (_Form.Controls[tmpInt] is TEdit)
           then if (_Form.Controls[tmpInt] as TEdit).Color<>clPaleGreen
                   then Exit;
   if (MinPos>(StrToInt(_EfH.Text)*60+StrToInt(_EfM.Text))) or
      (MaxPos<(StrToInt(_EsH.Text)*60+StrToInt(_EsM.Text)))
      then Exit;
   _BBOk.Enabled:=True;
   end;
end;



procedure TInterval.SetInterval(aForceStart : boolean = False);
  procedure CreateLabel(var aLabel : TLabel; aParent : TForm; aLeft,aTop : integer;const aName,aCaption : string);
  begin
  aLabel:=TLabel.Create(_Form);
  with aLabel do
    begin
    Parent:=aParent;
    Name:=aName;
    AutoSize:=False;
    Caption:=aCaption;
    Left := aLeft;
    Top := aTop;
    Width:=aParent.ClientWidth - Left*2;
    Anchors:=[akLeft,akTop,akRight];
    end;
  end;

  procedure CreateEdit(var aEdit : TEdit; aParent : TForm; aLeft,aTop : integer;const aName,aText : string);
  begin
  aEdit:=TEdit.Create(aParent);
  with aEdit do
    begin
    Parent:=aParent;
    Name:=aName;
    Top:=aTop;
    Left:=aLeft;
    Width:=(aParent.ClientWidth-6) div 2;
    NumbersOnly:=True;
    Text:=aText;
    Color:=clPaleGreen;
    Alignment:=taRightJustify;
    onChange:=CheckInputData;
    end;
  end;

  procedure CreateButton(var aButton : TButton; aParent : TForm; aLeft,aTop,aModalResult : integer;const aCaption : string);
  begin
  aButton:=TButton.Create(aParent);
  with aButton do
    begin
    Parent:=aParent;
    Top:=aTop;
    Left:=aLeft;
    Width:=(aParent.ClientWidth-6) div 2;
    caption:=aCaption;
    ModalResult:=aModalResult;
    end;
  end;

  function StrTimeFromMinutes(aMinutes : integer) : string;
  var
   ho : integer;
   mi : integer;
  begin
  ho:=aMinutes div 60;
  mi:=aMinutes - ho*60;
  Result:=FormatDateTime('hh'+FormatSettings.TimeSeparator+'nn',EncodeTime(ho,mi,0,0));
  end;
var
 pt          : TPoint;
 tmpFH : integer;
 tmpFM : integer;
 tmpSH : integer;
 tmpSM : integer;

begin
GetCursorPos(pt);
Windows.ScreenToClient(self.Handle,pt);
if not aForceStart
   then if (Abs(PrevIntX_OnDown-pt.X)>4) then Exit;

Windows.ClientToScreen(self.Handle,pt);
_Form:=TForm.CreateNew(Application);
try
with _Form do
 begin
 Canvas.Font := Font;
 BorderStyle := bsDialog;
 Caption := 'Установка интервала';
 ClientWidth := Canvas.TextWidth('Допустимый интервал с 00:00 по 00:00')+8+GetSystemMetrics(SM_CXFRAME);
 //PopupMode := pmAuto;
 //Position := poScreenCenter;
 AutoScroll:=False;
 Left:=pt.X;
 Top:=pt.Y;
 Height:=100;
 end;
CreateLabel(_LInf,_Form,4,4,'Label_Inf',Format('Допустимый интервал с %s по %s',[StrTimeFromMinutes(MinPos),StrTimeFromMinutes(MaxPos)]));
CreateLabel(_LfHM,_Form,4,_LInf.Top+_LInf.Height+4,'Label_First','Часы и минуты начала интервала');
CreateEdit(_EfH,_Form,2,_LfHM.Top+_LfHM.height+4,'FirstHOUR',IntToStr(fHour));
CreateEdit(_EfM,_Form,_EfH.Left+_EfH.Width+2,_LfHM.Top+_LfHM.height+4,'FirstMINUTE',IntToStr(fMinute));
CreateLabel(_LsHM,_Form,4,_EfM.Top+_EfM.Height+4,'Label_Second','Часы и минуты окончания интервала');
CreateEdit(_EsH,_Form,2,_LsHM.Top+_LsHM.height+4,'SecondHOUR',IntToStr(sHour));
CreateEdit(_EsM,_Form,_EsH.Left+_EsH.Width+2,_LsHM.Top+_LsHM.height+4,'SecondMINUTE',IntToStr(sMinute));
CreateButton(_BBCn,_Form,2,_EsM.Top+_EsM.Height+4,mrCancel,'Отменить');
CreateButton(_BBOk,_Form,_BBCn.Left+_BBCn.Width+2,_EsM.Top+_EsM.Height+4,mrOk,'Установить');
_Form.Height:=_BBOk.Top+_BBOk.Height+(_Form.height - _Form.ClientHeight)+4;
CheckInputData(_Form);
if _Form.ShowModal=mrOk
   then begin
   tmpFH := StrToInt(_EfH.Text);
   tmpFM := StrToInt(_EfM.Text);
   tmpSH := StrToInt(_EsH.Text);
   tmpSM := StrToInt(_EsM.Text);
   FirstPos:=tmpFH*60+tmpFM;
   SecondPos:=tmpSH*60+tmpSM;
   MouseMove([ssLeft],0,0);
   end;
finally
FreeAndNil(_Form);
end;
end;


procedure TInterval.FRM_SELFUPDATE_Handler(var aMSG : TMessage);
const dtShb : string = 'dd.mm.yyyy hh:nn';
var
 firstMinutes  : int64;
 secondMinutes : int64;
 cnt           : integer;
 lab           : TLabel;
 firstDT       : TDateTime;
 secondDT      : TDateTime;

begin
firstMinutes  := aMsg.WParam;
secondMinutes := aMsg.LParam;
aMsg.Result:=1;
ReplyMessage(aMsg.Result);
lab:=nil;
for cnt:=0 to Parent.ControlCount-1
  do if (Parent.Controls[cnt].Tag=100500) and (Parent.Controls[cnt] is TLabel)
        then lab:=Parent.Controls[cnt] as TLabel;
if Assigned(lab)
   then begin
   lab.Caption:=NewIntervalResponse(Parent as TForm,firstMinutes,secondMinutes,firstDT, secondDT);
   lab.Update;
   end;
end;




end.
