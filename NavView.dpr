program NavView;
 // -- !!! не менять порядок следования модулей в секции USES !!! ----------------------------------
uses
  Windows,
  Forms,
  SysUtils,
  Classes,
  Types,
  StrUtils,
  INIFiles,
  AppPrms in 'D:\Projects_Common\AppPrms.pas',
  FnCommon in 'D:\Projects_Common\FnCommon.pas',
  U_NV_Main in 'U_NV_Main.pas' {_Main};

{$R *.res}
type
 TGlobalExHandler = class
    public
      procedure HandlerProc(Sender:TObject;EInstance:Exception);
 end;

var
 GlobalExHandler : TGlobalExHandler;

procedure TGlobalExHandler.HandlerProc(Sender:TObject; EInstance:Exception);
var
 ec  : integer;
 str : string;
// res : boolean;
begin
try
ec:=GetLastError;
str:=AboutObject(Sender);
str:=str+Format('. %s',[GetErrorString(ec)]);
if Assigned(apLogList)
   then apLogList.AddRecord(lrtError,'UNHANDLED : '+str)
   else MessageBox(Application.Handle,PChar(str),'Необработанная ошибка приложения',MB_ICONERROR);
except
  on E : Exception do ShowMessageError('Ошибка в перехватчике(!!!) : '+E.Message);
end;
end;


begin
  IsMultiThread:=true;
{$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown:=DebugHook<>0;
{$WARN SYMBOL_PLATFORM ON}
  // -- apLogList создается и разрушается в модуле AppPrms отслеживаются параметры log, savelog
  GlobalExHandler:=TGlobalExHandler.Create;
  try
  Application.Initialize;
  Application.OnException:=GlobalExHandler.HandlerProc;
  Application.MainFormOnTaskbar:=true;
  Application.CreateForm(T_Main, _Main);
  Application.Run;
  finally
  Application.onMessage:=nil;
  Application.OnException:=nil;
  GlobalExHandler.Free;
  end;
end.
