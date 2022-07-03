
// ********************************************************************************
// **** ATTENTION! This unit is not developed anymore.                        *****
// **** Please use the new version RecBinUnit2.pas , which is Object-oriented *****
// ********************************************************************************

////////////////////////////////////////////////////////////////////////////////////
// RECYCLE-BIN-FUNCTIONS BY DANIEL MARSCHALL                                      //
// E-MAIL: info@daniel-marschall.de                                               //
// WEB:    www.daniel-marschall.de                                                //
////////////////////////////////////////////////////////////////////////////////////
// Revision: 30 Jun 2022                                                          //
// This unit is freeware, but please link to my website if you are using it!      //
////////////////////////////////////////////////////////////////////////////////////
// Successfully tested with:                                                      //
// Windows 95b (without IE4 Shell Extensions)                                     //
// Windows 95b (with IE4 Shell Extensions)                                        //
// Windows 98-SE                                                                  //
// Windows NT4 SP6                                                                //
// Windows XP-SP3                                                                 //
// Windows 2000-SP4                                                               //
// Windows 2003 Server EE SP1                                                     //
// Windows Vista                                                                  //
// Windows 7                                                                      //
// Windows 10 (version 1 and version 2 format)                                    //
// Windows 11                                                                     //
////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//  Needs Delphi 4 or higher. If you are using Delphi 4 or 5, you can not use the //
//  RecyclerGetDateTime() functions, because the unit "DateUtils" is missing.     //
//  Warning! This is a platform unit.                                             //
//                                                                                //
//  To do! Can you help?                                                          //
//    - Win7 : Drive GUIDs                                                        //
//    - Win7 : Absolute vs. Relative size limitations                             //
//    - WideString-Support (input/output)                                         //
//    - Always do EOF before reading anything?                                    //
//    - Is it possible to identify a Vista-file that is not named $Ixxxxxx.ext?   //
//    - RecyclerGetInfofiles() check additionally for removable device?           //
//      RecyclerIsValid() is false.                                               //
//    - Make it possible to empty the recycle bin of one specific drive!          //
//                                                                                //
//  Unknown! Do you know the answer?                                              //
//    - How does Windows 9x/NT manage the daylight saving time (if it does)?      //
//    - How does Windows Vista react to a RECYCLER\ folder on a NTFS device?      //
//    - How does Windows Vista react to a RECYCLED\ folder on a FAT device?       //
//                                                                                //
//  Thanks to all these who have helped me solving coding problems.               //
//  Thanks to SEBA for sending in the Windows Vista trash structure files.        //
//  Thanks to OMATA for testing the unit with Delphi 4.                           //
//  Thanks to DEITYSOU for making a bugfix of DriveExists()                       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

(*

== TODO LISTE ==

- Wichtig! Windows XP: InfoTip, IntroText und LocalizedString sind Resourcenangaben und müssen ausgelesen werden!
- Testen: Wie reagiert Windows, wenn Bitbucket\C existiert, aber kein Wert 'Percent' hat? Mit der Standardeinstellung?
- Bug: Windows 2000 bei bestehenden Windows 95 Partition: Recycler Filename ist dann Recycled und nicht Recycler!
- bug? w95 recycled file hat immer selben löschzeitpunkt und größe? war die nicht verschieden?
- beachtet? bei leerem papierkorb auf fat ist weder info noch info2 vorhanden?
- testen: auch möglich, einen vista papierkorb offline öffnen?
- Problem: bei win95(ohne ie4) und win2000 gleichzeitiger installation: es existiert info UND info2!!!
- Implement SETTER functions to every kind of configuration thing. (percentage etc)
- Registry CURRENT_USER: Funktionen auch für fremde Benutzer zur Verfügung stellen?
- Es sollte möglich sein, dass ein Laufwerk mehr als 1 Recycler beinhaltet -- behandeln

=== Future Ideas ===

- Demoapplikation: Dateien statt Text als Explorer-Like (TListView)?
- Einzelne Elemente oder alle wiederherstellen oder löschen
- Konfiguration für Laufwerke ändern etc
- IconString -> TIcon Convertion functions
- platzreservierung in mb-angabe berechnen
- I don't know if there exists any API function which checks the state at any internal way.
- copy/move files from recyclebin

*)

// TODO: Also include BC++ Versions
{$IFNDEF BCB}
{$DEFINE DEL1UP}
{$IFNDEF VER80}
{$DEFINE DEL2UP}
{$IFNDEF VER90}
{$DEFINE DEL3UP}
{$IFNDEF VER100}
{$DEFINE DEL4UP}
{$IFNDEF VER120}
{$DEFINE DEL5UP}
{$IFNDEF VER130}
{$DEFINE DEL6UP}
{$IFNDEF VER140}
{$DEFINE DEL7UP}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF DEL7UP}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$ENDIF}

{$IFDEF DEL6UP}
unit RecyclerFunctions platform;
{$ELSE}
unit RecyclerFunctions;
{$ENDIF}

// Configuration

// If enabled, all functions with parameter "InfofileOrRecycleFolder" will
// also accept files which are not the indexfile (then, a INFO2 or INFO file
// will be searched in this directory).
{.$DEFINE allow_all_filenames}

interface

uses
  Windows, SysUtils, Classes, {$IFDEF DEL6UP}DateUtils,{$ENDIF}
  ShellApi{$IFNDEF DEL6UP}, FileCtrl{$ENDIF}, Registry,
  Messages, BitOps;

type
  EUnknownState = class(Exception);
  EEventCategoryNotDefined = class(Exception);
  EAPICallError = class(Exception);

  PSHQueryRBInfo = ^TSHQueryRBInfo;
  {$IFDEF WIN64}
  // ATTENTION! MUST NOT BE PACKED! Alignment for 64 bit must be 8 and for 32 bit must be 4
  TSHQueryRBInfo = record
  {$ELSE}
  TSHQueryRBInfo = packed record
  {$ENDIF}
    cbSize      : dword;
    i64Size     : int64;
    i64NumItems : int64;
  end;

  GPOLICYBOOL = (gpUndefined, gpEnabled, gpDisabled);

const
  RECYCLER_CLSID = '{645FF040-5081-101B-9F08-00AA002F954E}';

{$IFDEF DEL6UP}
function RecyclerGetDateTime(drive: char; fileid: string): tdatetime; overload;
function RecyclerGetDateTime(drive: char; UserSID: string; fileid: string): tdatetime; overload;
function RecyclerGetDateTime(InfofileOrRecycleFolder: string): tdatetime; overload;
function RecyclerGetDateTime(InfofileOrRecycleFolder: string; id: string): tdatetime; overload;
{$ENDIF}

function RecyclerGetSourceUnicode(drive: char; fileid: string): WideString; overload;
function RecyclerGetSourceUnicode(drive: char; UserSID: string; fileid: string): WideString; overload;
function RecyclerGetSourceUnicode(InfofileOrRecycleFolder: string): WideString; overload;
function RecyclerGetSourceUnicode(InfofileOrRecycleFolder: string; id: string): WideString; overload;

function RecyclerGetSource(drive: char; fileid: string): string; overload;
function RecyclerGetSource(drive: char; UserSID: string; fileid: string): string; overload;
function RecyclerGetSource(InfofileOrRecycleFolder: string): string; overload;
function RecyclerGetSource(InfofileOrRecycleFolder: string; id: string): string; overload;

procedure RecyclerListIndexes(drive: char; result: TStringList); overload;
procedure RecyclerListIndexes(drive: char; UserSID: string; result: TStringList); overload;
procedure RecyclerListIndexes(InfofileOrRecycleFolder: string; result: TStringList); overload;

function RecyclerGetSourceDrive(drive: char; fileid: string): char; overload;
function RecyclerGetSourceDrive(drive: char; UserSID: string; fileid: string): char; overload;
function RecyclerGetSourceDrive(InfofileOrRecycleFolder: string): char; overload;
function RecyclerGetSourceDrive(InfofileOrRecycleFolder: string; id: string): char; overload;

function RecyclerOriginalSize(drive: char; fileid: string): integer; overload;
function RecyclerOriginalSize(drive: char; UserSID: string; fileid: string): integer; overload;
function RecyclerOriginalSize(InfofileOrRecycleFolder: string): integer; overload;
function RecyclerOriginalSize(InfofileOrRecycleFolder: string; id: string): integer; overload;

function RecyclerIsValid(drive: char): boolean; overload;
function RecyclerIsValid(drive: char; UserSID: string): boolean; overload;
function RecyclerIsValid(InfofileOrRecycleFolder: string): boolean; overload;

function RecyclerCurrentFilename(drive: char; fileid: string): string; overload;
function RecyclerCurrentFilename(drive: char; UserSID: string; fileid: string): string; overload;
function RecyclerCurrentFilename(InfofileOrRecycleFolder: string): string; overload;
function RecyclerCurrentFilename(InfofileOrRecycleFolder: string; id: string): string; overload;

function RecyclerGetPath(drive: char; UserSID: string; IncludeInfofile: boolean; fileid: string): string; overload;
function RecyclerGetPath(drive: char; UserSID: string; IncludeInfofile: boolean): string; overload;
function RecyclerGetPath(drive: char; IncludeInfofile: boolean): string; overload;
function RecyclerGetPath(drive: char; UserSID: string): string; overload;
function RecyclerGetPath(drive: char): string; overload;

procedure RecyclerGetInfofiles(drive: char; UserSID: string; IncludeInfofile: boolean; fileid: string; result: TStringList); overload;
procedure RecyclerGetInfofiles(drive: char; UserSID: string; IncludeInfofile: boolean; result: TStringList); overload;
procedure RecyclerGetInfofiles(drive: char; IncludeInfofile: boolean; result: TStringList); overload;
procedure RecyclerGetInfofiles(drive: char; UserSID: string; result: TStringList); overload;
procedure RecyclerGetInfofiles(drive: char; result: TStringList); overload;

