unit U_DTP_Editor;
// http://jira.kupivip.local/jira/browse/MO-1528


(*LIST(lst_Value(Task:1, Entity:1))*) // -- тип происшествия lst_Task.Task_Code=1, lst_Entity.EntityCode=1

{+$DEFINE MO2}

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
  , Dialogs
  , ComCtrls
  , StdCtrls
  , FnCommon
  , ADODB, DB
  , Buttons
  {$IFDEF MO2}
  , Global
  {$ELSE}
  ,AppLogNew, ImgList
  {$ENDIF}

  ;



type
 PNavCarItem = ^TNavCarItem;
 TNavCarItem = record
  Car    : array[1..10] of char;
  Driver : array[1..128] of char;
  CarNum : TBitmap;
 end;

 PNavCarForDateItem = ^TNavCarForDateItem;
 TNavCarForDateItem = record
   dlvDate : TDateTime;
   Items   : array of TNavCarItem;
   function LoadFromDB(aDate : TDateTime) : boolean;
   function FillStrings(aStrings : TStrings):boolean;
   function GetDriver(const aCar : string) : string;
   function GetCar(const aDriver : string) : string;
   function Clear : boolean;
 end;

 PNavCarForDateList = ^TNavCarForDateList;
 TNavCarForDateList = record
   Items   : array of TNavCarForDateItem;
   function GetDateIndex(aDate : TDateTime) : integer;
   function GetForDate(aDate : TDateTime ; var aIndex : integer; aCars : TStrings) : boolean;
   function GetDriver(aDate : TDateTime ;const aCar : string) : string;
   function GetCar(aDate : TDateTime ;const aDriver : string) : string;
   function Clear : boolean;
 end;

// TacType = (actUnknown      =  0 // не указано, неизвестно
//           ,actAgressor     =  1 // 1. Агрессивный стиль вождения (резкое торможение, перестроение, подрезание и т.п.)
//           ,actReverse      =  2 // 2.Движение в обратном направлении по односторонней улице
//           ,actWrongLane    =  3 // 3.Движение по встречной полосе
//           ,actPasser       =  4 // 4.Наезд на пешехода
//           ,actPark         =  5 // 5.Не правильная остановка и стоянка (парковка)
//           ,actDoubleLine   =  6 // 6.Пересечение двойной сплошной
//           ,actOverSpeed    =  7 // 7.Превышение скорости
//           ,actRedSignal    =  8 // 8.Проезд на запрещающий сигнал светофора
//           ,actEscape       =  9 // 9.Скрылся с места ДТП
//           ,actCrash        = 10 //10.Столкновение с другим Т/С
//           ,actAny          = 11 //11.Другое (описать нарушение ПДД)
//       );
//

  PacTypeItem = ^TacTypeItem;
  TacTypeItem = record
    id  : integer;
    val : array[1..128] of char;
  end;

  TacTypeList = record
   Items : array of TacTypeItem;
   function LoadFromDB(const aDBConnStr : string) : boolean;
   function acTypeDescr(aID : integer) : string;
   function Clear : boolean;
  end;

  TclType = (cltUnknown       = 0
            ,cltDriverWitness = 1  //водитель свидетель
            ,cltDriverInjured = 2  //водитель пострадавший
            ,cltPasserWitness = 3  //пешеход свидетель
            ,cltPasserInjured = 4  //пешеход пострадавший
          );

 TresGuilty = (
   rgUnknown    = 0
  ,rgNotGuilty  = 1
  ,rgGuilty     = 2
 );

 PAccidentItem = ^TAccidentItem;
 TAccidentItem = record
   ID         : integer;
   acDate     : TDateTime;               // -- дата события
   acPlace    : array[1..256] of char;   // -- место события
   acCar      : array[1..10] of char;     // -- по Navision (выбирается по дате)
   acDriver   : array[1..128] of char;   // -- по Navision (оператору не показывается, выбирается при выборе автомобиля)
   acType     : integer;                 // -- TacTypeItem.id // тип (словарь, HardCode (20141015))
   acNote     : array[1..256] of char;   // -- описание (если тип "Другое" или уточнение)
   clType     : TclType;                 // -- тип (словарь, HardCode (20141015))
   clFIO      : array[1..256] of char;   // -- ФИО звонившего
   clPhone    : array[1..32] of char;    // -- телефон звонившего
   resNote    : array[1..256] of char;   // -- заключение по случаю
   resGuilty  : TresGuilty;
   _addDate   : TDateTime;
   _addEditor : array[1..64] of char;
   _logDate   : TDateTime;
   _logEditor : array[1..64] of char;
   NumPic  : TBitmap;
   function LoadFromDB(const aDBConnStr : string) : boolean;
   function LoadFromSource(aAI : TAccidentItem) : boolean;
   function GetXML : string;
   function SaveIntoDB : integer;
   function Clear : boolean;
 end;


// -- acType


 TAccidentListArrange = (
         aclaNone       =  0
        ,aclaID         =  1
        ,aclaDate       =  2
        ,aclaPlace      =  3
        ,aclaCar        =  4
        ,aclaDriver     =  5
        ,aclaAType      =  6
        ,aclaCType      =  7
        ,aclaFIO        =  8
        ,aclaPhone      =  9
        ,aclaGuilty     = 10
        ,aclaAddDate    = 11
        ,aclaAddEditor  = 12
        ,aclaLogDate    = 13
        ,aclaLogEditor  = 14
        );

 PAccidentList = ^TAccidentList;
 TAccidentList = record
  Items : array of TAccidentItem;
  alArr  : TAccidentListArrange;
  alDesc : boolean;
  function GetCarNumIndex(const aCarNum : string)  :integer;
  function GetIndexByID(aID : integer) : integer;
  function LoadFromDB(const aDBConnStr, aXMLFilter : string)  :boolean;
  procedure Arrange(aMode : TAccidentListArrange; aDesc : boolean);
  function IntoExcel(const aTitle  :string) : boolean;
  function Clear : boolean;
 end;



