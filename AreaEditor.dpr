program AreaEditor;

{$R 'HtmlPages.res' 'HTML\HtmlPages.rc'}

// debug -- ����� ��������� ���������� ���������
// log ��� savelog -- �������������� ���������� ������� ������


// -- ������ --------------
// 1. ��������� ������������� � ��������� ���� (AreaEditor.GetWorkMode)
// 2. ����� ������ �� ������ ������ (����� AboutFull ?)
// 3. ��������� ����� (��� Router-�, ������, ��� � ������ ���������) ���(!!!) ���������� ��������� ����� �����
// -- �� AreaLogList --
// * ���������
// -- ������� ID �� XML �� ������� ������������ (�� ��������� ���������� (� XML ����� ���� ID=0))
// -- ����������� ������� ��������������� ��� ������ � ������
// * ��������� ��������� �������� � ����������� ID (�������� - �� ����)


uses
  Windows,
  Forms,
  SysUtils,
  Classes,
  Types,
  StrUtils,
  INIFiles,
  Graphics,
  AppLogNew in '..\Projects_Common\AppLogNew.pas',
  FnCommon in '..\Projects_Common\FnCommon.pas',
  FnADODB in '..\Projects_Common\FnADODB.pas',
  IntervalEx in '..\Projects_Common\IntervalEx.pas',
  AreaEditor_Types in 'AreaEditor_Types.pas',
  Frm_Interval in '..\Projects_Common\Frm_Interval.pas' {Interval: TFrame},
  U_Main in 'U_Main.pas' {_Main},
  U_DTP_Editor in 'U_DTP_Editor.pas' {_DTP_Editor},
  U_Filter_GetDates in '..\Projects_Common\U_Filter_GetDates.pas' {_Filter_GetDates},
  U_H2Interval in 'U_H2Interval.pas' {_H2Interval},
  ChangeAgentRulesFrm in 'ChangeAgentRulesFrm.pas' {ChangeAgentRulesForm},
  ChangeAgentRuleEditorFrm in 'ChangeAgentRuleEditorFrm.pas' {ChangeAgentRuleEditorForm},
  ChangeAgentRuleClasses in 'ChangeAgentRuleClasses.pas';

//,
//  U_TwoHours in 'U_TwoHours.pas' {_TwoHours};

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
LogErrorMessage('GlobalHandler',EInstance,[str,GetErrorString(ec)]);
//str:=str+Format('. %s',[GetErrorString(ec)]);
//if Assigned(apLogList)
//   then apLogList.AddRecord(lrtError,'UNHANDLED : '+str)
//   else MessageBox(Application.Handle,PChar(str),'�������������� ������ ����������',MB_ICONERROR);
except
  on E : Exception do ShowMessageError('������ � ������������(!!!) : '+E.Message);
end;
end;


function LoadDBSettings : boolean;
var
 inm : string;
begin
Result:=False;
try
inm:=AppParams.CFGCommonFileName;
with TINIFile.Create(inm) do
  try
  DBiniSection  := ReadString(baseSection,DBCurrentSection,DBiniSection);
  DBWinAutMode  := ReadBool(DBiniSection,'DBWinAutMode',DBWinAutMode);
  DBName        := ReadString(DBiniSection,'DBName',DBName);
  DBServer      := ReadString(DBiniSection,'DBServer',DBServer);
  FnADODB.dbPrepareConnString;
  finally
  Free;
  end;
Result:=True;
except
  on E : Exception do LogErrorMessage('LoadDBSettings',E,[inm]);
end
end;


function GetWorkMode : TWorkMode;
begin
Result:=[];
if not LoadDBSettings then Exit;

// -- �������������� �� �� --
//if InputQueryPas('�������������','���','������',logList,lastLog,curLog,curPas)
//   then begin
//
//   end;



Result:=[wmtRead, wmtWrite, wmtMarkers, wmtRoute];
end;


begin


  IsMultiThread:=true;
{$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown:=DebugHook<>0;
{$WARN SYMBOL_PLATFORM ON}
  GlobalExHandler:=TGlobalExHandler.Create;
  try
  Application.Initialize;
  WorkMode:=GetWorkMode;
  LogInfoMessage('������� ����������: '+AboutWorkMode) ;
  Application.OnException:=GlobalExHandler.HandlerProc;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(T_Main, _Main);
  //Application.CreateForm(T_TwoHours, _TwoHours);
  Application.Run;
  finally
  Application.onMessage:=nil;
  Application.OnException:=nil;
  GlobalExHandler.Free;
  end;
end.
