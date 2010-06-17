unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, registry, ExtCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    Memo2: TMemo;
    Splitter1: TSplitter;
    procedure Timer1Timer(Sender: TObject);
  private
    procedure GetDump;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Functions;

procedure TForm1.GetDump;
var
  reg: tregistry;
  i: integer;
  oldr, r: string;
  lw: char;
begin
  reg := tregistry.create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      oldr := memo1.text;

      if reg.ValueExists('PurgeInfo') then
        r := 'PurgeInfo = ' + BinaryStringToHexDump(RegistryReadDump(reg, 'PurgeInfo'))
      else
        r := 'No PurgeInfo';

      for lw := 'A' to 'Z' do
      begin
        if reg.ValueExists(lw) then
        begin
          r := r + #13#10#13#10 + lw + ' = ' + BinaryStringToHexDump(RegistryReadDump(reg, lw));
        end;
      end;

      if oldr <> '' then
      begin
        for i := 1 to length(oldr) do
        begin
          if oldr[i] <> r[i] then
            memo2.Lines.Add(inttostr(i)+': '+oldr[i]+' -> '+r[i]);
        end;
      end;

      memo1.Text := r;
      
      reg.CloseKey;
    end;
  finally
    reg.free;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  GetDump;
end;

end.
