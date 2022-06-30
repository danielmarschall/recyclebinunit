program Recycler;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  RecyclerFunctions in 'RecyclerFunctions.pas';

{$R *.res}

{$R XPManifest.res}

begin
  Application.Initialize;
  Application.Title := 'Recycle Bin Example';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
