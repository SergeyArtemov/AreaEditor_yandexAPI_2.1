unit ChangeAgentRuleEditorFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ChangeAgentRuleClasses;

type
  TChangeAgentRuleEditorForm = class(TForm)
    btnOk: TBitBtn;
    BtnCancel: TBitBtn;
    cbAgentList_From: TComboBox;
    cbAgentList_To: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eKLADR: TEdit;
    cbHab: TComboBox;
    Label4: TLabel;
    cbHab2: TComboBox;
    Label5: TLabel;
    cbPrivileged: TComboBox;
    Label6: TLabel;
    cbKupivip: TComboBox;
    cbNav: TComboBox;
    cbMRP: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    cbMamsy: TComboBox;
    procedure btnOkClick(Sender: TObject);
  private
    FChARule : TChangingAgentRule;
    procedure Init;
    procedure ObjectToControl;
    procedure ControlToObject;
    function CheckHasChanges : BOOLEAN;
    function CheckBeforeReturn : BOOLEAN;
  public
    class function Execute(AChARule : TChangingAgentRule) : BOOLEAN;
  end;


implementation

{$R *.dfm}

{ TTChangeAgentRuleEditorForm }

procedure TChangeAgentRuleEditorForm.btnOkClick(Sender: TObject);
begin
  if NOT CheckBeforeReturn then ModalResult := mrNone
  else if NOT CheckHasChanges then ModalResult := mrCancel;
end;

function TChangeAgentRuleEditorForm.CheckBeforeReturn: BOOLEAN;
var
  Err_msg : string;
  s : string;
  i, ln : Integer;
begin
  Err_msg := '';

  if cbAgentList_From.ItemIndex = -1 then
    Err_msg := Err_msg + '    ' + '???? "??????? ??????" ?????? ???? ???????;' + #13+#10;
  if cbAgentList_To.ItemIndex = -1 then
    Err_msg := Err_msg + '    ' + '???? "??  ??????" ?????? ???? ???????;' + #13+#10;
  if (cbAgentList_To.ItemIndex >= 0) AND (cbAgentList_From.ItemIndex = cbAgentList_To.ItemIndex) then
    Err_msg := Err_msg + '    ' + '???? "??????? ??????" ? ???? "??  ??????" ?? ?????? ?????????;' + #13+#10;

  s := Trim(AnsiUpperCase(eKLADR.Text));
  if NOT ((s = '') OR (s = 'NULL')) then
  begin
    ln := Length(s);
    for i := 1 to ln do
      if NOT(s[i] IN ['0'..'9']) then
      begin
        Err_msg := Err_msg + '    ' + '???? "KLADR" ?????? ????????? ??? ????? ????? ??? ????? NULL ??? "??????" ??????;' + #13+#10;
        break;
      end;
  end;
  if Err_msg <> '' then
  begin
    Err_msg := '? ???????? ???????? ???????? ???????? ??????????:' + #13+#10 + Err_msg;
    MessageDlg(Err_msg, mtConfirmation,[mbOk], 0);
    Result  := FALSE;
  end
  else
    Result  := TRUE;
end;

function TChangeAgentRuleEditorForm.CheckHasChanges: BOOLEAN;
begin
  //????????? ??????? ?????????
  Result := TRUE;
  with cbAgentList_From do
    if FChARule.AgentFrom <> TShipAgent(cbAgentList_From.Items.Objects[ItemIndex]) then exit;

  with cbAgentList_To do
    if FChARule.AgentTo <> TShipAgent(cbAgentList_To.Items.Objects[ItemIndex]) then exit;

  if FChARule.Hab <> Integer(cbHab.Items.Objects[cbHab.ItemIndex]) then exit;
  if FChARule.Hab2 <> Integer(cbHab2.Items.Objects[cbHab2.ItemIndex]) then exit;
  if FChARule.Privileged <> Integer(cbPrivileged.Items.Objects[cbPrivileged.ItemIndex]) then exit;
  if FChARule.MRP <> Integer(cbMRP.Items.Objects[cbMRP.ItemIndex]) then exit;
  if FChARule.NAV <> Integer(cbNAV.Items.Objects[cbNAV.ItemIndex]) then exit;
  if FChARule.KUPIVIP <> Integer(cbKUPIVIP.Items.Objects[cbKUPIVIP.ItemIndex]) then exit;
  if FChARule.MAMSY <> Integer(cbMamsy.Items.Objects[cbMamsy.ItemIndex]) then exit;

  if FChARule.KLADR <> eKLADR.Text then exit;

  Result := FALSE;
