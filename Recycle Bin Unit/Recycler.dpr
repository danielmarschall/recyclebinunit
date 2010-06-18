program Recycler;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  RecyclerFunctions in 'RecyclerFunctions.pas',
  BitOps in '..\Units\BitOps.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Recycle Bin Example';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
