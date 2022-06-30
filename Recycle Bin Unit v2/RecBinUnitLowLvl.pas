unit RecBinUnitLowLvl;

// TODO: Gain more information about drive '@' / Homedrive / Netdrive? Win2000 source
//       + überall verwenden

interface

uses
  Windows;

type
  PRbInfoHeader = ^TRbInfoHeader;
  TRbInfoHeader = record
    format: DWORD;         // Unsure...
                           // Win95 (without IE4): 00 00 00 00
                           // Win95 (with IE4):    04 00 00 00
                           // Win NT4:             02 00 00 00
                           // Win XP:              05 00 00 00
    totalEntries: DWORD;   // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
    nextPossibleID: DWORD; // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
    recordLength: DWORD; // 0x181  =  INFO  structure (without Unicode)
                         // 0x320  =  INFO2 structure (with Unicode)
    totalSize: DWORD; // sum of all "originalSize" values;
                      // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
  end;

type
  // Windows 95:      INFO file with TRbInfoRecordA; Folder deletion NOT possible
  // Windows 95 +IE4: INFO2 file with TRbInfoRecordA; Folder deletion possible
  PRbInfoRecordA = ^TRbInfoRecordA;
  TRbInfoRecordA = record
    sourceAnsi: array[0..MAX_PATH-3] of AnsiChar; // 258 elements
    recordNumber: DWORD;
    sourceDrive: DWORD;
    deletionTime: FILETIME;
    originalSize: DWORD; // Size occupied on disk. Not the actual file size.
                         // INFO2, for folders: The whole folder size with contents
  end;

type
  // Windows NT4:   INFO file with TRbInfoRecordW; Folder deletion possible
  // Windows 2000+: INFO2 file with TRbInfoRecordW; Folder deletion possible
  PRbInfoRecordW = ^TRbInfoRecordW;
  TRbInfoRecordW = record
    sourceAnsi: array[0..MAX_PATH-3] of AnsiChar; // 258 elements
    recordNumber: DWORD;
    sourceDrive: DWORD;
    deletionTime: FILETIME;
    originalSize: DWORD;
    sourceUnicode: array[0..MAX_PATH-3] of WideChar; // 258 elements
    unknown1: DWORD; // Dummy?
  end;

type
  PRbVistaRecord1 = ^TRbVistaRecord1;
  TRbVistaRecord1 = record
    version: int64; // Always 01 00 00 00 00 00 00 00
    originalSize: int64;
    deletionTime: FILETIME;
    sourceUnicode: array[0..MAX_PATH-1] of WideChar;
  end;

type
  PRbVistaRecord2Head = ^TRbVistaRecord2Head;
  TRbVistaRecord2Head = record
    version: int64; // Always 02 00 00 00 00 00 00 00
    originalSize: int64;
    deletionTime: FILETIME;
    sourceCountChars: DWORD; // including NUL
    //sourceUnicode: array[0..sourceCountChars+1] of WideChar;
  end;

type
  // Windows 95 + Windows NT 4
  // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket: PurgeInfo (Binary)
  PRbWin95PurgeInfo = ^TRbWin95PurgeInfo;
  TRbWin95PurgeInfo = record
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
