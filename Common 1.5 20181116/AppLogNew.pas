unit AppLogNew;

{-$DEFINE JCL}
{$DEFINE ONETWO}

interface

uses

    variants
    , ActiveX
    , windows
    , classes
    , FnCommon
    , Types
    , Forms
    , Controls
    , Grids
    , CheckLst
    , StdCtrls
    , ImgList
    , StrUtils
    , ExtCtrls
    , Buttons
    , Graphics
    , SysUtils
    {$IFDEF JCL}
    , JclDebug
    {$ENDIF}
    , Messages
    , Dialogs

;

{$R AppLogNew.res}
// LOGLIST1 - 3 картинки : info, warning, error
// LOGLIST2 - 5 картинок : info, warning, error, unknownn, sysinfo

const
 selfWSNAME           = 'KUPIVIP00000';
 ErrMsgShablon        = '"%s" : %s.';
 maxStrLength         = 512; // -- максимальная длина строки после которой строка режется для журнала и полная строка сохраняется в отдельный файл
 maxPrmLength         = 512; // -- максимальная длина строки ПАРАМЕТРОВ после которой строка режется для журнала и полная строка сохраняется в отдельный файл
 LogShortDateFormat   = 'dd.mm.yyyy';
 LogLongDateFormat    = LogShortDateFormat + ' hh:nn:ss.zzz';
 LogRecordFormat      = '%s'+DaggerChar+'%d'+DaggerChar+'%s';
 LOG_FILEUPDATED      = WM_APP + $0A00;


type
/// <summary>
/// </summary>

  // -- регистратор ошибок (поток, некий циклб процесс и т.п.)
  // -- при достижении(превышении) кол-ва ошибок на интервал времени выдает сигнал на стоп
  // -- StartRegister  : кол-во ошибок (ErrorCount) за временной интервал (Interval)
  {$M+}
  TThreadErrorRegister = class(TObject)
  strict private type
   TErrorItem = record
     Cls   : string;
     Msg   : string;
     Stack : string;
     dt    : TDateTime;
   end;
  strict private
   fItems : array of TErrorItem;
   fErrorCount : cardinal;
   fInterval : cardinal;
  private
    procedure SetErrorCount(Value : cardinal);
    procedure SetInterval(Value : cardinal);
    function GetCountAll : integer;
    function GetCountForInterval : integer;
    function GetNeedStop : boolean;
    {$HINTS OFF}
    procedure CopyItem(FromIndex,ToIndex : integer);
    {$HINTS ON}
    function Clear : boolean;
  public
    function Add(aExc : Exception) : integer;
    function ToString : string; override;
    procedure ClearItem(Index : integer);
    procedure ClearExpired;
    procedure Delete(Index : integer);
  published
    constructor StartRegister(ErrorCount, Interval : cardinal);
    destructor Destroy; override;
    property ErrorsCountAll : integer read GetCountAll;
    property ErrorsCountForInterval : integer read GetCountForInterval;
    property NeedStop : boolean read GetNeedStop;
    property ErrorCount : cardinal read fErrorCount write SetErrorCount default 10;
    property Interval : cardinal read fInterval write SetInterval default 10;
  end;
  {$M-}


 TAppParams = record
  UserName          : string;
  UserFullName      : string;
  UserGroups        : TStringDynArray;
  UserGroupsStr     : string;
  WSName            : string;
  WSAddress         : string;
  UserFolder        : string; // -- document folder of user
  AppPrefix         : string;
  CFGUserFileName   : string;
  CFGCommonFileName : string;
  CFGComDocFileName : string;
  SelfPID           : cardinal;
  Params            : TStringDynArray;
  verDate           : string;
  AppCFGFolder      : string;
  procedure FillParams;
  function ParamExists(const aParam : string):boolean;
  function ParamBeginWith(const aParam : string):integer;
  function GetParams : string;
  procedure ClearParams;
 end;

 TLogRecordType = (lrtInfo      = 0
                  ,lrtWarning   = 1
                  ,lrtError     = 2
                  ,lrtUndef     = 3 // -- error on parsing etc
                  ,lrtStack     = 4

                  );
 TLogViewFilter = set of TLogRecordType;

 TLogViewForm = class(TForm)
   IL   : TImageList;
   DrGr : TDrawGrid;
   ChLB : TCheckListBox;
   EdFnd: TEdit;
   LabFnd : TLabel;
   LabFileName : TLabel;
   procedure LVF_Close(Sender : TObject; var Action : TCloseAction);
   procedure LVF_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   procedure LVF_Resize(Sender: TObject);
   procedure LVF_DblClick(Sender: TObject);
   procedure LVF_Show(Sender : TOBject);

   procedure LVF_FilterClick(Sender : TObject);
   procedure LVF_DrGrDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
   procedure LVF_DrGrDoubleClick(Sender: TObject);
   procedure LVF_DrGrFixedCellClick(Sender: TObject; ACol, ARow: Integer);
   procedure LVF_EdFnd_Change(Sender: TObject);
   procedure LVF_LabFileName_Click(Sender : TObject);
   procedure LVF_LabFnd_Click(Sender: TObject);
   procedure LVF_ButtonsClick(Sender: TObject);

   //procedure APLFClose(Sender : TObject; var Action: TCloseAction);
  public
   CFGName         : string;
   Filter          : TLogViewFilter;
   LogStringsArray : array of TStringDynArray;
   //LogText         : string;
   resInd          : TIntegerDynArray;
   SortCol    : integer; // колонка сортировки
   SortDir    : boolean; // Asc (false), Desc (true)
   ErrorOnSort: boolean; // признак возникновения ошибки при сортировке
   destructor Destroy; override;
   procedure RefreshLog;
   procedure FillFromLogList(const aLogListText : string; aFilter : TLogViewFilter = [lrtInfo,lrtWarning,lrtError]);
   procedure FillFromSDA;
  private
   procedure DirWatchHandler(var Msg : TMessage);  message LOG_FILEUPDATED;
   procedure StartDirWatch;
   procedure StopDirWatch;
  end;

const
 DateFileNameShablon = 'yyyymmdd';
 descr : array[TLogRecordType] of string  =  (' INFO ',' WARNING ',' ERROR ', ' ** ', ' STACK ');

var
 terApp             : TThreadErrorRegister;
 LogFileHandle      : cardinal = 0;
 LogFileDate        : TDate;
 LogSilentDead      : boolean = true;
 LogOneDay          : boolean = false;
 LogEachClose       : boolean = false;

 LogFolderName      : string = '';
 LogFilePrefix      : string = '';
 LogFileName        : string = '';
 LogFileNameList    : TStringDynArray;
 LogCriticalSection : tRtlCriticalSection;
 LogMutexName       : string = '';
 LogMutexHandle     : cardinal = 0;

 ErrorCounter       : integer = 0;
 WarningCounter     : integer = 0;
 AppParams          : TAppParams;
 LVF                : TLogViewForm = nil;

 // -- Заменять #13(cr) на #2, #10(lf) на #1 и ; между параметрами на #3
 // -- это необходимо для хранения и отображения больших объемов данных в журнале
 // -- при отображении внутренними средствами производится подмена
 OneTwoReplace : boolean = {$IFDEF ONETWO}true {$ELSE} false {$ENDIF};
 OneTwoNote    : array[boolean] of string = ('отключено','включено [#13>#1; #10>#2]');

 // -- параметры потока, следящего за папкой журнала (и, естественно, за изменением лог-файла)
 auHandle       : cardinal = 0;
 auWork         : boolean  = False;
 auTerminated   : boolean  = True;
 auChangeHandle : cardinal = 0;
 auSleep        : cardinal = 50;
 auSDA          : array of TStringDynArray;
 maxUpdateTime  : integer  = 15000; // -- время в микросекундах, превышение которого останавливает автоматическое обновление ~ 1700 записей
 AutoUpdate     : boolean = true;
 maxPartSize    : integer = 1024 * 250; // -- максимальный размер части журнала
 LogFilePart    : integer = 0;


function GetUserFullname(const UserName: String; aWithState : boolean): string;
function GetAllUserGroups(const aUserName: String; var aGroupList : TStringDynArray): Boolean;

// -- Main : initialization of bases variables of module -------------------------------------------
function InitLogData(aOneDay,aSilent,aEachClose : boolean; const aLogFileName : string = '') : boolean;

function GetStringFromParamsOld(const aParams : array of const; var aResult : string): boolean;
function GetStringFromParamsNew(const aParams : array of const; var aResult : string): boolean;


function DirectRead(var aText : string) : boolean; // -- непосредственно из текущего файла журнала
function DirectWrite(const aRecord : string): boolean;

function SaveLongString(const aStr : string; aDT : TDateTime; isParam : boolean; var aFN : string) : boolean;

function AddRecordCommon(aType : TLogRecordType; const aValue : string; const aParams : array of const) : integer;

procedure LogInfoMessage(const aValue : string); overload;
procedure LogInfoMessage(const aValue : string; const aParams : array of const); overload;
procedure LogInfoMessage(const aProcName,aInfo : string; const aParams : array of const); overload;

procedure LogErrorMessage(const aProcName : string; E : Exception; const aParams : array of const);overload;
procedure LogErrorMessage(const aValue : string; const aParams : array of const);overload;
procedure ShowErrorEx(const aProcName : string; E : Exception; const aParams : array of const);

procedure LogWarningMessage(const aValue : string); overload;
procedure LogWarningMessage(const aValue : string; const aParams : array of const); overload;
procedure LogWarningMessage(const aProcName : string; E : Exception; const aParams : array of const);  overload;

procedure LogMessage(const aValue : string); overload;
procedure LogMessage(const aValue : string; const aParams : array of const); overload;
procedure LogMessage(const aProcName,aInfo : string; const aParams : array of const); overload;

