program BitBucketReader;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Functions in 'Functions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
