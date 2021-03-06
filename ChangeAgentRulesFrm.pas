unit ChangeAgentRulesFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, StdCtrls, Buttons, ToolWin, Grids, U_Main, Menus,
  ChangeAgentRuleClasses, ExtCtrls;

type

  TContentType = (ctText, ctImage);
  TSgColProp = record
    Alignment : TAlignment;
    ContentType : TContentType;
    FixedSize : BOOLEAN;
    MinWidth : Integer;
  End;

  TArrayOfSgColProp = Array of TSgColProp;


  TChangeAgentRulesForm = class(TForm)
    sg: TStringGrid;
    ToolBar: TToolBar;
    btnAdd: TToolButton;
    btnEdit: TToolButton;
    btnDel: TToolButton;
    pm: TPopupMenu;
    miAdd: TMenuItem;
    miEdit: TMenuItem;
    miDel: TMenuItem;
    Label1: TLabel;
    cbDataSourse: TComboBox;
    ToolBar2: TToolBar;
    btnRfillList: TToolButton;
    btnComfirm: TToolButton;
    ToolButton5: TToolButton;
    procedure miDelClick(Sender: TObject);
    procedure miAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure miEditClick(Sender: TObject);
    procedure btnRfillListClick(Sender: TObject);
    procedure btnComfirmClick(Sender: TObject);
  private
    SgColProps : TArrayOfSgColProp;

    DescrColInd : Integer;
    HabColInd : Integer;
    Hab2ColInd : Integer;
    PrivilegedColInd : Integer;
    MRPColInd : Integer;
    KLADRColInd : Integer;
    NAVColInd : Integer;
    KUPIVIPColInd : Integer;
    MAMSYColInd : Integer;
    HasChanges : Integer;

    procedure Init;
    procedure FillSg;
    procedure Draw_SgRow(Idx : Integer);
  public
    { Public declarations }
  end;

implementation

uses ChangeAgentRuleEditorFrm;

{$R *.dfm}

procedure TChangeAgentRulesForm.Draw_SgRow(Idx: Integer);
var
  ARule : TChangingAgentRule;
  NewWith : Integer;
begin
  ARule := TChangingAgentRule(sg.Objects[0,Idx]);
  if ARule <> nil then
  begin
    sg.Cells[DescrColInd,idx] := ARule.Caption;
    sg.Cells[KLADRColInd,idx] := ARule.KLADR;

    //??????????? ?????? ??????? ?? ?????? ?????? ?????
    NewWith := sg.Canvas.TextWidth(sg.Cells[DescrColInd,idx] + '    ');
    if sg.ColWidths[DescrColInd] < NewWith then sg.ColWidths[DescrColInd] := NewWith;

    NewWith := sg.Canvas.TextWidth(sg.Cells[KLADRColInd,idx] + '    ');
    if sg.ColWidths[KLADRColInd] < NewWith then sg.ColWidths[KLADRColInd] := NewWith;
  end
  else
  begin
    sg.Cells[DescrColInd,idx] := '';
    sg.Cells[KLADRColInd,idx] := '';
  end;
end;

procedure TChangeAgentRulesForm.FillSg;
var
  i, last_i : Integer;
begin
  with ChangingAgentRuleList do
  begin
    if ChangingAgentRuleList.Count = 0 then
    begin
      sg.RowCount := 2;
      sg.Objects[0,1] := nil;
      Draw_SgRow(1);
      exit;
    end;

    sg.RowCount := ChangingAgentRuleList.Count + 1;
    last_i := sg.RowCount - 1;
    for i := 1 to  last_i do
    begin
      sg.Objects[0,i] := ChangingAgentRuleList.Objects[i-1];
      Draw_SgRow(i);
    end;
  end;
  Sg.Row := 1;
end;

procedure TChangeAgentRulesForm.FormShow(Sender: TObject);
begin
  Init;
  btnRfillListClick(nil)
end;