function RecyclerCurrentFilenameAndPath(drive: char; UserSID: string; fileid: string): string; overload;
function RecyclerCurrentFilenameAndPath(drive: char; fileid: string): string; overload;
function RecyclerCurrentFilenameAndPath(InfofileOrRecycleFolder: string; id: string): string; overload;

function RecyclerRemoveItem(drive: char; UserSID: string; fileid: string): boolean; overload;
function RecyclerRemoveItem(drive: char; fileid: string): boolean; overload;
function RecyclerRemoveItem(InfofileOrRecycleFolder: string; id: string): boolean; overload;

procedure RecyclerGetAllRecyclerDrives(result: TStringList);

function RecyclerEmptyRecycleBin(flags: cardinal): boolean; overload;
function RecyclerEmptyRecycleBin(sound, progress, confirmation: boolean): boolean; overload;

function RecyclerAddFileOrFolder(FileOrFolder: string; confirmation: boolean): boolean; overload;
function RecyclerAddFileOrFolder(FileOrFolder: string): boolean; overload;

function RecyclerConfirmationDialogEnabled: boolean;
function RecyclerShellStateConfirmationDialogEnabled: boolean;
procedure RecyclerConfirmationDialogSetEnabled(NewSetting: boolean);

function RecyclerGetCurrentIconString: string;
function RecyclerGetDefaultIconString: string;
function RecyclerGetEmptyIconString: string;
function RecyclerGetFullIconString: string;

function RecyclerGetName: string;
function RecyclerGetInfoTip: string;
function RecyclerGetIntroText: string;

function RecyclerEmptyEventGetName: string;
function RecyclerEmptyEventGetCurrentSound: string;
function RecyclerEmptyEventGetDefaultSound: string;
procedure RecyclerEmptyEventGetSoundCategories(AStringList: TStringList);
function RecyclerEmptyEventGetSound(ACategory: string): string;

function RecyclerGlobalGetPercentUsage: integer;
function RecyclerSpecificGetPercentUsage(Drive: Char): integer;
function RecyclerGetPercentUsageAutoDeterminate(Drive: Char): integer;

function RecyclerGlobalIsNukeOnDelete: boolean;
function RecyclerSpecificIsNukeOnDelete(Drive: Char): boolean;
function RecyclerIsNukeOnDeleteAutoDeterminate(Drive: Char): boolean;

function RecyclerHasGlobalSettings: boolean;

function RecyclerIsEmpty: boolean; overload;
function RecyclerIsEmpty(Drive: Char): boolean; overload;

function RecyclerGetNumItems: int64; overload;
function RecyclerGetNumItems(Drive: Char): int64; overload;

function RecyclerGetSize: int64; overload;
function RecyclerGetSize(Drive: Char): int64; overload;

function RecyclerGetAPIInfo(Drive: Char): TSHQueryRBInfo; overload;
function RecyclerGetAPIInfo(Path: String): TSHQueryRBInfo; overload;

function RecyclerGetCLSID: string;

// Diese Funktion ist false, wenn sie z.B. unter Windows 95 ohne Internet Explorer
// 4.0 Shell Extension ausgeführt wird. Wenn abwärtskompatibler Code geschrieben
// werden soll, sollte RecyclerQueryFunctionAvailable() verwendet werden, da
// unter Windows 95 folgende Funktionalitäten NICHT vorhanden sind:
// - RecyclerIsEmpty
// - RecyclerGetNumItems
// - RecyclerGetSize
// - RecyclerGetAPIInfo
function RecyclerQueryFunctionAvailable: boolean;

function RecyclerGroupPolicyNoRecycleFiles: GPOLICYBOOL;
function RecyclerGroupPolicyConfirmFileDelete: GPOLICYBOOL;
function RecyclerGroupPolicyRecycleBinSize: integer;

function GPBoolToString(value: GPOLICYBOOL): String;

function RecyclerIsPossible(Drive: Char): boolean;

function RecyclerLibraryVersion: string;

implementation

type
  SHELLSTATE = record
    Flags1: DWORD;
(*
    BOOL fShowAllObjects : 1;
    BOOL fShowExtensions : 1;
    BOOL fNoConfirmRecycle : 1;

    BOOL fShowSysFiles : 1;
    BOOL fShowCompColor : 1;
    BOOL fDoubleClickInWebView : 1;
    BOOL fDesktopHTML : 1;
    BOOL fWin95Classic : 1;
    BOOL fDontPrettyPath : 1;
    BOOL fShowAttribCol : 1; // No longer used, dead bit
    BOOL fMapNetDrvBtn : 1;
    BOOL fShowInfoTip : 1;
    BOOL fHideIcons : 1;
    BOOL fWebView : 1;
    BOOL fFilter : 1;
    BOOL fShowSuperHidden : 1;
    BOOL fNoNetCrawling : 1;
*)
    dwWin95Unused: DWORD; // Win95 only - no longer supported pszHiddenFileExts
    uWin95Unused: UINT; // Win95 only - no longer supported cbHiddenFileExts

    // Note: Not a typo!  This is a persisted structure so we cannot use LPARAM
    lParamSort: Integer;
    iSortDirection: Integer;

    version: UINT;

    // new for win2k. need notUsed var to calc the right size of ie4 struct
    // FIELD_OFFSET does not work on bit fields
    uNotUsed: UINT; // feel free to rename and use
    Flags2: DWORD;
(*
    BOOL fSepProcess: 1;
    // new for Whistler.
    BOOL fStartPanelOn: 1;       //Indicates if the Whistler StartPanel mode is ON or OFF.
    BOOL fShowStartPage: 1;      //Indicates if the Whistler StartPage on desktop is ON or OFF.
    UINT fSpareFlags : 13;
*)
  end;
  LPSHELLSTATE = ^SHELLSTATE;

const
  {$IFDEF MSWINDOWS}
    shell32  = 'shell32.dll';
    advapi32 = 'advapi32.dll';
  {$ENDIF}
  {$IFDEF LINUX}
    shell32  = 'libshell32.borland.so';
    advapi32 = 'libwine.borland.so';
  {$ENDIF}

  // Masks for the shellstate
   SSF_SHOWALLOBJECTS  = $00000001;
  SSF_SHOWEXTENSIONS  = $00000002;
  SSF_HIDDENFILEEXTS  = $00000004;
  SSF_SERVERADMINUI   = $00000004;
  SSF_SHOWCOMPCOLOR   = $00000008;
  SSF_SORTCOLUMNS     = $00000010;
  SSF_SHOWSYSFILES    = $00000020;
  SSF_DOUBLECLICKINWEBVIEW = $00000080;
  SSF_SHOWATTRIBCOL   = $00000100;
  SSF_DESKTOPHTML     = $00000200;
  SSF_WIN95CLASSIC    = $00000400;
  SSF_DONTPRETTYPATH  = $00000800;
  SSF_SHOWINFOTIP     = $00002000;
  SSF_MAPNETDRVBUTTON = $00001000;
  SSF_NOCONFIRMRECYCLE = $00008000;
  SSF_HIDEICONS       = $00004000;
  SSF_FILTER          = $00010000;
  SSF_WEBVIEW         = $00020000;
  SSF_SHOWSUPERHIDDEN = $00040000;
  SSF_SEPPROCESS      = $00080000;
  SSF_NONETCRAWLING   = $00100000;
  SSF_STARTPANELON    = $00200000;
  SSF_SHOWSTARTPAGE   = $00400000;

// **********************************************************
// COMPATIBILITY FUNCTIONS
// **********************************************************

{$IFNDEF DEL5UP}
function IncludeTrailingBackslash(str: string): string;
begin
  if Copy(str, length(str), 1) = '\' then    // TODO? Gibt es PathDelim in Delphi 4?
    Result := str
  else
    Result := str + '\';
end;
{$ENDIF}

// **********************************************************
// INTERNALLY USED FUNCTIONS
// **********************************************************

resourcestring
  LNG_UNEXPECTED_STATE = 'Cannot determinate state of "%s" because of an unknown value in the configuration of your operation system. Please contact the developer of the Recycler Bin Unit and help improving the determination methods!';
  LNG_API_CALL_ERROR = 'Error while calling the API. Additional information: "%s".';
  LNG_NOT_CALLABLE = '%s not callable';
  LNG_ERROR_CODE = '%s (Arguments: %s) returns error code %s';
  LNG_UNEXPECTED_VISTA_FORMAT = 'Unexpeceted version %d of Vista index file';

function _DeleteDirectory(const Name: string): boolean;
var
  F: TSearchRec;
begin
  result := true;
  if FindFirst(IncludeTrailingPathDelimiter(Name) + '*', faAnyFile, F) = 0 then
  begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then
        begin
          if (F.Name <> '.') and (F.Name <> '..') then
          begin
            result := result and _DeleteDirectory(IncludeTrailingPathDelimiter(Name) + F.Name);
          end;
        end
        else
        begin
          if not DeleteFile(IncludeTrailingPathDelimiter(Name) + F.Name) then result := false;
        end;
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
    if not RemoveDir(Name) then result := false;
  end;
end;

function _FileSize(FileName: string): int64;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);
  try
    result := fs.size;
  finally
    fs.free;
  end;
end;

function _DriveNum(Drive: Char): Byte;
// a->0, ..., z->25
var
  tmp: string;
begin
  tmp := LowerCase(Drive);
  result := Ord(tmp[1])-Ord('a');
end;

function _registryReadDump(AReg: TRegistry; AName: string): string;
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

function _GetStringFromDLL(filename: string; num: integer): string;
const
  // http://www.eggheadcafe.com/forumarchives/vcmfc/sep2005/post23917443.asp
  MAX_BUF = 4097; // OK?
var
  hLib: THandle;
  buf: array[0..MAX_BUF] of char;