type
  T_DTP_Editor = class(TForm)
    Lab_DTP_Date: TLabel;
    DTP_Date: TDateTimePicker;
    Label1: TLabel;
    Ed_acPlace: TEdit;
    GrB_accident: TGroupBox;
    Label2: TLabel;
    CB_acType: TComboBox;
    Label3: TLabel;
    GrB_caller: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CB_clType: TComboBox;
    Ed_clFIO: TEdit;
    Ed_clPhone: TEdit;
    Label7: TLabel;
    CB_acCar: TComboBox;
    GrB_res: TGroupBox;
    Mem_resNote: TMemo;
    Label8: TLabel;
    BBok: TBitBtn;
    BBCancel: TBitBtn;
    Mem_acNote: TMemo;
    CB_resGuilty: TComboBox;
    IL_Paint: TImageList;
    Label9: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure DTP_DateChange(Sender: TObject);
    procedure CB_acCarChange(Sender: TObject);
    procedure CB_acCarDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure CallCheckAcceptData(Sender: TObject);
    procedure ComboBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure CB_resGuiltyDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);

  private
    isFirstVerdict : boolean;
    function LoadSettings : boolean;
    function SaveSettings : boolean;
    procedure FillControls( aAccidentItem : TAccidentItem);
    procedure CheckAcceptData;
  public
    dtp_Car    : string;
    dtp_Driver : string;
    constructor CreateWithParams(AOwner : TComponent; const aConnStr : string; aAccidentItem : TAccidentItem; aDataEdit, aResEdit : boolean);
  end;

var
  _DTP_Editor         : T_DTP_Editor;
  _DTP_DBConnStr      : string;
   NavCarForDateList  : TNavCarForDateList;
   acTypeList         : TacTypeList;
const
   DefRegNumRct : TRect = (Left: 0; Top : 0; Right : 100; Bottom : 18);
   ErrADOSPNoParam = 'Не удалось получить параметры хранимой процедуры "%s".';
   CanRewriteVerdict : boolean = false; // -- можно править вердикт
// -- (*LIST(lst_Value(Task:1, Entity:1))*)
//   acTypeDescr : array[TacType] of string = (
//           ''
//           ,'Агрессивный стиль вождения (резкое торможение, перестроение, подрезание и т.п.)'
//           ,'Движение в обратном направлении по односторонней улице'
//           ,'Движение по встречной полосе'
//           ,'Наезд на пешехода'
//           ,'Не правильная остановка и стоянка (парковка)'
//           ,'Пересечение двойной сплошной'
//           ,'Превышение скорости'
//           ,'Проезд на запрещающий сигнал светофора'
//           ,'Скрылся с места ДТП'
//           ,'Столкновение с другим Т/С'
//           ,'Другое'
//           );
   clTypeDescr : array[TclType] of string = (
           ''
           ,'водитель свидетель'
           ,'водитель пострадавший'
           ,'пешеход свидетель'
           ,'пешеход пострадавший'
           );
  lstTask_acType    = 1;
  lstEntity_acType  = 1;

implementation

{$R *.dfm}

procedure ShowErrorEx(const aProcname : string; aExc  :Exception; aParams : array of const);
var
 Ready : string;
begin
{$IFDEF MO2}
Global.ShowErrorEx(aProcname,aExc,aParams);
{$ENDIF}
CreateErrorMessage(aProcname,aExc,aParams,Ready);
if Ready<>'' then ;
end;

procedure InitProc;
begin
 //
end;

procedure FinalProc;
begin
acTypeList.Clear;
NavCarForDateList.Clear;
end;

(* Получение отображения регистрационного номера и подгонка по TRect **********)
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
on E : Exception do ShowErrorEx('GetRegNumber',E, []);
end;
end;



(*** TNavCarForDateItem ***************************************************************************)

function TNavCarForDateItem.LoadFromDB(aDate : TDateTime) : boolean;
var
 xml   : string;
 ADOSP : TADOStoredProc;
 ind   : integer;
 isMO2 : boolean;
begin
isMO2:=AnsiPos('MO2.EXE',AnsiUpperCase(ParamStr(0)))<>0;
Result:=false;
try
dlvDate:=aDate;
xml:=Format('<REQUEST DATE="%s"/>',[FormatDateTime('yyyymmdd',aDate)]);
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=_DTP_DBConnStr;
ADOSP.ProcedureName:='ae_GetCarForDate_Nav';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Length(Items);
    SetLength(Items,ind+1);
    with Items[ind] do
      begin
      Str2AC(Fields[0].AsString,Car);
      Str2AC(Fields[1].AsString,Driver);
      CarNum:=TBitmap.Create;
      if not IsMO2
         then begin
         with CarNum do
           begin
           Width:=DefRegNumRct.Right;
           Height:=DefRegNumRct.Bottom;
           end;
         GetRegNumber(Fields[0].AsString, DefRegNumRct, CarNum);
         end;
      end;
    Next;
    end;
  end;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
Result:=true;
except
on E : Exception do ShowErrorEx('TNavCarForDateItem.LoadFromDB',E, []);
end;
end;

function TNavCarForDateItem.FillStrings(aStrings : TStrings):boolean;
var
 cnt : integer;
begin
Result:=false;
try
aStrings.BeginUpdate;
try
aStrings.Clear;
for cnt:=0 to High(Items)
  do aStrings.Add(AC2Str(Items[cnt].Car));
finally
aStrings.EndUpdate;
end;
Result:=true;
except
on E : Exception do ShowErrorEx('TNavCarForDateItem.FillStrings',E, []);
end;
end;

function TNavCarForDateItem.GetDriver(const aCar : string) : string;
var
 tst : string;
 cnt : integer;
begin
Result:='';
try
tst:=AnsiUpperCase(aCar);
for cnt:=0 to High(Items)
  do if tst=AnsiUpperCase(Items[cnt].Car)
        then begin
        Result:=AC2Str(Items[cnt].Driver);
        Break;
        end;
except
on E : Exception do ShowErrorEx('TNavCarForDateItem.GetDriver',E, [aCar]);
end;
end;

function TNavCarForDateItem.GetCar(const aDriver : string) : string;
var
 tst : string;
 cnt : integer;
begin
Result:='';
try
tst:=AnsiUpperCase(aDriver);
for cnt:=0 to High(Items)
  do if tst=AnsiUpperCase(Items[cnt].Driver)
        then begin
        Result:=AC2Str(Items[cnt].Car);
        Break;
        end;
except
on E : Exception do ShowErrorEx('TNavCarForDateItem.GetCar',E, [aDriver]);
end;
end;

function TNavCarForDateItem.Clear : boolean;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items) do Items[cnt].CarNum.Free;
SetLength(Items,0);
dlvDate:=0;
Result:=true;
except
on E : Exception do ShowErrorEx('TNavCarForDateItem.Clear',E, []);
end;
end;

