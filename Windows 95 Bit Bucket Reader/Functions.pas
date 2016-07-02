unit Functions;

(*
    Some Delphi Functions
    by Daniel Marschall
*)

interface

uses
  SysUtils, Registry;

function RegistryReadDump(AReg: TRegistry; AName: string): string;
function BinaryStringToHexDump(ABinaryString: string): string;

type
  TNibble = $0..$F;

function LowerNibble(B: Byte): TNibble;
function UpperNibble(B: Byte): TNibble;
function MakeByte(UpperNibble, LowerNibble: TNibble): Byte;

type
  TBitPos = 0..7;

function GetBit(B: Byte; BitPos: TBitPos): boolean; overload;
function GetBit(B: Char; BitPos: TBitPos): boolean; overload;

implementation

function RegistryReadDump(AReg: TRegistry; AName: string): string;
const
  // Win2000 RegEdit has set the max input length of a REG_BINARY to $3FFF.
  // Probably its the longest possible binary string and not just a GUI limit.
  BufMax = $3FFF;
var
  buf: array[0..BufMax] of byte;
  i: integer;
  realsize: integer;
begin
  realsize := AReg.ReadBinaryData(AName, buf, SizeOf(buf));

  for i := 0 to realsize-1 do
  begin
    result := result + chr(buf[i]);
  end;
end;

function BinaryStringToHexDump(ABinaryString: string): string;
var
  i: integer;
begin
  for i := 1 to Length(ABinaryString) do
  begin
    result := result + IntToHex(Ord(ABinaryString[i]), 2);
    if i <> Length(ABinaryString) then
      result := result + ' ';
  end;
end;

function LowerNibble(B: Byte): TNibble;
begin
  result := B and 15 {00001111};
end;

function UpperNibble(B: Byte): TNibble;
begin
  result := B and 240 {11110000};
end;

function MakeByte(UpperNibble, LowerNibble: TNibble): Byte;
begin
  result := LowerNibble + UpperNibble * $10;
end;

function GetBit(B: Byte; BitPos: TBitPos): boolean;
var
  p: byte;
begin
  p := 1 shl BitPos; // 2 ^ BitPos
  result := B and p = p;
end;

function GetBit(B: Char; BitPos: TBitPos): boolean;
begin
  result := GetBit(Ord(B), BitPos);
end;

end.
