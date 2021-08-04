unit FnADODB;

interface

uses
    SysUtils
  , Classes
  , INIFiles
  , FnCommon, AppLogNew
  , variants
  , ADODB
  , DB
  , ActiveX, ComObj
  , types
  , StrUtils
  , Graphics

  ;


type
  PSPParamValueItem = ^TSPParamValueItem ;
  TSPParamValueItem = packed record
    ParamName  : string[128];
    ParamValue : variant;
  end;
  PSPParamValueList = ^TSPParamValueList;
  TSPParamValueList = array of TSPParamValueItem ;

  PADOSPParam = ^TADOSPParam;
  TADOSPParam = TSPParamValueItem;

  PADOSPParameters =^TADOSPParameters;
  TADOSPParameters = TSPParamValueList;

  TDoubleVariantArray = array of array of variant;

const
  DBCurrentSection = 'DBSection';
  ErrADOSPNoParam = 'Не удалось получить параметры хранимой процедуры "%s".';
  DBAutModeNote : array[boolean] of string = ('MSSQL server autorization', 'Windows autorization');

var
  DBiniSection  : string = 'Settings';
  DBWinAutMode  : boolean   = false;
  DBWinAutStr   : string    = 'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=@DBNAME@;Data Source=@DBSERVER@;Application Name=@APPLICATION@';
  DBSrvAutStr   : string    = 'Provider=SQLOLEDB.1;Initial Catalog=@DBNAME@;Data Source=@DBSERVER@;'+'Password=@DBPASSWORD@;Persist Security Info=True;User ID=@DBUSER@;Application Name=@APPLICATION@';
  DBConnString  : string    = '';



  DBServerTEST : string     = 'KUPIVIP00000\KHS_SQLSERVER';
  DBNameTEST   : string     = 'TEST';
  DBUserTEST   : string     = 'UserMain';
  DBPswTEST    : string     =
  Char(Ord('A'))+
  Char(Ord('l'))+
  Char(Ord('p'))+
  Char(Ord('h'))+
  Char(Ord('a'))+
  Char(Ord('1'))+
  Char(Ord('2'))+
  Char(Ord('3'));

  DBServerMO2  : string    = 'sqlsrv02.kupivip.local';
  DBNameMO2    : string    = 'MO';
  DBUserMO2    : string    = 'mo2';
  DBPswMO2     : string    =    //Ouy9gRplyFul0b9x
//  Char(Ord('p'))+
//  Char(Ord('r'))+
//  Char(Ord('u'))+
//  Char(Ord('@'))+
//  Char(Ord('u'))+
//  Char(Ord('w'))+
//  Char(Ord('R'))+
//  Char(Ord('5'))+
//  Char(Ord('D'))+
//  Char(Ord('r'))+
//  Char(Ord('E'));

  Char(Ord('O'))+
  Char(Ord('u'))+
  Char(Ord('y'))+
  Char(Ord('9'))+
  Char(Ord('g'))+
  Char(Ord('R'))+
  Char(Ord('p'))+
  Char(Ord('l'))+
  Char(Ord('y'))+
  Char(Ord('F'))+
  Char(Ord('u'))+
  Char(Ord('l'))+
  Char(Ord('0'))+
  Char(Ord('b'))+
  Char(Ord('9'))+
  Char(Ord('x'));

  //Ouy9gRplyFul0b9x

  DBServer      : string    = 'Server unknown!!!';
  DBName        : string    = 'DataBase unknown!!!';
  DBUser        : string    = '';
  DBPsw         : string    = '';


  conTimeOut    : cardinal  = 90;
  cmdTimeOut    : cardinal  = 90;

  function GetExceptionADOSPAbsent(const aSPName : string) : Exception;

  procedure dbLoadSettings(const aSection : string);
  procedure dbFillSettings(aDBWinAutMode : boolean; const aDBServer, aDBName : string); overload;
  procedure dbFillSettings(aDBWinAutMode : boolean; const aDBServer, aDBName, aDBUser, aDBPassword : string); overload;
  function dbPrepareConnString : boolean; overload;
  procedure dbPrepareConnString(const aDBUser, aDBPassword : string); overload;
  function dbTryConnect : boolean;