(*** TNavCarForDateList ***************************************************************************)

function TNavCarForDateList.GetDateIndex(aDate : TDateTime) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if Items[cnt].dlvDate = aDate
        then begin
        Result:=cnt;
        Break;
        end;
except
on E : Exception do ShowErrorEx('TNavCarForDateList.GetDateIndex',E, []);
end;
end;


function TNavCarForDateList.GetForDate(aDate : TDateTime ; var aIndex : integer; aCars : TStrings) : boolean;
var
 ind : integer;
begin
Result:=false;
try
ind:=GetDateIndex(aDate);
if ind>-1
   then Items[ind].FillStrings(aCars)
   else begin
   ind:=Length(Items);
   SetLength(Items,ind+1);
   if Items[ind].LoadFromDB(aDate)
      then Items[ind].FillStrings(aCars)
      else acars.Clear;
   end;
Result:=true;
except
on E : Exception do ShowErrorEx('TNavCarForDateList.GetForDate',E, []);
end;
end;

function TNavCarForDateList.GetDriver(aDate : TDateTime ;const aCar : string) : string;
var
 ind  : integer;
 strl : TStringList;
begin
Result:='';
try
ind:=GetDateIndex(aDate);
if ind=-1
   then begin
   strl:=TStringList.Create;
   try
   if not GetForDate(aDate, ind, strl) then Exit;
   finally
   FreeStringList(strl);
   end;
   end;
Result:=Items[ind].GetDriver(aCar);
except
on E : Exception do ShowErrorEx('TNavCarForDateList.GetDriver',E, [aCar]);
end;
end;

function TNavCarForDateList.GetCar(aDate : TDateTime ;const aDriver : string) : string;
var
 ind  : integer;
 strl : TStringList;
begin
Result:='';
try
ind:=GetDateIndex(aDate);
if ind=-1
   then begin
   strl:=TStringList.Create;
   try
   if not GetForDate(aDate, ind, strl) then Exit;
   finally
   FreeStringList(strl);
   end;
   end;
Result:=Items[ind].GetCar(aDriver);
except
on E : Exception do ShowErrorEx('TNavCarForDateList.GetCar',E, [aDriver]);
end;
end;

function TNavCarForDateList.Clear;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items) do Items[cnt].Clear;
Setlength(Items,0);
Result:=true;
except
on E : Exception do ShowErrorEx('TNavCarForDateList.Clear',E, []);
end;
end;

(*** TacTypeList **********************************************************************************)

function TacTypeList.LoadFromDB(const aDBConnStr : string) : boolean;
var
 xml   : string;
 ADOSP : TADOStoredProc;
 ind   : integer;
begin
Result:=false;
try
Clear;
xml:=Format('<LIST TASK="%d" ENTITY="%d"/>',[lstTask_acType, lstEntity_acType]);
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=aDBConnStr;
ADOSP.ProcedureName:='lst_Load';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
  with ADOSP do
    begin
    ind:=Length(Items);
    SetLength(Items,ind+1);
    with Items[ind] do
      begin
      id:=Fields[0].AsInteger;
      Str2AC(Fields[1].AsString,Val);
      end;
    Next;
    end;
  end;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
Result:=true;
except
on E : Exception do ShowErrorEx('TacTypeList.LoadFromDB',E, []);
end;
end;


function TacTypeList.acTypeDescr(aID : integer) : string;
var
 cnt : integer;
begin
Result:='';
try
for cnt:=0 to High(Items)
  do if aID = Items[cnt].id
        then begin
        Result:=AC2Str(Items[cnt].Val);
        Break;
        end;
except
on E : Exception do ShowErrorEx('TacTypeList.acTypeDescr',E, []);
end;
end;


function TacTypeList.Clear : boolean;
begin
Result:=false;
try
SetLength(Items,0);
except
on E : Exception do ShowErrorEx('TNavCarForDateList.Clear',E, []);
end;
end;


(*** TAccidentItem ********************************************************************************)

function TAccidentItem.LoadFromDB(const aDBConnStr : string) : boolean;
var
 xml    : string;
 ADOSP  : TADOStoredProc;
 carnum : string;
begin
Result:=false;
xml:=Format('<REQUEST ID="%d" />', [id]);
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
if _DTP_DBConnStr='' then _DTP_DBConnStr:=aDBConnStr;
ADOSP.ConnectionString:=_DTP_DBConnStr;
ADOSP.ProcedureName:='ae_AccidentList_Load';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.Active:=True;
if ADOSP.RecordCount=0 then Exit;
  with ADOSP do
    begin
    with self do
      begin
      ID    :=Fields[00].AsInteger;
      acDate:=Fields[01].AsDateTime;          // -- дата события
      Str2AC( Fields[02].AsString,acPlace);   // -- место события
      carnum:=Fields[03].AsString;
      Str2AC( carnum,acCar);                  // -- по Navision (выбирается по дате)
      Str2AC( Fields[04].AsString,acDriver);  // -- по Navision (оператору не показывается, выбирается при выборе автомобиля)
      acType:=Fields[05].AsInteger;           // -- (*LIST(lst_Value(Task:1, Entity:1))*) //тип (словарь, HardCode (20141015))
      Str2AC( Fields[06].AsString,acNote);    // -- описание (если тип "Другое" или уточнение)
      clType:=TclType(Fields[07].AsInteger);  // -- тип (словарь, HardCode (20141015))
      Str2AC( Fields[08].AsString,clFIO);     // -- ФИО звонившего
      Str2AC( Fields[09].AsString,clPhone);   // -- телефон звонившего
      Str2AC( Fields[10].AsString,resNote);   // -- заключение по случаю (описание)
      resGuilty:=TresGuilty(Fields[11].AsInteger);        // -- заключение по случаю
      if Fields.Count>=13 then _addDate:=Fields[12].AsDateTime;
      if Fields.Count>=14 then Str2AC( Fields[13].AsString,_addEditor);
      if Fields.Count>=15 then _logDate:=Fields[14].AsDateTime;
      if Fields.Count>=16 then Str2AC( Fields[15].AsString,_logEditor);
      NumPic:=TBitmap.Create;
      with NumPic do
        begin
        Width:=DefRegNumRct.Right;
        Height:=DefRegNumRct.Bottom;
        end;
      GetRegNumber(carnum, DefRegNumRct, NumPic)
      end;
  end;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