function GetNormalString(const aStr : string) : string;

procedure ValidLogData;
procedure FlushLog;
procedure CloseLog;

procedure ShowLog(const aCFGFileName : string = '');





implementation

(******************************************************************************)

function GetSelfFileName : string;
var
 res  : array[0..260] of char;
begin
GetModuleFileName(Hinstance,res,Length(res));
Result:= strPas(PChar(@res[0]));
end;

{$IFDEF JCL}
function GetExceptionStackInfoJCL(P: PExceptionRecord): Pointer;
const
  cDelphiException = $0EEDFADE;
var
  Stack: TJclStackInfoList;
  Str: TStringList;
  Trace: String;
  Sz: Integer;
  cnt : integer;
begin
  if P^.ExceptionCode = cDelphiException then
    Stack := JclCreateStackList(False, 3, P^.ExceptAddr)
  else
    Stack := JclCreateStackList(False, 3, P^.ExceptionAddress);
  try
    Str := TStringList.Create;
    try
      Stack.AddToStrings(Str, True, True, True, True);
      {*for AppLogNew_DateTime*} for cnt:=0 to Str.Count-1
      {*for AppLogNew_DateTime*}    do Str[cnt]:=IfThen(cnt>0,DaggerChar)+ FormatFloat('000: ',cnt+1)+Str[cnt];
      Trace := StringReplace(Str.Text,crlf,' ',[rfReplaceAll]);
    finally
      FreeAndNil(Str);
    end;
  finally
    FreeAndNil(Stack);
  end;
  if Trace <> '' then
  begin
    Sz := (Length(Trace) + 1) * SizeOf(Char);
    GetMem(Result, Sz);
    Move(Pointer(Trace)^, Result^, Sz);
  end
  else
    Result := nil;
end;

function GetStackInfoStringJCL(Info: Pointer): string;
begin
  Result := PChar(Info);
end;

procedure CleanUpStackInfoJCL(Info: Pointer);
begin
try
  FreeMem(Info);
except
end;
end;
{$ENDIF}



procedure MainInitProc;
var
 szPSA      : cardinal;
 PSA        : PSecurityAttributes;
 prms       : string;
 _userinfo  : string;
 Filedates  : TFileDates;
 FileVersion: TFileVersion;
begin
terApp:=TThreadErrorRegister.StartRegister(10, 10);
AppParams.FillParams;
InitializeCriticalSection(LogCriticalSection);
szPSA:=SizeOf(TSecurityAttributes);
PSA:=AllocMem(szPSA);
try
PSA^.nLength:=szPSA;
LogMutexName:='Mtx'+AppParams.AppPrefix;
LogMutexHandle:=CreateMutex(PSA,false,PChar(LogMutexName));
finally
FreeMem(PSA);
end;
InitLogData(LogOneDay,LogSilentDead,LogEachClose);
prms:=AppParams.GetParams;
if AppParams.UserFullname=''
   then _userinfo:=Format('"%s"',[AppParams.UserName])
   else _userinfo:=Format('%s (%s)',[AppParams.UserFullname,AppParams.UserName]);
_userinfo:=_userinfo+Format(' на "%s" [%s]',[AppParams.WSName,AppParams.WSAddress]);
FileDates:=GetFileDates(PChar(AppParams.Params[0]));
FnCommon.GetFileVersion(ParamStr(0),FileVersion);
AppParams.verDate:=AC2Str(FileVersion.FileVersion) +' от '+FormatDateTime('dd.mm.yyyy hh:nn',FileDates.DateWrite);
AppParams.Params[0]:=GetSelfFileName;
LogInfoMessage(Format('Журналирование больших объемов данных %s.',[OneTwoNote[OneTwoReplace]]));
if prms=''
   then LogInfoMessage(Format('%s запустил "%s" ver. %s (без параметров).',[_userinfo,AppParams.Params[0],AppParams.verDate]))
   else LogInfoMessage(Format('%s запустил "%s" ver. %s, параметры: %s.',[_userinfo,AppParams.Params[0],AppParams.verDate,prms]));
if AppParams.UserGroupsStr<>''
   then LogInfoMessage('Группы пользователя: '+AppParams.UserGroupsStr);
{$IFDEF JCL}
Exception.GetExceptionStackInfoProc := GetExceptionStackInfoJCL;
Exception.GetStackInfoStringProc := GetStackInfoStringJCL;
Exception.CleanUpStackInfoProc := CleanUpStackInfoJCL;
{$ENDIF}
end;


procedure MainFinalProc;
var
 ln  : integer;
 fnl : TStringDynArray;
 cnt : integer;
begin
try
LogInfoMessage(Format('Завершение журнала для "%s".',[AppParams.Params[0]]));
CloseLog;
try
//if Assigned(LVF) then LVF.Close;
except
end;
if LogMutexHandle<>0
   then begin
   CloseHandle(LogMutexHandle);
   LogMutexHandle:=0;
   end;
LogMutexName:='';
DeleteCriticalSection(LogCriticalSection);
AppParams.ClearParams;
if not LogSilentDead and (ErrorCounter<>0)
   then begin
   if not LogSilentDead then // -- иначе стирать начнет
   if MessageBox(Application.Handle
              , PChar('В процессе работы были происходили ошибки. Они записаны в журнал.'+crlf+
                Format('Файлы журнала находятся в папке "%s".',[ExtractFilePath(LogFileName)])+crlf+
                'Вы хотите открыть эту папку для просмотра файлов?')
              ,'К сведению',MB_ICONQUESTION+MB_YESNO)=IDYES
      then FileOpenNT(ExtractFilePath(LogFileName));
   end
   else
if (WarningCounter<>0)
   then begin
   if not LogSilentDead then // -- иначе стирать начнет
   if MessageBox(Application.Handle
              , PChar('В процессе работы были происходили события, на которые стоит обратить внимание. Они записаны в журнал.'+crlf+
                Format('Файлы журнала находятся в папке "%s".',[ExtractFilePath(LogFileName)])+crlf+
                'Вы хотите открыть эту папку для просмотра файлов?')
              ,'К сведению',MB_ICONQUESTION+MB_YESNO)=IDYES
      then FileOpenNT(ExtractFilePath(LogFileName));
   end
   else
if not LogSilentDead
   then begin
   if MessageBox(Application.Handle
              , PChar('Программа была запущена с опцией просмотра журнала при завершении работы.'+crlf+
                Format('Файлы журнала находятся в папке "%s".',[ExtractFilePath(LogFileName)])+crlf+
                'Вы хотите открыть эту папку для просмотра файлов?')
              ,'К сведению',MB_ICONQUESTION+MB_YESNO)=IDYES
      then FileOpenNT(ExtractFilePath(LogFileName));
   end
   else begin
   ln:=Length(LogFileNameList)+1;
   SetLength(fnl,ln);
   for cnt:=0 to High(LogFileNameList)do fnl[cnt]:=LogFileNameList[cnt];
   fnl[High(fnl)]:=LogFileName;
   try
   for cnt:=0 to High(fnl)
     do try
        DeleteFile(fnl[cnt]);
        //ShellDeleteFile(Application.Handle,fnl[cnt],false,false);
        except
        end;
   finally
   SetLength(fnl,0);
   end;
   end;
finally
terApp.Free;
end;
end;

(**************************************************************************************************)

(* --- TThreadErrorRegister --- *)


procedure TThreadErrorRegister.SetErrorCount(Value : cardinal);
begin
if Value<>fErrorCount
 then fErrorCount:=Value;
end;

procedure TThreadErrorRegister.SetInterval(Value : cardinal);
begin
if Value<>fInterval
 then fInterval:=Value;
end;

function TThreadErrorRegister.GetCountAll : integer;
begin
Result:=Length(fItems);
end;

function TThreadErrorRegister.GetCountForInterval : integer;
var
 minDT : TDateTime;
 maxDT : TDateTime;
 cnt   : integer;
begin
maxDT:=Now;
minDT:=Now - MinutesToTime(fInterval);
Result:=0;
for cnt:=0 to High(fItems)
  do inc(Result, integer((fItems[cnt].dt>=minDT) and (fItems[cnt].dt<=maxDT)))
end;

function TThreadErrorRegister.GetNeedStop : boolean;
begin
Result:=GetCountForInterval>=integer(fErrorCount);
end;

procedure TThreadErrorRegister.CopyItem(FromIndex,ToIndex : integer);
begin
fItems[ToIndex].Cls:=fItems[FromIndex].Cls;
fItems[ToIndex].Msg:=fItems[FromIndex].Msg;
fItems[ToIndex].Stack:=fItems[FromIndex].Stack;
fItems[ToIndex].dt:=fItems[FromIndex].dt;
end;

function TThreadErrorRegister.Clear : boolean;
var
 cnt : integer;
begin
Result:=false;
try
for cnt:=High(fItems) downto 0
  do fItems[cnt]:=Default(TErrorItem);
SetLength(fItems,0);
Result:=true;
except
end;
end;
  // -- public
function TThreadErrorRegister.Add(aExc : Exception) : integer;
begin
Result:=Length(fItems);
SetLength(fItems, Result+1);
with fItems[Result] do
  begin
  Cls:=aExc.ClassName;
  Msg:=aExc.Message;
  try // -- кто ж знает с какой опцией компилятора, компилить будем, проверять свойства через RTTI лень!
  Stack:=aExc.StackTrace;
  except
  Stack:='';
  end;
  dt:=Now;
  end;
end;

function TThreadErrorRegister.ToString : string;
var
 ind : integer;
 hg  : integer;
 cnt : integer;
