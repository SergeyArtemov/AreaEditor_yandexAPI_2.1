unit U_H2Interval;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  FnCommon, StdCtrls, Buttons, ComCtrls, Spin;

type
  T_H2Interval = class(TForm)
    LabAreaInfo: TLabel;
    LabInterval: TLabel;
    CBInterval: TComboBox;
    LabdateBegin: TLabel;
    dtpDateBegin: TDateTimePicker;
    Label1: TLabel;
    dtpDateEnd: TDateTimePicker;
    BBcancel: TBitBtn;
    BBOk: TBitBtn;
    seQuota: TSpinEdit;
    BBdelete: TBitBtn;
    LabQuote: TLabel;
    procedure CBIntervalChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CallCheckData(Sender: TObject);
  private
    procedure CheckData;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure T_H2Interval.CheckData;
var
 ok  :boolean;
begin
ok := (1=1)
  and ((CBInterval.ItemIndex>-1) and (integer(CBInterval.Items.Objects[CBInterval.ItemIndex])>0))
  and (Trunc(dtpDatebegin.Date)>0)
  and ((not (dtpDateEnd.Checked))
       or
      ((dtpDateEnd.Checked) and (trunc(dtpDateBegin.Date)<Trunc(dtpDateEnd.Date))));
BBok.Enabled:=ok;
end;

procedure T_H2Interval.FormCreate(Sender: TObject);
begin
dtpDateBegin.DateTime:=trunc(Now);
dtpDateEnd.DateTime:=trunc(Now)+1;
seQuota.MinValue:=0;
seQuota.MaxValue:=MAX_INTEGER;
SetMultiLineCaption(BBcancel,'Не'+crlf+'изменять');
end;

procedure T_H2Interval.CallCheckData(Sender: TObject);
begin
  CheckData;
end;

procedure T_H2Interval.CBIntervalChange(Sender: TObject);
begin
  CheckData;
end;

end.