Result:=true;
except
on E : Exception do ShowErrorEx('TAccidentItem.LoadFromDB',E, []);
end;
end;


function TAccidentItem.LoadFromSource(aAI : TAccidentItem) : boolean;
begin
Result:=false;
try
Clear;
id:=aAI.id;
acDate:=aAI.acDate;
StrCopy(PChar(@acPlace[1]),PChar(@aAI.acPlace[1]));
StrCopy(PChar(@acCar[1]),PChar(@aAI.acCar[1]));
StrCopy(PChar(@acDriver[1]),PChar(@aAI.acDriver[1]));
acType  := aAI.acType;
StrCopy(PChar(@acNote[1]),PChar(@aAI.acNote[1]));
clType  := aAI.clType;
StrCopy(PChar(@clFIO[1]),PChar(@aAI.clFIO[1]));
StrCopy(PChar(@clPhone[1]),PChar(@aAI.clPhone[1]));
StrCopy(PChar(@resNote[1]),PChar(@aAI.resNote[1]));
resGuilty:=aAI.resGuilty;
_addDate:=aAI._addDate;
StrCopy(PChar(@_addEditor[1]),PChar(@aAI._addEditor[1]));
_logDate:=aAI._logDate;
StrCopy(PChar(@_logEditor[1]),PChar(@aAI._logEditor[1]));
if Assigned(aAI.NumPic) and (aAI.NumPic.Width>0)
   then begin
   NumPic:=TBitmap.Create;
   NumPic.Assign(aAI.NumPic);
   end;
Result:=(aAI.id=self.id);
if Assigned(aAI.NumPic) and Assigned(self.NumPic)
   then Result:=Result and
        (aAI.NumPic.Width = self.NumPic.Width) and
        (aAI.NumPic.Height = self.NumPic.Height)
except
on E : Exception do ShowErrorEx('TAccidentItem.LoadFromSource',E, [Result])
end;
end;

function TAccidentItem.GetXML : string;
const Shablon : string =
  '<DATA'+
  ' ID="%d"'+
  ' ACDATE="%s"'+   //	-- дата события
  ' ACPLACE="%s"'+  //	-- место события
  ' ACCAR="%s"'+    //	-- номер автомобиляпо Navision (выбирается по дате)
  ' ACDRIVER="%s"'+ //	-- ФИО водителя по Navision (оператору не показывается, выбирается при выборе автомобиля)
  ' ACTYPE="%d"'+   //	-- тип (словарь, HardCode (20141015))
  ' ACNOTE="%s"'+   //	-- описание (если тип "Другое" или уточнение)
  ' CLTYPE="%d"'+   //	-- тип (словарь, HardCode (20141015))
  ' CLFIO="%s"'+    //	-- ФИО звонившего
  ' CLPHONE="%s"'+  //	-- телефон звонившего
  ' RESNOTE="%s"'+    //	-- заключение по случаю (описание)
  ' RESGUILTY="%d"'+  //	-- заключение по случаю (признак виновности)

  ' USERID="%d"'+
  ' USERNAME="%s"'+
  ' WS="%s"'+

  '/>';
var
 ws : string;
begin
Result:='<DATA></DATA>';
try
try ws:=GetWorkStationName; except ws:='*'; end;
Result:=Format(Shablon,[
                ID
               ,FormatDateTime('yyyymmdd',acDate)
               ,Str2XML(Ac2Str(acPlace))
               ,Str2XML(Ac2Str(acCar))
               ,Str2XML(Ac2Str(acDriver))
               ,acType
               ,Str2XML(Ac2Str(acNote))
               ,integer(clType)
               ,Str2XML(Ac2Str(clFIO))
               ,Str2XML(Ac2Str(clPhone))
               ,Str2XML(Ac2Str(resNote))
               ,integer(resGuilty)
               , {$IFDEF MO2}Global.UserId{$ELSE}0{$ENDIF}
               , GetUserName
               , ws
               ]);
except
on E : Exception do ShowErrorEx('TAccidentItem.GetXML',E, [Result])
end;
end;

function TAccidentItem.SaveIntoDB : integer;
var
 ADOSP : TADOStoredProc;
 xml   : string;
begin
Result:=0;
try
xml:=GetXML;
ADOSP:=TADOStoredProc.Create(nil);
try
ADOSP.ConnectionString:=_DTP_DBConnStr;
ADOSP.ProcedureName:='ae_AccidentList_Edit';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.ExecProc;
Result:=integer(ADOSP.Parameters[0].Value);
finally
if Assigned(ADOSP)then FreeAndNil(ADOSP);
end;
except
on E : Exception do ShowErrorEx('TAccidentItem.SaveIntoDB',E, [xml])
end;
end;

function TAccidentItem.Clear : boolean;
begin
Result:=false;
try
try if Assigned(NumPic) then NumPic.Free; NumPic:=nil; except end;
FillChar(self, SizeOf(TAccidentItem),0);
Result:=true;
except
on E : Exception do ShowErrorEx('TAccidentItem.Clear',E, [])
end;
end;


(*** TAccidentList ********************************************************************************)
function TAccidentList.GetCarNumIndex(const aCarNum : string)  :integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if Ac2Str(Items[cnt].acCar) = aCarNum
        then begin
        Result:=cnt;
        Exit;
        end;
except
on E : Exception do ShowErrorEx('TAccidentList.GetCarNumIndex',E, [aCarNum]);
end;
end;


function TAccidentList.GetIndexByID(aID : integer) : integer;
var
 cnt : integer;
begin
Result:=-1;
try
for cnt:=0 to High(Items)
  do if Items[cnt].ID = aID
        then begin
        Result:=cnt;
        Exit;
        end;
except
on E : Exception do ShowErrorEx('TAccidentList.GetIndexByID',E, [aID]);
end;
end;



function TAccidentList.LoadFromDB(const aDBConnStr, aXMLFilter : string)  :boolean;
var
 xml    : string;
 ADOSP  : TADOStoredProc;
 carnum : string;
 ind    : integer;
 numind : integer;
begin
Result:=false;
xml:=aXMLFilter;
try
Clear;
ADOSP:=TADOStoredProc.Create(nil);
try
if _DTP_DBConnStr='' then _DTP_DBConnStr:=aDBConnStr;
ADOSP.ConnectionString:=_DTP_DBConnStr;
ADOSP.ProcedureName:='ae_AccidentList_Load';
if not ADOSP.Parameters.Refresh
   then raise Exception.Create(Format(ErrADOSPNoParam,[ADOSP.ProcedureName]));
