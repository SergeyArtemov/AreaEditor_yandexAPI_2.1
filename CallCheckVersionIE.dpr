program CallCheckVersionIE;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FnCommon in 'D:\Projects_Common\FnCommon.pas';

begin
  try
    CallCheckVersionIE;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