begin
hg:=High(fItems);
ind:=-1;
try
Result:=Format('Ошибок (всего): %1:d (%2:d)%0:s',[crlf, GetCountForInterval, GetCountAll]);
if hg<0 then Exit;
for cnt:=0 to hg do
  begin
  ind:=cnt;
  with fItems[ind] do
    Result:=Result+Format('%2:s%0:s%1:s%3:s%0:s%1:s%4:s%0:s%1:s%5:s%0:s',[crlf, #9, FormatDateTime('dd.mm.yyyy hh:nn:ss',dt),Cls, Msg, Stack]);
  end;
except
 on E : Exception do LogErrorMessage('TThreadErrorRegister.ToString',E,[ind,hg]);
end;
end;

procedure TThreadErrorRegister.ClearExpired;
var
 cnt     : integer;
// hg      : integer;
 minDate : TDateTime;
begin
minDate:=Now - MinutesToTime(fInterval);
for cnt:=High(fItems) downto 0
  do begin
  if (fItems[cnt].dt<minDate)
      then Delete(cnt);
//  if (fItems[cnt].dt<minDate)
//     then begin
//     if cnt<High(fItems)
//        then System.Move(fItems[cnt+1],fItems[cnt],(High(fItems)-cnt) * SizeOf(TErrorItem));
//     sleep(1);
//     hg:=Length(fItems)-1;
//     ClearItem(hg);
//     SetLength(fItems,hg);
//     end;
  end;
end;

procedure TThreadErrorRegister.ClearItem(Index : integer);
begin
if (Index<0) or (Index>=GetCountAll) then Exit;
//with fItems[Index] do
//   begin
//   Cls:='';
//   Msg:='';
//   Stack:='';
//   end;
//FillChar(fItems[Index],SizeOf(TErrorItem),0);
fItems[Index] := Default(TErrorItem);
end;

procedure TThreadErrorRegister.Delete(Index : integer);
var
 cnt : integer;
 hg  : integer;
begin
if (Index<0) or (Index>=GetCountAll) then Exit;
try
if Index<High(fItems)
   then for cnt:=Index to High(fItems)-1
          do CopyItem(cnt+1,cnt);
//if Index<High(fItems)
//   then begin
//   hg:=High(fItems);
//   fItems[Index]:=Default(TErrorItem);
//   System.Move(fItems[Index+1],fItems[Index],(hg-Index) * SizeOf(TErrorItem));
//   end;
hg:=High(fItems);
ClearItem(hg);
SetLength(fItems,hg);
except
 on E : Exception do LogErrorMessage('TThreadErrorRegister.Delete',E,[Index,High(fItems)]);
end;
end;
  // -- published
constructor TThreadErrorRegister.StartRegister(ErrorCount, Interval : cardinal);
begin
inherited Create;
fErrorCount:=ErrorCount;
fInterval:=Interval;
end;

destructor TThreadErrorRegister.Destroy;
begin
Clear;
inherited destroy;
end;


(**************************************************************************************************)


procedure TAppParams.FillParams;
const
 dlm : string = ', ';
var
 cnt : integer;
 ln  : integer;
 FN  : string;
begin
Setlength(Params,0);
for cnt:=0 to ParamCount
  do begin
  ln:=Length(Params);
  Setlength(Params,ln+1);
  Params[ln]:=UpperCase(ParamStr(cnt));
  end;
UserName:=Trim(GetUserName);
{$IFNDEF NODOMAIN}
if not ParamExists('nodomain')
   then begin
   ShowSplash('Запуск (Инициализация) ... '(*'Доменная идентификация'*),stInfo);
   try
   UserFullName:='';
     try
     UserFullName:=GetUserFullname(UserName, false) ;
     except
     end;
   UserGroupsStr:='';
     try
     GetAllUserGroups(Username,UserGroups);
     for cnt:=0 to High(UserGroups) do UserGroupsStr:=UserGroupsStr+UserGroups[cnt]+dlm;
     UserGroupsStr:=Copy(UserGroupsStr,1,Length(UserGroupsStr)-Length(dlm));
     except
     end;
   finally
   FreeSplash;
   end;
   end;
{$ENDIF}
WSName:=Trim(GetWorkStationName);
WSAddress:=Trim(LocalIP);
UserFolder:=Trim(SetTailBackSlash(GetDocFolder));
FN:=ChangeFileExt(ExtractFileName(ParamStr(0)),'.INI');
AppPrefix:=Trim(ChangeFileExt(FN,''));
CFGUserFileName:=UserFolder+CFGSoftFolder+AppPrefix+'\';
if DirectoryExists(CFGUserFileName) or
   ForceDirectories(CFGUserFileName)
   then CFGUserFileName:=Trim(CFGUserFileName+FN+#0)
   else CFGUserFileName:=Trim(SetTailBackSlash(GetTempFolder)+FN);
AppCFGFolder:=SettailBackSlash(ExtractFilePath(CFGUserFileName));
CFGCommonFileName:=Trim(SetTailBackSlash(ExtractFilePath(Params[0]))+FN);
CFGComDocFileName:=Trim(SetTailBackSlash(GetCommonDocFolder)+CFGSoftFolder+AppPrefix+'\'+FN);
SelfPID:=GetCurrentProcessId;// аналогично : GetWindowThreadProcessId(Application.Handle,SelfPID);
if not DirectoryExists(ExtractFilePath(CFGComDocFileName)) then ForceDirectories(ExtractFilePath(CFGComDocFileName));
end;


function TAppParams.ParamExists(const aParam : string):boolean;
var
 tst : string;
 cnt : integer;
begin
tst:=UpperCase(aParam);
Result:=False;
try
for cnt:=0 to High(Params)
  do if Params[cnt] = tst
        then begin
        Result:=True;
        Break;
        end;
finally
tst:='';
end;
end;

function TAppParams.ParamBeginWith(const aParam : string):integer;
var
 tst : string;
 cnt : integer;
begin
tst:=UpperCase(aParam);
try
for cnt:=0 to High(Params)
  do if AnsiPos(tst,Params[cnt])=1
        then begin
        Result:=cnt;
        Exit;
        end;
//for Re-sult:=0 to High(Params)
//  do if AnsiPos(tst,Params[Result])=1
//        then Exit;
Result:=-1;
finally
tst:='';
end;
end;

function TAppParams.GetParams : string;
const dlm = ', ';
var cnt : integer;
begin
Result:='';
for cnt:=1 to High(Params)
  do if (Params[cnt]<>'') and (Params[cnt][1]<>'-') then
         Result:=Result+Params[cnt]+dlm;
Setlength(Result,Length(Result)-Length(dlm));
end;

procedure TAppParams.ClearParams;
begin
Setlength(UserGroups,0);
Setlength(Params,0);
UserName          := '';
UserFullName      := '';
UserGroupsStr     := '';
UserFolder        := '';
WSName            := '';
WSAddress         := '';
AppPrefix         := '';
CFGUserFileName   := '';
CFGCommonFileName := '';
CFGComDocFileName := '';
end;


(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

// -- еще вариант -----------------------------
//1. Можно читать разницу из файла
//  * установить на предыдущий размер и прочитать до конца
//  * разделить конец на массив TSringDynArray
//  * отфильтровать требуемые
//  * добавить к существующим позициям
//  * взять требуемую колонку и через AddObject([Значение_колонки], TObject(Index_In_LogStringsArray)) запихнуть в лист для сортировки

function DirChanged(Parameter : pointer) : cardinal;
  // -- // --- Подготовка массива строк для отображения (парсинг, сортировка, отбор по фильтру) ----
  function PrepareTextForShow(const Text : string) : boolean;
  var
   lvfSortCol : integer;
   lvfSortDir : boolean;
   lvfFilter  : TLogViewFilter;
   sortStrl   : TStringList;
   tmpStrl    : TStringList;
   sda        : TStringDynArray;
   cnt        : integer;
   tmpStr     : string;
   ind        : integer;
   cntLSA     : integer;
  begin
  Result:=false;
  try
  if Assigned(LVF)
     then begin
     lvfSortCol:=LVF.SortCol;
     lvfSortDir:=LVF.SortDir;
     lvfFilter:=LVF.Filter;
     end
     else Exit;
  try
  sortStrl:=TStringList.Create;
  try
  sortStrl.Text:=Text;
  for cnt:=0 to sortStrl.Count-1
    do begin
    sda:=SplitString(sortStrl[cnt],DaggerChar);
    try
    if Length(sda)>lvfSortCol
       then begin
       if lvfSortCol=0
          then begin
          tmpStr:=FormatDateTime('yyyymmdd_hhnnsszzz',StrToDateTimeByFormat(Trim(Copy(sda[0],1,Pos('[',sda[0]))),LogLongDateFormat));
          sortStrl[cnt]:=tmpStr+DoubleDaggerChar+sortStrl[cnt];
          end
          else sortStrl[cnt]:=sda[lvfSortCol]+DoubleDaggerChar+sortStrl[cnt];
       end
    finally
    SetLength(sda,0);
    end;
    end;
  sortStrl.Sort;
  tmpStr:='';
  if lvfSortDir
     then for cnt:=sortStrl.Count-1 downto 0
              do tmpStr:=tmpStr+Copy(sortStrl[cnt],Pos(DoubleDaggerChar,sortStrl[cnt])+1,Length(sortStrl[cnt]))+crlf
     else for cnt:=0 to sortStrl.Count-1
              do tmpStr:=tmpStr+Copy(sortStrl[cnt],Pos(DoubleDaggerChar,sortStrl[cnt])+1,Length(sortStrl[cnt]))+crlf;
  finally
  FreeStringList(sortStrl);
  end;
  except
  Exit;
  end;
  if TryEnterCriticalSection(LogCriticalSection)
     then begin
     tmpStrl:=TStringList.Create;
     try
     tmpStrl.Text:=trim(tmpStr);
     SetLength(auSDA,0);
     for cnt:=0 to tmpStrl.Count-1
         do begin
         sda:=SplitString(tmpStrl[cnt],DaggerChar);
         try
         if (Length(sda)>2) and
            (
             (TLogRecordType(StrToIntDef(sda[1],3)) in lvfFilter) or
             ((StrToIntDef(sda[1],3)=4) and (TLogRecordType(lrtError) in lvfFilter)) // -- show Stack with Errors
            )
            then begin
            ind:=Length(auSDA);
            SetLength(auSDA,ind+1);
            SetLength(auSDA[ind],Length(sda));
            for cntLSA:=0 to High(sda) do auSDA[ind][cntLSA]:=sda[cntLSA];
            end;
        finally
        SetLength(sda,0);
        end;
        end;
    Result:=True;
    finally
    FreeStringList(tmpStrl);
    LeaveCriticalSection(LogCriticalSection);
    end;
    end;
  except
   on E : Exception do LogErrorMessage('PrepareTextForShow',E,[]);
  end;
  end;
  // -- // -----------------------------------------------------------------------------------------
var
  fileSize     : integer;
  tempSize     : integer;
  fileBody     : string;
  NotifyFilter : cardinal;
  NotifyPath   : PChar;
  counter      : integer;
begin
fileSize:=GetSizeOfFile(LogFileName);
try
NotifyFilter:=//FILE_NOTIFY_CHANGE_FILE_NAME  +   // Any filename change in the watched directory or subtree causes a change notification wait operation to return. Changes include renaming, creating, or deleting a filename.
              //FILE_NOTIFY_CHANGE_DIR_NAME   +   // Any directory-name change in the watched directory or subtree causes a change notification wait operation to return. Changes include creating or deleting a directory.
              //FILE_NOTIFY_CHANGE_ATTRIBUTES +   // Any attribute change in the watched directory or subtree causes a change notification wait operation to return.
              FILE_NOTIFY_CHANGE_SIZE	   +        // Any file-size change in the watched directory or subtree causes a change notification wait operation to return. The operating system detects a change in file size only when the file is written to the disk. For operating systems that use extensive caching, detection occurs only when the cache is sufficiently flushed.
              FILE_NOTIFY_CHANGE_LAST_WRITE ;     // Any change to the last write-time of files in the watched directory or subtree causes a change notification wait operation to return. The operating system detects a change to the last write-time only when the file is written to the disk. For operating systems that use extensive caching, detection occurs only when the cache is sufficiently flushed.
              //FILE_NOTIFY_CHANGE_SECURITY   ;   // Any security-descriptor change in the watched directory or subtree causes a change notification wait operation to return.
NotifyPath:=AllocMem(Length(LogFolderName)*SizeOfChar+1);
try
StrPCopy(NotifyPath,LogFolderName); //ExtractFilePath(ParamStr(0))
auChangeHandle:=FindFirstChangeNotification(NotifyPath, false, NotifyFilter);
finally
FreeMem(NotifyPath);
end;
counter:=0;
if auChangeHandle <> INVALID_HANDLE_VALUE
 then begin
 while auWork
   do begin
   try
   if WaitForSingleObject(auChangeHandle,250) = WAIT_OBJECT_0
      then begin
      if Assigned(LVF)
         then begin
         tempSize:=GetSizeOfFile(LogFileName);
         // -- перед любыми более-менее долгими операциями проверяем auWork
         if auWork and (tempSize<>fileSize) and DirectRead(fileBody)
            then begin
            try
            if auWork and PrepareTextForShow(fileBody)
               then begin
               SendMessage(LVF.Handle,LOG_FILEUPDATED,2,0);
               sleep(1);
               end;
            if not auWork then Exit;
            fileSize:=tempSize;
            finally
            fileBody:='';
            end;
            end;
         end
         else begin
         if not Assigned(LVF)
            then Exit;
         end;
	    end;
   if not auWork then Exit;
   FindNextChangeNotification(auChangeHandle);
   if (counter=2) and Assigned(LVF)
      then begin
      SendMessage(LVF.Handle,LOG_FILEUPDATED,0,0);
      counter:=0;
      end
      else begin
      if not Assigned(LVF)
         then Exit;
      inc(counter);
      end;
   if not auWork then Exit;
   sleep(auSleep);
   except
   end;
   end;
end;
finally
FindCloseChangeNotification(auChangeHandle);
sleep(1);
auWork:=false;
auTerminated:=True;
GetExitCodeThread(auHandle,Result);
EndThread(Result);
end;
end;

procedure TLogViewForm.DirWatchHandler(var Msg : TMessage);
begin
//SuspendThread(auHandle);
try
case Msg.wParam of
1 : LVF_DblClick(self);
2 : FillFromSDA;
else begin
Tag:=integer(not boolean(Tag));
if Tag=0
   then Icon.Handle:= Application.Icon.Handle
   else Icon.Handle:= LoadIcon(0, IDI_INFORMATION);
end;
end;
finally
//ResumeThread(auHandle);
Msg.Result:=1;
ReplyMessage(Msg.Result);
end;
end;


procedure TLogViewForm.StartDirWatch;
var
   hThrLocal  : cardinal;
   PSA        : PSecurityAttributes;
begin
if not AutoUpdate then Exit;
CreatePSA(PSA);
try
auWork:=True;
auTerminated:=False;
auHandle := BeginThread(PSA,0,@DirChanged,nil,THREAD_FULL,hThrLocal);
sleep(1);
SetThreadPriority(auHandle,THREAD_PRIORITY_BELOW_NORMAL);
hThrLocal:=0;
finally
FreeMem(PSA);
end;
end;

procedure TLogViewForm.StopDirWatch;
var
  Counter  : integer;
begin
if (auHandle<>0) or (not auTerminated)
   then begin
   try
   auWork:=False;
   sleep(1);
   Counter:=0;
   while not auTerminated
     do begin
     inc(Counter);
     sleep(1);
     if Counter>250 then Break;
     end;
   if Counter>250
      then TerminateThread(auHandle,2);
   finally
   CloseHandle(auHandle);
   auHandle:=0;
   end;
   end;
end;

destructor TLogViewForm.Destroy;
begin
try
StopDirWatch;
except
end;
inherited Destroy;
end;


procedure TLogViewForm.RefreshLog;
var
 tmp : string;
begin
if not DirectRead(tmp)
   then Exit;
try
//LogText:=tmp;
FillFromLogList(tmp,Filter);
finally
//LogText:='';
tmp:='';
end;
end;

procedure TLogViewForm.FillFromLogList(const aLogListText : string; aFilter : TLogViewFilter = [lrtInfo,lrtWarning,lrtError]);
var
 cnt     : integer;
 maxCol  : integer;
 ind     : integer;
 cntLSA  : integer;
 sda     : TStringDynArray;
 txt     : string;
 tmpStrl : TStringList;
 sortStrl: TStringList;
 start   : int64;
 finish  : int64;
 freq    : int64;

begin
QueryPerformanceCounter(start);
try
txt:=aLogListText;
maxCol:=3;
if not ErrorOnSort
then begin
try
sortStrl:=TStringList.Create;
try
sortStrl.Text:=txt;
for cnt:=0 to sortStrl.Count-1
  do begin
  sda:=SplitString(sortStrl[cnt],DaggerChar);
  try
  if Length(sda)>SortCol
     then begin
     if SortCol=0
        then begin
        txt:=FormatDateTime('yyyymmdd_hhnnsszzz',StrToDateTimeByFormat(Trim(Copy(sda[0],1,Pos('[',sda[0]))),LogLongDateFormat));
        sortStrl[cnt]:=txt+DoubleDaggerChar+sortStrl[cnt];
        end
        else sortStrl[cnt]:=sda[SortCol]+DoubleDaggerChar+sortStrl[cnt];
     end
  finally
  SetLength(sda,0);
  end;
  end;
sortStrl.Sort;
txt:='';
if SortDir
   then for cnt:=sortStrl.Count-1 downto 0
            do txt:=txt+Copy(sortStrl[cnt],Pos(DoubleDaggerChar,sortStrl[cnt])+1,Length(sortStrl[cnt]))+crlf
   else for cnt:=0 to sortStrl.Count-1
            do txt:=txt+Copy(sortStrl[cnt],Pos(DoubleDaggerChar,sortStrl[cnt])+1,Length(sortStrl[cnt]))+crlf;
finally
FreeStringList(sortStrl);
end;
except
ErrorOnSort:=true;
end;
end;

tmpStrl:=TStringList.Create;
try
tmpStrl.Text:=trim(txt);
SetLength(LogStringsArray,0);
for cnt:=0 to tmpStrl.Count-1
  do begin
  sda:=SplitString(tmpStrl[cnt],DaggerChar);
  try
  if (Length(sda)>2) and
     (
        (TLogRecordType(StrToIntDef(sda[1],3)) in aFilter)
     or ((StrToIntDef(sda[1],3)=4) and (TLogRecordType(lrtError) in aFilter)) // -- show Stack with Errors
     )
     then begin
     ind:=Length(LogStringsArray);
     SetLength(LogStringsArray,ind+1);
     SetLength(LogStringsArray[ind],Length(sda));
     for cntLSA:=0 to High(sda) do LogStringsArray[ind][cntLSA]:=sda[cntLSA];
     end;
  finally
  SetLength(sda,0);
  end;
  end;
finally
FreeStringList(tmpStrl);
end;
if Assigned(DrGr)
   then begin
   DrGr.ColCount:=maxCol;
   DrGr.RowCount:=1+length(LogStringsArray)+integer(Length(LogStringsArray)=0);
   DrGr.Invalidate;
   end;
LVF_EdFnd_Change(EdFnd);
QueryPerformanceCounter(finish);
QueryPerformanceFrequency(freq);
start:=Round((finish-start)/freq*1000000);
Caption:=Format('Журнал выполнения. Обновлено %s (%d %sS)',[FormatDateTime(LogLongDateFormat,Now),start,MicroChar]);
if LVF.LabFileName.Hint<>logFileName
   then begin
   LVF.LabFileName.Caption:='Файл журнала: '+logFileName;
   LVF.LabFileName.Hint:=logFileName;
   end;


if (start>maxUpdateTime)
   then begin
   AutoUpdate:=false;
   StopDirWatch;
   Caption:='Журнал выполнения. Автообновление остановлено (overtime).';
   end;
except
 on E : Exception do LogErrorMessage('TLogViewForm.FillFromLogList',E,[]);
end;
end;

procedure TLogViewForm.FillFromSDA;
var
 start   : int64;
 finish  : int64;
 freq    : int64;
 cntRow  : integer;
 cntCol  : integer;
begin
if not TryEnterCriticalSection(LogCriticalSection)
 then Exit;
try
QueryPerformanceCounter(start);
try
SetLength(LogStringsArray, Length(auSDA));
for cntRow:=0 to High(LogStringsArray)
  do begin
  SetLength(LogStringsArray[cntRow],Length(auSDA[cntRow]));
  for cntCol:=0 to High(LogStringsArray[cntRow]) do LogStringsArray[cntRow,cntCol]:=auSDA[cntRow,cntCol];
  end;
if Assigned(DrGr)
   then begin
   DrGr.ColCount:=3;
   DrGr.RowCount:=1+length(LogStringsArray)+integer(Length(LogStringsArray)=0);
   DrGr.Invalidate;
   end;
LVF_EdFnd_Change(EdFnd);
QueryPerformanceCounter(finish);
QueryPerformanceFrequency(freq);
start:=Round((finish-start)/freq*1000000);
Caption:=Format('Журнал выполнения. Обновлено %s (%d %sS)',[FormatDateTime(LogLongDateFormat,Now),start,MicroChar]);
if (start>maxUpdateTime)
   then begin
   StopDirWatch;
   Caption:='Журнал выполнения. Автообновление остановлено (overtime).';
   end;
finally
for cntRow:=0 to High(auSDA) do SetLength(auSDA[cntRow],0);
SetLength(auSDA,0);
LeaveCriticalSection(LogCriticalSection);
end;
except
 on E : Exception do LogErrorMessage('TLogViewForm.FillFromSDA',E,[]);
end;
end;

procedure TLogViewForm.LVF_Close(Sender : TObject; var Action : TCloseAction);
begin
try
if not Visible then Exit;
Hide;
Application.ProcessMessages;
StopDirWatch;
if Assigned(ChLB)then ChLB.OnClickCheck:=nil;
if Assigned(DrGr)then DrGr.OnDrawCell:=nil;
try
if Assigned(DrGr)then SaveColumnsEx(self,DrGr,CFGName);
SavePosition(self,CFGName);
finally
Action:=caFree;
LVF:=nil;
end;
except
 on E : Exception  do LogErrorMessage('TLogViewForm.LVF_Close',E,[]);
end;
end;

procedure TLogViewForm.LVF_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  function GetOneString(Row : integer;asCSV : boolean) : string;
  const
    dlm   : array[boolean] of string = (tab, ';');
  var
   cnt : integer;
   tmp : string;
  begin
  Result:='';
  for cnt:=0 to High(LogStringsArray[Row])
     do begin
     tmp:=LogStringsArray[Row,cnt];
     if (cnt=1)
        then tmp:=trim(descr[TLogRecordType(StrToIntDef(tmp,0))]);
     if asCSV
        then tmp:=AnsiQuotedStr(tmp,'"');
     Result:=Result+tmp+dlm[asCSV];
     end;
  Result:=Copy(Result,1,Length(Result)-Length(dlm[asCSV]));
  end;
var
 str  : string;
 fn   : string;
 cnt  : integer;
 csv  : boolean;
begin
inherited;
try
if (Key in [VK_N,VK_A]) and (ssCtrl in Shift)
   then begin
   str:='';
   if InputQuery('Журнал выполнения','Пользовательская заметка',str) and (str<>'')
      then LogInfoMessage(str);
   end
   else
if (Key=VK_C) and (ssCtrl in Shift)
   then begin
   csv:=(ssAlt in Shift);
   str:='';
   if (ssShift in Shift)
      then begin
      for cnt:=0 to High(LogStringsArray)
        do str:=str+GetOneString(cnt,csv)+crlf;
      end
      else begin
      cnt:=DrGr.Row-1;
      if (cnt<Low(LogStringsArray)) or (cnt>High(LogStringsArray)) then Exit;
      str:=GetOneString(cnt,csv);
     end;
   if str<>'' then CopyStringIntoClipboard(str);
   end
   else
if (Key=VK_S) and (ssCtrl in Shift)
   then begin
   try
   fn:=ChangeFileExt(AppParams.CFGUserFileName,'.LOG');
   DirectRead(str);
   str:=GetNormalString(str);
   SaveStringIntoFileStream(str, fn);
   _sleep(10);
   if FileExists(str) and (MessageBox(Handle,PChar(Format('Журнал сохранен в %s. Открыть для просмотра?',[AnsiQuotedStr(str,'"')])),'Файл журнала',MB_ICONINFORMATION + MB_YESNO)=IDYES)
      then FileOpenNT(str);
   except
   on E : Exception do LogErrorMessage('TLogViewForm.LVF_KeyDown',E,['SaveLog']);
   end;
   end;
except
 on E : Exception  do LogErrorMessage('TLogViewForm.LVF_KeyDown',E,[]);
end;
end;

procedure TLogViewForm.LVF_Resize(Sender: TObject);
begin
Invalidate;
DrGr.Invalidate;
end;


procedure TLogViewForm.LVF_DblClick(Sender: TObject);
begin
RefreshLog;
end;

procedure TLogViewForm.LVF_Show(Sender: TObject);
begin
Update;
StartDirWatch;
end;

procedure TLogViewForm.LVF_FilterClick(Sender : TObject);
var
 cnt : integer;
 flt : TLogViewFilter;
 tmp : string;
begin
flt:=[];
for cnt:=0 to ChLB.Items.Count-1
  do if ChLB.Checked[cnt]
        then flt:=flt+[TLogRecordType(cnt)];
try
if flt=[] then flt:=[lrtInfo,lrtWarning,lrtError,lrtUndef];
Filter:=flt;
if Assigned(LVF)
   then if DirectRead(tmp)
           then FillFromLogList(tmp,Filter);
except
 on E : Exception  do LogErrorMessage('TLogViewForm.CallFill',E,[]);
end;
end;


procedure TLogViewForm.LVF_DrGrDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
const
 BrClrs  : array[boolean,boolean] of TColor = ((clWindow, clInfoBk),(clHighlight, clHighlight));
 FndClrs : array[boolean] of TColor = (clPaleGreen, clGreen);
 FnClrs  : array[boolean] of TColor = (clWindowText, clHighlightText);
 Titles  : array[0..2] of string = ('Дата','Тип','Описание');
var
 rct : TRect;
 str : string;
 alg : integer;
 ind : integer;
 sel : boolean;
begin
try
str:='';
rct:=Classes.Rect(Rect.Left+2, Rect.Top+1, Rect.Right-2, Rect.Bottom-1);
alg:=DT_LEFT_ALIGN;
try
case Arow of
0 : str:=Titles[ACol];
else begin
ind:=ARow-1;
if (ind<Low(LogStringsArray)) or (ind>High(LogStringsArray)) then Exit;
if (ACol>=Low(LogStringsArray[ind])) and (ACol<=High(LogStringsArray[ind]))
   then str:=LogStringsArray[ind][ACol];
sel:=(gdSelected in State) or (gdFocused in State);
DrGr.Canvas.Brush.Color:=BrClrs[sel,Length(LogStringsArray[ind])>=4];
DrGr.Canvas.Font.Color:=FnClrs[sel];
case ACol of
0 : alg:=DT_RIGHT_ALIGN;
1 : begin
    alg:=DT_CENTER_ALIGN;
    if not CheckValidInteger(str,true)
       then str:='3';
    end;
end;
if InnerBool(ind,resInd)
   then DrGr.Canvas.Brush.Color:=FndClrs[sel];
end;
end;
finally
with DrGr.Canvas do
  begin
  Windows.FillRect(Handle, Rect, Brush.Handle);
  if ARow=0
     then begin
     if ACol=SortCol
        then SimpleTriAngleOrder(Handle,rct.Right-15,rct.Top+1,not SortDir,ttobcGray,15);
     DrawTransparentText(Handle,str,rct,alg);
     end
     else
  if (ARow>0) and (ACol=1)
     then begin
     (*ATTENTION*)IL.DrawingStyle:=dsTransparent;
     (*ATTENTION*)IL.Draw(DrGr.Canvas,rct.Left+(Rect.Right - Rect.Left) div 2 - IL.Width div 2,rct.Top,StrToIntDef(str,3));
     end
     else DrawTransparentText(Handle,str,rct,alg);
  end;
end;
except
 on E : Exception do ;
end;
end;


procedure TLogViewForm.LVF_DrGrDoubleClick(Sender: TObject);
var
 ind    : integer;
 lrt    : TLogRecordType;
 ico    : integer;
 cnt    : integer;
 //sda    : TStringDynArray;
 txt    : string;
 //cntSub : integer;
 fnd    : string;

begin
ind:=Drgr.Row-1;
if (ind>=Low(LogStringsArray)) and (ind<=High(LogStringsArray))
   then begin
   if Length(LogStringsArray[ind])<=3
      then Exit;
   lrt:=TLogRecordType(StrToIntDef(LogStringsArray[ind][1],3));
   case lrt of
   lrtInfo    : ico:=MB_ICONINFORMATION;
   lrtWarning : ico:=MB_ICONWARNING;
   lrtError   : ico:=MB_ICONERROR;
   else ico:=0;
   end;
   txt:='';
   for cnt:=3 to High(LogStringsArray[ind])
     do txt:=txt+LogStringsArray[ind][cnt]+DaggerChar;
   if OneTwoReplace
      then begin
      if Pos(#2, txt)<>0 then txt:=StringReplace(txt,#2,#13,[rfReplaceAll]);
      if Pos(#1, txt)<>0 then txt:=StringReplace(txt,#1,#10,[rfReplaceAll]);
      if Pos(DaggerChar, txt)<>0 then txt:=StringReplace(txt,DaggerChar,crlf,[rfReplaceAll]);
      end
      else begin
      if (Pos('dop_file ', txt)=1)
         then begin
         fnd:=AnsiDeQuotedStr(StringReplace(Trim(txt),'dop_file ','',[]),'"');
         if FileExists(fnd)
            then txt:=LoadStringFromFile(fnd);
         end;
      end;
   ScrollMessageBox(LogStringsArray[ind][0]+': '+LogStringsArray[ind][2],txt,'','Запись в журнале',ico,MB_Ok);
   end;
end;


procedure TLogViewForm.LVF_DrGrFixedCellClick(Sender: TObject; ACol, ARow: Integer);
var
 tmp : string;
begin
if not DirectRead(tmp)
  then Exit;
try
if SortCol=ACol
   then SortDir:=not SortDir
   else SortCol:=ACol;
 try
 SaveInteger('Settings','LogSortCol',SortCol,LVF.CFGName);
 SaveBool('Settings','LogSortDir',SortDir,LVF.CFGName);
 except
 end;
FillFromLogList(tmp,Filter);
finally
tmp:='';
end;
end;

procedure TLogViewForm.LVF_EdFnd_Change(Sender: TObject);
var
 cnt  : integer;
 cntL : integer;
 ind  : integer;
 fnd  : string;
begin
SetLength(resInd,0);
if EdFnd.Text<>''
   then begin
   fnd:=AnsiUppercase(EdFnd.Text);
   for cnt:=0 to High(LogStringsArray)
     do begin
     if Length(LogStringsArray[cnt])>2
        then for cntL:=2 to High(LogStringsArray[cnt])
               do if AnsiPos(fnd, AnsiUpperCase(LogStringsArray[cnt,cntL]))<>0
                     then begin
                     ind:=Length(resInd);
                     Setlength(resInd,ind+1);
                     resInd[ind]:=cnt;
                     Break;
                     end;
     end;
  end;
LabFnd.Caption:=Format('Поиск. Найдено: %d из %d',[Length(resInd), Length(LogStringsArray)]);
LabFnd.Hint:=Format('Всего строк: %1:d%0:sНайдено: %2:d',[crlf, Length(LogStringsArray), Length(resInd)]);
LabFnd.ShowHint:=true;
EdFnd.Hint:=fnd;
DrGr.Invalidate;
end;


procedure TLogViewForm.LVF_LabFileName_Click(Sender : TObject);
begin
FileOpenNT(ExtractFilePath(logFileName));
end;

procedure TLogViewForm.LVF_LabFnd_Click(Sender : TObject);
var
 ind : integer;
 row : integer;
begin
if Length(resInd)=0
   then begin
   LabFnd.Tag:=0;
   Exit;
   end;
ind:=LabFnd.Tag;
if (ind>High(resInd))
   then begin
   LabFnd.Tag:=Low(resInd);
   ind:=LabFnd.Tag;
   end;
if (ind>=Low(resInd)) and (ind<=High(resInd))
   then begin
   row:=resInd[ind]+1;
   if (row>0) and (row<drGr.RowCount)
      then SetVisibleRow3(DrGr,row);
   LabFnd.Tag:=LabFnd.Tag+1;
   end;
end;

procedure TLogViewForm.LVF_ButtonsClick(Sender: TObject);
begin
// кнопок еще нет, а процедура уже есть
end;


(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(***************************************************************************************************)
const
  netapi32lib = 'netapi32.dll';
  NERR_Success = NO_ERROR;
type
  PGroupUsersInfo2 = ^TGroupUsersInfo2;
  TGroupUsersInfo2 = record
    usri2_name             : LPWSTR ;
    usri2_password         : LPWSTR ;
    usri2_password_age     : DWORD  ;
    usri2_priv             : DWORD  ;
    usri2_home_dir         : LPWSTR ;
    usri2_comment          : LPWSTR ;
    usri2_flags            : DWORD  ;
    usri2_script_path      : LPWSTR ;
    usri2_auth_flags       : DWORD  ;
    usri2_full_name        : LPWSTR ;
    usri2_usr_comment      : LPWSTR ;
    usri2_parms            : LPWSTR ;
    usri2_workstations     : LPWSTR ;
    usri2_last_logon       : DWORD  ;
    usri2_last_logoff      : DWORD  ;
    usri2_acct_expires     : DWORD  ;
    usri2_max_storage      : DWORD  ;
    usri2_units_per_week   : DWORD  ;
    usri2_logon_hours      : PBYTE  ;
    usri2_bad_pw_count     : DWORD  ;
    usri2_num_logons       : DWORD  ;
    usri2_logon_server     : LPWSTR ;
    usri2_country_code     : DWORD  ;
    usri2_code_page        : DWORD  ;
 end;

 PGroupUsersInfo0 = ^TGroupUsersInfo0;
  TGroupUsersInfo0 = record
    grui0_name : LPWSTR;
  end;

function NetApiBufferFree(Buffer: Pointer): DWORD; stdcall;    external netapi32lib;
function NetGetDCName(ServerName: PWideChar; DomainName: PWideChar;  var Bufptr: PWideChar): DWORD; stdcall; external netapi32lib;
function NetUserGetInfo(ServerName: PWideChar; UserName: PWideChar; Level: DWORD; var Bufptr: Pointer): DWORD; stdcall; external netapi32lib;
function NetUserGetGroups(ServerName: PWideChar; UserName: PWideChar; Level: DWORD; var Bufptr: Pointer; PrefMaxLen: DWORD; var EntriesRead: DWORD; var TotalEntries: DWORD): DWORD; stdcall; external netapi32lib;

function GetDomainController(const DomainName: String): String;
var
  Domain : PWideChar;
  Server : PWideChar;
begin
Domain := PChar(DomainName);
if NetGetDCName(nil, Domain, Server) = NERR_Success
   //NetGetDCName('\\192.168.57.11', @Domain[1], Server) = NERR_Success
   then try
        Result := Server;
        finally
        NetApiBufferFree(Server);
        end;
end;

function GetUserFullname(const UserName: String; aWithState : boolean): string;
var
  Info : pointer;
  ctrl : string;
  com  : array[1..256] of char;
  fn   : array[1..256] of char;
begin
Result:=UserName;
ctrl:=GetDomainController(''); // --- а пользователи могут быть и из другого домена (как логисты, например)
if NetUserGetInfo(StringToOleStr(ctrl), StringToOleStr(UserName), 2, Info) <> NERR_Success
   then Exit;
try
StrPCopy(@com[1],WideCharToString(PGroupUsersInfo2(Info)^.usri2_comment));
StrPCopy(@fn[1],WideCharToString(PGroupUsersInfo2(Info)^.usri2_full_name));
Result:=StrPas(Pchar(@com[1]));
if (Result<>'') and aWithState
   then Result:=StrPas(Pchar(@fn[1]))+' ['+Result+']'
   else Result:=StrPas(Pchar(@fn[1]));
finally
NetApiBufferFree(Info);
end;
end ;


function GetAllUserGroups(const aUserName: String; var aGroupList : TStringDynArray): Boolean;
var
  ctrl         : string;
  Tmp          : PGroupUsersInfo0;
  Info         : PGroupUsersInfo0;
  PrefMaxLen   : DWORD;
  EntriesRead  : DWORD;
  TotalEntries : DWORD;
  I            : Integer;
  ind          : integer;
begin
ctrl:=GetDomainController('');
Setlength(aGroupList,0);
PrefMaxLen := DWORD(-1);
Result := NetUserGetGroups(StringToOleStr(ctrl), StringToOleStr(aUserName), 0, Pointer(Info), PrefMaxLen, EntriesRead, TotalEntries) = NERR_Success;
if not Result then Exit;
try
Tmp := Info;
for I := 0 to EntriesRead - 1
  do begin
  ind:=Length(aGroupList);
  SetLength(aGroupList,ind+1);
  aGroupList[ind]:=WideCharToString(Tmp^.grui0_name);
  Inc(Tmp);
  end;
finally
NetApiBufferFree(Info);
end;
end;

(**************************************************************************************************)

// -- Main : initialization of bases variables of module -------------------------------------------
function InitLogData(aOneDay,aSilent,aEachClose : boolean; const aLogFileName : string = '') : boolean;
var
 tempFolder : string;
begin
Result:=false;
try
LogOneDay     := aOneDay;
LogSilentDead := aSilent;
LogEachClose  := aEachClose;
tempFolder    := SetTailBackSlash(GetTempFolder);
LogFilePrefix := ChangeFileExt(ExtractFilename(ParamStr(0)),'')+'_';
if (AppParams.CFGUserFileName<>'')
   then begin
   LogFolderName:=SetTailBackSlash(ExtractFilePath(AppParams.CFGUserFileName))+'log\';
   if not DirectoryExists(LogFolderName)
      then if not ForceDirectories(LogFolderName)
              then LogFolderName:=tempFolder
              else LogFilePrefix:=''
      else LogFilePrefix:='';
   end
   else begin
   LogFolderName:=tempFolder;
   end;
LogFileDate:=Date;
if aLogFileName=''
   then LogFileName:=LogFolderName+LogFilePrefix+FormatDateTime(DateFileNameShablon,LogFileDate)+FormatFloat('_0', AppParams.SelfPID)+FormatFloat('(0)',LogFilePart)+'.log';
Result:=true;
except
on E : Exception do LogErrorMessage('InitLogData',E,[]);
end;
end;


function GetStringFromParamsOld(const aParams : array of const; var aResult : string): boolean;
var cnt : integer;
begin
Result:=false;
aResult:='';
try
for cnt:=0 to High(aParams) do aResult:=aResult+GDV(aParams[cnt])+';';
SetLength(aResult,Length(aResult)-1);
Result:=aResult<>'';
except
on E : Exception do LogErrorMessage('',E,[]);
end;
end;


function GetStringFromParamsNew(const aParams : array of const; var aResult : string): boolean;
var
 cnt : integer;
 one : string;
begin
Result:=false;
if Length(aParams)=0 then Exit;
aResult:='Дополнительно:'+crlf;
try
for cnt:=0 to High(aParams)
   do begin
   one:=GDV(aParams[cnt]);
   if OneTwoReplace
      then begin
      if Pos(#13, one)<>0 then one:=StringReplace(one,#13,#2,[rfReplaceAll]);
      if Pos(#10, one)<>0 then one:=StringReplace(one,#10,#1,[rfReplaceAll]);
      aResult:=aResult+Format('#%d: %s%s',[cnt+1,one,crlf]);
      end
      else aResult:=aResult+Format('#%d: %s%s',[cnt+1,one,';']);
   end;
aResult:=StringReplace(Trim(aResult),crlf,DaggerChar,[rfReplaceAll]);
Result:=aResult<>'';
except
on E : Exception do LogErrorMessage('',E,[]);
end;
end;


function DirectRead(var aText : string) : boolean;
var
 hndl: cardinal;
 ln  : cardinal;
 PSA : PSecurityAttributes;
 buf : PAnsiChar;
 wrt : cardinal;
 fnl : TStringDynArray;
 cnt : integer;
begin
Result:=false;
aText:='';
try
ln:=Length(LogFileNameList)+1;
SetLength(fnl,ln);
for cnt:=0 to High(LogFileNameList)do fnl[cnt]:=LogFileNameList[cnt];
fnl[High(fnl)]:=LogFileName;
CreatePSA(PSA);
try
for cnt:=0 to High(fnl)
do begin
if (1=1) //and  TryEnterCriticalSection(LogCriticalSection)
   then begin
   hndl:=CreateFile(PChar(LogFileName),GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, PSA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   try
   if hndl <> INVALID_HANDLE_VALUE
      then begin
      ln:=GetFileSize(hndl,nil);
      buf:=AllocMem(ln+1);
      try
      ReadFile(hndl,buf^,ln,wrt,nil);
      aText:=aText+string(StrPas(buf));
      finally
      FreeMem(buf);
      end;
      end;
   finally
   CloseHandle(hndl);
   //LeaveCriticalSection(LogCriticalSection);
   end;
   end;
end;
finally
FreeMem(PSA);
SetLength(fnl,0);
end;
Result:=true;
except
on E : Exception do LogErrorMessage('',E,[]);
end;
end;


function DirectWrite(const aRecord : string) : boolean;
var
 ln  : cardinal;
 PSA : PSecurityAttributes;
 buf : PAnsiChar;
 wrt : cardinal;
begin
Result:=false;
try
ln:=cardinal(Length(aRecord));
if ln=0 then Exit;
if LogFileHandle=0
   then begin
   CreatePSA(PSA);
   try
   LogFileHandle:=CreateFile(PChar(LogFileName),GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, PSA, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
   finally
   FreeMem(PSA);
   end;
   end;
try
SetFilePointer(LogFileHandle,0,nil,FILE_END); // -- это может быть полезным : LogFileHandle торчит наружу (хоть и на запись только....)
buf:=AllocMem(ln+1);
try
StrPCopy(buf, Ansistring(aRecord));
WriteFile(LogFileHandle,buf^,ln,wrt,nil);
finally
FreeMem(buf);
end;
finally
if LogEachClose
   then CloseLog
   else FlushLog;

if GetSizeOfFile(LogFileName)>maxPartSize
   then begin
   CloseLog;
   inc(LogFilePart);
   LogFileName:=LogFolderName+LogFilePrefix+FormatDateTime(DateFileNameShablon,LogFileDate)+FormatFloat('_0', AppParams.SelfPID)+FormatFloat('(0)',LogFilePart)+'.log';
   end;

end;
Result:=ln=wrt;



except
on E : Exception do LogErrorMessage('',E,[]);
end;
end;


function SaveLongString(const aStr : string; aDT : TDateTime; isParam : boolean; var aFN : string) : boolean;
const
 prmSign : array[boolean] of string = ('_msg','_prm');
var
 fld : string;
begin
Result:=false;
try
aFN:=FormatDateTime('yyyymmdd_hhnnsszzz',aDT)+prmSign[isParam]+'.txt';
if LogFilePrefix<>''
   then fld:=LogFolderName+LogFilePrefix+'_dop\'
   else fld:=LogFolderName+LogFilePrefix+'dop\';
if not DirectoryExists(fld)
   then if not ForceDirectories(fld)
           then fld:=LogFolderName;
aFN:=fld+aFN;
SaveStringIntoFileStream(aStr, aFN, true);
sleep(1);
Result:=true;
except
on E : Exception do LogErrorMessage('SaveLongString',E,[aStr]);
end;
end;


function AddRecordCommon(aType : TLogRecordType; const aValue : string; const aParams : array of const) : integer;
var
 dt  : TDateTime;
 shb : string;
 prm : string;
 msg : string;
 fnf : string;
 dts : string;
 posJCL : integer;
begin
Result:=-1;
dt:=now;
msg:=aValue;
shb:=LogRecordFormat;
if OneTwoReplace
   then begin
   if GetStringFromParamsNew(aParams, prm) or (Pos(DegreeChar,msg)>0)
      then shb:=shb+DaggerChar+'%s';
   end
   else begin
   if GetStringFromParamsOld(aParams, prm)
      then begin
      shb:=shb+DaggerChar+'%s';
      if (Pos(#13, prm)>0) and (SaveLongString(prm,dt,true,fnf))
         then prm:=Format('dop_file "%s"',[fnf]);
      end;
   end;
DateTimeToString(dts, LogLongDateFormat, dt, FormatSettings);
dts:=Format('%s [%s]',[dts, FormatFloat('0000000000',hInstance)]);
posJCL:=Pos(DegreeChar,msg);
{$IFDEF JCL} // -- Jedi mode
//jdt:=dts+DaggerChar+IntToStr(integer(lrtStack))+DaggerChar;
{*for AppLogNew_DateTime*}
if posJCL>0
//then msg:=StringReplace(msg,DegreeChar,jdt,[rfReplaceAll]);
  then begin
  prm:=prm+IfThen(prm<>'',DaggerChar)+Copy(msg,posJCL+1,Length(msg));
  msg:=Trim(Copy(msg,1,posJCL-1));
  posJCL:=Length(msg);
  if (posJCL>0) and (msg[posJCL]=':')
     then msg:=Copy(msg,1,posJCL-1)+' (см. доп.параметры)';
  //msg:=msg+IfThen(prm<>'',DaggerChar+prm);
  end;

msg:=Format(shb,[dts,integer(aType),msg,trim(prm)])+crlf;
{$ELSE} // -- simple, standard mode
if (Length(msg)>maxStrLength) and (SaveLongString(msg,dt,false,fnf))
   then msg:=Copy(msg,1,maxStrLength)+ElipBtnChar+Format(crlf+'см. "%s"',[fnf]);
msg:=Format(shb,[dts,integer(aType),msg,trim(prm)]);
msg:=StringReplaceEx(msg,cr,' ',[rfReplaceAll]);
msg:=StringReplaceEx(msg,lf,'',[rfReplaceAll]);
if posJCL>0
   then msg:=StringReplaceEx(msg,DegreeChar,'',[]);
msg:=msg+crlf;
{$ENDIF}
ValidLogData;
DirectWrite(msg);

{$WARN SYMBOL_PLATFORM OFF}
if (DebugHook<>0) and (MainFormHandle<>0)
   then begin
   case aType of
   lrtError   : ShowMessageError(msg,'Отладка: Ошибка');
   lrtWarning : ShowMessageWarning(msg,'Отладка: Предупреждение');
//   lrtInfo    : ShowMessageInfo(msg,'Отладка: Сообщение');
   lrtUndef   : ShowMessageInfo(msg,'Отладка: ????');
   end;
   end;
{$WARN SYMBOL_PLATFORM ON}
end;

(**************************************************************************************************)



function AboutException(E : Exception) : string;
const
 redstrip = #160#160;
var
  Msg  : string;
  Stack: string;
  Inner: Exception;
begin
Inner := E;
Msg := DegreeChar+redstrip+'About error (Unit.Class: Message) :'+DaggerChar;
while Inner <> nil do
  begin
  Msg := Msg + Format('%s%s.%s: %s',[redstrip,Inner.UnitName,Inner.ClassName,Inner.Message]);
  if (Msg <> '') and (Msg[Length(Msg)] > '.')
     then Msg := Msg + '.';
  Stack := Trim(Inner.StackTrace);
  if Stack <> ''
    then Msg := Msg + IfThen(Msg<>'', DaggerChar) + Stack;
  Inner := Inner.InnerException;
  end;
Result:=Trim(Msg);
end;

function AboutError(const aProcName:string; E: Exception) : string;
var
  ec  : cardinal;
  em  : string;
begin
ec := GetLastError;
em := Format('Код ошибки ОС : %d (%s)',[ec,SysErrorMessage(ec)]);
if Assigned(E)
  then begin
  {$IFDEF JCL}
  Result := aProcName+': '+AboutException(E)+DaggerChar+em;
  {$ELSE}
  Result := aProcName+': '+AboutException(E)+DaggerChar+em;
  //Result := aProcName+': '+DegreeChar+E.Message+'.'+em;
  {$ENDIF}
  if Assigned(terApp)
     then terApp.Add(E);
  end
  else begin
  Result := aProcName+': '+'(Exception is NIL)'+'.'+em;
  end;
end;

procedure LogInfoMessage(const aValue : string);
begin
AddRecordCommon(lrtInfo,aValue,[]);
end;

procedure LogInfoMessage(const aValue : string; const aParams : array of const);
begin
AddRecordCommon(lrtInfo,aValue,aParams);
end;

procedure LogInfoMessage(const aProcName,aInfo : string; const aParams : array of const);
begin
AddRecordCommon(lrtInfo,Format('"%s" : %s',[aProcName,aInfo]),aParams);
end;

procedure LogErrorMessage(const aProcName : string; E : Exception; const aParams : array of const);
var
  res : string;
begin
ErrorCounter:=ErrorCounter+1;
res := AboutError(aProcName, E);
AddRecordCommon(lrtError,res,aParams);
end;

procedure LogErrorMessage(const aValue : string; const aParams : array of const);
begin
ErrorCounter:=ErrorCounter+1;
AddRecordCommon(lrtError,aValue,aParams);
end;

procedure ShowErrorEx(const aProcName : string; E : Exception; const aParams : array of const);
begin
LogErrorMessage(aProcName, E, aParams);
end;


procedure LogWarningMessage(const aValue : string);
begin
WarningCounter:=WarningCounter+1;
AddRecordCommon(lrtWarning,aValue,[]);
end;


procedure LogWarningMessage(const aValue : string; const aParams : array of const);
begin
WarningCounter:=WarningCounter+1;
AddRecordCommon(lrtWarning,aValue,aParams);
end;


procedure LogWarningMessage(const aProcName : string; E : Exception; const aParams : array of const);
var
 res : string;
begin
WarningCounter:=WarningCounter+1;
res:=AboutError(aProcName, E);
AddRecordCommon(lrtWarning,res,aParams);
end;


procedure LogMessage(const aValue : string);
begin
AddRecordCommon(lrtInfo,aValue,[]);
end;

procedure LogMessage(const aValue : string; const aParams : array of const);
begin
AddRecordCommon(lrtInfo,aValue,aParams);
end;

procedure LogMessage(const aProcName,aInfo : string; const aParams : array of const);
begin
AddRecordCommon(lrtInfo,Format('"%s" : %s',[aProcName,aInfo]),aParams);
end;


function GetNormalString(const aStr : string) : string;
const
 shablon = DaggerChar+'%d'+DaggerChar;
var
 cnt : TLogRecordType;
begin
Result:=aStr;
for cnt:=Low(TLogRecordType) to High(TLogRecordType)
  do Result:=StringReplaceEx(Result,Format(shablon,[integer(cnt)]),descr[cnt],[rfReplaceAll]);
end;


procedure ValidLogData;
var
  tmp : string;
  ind : integer;
begin
try
if LogFileName=''
   then InitLogData(LogOneday,LogSilentDead,LogEachClose)
   else begin
   if (Date<>LogFileDate) and LogOneDay
      then begin
      LogFileDate:=Date;
      tmp:=LogFolderName+LogFilePrefix+FormatDateTime(DateFileNameShablon,LogFileDate)+FormatFloat('_0', AppParams.SelfPID)+'.log';
      DirectWrite(Format('Продолжение журнала в следующем файле (%s)....',[tmp]));
      ind:=Length(LogFileNameList);
      Setlength(LogFileNameList, ind+1);
      LogFileNameList[ind]:=LogFileName;
      LogFileName:=tmp;
      end;
   end;
except
on E : Exception do LogErrorMessage('',E,[]);
end;
end;


procedure FlushLog;
begin
try
if LogFileHandle>0
   then FlushFileBuffers(LogFileHandle);
except
on E : Exception do LogErrorMessage('FlushLog',E,[LogFileHandle, LogFileName]);
end;
end;

procedure CloseLog;
begin
try
try
FlushFileBuffers(LogFileHandle);
if LogFileHandle>0
   then CloseHandle(LogFileHandle);
finally
LogFileHandle:=0;
end;
except
on E : Exception do LogErrorMessage('CloseLog',E,[LogFileHandle, LogFileName]);
end;
end;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure ShowLog(const aCFGFileName : string = '');
var
 tmp : string;
begin
try
if not DirectRead(tmp) then Exit;
if Assigned(LVF)
   then FreeAndNil(LVF);
LVF := TLogViewForm.CreateNew(Application);
LVF.ChLB:=TCheckListBox.Create(LVF);
LVF.EdFnd:=TEdit.Create(LVF);
LVF.LabFnd:=TLabel.Create(LVF);
LVF.LabFileName:=TLabel.Create(LVF);
LVF.DrGr:=TDrawGrid.Create(LVF);
LVF.IL:=TImageList.Create(LVF);

if aCFGFileName=''
   then LVF.CFGName:=AppParams.CFGUserFileName//ParamStr(0)
   else LVF.CFGName:=aCFGFileName;
try
with LVF do
 begin
 Filter := [lrtInfo,lrtWarning,lrtError,lrtUndef];
 BorderIcons:=[biSystemMenu];
 //Position:=poMainFormCenter;
 KeyPreview:=true;
 Caption:='Журнал выполнения (без автообновления!)';
 onClose:=LVF_Close;
 onKeyDown:=LVF_KeyDown;
 OnResize:=LVF_Resize;
 OnDblClick:=LVF_DblClick;
 OnShow:=LVF_Show;
 SortCol := 0;
 SortDir := false;
 LoadInteger('Settings','LogSortCol',SortCol,LVF.CFGName);
 LoadBool('Settings','LogSortDir',SortDir,LVF.CFGName);
 ErrorOnSort:=false;
 end;
FillImageListFromResource(LVF.IL,'LogList3');
with LVF.ChLB do
 begin
 Parent:=LVF;
 Top:=0;
 Left:=0;
 Checked[Items.Add('Информация')]:=true;
 Checked[Items.Add('Предупреждения')]:=true;
 Checked[Items.Add('Ошибки')]:=true;
 Checked[Items.Add('Неизвестные')]:=true;
 //Checked[Items.Add('Stack info')]:=true; // показывается вместе с ошибками
 Width:=LVF.Canvas.TextWidth(Items[1])+4+ItemHeight+8;
 Height:=ItemHeight*4+4;
 OnClickCheck:=LVF.LVF_FilterClick;
 OnClickCheck(LVF);
 end;

with LVF.LabFileName do
 begin
 Parent:=LVF;
 Top:=LVF.ChLB.Top+4;
 Left:=LVF.ChLB.Left+LVF.ChLB.Width+4;
 AutoSize:=false;
 Width:=Parent.ClientWidth - 4 - Left;
 Anchors:=[akLeft, akTop, akRight];
 Caption:='Файл журнала: '+logFileName;
 Hint:=logFileName;
 Cursor:=crHandPoint;
 onClick:=LVF.LVF_LabFileName_Click;
 end;

with LVF.EdFnd do
 begin
 Parent:=LVF;
 Top:=LVF.ChLB.Top+LVF.ChLB.Height - Height;
 Left:=LVF.ChLB.Left+LVF.ChLB.Width+4;
 Width:=150;
 OnChange:=LVF.LVF_EdFnd_Change;
 TextHint:='Поисковая фраза';
 end;

with LVF.LabFnd do
 begin
 Parent:=LVF;
 Top:=LVF.EdFnd.Top-Height-2;
 Left:=LVF.EdFnd.Left;
 Caption:='Поиск. Найдено: 0';
 Cursor:=crHandPoint;
 onClick:=LVF.LVF_LabFnd_Click;
 end;

with LVF.DrGr do
 begin
 Parent:=LVF;
 ColCount:=3;
 RowCount:=2;
 FixedCols:=0;
 FixedRows:=1;
 DefaultRowHeight:=20;
 Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goRowSelect,goFixedRowClick];
 Left:=2;
 Top:=LVF.ChLB.Top+LVF.ChLB.Height+2;
 Width:=Parent.ClientWidth - Left*2;
 Height:=Parent.ClientHeight - Top - 2;
 Anchors:=[akLeft,akTop,akRight,akBottom];
 OnDrawCell:=LVF.LVF_DrGrDrawCell;
 onDblClick:=LVF.LVF_DrGrDoubleClick;
 OnFixedCellClick:=LVF.LVF_DrGrFixedCellClick;
 end;
LVF.FillFromLogList(tmp);
SetDoubleBuffered(LVF);
RestorePosition(LVF,LVF.CFGName);
RestoreColumnsEx(LVF,LVF.DrGr,LVF.CFGName);
LVF.Show;
finally
end;
except
on E : Exception do LogErrorMessage('ShowLog',E,[aCFGFileName]);
end;
end;


// --- TLogViewForm ---


initialization MainInitProc;
finalization MainFinalProc;

end.