procedure TChangeAgentRulesForm.Init;
var
  i : Integer;
begin
  cbDataSourse.Items.AddObject('???????? (??????????????)', Pointer(1));
  cbDataSourse.Items.AddObject('?? ????????? ??????? (????????????????)', Pointer(0));
  cbDataSourse.ItemIndex := cbDataSourse.Items.IndexOfObject(Pointer(0));  //   ject('?? ????????? ??????? (????????????????)', Pointer(0));

  with sg do
  begin
    ColCount := 10;
    RowCount := 2;
    FixedCols := 0;
    FixedRows := 1;
    SetLength(SgColProps, ColCount);

    Cells[0,0] := '????????';
    SgColProps[0].Alignment := taLeftJustify;
    SgColProps[0].FixedSize := TRUE;

    Cells[1,0] := 'Hab';
    SgColProps[1].Alignment := taCenter;
    SgColProps[1].FixedSize := TRUE;

    Cells[2,0] := 'Hab2';
    SgColProps[2].Alignment := taCenter;
    SgColProps[2].FixedSize := TRUE;

    Cells[3,0] := '??????????';
    SgColProps[3].Alignment := taCenter;
    SgColProps[3].FixedSize := TRUE;

    Cells[4,0] := 'MRP';
    SgColProps[4].Alignment := taCenter;
    SgColProps[4].FixedSize := TRUE;

    Cells[5,0] := 'KLADR';
    SgColProps[5].Alignment := taCenter;
    SgColProps[5].FixedSize := TRUE;

    Cells[6,0] := 'NAV';
    SgColProps[6].Alignment := taCenter;
    SgColProps[6].FixedSize := TRUE;

    Cells[7,0] := 'KUPIVIP';
    SgColProps[7].Alignment := taCenter;
    SgColProps[7].FixedSize := TRUE;


    Cells[8,0] := 'MAMSY';
    SgColProps[8].Alignment := taCenter;
    SgColProps[8].FixedSize := TRUE;



    Cells[9,0] := '  ';
    SgColProps[9].Alignment := taCenter;
    SgColProps[9].FixedSize := TRUE;



    DescrColInd := 0;
    HabColInd := 1;
    Hab2ColInd := 2;
    PrivilegedColInd := 3;
    MRPColInd := 4;
    KLADRColInd := 5;
    NAVColInd := 6;
    KUPIVIPColInd := 7;
    MAMSYColInd := 8;
    HasChanges := 9;

    for i := ColCount - 1 downto 0 do
    ColWidths[i] := Canvas.TextWidth(Cells[i,0] +'    ')
  end;
end;

procedure TChangeAgentRulesForm.miAddClick(Sender: TObject);
var
  Rule : TChangingAgentRule;
begin
  Rule := TChangingAgentRule.Create;
  if TChangeAgentRuleEditorForm.Execute(Rule) then
  begin
    Rule.Save;
    ChangingAgentRuleList.AddRule(Rule);
    sg.RowCount := sg.RowCount + 1;
    sg.Objects[0,sg.RowCount - 1] := Rule;
    Draw_SgRow(sg.RowCount - 1);
  end;
end;

procedure TChangeAgentRulesForm.miDelClick(Sender: TObject);
var
  Rule : TChangingAgentRule;
begin
  if Sg.Row < 1 then exit;
  Rule := TChangingAgentRule(sg.Objects[0, Sg.Row]);

  if MessageDlg('?? ????????????? ?????? ??????? ??????? "' + Rule.Caption+'"',
      mtConfirmation, [mbOk, mbCancel],0) = mrOk then
  begin
    if ChangingAgentRuleList.DeleteRule(Rule) then
    begin
      FillSg;
    end;
  end;
end;

procedure TChangeAgentRulesForm.miEditClick(Sender: TObject);
var
  Rule : TChangingAgentRule;