ADOSP.Parameters.ParamByName('@xmltext').Value:=xml;
ADOSP.Active:=True;
while not ADOSP.Eof do
  begin
// -- это можно на клиенте фильтровать записи ...
//  if aWithOutVerdict
//       then begin
//       if (Trim(ADOSP.Fields[10].AsString)<>'')
//          then begin
//          ADOSP.Next;
//          Continue;
//          end;
//       end;
  with ADOSP do
    begin
    ind:=Length(Items);
    SetLength(Items,ind+1);
    Items[ind].NumPic:=nil;
    with Items[ind] do
      begin
      ID    :=Fields[00].AsInteger;
      acDate:=Fields[01].AsDateTime;          // -- дата события
      Str2AC( Fields[02].AsString,acPlace);   // -- место события
      carnum:=Fields[03].AsString;
      numind:=GetCarNumIndex(carnum);         // -- а то потом он, естественно, появится (или надо Assigned(NumPic) проверять)
      Str2AC( carnum,acCar);                  // -- по Navision (выбирается по дате)
      Str2AC( Fields[04].AsString,acDriver);  // -- по Navision (оператору не показывается, выбирается при выборе автомобиля)
      acType:=Fields[05].AsInteger;           // -- (*LIST(lst_Value(Task:1, Entity:1))*) //тип (словарь, HardCode (20141015))
      Str2AC( Fields[06].AsString,acNote);    // -- описание (если тип "Другое" или уточнение)
      clType:=TclType(Fields[07].AsInteger);  // -- тип (словарь, HardCode (20141015))
      Str2AC( Fields[08].AsString,clFIO);     // -- ФИО звонившего
      Str2AC( Fields[09].AsString,clPhone);   // -- телефон звонившего
      Str2AC( Fields[10].AsString,resNote);   // -- заключение по случаю (описание)
      resGuilty:=TresGuilty(Fields[11].AsInteger);        // -- заключение по случаю
      if Fields.Count>=13 then _addDate:=Fields[12].AsDateTime;
      if Fields.Count>=14 then Str2AC( Fields[13].AsString,_addEditor);
      if Fields.Count>=15 then _logDate:=Fields[14].AsDateTime;
      if Fields.Count>=16 then Str2AC( Fields[15].AsString,_logEditor);
      NumPic:=TBitmap.Create;
      with NumPic do
        begin
        Width:=DefRegNumRct.Right;
        Height:=DefRegNumRct.Bottom;
        end;
      if numind=-1
         then GetRegNumber(carnum, DefRegNumRct, NumPic)
         else NumPic.Assign(Items[numind].NumPic);
      end;
    Next;
    end;
  end;
finally
if Assigned(ADOSP)
   then begin
   if ADOSP.Active then ADOSP.Active:=False;
   FreeAndNil(ADOSP);
   end;
end;
if alArr<>aclaNone then Arrange(alArr, alDesc);
Result:=true;
except
on E : Exception do ShowErrorEx('TAccidentList.LoadFromDB',E, []);
end;
end;


procedure TAccidentList.Arrange(aMode : TAccidentListArrange; aDesc : boolean);
  function FormatCarNumber(aItemIndex : integer) : string;
  var
   tmp  :string;
  begin
  tmp:=AC2Str(Items[aItemIndex].acCar);
  Result:=Copy(tmp,1,6);
  tmp:=Copy(tmp,7,Length(tmp));
  if CheckValidInteger(tmp)
     then Result:=Result+FormatFloat('000',StrToInt(tmp))
     else Result:=Result+tmp;
  Result:=AnsiUpperCase(Result);
  end;
var
 strl : TStringList;
 cnt  : integer;
 tmp  : array of TAccidentItem;
 hg   : integer;
begin
alArr  := aMode;
alDesc := aDesc;
try
strl:=TStringList.Create;
try
case aMode of
aclaNone      : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',cnt),TObject(@Items[cnt]));
aclaID        : for cnt:=0 to High(Items) do strl.AddObject(FormatFloat('0000000000',Items[cnt].ID),TObject(@Items[cnt]));
aclaDate      : for cnt:=0 to High(Items) do strl.AddObject(FormatDateTime('yyyymmdd',Items[cnt].acDate),TObject(@Items[cnt]));
aclaPlace     : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].acPlace)),TObject(@Items[cnt]));
aclaCar       : for cnt:=0 to High(Items) do strl.AddObject(FormatCarNumber(cnt),TObject(@Items[cnt]));
aclaDriver    : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].acDriver)),TObject(@Items[cnt]));
aclaAType     : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(acTypeList.acTypeDescr(Items[cnt].acType)),TObject(@Items[cnt]));
aclaCType     : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(clTypeDescr[Items[cnt].clType]),TObject(@Items[cnt]));
aclaFIO       : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].clFIO)),TObject(@Items[cnt]));
aclaPhone     : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt].clPhone)),TObject(@Items[cnt]));
aclaGuilty    : for cnt:=0 to High(Items) do strl.AddObject(IntToStr(integer(Items[cnt].resGuilty)),TObject(@Items[cnt]));
aclaAddDate   : for cnt:=0 to High(Items) do strl.AddObject(FormatDateTime('yyyymmdd_hhnnss',Items[cnt]._addDate),TObject(@Items[cnt]));
aclaAddEditor : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt]._addEditor)),TObject(@Items[cnt]));
aclaLogDate   : for cnt:=0 to High(Items) do strl.AddObject(FormatDateTime('yyyymmdd_hhnnss',Items[cnt]._logDate),TObject(@Items[cnt]));
aclaLogEditor : for cnt:=0 to High(Items) do strl.AddObject(AnsiUpperCase(Ac2Str(Items[cnt]._logEditor)),TObject(@Items[cnt]));
end;
strl.Sort;
SetLength(tmp,strl.Count);
hg:=high(tmp);
if aDesc
   then for cnt:=0 to strl.Count-1 do tmp[hg-cnt].LoadFromSource(PAccidentItem(strl.Objects[cnt])^)
   else for cnt:=0 to strl.Count-1 do tmp[cnt].LoadFromSource(PAccidentItem(strl.Objects[cnt])^);
Clear;
SetLength(Items,Length(tmp));
for cnt:=0 to strl.Count-1 do Items[cnt].LoadFromSource(tmp[cnt]);
finally
for cnt:=0 to High(tmp) do tmp[cnt].NumPic.Free;
Setlength(tmp,0);
FreeStringList(strl);
end;
except
  on E : Exception do ShowErrorEx('TAccidentList.Arrange',E, []);