begin
  hLib := LoadLibrary(PChar(filename));
  try
    LoadString(hLib, num, buf, sizeof(buf));
    result := buf;
  finally
    FreeLibrary(hLib);
  end;
end;

// http://www.delphi-library.de/topic_Umgebungsvariable+in+einem+String+aufloesen_20516,0.html
function _ExpandEnvStr(const szInput: string): string;
const
  MAXSIZE = 32768; // laut PSDK sind 32k das Maximum
begin
  SetLength(Result,MAXSIZE);
  SetLength(Result,ExpandEnvironmentStrings(pchar(szInput),
    @Result[1],length(Result))-1); //-1 um abschließendes #0 zu verwerfen
end;

// Beispiele
// Papierkorb                                                 -- Windows 95
// @C:\WINNT\system32\shell32.dll,-8964@1031,Papierkorb       -- Windows 2000

function _DecodeReferenceString(s: string): string;
var
  dll, id, lang, cache: string;
  sl, sl2: tstringlist;
begin
  if Copy(s, 1, 1) = '@' then
  begin
    // Referenz auf eine DLL
    // @<dll>,-<id>[@<lang>][,<cache>]

    sl := TStringList.Create;
    try
      // '@' am Anfang entfernen
      s := Copy(s, 2, length(s)-1);

      // Nach ',' auftrennen
      // sl[0] --> dll
      // sl[1] --> -id@lang
      // sl[2] --> cache
      sl.CommaText := s;

      if sl.Count > 2 then
      begin
        // Das Ergebnis ist bereits im Klartext vorhanden und muss nicht extrahiert werden
        // Ist bei Windows 2000 der Fall
        cache := sl[2];
        result := cache;
        exit;
      end;

      if sl.Count > 1 then
      begin
        dll := sl[0];

        sl2 := TStringList.Create;
        try
          // Nach '@' auftrennen
          // sl2[0] --> id
          // sl2[1] --> lang
          sl2.CommaText := StringReplace(sl[1], '@', ',', [rfReplaceAll]);

          id := sl2[0];

          if sl2.Count > 1 then
          begin
            // ToDo: In Zukunft beachten, sofern möglich
            lang := sl2[1];
          end;

          // Umgebungsvariablen erkennen und Minuszeichen entfernen
          result := _GetStringFromDLL(_ExpandEnvStr(dll), -StrToInt(id));
        finally
          sl2.Free;
        end;
      end
      else
      begin
        // Zu wenige Informationen!

        result := '';
      end;
    finally
      sl.Free;
    end;
  end
  else
  begin
    // Kein Hinweis auf eine Referenz
    result := s;
  end;
end;

function _readInt8(const Stream: TStream): byte;
var
  I: integer;
begin
  i := 0;
  Stream.ReadBuffer(i, 1);
  Result := i;
end;

function _readInt32(const Stream: TStream): Longword;
var
  I: integer;
begin
  i := 0;
  Stream.ReadBuffer(i, 4);
  Result := i;
end;

function _readInt64(const Stream: TStream): int64;
var
  I: int64;
begin
  i := 0;
  Stream.ReadBuffer(i, 8);
  Result := i;
end;

function _readChar(const Stream: TStream): char;
var
  C: Char;
begin
  C := #0;
  Stream.ReadBuffer(C, 1);
  Result := C;
end;

function _readNullTerminatedString(const Stream: TStream): String;
var
  S: String;
  C: Char;