end;

procedure TChangeAgentRuleEditorForm.ControlToObject;
begin
  with cbAgentList_From do
    FChARule.AgentFrom := TShipAgent(cbAgentList_From.Items.Objects[ItemIndex]);

  with cbAgentList_To do
    FChARule.AgentTo := TShipAgent(cbAgentList_To.Items.Objects[ItemIndex]);

  FChARule.Hab := Integer(cbHab.Items.Objects[cbHab.ItemIndex]);
  FChARule.Hab2 := Integer(cbHab2.Items.Objects[cbHab2.ItemIndex]);
  FChARule.Privileged := Integer(cbPrivileged.Items.Objects[cbPrivileged.ItemIndex]);
  FChARule.MRP := Integer(cbMRP.Items.Objects[cbMRP.ItemIndex]);
  FChARule.NAV := Integer(cbNAV.Items.Objects[cbNAV.ItemIndex]);
  FChARule.KUPIVIP := Integer(cbKUPIVIP.Items.Objects[cbKUPIVIP.ItemIndex]);
  FChARule.MAMSY := Integer(cbMamsy.Items.Objects[cbMamsy.ItemIndex]);

  FChARule.KLADR := eKLADR.Text;
end;

class function TChangeAgentRuleEditorForm.Execute(AChARule: TChangingAgentRule): BOOLEAN;
begin
  with Create(nil) do
  begin
    FChARule := AChARule;
    Init;
    ObjectToControl;
    if ShowModal = mrOk then
    begin
      ControlToObject;
      Result := TRUE;
    end
    else Result := FALSE;
  end;
end;

procedure TChangeAgentRuleEditorForm.Init;
var
  cb : TComboBox;
  itms : TStringList;
begin
  ShipAgentList.FillStrings(cbAgentList_From.Items);
  ShipAgentList.FillStrings(cbAgentList_To.Items);

  itms := TStringList.Create;
  itms.AddObject('?????.', Pointer(-1));
  itms.AddObject('??', Pointer(1));
  itms.AddObject('???', Pointer(0));

  cbHab.Items.Assign(itms);
  cbHab2.Items.Assign(itms);
  cbPrivileged.Items.Assign(itms);
  cbMRP.Items.Assign(itms);
  cbNav.Items.Assign(itms);
  cbKupivip.Items.Assign(itms);
  cbMamsy.Items.Assign(itms);
end;

procedure TChangeAgentRuleEditorForm.ObjectToControl;
begin
  cbAgentList_From.ItemIndex := cbAgentList_From.Items.IndexOfObject(FChARule.AgentFrom);
  cbAgentList_To.ItemIndex := cbAgentList_To.Items.IndexOfObject(FChARule.AgentTo);

  cbHab.ItemIndex := cbHab.Items.IndexOfObject(Pointer(FChARule.Hab));
  cbHab2.ItemIndex := cbHab2.Items.IndexOfObject(Pointer(FChARule.Hab2));
  cbPrivileged.ItemIndex := cbPrivileged.Items.IndexOfObject(Pointer(FChARule.Privileged));
  cbMRP.ItemIndex := cbMRP.Items.IndexOfObject(Pointer(FChARule.MRP));
  cbNav.ItemIndex := cbNav.Items.IndexOfObject(Pointer(FChARule.NAV));
  cbKupivip.ItemIndex := cbKupivip.Items.IndexOfObject(Pointer(FChARule.KUPIVIP));
  cbMamsy.ItemIndex := cbMamsy.Items.IndexOfObject(Pointer(FChARule.MAMSY));

  eKLADR.Text := FChARule.KLADR;
end;

end.
