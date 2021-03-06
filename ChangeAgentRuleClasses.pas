unit ChangeAgentRuleClasses;

interface

uses  Windows, Messages, SysUtils, Classes, DB, ADODB, FnADODB, Dialogs
;

type

  TShipAgent = class
  public
    id : Integer;
    Code : String;
    Description : String;
    Outlet : BOOLEAN;
    procedure FillObject(DataSet : TDataSet);
    function id_for_ord_str : string;
    function FullCaption : string;

  end;

  TShipAgentList = class(TStringList)
  private
    function GetObject(Index: Integer): TShipAgent;
    procedure PutObject(Index: Integer; AObject : TShipAgent);
  public
    constructor Create;
    procedure Load;
    procedure FillStrings(List : TStrings);
    function GetShipAgentById(Id : Integer) : TShipAgent;
    property Objects[Index : Integer] : TShipAgent read GetObject write PutObject;
  end;


  TChangingAgentRule = class
  public
    RuleID : Integer;
    AgentFrom : TShipAgent;
    AgentTo : TShipAgent;
    Hab	: Integer;
    Hab2	: Integer;
    Privileged	: Integer;
    MRP	: Integer;
    KLADR : string;
    NAV	: Integer;
    KUPIVIP	: Integer;
    MAMSY	: Integer;

    HasChanges : BOOLEAN;

    constructor Create;
    procedure FillObject(DataSet : TAdoDataSet);
    function Caption : String;
    function Save : BOOLEAN;
  end;

  TReLoadFrom = (rfTempData, rfHistory);

  TChangingAgentRuleList = class(TStringList)
  private
    FConfirmCode : String;

    function GetObject(Index: Integer): TChangingAgentRule;
    procedure PutObject(Index: Integer; AObject: TChangingAgentRule);
    function ConfirmCode: BOOLEAN;
  published
  public
    constructor Create;
    procedure Load(From : TReLoadFrom = rfHistory);
    procedure ReLoad(From : TReLoadFrom);
    procedure AgentRulesClear;

    procedure AddRule(ARule : TChangingAgentRule);
    function DeleteRule(ARule : TChangingAgentRule) : BOOLEAN;

    function ConfirmRules(Code : String; var ErrMsg : String) : BOOLEAN;
    function GetConfirmCode : BOOLEAN;

    property Objects[Index : Integer] : TChangingAgentRule read GetObject write PutObject;
  end;


  function IntAs10Chars(AInt : Integer): string;

  function ShipAgentList : TShipAgentList;
  function ChangingAgentRuleList : TChangingAgentRuleList;


implementation

var
  _ShipAgentList  : TShipAgentList;
  _ChangingAgentRuleList : TChangingAgentRuleList;


function ShipAgentList;
begin
  if _ShipAgentList = nil then
  begin
    _ShipAgentList := TShipAgentList.Create;
    _ShipAgentList.Load;
  end;
  Result := _ShipAgentList;
end;

function ChangingAgentRuleList : TChangingAgentRuleList;
begin
  if _ChangingAgentRuleList = nil then
  begin
    _ChangingAgentRuleList := TChangingAgentRuleList.Create;
//    _ChangingAgentRuleList.Load;
  end;
  Result := _ChangingAgentRuleList;
end;



function IntAs10Chars (AInt : Integer): string;
var
  i : Integer;
begin
  //?????? ?????? ? 10 ???????? ? ??????????? ??????
  Result := IntToStr(AInt);
  i := 10 - Length(Result);

  while i > 0 do
  begin
    Result := '0' + Result;
    Dec(i);
  end;
end;


{ TShipAgentList }

constructor TShipAgentList.Create;
begin
  Sorted := TRUE;
end;

procedure TShipAgentList.FillStrings(List: TStrings);
var
  sl : TStringList;
  i : Integer;
begin
  if List = nil then exit;
  List.Clear;

  sl := TStringList.Create;
  sl.Sorted := TRUE;

  for i := Count-1 downto 0 do sl.AddObject(Objects[i].FullCaption, Objects[i]);
  List.Assign(sl);
end;

function TShipAgentList.GetObject(Index: Integer): TShipAgent;
begin
  Result := TShipAgent(inherited GetObject(Index));
end;

function TShipAgentList.GetShipAgentById(Id: Integer): TShipAgent;
var
  s : String;
  idx : Integer;
begin
  s := IntAs10Chars(Id);
  if Find(s, idx) then Result := Objects[idx] else Result := nil;
end;

