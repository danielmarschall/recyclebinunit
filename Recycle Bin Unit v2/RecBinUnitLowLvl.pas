unit RecBinUnitLowLvl;

// TODO: Gain more information about drive '@' / Homedrive / Netdrive? Win2000 source
//       + überall verwenden

interface

uses
  Windows;

type
  TRbInfo12Header = record
    unknown1: DWORD; // For INFO2 always 05 00 00 00 ?
    unknown2: DWORD; // For INFO2 always 00 00 00 00 ?
    unknown3: DWORD; // For INFO2 always 00 00 00 00 ?
    recordLength: DWORD; // 0x181  =  INFO  structure (without Unicode)
                         // 0x320  =  INFO2 structure (with Unicode)
    totalSize: DWORD; // INFO file: sum of all "originalSize" values
                      // INFO2 file: always zero?
  end;

type
  TRbInfoRecord = record
    sourceAnsi: array[0..MAX_PATH-3] of AnsiChar; // 258 elements
    recordNumber: DWORD;
    sourceDrive: DWORD;
    deletionTime: FILETIME;
    originalSize: DWORD; // Size occupied on disk. Not the actual file size.
                         // INFO2, for folders: The whole folder size with contents 
  end;

type
  TRbInfo2Record = record
    sourceAnsi: array[0..MAX_PATH-3] of AnsiChar; // 258 elements
    recordNumber: DWORD;
    sourceDrive: DWORD;
    deletionTime: FILETIME;
    originalSize: DWORD;
    sourceUnicode: array[0..MAX_PATH-3] of WideChar; // 258 elements
    unknown1: DWORD; // Dummy?
  end;

type
  TRbVistaRecord = record
    signature: int64; // Always 01 00 00 00 00 00 00 00 ?
    originalSize: int64;
    deletionTime: FILETIME;
    sourceUnicode: array[0..MAX_PATH-1] of WideChar;
  end;

type
  // Windows 95
  // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\BitBucket: PurgeInfo (Binary)
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
