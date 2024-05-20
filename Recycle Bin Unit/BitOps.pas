unit BitOps;

(*************************************************************

    BitOps.pas
    Bit- Byte- and Nibbleoperations
    64 Bit Edition; Rev 05 July 2010

    (C) 2010 ViaThinkSoft [www.viathinksoft.com]
    Developed by Daniel Marschall [www.daniel-marschall.de]

*************************************************************)

interface

uses
  SysUtils;

// * TYPES *

type
  Nibble = 0..127;
  THexNibble = $0..$F;
  T4BitPos = 0..3;
  T8BitPos = 0..7;
  T16BitPos = 0..15;
  T32BitPos = 0..31;
  T64BitPos = 0..63;

  // Maximum amount of bytes in the biggest data type (int64)
  TBytePos = 0..7;
  // Maximum amount of nibbles in the biggest data type (int64)
  THexNibblePos = 0..15;

  TBit = Boolean;
  THexNibbleBitArray = array[Low(T4BitPos)..High(T4BitPos)] of TBit;
  TByteBitArray = array[Low(T8BitPos)..High(T8BitPos)] of TBit;
  TBitString = type string;
  TByteBitString = type TBitString;
  THexNibbleBitString = type TBitString;

// ******************
// * BYTE FUNCTIONS *
// ******************

// Build a byte.
// Either you combine two nibbles...
function BuildByte(AUpperNibble, ALowerNibble: THexNibble): Byte; overload;
// ...or you define an array of 8 bits.
function BuildByte(ABitArray: TByteBitArray): Byte; overload;
// ...or you define a bitstring (e.g. '00011100')
function BuildByte(ABits: TByteBitString): Byte; overload;
// ...or you define the bits as parameters
function BuildByte(ABit1, ABit2, ABit3, ABit4, ABit5, ABit6, ABit7,
  ABit8: TBit): Byte; overload;

// Converts a byte into a array of 8 bits
function GetByteBitArray(AByte: Byte): TByteBitArray;

// Getting and setting the lower nibble of a byte.
function GetLowerNibble(AByte: Byte): THexNibble;
function SetLowerNibble(AByte: Byte; ANewNibble: THexNibble): Byte;

// Getting and setting the upper nibble of a byte.
function GetUpperNibble(AByte: Byte): THexNibble;
function SetUpperNibble(AByte: Byte; ANewNibble: THexNibble): Byte;

// Interchanges upper and lower Nibble in a byte
function InterchangeNibbles(AByte: Byte): Byte;

// Creates an 8-bit-array from a 8-bit-string
// Throws EBitStringTooLong and EBitStringInvalidCharacter
function ByteBitArrayFromBitString(const ABits: TByteBitString):
  TByteBitArray;

// Getting and setting of a bit in a byte
function GetByteBit(AByte: Byte; ABitPos: T8BitPos): TBit;
function SetByteBit(AByte: Byte; ABitPos: T8BitPos; ANewBit: TBit): Byte;

// Getting and setting of a bit in a AnsiChar
function GetAnsiCharBit(AChar: AnsiChar; ABitPos: T8BitPos): TBit;
function SetAnsiCharBit(AChar: AnsiChar; ABitPos: T8BitPos; ANewBit: TBit): Byte;

// Logical operations for the 8 bit arrays.
function ByteBitArrayShr(ABitArray: TByteBitArray;
  AVal: Longword): TByteBitArray;
function ByteBitArrayShl(ABitArray: TByteBitArray;
  AVal: Longword): TByteBitArray;
