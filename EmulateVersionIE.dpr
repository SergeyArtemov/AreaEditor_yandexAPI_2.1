program EmulateVersionIE;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Registry;

procedure CheckVersionIE(aRoot: HKEY; const aKey : string; aVers : integer); overload;
var
 errStep : string;
 RegKey  : TRegistry;
 app     : string;
begin
errStep:='';
try
RegKey:=TRegistry.Create;
try
RegKey.RootKey:=aRoot;
if not RegKey.KeyExists(aKey)
   then if not RegKey.CreateKey(aKey)
           then begin
           errStep:='No Key exists : '+aKey;
           Exit;
           end;
if not RegKey.OpenKey(aKey, false)
   then begin
   errStep:='Can not open Key for write : '+aKey;
   Exit;
   end;
app:=ExtractFileName(ParamStr(0));
if not RegKey.ValueExists(app)
   then RegKey.WriteInteger(app,aVers);
RegKey.CloseKey;
finally
RegKey.Free;
end;
except
 on E : Exception do ;
end;
end;

procedure CallCheckVersionIE;
type
 TEIEmulItem = record
   Root : hkey;
   Key  : string[255];
 end;

const
 BaseVers = 9999;
 //; Vers:11001
 Keys : array[0..2] of TEIEmulItem = (
 (Root:HKEY_CURRENT_USER ; Key: '\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION' ),
 (Root:HKEY_LOCAL_MACHINE; Key: '\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION'),
 (Root:HKEY_LOCAL_MACHINE; Key: '\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION')
 );
var
 cnt : integer;
begin
try
for cnt:=Low(Keys) to High(Keys) do with Keys[cnt] do CheckVersionIE(Root, string(Key), BaseVers);
except
 on E : Exception do;
end;
end;

begin
  try
    CallCheckVersionIE;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
