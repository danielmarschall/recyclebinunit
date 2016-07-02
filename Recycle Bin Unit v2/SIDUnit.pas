unit SIDUnit;

// This unit helps you to find out your SID.
// It is compatible with all Windows versions down to Win95!
// (On Win9x, the result string is empty, of course)

interface

uses
  Windows, SysUtils;

type
  EAPICallError = class(Exception);

function GetMySID: string;

implementation

// **********************************************************
// INTERNALLY USED FUNCTIONS
// **********************************************************

// http://www.delphipraxis.net/post471470.html
function _getAccountSid(const Server, User: WideString; var Sid: PSID): DWORD;
var
  dwDomainSize, dwSidSize: DWord;
  R: LongBool;
  wDomain: WideString;
  Use: DWord;
begin
  Result := 0;
  SetLastError(0);
  dwSidSize := 0;
  dwDomainSize := 0;
  R := LookupAccountNameW(PWideChar(Server), PWideChar(User), nil, dwSidSize,
       nil, dwDomainSize, Use);
  if (not R) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
  begin
    SetLength(wDomain, dwDomainSize);
    Sid := GetMemory(dwSidSize);
    R := LookupAccountNameW(PWideChar(Server), PWideChar(User), Sid,
         dwSidSize, PWideChar(wDomain), dwDomainSize, Use);
    if not R then
    begin
      FreeMemory(Sid);
      Sid := nil;
    end;
  end
  else
    Result := GetLastError;
end;

const
  UNLEN = 256; // lmcons.h

// Template:
// http://www.latiumsoftware.com/en/pascal/0014.php
function _getLoginNameW: widestring;
var
  Buffer: array[0..UNLEN] of widechar;
  Size: DWORD;
begin
  Size := SizeOf(Buffer);
  if GetUserNameW(Buffer, Size) then
    Result := Buffer
  else
    Result := 'User';
end;

function _ConvertSidToStringSidA(SID: PSID; var strSID: LPSTR): boolean;
type
  DllReg = function(SID: PSID; var StringSid: LPSTR): Boolean; stdcall;
var
  hDll: THandle;
  dr: DllReg;
begin
  result := false;
  hDll := LoadLibrary(advapi32);
  if hDll <> 0 then
  begin
    @dr := GetProcAddress(hDll, 'ConvertSidToStringSidA');

    if assigned(dr) then
    begin
      result := dr(SID, strSID);
    end;
  end;
end;

const
  winternl_lib = 'Ntdll.dll';

type
  USHORT = Word;
  PWSTR = PWidechar;
  PCWSTR = PWideChar;

   NTSTATUS = Longword;

  _UNICODE_STRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: PWSTR;
  end;
  UNICODE_STRING = _UNICODE_STRING;
  PUNICODE_STRING = ^UNICODE_STRING;

function _RtlConvertSidToUnicodeString(
  UnicodeString: PUNICODE_STRING;
  Sid: PSID;
  AllocateDestinationString: BOOLEAN): NTSTATUS; stdcall;
type
  DllReg = function(UnicodeString: PUNICODE_STRING;
  Sid: PSID;
  AllocateDestinationString: BOOLEAN): NTSTATUS; stdcall;
var
  hDll: THandle;
  dr: DllReg;
begin
  result := $FFFFFFFF;
  hDll := LoadLibrary(winternl_lib);
  if hDll = 0 then Exit;
  try
    @dr := GetProcAddress(hDll, 'RtlConvertSidToUnicodeString');
    if not Assigned(dr) then Exit;
    result := dr(UnicodeString, Sid, AllocateDestinationString);
  finally
    FreeLibrary(hDll);
  end;
end;

procedure _RtlFreeUnicodeString(UnicodeString: PUNICODE_STRING); stdcall;
type
  DllReg = procedure(UnicodeString: PUNICODE_STRING); stdcall;
var
  hDll: THandle;
  dr: DllReg;
begin
  hDll := LoadLibrary(winternl_lib);
  if hDll = 0 then Exit;
  try
    @dr := GetProcAddress(hDll, 'RtlFreeUnicodeString');
    if not Assigned(dr) then Exit;
    dr(UnicodeString);
  finally
    FreeLibrary(hDll);
  end;
end;

function _NT_SidToString(SID: PSID; var strSID: string): boolean;
var
  pus: PUNICODE_STRING;
  us: UNICODE_STRING;
begin
  pus := @us;
  result := _RtlConvertSidToUnicodeString(pus, SID, true) = 0;
  if not result then Exit;
  strSID := pus^.Buffer;
  UniqueString(strSID);
  _RtlFreeUnicodeString(pus);
  result := true;
end;

// http://www.delphipraxis.net/post471470.html
// Changed
function GetMySID(): string;
var
  SID: PSID;
  strSID: PAnsiChar;
  err: DWORD;
begin
  SID := nil;

  err := _getAccountSid('', _getLoginNameW(), SID);
  if err > 0 then
  begin
    EAPICallError.Create('_getAccountSid:' + SysErrorMessage(err));
    Exit;
  end;

  if _ConvertSidToStringSidA(SID, strSID) then
  begin
    result := string(strSID);
    Exit;
  end;

  if not _NT_SidToString(SID, result) then
  begin
    EAPICallError.Create('_NT_SidToString'); // TODO: RaiseLastOsError???
  end;
end;

end.
