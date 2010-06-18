program BitBucketReader;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Functions in 'Functions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