begin
  if Sg.Row < 1 then exit;
  Rule := TChangingAgentRule(sg.Objects[0, Sg.Row]);

  if TChangeAgentRuleEditorForm.Execute(Rule) then
  begin
    Rule.Save;
    Draw_SgRow(Sg.Row);
  end;
end;

procedure TChangeAgentRulesForm.sgDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s : String;
  tw : Integer;
  FLG : UINT;
  x, idx : Integer;
begin
  s := sg.Cells[ACol, ARow];
  tw :=  sg.Canvas.TextWidth(s);

  sg.Canvas.FillRect(Rect);
  Rect.Left := Rect.Left + 3;
  Rect.Right := Rect.Right - 3;
  Rect.Top := Rect.Top + 2;
  Rect.Bottom := Rect.Bottom - 2;

  FLG := DT_VCENTER;
{
  //??????? ??? ????????? ? ????????????? ????? ??????? (?? ????????? ?????? ? ?? ???????? selection)
  //  sg.DefaultDrawing := FALSE;
  if SgColProps[ACol].Alignment = taLeftJustify then FLG := FLG OR DT_LEFT
  else if SgColProps[ACol].Alignment = taRightJustify then FLG := FLG OR DT_RIGHT
  else if SgColProps[ACol].Alignment = taCenter then FLG := FLG OR DT_CENTER;
}

  DrawText(sg.Canvas.Handle, PWideChar(s), Length(s), Rect, FLG);

  if (ACol = HabColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).Hab else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end
  else if (ACol = Hab2ColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).Hab2 else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end
  else if (ACol = PrivilegedColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).Privileged else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end
  else if (ACol = MRPColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).MRP else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end
  else if (ACol = NAVColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).NAV else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end
  else if (ACol = KUPIVIPColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).KUPIVIP else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end

  else if (ACol = MAMSYColInd) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if sg.Objects[0, ARow] <> nil then idx := TChangingAgentRule(sg.Objects[0, ARow]).MAMSY else idx := -2;
    if idx = -1 then idx := 2;
    if idx <> -2 then _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx + 7);
  end



  else if (ACol = HasChanges) AND (ARow > 0)  then
  begin
    x :=  Rect.Left +((Rect.Right - Rect.Left) div 2) - 8;
    if (sg.Objects[0, ARow] <> nil) AND (TChangingAgentRule(sg.Objects[0, ARow]).HasChanges) then idx := 22 else idx := -2;
    if idx = 22 then  _Main.IL_Paint.Draw(sg.Canvas, x, Rect.Top, idx);
  end;
end;

procedure TChangeAgentRulesForm.btnComfirmClick(Sender: TObject);
var
  InputCode, ErrMsg : String;
begin
  if ChangingAgentRuleList.GetConfirmCode then
  begin
    InputCode := InputBox('?????????????', '??????? ??? ?????????????', '');
    if ChangingAgentRuleList.ConfirmRules(InputCode, ErrMsg) then
      FillSg
    else
     MessageDlg(ErrMsg, mtError, [mbOk], 0);
  end
  else
  begin
    MessageDlg('????????????? ?? ????? ???? ?????????', mtError, [mbOK], 0);
  end;
end;

procedure TChangeAgentRulesForm.btnRfillListClick(Sender: TObject);
var
  rlf : TReLoadFrom;
  r : Integer;

begin
  if Integer(cbDataSourse.Items.Objects[cbDataSourse.ItemIndex]) = 1 then
  begin
    rlf :=  rfHistory;
    if NOT((sg.RowCount = 2) AND (sg.Objects[0, 1] = nil))  then
      if MessageDlg('???????? ????? ?? ????????? ?????? ?? ?????????? ???????????????? ?????? ??????????? ?? ????????? ??????? ???????.' + #13+#10 + '???????????',
         mtWarning, [mbOK, mbCancel], 0) = mrCancel then exit;
  end
  else
    rlf :=  rfTempData;

  ChangingAgentRuleList.ReLoad(rlf);
  FillSg;
end;

end.



