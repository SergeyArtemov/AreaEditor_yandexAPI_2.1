unit U_AreaProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  AppPrms, AreaEditor_Types, FnADODB, FnCommon, Frm_Interval, ExtCtrls, StdCtrls, Buttons, ImgList;

type
  T_AreaProps = class(TForm)
    Lab_AreaName: TLabel;
    Ed_AreaName: TEdit;
    Label2: TLabel;
    CB_AreaParent: TComboBox;
    Label3: TLabel;
    Pan_RGBLine: TPanel;
    Pan_RGBFill: TPanel;
    Label1: TLabel;
    CB_Level: TComboBox;
    SpB_AreaProps_Info: TSpeedButton;
    BB_AreaProps_Cancel: TBitBtn;
    BB_AreaProps_Ok: TBitBtn;
    LabT_AreaProps_Info: TLabel;
    Lab_AreaID: TLabel;
    Lab_Inp: TLabel;
    Lab_ParentAreaID: TLabel;
    IL: TImageList;
    procedure CB_AreaParentChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpB_AreaProps_InfoClick(Sender: TObject);
    procedure CB_LevelChange(Sender: TObject);
  private
    _Area : TAreaItem;
    dopVisible  : boolean;
    maxBottom   : integer;
    procedure FillControls;
  public
    constructor CreateWidthParams(AOwner : TComponent; const aArea : TAreaItem);
    destructor Destroy; override;
    procedure FillResult(var aArea : TAreaItem);
  end;

var
  _AreaProps: T_AreaProps;

implementation

uses U_Main;



{$R *.dfm}

(**************************************************************)
procedure T_AreaProps.FillControls;
var
 cnt    : integer;
 tmp    : integer;
 ind    : integer;
 strl   : TStringList;
// ChB  : TCheckBox;
// dt   : TDateTime;
 ifl    : integer;
 arName : string;
begin
try
if (_Area.aID=0) and (_Area.aName='')
   then _Area.aName:='Новая область' ;
Caption:=Format('Описание области [%s]',[_Area.aName]);

Lab_AreaID.Tag:=_Area.aID;
Lab_AreaID.Caption:=Format('ID : %d',[Lab_AreaID.Tag]);
Ed_AreaName.Text:=string(_Area.aName);
ind:=-1;
if (_Area.aLevel>CB_Level.Items.Count-1) or (_Area.aLevel<0)
   then CB_Level.ItemIndex:=CB_Level.Items.Count-1
   else CB_Level.ItemIndex:=_Area.aLevel;





strl := TStringList.Create;
FullAreaList.GetSortedByName(strl);
//CB_AreaParent.Items.BeginUpdate;
try
CB_AreaParent.Items.Clear;
for cnt:=0 to strl.Count-1
  do with PAreaItem(strl.Objects[cnt])^ do
    if (1=1) // -- до условия отбора (типа проверка на закольцовку? и т.д.)
       and ((_Area.aLevel in [4,5,6]) and (aLevel=3)) or ((_Area.aLevel<=3) and (aLevel<_Area.aLevel))
       and (aID<>_Area.aID)
       then begin
       ifl:=FullAreaList.GetAreaDataById(aID, arname, tmp);
       tmp:=CB_AreaParent.Items.AddObject(string(FullAreaList.Items[ifl].aName),TObject(@FullAreaList.Items[ifl]));
       if _Area.aParentID = FullAreaList.Items[ifl].aID
          then ind:=tmp;
       end;
finally
if ind>-1
   then CB_AreaParent.ItemIndex:=ind;
//CB_AreaParent.Items.EndUpdate;
FreeStringList(strl);
end;
Pan_RGBLine.Color:=HTMLRGBtoColor(_Area.aRGBLine);
Pan_RGBLine.Font.Color:=ContrastColor(Pan_RGBLine.Color);
Pan_RGBFill.Color:=HTMLRGBtoColor(_Area.aRGBFill);
Pan_RGBFill.Font.Color:=ContrastColor(Pan_RGBFill.Color);
//for cnt:=1 to 7
//  do begin
//  ChB:=GB_Area_obsolete.FindChildControl(Format('ChB_Area_Day%d',[cnt])) as TCheckBox;
//  if Assigned(ChB) then ChB.Checked:=(Area.aDays[cnt]='1');
//  end;

//
//
//if Area.aRecordState>0
//   then ind:=FullAreaList.FillItem(Area);
//if ind<0
//   then (**);
//if Area.aLevel>=4 (*ATTENTION*) (*LEVEL-INTERVAL*)
//   then begin
//   ind:=AreaIntervalList.LoadFromDB(Area.aID);
//   DrGr_AreaIntervalList.RowCount:=1+ind+integer(ind=0);
//   if ind>0
//      then begin
//      ind:=-1;
//      dt:=Date+daysNoEditInterval+1;
//      for cnt:=High(AreaIntervalList.Items) downto 0
//        do if dt <= AreaIntervalList.Items[cnt].aiDate
//              then begin
//              SetVisibleRow3(DrGr_AreaIntervalList,cnt+1);
//              ind:=cnt;
//              Break;
//              end;
//      case ind of
//      -1 : (*новый добавлять нужно*) ;
//       else (*редактировать будем*);
//      end;
//      end;
//   end;
except
  on E : Exception do LogErrorMessage('T_AreaProps.FillControls',E,[]);
