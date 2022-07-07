unit RecBinUnitLowLvl;

interface

uses
  Windows;

type
  PRbInfoHeader = ^TRbInfoHeader;
  TRbInfoHeader = packed record
    format: DWORD;         // Version of the info file
                           // Win95 (without IE4):   00 00 00 00
                           // Win NT4:               02 00 00 00   (Win96/Cairo?)
                           // Win95 (with IE4), 98:  04 00 00 00
                           // Win Me, 2000, XP:      05 00 00 00   (NT4+IE4, NT5?)
    totalEntries: DWORD;   // Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons
    nextPossibleID: DWORD; // Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons
    recordLength: DWORD;   // 0x118  =  ANSI records
                           // 0x320  =  Unicode records
    totalSize: DWORD;      // sum of all "originalSize" values;
                           // Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons
  end;

type
  // Windows 95:      INFO file with TRbInfoRecordA; Folder deletion NOT possible
  // Windows 95 +IE4: INFO2 file with TRbInfoRecordA; Folder deletion possible
  PRbInfoRecordA = ^TRbInfoRecordA;
  TRbInfoRecordA = packed record
    sourceAnsi: array[0..MAX_PATH-1] of AnsiChar; // 260 characters (including NUL terminator)
    recordNumber: DWORD;
    sourceDrive: DWORD; // 0=A, 1=B, 2=C, ..., 25=Z, 26=@ (this is the "Network home drive" of the Win95 days)
    deletionTime: FILETIME;
    originalSize: DWORD; // Size occupied on disk. Not the actual file size.
                         // INFO2, for folders: The whole folder size with contents
  end;

type
  // Windows NT4:   INFO file with TRbInfoRecordW; Folder deletion possible
  // Windows 2000+: INFO2 file with TRbInfoRecordW; Folder deletion possible
  PRbInfoRecordW = ^TRbInfoRecordW;
  TRbInfoRecordW = packed record
    sourceAnsi: array[0..MAX_PATH-1] of AnsiChar; // 260 characters (including NUL terminator)
    recordNumber: DWORD;
    sourceDrive: DWORD; // 0=A, 1=B, 2=C, ..., 25=Z, 26=@ (this is the "Network home drive" of the Win95 days)
    deletionTime: FILETIME;
    originalSize: DWORD;
    sourceUnicode: array[0..MAX_PATH-1] of WideChar; // 260 characters (including NUL terminator)
  end;

type
  // Introduced in Windows Vista
  PRbVistaRecord1 = ^TRbVistaRecord1;
  TRbVistaRecord1 = packed record
    version: int64; // Always 01 00 00 00 00 00 00 00
    originalSize: int64;
    deletionTime: FILETIME;
    sourceUnicode: array[0..MAX_PATH-1] of WideChar;
  end;

type
  // Introduced somewhere in a Win10 release
  PRbVistaRecord2Head = ^TRbVistaRecord2Head;
  TRbVistaRecord2Head = packed record
    version: int64; // Always 02 00 00 00 00 00 00 00
    originalSize: int64;
    deletionTime: FILETIME;
    sourceCountChars: DWORD; // including NUL
    //sourceUnicode: array[0..sourceCountChars-1] of WideChar;
  end;

type
  // Windows 95 (tested with 4.00.180 and above) + Windows NT 4
  // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket: PurgeInfo (Binary)
  // TODO: also explain this in FORMAT.md ?
  PRbWin95PurgeInfo = ^TRbWin95PurgeInfo;
  TRbWin95PurgeInfo = packed record
    cbSize: DWORD; // 0x48 = 72
    bGlobalSettings: BOOL;
    percentDrive: array['A'..'Z'] of WORD; // 0x00..0x64 = 0%..100%
    percentHomedrive: WORD;
    percentGlobal: WORD;
    NukeOnDeleteBits: DWORD; // Flags "Nuke on delete"
                             // Bit 0 (LSB): Drive A
                             // Bit 1: Drive B
                             // ...
                             // Bit 25: Drive Z
                             // Bit 26: "Network home drive"
                             // Bit 27: Global
                             // Bit 28..31 (MSB) unused
    dummy: DWORD; // "dummy to force a new size" ?! But the 0x48 format was already in Win95 beta build 180, which is the first known build with this recycle bin implementation!
  end;

implementation

end.