end;
end;


function TAccidentList.IntoExcel(const aTitle  :string) : boolean;
const
 bool    : array[boolean] of string = ('Нет','Да');
 guilty  : array[TresGuilty] of string = ('','Нет','Да');
var
  aVarArray2D : variant;
  rows        : integer;
begin
Result:=False;
ShowSplash('Формирование отчета', stInfo);
try
aVarArray2D:=VarArrayCreate([0,Length(Items)+1,0,15],varVariant);
aVarArray2D[0, 0]:='Дата';
aVarArray2D[0, 1]:='Место';
aVarArray2D[0, 2]:='Гос.Рег.Знак';
aVarArray2D[0, 3]:='Водитель';
aVarArray2D[0, 4]:='Тип нарушения';
aVarArray2D[0, 5]:='Примечание';
aVarArray2D[0, 6]:='Звонящий';
aVarArray2D[0, 7]:='ФИО';
aVarArray2D[0, 8]:='Телефон';
aVarArray2D[0, 9]:='Вердикт';
aVarArray2D[0,10]:='Виновность';
aVarArray2D[0,11]:='Добавлено';
aVarArray2D[0,12]:='Оператор';
aVarArray2D[0,13]:='Решение';
aVarArray2D[0,14]:='Логист';
for rows:=0 to High(Items)
   do begin
   aVarArray2D[rows+1, 0]:=(*''''+*)FormatDateTime('dd.mm.yyyy',Items[rows].acDate);  // -- дата события
   aVarArray2D[rows+1, 1]:=''''+AC2Str(Items[rows].acPlace);                          // -- место события
   aVarArray2D[rows+1, 2]:=''''+AC2Str(Items[rows].acCar);                            // -- по Navision (выбирается по дате)
   aVarArray2D[rows+1, 3]:=''''+AC2Str(Items[rows].acDriver);                         // -- по Navision (оператору не показывается, выбирается при выборе автомобиля)
   aVarArray2D[rows+1, 4]:=''''+acTypeList.acTypeDescr(Items[rows].acType);   // -- TacTypeItem.id // тип (словарь, HardCode (20141015))
   aVarArray2D[rows+1, 5]:=''''+AC2Str(Items[rows].acNote);                       // -- описание (если тип "Другое" или уточнение)
   aVarArray2D[rows+1, 6]:=''''+clTypeDescr[Items[rows].clType];                      // -- тип (словарь, HardCode (20141015))
   aVarArray2D[rows+1, 7]:=''''+AC2Str(Items[rows].clFIO);                            // -- ФИО звонившего
   aVarArray2D[rows+1, 8]:=''''+AC2Str(Items[rows].clPhone);                          // -- телефон звонившего
   aVarArray2D[rows+1, 9]:=''''+AC2Str(Items[rows].resNote);                          // -- заключение по случаю
   aVarArray2D[rows+1,10]:=''''+guilty[Items[rows].resGuilty];
   aVarArray2D[rows+1,11]:=FormatDateTime('dd.mm.yyyy',Items[rows]._addDate);
   aVarArray2D[rows+1,12]:=''''+AC2Str(Items[rows]._addEditor);
   aVarArray2D[rows+1,13]:=FormatDateTime('dd.mm.yyyy',Items[rows]._logDate);
   aVarArray2D[rows+1,14]:=''''+AC2Str(Items[rows]._logEditor);
   end;
try
ArrayVariantToExcelEx(aTitle,aVarArray2D,1);
finally
if not VarIsEmpty(aVarArray2D) then VarArrayRedim(aVarArray2D,0);
aVarArray2D:=Unassigned;
FreeSplash;
end;
except
on E : Exception do ShowErrorEx('TAccidentList.IntoExcel',E,[]);
end;
end;


function TAccidentList.Clear : boolean;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=0 to High(Items) do Items[cnt].Clear;
SetLength(Items,0);
Result:=true;
except
on E : Exception do ShowErrorEx('TAccidentList.Clear',E, []);
end;
end;


(**************************************************************************************************)

function T_DTP_Editor.LoadSettings  :boolean;
begin
Result:=False;
try
{$IFDEF MO2}
Result:=True;
BorderStyle:=bsSingle;
{$ELSE}
if AppParams.UserName = 'S.KHOLIN'
   then begin
   Position:=poDefault;
   SetDoubleBuffered(self);
   RestorePos(self,AppParams.CFGUserFileName);
   end
   else begin
   BorderStyle:=bsSingle;
   end;
{$ENDIF}
Result:=True;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.LoadSettings', E, []);
end;
end;


function T_DTP_Editor.SaveSettings : boolean;
begin
Result:=False;
try
{$IFDEF MO2}
Result:=True;
Exit;
{$ELSE}
if AppParams.UserName = 'S.KHOLIN'
   then begin
   SavePos(self,AppParams.CFGUserFileName);
   end
   else begin
    end;
{$ENDIF}

Result:=True;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.SaveSettings', E, []);
end;
end;


procedure T_DTP_Editor.FillControls( aAccidentItem : TAccidentItem);
var
 ind : integer;
 cnt : integer;
begin
try
isFirstVerdict:=(aAccidentItem.resGuilty=rgUnknown);
Tag:=aAccidentItem.ID;
if aAccidentItem.acDate=0
   then DTP_Date.DateTime:=Date-1
   else DTP_Date.DateTime:=aAccidentItem.acDate;
DTP_DateChange(DTP_Date);
ind:=CB_acCar.Items.IndexOf(AC2Str(aAccidentItem.acCar));
if ind>-1
   then CB_acCar.ItemIndex:=ind;
if Assigned(CB_acCar.OnChange) then CB_acCar.OnChange(CB_acCar);
Ed_acPlace.Text:=Ac2Str(aAccidentItem.acPlace);
  Ed_acPlace.MaxLength:=Length(aAccidentItem.acPlace)-1;
ind:=aAccidentItem.acType;
CB_acType.ItemIndex:=-1;
if ind>0
   then for cnt:=0 to CB_acType.Items.Count-1
          do if integer(CB_acType.Items.Objects[cnt]) = aAccidentItem.acType
                then begin
                CB_acType.ItemIndex:=cnt;
                Break;
                end;
if Assigned(CB_acType.OnChange) then CB_acType.OnChange(CB_acType);
Mem_acNote.Text:=Ac2Str(aAccidentItem.acNote);
  Mem_acNote.MaxLength:=Length(aAccidentItem.acNote)-1;
ind:=integer(aAccidentItem.clType)-1;
if ind>-1
   then CB_clType.ItemIndex:=ind;
if Assigned(CB_clType.OnChange) then CB_clType.OnChange(CB_clType);
Ed_clFIO.Text:=Ac2Str(aAccidentItem.clFIO);
  Ed_clFIO.MaxLength:=Length(aAccidentItem.clFIO)-1;
Ed_clPhone.Text:=Ac2Str(aAccidentItem.clPhone);
  Ed_clPhone.MaxLength:=Length(aAccidentItem.clPhone)-1;
Mem_resNote.Text:=Ac2Str(aAccidentItem.resNote);
  Mem_resNote.MaxLength:=Length(aAccidentItem.resNote)-1;
//case aAccidentItem.resGuilty of
//rgUnknown   : ChB_resGuilty.State:=cbGrayed;
//rgNotGuilty : ChB_resGuilty.State:=cbUnchecked;
//rgGuilty    : ChB_resGuilty.State:=cbChecked;
//end;
CB_resGuilty.ItemIndex:=integer(aAccidentItem.resGuilty);
except
on E : Exception do ShowErrorEx('T_DTP_Editor.FillControls',E, []);
end;
end;


procedure T_DTP_Editor.CheckAcceptData;
  procedure CheckLengthEdit(aEdit : TEdit);
  begin
  if not aEdit.ReadOnly
     then begin
     if Length(aEdit.Text)=aEdit.MaxLength
        then aEdit.Color:=clInfoBk
        else aEdit.Color:=clWindow;
     end;
  end;

  procedure CheckLengthMemo(aMemo : TMemo);
  begin
  if not aMemo.ReadOnly
     then begin
     if Length(aMemo.Text)=aMemo.MaxLength
        then aMemo.Color:=clInfoBk
        else aMemo.Color:=clWindow;
     end;
  end;


var
  isCar
 ,isPlace
 ,isAType

 ,isCType
 ,isFIO
 ,isPhone
 ,CanRewrite
          : boolean;
begin
try
isCar:=CB_acCar.ItemIndex>-1;
isPlace:=trim(Ed_acPlace.Text)<>'';
isAType:=CB_acType.ItemIndex>-1;
isCType:=CB_clType.ItemIndex>-1;
isFIO:=trim(Ed_clFIO.Text)<>'';
isPhone:=trim(Ed_clPhone.Text)<>'';
CanRewrite:=not GrB_res.Visible; // -- если операторский показ
if not CanRewrite
   then begin
   CanRewrite:=CanRewriteVerdict or // -- можно переписывать вердикт
               (not CanRewriteVerdict and isFirstVerdict); // -- переписывать нельзя, но это первая правка;
   end;
CheckLengthEdit(Ed_acPlace);
CheckLengthMemo(Mem_acNote);
CheckLengthEdit(Ed_clFIO);
CheckLengthEdit(Ed_clPhone);
CheckLengthMemo(Mem_resNote);
BBok.Enabled:=isCar and isAType and isPlace and isCType and isFIO and isPhone and CanRewrite;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.CheckAcceptData',E, []);
end;
end;

(**************************************************************************************************)

constructor T_DTP_Editor.CreateWithParams(AOwner : TComponent; const aConnStr : string; aAccidentItem : TAccidentItem; aDataEdit, aResEdit : boolean);
   procedure SetReadOnly(aObj : TObject; aReadOnly : boolean);
   begin
   if (aObj is TEdit) then
       with (aObj as TEdit)
         do begin
         ReadOnly:=aReadOnly;
         Ctl3D:=not ReadOnly;
         Color:=clPaleGray;
         end
       else
   if (aObj is TMemo) then
    with (aObj as TMemo)
         do begin
         ReadOnly:=aReadOnly;
         Ctl3D:=not ReadOnly;
         Color:=clPaleGray;
         end
       else
   if (aObj is TComboBox) then
    with (aObj as TComboBox)
         do begin
         Enabled:=not aReadOnly;
         Ctl3D:=Enabled;
         end
       else

       ;
   end;

   procedure SetControls(aControl : TObject; aEnabled : boolean);
   var
    cnt : integer;
   begin
   if aControl.InheritsFrom(TWinControl)
      then for cnt:=0 to (aControl as TWinControl).ControlCount-1
              do begin
              SetReadOnly((aControl as TWinControl).Controls[cnt], not aEnabled);
              SetControls((aControl as TWinControl).Controls[cnt], aEnabled);
              end;
   end;

   function GetMaxTop : integer;
   var
    cnt : integer;
    hgt : integer;
   begin
   Result:=0;
   for cnt:=0 to ControlCount-1
     do if not (Controls[cnt].InheritsFrom(TBitBtn)) and Controls[cnt].Visible
           then begin
           hgt:=Controls[cnt].Top+Controls[cnt].Height;
           if Result<hgt then Result:=hgt;
           end;
   inc(Result,4);
   end;



var
 cnt : integer;
 hgt : integer;
begin
inherited Create(AOwner);
try
_DTP_DBConnStr:=aConnStr;
acTypeList.LoadFromDB(_DTP_DBConnStr);
CB_acType.Items.BeginUpdate;
try
CB_acType.Items.Clear;
for cnt:=0 to High(acTypeList.Items)
  do CB_acType.Items.AddObject(Ac2Str(acTypeList.Items[cnt].val), TObject(acTypeList.Items[cnt].id));
finally
CB_acType.Items.EndUpdate;
end;


FillControls(aAccidentItem);
// -- общие данные --
DTP_Date.Enabled:=aDataEdit;
SetControls(self,aDataEdit);
// -- результаты --
SetControls(GrB_res,aResEdit);
// -- это для скрытия полей ввода вердикта от оператора --
GrB_res.Visible:=aResEdit;
//if aResEdit then Mem_resNote.SetFocus;
//if aDataEdit then DTP_Date.SetFocus;
hgt:=GetMaxTop;
with Constraints do
  begin
  MaxHeight:=0;
  MinHeight:=0;
  ClientHeight:=hgt+BBok.Height+4;
  MinHeight:=Height;
  MaxHeight:=Height;
  end;
BBok.Top:=hgt;
BBCancel.Top:=BBok.Top;
// --
if Assigned(CB_acCar.onChange) then CB_acCar.onChange(CB_acCar);
BBok.Enabled:=false;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.CreateWithParams',E, []);
end;
end;

procedure T_DTP_Editor.FormCreate(Sender: TObject);
const
 verdInfo : array[boolean] of string = (' (однократное редактирование)','');
begin
LoadSettings;
GrB_res.Caption:='Вердикт'+verdInfo[CanRewriteVerdict];
end;

procedure T_DTP_Editor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
NavCarForDateList.Clear;
SaveSettings;
end;


procedure T_DTP_Editor.DTP_DateChange(Sender: TObject);
var
 ind : integer;
begin
try
NavCarForDateList.GetForDate(DTP_Date.Date,ind, CB_acCar.Items);
CB_acCar.Tag:=ind;
CheckAcceptData;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.DTP_DateChange',E, []);
end;
end;


procedure T_DTP_Editor.CB_acCarChange(Sender: TObject);
var
 ind  :integer;
begin
try
dtp_Car:='';
dtp_Driver:='';
CB_acCar.Hint:='';
ind:=NavCarForDateList.GetDateIndex(DTP_date.Date);
if ind>-1
  then begin
  if (CB_acCar.ItemIndex>=Low(NavCarForDateList.Items[ind].Items)) and (CB_acCar.ItemIndex<=High(NavCarForDateList.Items[ind].Items))
      then begin
      with NavCarForDateList.Items[ind].Items[CB_acCar.ItemIndex]
          do begin
          dtp_Car:=AC2Str(Car);
          dtp_Driver:=AC2Str(Driver);
          CB_acCar.Hint:='Водитель: '+dtp_Driver;
          end;
      end;
   end;
CheckAcceptData;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.CB_acCarChange',E, []);
end;
end;

procedure T_DTP_Editor.CB_acCarDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 ind  : integer;
 offX : integer;
 str  : string;
 rct  : TRect;
begin
try
ind:=NavCarForDateList.GetDateIndex(DTP_date.Date);
if ind>-1
  then begin
  CB_acCar.Canvas.Brush.Color:=clWindow;
  FillRect(CB_acCar.Canvas.Handle,Rect,CB_acCar.Canvas.Brush.Handle);
  with NavCarForDateList.Items[ind].Items[index]
    do begin
    str:=Ac2Str(NavCarForDateList.Items[ind].Items[index].Car);
    offX:=0;
    CB_acCar.Canvas.Font.Color:=clBlack;
    if ((odSelected in State) or (odFocused in State)) and not (odComboBoxEdit in State)
       then begin
       offX:=CB_acCar.ItemHeight-6;
       GradientFigure(CB_acCar.Canvas.Handle,gfTriangleRight,Bounds(Rect.Left, Rect.Top+3, offX, offX),clBlue,'',clYellow, false);
       offX:=offX+3;
       end;
  if Assigned(CarNum) and (CarNum.Height>5) and (CarNum.Width>10)
     then TransparentBlt(CB_acCar.Canvas.Handle,Rect.Left+offX, Rect.Top, CarNum.Width, CarNum.Height,CarNum.Canvas.Handle, 0,0, CarNum.Width, CarNum.height,clFuchsia)
     else begin
     rct:=Classes.Rect(Rect.Left+offX, Rect.Top+1,Rect.Right-2, Rect.Bottom-1);
     DrawTransparentText(CB_acCar.Canvas.Handle,str,rct,DT_LEFT_ALIGN);
     end;
  end;
  end;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.CB_acCarDrawItem',E, []);
end;
end;




procedure T_DTP_Editor.CallCheckAcceptData(Sender: TObject);
begin
CheckAcceptData;
end;


procedure T_DTP_Editor.ComboBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 CB  : TComboBox;
 rct : TRect;
 str : string;
begin
try
if Control is TComboBox
   then CB:=(Control as TComboBox)
   else Exit;
System.Move(Rect,rct,SizeOf(TRect));
with CB.Canvas do
  begin
  if (odGrayed in State) or (odDisabled in State)
     then begin
     Font.Color:=clWindowText;
     Brush.Color:=clPaleGray;
     end
     else
  if (odSelected in State) or (odFocused in State)
     then begin
     Font.Color:=clHighlightText;
     Brush.Color:=clHighlight;
     end
     else begin
     Font.Color:=clWindowText;
     Brush.Color:=clWindow;
     end;
  FillRect(Bounds(0,0,Cb.Width,CB.Height)); // Rect - аналогично....
  str:=CB.Items[Index];
  DrawTransparentText(Handle,str,rct,DT_LEFT_ALIGN);
  end;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.ComboBoxDrawItem',E, []);
end;
end;


procedure T_DTP_Editor.CB_resGuiltyDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 bmp : TBitmap;
 rct : TRect;
 str : string;
begin
try
bmp:=TBitmap.Create;
try
with bmp do
  begin
  Width:=IL_Paint.Width;
  Height:=IL_Paint.Height;
  TransparentColor:=clFuchsia;
  Canvas.Brush.Color:=TransparentColor;
  FillRect(Canvas.Handle,Bounds(0,0,Width,Height),Canvas.Brush.Handle);
  IL_Paint.Draw(Canvas,0,0,Index);
  end;
with CB_resGuilty.Canvas do
  begin
  if (odSelected in State) or (odFocused in State)
     then begin
     Font.Color:=clHighlightText;
     Brush.Color:=clHighlight;
     end
     else begin
     Font.Color:=clWindowText;
     Brush.Color:=clWindow;
     end;
  Windows.FillRect(Handle,Rect,Brush.Handle);
  TransparentBlt(Handle
                ,Rect.Left+2
                ,Rect.Top+(Rect.Bottom - Rect.Top - bmp.Height) div 2
                ,bmp.Width
                ,bmp.Height
                ,bmp.Canvas.Handle
                ,0,0, bmp.Width, bmp.Height, ColorToRGB(clFuchsia));
  str:=CB_resGuilty.Items[Index];
  rct:=Classes.Rect(Rect.Left+bmp.Width+4, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
  DrawTransparentText(Handle,str, rct, DT_LEFT_ALIGN);
  end;
finally
if Assigned(bmp) then bmp.Free;
end;
except
on E : Exception do ShowErrorEx('T_DTP_Editor.CB_resGuiltyDrawItem',E, []);
end;
end;


initialization  InitProc;
finalization FinalProc;

end.
