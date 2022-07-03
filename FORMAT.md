
# Windows Recycle Bin internal format

## Locations

### FAT drives:

- Windows 95 native:	`C:\RECYCLED\INFO` (with ANSI records, folder deletion is NOT possible, format `00 00 00 00`)
- Windows 95+IE4, 98SE:	`C:\RECYCLED\INFO2` (with ANSI records, folder deletion is possible, format `04 00 00 00`)
- Windows Me:		`C:\RECYCLED\INFO2` (with ANSI records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	`C:\$RECYCLE.BIN\$I...`

### NTFS drives:

- Windows NT4:		`C:\RECYCLER\<UserSID>\INFO` (with Unicode records, folder deletion is possible, format `02 00 00 00`)
- Windows 2000, XP:	`C:\RECYCLER\<UserSID>\INFO2` (with Unicode records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	`C:\$RECYCLE.BIN\<UserSID>\$I...`

## INFO and INFO2 files

INFO is written by Win95 without IE4 (with ANSI records), and WinNT4 (with Unicode records).

INFO2 is written by Win95 with Internet Explorer 4 shell extensions, Win98, WinMe (with ANSI records), Win2000, and WinXP (with Unicode records).

Since some Windows version combinations mix up ANSI records and Unicode records (e.g. Win95+IE4 and Win2000), these Windows versions break the recycle bin information file of each other.

INFO and INFO2 is the index file containing all information about the deleted files. The data files are renamed to `Dxy.ext` (`x` replaced with the drive letter, `y` being a dynamic length integer, `ext` being replaced with the file name extension).

### Header

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
        recordLength: DWORD;   // 0x181  =  ANSI records
                               // 0x320  =  Unicode records
        totalSize: DWORD;      // sum of all "originalSize" values;
                               // Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons
      end;

### ANSI record (Win95, Win98, WinMe)

When a file is deleted, the first byte of `sourceAnsi` will be filled with a zero byte,
making the zero-terminated string empty. This way, the record is marked as deleted
and the INFO/INFO2 file does not need to be reorganized.

    type
      // Windows 95:      INFO file with TRbInfoRecordA; Folder deletion NOT possible
      // Windows 95 +IE4: INFO2 file with TRbInfoRecordA; Folder deletion possible
      PRbInfoRecordA = ^TRbInfoRecordA;
      TRbInfoRecordA = packed record
        sourceAnsi: array[0..MAX_PATH-1] of AnsiChar; // 260 characters (including NUL terminator)
        recordNumber: DWORD;
        sourceDrive: DWORD; // 0=A, 1=B, 2=C, ..., Z=25, @=26 (@ is the "Network home drive" of the Win95 time)
        deletionTime: FILETIME;
        originalSize: DWORD; // Size occupied on disk. Not the actual file size.
                             // INFO2, for folders: The whole folder size with contents
      end;

### Unicode record (WinNT4, Win2000, WinXP)

When a file is deleted, the first byte of `sourceAnsi` will be filled with a zero byte,
making the zero-terminated string empty. This way, the record is marked as deleted
and the INFO/INFO2 file does not need to be reorganized.

    type
      // Windows NT4:   INFO file with TRbInfoRecordW; Folder deletion possible
      // Windows 2000+: INFO2 file with TRbInfoRecordW; Folder deletion possible
      PRbInfoRecordW = ^TRbInfoRecordW;
      TRbInfoRecordW = packed record
        sourceAnsi: array[0..MAX_PATH-1] of AnsiChar; // 260 characters (including NUL terminator)
        recordNumber: DWORD;
        sourceDrive: DWORD; // 0=A, 1=B, 2=C, ..., Z=25, @=26 (@ is the "Network home drive" of the Win95 time)
        deletionTime: FILETIME;
        originalSize: DWORD;
        sourceUnicode: array[0..MAX_PATH-1] of WideChar; // 260 characters (including NUL terminator)
      end;

## $I... files of Windows Vista and above

Beginning with Windows Vista, each deleted file gets its own information record. The information record ("index file") has the name `$Ixxxxxx.ext` while the data file is renamed to `$Rxxxxxx.ext` (`xxxxxx` replaced with a random `[0-9A-Z]` string and `ext` replaced with the file name extension).

### Version 1 (Introduced in Windows Vista)

    type
      // Introduced in Windows Vista
      PRbVistaRecord1 = ^TRbVistaRecord1;
      TRbVistaRecord1 = packed record
        version: int64; // Always 01 00 00 00 00 00 00 00
        originalSize: int64;
        deletionTime: FILETIME;
        sourceUnicode: array[0..MAX_PATH-1] of WideChar;
      end;

### Version 2 (Introduced somewhere in a Windows 10 release)

    type
      // Introduced somewhere in a Win10 release
      PRbVistaRecord2Head = ^TRbVistaRecord2Head;
      TRbVistaRecord2Head = packed record
        version: int64; // Always 02 00 00 00 00 00 00 00
        originalSize: int64;
        deletionTime: FILETIME;
        (* sourceUnicode: BSTR; *)
        sourceCountChars: DWORD; // including NUL
        //sourceUnicode: array[0..sourceCountChars-1] of WideChar;
      end;