procedure TShipAgentList.Load;
var
  Q : String;
  ADODataSet : TAdoDataSet;
  ADOSP : TADOStoredProc;
  Agent : TShipAgent;
begin
  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := 'EXEC rt_Select_AgentsListOfChangingAgentRules' ;

  try
    ADODataSet.Open;
    while not ADODataSet.Eof do
    begin
      Agent := TShipAgent.Create;
      Agent.FillObject(ADODataSet);
      AddObject(Agent.id_for_ord_str, Agent);
      ADODataSet.Next;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

procedure TShipAgentList.PutObject(Index: Integer; AObject : TShipAgent);
begin
  inherited PutObject(Index, AObject);
end;

{ TShipAgent }

procedure TShipAgent.FillObject(DataSet: TDataSet);
begin
  id := DataSet.FieldByName('id').AsInteger;
  Code := DataSet.FieldByName('Code').AsString;
  Description := DataSet.FieldByName('Description').AsString;
  Outlet := DataSet.FieldByName('Outlet').AsInteger <> 0;
end;

function TShipAgent.FullCaption: string;
begin
  Result := Description + ' - ' + Code;
end;

function TShipAgent.id_for_ord_str: string;
var
  i : Integer;
begin
  Result := IntAs10Chars(id);
end;

{ TChangingAgentRuleList }

procedure TChangingAgentRuleList.AddRule(ARule : TChangingAgentRule);
begin
  AddObject(ARule.Caption, ARule);
end;

procedure TChangingAgentRuleList.AgentRulesClear;
var
  i : Integer;
begin
  for i := Count - 1 downto 0 do Objects[i].Free;
  Clear;
end;

function TChangingAgentRuleList.ConfirmCode: BOOLEAN;
var
  Q : String;
  ADODataSet : TAdoDataSet;
begin
  Result := FALSE;

  if Count = 0 then
  begin
    MessageDlg('??? ??????? ??? ?????????????.', mtInformation, [mbOK],0);
    exit;
  end;

  Q := 'EXEC rt_GetConfirmCode_ChangingAgentRules';

  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := Q;
  try
    ADODataSet.Open;
    if not ADODataSet.Eof then
    begin
      FConfirmCode := ADODataSet.FieldByName('Code').AsString;
      Result := TRUE;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

function TChangingAgentRuleList.ConfirmRules(Code: String; var ErrMsg: String): BOOLEAN;
var
  Q : String;
  ADODataSet : TAdoDataSet;
begin
  Result := FALSE;

  if FConfirmCode <> Code then
  begin
    ErrMsg := '????????? ??? ?? ????????????? ???????????';
    exit;
  end;

  Q := 'EXEC rt_Confirm_Last_ChangingAgentRules';

  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := Q;
  try
    try
      ADODataSet.Open;
      if not ADODataSet.Eof then
      begin
        ReLoad(rfTempData);
        Result := TRUE;
      end;
    except
      on e : Exception do ErrMsg := E.ClassName+' ?????? ? ?????????? : '+E.Message;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

constructor TChangingAgentRuleList.Create;
begin
//  Sorted := TRUE;
end;

function TChangingAgentRuleList.DeleteRule(ARule: TChangingAgentRule): BOOLEAN;
var
  Q : String;
  ADODataSet : TAdoDataSet;
begin
  Result := FALSE;
  Q := 'EXEC rt_Delete_ChangingAgentRules @RuleID = ' + IntToStr(ARule.RuleID);

  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := Q;
  try
    ADODataSet.Open;
    if not ADODataSet.Eof then
    begin
      Delete(IndexOfObject(ARule));
      ARule.Free;
      Result := TRUE;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

function TChangingAgentRuleList.GetConfirmCode : BOOLEAN;
var
  Q : String;
  ADODataSet : TAdoDataSet;
begin
  Result := FALSE;

  if Count = 0 then
  begin
    MessageDlg('??? ??????? ??? ?????????????.', mtInformation, [mbOK],0);
    exit;
  end;

  Q := 'EXEC rt_GetConfirmCode_ChangingAgentRules';

  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := Q;
  try
    ADODataSet.Open;
    if not ADODataSet.Eof then
    begin
      FConfirmCode := ADODataSet.FieldByName('Code').AsString;
      Result := TRUE;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

function TChangingAgentRuleList.GetObject(Index: Integer): TChangingAgentRule;
begin
  Result := TChangingAgentRule(inherited GetObject(Index));
end;

procedure TChangingAgentRuleList.Load(From : TReLoadFrom = rfHistory);
var
  Q : String;
  ADODataSet : TAdoDataSet;