begin
  S := '';
  repeat
    Stream.ReadBuffer(C, 1);
    if (C <> #0) then
      S := S + C;
  until C = #0;
  Result := S;
end;

// http://www.delphipraxis.net/post761928.html#761928
function _readNullTerminatedWideString(const Stream: TStream): WideString;
var
  S: WideString;
  WC: WideChar;
begin
  S := '';
  repeat
    Stream.ReadBuffer(WC, 2);
    if (WC <> #0) then
      S := S + WC;
  until WC = #0;
  Result := S;
end;

// http://www.delphipraxis.net/post340194.html#340194
function _nowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  with SystemTime do
  begin
    Result := EncodeDate(wYear, wMonth, wDay) +
              EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
  end;
end;

{$IFDEF DEL6UP}
function _getGMTDifference(): extended;
begin
  result := - (datetimetounix(_nowUTC())-datetimetounix(Now())) / 3600;
end;

function _fileTimeToDateTime(FileTime: int64): TDateTime;
begin
  // http://www.e-fense.com/helix/Docs/Recycler_Bin_Record_Reconstruction.pdf
  // UnixTime = 0.0000001 * NTTime + 11644473600
  // This is wrong! The correct formula is:
  // UnixTime = 0.0000001 * NTTime - 11644473600 + c * 3600
  // c = GMT-Difference (MEZ = 1) inclusive daylight saving time (+3600 seconds)
  result := unixtodatetime(FileTime div 10000000 - 11644473600 + round(_getGMTDifference() * 3600));
end;
{$ENDIF}

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

// Source: http://www.delphipraxis.net/post471470.html
// Modified
function _getMySID(): string;
var
  SID: PSID;
  strSID: PAnsiChar;
  err: DWORD;
begin
  SID := nil;

  err := _getAccountSid('', _getLoginNameW(), SID);
  try
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

    if _NT_SidToString(SID, result) then Exit;

    EAPICallError.Create('_getMySID:' + SysErrorMessage(err));
  finally
    if Assigned(SID) then FreeMemory(SID);
  end;
end;

// Originalcode aus http://www.delphipraxis.net/post2933.html
function _DriveExists(DriveByte: Byte): Boolean; overload;
begin
  Result := GetLogicalDrives and (1 shl DriveByte) <> 0;
end;

function _driveExists(Drive: Char): Boolean; overload;
var
  DriveByte: Byte;
  tmp: string;
begin
  // Make drive letter upper case (for older Delphi versions)
  tmp := UpperCase(Drive);
  Drive := tmp[1];

  DriveByte := Ord(Drive) - Ord('A');
  Result := _DriveExists(DriveByte);
end;

function _isFAT(drive: char): boolean;
var
  Dummy2: DWORD;
  Dummy3: DWORD;
  FileSystem: array[0..MAX_PATH-1] of char;
  VolumeName: array[0..MAX_PATH-1] of char;
  s: string;
begin
  result := false;
  if _driveExists(drive) then
  begin
    s := drive + DriveDelim + PathDelim; // ohne die Auslagerung in einen String kommt es zu einer AV in ntdll
    GetVolumeInformation(PChar(s), VolumeName,
      SizeOf(VolumeName), nil, Dummy2, Dummy3, FileSystem, SizeOf(FileSystem));
    result := uppercase(copy(FileSystem, 0, 3)) = 'FAT';
  end;
end;

// **********************************************************
// VISTA AND WINDOWS 7 FUNCTIONS, INTERNAL USED
// **********************************************************

function _isFileVistaRealfile(filename: string): boolean;
begin
  result := uppercase(copy(extractfilename(filename), 0, 2)) = '$R';
end;

function _isFileVistaIndexfile(filename: string): boolean;
begin
  result := uppercase(copy(extractfilename(filename), 0, 2)) = '$I';
end;

function _isFileVistaNamed(filename: string): boolean;
begin
  result := _isFileVistaIndexfile(filename) or
            _isFileVistaRealfile(filename);
end;

function _VistaChangeRealfileToIndexfile(realfile: string): string;
begin
  if _isFileVistaRealfile(realfile) then
  begin
    result := extractfilepath(realfile)+'$I'+
      copy(extractfilename(realfile), 3, length(extractfilename(realfile))-2);
  end
  else
    result := realfile; // ignore, even if it is not a vista recycle-file
end;

function _VistaChangeIndexfileToRealfile(indexfile: string): string;
begin
  if _isFileVistaIndexfile(indexfile) then
  begin
    result := extractfilepath(indexfile)+'$R'+
      copy(extractfilename(indexfile), 3, length(extractfilename(indexfile))-2);
  end
  else
    result := indexfile; // ignore, even if it is not a vista recycle-file
end;

procedure _VistaListIndexes(recyclerpath: string; result: TStringList);
var
  sr: TSearchRec;
  r: Integer;
  tmp: string;
begin
  tmp := recyclerpath;
  tmp := IncludeTrailingBackslash(tmp);

  if not directoryexists(tmp) then exit;

  r := FindFirst(tmp+PathDelim + '$I*', faAnyFile, sr);
  while r = 0 do
  begin
    if (sr.Name <> '.') and (sr.Name <> '..') then
    begin
      result.Add(copy(sr.name, 3, length(sr.name)-2));
    end;
    r := FindNext(sr);
  end;

  FindClose(sr);
end;

function _VistaCurrentFilename(infofilename: string): string;
begin
  result := extractfilename(infofilename);

  if _isFileVistaRealfile(result) then
  begin
    exit;
  end;

  if _isFileVistaIndexfile(result) then
  begin
    result := _VistaChangeIndexfileToRealfile(result);
    exit;
  end;

  result := copy(result, 3, length(result)-2);
  result := '$R'+result;
end;

function _VistaGetSourceDrive(infofile: string): char;
var
  fs: TFileStream;
  tmp: string;
  version: DWORD;
const
  drive_vista_position = $18;
begin
  result := #0;

  tmp := infofile;
  tmp := _VistaChangeRealfileToIndexfile(tmp);
  if not fileexists(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.ReadBuffer(version, 4);
    if version > 2 then
      raise Exception.CreateFmt(LNG_UNEXPECTED_VISTA_FORMAT, [version]);
    fs.seek(drive_vista_position, soFromBeginning);
    result := _readChar(fs);
  finally
    fs.free;
  end;
end;

{$IFDEF DEL6UP}
function _VistaGetDateTime(infofile: string): TDateTime;
var
  fs: TFileStream;
  tmp: string;
  version: DWORD;
const
  timestamp_vista_position = $10;
begin
  result := EncodeDateTime(1601, 1, 1, 0, 0, 0, 0);

  tmp := infofile;
  tmp := _VistaChangeRealfileToIndexfile(tmp);
  if not fileexists(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.ReadBuffer(version, 4);
    if version > 2 then
      raise Exception.CreateFmt(LNG_UNEXPECTED_VISTA_FORMAT, [version]);
    fs.seek(timestamp_vista_position, soFromBeginning);
    result := _fileTimeToDateTime(_readInt64(fs));
  finally
    fs.free;
  end;
end;
{$ENDIF}

function _VistaGetSourceUnicode(infofile: string): string;
var
  fs: TFileStream;
  tmp: string;
  version: DWORD;
const
  unicode_vista_position_v1 = $18;
  unicode_vista_position_v2 = $1C;
begin
  result := '';

  tmp := infofile;
  tmp := _VistaChangeRealfileToIndexfile(tmp);
  if not fileexists(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.ReadBuffer(version, 4);
    if version = 2 then
      // Note: This is not the official way to read the source. Actually, you should check the size and only read this specified size
      fs.seek(unicode_vista_position_v2, soFromBeginning)
    else if version = 1 then
      fs.seek(unicode_vista_position_v1, soFromBeginning)
    else
      raise Exception.CreateFmt(LNG_UNEXPECTED_VISTA_FORMAT, [version]);
    result := _readNullTerminatedWideString(fs);
  finally
    fs.free;
  end;
end;

function _VistaOriginalSize(infofile: string): integer;
var
  fs: TFileStream;
  tmp: string;
  version: DWORD;
const
  size_vista_position = $8;
begin
  result := -1;

  tmp := infofile;
  tmp := _VistaChangeRealfileToIndexfile(tmp);
  if not fileexists(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.ReadBuffer(version, 4);
    if version > 2 then
      raise Exception.CreateFmt(LNG_UNEXPECTED_VISTA_FORMAT, [version]);
    fs.seek(size_vista_position, soFromBeginning);
    result := _readInt32(fs);
  finally
    fs.free;
  end;
end;

function _checkInfo1or2File(filename: string): boolean;
var
  fs: TStream;
  record_length: integer;
const
  length_position = $C;
  empty_size = 20;
begin
  fs := TFileStream.Create(filename, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    // Check the file length
    if record_length = 0 then
      result := false
    else
      result := (fs.size - empty_size) mod record_length = 0;
  finally
    fs.free;
  end;
end;

function _VistaIsValid(infofile: string): boolean;
var
  tmp: string;
begin
  tmp := infofile;
  tmp := _VistaChangeRealfileToIndexfile(tmp);
  result := fileexists(tmp);
end;

// **********************************************************
// PUBLIC FUNCTIONS
// **********************************************************

{$IFDEF DEL6UP}

function RecyclerGetDateTime(InfofileOrRecycleFolder: string): tdatetime; overload;
begin
  result := RecyclerGetDateTime(InfofileOrRecycleFolder, '');
end;

function RecyclerGetDateTime(drive: char; fileid: string): tdatetime; overload;
begin
  result := RecyclerGetDateTime(drive, '', fileid);
end;

function RecyclerGetDateTime(drive: char; UserSID: string; fileid: string): tdatetime; overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, true, fileid);
  result := RecyclerGetDateTime(infofile, fileid);
end;

function RecyclerGetDateTime(InfofileOrRecycleFolder: string; id: string): tdatetime; overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
const
  length_position = $C;
  unique_index_position = $118;
  timestamp_position = $120;
begin
  // FILETIME does start at 01.01.1601 00:00:00 (GMT)
  result := EncodeDateTime(1601, 1, 1, 0, 0, 0, 0);

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    result := _VistaGetDateTime(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      result := _VistaGetDateTime(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    i := -1;
    repeat
      inc(i);
      if unique_index_position+i*record_length > fs.size then break;
      fs.seek(unique_index_position+i*record_length, soFromBeginning);
      if inttostr(_readInt32(fs)) = id then
      begin
        fs.seek(timestamp_position+i*record_length, soFromBeginning);
        result := _fileTimeToDateTime(_readInt64(fs));
        break;
      end;
      until false;
  finally
    fs.free;
  end;
end;

{$ENDIF}

////////////////////////////////////////////////////////////////////////////////

function RecyclerGetSourceUnicode(InfofileOrRecycleFolder: string): WideString; overload;
begin
  result := RecyclerGetSourceUnicode(InfofileOrRecycleFolder, '');
end;

function RecyclerGetSourceUnicode(drive: char; fileid: string): WideString; overload;
begin
  result := RecyclerGetSourceUnicode(drive, '', fileid);
end;

function RecyclerGetSourceUnicode(drive: char; UserSID: string; fileid: string): WideString; overload;
var
  infofile: string;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    infofile := RecyclerGetPath(drive, UserSID, true, fileid);
    result := RecyclerGetSourceUnicode(infofile, fileid);
  end
  else
  begin
    // Windows 9x does not support unicode
    result := RecyclerGetSource(drive, UserSID, fileid);
  end;
end;

function RecyclerGetSourceUnicode(InfofileOrRecycleFolder: string; id: string): WideString; overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
const
  length_position = $C;
  unique_index_position = $118;
  unicode_source_position = $12C;
begin
  result := '';

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    // Vista only gives unicode names
    result := _VistaGetSourceUnicode(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      // Vista only gives unicode names
      result := _VistaGetSourceUnicode(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    if record_length <> $118 then
    begin
      // Windows NT
      i := -1;
      repeat
        inc(i);
        if unique_index_position+i*record_length > fs.size then break;
        fs.seek(unique_index_position+i*record_length, soFromBeginning);
        if inttostr(_readInt32(fs)) = id then
        begin
          fs.seek(unicode_source_position+i*record_length, soFromBeginning);
          result := _readNullTerminatedWideString(fs);
          break;
        end;
      until false;
    end;
  finally
    fs.free;
  end;

  if record_length = $118 then
  begin
    // Windows 9x has no unicode support
    result := RecyclerGetSource(tmp, id);
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerGetSource(InfofileOrRecycleFolder: string): string; overload;
begin
  result := RecyclerGetSource(InfofileOrRecycleFolder, '');
end;

function RecyclerGetSource(drive: char; fileid: string): string; overload;
begin
  result := RecyclerGetSource(drive, '', fileid);
end;

function RecyclerGetSource(drive: char; UserSID: string; fileid: string): string; overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, true, fileid);
  result := RecyclerGetSource(infofile, fileid);
end;

function RecyclerGetSource(InfofileOrRecycleFolder: string; id: string): string; overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
  alternativ: string;
const
  length_position = $C;
  unique_index_position = $118;
  source_position = $14;
begin
  result := '';

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    // Vista only gives unicode names
    result := _VistaGetSourceUnicode(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      // Vista only gives unicode names
      result := _VistaGetSourceUnicode(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    i := -1;
    repeat
      inc(i);
      if unique_index_position+i*record_length > fs.size then break;
      fs.seek(unique_index_position+i*record_length, soFromBeginning);
      if inttostr(_readInt32(fs)) = id then
      begin
        fs.seek(source_position+i*record_length, soFromBeginning);
        alternativ := _readChar(fs);

        if alternativ = #0 then
        begin
          fs.seek(source_position+i*record_length+1, soFromBeginning);
          result := _readNullTerminatedString(fs);
        end
        else
        begin
          fs.seek(source_position+i*record_length, soFromBeginning);
          result := _readNullTerminatedString(fs);
        end;

        break;
      end;
    until false;
  finally
    fs.free;
  end;

  // In some cases the ansi-source-name is [Null]:\...\
  if alternativ = #0 then
  begin
    result := RecyclerGetSourceDrive(InfofileOrRecycleFolder, id) + result;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure RecyclerListIndexes(drive: char; result: TStringList); overload;
begin
  RecyclerListIndexes(drive, '', result);
end;

procedure RecyclerListIndexes(drive: char; UserSID: string; result: TStringList); overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, false);
  RecyclerListIndexes(infofile, result);
end;

procedure RecyclerListIndexes(InfofileOrRecycleFolder: string; result: TStringList); overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
const
  length_position = $C;
  unique_index_position = $118;
begin
  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    _VistaListIndexes(extractfilepath(tmp), result);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'INFO2') then     tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then tmp := tmp+'INFO'
    else
    begin
      // Last try: is it a vista-directory?
      _VistaListIndexes(tmp, result);
      exit;
    end;
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    i := -1;
    repeat
      inc(i);
      if unique_index_position+i*record_length > fs.size then break;
      fs.seek(unique_index_position+i*record_length, soFromBeginning);

      result.Add(inttostr(_readInt32(fs)));
    until false;
  finally
    fs.free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerGetSourceDrive(InfofileOrRecycleFolder: string): char; overload;
begin
  result := RecyclerGetSourceDrive(InfofileOrRecycleFolder, '');
end;

function RecyclerGetSourceDrive(drive: char; fileid: string): char; overload;
begin
  result := RecyclerGetSourceDrive(drive, '', fileid);
end;

function RecyclerGetSourceDrive(drive: char; UserSID: string; fileid: string): char; overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, true, fileid);
  result := RecyclerGetSourceDrive(infofile, fileid);
end;

function RecyclerGetSourceDrive(InfofileOrRecycleFolder: string; id: string): char; overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
const
  length_position = $C;
  unique_index_position = $118;
  source_drive_position = $11C;
begin
  result := #0;

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    result := _VistaGetSourceDrive(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      result := _VistaGetSourceDrive(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    i := -1;
    repeat
      inc(i);
      if unique_index_position+i*record_length > fs.size then break;
      fs.seek(unique_index_position+i*record_length, soFromBeginning);
      if inttostr(_readInt32(fs)) = id then
      begin
        fs.seek(source_drive_position+i*record_length, soFromBeginning);
        result := chr(ord('A') + _readInt8(fs));
        break;
      end;
    until false;
  finally
    fs.free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerOriginalSize(InfofileOrRecycleFolder: string): integer; overload;
begin
  result := RecyclerOriginalSize(InfofileOrRecycleFolder, '');
end;

function RecyclerOriginalSize(drive: char; fileid: string): integer; overload;
begin
  result := RecyclerOriginalSize(drive, '', fileid);
end;

function RecyclerOriginalSize(drive: char; UserSID: string; fileid: string): integer; overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, true, fileid);
  result := RecyclerOriginalSize(infofile, fileid);
end;

function RecyclerOriginalSize(InfofileOrRecycleFolder: string; id: string): integer; overload;
var
  fs: TFileStream;
  i, record_length: integer;
  tmp: string;
const
  length_position = $C;
  unique_index_position = $118;
  original_size_position = $128;
begin
  result := -1;

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    result := _VistaOriginalSize(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      result := _VistaOriginalSize(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  if not fileexists(tmp) then exit;
  if not RecyclerIsValid(tmp) then exit;

  fs := TFileStream.Create(tmp, fmOpenRead);
  try
    fs.seek(length_position, soFromBeginning);
    record_length := _readInt32(fs);

    i := -1;
    repeat
      inc(i);
      if unique_index_position+i*record_length > fs.size then break;
      fs.seek(unique_index_position+i*record_length, soFromBeginning);
      if inttostr(_readInt32(fs)) = id then
      begin
        fs.seek(original_size_position+i*record_length, soFromBeginning);
        result := _readInt32(fs);
        break;
      end;
    until false;
  finally
    fs.free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerIsValid(drive: char): boolean; overload;
begin
  // Bei Vista und Win2003 (VM) erhalte ich bei LW A: die Meldung
  // "c0000013 Kein Datenträger". Exception Abfangen geht nicht.
  // Daher erstmal überprüfen, ob Laufwerk existiert.
  result := false;
  if not RecyclerIsPossible(drive) then exit;

  result := RecyclerIsValid(drive, '');
end;

function RecyclerIsValid(drive: char; UserSID: string): boolean; overload;
var
  infofile: string;
begin
  // Anmerkung siehe oben.
  result := false;
  if not RecyclerIsPossible(drive) then exit;

  infofile := RecyclerGetPath(drive, UserSID, false);
  result := RecyclerIsValid(infofile);
end;

function RecyclerIsValid(InfofileOrRecycleFolder: string): boolean; overload;
var
  tmp: string;
  x: TStringList;
  i: integer;
  eine_fehlerhaft: boolean;
begin
  result := false;

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    result := _VistaIsValid(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'INFO2') then
    begin
      result := _checkInfo1or2File(tmp+'INFO2');
    end;

    if not result and fileexists(tmp+'INFO') then
    begin
      result := _checkInfo1or2File(tmp+'INFO');
    end;

    if not result then
    begin
      // Complete vista-directory declared?
      eine_fehlerhaft := false;
      x := TStringList.Create;
      try
        _VistaListIndexes(tmp, x);
        for i := 0 to x.Count - 1 do
        begin
          if not _VistaIsValid(tmp+'$I'+x.Strings[i]) then
          begin
            eine_fehlerhaft := true;
          end;
        end;
      finally
        x.Free;
      end;
      result := not eine_fehlerhaft;
    end;
  end;

  if not fileexists(tmp) then exit;

  result := _checkInfo1or2File(tmp);
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerCurrentFilename(InfofileOrRecycleFolder: string): string; overload;
begin
  result := RecyclerCurrentFilename(InfofileOrRecycleFolder, '');
end;

function RecyclerCurrentFilename(drive: char; fileid: string): string; overload;
begin
  result := RecyclerCurrentFilename(drive, '', fileid);
end;

function RecyclerCurrentFilename(drive: char; UserSID: string; fileid: string): string; overload;
var
  infofile: string;
begin
  infofile := RecyclerGetPath(drive, UserSID, true, fileid);
  result := RecyclerCurrentFilename(infofile, fileid);
end;

function RecyclerCurrentFilename(InfofileOrRecycleFolder: string; id: string): string; overload;
var
  a, c: string;
  tmp: string;
begin
  result := '';

  tmp := InfofileOrRecycleFolder;

  if _isFileVistaNamed(tmp) then
  begin
    result := _VistaCurrentFilename(tmp);
    exit;
  end;

  {$IFDEF allow_all_filenames}
  if not RecyclerIsValid(tmp) and fileexists(tmp) then
  begin
    if fileexists(extractfilepath(tmp)+'INFO2') then
      tmp := extractfilepath(tmp)+'INFO2'
    else if fileexists(extractfilepath(tmp)+'INFO') then
      tmp := extractfilepath(tmp)+'INFO';
  end;
  {$ENDIF}

  if directoryexists(tmp) then
  begin
    tmp := IncludeTrailingBackslash(tmp);

    if fileexists(tmp+'$I'+id) then
    begin
      result := _VistaCurrentFilename(tmp+'$I'+id);
      exit;
    end
    else if fileexists(tmp+'INFO2') then tmp := tmp+'INFO2'
    else if fileexists(tmp+'INFO') then  tmp := tmp+'INFO';
  end;

  a := RecyclerGetSourceDrive(tmp, id);
  c := extractfileext(RecyclerGetSourceUnicode(tmp, id));
  if (a <> '') then
  begin
    result := 'D' + a + id + c;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerGetPath(drive: char; UserSID: string; IncludeInfofile: boolean; fileid: string): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RecyclerGetInfofiles(drive, UserSID, IncludeInfofile, fileid, sl);
    if sl.Count > 0 then
      result := ExtractFilePath(sl.Strings[0])
    else
      result := '';
  finally
    sl.free;
  end;
end;

function RecyclerGetPath(drive: char; UserSID: string; IncludeInfofile: boolean): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RecyclerGetInfofiles(drive, UserSID, IncludeInfofile, sl);
    if sl.Count > 0 then
      result := ExtractFilePath(sl.Strings[0])
    else
      result := '';
  finally
    sl.free;
  end;
end;

function RecyclerGetPath(drive: char; IncludeInfofile: boolean): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RecyclerGetInfofiles(drive, IncludeInfofile, sl);
    if sl.Count > 0 then
      result := ExtractFilePath(sl.Strings[0])
    else
      result := '';
  finally
    sl.free;
  end;
end;

function RecyclerGetPath(drive: char; UserSID: string): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RecyclerGetInfofiles(drive, UserSID, sl);
    if sl.Count > 0 then
      result := ExtractFilePath(sl.Strings[0])
    else
      result := '';
  finally
    sl.free;
  end;
end;

function RecyclerGetPath(drive: char): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RecyclerGetInfofiles(drive, sl);
    if sl.Count > 0 then
      result := ExtractFilePath(sl.Strings[0])
    else
      result := '';
  finally
    sl.free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure RecyclerGetInfofiles(drive: char; UserSID: string; IncludeInfofile: boolean; fileid: string; result: TStringList); overload;
var
  dir: string;
begin
  // Find recyclers from Windows Vista or higher

  if _isFAT(drive) then
  begin
    dir := drive + DriveDelim + PathDelim + '$recycle.bin' + PathDelim;
    if IncludeInfofile and (fileid <> '') then
    begin
      if fileExists(dir + '$I'+fileid) then
      begin
        result.Add(dir + '$I'+fileid);
      end;
    end
    else
    begin
      if directoryExists(dir) then
      begin
        result.Add(dir);
      end;
    end;
  end
  else
  begin
    if UserSID <> '' then
    begin
      dir := drive + DriveDelim + PathDelim + '$recycle.bin'+PathDelim+UserSID+PathDelim;
      if IncludeInfofile and (fileid <> '') then
      begin
        if fileExists(dir + '$I'+fileid) then
        begin
          result.Add(dir + '$I'+fileid);
        end;
      end
      else
      begin
        if directoryExists(dir) then
        begin
          result.Add(dir);
        end;
      end;
    end
    else
    begin
      // TODO: aber vielleicht möchte man die Papierkörbe aller Benutzer (also aller SIDs) finden!!!
      dir := drive + DriveDelim + PathDelim + '$recycle.bin'+PathDelim+_getMySID()+PathDelim;
      if IncludeInfofile and (fileid <> '') then
      begin
        if fileExists(dir + '$I'+fileid) then
        begin
          result.Add(dir + '$I'+fileid);
        end;
      end
      else
      begin
        if directoryExists(dir) then
        begin
          result.Add(dir);
        end;
      end;
    end;
  end;

  // Find recyclers from Windows before Vista

  if _isFAT(drive) then
  begin
    dir := drive + DriveDelim + PathDelim + 'Recycled' + PathDelim;
    if IncludeInfofile then
    begin
      // Both "recycle bins" are possible if you have multiboot (but do overwrite themselfes if you empty them)
      if fileExists(dir + 'INFO2') then
        result.Add(dir + 'INFO2'); // Windows 95 with Internet Explorer 4 Extension or higher Windows versions
      if fileExists(dir + 'INFO') then
        result.Add(dir + 'INFO'); // Windows 95 native
    end
    else
    begin
      if directoryExists(dir) then
        result.Add(dir);
    end;
  end
  else
  begin
    if UserSID <> '' then
    begin
      dir := drive + DriveDelim + PathDelim + 'Recycler'+PathDelim+UserSID+PathDelim;
      if IncludeInfofile then
      begin
        if fileExists(dir + 'INFO2') then
          result.Add(dir + 'INFO2');
        if fileExists(dir + 'INFO') then
          result.Add(dir + 'INFO'); // Windows NT 4
      end
      else
      begin
        if directoryExists(dir) then
          result.Add(dir);
      end;
    end
    else
    begin
      dir := drive + DriveDelim + PathDelim + 'Recycler'+PathDelim+_getMySID()+PathDelim;
      if IncludeInfofile then
      begin
        if fileExists(dir + 'INFO2') then
          result.Add(dir + 'INFO2');
        if fileExists(dir + 'INFO') then
          result.Add(dir + 'INFO'); // Windows NT 4
      end
      else
      begin
        if directoryExists(dir) then
          result.Add(dir);
      end;
    end;
  end;
end;

procedure RecyclerGetInfofiles(drive: char; UserSID: string; IncludeInfofile: boolean; result: TStringList); overload;
begin
  RecyclerGetInfofiles(drive, UserSID, IncludeInfofile, '', result);
end;

procedure RecyclerGetInfofiles(drive: char; IncludeInfofile: boolean; result: TStringList); overload;
begin
  RecyclerGetInfofiles(drive, '', IncludeInfofile, '', result);
end;

procedure RecyclerGetInfofiles(drive: char; UserSID: string; result: TStringList); overload;
begin
  RecyclerGetInfofiles(drive, UserSID, false, '', result);
end;

procedure RecyclerGetInfofiles(drive: char; result: TStringList); overload;
begin
  RecyclerGetInfofiles(drive, '', false, '', result);
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerCurrentFilenameAndPath(drive: char; UserSID: string; fileid: string): string; overload;
begin
  result := RecyclerGetPath(drive, UserSID, false, fileid) +
    RecyclerCurrentFilename(drive, UserSID, fileid);
end;

function RecyclerCurrentFilenameAndPath(drive: char; fileid: string): string; overload;
begin
  result := RecyclerCurrentFilenameAndPath(drive, '', fileid);
end;

function RecyclerCurrentFilenameAndPath(InfofileOrRecycleFolder: string; id: string): string; overload;
begin
  if RecyclerIsValid(InfofileOrRecycleFolder) then
  begin
    result := extractfilepath(InfofileOrRecycleFolder) +
      RecyclerCurrentFilename(InfofileOrRecycleFolder, id);
  end
  else
    result := '';
end;

////////////////////////////////////////////////////////////////////////////////

function RecyclerRemoveItem(drive: char; UserSID: string; fileid: string): boolean; overload;
var
  tmp: string;
begin
  tmp := RecyclerCurrentFilenameAndPath(drive, UserSID, fileid);
  if fileexists(tmp) then
  begin
    deletefile(tmp);
    result := fileexists(tmp);
  end
  else
  begin
    directoryexists(tmp);
    result := directoryexists(tmp);
  end;
end;

function RecyclerRemoveItem(drive: char; fileid: string): boolean; overload;
begin
  result := RecyclerRemoveItem(drive, '', fileid);
end;

function RecyclerRemoveItem(InfofileOrRecycleFolder: string; id: string): boolean; overload;
var
  tmp: string;
begin
  tmp := RecyclerCurrentFilenameAndPath(InfofileOrRecycleFolder, id);
  if fileexists(tmp) then
  begin
    deletefile(tmp);
    result := fileexists(tmp);
  end
  else
  begin
    _DeleteDirectory(tmp);
    result := directoryexists(tmp);
  end;
end;

procedure RecyclerGetAllRecyclerDrives(result: TStringList);
var
  Drive: char;
begin
  for Drive := 'A' to 'Z' do
  begin
    if RecyclerIsPossible(Drive) and RecyclerIsValid(Drive) then
    begin
      result.Add(Drive);
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

// http://www.dsdt.info/tipps/?id=176
function RecyclerEmptyRecycleBin(flags: cardinal): boolean; overload;
type
  TSHEmptyRecycleBin = function (Wnd: HWND;
                                 pszRootPath: PChar;
                                 dwFlags: DWORD):
                                 HRESULT; stdcall;
var
  PSHEmptyRecycleBin: TSHEmptyRecycleBin;
  LibHandle: THandle;
const
  {$IFDEF UNICODE}
  C_SHEmptyRecycleBin = 'SHEmptyRecycleBinW';
  {$ELSE}
  C_SHEmptyRecycleBin = 'SHEmptyRecycleBinA';
  {$ENDIF}
begin
  result := true;
  LibHandle := LoadLibrary(shell32) ;
  try
    if LibHandle <> 0 then
    begin
      @PSHEmptyRecycleBin:= GetProcAddress(LibHandle, C_SHEmptyRecycleBin);
      if @PSHEmptyRecycleBin <> nil then
      begin
        PSHEmptyRecycleBin(hInstance, nil, flags);
      end
      else
        result := false;
    end
    else
      result := false;
  finally
    @PSHEmptyRecycleBin := nil;
    FreeLibrary(LibHandle);
  end;
end;

function RecyclerEmptyRecycleBin(sound, progress, confirmation: boolean): boolean; overload;
const
  SHERB_NOCONFIRMATION = $00000001;
  SHERB_NOPROGRESSUI   = $00000002;
  SHERB_NOSOUND        = $00000004;
var
  flags: cardinal;
begin
  flags := 0;

  if not progress then
    flags := flags or SHERB_NOPROGRESSUI;
  if not confirmation then
    flags := flags or SHERB_NOCONFIRMATION;
  if not sound then
    flags := flags or SHERB_NOSOUND;

  result := RecyclerEmptyRecycleBin(flags);
end;

////////////////////////////////////////////////////////////////////////////////

// Template
// http://www.dsdt.info/tipps/?id=116
function RecyclerAddFileOrFolder(FileOrFolder: string; confirmation: boolean): boolean; overload;
var
  Operation: TSHFileOpStruct;
begin
  with Operation do
  begin
    Wnd := hInstance; // OK?
    wFunc := FO_DELETE;
    pFrom := PChar(FileOrFolder + #0);
    pTo := nil;
    fFlags := FOF_ALLOWUNDO;
    if not confirmation then fFlags := fFlags or FOF_NOCONFIRMATION;
  end;
  Result := SHFileOperation(Operation) = 0;
end;

function RecyclerAddFileOrFolder(FileOrFolder: string): boolean; overload;
begin
  result := RecyclerAddFileOrFolder(FileOrFolder, false);
end;

function RecyclerConfirmationDialogEnabled: boolean;
var
  gp: GPOLICYBOOL;
begin
  gp := RecyclerGroupPolicyConfirmFileDelete;
  if gp <> gpUndefined then
  begin
    result := gp = gpEnabled;
  end
  else
  begin
    result := RecyclerShellStateConfirmationDialogEnabled;
  end;
end;

function RecyclerShellStateConfirmationDialogEnabled: boolean;
type
  TSHGetSettings = procedure (var lpss: SHELLSTATE; dwMask: DWORD); stdcall;
const
  C_SHGetSettings = 'SHGetSettings';
var
  lpss: SHELLSTATE;
  bNoConfirmRecycle: boolean;

  PSHGetSettings: TSHGetSettings;
  RBHandle: THandle;

  reg: TRegistry;
  rbuf: array[0..255] of byte;
begin
  PSHGetSettings := nil;
  result := false; // Avoid warning message

  RBHandle := LoadLibrary(shell32);
  if(RBHandle <> 0) then
  begin
    PSHGetSettings := GetProcAddress(RBHandle, C_SHGetSettings);
    if (@PSHGetSettings = nil) then
    begin
      FreeLibrary(RBHandle);
      RBHandle := 0;
    end;
  end;

  if (RBHandle <> 0) and (Assigned(PSHGetSettings)) then
  begin
    ZeroMemory(@lpss, SizeOf(lpss));
    PSHGetSettings(lpss, SSF_NOCONFIRMRECYCLE);
    // bNoConfirmRecycle := (lpss.Flags1 and 4) = 4; // fNoConfirmRecycle
    bNoConfirmRecycle := GetByteBit(lpss.Flags1, 2);

    result := not bNoConfirmRecycle;
  end
  else
  begin
    reg := TRegistry.Create;
    try
      // API function call failed. Probably because Windows is too old.
      // Try to read out from registry.
      // The 3rd bit of the 5th byte of "ShellState" is the value
      // of "fNoConfirmRecycle".

      reg.RootKey := HKEY_CURRENT_USER;
      if (reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Explorer')) then
      begin
        ZeroMemory(@rbuf, SizeOf(rbuf));
        reg.ReadBinaryData('ShellState', rbuf, SizeOf(rbuf));

        // Lese 3tes Bit vom 5ten Byte
        // bNoConfirmRecycle := ((rbuf[4] and 4) = 4);
        bNoConfirmRecycle := GetByteBit(rbuf[4], 2);
        result := not bNoConfirmRecycle;

        reg.CloseKey;
      end
      else
      begin
        raise EAPICallError.CreateFmt(LNG_API_CALL_ERROR, [Format(LNG_NOT_CALLABLE, [C_SHGetSettings])]);
      end;
    finally
      reg.Free;
    end;
  end;

  if (RBHandle <> 0) then FreeLibrary(RBHandle);
end;

procedure RecyclerConfirmationDialogSetEnabled(NewSetting: boolean);
type
  TSHGetSetSettings = procedure (var lpss: SHELLSTATE; dwMask: DWORD; bSet: BOOL); stdcall;
const
  C_SHGetSetSettings = 'SHGetSetSettings';
var
  lpss: SHELLSTATE;

  PSHGetSetSettings: TSHGetSetSettings;
  RBHandle: THandle;

  reg: TRegistry;
  rbuf: array[0..255] of byte;

  //dwResult: DWORD;
  lpdwResult: PDWORD_PTR;
begin
  PSHGetSetSettings := nil;
  lpdwResult := nil;

  RBHandle := LoadLibrary(shell32);
  if(RBHandle <> 0) then
  begin
    PSHGetSetSettings := GetProcAddress(RBHandle, C_SHGetSetSettings);
    if (@PSHGetSetSettings = nil) then
    begin
      FreeLibrary(RBHandle);
      RBHandle := 0;
    end;
  end;

  if (RBHandle <> 0) and (Assigned(PSHGetSetSettings)) then
  begin
    ZeroMemory(@lpss, SizeOf(lpss));
    PSHGetSetSettings(lpss, SSF_NOCONFIRMRECYCLE, false); // Get
    lpss.Flags1 := SetByteBit(lpss.Flags1, 2, NewSetting);
    PSHGetSetSettings(lpss, SSF_NOCONFIRMRECYCLE, true); // Set

    SendMessageTimeout (
      HWND_BROADCAST, WM_SETTINGCHANGE,
      0, lParam (pChar ('ShellState')),
      SMTO_ABORTIFHUNG, 5000, lpdwResult(*dwResult*)
    );
  end
  else
  begin
    reg := TRegistry.Create;
    try
      // API function call failed. Probably because Windows is too old.
      // Try to read out from registry.
      // The 3rd bit of the 5th byte of "ShellState" is the value
      // of "fNoConfirmRecycle".

      reg.RootKey := HKEY_CURRENT_USER;
      if (reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer', false)) then
      begin
        ZeroMemory(@rbuf, SizeOf(rbuf));
        reg.ReadBinaryData('ShellState', rbuf, SizeOf(rbuf)); // Get
        rbuf[4] := SetByteBit(rbuf[4], 2, NewSetting);
        reg.WriteBinaryData('ShellState', rbuf, SizeOf(rbuf)); // Set

        SendMessageTimeout (
          HWND_BROADCAST, WM_SETTINGCHANGE,
          0, lParam (pChar ('ShellState')),
          SMTO_ABORTIFHUNG, 5000, lpdwResult(*dwResult*)
        );

        reg.CloseKey;
      end
      else
      begin
        raise EAPICallError.CreateFmt(LNG_API_CALL_ERROR, [Format(LNG_NOT_CALLABLE, [C_SHGetSetSettings])]);
      end;
    finally
      reg.Free;
    end;
  end;

  if (RBHandle <> 0) then FreeLibrary(RBHandle);
end;

function RecyclerGetCurrentIconString: string;
begin
  if RecyclerIsEmpty then
    result := RecyclerGetEmptyIconString
  else
    result := RecyclerGetFullIconString;
end;

function RecyclerGetDefaultIconString: string;
var
  reg: TRegistry;
begin
  // Please note: The "default" icon is not always the icon of the
  // current recycle bin in its current state (full, empty)
  // At Windows 95b, the registry value actually did change every time the
  // recycle bin state did change, but at Windows 2000 I could not see any
  // update, even after reboot. So, the registry value is possible fixed as
  // default = empty on newer OS versions.

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID+'\DefaultIcon') then
    begin
      result := reg.ReadString('');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetEmptyIconString: string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID+'\DefaultIcon') then
    begin
      result := reg.ReadString('Empty');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetFullIconString: string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID+'\DefaultIcon') then
    begin
      result := reg.ReadString('Full');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetName: string;
var
  reg: TRegistry;
begin
  // Windows 95b:
  // Change of CLSID\{645FF040-5081-101B-9F08-00AA002F954E} will change the desktop name of the recycle bin.

  // Windows 2000: If LocalizedString is available, the 3rd argument will be parsed
  // (if the third argument will removed, it will be read out from the DLL resource string automatically)

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID) then
    begin
      if reg.ValueExists('LocalizedString') then
      begin
        result := reg.ReadString('LocalizedString');
        result := _DecodeReferenceString(result);
      end
      else
      begin
        result := reg.ReadString('');
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetInfoTip: string;
var
  reg: TRegistry;
begin
  // Not available in some older versions of Windows

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID) then
    begin
      result := reg.ReadString('InfoTip');
      result := _DecodeReferenceString(result);

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetIntroText: string;
var
  reg: TRegistry;
begin
  // Not available in some older versions of Windows

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('CLSID\'+RECYCLER_CLSID) then
    begin
      result := reg.ReadString('IntroText');
      result := _DecodeReferenceString(result);

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerEmptyEventGetName: string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('AppEvents\EventLabels\EmptyRecycleBin') then
    begin
      result := reg.ReadString('');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerEmptyEventGetCurrentSound: string;
begin
  result := RecyclerEmptyEventGetSound('.Current');
end;

function RecyclerEmptyEventGetDefaultSound: string;
begin
  result := RecyclerEmptyEventGetSound('.Default');
end;

procedure RecyclerEmptyEventGetSoundCategories(AStringList: TStringList);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('AppEvents\Schemes\Apps\Explorer\EmptyRecycleBin') then
    begin
      reg.GetKeyNames(AStringList);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerEmptyEventGetSound(ACategory: string): string;
var
  reg: TRegistry;
resourcestring
  LNG_SND_EVENT_CAT_ERROR = 'The category "%s" is not available for the notification event "%s".';
begin
  // Outputs an filename or empty string for no sound defined.

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('AppEvents\Schemes\Apps\Explorer\EmptyRecycleBin') then
    begin
      if reg.OpenKeyReadOnly(ACategory) then
      begin
        result := reg.ReadString('');
        reg.CloseKey;
      end
      else
        raise EEventCategoryNotDefined.CreateFmt(LNG_SND_EVENT_CAT_ERROR, [ACategory, 'EmptyRecycleBin']);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGlobalGetPercentUsage: integer;
var
  reg: TRegistry;
  dump: string;
const
  RES_DEFAULT = 10;
begin
  result := -1;

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      if reg.ValueExists('Percent') then
      begin
        // Windows 2000 - Informationen liegen aufgeschlüsselt in der Registry

        result := reg.ReadInteger('Percent');
      end
      else if reg.ValueExists('PurgeInfo') then
      begin
        // Windows 95 - Verschlüsselte Informationen liegen in PurgeInfo

        dump := _registryReadDump(reg, 'PurgeInfo');
        result := Ord(dump[63]);
      end
      else
      begin
        // Windows 95 - Standardwerte sind gegeben, deswegen existiert kein PurgeInfo

        result := RES_DEFAULT; // Standardeinstellung bei Windows
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerSpecificGetPercentUsage(Drive: Char): integer;
var
  reg: TRegistry;
  dump: string;
const
  RES_DEFAULT = 10;
begin
  result := -1;

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      if reg.OpenKeyReadOnly(Drive) then
      begin
        if reg.ValueExists('Percent') then
        begin
          // Windows 2000 - Informationen liegen aufgeschlüsselt in der Registry

          result := reg.ReadInteger('Percent');
        end
        else
        begin
          result := RES_DEFAULT;
        end;
        reg.CloseKey;
      end
      else
      begin
        if reg.ValueExists('PurgeInfo') then
        begin
          // Windows 95 - Verschlüsselte Informationen liegen in PurgeInfo

          dump := _registryReadDump(reg, 'PurgeInfo');

          // NOT tested, only theoretical! My idea about the possible structure is:
          // 0x08 = Drive A
          // 0x0a = Drive B
          // 0x0c = Drive C (validated)
          // 0x0e = Drive D
          // ...

          result := Ord(dump[9+_DriveNum(Drive)*2]);
        end
        else
        begin
          // Windows 95 - Standardwerte sind gegeben, deswegen existiert kein PurgeInfo

          result := RES_DEFAULT; // Standardeinstellung bei Windows
        end;
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerGetPercentUsageAutoDeterminate(Drive: Char): integer;
var
  gpSetting: integer;
begin
  gpSetting := RecyclerGroupPolicyRecycleBinSize;
  if gpSetting <> -1 then
    result := gpSetting
  else if RecyclerHasGlobalSettings then
    result := RecyclerGlobalGetPercentUsage
  else
    result := RecyclerSpecificGetPercentUsage(Drive);
end;

function RecyclerGlobalIsNukeOnDelete: boolean;
var
  reg: TRegistry;
  dump: AnsiString;
const
  RES_DEFAULT = false;
begin
  result := false;

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      if reg.ValueExists('NukeOnDelete') then
      begin
        // Windows 2000 - Informationen liegen aufgeschlüsselt in der Registry

        result := reg.ReadBool('NukeOnDelete');
      end
      else if reg.ValueExists('PurgeInfo') then
      begin
        // Windows 95 - Verschlüsselte Informationen liegen in PurgeInfo

        // See comment at RecyclerSpecificIsNukeOnDelete()

        dump := AnsiString(_registryReadDump(reg, 'PurgeInfo'));
        result := GetAnsiCharBit(dump[68], 3);
      end
      else
      begin
        // Windows 95 - Standardwerte sind gegeben, deswegen existiert kein PurgeInfo

        result := RES_DEFAULT; // Standardeinstellung bei Windows
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerSpecificIsNukeOnDelete(Drive: Char): boolean;
var
  reg: TRegistry;
  dump: AnsiString;
  d: Byte;
const
  RES_DEFAULT = false;
begin
  result := false;

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      if reg.OpenKeyReadOnly(Drive) then
      begin
        if reg.ValueExists('NukeOnDelete') then
        begin
          // Windows 2000 - Informationen liegen aufgeschlüsselt in der Registry

          result := reg.ReadBool('NukeOnDelete');
        end;
        reg.CloseKey;
      end
      else
      begin
        if reg.ValueExists('PurgeInfo') then
        begin
          // Windows 95 - Verschlüsselte Informationen liegen in PurgeInfo

          dump := AnsiString(_registryReadDump(reg, 'PurgeInfo'));

          // NOT tested, only theoretical! My idea about the possible structure is:
          //
          // Byte      0x40       0x41       0x42       0x43
          // Bit       76543210   76543210   76543210   76543210
          //           --------   --------   --------   --------
          // Meaning   hgfedcba   ponmlkji   xwvutsrq   ????G?zy
          //
          // a..z = Drives
          // G    = global settings
          //
          // Already validated:
          // 0x64 = 04 (00000100)
          // 0x67 = 08 (00001000)

          d := _DriveNum(Drive);
          result := GetAnsiCharBit(dump[65+(d div 7)], d mod 7);
        end
        else
        begin
          // Windows 95 - Standardwerte sind gegeben, deswegen existiert kein PurgeInfo

          result := RES_DEFAULT; // Standardeinstellung bei Windows
        end;
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerIsNukeOnDeleteAutoDeterminate(Drive: Char): boolean;
begin
  if RecyclerGroupPolicyNoRecycleFiles = gpEnabled then
    result := true
  else if RecyclerHasGlobalSettings then
    result := RecyclerGlobalIsNukeOnDelete
  else
    result := RecyclerSpecificIsNukeOnDelete(Drive);
end;

function RecyclerHasGlobalSettings: boolean;
var
  reg: TRegistry;
  dump: string;
begin
  result := false;
  
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket') then
    begin
      if reg.ValueExists('UseGlobalSettings') then
      begin
        // Windows 2000 - Informationen liegen aufgeschlüsselt in der Registry

        result := reg.ReadBool('UseGlobalSettings');
      end
      else if reg.ValueExists('PurgeInfo') then
      begin
        // Windows 95 - Verschlüsselte Informationen liegen in PurgeInfo
        // TODO: Gibt es ein offizielles Dokument oder ein API, indem PurgeInfo
        // offiziell entschlüsselbar ist?

        dump := _registryReadDump(reg, 'PurgeInfo');
        if dump[5] = #$01 then
          result := true
        else if dump[5] = #$00 then
          result := false
        else
          raise EUnknownState.Create(Format(LNG_UNEXPECTED_STATE, ['PurgeInfo']));
      end
      else
      begin
        // Windows 95 - Standardwerte sind gegeben, deswegen existiert kein PurgeInfo

        result := true; // Standardeinstellung bei Windows
      end;

      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function RecyclerIsEmpty: boolean;
var
  Drive: Char;
begin
  result := true;
  for Drive := 'A' to 'Z' do
  begin
    if RecyclerIsPossible(Drive) and not RecyclerIsEmpty(Drive) then
    begin
      result := false;
      exit;
    end;
  end;
end;

function RecyclerIsEmpty(Drive: Char): boolean;
begin
  result := RecyclerGetAPIInfo(Drive).i64NumItems = 0;
end;

function RecyclerGetNumItems: int64;
var
  Drive: Char;
begin
  result := 0;
  for Drive := 'A' to 'Z' do
  begin
    if RecyclerIsPossible(Drive) then
    begin
      result := result + RecyclerGetNumItems(Drive);
    end;
  end;
end;

function RecyclerGetNumItems(Drive: Char): int64;
begin
  result := RecyclerGetAPIInfo(Drive).i64NumItems;
end;

function RecyclerGetSize: int64;
var
  Drive: Char;
begin
  result := 0;
  for Drive := 'A' to 'Z' do
  begin
    if RecyclerIsPossible(Drive) then
    begin
      result := result + RecyclerGetSize(Drive);
    end;
  end;
end;

function RecyclerGetSize(Drive: Char): int64;
begin
  result := RecyclerGetAPIInfo(Drive).i64Size;
end;

function RecyclerGetAPIInfo(Drive: Char): TSHQueryRBInfo;
begin
  result := RecyclerGetAPIInfo(Drive + ':\');
end;

const
  {$IFDEF UNICODE}
  C_SHQueryRecycleBin = 'SHQueryRecycleBinW';
  {$ELSE}
  C_SHQueryRecycleBin = 'SHQueryRecycleBinA';
  {$ENDIF}

type
  TSHQueryRecycleBin = function(pszRootPath: LPCTSTR;
    var pSHQueryRBInfo: TSHQueryRBInfo): HRESULT; stdcall;

function RecyclerGetAPIInfo(Path: String): TSHQueryRBInfo;
var
  PSHQueryRecycleBin: TSHQueryRecycleBin;
  RBHandle: THandle;
  res: HRESULT;
begin
  PSHQueryRecycleBin := nil;

  // Ref: http://www.delphipraxis.net/post1291.html

  RBHandle := LoadLibrary(shell32);
  if(RBHandle <> 0) then
  begin
    PSHQueryRecycleBin := GetProcAddress(RBHandle, C_SHQueryRecycleBin);
    if(@PSHQueryRecycleBin = nil) then
    begin
      FreeLibrary(RBHandle);
      RBHandle := 0;
    end;
  end;

  fillchar(result, SizeOf(TSHQueryRBInfo),0);
  result.cbSize := SizeOf(TSHQueryRBInfo);

  if (RBHandle <> 0) and (Assigned(PSHQueryRecycleBin)) then
  begin
    res := PSHQueryRecycleBin(PChar(Path), result);
    // if Succeeded(res) then
    if res = S_OK then
    begin
      // Alles OK, unser result hat nun die gewünschten Daten.
    end
    else
    begin
      // Since Windows Vista, SHQueryRecycleBin will fail with E_FAIL (80004005)
      // if Path is a floppy or CD drive...
      raise EAPICallError.CreateFmt(LNG_API_CALL_ERROR, [Format(LNG_ERROR_CODE, [C_SHQueryRecycleBin, Path, '0x'+IntToHex(res, 2*SizeOf(HRESULT))])]);
    end;
  end
  else
    raise EAPICallError.CreateFmt(LNG_API_CALL_ERROR, [Format(LNG_NOT_CALLABLE, [C_SHQueryRecycleBin])]);

  if (RBHandle <> 0) then FreeLibrary(RBHandle);
end;

function RecyclerGetCLSID: string;
begin
  result := RECYCLER_CLSID;
end;

// Windows 95 without Internet Explorer 4 has no SHQueryRecycleBinA.
function RecyclerQueryFunctionAvailable: boolean;
var
  RBHandle: THandle;
  SHQueryRecycleBin: TSHQueryRecycleBin;
begin
  RBHandle := LoadLibrary(shell32);
  if(RBHandle <> 0) then
  begin
    SHQueryRecycleBin := GetProcAddress(RBHandle, C_SHQueryRecycleBin);
    if(@SHQueryRecycleBin = nil) then
    begin
      FreeLibrary(RBHandle);
      RBHandle := 0;
    end;
  end;

  result := RBHandle <> 0;
end;

const
  GroupPolicyAcceptHKLMTrick = true;

// TODO: In future also detect for other users
// TODO: Also make a setter (inkl. Message to Windows Explorer?)
function RecyclerGroupPolicyNoRecycleFiles: GPOLICYBOOL;
var
  reg: TRegistry;
begin
  result := gpUndefined;

  reg := TRegistry.Create;
  try
    // If a value is set in HKEY_LOCAL_MACHINE, it will be prefered,
    // even if gpedit.msc shows "Not configured"!
    if GroupPolicyAcceptHKLMTrick then
    begin
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
      begin
        if reg.ValueExists('NoRecycleFiles') then
        begin
          if reg.ReadBool('NoRecycleFiles') then
            result := gpEnabled
          else
            result := gpDisabled;
          Exit;
        end;
        reg.CloseKey;
      end;
    end;

    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
    begin
      if reg.ValueExists('NoRecycleFiles') then
      begin
        if reg.ReadBool('NoRecycleFiles') then
          result := gpEnabled
        else
          result := gpDisabled;
      end;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

// TODO: In future also detect for other users
// TODO: Also make a setter (inkl. Message to Windows Explorer?)
function RecyclerGroupPolicyConfirmFileDelete: GPOLICYBOOL;
var
  reg: TRegistry;
begin
  result := gpUndefined;
  reg := TRegistry.Create;
  try
    // If a value is set in HKEY_LOCAL_MACHINE, it will be prefered,
    // even if gpedit.msc shows "Not configured"!
    if GroupPolicyAcceptHKLMTrick then
    begin
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
      begin
        if reg.ValueExists('ConfirmFileDelete') then
        begin
          if reg.ReadBool('ConfirmFileDelete') then
            result := gpEnabled
          else
            result := gpDisabled;
          Exit;
        end;
        reg.CloseKey;
      end;
    end;

    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
    begin
      if reg.ValueExists('ConfirmFileDelete') then
      begin
        if reg.ReadBool('ConfirmFileDelete') then
          result := gpEnabled
        else
          result := gpDisabled;
      end;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;


// TODO: In future also detect for other users
// TODO: Also make a setter (inkl. Message to Windows Explorer?)
function RecyclerGroupPolicyRecycleBinSize: integer;
var
  reg: TRegistry;
begin
  result := -1;
  reg := TRegistry.Create;
  try
    // If a value is set in HKEY_LOCAL_MACHINE, it will be prefered,
    // even if gpedit.msc shows "Not configured"!
    if GroupPolicyAcceptHKLMTrick then
    begin
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
      begin
        if reg.ValueExists('RecycleBinSize') then
        begin
          result := reg.ReadInteger('RecycleBinSize');
          Exit;
        end;
        reg.CloseKey;
      end;
    end;

    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Policies\Explorer') then
    begin
      if reg.ValueExists('RecycleBinSize') then
      begin
        result := reg.ReadInteger('RecycleBinSize');
      end;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function GPBoolToString(value: GPOLICYBOOL): String;
begin
  case value of
    gpUndefined: result := 'Not configured';
    gpEnabled: result := 'Enabled';
    gpDisabled: result := 'Disabled';
  end;
end;

function RecyclerIsPossible(Drive: Char): boolean;
var
  typ: Integer;
begin
  typ := GetDriveType(PChar(Drive + ':\'));
  result := typ = DRIVE_FIXED;
end;

function RecyclerLibraryVersion: string;
begin
  result := 'ViaThinkSoft Recycle Bin Unit [30 JUN 2022]';
end;

end.
