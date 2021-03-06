unit TChangeAgentRuleEditorFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TTChangeAgentRuleEditorForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
  private
    FChARule : TObject;
    procedure Init;
    procedure ObjectToControl;
    procedure ControlToObject;
  public
    class function Execute(AChARule : TObject) : BOOLEAN;
  end;


implementation

{$R *.dfm}

{ TTChangeAgentRuleEditorForm }

procedure TTChangeAgentRuleEditorForm.ControlToObject;
begin

end;

class function TTChangeAgentRuleEditorForm.Execute(AChARule: TObject): BOOLEAN;
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

procedure TTChangeAgentRuleEditorForm.Init;
begin
//
end;

procedure TTChangeAgentRuleEditorForm.ObjectToControl;
begin

end;

end.
