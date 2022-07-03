unit RecBinUnitLowLvl;

// TODO: Gain more information about drive '@' / Homedrive / Netdrive?

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
    totalEntries: DWORD;   // Only Win95 (without IE4) and Win NT4, other OS versions might use the registry instead
    nextPossibleID: DWORD; // Only Win95 (without IE4) and Win NT4, other OS versions might use the registry instead
    recordLength: DWORD;   // 0x181  =  ANSI records
                           // 0x320  =  Unicode records
    totalSize: DWORD;      // sum of all "originalSize" values;
                           // Only Win95 (without IE4) and Win NT4, other OS versions might use the registry instead
  end;

type
  // Windows 95:      INFO file with TRbInfoRecordA; Folder deletion NOT possible
  // Windows 95 +IE4: INFO2 file with TRbInfoRecordA; Folder deletion possible
  PRbInfoRecordA = ^TRbInfoRecordA;
  TRbInfoRecordA = packed record
    sourceAnsi: array[0..MAX_PATH-1] of AnsiChar; // 260 characters (including NUL terminator)
    recordNumber: DWORD;
    sourceDrive: DWORD; // 0=A, 1=B, 2=C, ...
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
    sourceDrive: DWORD; // 0=A, 1=B, 2=C, ...
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
    (* sourceUnicode: BSTR; *)
    sourceCountChars: DWORD; // including NUL
    //sourceUnicode: array[0..sourceCountChars+1] of WideChar;
  end;

type
  // Windows 95 + Windows NT 4
  // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket: PurgeInfo (Binary)
  PRbWin95PurgeInfo = ^TRbWin95PurgeInfo;
  TRbWin95PurgeInfo = packed record
    cbSize: DWORD;
    bGlobalSettings: BOOL;
    percentDrive: array['A'..'Z'] of WORD; // 0x00..0x64 = 0%..100%
    percentHomedrive: WORD;
    percentGlobal: WORD;
    NukeOnDeleteBits: DWORD; // Flags "Nuke on delete"
                             // Bit 0 (LSB): Drive A
                             // Bit 1: Drive B
                             // ...
                             // Bit 25: Drive Z
                             // Bit 26: Homedrive
                             // Bit 27: Global
                             // Bit 28..31 (MSB) probably unused
    unknown1: DWORD; // For example 04 0D 02 00
  end;               // or          C4 0C 02 00

implementation

end.
