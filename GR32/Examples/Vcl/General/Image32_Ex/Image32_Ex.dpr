program Image32_Ex;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {FormImage32Example};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormImage32Example, FormImage32Example);
  Application.Run;
end.
