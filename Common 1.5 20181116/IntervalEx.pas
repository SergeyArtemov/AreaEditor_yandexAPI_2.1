unit IntervalEx;


interface

uses
   Windows
  ,Classes
  ,Graphics
  ,Controls
  ,Messages
  ,SysUtils
  ,Types
  ;


const
  sliderSize        = 25;
  clPaleGreen       = TColor($CCFFCC);
  clPaleRed         = TColor($CCCCFF);
  clLiteGray        = TColor($ECECEC);
  clPaleGray        = TColor($F8F8F8);
  wdtDelta          = 16; // -- смещение для использования в фунциях отображения и рссчетов "Позиция<>Значение" для слайдеров
  shbDT             = 'yyyymmdd hh:nn:00'; // -- XML шаблон datetime
  shbD              = 'yyyymmdd'; // -- XML шаблон date

  (*FnCommon*)
  XMLTitleWIN1251 = '<?xml version="1.0" encoding="windows-1251"?>';
  cr = #13;
  lf = #10;
  crlf = cr + lf;

type
TPairDateTime = record
 case Direct : boolean of
 false : ( Anchor          : TDate;
           offsetStartMin  : integer;
           offsetFinishMin : integer;
         );
 true  : (
     Start  : TDateTime;
     Finish : TDateTime;
         );
end;

TPairDateTimeList = record
  Items  :array of TPairDateTime;
  function Add(aStart, aFinish : TdateTime) : integer; overload;
  function Add(aAnchor : TDateTime; aoffsetStartMin, aoffsetFinishMin : integer) : integer; overload;
  function GetXML(aDirect : boolean) : string;
  function Clear : boolean;
end;


