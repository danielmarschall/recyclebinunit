
# Windows Recycle Bin internal format

## Locations

### FAT drives:

- Windows 95 native:	C:\RECYCLED\INFO (with ANSI records, folder deletion is NOT possible, format `00 00 00 00`)
- Windows 95+IE4, 98SE:	C:\RECYCLED\INFO2 (with ANSI records, folder deletion is possible, format `04 00 00 00`)
- Windows Me:		C:\RECYCLED\INFO2 (with ANSI records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	C:\$RECYCLE.BIN\$I...

### NTFS drives:

- Windows NT4:		C:\RECYCLER\<UserSID>\INFO (with Unicode records, folder deletion is possible, format `02 00 00 00`)
- Windows 2000, XP:	C:\RECYCLER\<UserSID>\INFO2 (with Unicode records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	C:\$RECYCLE.BIN\<UserSID>\$I...

## INFO and INFO2 files

INFO is written by Win95 without IE4 (with ANSI records), and WinNT4 (with Unicode records).

INFO2 is written by Win95 with Internet Explorer 4 shell extensions, Win98, WinMe (with ANSI records), Win2000, and WinXP (with Unicode records).

Since some Windows versions combinations mix up ANSI records and Unicode records (e.g. Win95+IE4 and Win2000), these Windows versions break the recycle bin information file of each other.

INFO and INFO2 is the index file containing all information about the deleted files. The data files are renamed to `Dxy.ext` (`x` replaced with the drive letter, `y` being a dynamic length integer, `ext` being replaced with the file name extension).

### Header

    type
      PRbInfoHeader = ^TRbInfoHeader;
      TRbInfoHeader = record
        format: DWORD;         // Unsure if this is just a version field or some unknown flags...!
                               // Win95 (without IE4): 00 00 00 00
                               // Win95 (with IE4):    04 00 00 00
                               // Win NT4:             02 00 00 00
                               // Win Me, 2000, XP:    05 00 00 00
        totalEntries: DWORD;   // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
        nextPossibleID: DWORD; // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
        recordLength: DWORD; // 0x181  =  INFO  structure (without Unicode)
                             // 0x320  =  INFO2 structure (with Unicode)
        totalSize: DWORD; // sum of all "originalSize" values;
                          // Only Win95 (without IE4) and Win NT4, unknown purpose for other OS versions
      end;

### ANSI record (Win95, 98, Me)

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

### Unicode record (NT4, 2000, XP)

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

## $I... files of Windows Vista and above

Beginning with Windows Vista, each deleted file gets its own information record. The information record ("index file") has the name `$Ixxxxxx.ext` while the data file is renamed to `$Rxxxxxx.ext` (`xxxxxx` replaced with a random `[0-9A-Z]` string and ext replaced with the file name extension).

### Version 1 (Introduced in Windows Vista)

    type
      // Introduced in Windows Vista
      PRbVistaRecord1 = ^TRbVistaRecord1;
      TRbVistaRecord1 = record
        version: int64; // Always 01 00 00 00 00 00 00 00
        originalSize: int64;
        deletionTime: FILETIME;
        sourceUnicode: array[0..MAX_PATH-1] of WideChar;
      end;

### Version 2 (Introduced somewhere in a Windows 10 release)

    type
      // Introduced somewhere in a Win10 release
      PRbVistaRecord2Head = ^TRbVistaRecord2Head;
      TRbVistaRecord2Head = record
        version: int64; // Always 02 00 00 00 00 00 00 00
        originalSize: int64;
        deletionTime: FILETIME;
        (* sourceUnicode: BSTR; *)
        sourceCountChars: DWORD; // including NUL
        //sourceUnicode: array[0..sourceCountChars+1] of WideChar;
      end;