function ByteBitArrayAnd(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
function ByteBitArrayOr(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
function ByteBitArrayXor(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
function ByteBitArrayNot(ABitArray: TByteBitArray): TByteBitArray;

// Inverse the bits of a byte
function InverseByteBits(x: Byte): Byte;

// Reverses the bit sequence of a byte
function ReverseByteBitSequence(AByte: Byte): Byte;

// ********************
// * NIBBLE FUNCTIONS *
// ********************

// Build a Nibble.
// You can define an array of 4 bits.
function BuildNibble(ABitArray: THexNibbleBitArray): Nibble; overload;
// ...or you define a bitstring (e.g. '0001')
function BuildNibble(ABits: THexNibbleBitString): Nibble; overload;
// ...or you define the bits as parameters
function BuildNibble(ABit1, ABit2, ABit3, ABit4: TBit): Nibble; overload;

// Converts a nibble into a array of 4 bits
function GetNibbleBitArray(ANibble: Nibble): THexNibbleBitArray;

// Creates an 4-bit-array from a 4-bit-string
// Throws EBitStringTooLong and EBitStringInvalidCharacter
function NibbleBitArrayFromBitString(const ABits: THexNibbleBitString):
  THexNibbleBitArray;

// Getting and setting of a bit in a nibble
function GetNibbleBit(ANibble: Nibble; ABitPos: T4BitPos): TBit;
function SetNibbleBit(ANibble: Nibble; ABitPos: T4BitPos;
  ANewBit: TBit): Nibble;

// Logical operations for the 4 bit arrays.
function NibbleBitArrayShr(ABitArray: THexNibbleBitArray; AVal: Longword):
  THexNibbleBitArray;
function NibbleBitArrayShl(ABitArray: THexNibbleBitArray; AVal: Longword):
  THexNibbleBitArray;
function NibbleBitArrayAnd(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
function NibbleBitArrayOr(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
function NibbleBitArrayXor(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
function NibbleBitArrayNot(ABitArray: THexNibbleBitArray): THexNibbleBitArray;

// Inverse the bits of a nibble
function InverseNibbleBits(x: Nibble): Nibble;

// Reverses the bit sequence of a nibble
function ReverseNibbleBitSequence(ANibble: Nibble): Nibble;

// * EXCEPTIONS *

type
  EInvalidBitString = class(Exception);
  EBitStringTooLong = class(EInvalidBitString);
  EBitStringInvalidCharacter = class(EInvalidBitString);

// * CONSTANTS *

// Lookup tables to avoid calculation each time
const
  AllSetBitsBytes: array[TBytePos] of uint64 =
   ($00000000000000FF,
    $000000000000FFFF,
    $0000000000FFFFFF,
    $00000000FFFFFFFF,
    $000000FFFFFFFFFF,
    $0000FFFFFFFFFFFF,
    $00FFFFFFFFFFFFFF,
    $FFFFFFFFFFFFFFFF);

  AllSetBitsNibbles: array[THexNibblePos] of uint64 =
   ($000000000000000F,
    $00000000000000FF,
    $0000000000000FFF,
    $000000000000FFFF,
    $00000000000FFFFF,
    $0000000000FFFFFF,
    $000000000FFFFFFF,
    $00000000FFFFFFFF,
    $0000000FFFFFFFFF,
    $000000FFFFFFFFFF,
    $00000FFFFFFFFFFF,
    $0000FFFFFFFFFFFF,
    $000FFFFFFFFFFFFF,
    $00FFFFFFFFFFFFFF,
    $0FFFFFFFFFFFFFFF,
    $FFFFFFFFFFFFFFFF);

  AllSetBitsNibble: array[THexNibblePos] of uint64 =
   ($000000000000000F,
    $00000000000000F0,
    $0000000000000F00,
    $000000000000F000,
    $00000000000F0000,
    $0000000000F00000,
    $000000000F000000,
    $00000000F0000000,
    $0000000F00000000,
    $000000F000000000,
    $00000F0000000000,
    $0000F00000000000,
    $000F000000000000,
    $00F0000000000000,
    $0F00000000000000,
    $F000000000000000);

  // Deprecated function:
  // function GetSingleBit(ABit: T64BitPos): Int64;
  //
  // Gives you a 64 bit datatype which is representing the binary coding
  //
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000001,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000010,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000100,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001000,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00010000,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00100000,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01000000,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 10000000,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000001 00000000,
  // ...
  // 10000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000.
  //
  // Limitation because of the data type: 64 Bit
  //
  // For the GetByteBit() and SetByteBit functions we only need this array to
  // be max at $80 (128).
  // Manual calculation (not 64 bit useable) would be
  // result := Math.Floor(Math.Power(2, ABit));
  SingleBitArray: array[T64BitPos] of uint64 =
   ($0000000000000001, $0000000000000002, $0000000000000004, $0000000000000008,
    $0000000000000010, $0000000000000020, $0000000000000040, $0000000000000080,
    $0000000000000100, $0000000000000200, $0000000000000400, $0000000000000800,
    $0000000000001000, $0000000000002000, $0000000000004000, $0000000000008000,
    $0000000000010000, $0000000000020000, $0000000000040000, $0000000000080000,
    $0000000000100000, $0000000000200000, $0000000000400000, $0000000000800000,
    $0000000001000000, $0000000002000000, $0000000004000000, $0000000008000000,
    $0000000010000000, $0000000020000000, $0000000040000000, $0000000080000000,
    $0000000100000000, $0000000200000000, $0000000400000000, $0000000800000000,
    $0000001000000000, $0000002000000000, $0000004000000000, $0000008000000000,
    $0000010000000000, $0000020000000000, $0000040000000000, $0000080000000000,
    $0000100000000000, $0000200000000000, $0000400000000000, $0000800000000000,
    $0001000000000000, $0002000000000000, $0004000000000000, $0008000000000000,
    $0010000000000000, $0020000000000000, $0040000000000000, $0080000000000000,
    $0100000000000000, $0200000000000000, $0400000000000000, $0800000000000000,
    $1000000000000000, $2000000000000000, $4000000000000000, $8000000000000000);

  // Deprecated function:
  // function GetSingleBitDynamicInversed(ABit: T64BitPos): Int64;
  //
  // Gives you a 64 bit datatype which is representing the dynamic inversed
  // binary encoding. (Dynamic inversed means, that only the used bytes get
  // inverted, so this is NOT the same as "NOT GetSingleBit(ABit)"!)
  //
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11111110,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11111101,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11111011,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11110111,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11101111,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 11011111,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 10111111,
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01111111,
  // 00000000 00000000 00000000 00000000 00000000 00000000 11111110 11111111,
  // ...
  // 01111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111.
  //
  // Limitation because of the data type: 64 Bit
  //
  // Manual calculation (not 64 bit useable) would be
  // result := MathFloor(
  //   Math.Power(256, Math.Floor(ABit / 8)+1)-1 {***} -
  //   Math.Power(2, ABit));
  //
  // *** is the maximal value of the byte amount we were requesting.
  // Example:
  // If ABit in [ 0.. 7] => 1 Byte  used => (256^1-1) = $FF
  // If ABit in [ 8..15] => 2 Bytes used => (256^2-1) = $FF FF
  // If ABit in [16..23] => 3 Bytes used => (256^3-1) = $FF FF FF
  // If ABit in [24..31] => 4 Bytes used => (256^3-1) = $FF FF FF FF
  // ...
  SingleBitArrayDynamicInversed: array[T64BitPos] of uint64 =
   ($00000000000000FE, $00000000000000FD, $00000000000000FB, $00000000000000F7,
    $00000000000000EF, $00000000000000DF, $00000000000000BF, $000000000000007F,
    $000000000000FEFF, $000000000000FDFF, $000000000000FBFF, $000000000000F7FF,
    $000000000000EFFF, $000000000000DFFF, $000000000000BFFF, $0000000000007FFF,
    $0000000000FEFFFF, $0000000000FDFFFF, $0000000000FBFFFF, $0000000000F7FFFF,
    $0000000000EFFFFF, $0000000000DFFFFF, $0000000000BFFFFF, $00000000007FFFFF,
    $00000000FEFFFFFF, $00000000FDFFFFFF, $00000000FBFFFFFF, $00000000F7FFFFFF,
    $00000000EFFFFFFF, $00000000DFFFFFFF, $00000000BFFFFFFF, $000000007FFFFFFF,
    $000000FEFFFFFFFF, $000000FDFFFFFFFF, $000000FBFFFFFFFF, $000000F7FFFFFFFF,
    $000000EFFFFFFFFF, $000000DFFFFFFFFF, $000000BFFFFFFFFF, $0000007FFFFFFFFF,
    $0000FEFFFFFFFFFF, $0000FDFFFFFFFFFF, $0000FBFFFFFFFFFF, $0000F7FFFFFFFFFF,
    $0000EFFFFFFFFFFF, $0000DFFFFFFFFFFF, $0000BFFFFFFFFFFF, $00007FFFFFFFFFFF,
    $00FEFFFFFFFFFFFF, $00FDFFFFFFFFFFFF, $00FBFFFFFFFFFFFF, $00F7FFFFFFFFFFFF,
    $00EFFFFFFFFFFFFF, $00DFFFFFFFFFFFFF, $00BFFFFFFFFFFFFF, $007FFFFFFFFFFFFF,
    $FEFFFFFFFFFFFFFF, $FDFFFFFFFFFFFFFF, $FBFFFFFFFFFFFFFF, $F7FFFFFFFFFFFFFF,
    $EFFFFFFFFFFFFFFF, $DFFFFFFFFFFFFFFF, $BFFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF);

  // Gives you a 64 bit datatype which is representing the inversed
  // binary encoding.
  //
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111110,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111101,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111011,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11110111,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11101111,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11011111,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 10111111,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111111 01111111,
  // 11111111 11111111 11111111 11111111 11111111 11111111 11111110 11111111,
  // ...
  // 01111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111.
  //
  // Limitation because of the data type: 64 Bit
  //
  // Manual calculation (not 64 bit useable) would be
  // result := NOT GetSingleBit(ABit)
  //
  SingleBitArrayInversed: array[T64BitPos] of uint64 =
   ($FFFFFFFFFFFFFFFE, $FFFFFFFFFFFFFFFD, $FFFFFFFFFFFFFFFB, $FFFFFFFFFFFFFFF7,
    $FFFFFFFFFFFFFFEF, $FFFFFFFFFFFFFFDF, $FFFFFFFFFFFFFFBF, $FFFFFFFFFFFFFF7F,
    $FFFFFFFFFFFFFEFF, $FFFFFFFFFFFFFDFF, $FFFFFFFFFFFFFBFF, $FFFFFFFFFFFFF7FF,
    $FFFFFFFFFFFFEFFF, $FFFFFFFFFFFFDFFF, $FFFFFFFFFFFFBFFF, $FFFFFFFFFFFF7FFF,
    $FFFFFFFFFFFEFFFF, $FFFFFFFFFFFDFFFF, $FFFFFFFFFFFBFFFF, $FFFFFFFFFFF7FFFF,
    $FFFFFFFFFFEFFFFF, $FFFFFFFFFFDFFFFF, $FFFFFFFFFFBFFFFF, $FFFFFFFFFF7FFFFF,
    $FFFFFFFFFEFFFFFF, $FFFFFFFFFDFFFFFF, $FFFFFFFFFBFFFFFF, $FFFFFFFFF7FFFFFF,
    $FFFFFFFFEFFFFFFF, $FFFFFFFFDFFFFFFF, $FFFFFFFFBFFFFFFF, $FFFFFFFF7FFFFFFF,
    $FFFFFFFEFFFFFFFF, $FFFFFFFDFFFFFFFF, $FFFFFFFBFFFFFFFF, $FFFFFFF7FFFFFFFF,
    $FFFFFFEFFFFFFFFF, $FFFFFFDFFFFFFFFF, $FFFFFFBFFFFFFFFF, $FFFFFF7FFFFFFFFF,
    $FFFFFEFFFFFFFFFF, $FFFFFDFFFFFFFFFF, $FFFFFBFFFFFFFFFF, $FFFFF7FFFFFFFFFF,
    $FFFFEFFFFFFFFFFF, $FFFFDFFFFFFFFFFF, $FFFFBFFFFFFFFFFF, $FFFF7FFFFFFFFFFF,
    $FFFEFFFFFFFFFFFF, $FFFDFFFFFFFFFFFF, $FFFBFFFFFFFFFFFF, $FFF7FFFFFFFFFFFF,
    $FFEFFFFFFFFFFFFF, $FFDFFFFFFFFFFFFF, $FFBFFFFFFFFFFFFF, $FF7FFFFFFFFFFFFF,
    $FEFFFFFFFFFFFFFF, $FDFFFFFFFFFFFFFF, $FBFFFFFFFFFFFFFF, $F7FFFFFFFFFFFFFF,
    $EFFFFFFFFFFFFFFF, $DFFFFFFFFFFFFFFF, $BFFFFFFFFFFFFFFF, $7FFFFFFFFFFFFFFF);

implementation

resourcestring
  LngEBitStringInvalidCharacter = 'The bitstring "%s" contains a invalid ' +
    'character. Unexpected character "%s" at position "%d".';
  LngEBitStringTooLong = 'The bitstring "%s" is too long. Expected: %d byte.';

function GetByteBitArray(AByte: Byte): TByteBitArray;
var
  i: T8BitPos;
begin
  for i := Low(T8BitPos) to High(T8BitPos) do
  begin
    // result[i] := GetByteBit(AByte, i);
    result[i] := AByte and SingleBitArray[i] = SingleBitArray[i];
  end;
end;

function GetNibbleBitArray(ANibble: Nibble): THexNibbleBitArray;
var
  i: T4BitPos;
begin
  for i := Low(T4BitPos) to High(T4BitPos) do
  begin
    // result[i] := GetNibbleBit(ANibble, i);
    result[i] := ANibble and SingleBitArray[i] = SingleBitArray[i];
  end;
end;

function BuildByte(AUpperNibble, ALowerNibble: THexNibble): Byte;
begin
  // result := $10 * AUpperNibble + ALowerNibble;
  result := (AUpperNibble shl 4) + ALowerNibble;
end;

function BuildByte(ABitArray: TByteBitArray): Byte;
var
  i: T8BitPos;
begin
  result := 0;
  for i := Low(T8BitPos) to High(T8BitPos) do
  begin
    // SetByteBit(result, i, ABitArray[i]);

    if not ABitArray[i] then
      result := result and SingleBitArrayDynamicInversed[i]
    else
      result := result or SingleBitArray[i];
  end;
end;

function BuildByte(ABits: TByteBitString): Byte;
begin
  result := BuildByte(ByteBitArrayFromBitString(ABits));
end;

function BuildByte(ABit1, ABit2, ABit3, ABit4, ABit5, ABit6, ABit7,
  ABit8: TBit): Byte; overload;
var
  ba: TByteBitArray;
begin
  ba[0] := ABit1;
  ba[1] := ABit2;
  ba[2] := ABit3;
  ba[3] := ABit4;
  ba[4] := ABit5;
  ba[5] := ABit6;
  ba[6] := ABit7;
  ba[7] := ABit8;
  result := BuildByte(ba);
end;

function ByteBitArrayFromBitString(const ABits: TByteBitString): TByteBitArray;
var
  i: integer;
begin
  if Length(ABits) <> 8 then
  begin
    raise EBitStringTooLong.CreateFmt(LngEBitStringTooLong, [ABits, 8]);
    exit;
  end;

  for i := 1 to Length(ABits) do
  begin
    case ABits[i] of
      '0': result[i-1] := false;
      '1': result[i-1] := true;
    else
      raise EBitStringInvalidCharacter.CreateFmt(LngEBitStringInvalidCharacter,
        [ABits, ABits[i], i]);
    end;
  end;
end;

function NibbleBitArrayFromBitString(const ABits: THexNibbleBitString):
  THexNibbleBitArray;
var
  i: integer;
begin
  if Length(ABits) <> 4 then
  begin
    raise EBitStringTooLong.CreateFmt(LngEBitStringTooLong, [ABits, 4]);
    exit;
  end;

  for i := 1 to Length(ABits) do
  begin
    case ABits[i] of
      '0': result[i-1] := false;
      '1': result[i-1] := true;
    else
      raise EBitStringInvalidCharacter.CreateFmt(LngEBitStringInvalidCharacter,
        [ABits, ABits[i], i]);
    end;
  end;
end;

function BuildNibble(ABit1, ABit2, ABit3, ABit4: TBit): Nibble;
var
  ba: THexNibbleBitArray;
begin
  ba[0] := ABit1;
  ba[1] := ABit2;
  ba[2] := ABit3;
  ba[3] := ABit4;
  result := BuildNibble(ba);
end;

function BuildNibble(ABitArray: THexNibbleBitArray): Nibble;
var
  i: T4BitPos;
begin
  result := 0;
  for i := Low(T4BitPos) to High(T4BitPos) do
  begin
    // SetNibbleBit(result, i, ABitArray[i]);

    if not ABitArray[i] then
      result := result and SingleBitArrayDynamicInversed[i]
    else
      result := result or SingleBitArray[i];
  end;
end;

function BuildNibble(ABits: THexNibbleBitString): Nibble;
begin
  result := BuildNibble(NibbleBitArrayFromBitString(ABits));
end;

function GetLowerNibble(AByte: Byte): THexNibble;
begin
  result := AByte and AllSetBitsNibble[0];
end;

function SetLowerNibble(AByte: Byte; ANewNibble: THexNibble): Byte;
begin
  // result := BuildByte(GetUpperNibble(AByte), ANewNibble);
  // result := $10 * (AByte and AllSetBitsNibble[1] shr 4) + ANewNibble;
  // result := (AByte and AllSetBitsNibble[1] shr 4) shl 4 + ANewNibble;

  // Optimized: "shr 4 shl 4" removed
  result := (AByte and AllSetBitsNibble[1]) + ANewNibble;
end;

function GetUpperNibble(AByte: Byte): THexNibble;
begin
  result := AByte and AllSetBitsNibble[1] shr 4;
end;

function SetUpperNibble(AByte: Byte; ANewNibble: THexNibble): Byte;
begin
  // result := BuildByte(ANewNibble, GetLowerNibble(AByte));
  // result := ($10 * ANewNibble) + (AByte and AllSetBitsNibble[0]);
  result := (ANewNibble shl 4) + (AByte and AllSetBitsNibble[0]);
end;

function GetByteBit(AByte: Byte; ABitPos: T8BitPos): TBit;
begin
  // result := AByte and SingleBitArray[ABitPos] shr ABitPos = 1;
  // result := AByte and Math.Power(2, ABitPos) shr ABitPos = 1;
  // result := AByte and SingleBitArray[ABitPos] shr ABitPos = 1;
  result := AByte and SingleBitArray[ABitPos] = SingleBitArray[ABitPos];
end;

function SetByteBit(AByte: Byte; ABitPos: T8BitPos; ANewBit: TBit): Byte;
begin
  if not ANewBit then
  begin
    // Set a bit to 0.
    // Example: abcdefgh AND 11111011 = abcde0gh

    // result := AByte and (AllSetBitsBytes[0] - SingleBitArray[ABitPos]);
    // result := AByte and (AllSetBitsBytes[0] - Math.Power(2, ABitPos));
    result := AByte and SingleBitArrayDynamicInversed[ABitPos]
  end
  else
  begin
    // Set a bit to 1.
    // Example: abcdefgh OR 00000100 = abcde1gh

    // result := AByte or Math.Power(2, ABitPos);
    result := AByte or SingleBitArray[ABitPos];
  end;
end;

function GetAnsiCharBit(AChar: AnsiChar; ABitPos: T8BitPos): TBit;
begin
  result := GetByteBit(Ord(AChar), ABitPos);
end;

function SetAnsiCharBit(AChar: AnsiChar; ABitPos: T8BitPos; ANewBit: TBit): Byte;
begin
  result := SetByteBit(Ord(AChar), ABitPos, ANewBit);
end;

function GetNibbleBit(ANibble: Nibble; ABitPos: T4BitPos): TBit;
begin
  result := GetByteBit(ANibble, ABitPos);
end;

function SetNibbleBit(ANibble: Nibble; ABitPos: T4BitPos;
  ANewBit: TBit): Nibble;
begin
  result := SetByteBit(ANibble, ABitPos, ANewBit);
end;

function ByteBitArrayShr(ABitArray: TByteBitArray;
  AVal: Longword): TByteBitArray;
var
  b: Byte;
begin
  b := BuildByte(ABitArray);
  result := GetByteBitArray(b shr AVal);
end;

function ByteBitArrayShl(ABitArray: TByteBitArray;
  AVal: Longword): TByteBitArray;
var
  b: Byte;
begin
  b := BuildByte(ABitArray);
  result := GetByteBitArray(b shl AVal);
end;

function ByteBitArrayAnd(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
var
  b, b2: Byte;
begin
  b  := BuildByte(ABitArray);
  b2 := BuildByte(ABitArray2);
  result := GetByteBitArray(b and b2);
end;

function ByteBitArrayOr(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
var
  b, b2: Byte;
begin
  b  := BuildByte(ABitArray);
  b2 := BuildByte(ABitArray2);
  result := GetByteBitArray(b or b2);
end;

function ByteBitArrayXor(ABitArray, ABitArray2: TByteBitArray): TByteBitArray;
var
  b, b2: Byte;
begin
  b  := BuildByte(ABitArray);
  b2 := BuildByte(ABitArray2);
  result := GetByteBitArray(b xor b2);
end;

function ByteBitArrayNot(ABitArray: TByteBitArray): TByteBitArray;
var
  b: Byte;
begin
  b := BuildByte(ABitArray);
  result := GetByteBitArray(not b);
end;

function NibbleBitArrayShr(ABitArray: THexNibbleBitArray; AVal: Longword):
  THexNibbleBitArray;
var
  b: Nibble;
begin
  b := BuildNibble(ABitArray);
  result := GetNibbleBitArray(b shr AVal);
end;

function NibbleBitArrayShl(ABitArray: THexNibbleBitArray; AVal: Longword):
  THexNibbleBitArray;
var
  b: Nibble;
begin
  b := BuildNibble(ABitArray);
  result := GetNibbleBitArray(b shl AVal);
end;

function NibbleBitArrayAnd(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
var
  b, b2: Nibble;
begin
  b  := BuildNibble(ABitArray);
  b2 := BuildNibble(ABitArray2);
  result := GetNibbleBitArray(b and b2);
end;

function NibbleBitArrayOr(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
var
  b, b2: Nibble;
begin
  b  := BuildNibble(ABitArray);
  b2 := BuildNibble(ABitArray2);
  result := GetNibbleBitArray(b or b2);
end;

function NibbleBitArrayXor(ABitArray, ABitArray2: THexNibbleBitArray):
  THexNibbleBitArray;
var
  b, b2: Nibble;
begin
  b  := BuildNibble(ABitArray);
  b2 := BuildNibble(ABitArray2);
  result := GetNibbleBitArray(b xor b2);
end;

function NibbleBitArrayNot(ABitArray: THexNibbleBitArray): THexNibbleBitArray;
var
  b: Nibble;
begin
  b := BuildNibble(ABitArray);
  result := GetNibbleBitArray(not b);
end;

function InverseByteBits(x: Byte): Byte;
begin
  //     10110001
  // xor 11111111
  //   = 01001110
  result := x xor AllSetBitsBytes[0];
end;

function InverseNibbleBits(x: Nibble): Nibble;
begin
  //         0001
  // xor     1111
  //   =     1110
  result := x xor AllSetBitsNibbles[0];
end;

function InterchangeNibbles(AByte: Byte): Byte;
begin
  // result := BuildByte(GetLowerNibble(AByte), GetUpperNibble(AByte));
  result := (AByte and AllSetBitsNibble[0] shl 4) +
            (AByte and AllSetBitsNibble[1] shr 4)
end;

function ReverseByteBitSequence(AByte: Byte): Byte;
var
  ba: TByteBitArray;
begin
  ba := GetByteBitArray(AByte);
  result := BuildByte(ba[7], ba[6], ba[5], ba[4], ba[3], ba[2], ba[1], ba[0]);
end;

function ReverseNibbleBitSequence(ANibble: Nibble): Nibble;
var
  ba: THexNibbleBitArray;
begin
  ba := GetNibbleBitArray(ANibble);
  result := BuildNibble(ba[3], ba[2], ba[1], ba[0]);
end;

end.