end
end;

(**************************************************************)






constructor T_AreaProps.CreateWidthParams(AOwner : TComponent; const aArea : TAreaItem);
var
 cnt  : integer;
 _th  : integer;
begin
inherited Create(AOwner);
maxBottom:=0;
for cnt:=0 to ControlCount-1
do begin
_th:= Controls[cnt].Top + Controls[cnt].Height;
if _th>maxBottom
   then maxBottom:=_th;
end;
System.Move(aArea, _Area, SizeOf(TAreaItem));
FillControls;
SetGlyph(SpB_AreaProps_Info,IL,integer(dopVisible));
if _Area.aID=0
   then BB_AreaProps_Ok.Caption:='Создать'
   else BB_AreaProps_Ok.Caption:='Сохранить';
end;

destructor T_AreaProps.Destroy;
begin
_Area.Clear;
inherited Destroy;
end;

procedure T_AreaProps.FillResult(var aArea : TAreaItem);
begin
try
aArea.LoadFromSource(_Area);
except
on E : Exception do LogErrorMessage('T_AreaProps.FillResult',E,[]);
end;
end;


(******************************************************************)

procedure T_AreaProps.FormShow(Sender: TObject);
begin
ClientHeight:=SpB_AreaProps_Info.Top+SpB_AreaProps_Info.Height+4;
LabT_AreaProps_Info.Caption:='Подробнее';
end;

procedure T_AreaProps.SpB_AreaProps_InfoClick(Sender: TObject);
begin
dopVisible:=not dopVisible;
Constraints.MinHeight:=0;
Constraints.MaxHeight:=0;
try
if dopVisible
   then begin
   ClientHeight:=maxBottom+4+GetSystemMetrics(SM_CYFRAME);
   LabT_AreaProps_Info.Caption:='Меньше сведений';
   end
   else begin
   ClientHeight:=SpB_AreaProps_Info.Top+SpB_AreaProps_Info.Height+4+GetSystemMetrics(SM_CYFRAME);
   LabT_AreaProps_Info.Caption:='Подробнее';
   end;
finally
SetGlyph(SpB_AreaProps_Info,IL,integer(dopVisible));
Constraints.MinHeight:=Height;
Constraints.MaxHeight:=Height;
end;
end;



procedure T_AreaProps.CB_LevelChange(Sender: TObject);
var
 ind : integer;
begin
_Area.alevel:=CB_Level.ItemIndex;
ind:=_Main.FillParentAreaList(_Area, CB_AreaParent);
if ind<0 then ;
end;

procedure T_AreaProps.CB_AreaParentChange(Sender: TObject);
var
 cont   : array of TFloatPoint;
 ind    : integer;
 ParID  : integer;
 _nm    : string;
 _rn    : integer;
 res    : integer;
 pts    : TArrayOfFloatPoint;
begin
Lab_Inp.Caption:='Вхождение точек : ?%';
Lab_Inp.Hint:='';
CB_AreaParent.Enabled:=false;
Screen.Cursor:=crAppStart;
try
if CB_AreaParent.ItemIndex=-1 then Exit;
ParID:=PAreaItem(CB_AreaParent.Items.Objects[CB_AreaParent.ItemIndex])^.aID;
Lab_Inp.Hint:=Format('ID владельца : %d',[ParID]);
Lab_ParentAreaID.Caption:=Lab_Inp.Hint;
if (_Area.aID=0) or (Length(_Area.LatLng)=0) // -- считать нечего
   then Exit;
ind:=FullAreaList.GetAreaDataById(ParID,_nm,_rn);
if ind<0 then Exit;
Setlength(cont, Length(FullAreaList.Items[ind].LatLng));
if Length(cont)=0 then Exit;
System.Move(FullAreaList.Items[ind].LatLng[0], cont[0], Length(FullAreaList.Items[ind].LatLng)*SizeOf(TFloatPoint));
res:=GetInnerPoints(_Area.LatLng, cont, pts);
Lab_Inp.Caption:=Format('Вхождение точек : %3.2f%%',[res/Length(_Area.LatLng)*100]);
Lab_Inp.Hint:=Lab_Inp.Hint+Format(crlf+'по кол-ву : %d из %d',[res,Length(_Area.LatLng)]);
finally
Lab_Inp.ShowHint:=true;
CB_AreaParent.Enabled:=true;
Screen.Cursor:=crDefault;
end;
Lab_ParentAreaID.Tag:=ParID;
Lab_ParentAreaID.Caption:=Format('ID владельца : %d',[Lab_ParentAreaID.Tag]);
(*ATTENTION*)
Exit;
//if Length(pts)>0
//   then begin
//   _nm:=GetPointsForDisplay(pts);
//   ExecuteScript(WB,'ClearMarkerList()');
//   _sleep(std_JS_Wait);
//   ExecuteScript(WB, Format('SetArrayOfMarker(%s)',[AnsiQuotedStr(_nm,'"')]));
//   end;
end;

end.