//  ADOSP : TADOStoredProc;
  ARule : TChangingAgentRule;
begin
  if From = rfHistory then
    Q := 'EXEC rt_Select_ChangingAgentRules @fromHistory = 1'
  else
    Q := 'EXEC rt_Select_ChangingAgentRules @fromHistory = 0';


  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;
  ADODataSet.CommandText := Q;

  try
    ADODataSet.Open;
    while not ADODataSet.Eof do
    begin
      ARule := TChangingAgentRule.Create;
      ARule.FillObject(ADODataSet);
      AddRule(ARule);
      ADODataSet.Next;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

procedure TChangingAgentRuleList.PutObject(Index: Integer; AObject: TChangingAgentRule);
begin
  inherited PutObject(Index, AObject);
end;

procedure TChangingAgentRuleList.ReLoad(From: TReLoadFrom);
begin
  AgentRulesClear;
  Load(From);
end;

{ TChangingAgentRule }

function TChangingAgentRule.Caption: String;
begin
 Result := AgentFrom.Description + ' ['+AgentFrom.Code +']' +
 ' - ' +
 AgentTo.Description + ' ['+AgentTo.Code +']';
end;

constructor TChangingAgentRule.Create;
begin
  Hab	:= -1;
  Hab2	:= -1;
  Privileged	:= -1;
  MRP	:= -1;
  NAV	:= -1;
  KUPIVIP	:= -1;
  HasChanges := FALSE;
end;

procedure TChangingAgentRule.FillObject(DataSet: TAdoDataSet);
var
  id : Integer;
begin
  RuleID := DataSet.FieldByName('RuleID').AsInteger;
  id := DataSet.FieldByName('AgentFrom').AsInteger;
  AgentFrom := ShipAgentList.GetShipAgentById(id);
  id := DataSet.FieldByName('AgentTo').AsInteger;
  AgentTo := ShipAgentList.GetShipAgentById(id);

  Hab	:= DataSet.FieldByName('Hab').AsInteger;
  Hab2	:= DataSet.FieldByName('Hab2').AsInteger;
  Privileged	:= DataSet.FieldByName('Privileged').AsInteger;
  MRP	:= DataSet.FieldByName('MRP').AsInteger;
  KLADR := DataSet.FieldByName('KLADR').AsString;
  NAV	:= DataSet.FieldByName('NAV').AsInteger;
  KUPIVIP	:= DataSet.FieldByName('KUPIVIP').AsInteger;
  MAMSY := DataSet.FieldByName('MAMSY').AsInteger;
end;

function TChangingAgentRule.Save: BOOLEAN;
var
  Q : String;
  ADODataSet : TAdoDataSet;
//  ADOSP : TADOStoredProc;
  ARule : TChangingAgentRule;
begin

  ADODataSet := TAdoDataSet.Create(nil);;
  ADODataSet.Connection := TADOConnection.Create(nil);
  ADODataSet.Connection.ConnectionString:= DBConnString;


  if RuleID = 0 then
    Q := 'EXEC rt_Insert_ChangingAgentRules '
  else
    Q := 'EXEC rt_Update_ChangingAgentRules ' +
    '@RuleID = ' + IntToStr(RuleID) + ', ';

  //?????? ????? ?????????
  Q := Q +
  '@AgentFrom = ' + IntToStr(AgentFrom.id) + ', ' +
  '@AgentTo = ' + IntToStr(AgentTo.id) + ', ' +
  '@Hub = ' + IntToStr(Hab) + ', ' +
  '@Hub2 = ' + IntToStr(Hab2) + ', ' +
  '@Privileged = ' + IntToStr(Privileged) + ', ' +
  '@MRP = ' + IntToStr(MRP) + ', ' ;

  if AnsiUpperCase(KLADR) = 'NULL' then
    Q := Q + '@KLADR = NULL, '
  else
    Q := Q + '@KLADR = ''' + KLADR + ''', ';

  Q := Q +
  '@NAV = ' + IntToStr(NAV) + ', ' +
  '@KUPIVIP = ' + IntToStr(KUPIVIP) + ', ' +
  '@MAMSY = ' + IntToStr(MAMSY) ;

  ADODataSet.CommandText := Q;

  try
    ADODataSet.Open;
    if not ADODataSet.Eof then
    begin
      RuleID := ADODataSet.FieldByName('RuleID').AsInteger;
      HasChanges := TRUE;
    end;
  finally
    ADODataSet.Connection.Free;
    ADODataSet.Free;
  end;
end;

end.