TDateTimeInterval = class;

 // -- СЛАЙДЕР-ДВИЖОК для указания интервала
 TIntSlider = class(TWinControl)
 private
    fValue    : int64;
    fDateTime : TDateTime;
    fOver     : boolean;
    fIndex    : integer;
    fIsFinish : boolean;
    fRGN      : hRGN;
    procedure SetValue(aVal : int64);
    procedure SetDateTime(aVal : TDateTime);
    function GetDateTime : TDateTime;

    procedure CMEnter(var aMsg : TMessage); message CM_MOUSEENTER;
    procedure CMLeave(var aMsg : TMessage); message CM_MOUSELEAVE;
    procedure WMLBDown(var aMsg : TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMove(var aMsg : TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLBUp(var aMsg : TWMLButtonDown); message WM_LBUTTONUP;
    procedure DoPaint;
    procedure WMPaint(var aMsg : TWMPaint); message WM_PAINT;
 protected
 public
    constructor CreateWithParams(AOwner: TDateTimeInterval; aVal : int64; aIndex : integer; aIsFinish : boolean);
    destructor Destroy; override;
 published
    property Value    : int64 read fValue write SetValue;
    property DateTime : TDateTime read GetDateTime write SetDateTime;
end;

 // -- пара слайдеров для указания интервала
 TSliderPair = record
  Start   : TIntSlider;
  Finish  : TIntSlider;
  Pressed : boolean;
  function Duration : TDateTime;
 end;

 // -- набор пар слайдеров
 TSliders = array of TSliderPair;

 // -- тип интервала
 TDTInterval =
  (  dti10min = 10
   , dti15min = 15
   , dti20min = 20
   , dti30min = 30
   , dti60min = 60
  );



 TIntervalUpdated = procedure(Sender : TObject; aIndex : integer) of object;

 // -- ОСНОВНОЙ ЭЛЕМЕНТ ОТОБРАЖЕНИЯ --------------------------------------------
 TDateTimeInterval = class(TWinControl)
 private
   // -- минимальное значение, все смещения относительного этого значения
   fMinVal      : int64;
   // -- максимально возможное значение, fMinVal+TSliderPair.osRight<=fMaxVal
   fMaxVal      : int64;
   // -- тип интервала
   fDTI         : TDTInterval;
   // -- движки-ограничители интервалов
   fSliders     : TSliders;
   // -- изменять граничные значения, если размеры интервалов выходят за них (см Конструктор)
   fExtMinMax   : boolean;
   // -- кол-во интервалов приуказанном типе и граничных значениях
   fIntCount    : int64;
   // -- максимальное кол-во пар движков (см Конструктор)
   fMaxSliders  : integer;
   // -- крайняя используемая пара слайдеров (крайний измененный индекс интервала)
   fLastUpdated : integer;
   // -- указатель на внешнюю процедуру onUpdate
   fIntervalUpdated : TIntervalUpdated;

   fShowDates   : boolean;

   procedure SetMinValue(Value : int64);
   procedure SetMaxValue(Value : int64);
   procedure RecalcIntervals(aMinVal, aMaxVal : int64; aDTI : TDTInterval); overload;
   procedure RecalcIntervals(aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval); overload;
   procedure SetLastUpdated(Value : integer);
   procedure DoPaint;
   procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
   procedure WMResize(var Message: TWMSize); message WM_SIZE;
   procedure InvalidateNonSlidersArea;
 protected
 public
    constructor CreateMain(AOwner: TComponent; aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval; aMaxCount : integer);
    destructor Destroy; override;
    // -- Добавление интервала aBegin: Начало, aEnd: Окончание, aIsOffset: Значения являются смещением отностительно минимума
    function AddInterval(aBegin, aEnd : TDateTime; aIsOffset : boolean = false) : integer;

    procedure DeleteInterval(aIndex : integer);
    // -- значение (в минутах, не приведенное к Минимуму) в позицию слайдера
    function ValToPos(Value : int64) : integer;
    // -- позиция слайдера в значение (в минутах, не приведенное к Минимуму)
    function PosToVal(Value : integer) : integer;
    // -- проверка обменивания слайдеров (при превашении начального значения интервала над конечным)
    procedure CheckSwapSpliders(aIndex : integer);

    procedure CallRecalcIntervals(aMove : boolean); overload;
    procedure CallRecalcIntervals(aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval); overload;

    procedure UpdateCrossList;

    function GetXML : string;
 published
    property onClick;
    property onDblClick;
    property onUpdated    : TIntervalUpdated read fIntervalUpdated write fIntervalUpdated;

    property MinValue     : int64 read fMinVal write SetMinValue;
    property MaxValue     : int64 read fMaxVal write SetMaxValue;
    property LastUpdated  : integer read fLastUpdated write SetLastUpdated;
    property IntervalType : TDTInterval read fDTI write fDTI;
    property Sliders      : TSliders read fSliders;
    property MaxCount     : integer read fMaxSliders;
end;

 // -- структура для обмена слайдеров
 TSliderParam = record
   Left : integer;
   Val  : integer;
 end;

 // -- тип пересечения интервалов
 TSliderCrossType  = ( sctStart  = $01  // -- интервал залез свои началом
                      ,sctFinish = $02  // -- интервал залез своим окончанием
                     );
 // -- общий набор пересечений для одного интервала
 TSliderCrossSet = set of TSliderCrossType;

 // -- список интервалов  - пересечений
 TSliderCrossItem = record
   OverIndex : integer;         // -- индекс интервала-пересечения
   CrossType : TSliderCrossSet; // -- тип перечечения
 end;
 TSliderCrossList = array of TSliderCrossItem;

 // -- структура-описание перечечений интервалов
 TSliderCrossDataItem = record
   SelfIndex  : integer; // -- индекс пары слайдеров
   CrossList  : TSliderCrossList; // -- список пар слайдеров с указанием чем они пересекаются с CheckIndex
   procedure CheckCross(aSelfIndex : integer; const aSliders : array of TSliderPair);
   procedure Clear;
 end;

 // -- описание точки-перечения
 TBorderPointItem = record
  XPos     : integer;   // --  позиция по Х-оси
  IsFinish : boolean;   // -- начальная или конечная точка в области пересечения
  indA     : integer;   // -- индекс одного интервала в пересечении (сортированны по возрастанию)
  indB     : integer;   // -- индекс второго интервала в пересечении (сортированны по возрастанию)
  resIndex : integer;   // -- индекс пересечения
 end;

 TDynRectArray = array of TRect;

 // -- структура для подготовки описания областей-пересечений
 TBorderPointList = record
  Items : array of TBorderPointItem;
  function Add(aPos : integer; aIsFinish : boolean; aIndA, aIndB : integer) : integer;
  procedure Pack(var aBorders : TDynRectArray);
  procedure Clear;
 end;

 // -- структура-описание областей-пересечений для отображения
 TSliderCrossDataList = record
   Items   : array of TSliderCrossDataItem; // -- предварительные данные
   Borders : TDynRectArray;                 // -- результатные прямоугольник областей-пересечений
   procedure FillItems(const aDTI : TDateTimeInterval);
   procedure Clear;
 end;


//procedure Register;

implementation

var
 SCDL : TSliderCrossDataList;

//procedure Register;
//begin
//  RegisterComponents('KHS',[TDateTimeInterval]);
//end;


function DateTimeToMinutes(aDateTime: TDateTime): int64;
var
  H, n, S, z: Word;
begin
  DecodeTime(aDateTime, H, n, S, z);
  Result := Trunc(aDateTime)* 1440+H * 60 + n ;
end;


function MinutesToDateTime(aMinutes: int64): TDateTime;
var
  days : DWORD;
  hours: DWORD;
  mins : DWORD;
begin
  days := aMinutes div 60 div 24;
  hours :=(aMinutes div 60)-(days * 24);
  mins := aMinutes - hours * 60 - days * 24 * 60;
  Result := days + EncodeTime(hours, mins, 0, 0);
end;


(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(*~~~ TPairDateTimeList ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
function TPairDateTimeList.Add(aStart, aFinish : TDateTime) : integer;
begin
Result:=-1;
try
Result:=Length(Items);
SetLength(Items,Result+1);
Items[Result].Direct:=true;
Items[Result].Start:=aStart; // !!! -- без проверки на больше / меньше
Items[Result].Finish:=aFinish;
except
 on E : Exception do //LogErrorMessage('',E,[]);
end;
end;

function TPairDateTimeList.Add(aAnchor : TDateTime; aoffsetStartMin, aoffsetFinishMin : integer) : integer;
begin
Result:=-1;
try
Result:=Length(Items);
SetLength(Items,Result+1);
Items[Result].Direct:=false;
Items[Result].Anchor:=aAnchor;
Items[Result].offsetStartMin:=aoffsetStartMin; // !!! -- без проверки на больше / меньше
Items[Result].offsetFinishMin:=aoffsetFinishMin;
except
 on E : Exception do //LogErrorMessage('',E,[]);
end;
end;

function TPairDateTimeList.GetXML(aDirect : boolean) : string;
var
 cnt : integer;
begin
Result:='';
try
if aDirect
   then for cnt:=0 to High(Items)
         do Result:=Result+Format('<PDT S="%s" F="%s"/>',[FormatDateTime(shbDT,Items[cnt].Start),FormatDateTime(shbDT,Items[cnt].Finish)])+crlf
   else for cnt:=0 to High(Items)
         do Result:=Result+Format('<PDT A="%s" OS="%d" OF="%d"/>',[FormatDateTime(shbD,Items[cnt].Anchor),Items[cnt].offsetStartMin,Items[cnt].offsetFinishMin])+crlf;
Result:=(*XMLTitleWIN1251+*)'<DATES>'+crlf+Result+'</DATES>';
except
 on E : Exception do //LogErrorMessage('',E,[]);
end;
end;

function TPairDateTimeList.Clear : boolean;
begin
Result:=False;
try
Setlength(Items,0);
Result:=True;
except
 on E : Exception do //LogErrorMessage('',E,[]);
end;
end;


(*~~~ TIntSlider ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure TIntSlider.SetValue(aVal : int64);
begin
if aVal<>Value then Value:=aVal;
//Parent.Repaint;
TDateTimeInterval(Parent).InvalidateNonSlidersArea;
end;


procedure TIntSlider.SetDateTime(aVal : TDateTime);
begin
SetValue(DateTimeToMinutes(aVal));
end;


function TIntSlider.GetDateTime : TDateTime;
var
 DTI  : TDateTimeInterval;
 _dti : int64;
begin
DTI:=TDateTimeInterval(Parent);
_dti:=integer(DTI.IntervalType);
Result:=MinutesToDateTime(DTI.MinValue+(Round(((**)DTI.PosToVal(self.Left)(**) -DTI. MinValue) / _dti) * _dti));
end;


procedure  TIntSlider.CMEnter(var aMsg : TMessage);
begin
inherited;
fOver:=true;
Repaint;
end;


procedure  TIntSlider.CMLeave(var aMsg : TMessage);
begin
inherited;
fOver:=false;
Repaint;
end;

var
 sX : integer ;
 sY  :integer ;

procedure TIntSlider.WMLBDown(var aMsg : TWMLButtonDown);
begin
sY:=Top;
sX:=aMsg.XPos;
BringToFront;
SetCaptureControl(self);
end;


procedure TIntSlider.WMMove(var aMsg : TWMMouseMove);
const
  SC_DRAGMOVE : Longint = $F012;
begin
if (aMsg.Keys and MK_LBUTTON <> 0)
   then begin
   Left := Left+(aMsg.XPos-sX);
   TDateTimeInterval(Parent).InvalidateNonSlidersArea;
   // SCDL.FillItems(TDateTimeInterval(self.Parent)); // -- можно и тут, но моргушек больше, вынесено ниже, в WMLBUp
   end;
inherited;
end;


procedure TIntSlider.WMLBUp(var aMsg : TWMLButtonDown);
begin
 SetCaptureControl(nil);
 fValue:=DateTimeToMinutes(GetDateTime);
 if fValue<TDateTimeInterval(Parent).MinValue
    then begin
    fvalue:=TDateTimeInterval(Parent).MinValue;
    Left:=wdtDelta-1 - sliderSize div 2;
    end
    else
 if fValue>TDateTimeInterval(Parent).MaxValue
    then begin
    fvalue:=TDateTimeInterval(Parent).MaxValue;
    Left:=TDateTimeInterval(Parent).ClientWidth-5 - sliderSize div 2;
    end;
 TDateTimeInterval(Parent).CheckSwapSpliders(fIndex);
 SCDL.FillItems(TDateTimeInterval(self.Parent));
end;


procedure TIntSlider.DoPaint;
var
 dc   : hDC;
 _bmp : TBitmap;
begin
dc:=GetWindowDC(Handle);
_bmp:=TBitmap.Create;
try
with _bmp do
  begin
  Width:=self.Width;
  Height:=self.Height;
  TransparentColor:=clFuchsia;
  Transparent:=True;
  end;
  _bmp.Canvas.Brush.Color:=_bmp.TransparentColor;
  _bmp.Canvas.FillRect(Bounds(0,0,Width,Height));
if fOver
   then _bmp.Canvas.Brush.Color:=clRed
   else _bmp.Canvas.Brush.Color:=clBlue ;
_bmp.Canvas.Pen.Color:=clBlack;
_bmp.Canvas.MoveTo(Width div 2, 2);
_bmp.Canvas.LineTo(Width - 2, Height - 2);
_bmp.Canvas.LineTo(2, Height - 2);
_bmp.Canvas.LineTo(Width div 2, 2);
_bmp.Canvas.FloodFill(Width div 2, height div 2, _bmp.Canvas.Pen.Color, fsBorder);

TransparentBlt(dc,0,0,Width,Height,_bmp.Canvas.Handle,0,0,Width,Height,ColorToRGB(_bmp.TransparentColor) );
finally
_bmp.Free;
ReleaseDC(Handle,dc);
end;
end;


procedure TIntSlider.WMPaint(var aMsg : TWMPaint);
begin
inherited;
DoPaint;
end ;


constructor TIntSlider.CreateWithParams(AOwner: TDateTimeInterval; aVal : int64; aIndex : integer; aIsFinish : boolean);
var
 pts : array[0..2] of TPoint;
 rgnRe : hRGN;
begin
inherited Create(AOwner);
Parent:=AOwner;
fValue:=aVal;
fIndex:=aIndex;
fIsFinish:=aIsFinish;
fDateTime:=GetDateTime;
Left:=AOwner.ValToPos(fValue) ;
Top:=sliderSize*2+4;
Width:=sliderSize;
Height:=sliderSize;
pts[0]:=Point(Width div 2,0);
pts[1]:=Point(Width,Height);
pts[2]:=Point(0,Height);
fRGN:=CreatePolygonRgn(pts,Length(pts),WINDING);
rgnRe:=CreateRectRgnIndirect(BoundsRect);
try
CombineRgn(fRGN,rgnRe,fRGN,RGN_XOR);
SetWindowRgn(Handle,fRGN,True);
finally
DeleteObject(rgnRe);
end;
DoubleBuffered:=true;
end;


destructor TIntSlider.Destroy;
begin

DeleteObject(fRGN);
inherited Destroy;
end;

(*~~~ TSliderPair ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

function TSliderPair.Duration : TDateTime;
begin
Result:=Finish.DateTime - Start.DateTime;
end;


(*~~~ TDateTimeInterval ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure TDateTimeInterval.SetMinValue(Value : int64);
begin
if Value<>fMinVal
   then begin
   fMinVal:=Value;
   Invalidate;
   end;
RecalcIntervals(fMinVal, fMaxVal, fDTI);
end;

procedure TDateTimeInterval.SetMaxValue(Value : int64);
begin
if Value<>fMaxVal
   then begin
   fMaxVal:=Value;
   Invalidate;
   end;
RecalcIntervals(fMinVal, fMaxVal, fDTI);
end;


procedure TDateTimeInterval.SetLastUpdated(Value : integer);
begin
if Value<>fLastUpdated
   then begin
   fLastUpdated:=Value;
   Invalidate;
   if Assigned(fIntervalUpdated)
     then fIntervalUpdated(self,fLastUpdated);
   end;
end;


procedure TDateTimeInterval.RecalcIntervals(aMinVal, aMaxVal : int64; aDTI : TDTInterval);
var
 _dti      : integer;
 tmp_int64 : int64;
begin
fDTI:=aDTI;
_dti:=integer(fDTI);
// -- подготовка границ
fMinVal:=aMinVal;
fMaxVal:=aMaxVal;
if fMinVal>fMaxVal
   then begin
   tmp_int64:=fMinVal;
   fMinVal:=fMaxVal;
   fMaxVal:=tmp_int64;
   end;
fMinVal:=fMinVal-(fMinVal mod _dti);
if fMaxval mod _dti>0
   then fMaxval:=fMaxval+(_dti-(fMaxval mod _dti));
// -- общая продолжительность наблюдаемого интервала
fIntCount:=Trunc((fMaxval - fMinVal) / _dti);
end;


procedure TDateTimeInterval.RecalcIntervals(aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval);
begin
fDTI:=aDTI;
fMinVal:=DateTimeToMinutes(aMinVal);
fMaxVal:=DateTimeToMinutes(aMaxVal);
RecalcIntervals(fMinVal, fMaxVal, fDTI);
end;


(* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)

procedure TDateTimeInterval.DoPaint;
var
  _bmp    : TBitmap;
  rctBase : TRect;
  procedure ShowSliders(aIndex : integer ; aLastUdated : boolean);
  var
   slTop     : integer;
   slBottom1 : integer;
   slBottom2 : integer;
   slLeft    : integer;
   slRight   : integer;
   rctMsg    : TRect;
   strMsg    : string;
   minDate   : TDate;
   stDay     : integer;
   stDayMsg  : string;
   fiDay     : integer;
   fiDayMsg  : string;
  begin
  slTop:=fSliders[aIndex].Start.Top;
  slBottom1:=fSliders[aIndex].Start.Top+fSliders[aIndex].Start.Height;
  slBottom2:=fSliders[aIndex].Start.Top+fSliders[aIndex].Start.Height+2+aIndex*2;
  slLeft:=fSliders[aIndex].Start.Left+fSliders[aIndex].Start.Width div 2;
  slRight:=fSliders[aIndex].Finish.Left+fSliders[aIndex].Finish.Width div 2;
    _bmp.Canvas.MoveTo(slLeft,4);
    _bmp.Canvas.LineTo(slLeft,slTop);

    _bmp.Canvas.MoveTo(slLeft,slBottom1);
    _bmp.Canvas.LineTo(slLeft,slBottom2);
    _bmp.Canvas.LineTo(slRight,slBottom2);
    _bmp.Canvas.LineTo(slRight,slBottom1);

    _bmp.Canvas.MoveTo(slRight,slTop);
    _bmp.Canvas.LineTo(slRight,4);

  _bmp.Canvas.Brush.Color:=clPaleGreen;
  _bmp.Canvas.Rectangle(Rect(slLeft+2,rctBase.Top+4, slRight-1, rctBase.Bottom-4));
  rctMsg:=Rect(fSliders[aIndex].Start.Left,slBottom2+2, fSliders[aIndex].Finish.Left+fSliders[aIndex].Finish.Width, ClientHeight-2);
  if aLastUdated
     then _bmp.Canvas.Brush.Color:=clWhite
     else _bmp.Canvas.Brush.Color:=clPaleGray;
  _bmp.Canvas.Rectangle(rctMsg);
  SetBkMode(_bmp.Canvas.handle,TRANSPARENT);
  //strMsg:=FormatDateTime('dd.mm.yyyy hh:nn',MinutesToDateTime(fMinVal+(Round(((**)PosToVal(fSliders[aIndex].Start.Left)(**) - fMinVal) / integer(fDTI)) * integer(fDTI))))+' '+
  //        FormatDateTime('dd.mm.yyyy hh:nn',MinutesToDateTime(fMinVal+(Round(((**)PosToVal(fSliders[aIndex].Finish.Left)(**) - fMinVal) / integer(fDTI)) * integer(fDTI))));
  minDate:=Trunc(MinutesToDateTime(fMinVal));
  with fSliders[aIndex] do
  if fShowDates
     then strMsg:=FormatDateTime('dd.mm.yyyy hh:nn',Start.DateTime)+' '+
          FormatDateTime('dd.mm.yyyy hh:nn',Finish.DateTime)
     else begin
     stDay:=Trunc(Start.DateTime - minDate);
     //stDayMsg:='День "Д"';
     //if stDay>0
     //   then stDayMsg:=stDayMsg+'+'+IntToStr(stDay);
     stDayMsg:=IntToStr(stDay+1)+'»';
     fiDay:=Trunc(Finish.DateTime - minDate);
     //fiDayMsg:='День "Д"';
     //if fiDay>0 then fiDayMsg:=fiDayMsg+'+'+IntToStr(fiDay);
     fiDayMsg:=IntToStr(fiDay+1)+'»';
     strMsg:=stDayMsg + FormatDateTime(' hh:nn',Start.DateTime)+' '+crlf+
             fiDayMsg + FormatDateTime(' hh:nn',Finish.DateTime)
     end;
       //   +#13+Format('%d %d',[Start.fValue, Finish.fValue]);
  DrawText(_bmp.Canvas.handle,strMsg,Length(strMsg),rctMsg,DT_CENTER or DT_VCENTER or DT_WORDBREAK);
  SetBkMode(_bmp.Canvas.handle,OPAQUE);
  end;

var
 dc      : hDC;
 PS      : TPaintStruct; // -- через BeginPaint субъективно меньше моргает (из WM_PAINT убрал inherited !!!! см. Controls.TWinControl.WMPaint (строка 10104))
 cntSP   : integer;
 txtWdt  : integer;
 txtHgt  : integer;
 szFont  : integer;
 strTxt  : string;
 rctTxt  : TRect;
 days    : integer;
begin
dc:=BeginPaint(Handle,PS);
_bmp:=TBitmap.Create;
try
with _bmp do
  begin
  Width:=self.Width;
  Height:=self.Height;
  TransparentColor:=clFuchsia;
  Transparent:=True;
  end;
  _bmp.Canvas.Brush.Color:=_bmp.TransparentColor;
  _bmp.Canvas.FillRect(Bounds(0,0,Width,Height));
  _bmp.Canvas.Brush.Color:=clBtnFace;
  _bmp.Canvas.RoundRect(0,0,_bmp.Width,_bmp.Height,10,10);

txtHgt:=_bmp.Canvas.TextHeight('ЙQ')+4;
//rctBase:=Rect(4,txtHgt+txtHgt div 2+4,ClientWidth-4, ClientHeight div 2 - 2);
rctBase:=Rect(wdtDelta-1,sliderSize,ClientWidth-4, sliderSize*2);
_bmp.Canvas.Brush.Color:=clInfoBk;
_bmp.Canvas.Rectangle(rctBase);

// -- рисуем признак интервала
strTxt:=Format('%d',[integer(fDTI)]);//
rctTxt:=Rect(1,rctBase.Top,rctBase.Left,rctBase.Bottom);
_bmp.Canvas.Brush.Color:=clBtnFace;
_bmp.Canvas.Pen.Color:=clRed;
txtWdt:=(rctTxt.Right-rctTxt.Left);
_bmp.Canvas.Ellipse(Bounds(rctTxt.Left, rctTxt.Top+((rctTxt.Bottom-rctTxt.Top)-txtWdt) div 2,txtWdt,txtWdt));
szFont:=_bmp.Canvas.Font.Size;
_bmp.Canvas.Font.Size:=6;
try
SetBkMode(_bmp.Canvas.handle,TRANSPARENT);
DrawText(_bmp.Canvas.Handle, strTxt, Length(strTxt), rctTxt, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
SetBkMode(_bmp.Canvas.handle,OPAQUE);
finally
_bmp.Canvas.Font.Size:=szFont;
end;

// -- рисуем околослайдерную обстановку (связи, информационные панели)
_bmp.Canvas.Pen.Color:=clBlack;
szFont:=_bmp.Canvas.Font.Size;
_bmp.Canvas.Font.Size:=8;
try
for cntSP:=0 to High(fSliders)
  do begin
  if cntSP=fLastUpdated then Continue;
  ShowSliders(cntSP,false);
  end;
if (fLastUpdated>=Low(fSliders)) and (fLastUpdated<=High(fSliders))
  then ShowSliders(fLastUpdated, true);
finally
_bmp.Canvas.Font.Size:=szFont;
end;

// -- отображение пересекающихся интервалов
for cntSP:=0 to High(SCDL.Borders)
  do begin
  with SCDL.Borders[cntSP] do
    begin
    Top:=rctBase.Top+6;
    Bottom:=rctBase.Bottom-6;
    end;
  _bmp.Canvas.Pen.Color:=clRed;
  _bmp.Canvas.Brush.Color:=clPaleRed;
  _bmp.Canvas.Rectangle(SCDL.Borders[cntSP]);
  end;

// -- отображение граничных TDateTime-ов
// -- начало --
if fShowDates
   then begin
   strTxt:=FormatDateTime('dd.mm.yyyy'#13' hh:nn',MinutesToDateTime(fMinVal));
   txtWdt:=_bmp.canvas.TextWidth(strTxt);
   end
   else begin
   strTxt:=FormatDateTime('hh:nn',MinutesToDateTime(fMinVal));
   txtWdt:=_bmp.canvas.TextWidth(strTxt);
   end;
rctTxt:=Bounds(rctBase.Left,rctBase.Top - txtHgt ,txtWdt,txtHgt);
_bmp.Canvas.Brush.Color:=clBtnFace;
_bmp.Canvas.Pen.Color:=clBtnFace;
_bmp.Canvas.Rectangle(rctTxt);
SetBkMode(_bmp.Canvas.handle,TRANSPARENT);
DrawText(_bmp.Canvas.Handle, strTxt, Length(strTxt), rctTxt, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
SetBkMode(_bmp.Canvas.handle,OPAQUE);
// -- окончание --
if fShowdates
   then begin
   strTxt:=FormatDateTime('dd.mm.yyyy'#13' hh:nn',MinutesToDateTime(fMaxVal));
   txtWdt:=_bmp.canvas.TextWidth(strTxt);
   end
   else begin
   days:=Trunc(MinutesToDateTime(fMaxVal)) - Trunc(MinutesToDateTime(fMinVal));
   strTxt:=IntToStr(days) + ' дн. ' + FormatDateTime('hh:nn',MinutesToDateTime(fMaxVal));
   txtWdt:=_bmp.canvas.TextWidth(strTxt);
   end;
rctTxt:=Bounds(rctBase.Right-txtWdt,rctBase.Top - txtHgt ,txtWdt,txtHgt);
_bmp.Canvas.Brush.Color:=clBtnFace;
_bmp.Canvas.Pen.Color:=clBtnFace;
_bmp.Canvas.Rectangle(rctTxt);
SetBkMode(_bmp.Canvas.handle,TRANSPARENT);
DrawText(_bmp.Canvas.Handle, strTxt, Length(strTxt), rctTxt, DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
SetBkMode(_bmp.Canvas.handle,OPAQUE);
TransparentBlt(dc,0,0,Width,Height,_bmp.Canvas.Handle,0,0,Width,Height,ColorToRGB(_bmp.TransparentColor) );
finally
_bmp.Free;
EndPaint(Handle,PS);
ReleaseDC(Handle,dc);
end;
end;


procedure TDateTimeInterval.WMPaint(var Message: TWMPaint);
begin
DoPaint;
end;


procedure TDateTimeInterval.WMResize(var Message: TWMSize);
begin
Repaint;
inherited;
end;


procedure TDateTimeInterval.InvalidateNonSlidersArea;
var
 rct : TRect;
begin
rct:=Rect(0,0,ClientWidth,sliderSize*2+4);
InvalidateRect(Handle,rct,true);
rct:=Rect(0,sliderSize*3+4,ClientWidth,ClientHeight);
InvalidateRect(Handle,rct,true);
end;


constructor TDateTimeInterval.CreateMain(AOwner: TComponent; aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval; aMaxCount : integer);
var
 _date : TdateTime;
begin
inherited Create(AOwner);
fMaxSliders:=aMaxCount;
fExtMinMax:=false;
fShowDates:=false;
if fShowDates
   then RecalcIntervals(aMinVal, aMaxVal, aDTI)
   else begin
   _date:=aMinVal; // Date
   fDTI:=aDTI;
   fMinVal:=DateTimeToMinutes(Trunc(_date)+Frac(aMinVal));
   fMaxVal:=DateTimeToMinutes(Trunc(_date)+(Trunc(aMaxVal) - Trunc(_date))+Frac(aMaxVal));
   RecalcIntervals(fMinVal, fMaxVal, fDTI);
   end;
end;


destructor TDateTimeInterval.Destroy;
begin

inherited Destroy;
end;


function TDateTimeInterval.AddInterval(aBegin, aEnd : TDateTime; aIsOffset : boolean = false) : integer;
var
 cnt   : integer;
 a,b,c : int64;
begin
Result:=-1;
if fMaxSliders=Length(fSliders)
   then Exit;
for cnt:=0 to High(fSliders)
  do fSliders[cnt].Pressed:=false;
a:=DateTimeToMinutes(aBegin);
b:=DateTimeToMinutes(aEnd);
if a>b
   then begin
   c:=a;
   a:=b;
   b:=c;
   end;
if aIsOffset
   then begin
   a:=fMinVal+a;
   b:=fMaxVal+b;
   end;
for cnt:=0 to High(fSliders)
  do if ((fSliders[cnt].Start.Value   = a) and (fSliders[cnt].Finish.Value = b)) or // -- точное совпадение
        ((fSliders[cnt].Start.Value   <= a) and (fSliders[cnt].Finish.Value >= b))  // -- внутри существующего
        then begin
        Result:=cnt;
        Exit;
        end;
if a<fMinVal
  then if fExtMinMax
          then fMinVal:=a
          else a:=fMinVal;
if b>fMaxVal
  then if fExtMinMax
          then fMaxVal:=b
          else b:=fMaxVal;
RecalcIntervals(fMinVal, fMaxVal, fDTI);
Result:=Length(fSliders);
Setlength(fSliders, Result+1);
fSliders[Result].Start:=TIntSlider.CreateWithParams(self, a, Result, false);
fSliders[Result].Finish:=TIntSlider.CreateWithParams(self, b, Result, true);
fSliders[Result].Pressed:=True;
fLastUpdated:=Result;
end;


procedure TDateTimeInterval.DeleteInterval(aIndex : integer);
var
 cnt : integer;
 slA : TSliderParam;
 slB : TSliderParam;
begin
if (aIndex>=Low(fSliders)) and (aIndex<=High(fSliders))
   then begin
   for cnt:=aIndex+1 to High(fSliders)
     do begin
     slA.Left:=fSliders[cnt].Start.Left;
     slA.Val:=fSliders[cnt].Start.Value;
     slB.Left:=fSliders[cnt].Finish.Left;
     slB.Val:=fSliders[cnt].Finish.Value;
     fSliders[cnt-1].Start.Free;
     fSliders[cnt-1].Start:=TIntSlider.CreateWithParams(self,slA.Val,aIndex,false);
     fSliders[cnt-1].Start.Left:=slA.Left;
     fSliders[cnt-1].Finish.Free;
     fSliders[cnt-1].Finish:=TIntSlider.CreateWithParams(self,slB.Val,aIndex,true);
     fSliders[cnt-1].Finish.Left:=slB.Left;
     end;

   cnt:=High(fSliders);
   fSliders[cnt].Start.Free;
   fSliders[cnt].Finish.Free;
   fSliders[cnt].Pressed:=false;

   SetLength(fSliders,Length(fSliders)-1);
   end;
Repaint;
Update;
end;


function TDateTimeInterval.ValToPos(Value : int64) : integer;
var
 offVal : int64;
begin
offVal:=Value - fMinVal;
Result:=Trunc(offVal / ((fMaxVal - fMinVal) / (Width-wdtDelta)));
end;


function TDateTimeInterval.PosToVal(Value : integer) : integer;
var
 direct : integer;
begin
direct:=1;
//if aIsFinish then direct:=direct*0;
Result := Trunc((fMaxVal - fMinVal) / (Width-wdtDelta*direct) * Value) + fMinVal;
end;


procedure TDateTimeInterval.CheckSwapSpliders(aIndex : integer);
var
 slA : TSliderParam;
 slB : TSliderParam;
begin
fLastUpdated:=aIndex;
if fSliders[aIndex].Start.Left>fSliders[aIndex].Finish.Left
   then begin
   slA.Left:=fSliders[aIndex].Finish.Left;
   slA.Val:=fSliders[aIndex].Finish.Value;
   slB.Left:=fSliders[aIndex].Start.Left;
   slB.Val:=fSliders[aIndex].Start.Value;
   fSliders[aIndex].Start.Free;
   fSliders[aIndex].Start:=TIntSlider.CreateWithParams(self,slA.Val,aIndex,false);
   fSliders[aIndex].Start.Left:=slA.Left;
   fSliders[aIndex].Finish.Free;
   fSliders[aIndex].Finish:=TIntSlider.CreateWithParams(self,slB.Val,aIndex,true);
   fSliders[aIndex].Finish.Left:=slB.Left;
   end;
Repaint;
if Assigned(fIntervalUpdated)
   then fIntervalUpdated(self,fLastUpdated);
end;

procedure TDateTimeInterval.CallRecalcIntervals(aMove : boolean);
begin
if aMove
   then
   else RecalcIntervals(fMinVal, fMaxVal, fDTI);
end;

procedure TDateTimeInterval.CallRecalcIntervals(aMinVal, aMaxVal : TDateTime; aDTI : TDTInterval);
begin
RecalcIntervals(aMinVal, aMaxVal, aDTI);
Repaint;
Update;
end;

procedure TDateTimeInterval.UpdateCrossList;
begin
SCDL.FillItems(self);
Repaint;
Update;
end;


function TDateTimeInterval.GetXML : string;
var
  cnt : integer;
begin
Result:='';
try
// ВНИМАНИЕ!!!
// 1. В этом режиме использовать конструкцию "DATEADD(mi,t.r.value('@OS', 'int'),t.r.value('@A', 'datetime'))"
// 2. При отсутствии -fMinVal использовать конструкцию "DATEADD(mi,t.r.value('@OS', 'int'),-2)"
for cnt:=0 to High(fSliders)
   do begin
   Result:=Result+Format('<I S="%s" F="%s" A="%s" OS="%d" OF="%d"/>',[
                   FormatDateTime(shbDT,fSliders[cnt].Start.DateTime)
                  ,FormatDateTime(shbDT,fSliders[cnt].Finish.DateTime)
                  ,FormatDateTime(shbDT,MinutesToDateTime(fMinVal))
                  ,fSliders[cnt].Start.Value - fMinVal
                  ,fSliders[cnt].Finish.Value - fMinVal
                  ])+crlf;
   end;
Result:=(*XMLTitleWIN1251+*)'<INTERVALS DAYS="'+IntToStr((fMaxVal-fMinVal) div 1440)+'" STEP="'+IntToStr(integer(fDTI))+'">'+crlf+Result+'</INTERVALS>';
except
 on E : Exception do ;
end;
end;


(*~~~ TSliderCrossDataItem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure TSliderCrossDataItem.CheckCross(aSelfIndex : integer; const aSliders : array of TSliderPair);
var
 cnt            : integer;
 res            : TSliderCrossSet;
 selfDTStart    : TDateTime;
 selfDTFinish   : TDateTime;
 checkDTStart   : TDateTime;
 checkDTFinish  : TDateTime;
 ind            : integer;
begin
Clear;
SelfIndex:=aSelfIndex;
selfDTStart:=aSliders[SelfIndex].Start.GetDateTime;
selfDTFinish:=aSliders[SelfIndex].Finish.GetDateTime;
for cnt:=0 to High(aSliders)
  do begin
  if cnt=SelfIndex then Continue;
  res:=[];
  checkDTStart:=aSliders[cnt].Start.GetDateTime;
  checkDTFinish:=aSliders[cnt].Finish.GetDateTime;
  if (checkDTStart>=selfDTStart) and (checkDTStart<=selfDTFinish)
     then res:=res+[sctStart];
  if (checkDTFinish>=selfDTStart) and (checkDTFinish<=selfDTFinish)
     then res:=res+[sctFinish];
  if res<>[]
     then begin
     ind:=Length(CrossList);
     SetLength(CrossList,ind+1);
     CrossList[ind].OverIndex:=cnt;
     CrossList[ind].CrossType:=res;
     end;
  end;
end;

procedure TSliderCrossDataItem.Clear;
begin
SetLength(CrossList,0);
SelfIndex:=-1;
end;

(*~~~ TBorderPointList ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

function TBorderPointList.Add(aPos : integer; aIsFinish : boolean; aIndA, aIndB : integer) : integer;
begin
Result:=Length(Items);
SetLength(Items,Result+1);
with Items[Result] do
  begin
  XPos:=aPos;
  IsFinish:=aIsFinish;
  if aIndA>aIndB
     then begin
     indA:=aIndB;
     indB:=aIndA;
     end
     else begin
     indA:=aIndA;
     indB:=aIndB;
     end;
  resIndex:=-1;
  end;
end;

procedure TBorderPointList.Pack(var aBorders : TDynRectArray);
  function GetFinishPos(aIndA, aIndB : integer; var ResInd : integer) : integer;
  var
   cnt : integer;
  begin
  ResInd:=-1;
  Result:=-1;
  for cnt:=0 to High(Items)
    do with Items[cnt] do
        if IsFinish and (indA=aIndA) and (indB=aIndB) //and (resIndex=-1)
           then begin
           ResInd:=cnt;
           Result:=XPos;
           Exit;
           end;
  end;
var
 rct    : TRect;
 cnt    : integer;
 resind : integer;
 ind    : integer;
begin
Setlength(aBorders,0);
for cnt:=0 to High(Items)
  do with Items[cnt] do
       if not IsFinish and (resIndex=-1)
          then begin
          rct:=Rect(XPos,-1,GetFinishPos(indA,indB,resind),-1);
          if (rct.Left>-1) and (rct.Right>-1)
             then begin
             ind:=Length(aBorders);
             SetLength(aBorders,ind+1);
             resIndex:=ind;
             if (ind>=Low(Items)) and (ind<=High(Items))
                then Items[resind].resIndex:=resind;
             System.Move(rct,aBorders[ind],SizeOf(TRect));
             end;
          end;
if Length(aBorders)<>0 then ;
end;

procedure TBorderPointList.Clear;
begin
Setlength(Items,0);
end;

(*~~~ TSliderCrossDataList ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure TSliderCrossDataList.FillItems(const aDTI : TDateTimeInterval);
var
 cnt : integer;
 cntCL      : integer;
 selfPosA   : integer;
 selfPosB   : integer;
 selfInd    : integer;
 checkPosA  : integer;
 checkPosB  : integer;
 checkIndA  : integer;
 checkIndB  : integer;
 tempPos    : integer;
 BPL        : TBorderPointList;
begin
Clear;
SetLength(Items,Length(aDTI.Sliders));
for cnt:=0 to High(Items)
  do Items[cnt].CheckCross(cnt,aDTI.Sliders);
BPL.Clear;
for cnt:=0 to High(SCDL.Items)
  do begin
  if Length(Items[cnt].CrossList)>0
     then begin
     selfInd:=Items[cnt].SelfIndex;
     with aDTI.Sliders[selfInd] do
       begin
       selfPosA:=Start.Left+Start.Width div 2;
       selfPosB:=Finish.Left+Finish.Width div 2;
       end;

     for cntCL:=0 to High(SCDL.Items[cnt].CrossList)
        do begin
        checkPosB:=selfPosA;
        checkPosA:=selfPosB;
        checkIndA:=-1;
        checkIndB:=-1;
        if sctStart in SCDL.Items[cnt].CrossList[cntCL].CrossType
           then begin
           tempPos:=aDTI.Sliders[SCDL.Items[cnt].CrossList[cntCL].OverIndex].Start.Left+aDTI.Sliders[SCDL.Items[cnt].CrossList[cntCL].OverIndex].Start.Width div 2;
           if tempPos<checkPosA
              then begin
              checkPosA:=tempPos;
              checkIndA:=SCDL.Items[cnt].CrossList[cntCL].OverIndex;
              end;
           end;
        if sctFinish in SCDL.Items[cnt].CrossList[cntCL].CrossType
           then begin
           tempPos:=aDTI.Sliders[SCDL.Items[cnt].CrossList[cntCL].OverIndex].Finish.Left+aDTI.Sliders[SCDL.Items[cnt].CrossList[cntCL].OverIndex].Finish.Width div 2;
           if tempPos>checkPosB
              then begin
              checkPosB:=tempPos;
              checkIndB:=SCDL.Items[cnt].CrossList[cntCL].OverIndex;
              end;
           end;
        if (checkPosA<>selfPosB) and (checkIndA>-1)
           then BPL.Add(checkPosA,false,selfInd, checkIndA);
        if (checkPosB<>selfPosA) and (checkIndB>-1)
           then BPL.Add(checkPosB,true,selfInd, checkIndB);
        end;
     end;
  end;
BPL.Pack(Borders);
BPL.Clear;
aDTI.Invalidate;
end;

procedure TSliderCrossDataList.Clear;
var
 cnt : integer;
begin
for cnt:=0 to High(Items)
  do Items[cnt].Clear;
SetLength(Items,0);
SetLength(Borders,0);
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

initialization

finalization
SCDL.Clear;


end.