(* Создание / Освобождение хранимой процедуры ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
  function dbGetADOSP(const aSPName : string) : TADOStoredProc; overload;
  function dbGetADOSP(const aSPName : string; var aErrorMsg : string) : TADOStoredProc; overload;
  function dbClearADOSP(var aADOSP : TADOStoredProc; aClearParams : boolean = true) : boolean;
(* Создание / Освобождение датасета ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
  function dbGetADODS(const CmdText : string) : TADODataSet;
  function dbClearADODS(var aADODS : TADODataSet) : boolean;

(* Заполнение параметров для функции ExecuteStoredProc ~~~~~~~~~~~~~~~~~~~~~~ *)
  procedure dbFillSPParamValueItem(var aPVI : TSPParamValueItem; const aParamname : string; const aParamvalue : variant); overload;
  procedure dbFillSPParamValueItem(var aPVI : TSPParamValueItem; const aParamname : string; const aParamvalue : TStream); overload;
(* Выполнение хранимой процедуры ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
  function dbExecSP(const aSPName : string;var aSPParamValueList : TSPParamValueList; aClearParamList : boolean = True) : integer; overload;
  function dbExecSP(const aSPName : string;var aSPParamValueList : TSPParamValueList;  var aErrorMsg : string ; aClearParamList : boolean = True) : integer; overload;

  function dbFieldToStream(aField : TField; aMemoryStream : TMemoryStream): integer; overload;
  function dbFieldToStream(aField : TField; aStringStream : TStream): integer; overload;

  function excSelectFromFile(const aFN : string) : boolean;  overload;
  function excSelectFromFile(const aFN : string; var DVA : TDoubleVariantArray) : boolean;  overload;

  function getConnStrForErrorMessage(const aConnStr  :string = '') : string;

  function dbDataSetToHTML(DataSet : TDataSet; var html : string; const title : string): boolean;

implementation

function GetExceptionADOSPAbsent(const aSPName : string) : Exception;
var
 tmp : string;
begin
tmp:=Format('На сервере "%s" в БД "%s" отсутствует процедура "%s".',[DBServer,DBName,aSPName]);
try
Result:=Exception.Create(tmp);
finally
tmp:='';
end;
end;

function GetExceptionADODataset(const CmdText : string) : Exception;
var
 tmp : string;
begin
tmp:=Format('Ошибка подготовки DataSet на сервере "%s" в БД "%s". Текст запроса  %s.',[DBServer,DBName,AnsiQuotedStr(CmdText,'"')]);
try
Result:=Exception.Create(tmp);
finally
tmp:='';
end;
end;
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

procedure dbLoadSettings(const aSection : string);
var
 INI : TINIFile;
begin
try
INI:=TINIFile.Create(AppParams.CFGCommonFileName);
try
DBWinAutMode  := INI.ReadBool(aSection,'DBWinAutMode',DBWinAutMode);
DBServer      := INI.ReadString(aSection,'DBServer',DBServer);
DBName        := INI.ReadString(aSection,'DBName',DBName);
finally
FreeAndNil(INI);
end;
dbPrepareConnString;
except
  on E : Exception do LogErrorMessage('dbLoadSettings',E,[]);
end;
end;

procedure dbFillSettings(aDBWinAutMode : boolean; const aDBServer, aDBName : string);
begin
try
DBWinAutMode  := aDBWinAutMode;
DBServer      := aDBServer;
DBName        := aDBName;
dbPrepareConnString;
except
  on E : Exception do LogErrorMessage('dbLoadSettings',E,[]);
end;
end;


procedure dbFillSettings(aDBWinAutMode : boolean; const aDBServer, aDBName, aDBUser, aDBPassword : string); overload;
begin
try
DBWinAutMode  := aDBWinAutMode;
DBServer      := aDBServer;
DBName        := aDBName;
dbPrepareConnString(aDBUser, aDBPassword);
except
  on E : Exception do LogErrorMessage('dbFillSettings(with User)',E,[]);
end;

end;

function IsMo2Application : boolean;
const MO2App : array[0..7] of string =
 ('ROUTER'
 ,'AREAEDITOR'
 ,'SMSSENDER'
 ,'EMSYSTRG'
 ,'INTRAROBOT'
 ,'ONLYZERO'
 ,'SMSSWITCH'
 ,'OLPROC');
var
 tst : string;
 cnt  :integer;
begin
tst:=AnsiUpperCase(ChangeFileExt(ExtractFileName(ParamStr(0)),''));
Result:=True;
for cnt:=0 to High(MO2App)
  do if tst=MO2App[cnt]
        then Exit;
Result:=False;
end;

function dbPrepareConnString : boolean;
begin
Result:=false;
try
if DBWinAutMode // -- Windows авторизация
   then DBConnString:=DBWinAutStr
   else DBConnString:=DBSrvAutStr;
DBConnString:=StringReplace(DBConnString,'@DBNAME@'     ,DBName  ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@DBSERVER@'   ,DBServer,[rfIgnoreCase]);
if IsMo2Application or (LowerCase(DBUser)='mo2')
   then begin
   DBPsw:=DBPswMO2;
   DBuser:=DBUserMO2;
   end ;
DBConnString:=StringReplace(DBConnString,'@DBPASSWORD@' ,DBPsw   ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@DBUSER@'     ,DBUser  ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@APPLICATION@',AnsiUpperCase(AppParams.AppPrefix),[rfIgnoreCase]);
LogInfoMessage(Format('Установлены параметры подключения. БД "%s" на сервере "%s". %s.',[DBName,DBServer,DBAutModeNote[DBWinAutMode]])) ;
Result:=dbTryConnect;
if Result
   then LogInfoMessage(Format('Служебные подключения к БД "%s" на сервере "%s". %s.',[DBName,DBServer,DBAutModeNote[DBWinAutMode]]))
   else LogWarningMessage(Format('Служебные подключения к БД "%s" на сервере "%s". %s.',[DBName,DBServer,DBAutModeNote[DBWinAutMode]]))
except
  on E : Exception do LogErrorMessage('dbPrepareConnString',E,[]);
end;
end;

procedure dbPrepareConnString(const aDBUser, aDBPassword : string);
const
 DBAutModeNote : array[boolean] of string = ('MSSQL server autorization', 'Windows autorization');
begin
try
if DBWinAutMode // -- Windows авторизация
   then DBConnString:=DBWinAutStr
   else DBConnString:=DBSrvAutStr;
DBConnString:=StringReplace(DBConnString,'@DBNAME@'     ,DBName  ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@DBSERVER@'   ,DBServer,[rfIgnoreCase]);
DBPsw:=aDBPassword;
DBuser:=aDBUser;
DBConnString:=StringReplace(DBConnString,'@DBPASSWORD@' ,DBPsw   ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@DBUSER@'     ,DBUser  ,[rfIgnoreCase]);
DBConnString:=StringReplace(DBConnString,'@APPLICATION@',AnsiUpperCase(AppParams.AppPrefix),[rfIgnoreCase]);
LogInfoMessage(Format('Установлены параметры подключения. БД "%s" на сервере "%s". %s.',[DBName,DBServer,DBAutModeNote[DBWinAutMode]])) ;
except
  on E : Exception do LogErrorMessage('dbPrepareConnString(with User)',E,[]);
end;
end;

function dbTryConnect : boolean;
var
 ADOC : TADOConnection;
begin
Result:=false;
try
ADOC:=TADOConnection.Create(nil);
try
ADOC.ConnectionTimeout:=2;
ADOC.ConnectionString:=DBConnString;
ADOC.LoginPrompt:=False;
ADOC.Connected:=true;
Result:=ADOC.Connected;
finally
if ADOC.Connected then ADOC.Connected:=false;
ADOC.Free;
end;
except
  on E : Exception do LogErrorMessage('dbTryConnect',E,[getConnStrForErrorMessage]);
end;
end;

(* Создание / Освобождение хранимой процедуры ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
function dbGetADOSP(const aSPName : string) : TADOStoredProc;
var
 Exc : Exception;
begin
Result:=nil;
try
Result:=TADOStoredProc.Create(nil);
with Result do
 begin
 CommandTimeout:=cmdTimeOut;
 ConnectionString:=DBConnString;
 ProcedureName:=aSPName;
 Prepared:=True;
 if not Parameters.Refresh
    then begin
    Exc:=GetExceptionADOSPAbsent(aSPName);
    try
    LogErrorMessage('dbGetADOSP',Exc,[aSPName]);
    finally
    Exc.Free;
    end;
    if Assigned(Result) then FreeAndNil(Result);
    Exit;
    end;
 end;
except
  on E : Exception
     do begin
     if Assigned(Result) then FreeAndNil(Result);
     LogErrorMessage('dbGetADOSP',E,[aSPName,IfThen(DBPsw<>'',StringReplace(DBConnString,DBPsw,'******',[]),DBConnString)]);
     end;
end;
end;

(* Создание / Освобождение хранимой процедуры ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
function dbGetADOSP(const aSPName : string; var aErrorMsg : string) : TADOStoredProc;
var
 Exc : Exception;
begin
Result:=nil;
try
Result:=TADOStoredProc.Create(nil);
with Result do
 begin
 CommandTimeout:=cmdTimeOut;
 ConnectionString:=DBConnString;
 ProcedureName:=aSPName;
 Prepared:=True;
 if not Parameters.Refresh
    then begin
    Exc:=GetExceptionADOSPAbsent(aSPName);
    try
    aErrorMsg:=Format('%s(%s) : %s',['dbGetADOSP',aSPName,Exc.Message]);
    finally
    Exc.Free;
    end;
    if Assigned(Result) then FreeAndNil(Result);
    Exit;
    end;
 end;
except
  on E : Exception
     do begin
     if Assigned(Result) then FreeAndNil(Result);
     CreateErrorMessage('dbGetADOSP',E,[aSPName, getConnStrForErrorMessage],aErrorMsg);
     end;
end;
end;



function dbClearADOSP(var aADOSP : TADOStoredProc; aClearParams : boolean = true) : boolean;
var
 ProcName : string;
begin
Result:=false;
ProcName:='???';
try
if Assigned(aADOSP)
   then begin
   ProcName:=aADOSP.ProcedureName;
   if aADOSP.Active then aADOSP.Close;
   aADOSP.Parameters.Clear;
   aADOSP.ConnectionString:='';
   aADOSP.ProcedureName:='';
   aADOSP.Free;
   aADOSP:=nil;
   end;
Result:=not Assigned(aADOSP);
except
  on E : Exception do LogErrorMessage('dbClearADOSP',E,[ProcName]);
end;
end;


function dbGetADODS(const CmdText : string) : TADODataSet;
//var
// Exc : Exception;
begin
Result:=nil;
try
Result:=TADODataset.Create(nil);
with Result do
 begin
 CommandTimeout:=cmdTimeOut;
 ConnectionString:=DBConnString;
 CommandText:=CmdText;
 ParamCheck:=false;
 Prepared:=True;
// if not Parameters.Refresh
//    then begin
//    Exc:=GetExceptionADODataset(CmdText);
//    try
//    LogErrorMessage('dbGetADODS',Exc,[]);
//    finally
//    Exc.Free;
//    end;
//    if Assigned(Result) then FreeAndNil(Result);
//    Exit;
//    end;
 end;
except
  on E : Exception
     do begin
     if Assigned(Result) then FreeAndNil(Result);
     LogErrorMessage('dbGetADODS',E,[IfThen(DBPsw<>'',StringReplace(DBConnString,DBPsw,'******',[]),DBConnString)]);
     end;
end;
end;


function dbClearADODS(var aADODS : TADODataSet) : boolean;
begin
Result:=false;
try
if Assigned(aADODS)
   then begin
   if aADODS.Active then aADODS.Close;
   aADODS.Parameters.Clear;
   aADODS.ConnectionString:='';
   aADODS.CommandText:='';
   aADODS.Free;
   aADODS:=nil;
   end;
Result:=not Assigned(aADODS);
except
  on E : Exception do LogErrorMessage('dbClearADODS',E,[]);
end;
end;


(* Заполнение параметров для функции ExecuteStoredProc                        *)
procedure dbFillSPParamValueItem(var aPVI : TSPParamValueItem; const aParamName : string; const aParamvalue : variant);
begin
try
with aPVI do
 begin
 ParamName:=shortstring(aParamName);
 ParamValue:=aParamValue;
 end;
except
  on E : Exception do LogErrorMessage('dbFillSPParamValueItem(Value)',E,[aParamName,GDV(aParamValue)]);
end;
end;

(* Заполнение параметров для функции ExecuteStoredProc ~~~~~~~~~~~~~~~~~~~~~~ *)
procedure dbFillSPParamValueItem(var aPVI : TSPParamValueItem; const aParamname : string; const aParamvalue : TStream);
var
  BinData : OleVariant;
  DataPtr : Pointer;
  Len     : Integer;
begin
try
aPVI.ParamName:=shortstring(aParamName);
aPVI.ParamValue := null;
if not Assigned(aParamvalue) then Exit;
aParamvalue.Position := 0;
Len := aParamvalue.Size;
BinData := VarArrayCreate([0, Len-1], varByte);
DataPtr := VarArrayLock(BinData);
try
aParamvalue.ReadBuffer(DataPtr^, Len);
aPVI.ParamValue := BinData;
finally
VarArrayUnlock(BinData);
end;
except
  on E : Exception do LogErrorMessage('dbFillSPParamValueItem(Stream)',E,[aParamName]);
end;
end;


(* Выполнение хранимой процедуры ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
function dbExecSP(const aSPName : string;var aSPParamValueList : TSPParamValueList; aClearParamList : boolean = True) : integer;
  procedure SetOutputParamValue(const aParamname : string; aValue : variant);
  var
   cnt: integer;
  begin
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          aSPParamValueList[cnt].ParamValue:=aValue;
          Break;
          end;
  end;

  function GetParamValueByName(const aParamName : string): variant;
  var
   cnt: integer;
  begin
  Result:='';
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          Result:=aSPParamValueList[cnt].ParamValue;
          Break;
          end;
  end;
var
 SP  : TADOStoredProc;
 cnt : integer;
 prm : string;
 val : variant;
 EmergencyFolder : string;
 FileName        : string;
 FileBody        : string;
 szOfPrm         : int64;
 logtmpstr       : string;
begin
szOfPrm:=-1;
Result:=0;
CoInitialize(nil);
try
SP:=dbGetADOSP(aSPName);
try
prm:='';
if not Assigned(SP)
   then begin
   Result:=-1;
   Exit;
   end;
with SP do
 begin
 CommandTimeout:=cmdTimeOut;
 for cnt:=0 to High(aSPParamValueList)
   do begin
   prm:=string(aSPParamValueList[cnt].ParamName);
   Parameters.ParamByName(prm).Value:=aSPParamValueList[cnt].ParamValue;
   end;
 prm:='';
 logtmpstr:=Format('%d',[Parameters.Count]);
 for cnt:=1 to High(aSPParamValueList)
   do  szOfPrm:=szOfPrm+SizeOf(VarToStr(aSPParamValueList[cnt].ParamValue));
 logtmpstr:=logtmpstr+Format(' : %d bytes',[szOfPrm]);
 ExecProc;
 Result:=Parameters[0].Value;
 for cnt:=0 to Parameters.Count-1
   do begin
   if Parameters[cnt].Direction in [pdOutput, pdInputOutput]
      then begin
      prm:=WideCharToString(PWideChar(Parameters[cnt].Name));
      val:=Parameters[cnt].Value;
      SetOutputParamValue(prm, val);
      end;
   end
 end;
finally
dbClearADOSP(SP);
if aClearParamList
   then begin
   for cnt:=0 to High(aSPParamValueList)
       do aSPParamValueList[cnt].ParamValue:=null;
   SetLength(aSPParamValueList,0);
   end;
CoUninitialize;
end;
except
on E : Exception
  do begin
  if (E.Message<>'') and (E.Message[1]=#160)
     then ShowMessageWarning(E.Message,'Внимание!')
     else
  if prm<>''
     then LogErrorMessage('dbExecSP(FillParam)',E,[aSPName,cmdTimeOut,prm,GDV(GetParamValueByName(prm))])
     else if AnsiPos('анализ XML',E.Message)<>0
             then begin
             EmergencyFolder:=SetTailBackSlash(GetTempFolder)+'mo2DBError\';
             if ForceDirectories(SetTailBackSlash(EmergencyFolder))
                then if ForceDirectories(SetTailBackSlash(EmergencyFolder)+'xml\')
                        then
                        try
                        FileName:=SetTailBackSlash(EmergencyFolder)+'xml\';
                        prm:='';
                        FileBody:='';
                        for cnt:=0 to High(aSPParamValueList)
                           do begin
                           prm:=prm+'_'+string(aSPParamValueList[cnt].ParamValue);
                           FileBody:=FileBody+string(aSPParamValueList[cnt].ParamName)+':'+crlf+string(aSPParamValueList[cnt].ParamValue);
                           end;
                        prm:=Copy(prm,1,250-Length(FileName));
                        prm:=NormalizeStringSysPath(prm);
                        FileName:=FileName+prm+'.txt';
                        if not FileExists(FileName)
                           then SaveStringIntoFile(FileBody,FileName);
                        except
                        on E : Exception do LogErrorMessage('dbExecSP(SaveFile)',E,[FileName]);
                        end;
             end
             else LogErrorMessage('dbExecSP',E,[aSPName,cmdTimeOut,logtmpstr]); // -- все равно prm пустая....
  end;
end;
end;

function dbExecSP(const aSPName : string;var aSPParamValueList : TSPParamValueList; var aErrorMsg : string ;aClearParamList : boolean = True) : integer;
  procedure SetOutputParamValue(const aParamname : string; aValue : variant);
  var
   cnt: integer;
  begin
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          aSPParamValueList[cnt].ParamValue:=aValue;
          Break;
          end;
  end;

  function GetParamValueByName(const aParamName : string): variant;
  var
   cnt: integer;
  begin
  Result:='';
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          Result:=aSPParamValueList[cnt].ParamValue;
          Break;
          end;
  end;
var
 SP  : TADOStoredProc;
 cnt : integer;
 prm : string;
 val : variant;
begin
aErrorMsg:='';
Result:=0;
CoInitialize(nil);
try
SP:=dbGetADOSP(aSPName,aErrorMsg);
if aErrorMsg<>'' then Exit;
try
prm:='';
if not Assigned(SP)
   then begin
   Result:=-1;
   Exit;
   end;
with SP do
 begin
 CommandTimeout:=cmdTimeOut;
 for cnt:=0 to High(aSPParamValueList)
   do begin
   prm:=string(aSPParamValueList[cnt].ParamName);
   Parameters.ParamByName(prm).Value:=aSPParamValueList[cnt].ParamValue;
   //Parameters.ParamByName(prm).Direction:=pdInputOutput;
   end;
 prm:='';
 try
 ExecProc;
 except
 on E : Exception
   do aErrorMsg:=aErrorMsg+crlf+E.Message;
 end;
 try
 Result:=Parameters[0].Value;
 except
  on E : Exception do ;
 end;
 for cnt:=0 to Parameters.Count-1
   do begin
   if Parameters[cnt].Direction in [pdOutput, pdInputOutput]
      then begin
      prm:=WideCharToString(PWideChar(Parameters[cnt].Name));
      val:=Parameters[cnt].Value;
      SetOutputParamValue(prm, val);
      end;
   end
 end;
finally
dbClearADOSP(SP);
if aClearParamList
   then begin
   for cnt:=0 to High(aSPParamValueList)
       do aSPParamValueList[cnt].ParamValue:=null;
   SetLength(aSPParamValueList,0);
   end;
CoUninitialize;
end;
except
on E : Exception
  do aErrorMsg:=aErrorMsg+crlf+E.Message;
end;
end;


function dbFieldToStream(aField : TField; aMemoryStream : TMemoryStream): integer;
begin
Result:=0;
try
aMemoryStream.Clear;
Result:=Length(aField.AsBytes);
aMemoryStream.WriteBuffer(aField.AsBytes[0], Result);
aMemoryStream.Position:=0;
if integer(aMemoryStream.Size) <> Result
   then Result:=-1;
except
end;
end;


function dbFieldToStream(aField : TField; aStringStream : TStream): integer;
begin
Result:=0;
try
aStringStream.Position:=0;
Result:=Length(aField.AsBytes);
aStringStream.WriteBuffer(aField.AsBytes[0], Result);
aStringStream.Position:=0;
if integer(aStringStream.Size) <> Result
   then Result:=-1;
except
end;
end;


function dbSelectFromSP(const aSPName : string;var aSPParamValueList : TSPParamValueList; aClearParamList : boolean = True) : integer;
  procedure SetOutputParamValue(const aParamname : string; aValue : variant);
  var
   cnt: integer;
  begin
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          aSPParamValueList[cnt].ParamValue:=aValue;
          Break;
          end;
  end;

  function GetParamValueByName(const aParamName : string): variant;
  var
   cnt: integer;
  begin
  Result:='';
  for cnt:=0 to High(aSPParamValueList)
    do if aSPParamValueList[cnt].ParamName = shortstring(aParamName)
          then begin
          Result:=aSPParamValueList[cnt].ParamValue;
          Break;
          end;
  end;
var
 SP  : TADOStoredProc;
 cnt : integer;
 prm : string;
 val : variant;
begin
Result:=0;
CoInitialize(nil);
try
SP:=dbGetADOSP(aSPName);
try
prm:='';
if not Assigned(SP)
   then begin
   Result:=-1;
   Exit;
   end;
with SP do
 begin
 for cnt:=0 to High(aSPParamValueList)
   do begin
   prm:=string(aSPParamValueList[cnt].ParamName);
   Parameters.ParamByName(prm).Value:=aSPParamValueList[cnt].ParamValue;
   end;
 prm:='';
 ExecProc;
 Result:=Parameters[0].Value;
 for cnt:=0 to Parameters.Count-1
   do begin
   if Parameters[cnt].Direction in [pdOutput, pdInputOutput]
      then begin
      prm:=WideCharToString(PWideChar(Parameters[cnt].Name));
      val:=Parameters[cnt].Value;
      SetOutputParamValue(prm, val);
      end;
   end
 end;
finally
dbClearADOSP(SP);
if aClearParamList
   then begin
   for cnt:=0 to High(aSPParamValueList)
       do aSPParamValueList[cnt].ParamValue:=null;
   SetLength(aSPParamValueList,0);
   end;
CoUninitialize;
end;
except
on E : Exception
  do begin
  if (E.Message<>'') and (E.Message[1]=#160)
     then ShowMessageWarning(E.Message,'Внимание!')
     else
  if prm<>''
     then LogErrorMessage('dbExecSP(FillParam)',E,[aSPName,prm,GDV(GetParamValueByName(prm))])
     else LogErrorMessage('dbExecSP',E,[prm]);
  end;
end;
end;


function excSelectFromFile(const aFN : string) : boolean;
const
 constr : string =
   'Provider=Microsoft.Jet.OLEDB.4.0;'
 //  'Provider=Microsoft.ACE.OLEDB.12.0;'
 + 'Data Source=%s;'
 + 'Extended Properties="Excel 8.0;HDR=No";'              //
 + 'Mode=Read;'
 + 'Persist Security Info=False';

var
 _exc     : variant;
 _wb      : variant;
 _excStop : boolean;
 maxR     : integer;
 cnt      : integer;
 sheets   : TStringList;
 SQLConn  : string;
 SQLStr   : string;
 ADOQ     : TADOQuery;
 tmp      : string;
begin
Result:=false;
SQLstr:='';
SQLConn:='';
_excstop:=false;
try
if not FileExists(aFN) then Exit;
sheets:=TStringList.Create;
try
_exc:=CreateOleObject('Excel.Application');
try
_excStop := (_exc.Application.WorkBooks.Count>0);
_wb:=_exc.Application.WorkBooks.Open[aFN, 0, True];
for cnt:=1 to 1 //_wb.WorkSheets.Count
  do sheets.Add(_wb.WorkSheets[cnt].Name);
maxR:=_wb.WorkSheets[1].UsedRange.Rows.Count;
SQLConn:=_exc.Application.Version;
finally
_wb.Close;
_wb:=Unassigned;
if _excstop then _exc.Quit;
_exc:=Unassigned;
end;


for cnt:=0 to 0//sheets.Count-1
  do SQLStr:=SQLStr+Format('select TOP %d * from [%s$]',[maxR, sheets[cnt]])+crlf;
SQLConn:=Format(constr,[aFN]);
ADOQ:=TADOQuery.Create(nil);
try
ADOQ.ConnectionString:=SQLconn;
ADOQ.SQL.Text:=SQLstr;
ADOQ.Active:=True;
sheets.Clear;
while not ADOQ.Eof do
begin
tmp:='';
 for cnt:=0 to ADOQ.FieldCount-1
    do tmp:=tmp+Format('%s;',[ADOQ.Fields[cnt].DisplayText]);
sheets.Add(Copy(tmp,1,Length(tmp)-1));
ADOQ.Next;
end;

tmp:=aFN+'.txt';
SaveStringIntoFile(sheets.text,tmp);
///FileOpenNT(tmp);
finally
ADOQ.Active:=False;
FreeAndNil(ADOQ);
end;

finally
FreeStringList(sheets);
end;
Result:=True;
except
on E : Exception
   do begin
   CreateErrorMessage('excSelectFromFile',E,[SQLConn, SQLStr],tmp);
   ShowMessageError(tmp);
   end;
end;
//
end;

function excSelectFromFile(const aFN : string; var DVA : TDoubleVariantArray) : boolean;
const
 constr : string =
   'Provider=Microsoft.Jet.OLEDB.4.0;'
 //  'Provider=Microsoft.ACE.OLEDB.12.0;'
 + 'Data Source=%s;'
 + 'Extended Properties="Excel 8.0;HDR=No";'              //
 + 'Mode=Read;'
 + 'Persist Security Info=False';

var
 _exc     : variant;
 _wb      : variant;
 _excStop : boolean;
 maxR     : integer;
 cnt      : integer;
 sheets   : TStringList;
 SQLConn  : string;
 SQLStr   : string;
 ADOQ     : TADOQuery;
 tmp      : string;
begin
Result:=false;
SQLstr:='';
SQLConn:='';
_excstop:=false;
try
if not FileExists(aFN) then Exit;
sheets:=TStringList.Create;
try
_exc:=CreateOleObject('Excel.Application');
try
_excStop := (_exc.Application.WorkBooks.Count>0);
_wb:=_exc.Application.WorkBooks.Open[aFN, 0, True];
for cnt:=1 to 1 //_wb.WorkSheets.Count
  do sheets.Add(_wb.WorkSheets[cnt].Name);
maxR:=_wb.WorkSheets[1].UsedRange.Rows.Count;
SQLConn:=_exc.Application.Version;
finally
_wb.Close;
_wb:=Unassigned;
if _excstop then _exc.Quit;
_exc:=Unassigned;
end;


for cnt:=0 to 0//sheets.Count-1
  do SQLStr:=SQLStr+Format('select TOP %d * from [%s$]',[maxR, sheets[cnt]])+crlf;
SQLConn:=Format(constr,[aFN]);
ADOQ:=TADOQuery.Create(nil);
try
ADOQ.ConnectionString:=SQLconn;
ADOQ.SQL.Text:=SQLstr;
ADOQ.Active:=True;
SetLength(DVA,ADOQ.RecordCount);
maxR:=0;
while not ADOQ.Eof do
begin
SetLength(DVA[maxR],ADOQ.FieldCount);
for cnt:=0 to ADOQ.FieldCount-1
  do begin
  case ADOQ.Fields[cnt].DataType of
  ftDate,ftDateTime,ftTime :
     DVA[maxR, cnt]:= ADOQ.Fields[cnt].asDateTime;
  ftSmallint, ftInteger, ftWord, ftAutoInc,ftLargeint,ftLongWord, ftShortint, ftByte :
     DVA[maxR, cnt]:= ADOQ.Fields[cnt].asInteger;
  ftFloat, ftCurrency,  ftExtended, ftSingle :
     DVA[maxR, cnt]:= ADOQ.Fields[cnt].AsExtended;
  else DVA[maxR, cnt]:= ADOQ.Fields[cnt].Value;
  end;

  end;
ADOQ.Next;
inc(maxR);
end;

finally
ADOQ.Active:=False;
FreeAndNil(ADOQ);
end;

finally
FreeStringList(sheets);
end;
Result:=(Length(DVA)>0) and (Length(DVA[0])>0);
except
on E : Exception
   do begin
   CreateErrorMessage('excSelectFromFile',E,[SQLConn, SQLStr],tmp);
   ShowMessageError(tmp);
   end;
end;
//               ,
end;


function getConnStrForErrorMessage(const aConnStr  :string = '') : string;
var
 spl : TStringDynArray;
begin
if aConnStr<>''
   then Result:=aConnStr
   else Result:=DBConnString;
if Pos('PASSWORD=',AnsiUpperCase(Result))<>0
   then begin
   spl:=SplitStringCIstrl(Result,'Password=');
   try
   Result:=spl[0]+'Password=••••••••'+Copy(spl[1],Pos(';',spl[1]),Length(spl[1]));
   finally
   Setlength(spl,0);
   end;
   end;
end;


function dbDataSetToHTML(DataSet : TDataSet; var html : string; const title : string): boolean;
var
 cnt     : integer;
 row     : string;
 align   : string;
 value   : string;
 ms      : TMemoryStream;
 sz      : Int64;
 PicType : TPicType;
 wdt, hgt: integer;
begin
Result:=false;
if not Assigned(DataSet) or
   (DataSet.State<>dsBrowse) or
   (DataSet.Fields.Count=0) or
   (DataSet.Eof) then Exit;
with DataSet do
   begin
   html:='<html><head>';
   html:=html+'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>';
   html:=html+'<title>'+title+'</title></head>';
   html:=html+'<body><div>'+title+'</div></br><table border="1">';
   row:='<tr>';
   for cnt:=0 to FieldCount-1
     do row:=row+Format('<td align="center">%0:s</td>',[Fields[cnt].FieldName]);
   html:=html+row+'</tr>';
   while not Eof
     do begin
     for cnt:=0 to FieldCount-1
       do begin
       if Fields[cnt].IsNull
          then row:=row+'<td align="center"><i>null</i></td>'
          else begin
          case Fields[cnt].DataType of
          ftString, ftMemo, ftWideString, ftWideMemo :
            begin
            align:='left';
            value:=Fields[cnt].AsString;
            end;
          ftTime :
            begin
            align:='center';
            value:=FormatDateTime('hh:nn:ss',Fields[cnt].AsDateTime);
            end;
          ftDate :
            begin
            align:='center';
            value:=FormatDateTime('dd.mm.yyyy',Fields[cnt].AsDateTime);
            end;
          ftDateTime :
            begin
            align:='center';
            if Frac(Fields[cnt].AsDateTime)=0
               then value:=FormatDateTime('dd.mm.yyyy',Fields[cnt].AsDateTime)
               else value:=FormatDateTime('dd.mm.yyyy hh:nn:ss',Fields[cnt].AsDateTime);
            end;
          ftBoolean:
            begin
            align:='center';
            value:=IfThen(Fields[cnt].AsBoolean,'','');
            end;
          ftBlob, ftGraphic :
            begin
            align:='center';
            ms:=TMemoryStream.Create;
            try
            sz:=FieldToMemoryStream(Fields[cnt], ms);
            PicType:=GetPictureType(ms);
            if (PicType=ptNotImage) or (sz=0)
               then value:=Fields[cnt].DisplayText
               else begin
               ms.Position:=0;
               if PicStreamProps(ms, wdt, hgt)
                  then  value:=Format('<img width="%1:d%%" src="%0:s">',[Round(150/wdt*100), '"'+PicDataBase64[PicType]+Base64_EncodeStream(ms)+'"'])
                  else  value:=Format('<img src="%0:s">',['"'+PicDataBase64[PicType]+Base64_EncodeStream(ms)+'"'])
               end;

            finally
            ms.Clear;
            ms.Free;
            end;
            end;
          ftVariant :
            begin
            align:='left';
            value:=GDV(Fields[cnt].AsVariant);
            end;
          else begin
          align:='right';
          value:=Fields[cnt].DisplayText;
          end;
          end;
       row:=row+Format('<td align="%1:s">%0:s</td>',[align, value]);
       end;
       end;

     Next;
     end;


end;
Result:=true;
end;


initialization
//dbLoadSettings(DBiniSection);
finalization
//

end.



