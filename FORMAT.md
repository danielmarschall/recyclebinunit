
# Windows Recycle Bin internal format

## Locations

### FAT drives:

- Windows 95 native:	`C:\RECYCLED\INFO` (with ANSI records, folder deletion is NOT possible, format `00 00 00 00`)
- Windows 95+IE4, 98SE:	`C:\RECYCLED\INFO2` (with ANSI records, folder deletion is possible, format `04 00 00 00`)
- Windows Me:		`C:\RECYCLED\INFO2` (with ANSI records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	`C:\$RECYCLE.BIN\$I...`
- Windows 95 (Beta 58s)	`<WinDir>\DESKTOP\RECYCLE.BIN` (a normal folder with the deleted files. No index, no renamed files). In beta build 122, the recycle bin was removed and re-added in beta build 180 with the INFO-format we know from the RTM release.

### NTFS drives:

- Windows NT4:		`C:\RECYCLER\<UserSID>\INFO` (with Unicode records, folder deletion is possible, format `02 00 00 00`)
- Windows 2000, XP:	`C:\RECYCLER\<UserSID>\INFO2` (with Unicode records, folder deletion is possible, format `05 00 00 00`)
- Windows Vista+:	`C:\$RECYCLE.BIN\<UserSID>\$I...`

## INFO and INFO2 files

INFO is written by Win95 without IE4 (with ANSI records), and WinNT4 (with Unicode records).

INFO2 is written by Win95 with Internet Explorer 4 shell extensions, Win98, WinMe (with ANSI records), Win2000, and WinXP (with Unicode records).

Since some Windows version combinations mix up ANSI records and Unicode records (e.g. Win95+IE4 and Win2000), these Windows versions break the recycle bin information file of each other.

INFO and INFO2 is the index file containing all information about the deleted files. The data files are renamed to `Dxyyy.ext` (`x` replaced with the drive letter, `yyy` being a dynamic length integer, `ext` being replaced with the file name extension).

### Header

| offset (hex) | size (dec) |  type | description |
|--------------|------------|-------|-------------|
| 0000         | 4          | DWORD | Version of the info file<br>`00 00 00 00` = Win95 (without IE4)<br>`02 00 00 00` = Win NT4 (Win96/Cairo?)<br>`04 00 00 00` = Win95 (with IE4), Win98<br>`05 00 00 00` = Win Me, 2000, WinXP (NT4+IE4, NT5?) | 
| 0004         | 4          | DWORD | Total entries. Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons. | 
| 0008         | 4          | DWORD | Next possible ID. Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons. | 
| 000C         | 4          | DWORD | Item record length<br>0x118 = ANSI records<br>0x320 = Unicode records | 
| 0010         | 4          | DWORD | Total size (sum of all original sizes of the files). Only Win95 (without IE4) and Win NT4, other OS versions will use the registry instead and might write information on WM_ENDSESSION for compatibility reasons. | 

### ANSI record (Win95, Win98, WinMe)

When a file is deleted, the first byte of the original filename will be set to a zero byte,
making the zero-terminated string empty. This way, the record is marked as deleted
and the INFO/INFO2 file does not need to be reorganized.

Windows 95:      INFO file with ANSI record; Folder deletion NOT possible
Windows 95 +IE4: INFO2 file with ANSI record; Folder deletion possible

| offset (hex) | size (dec) |  type           | description |
|--------------|------------|-----------------|-------------|
| 0000         | 260        | char[MAX_PATH]  | Original file name and path in ANSI characters. 260 characters (including NUL terminator). Empty string if file was deleted. | 
| 0104         | 4          | DWORD           | Record number | 
| 0108         | 4          | DWORD           | Source drive; 0=A, 1=B, 2=C, ..., Z=25, @=26 (@ is the "Network home drive" of the Win95 times) | 
| 010C         | 8          | FILETIME        | Deletion time | 
| 0114         | 4          | DWORD           | Size occupied on disk. Not the actual file size.<br>INFO2, for folders: The whole folder size with contents | 

### Unicode record (WinNT4, Win2000, WinXP)

When a file is deleted, the first byte of the original filename will be set to a zero byte,
making the zero-terminated string empty. This way, the record is marked as deleted
and the INFO/INFO2 file does not need to be reorganized.

Windows NT4:   INFO file with Unicode record; Folder deletion possible
Windows 2000+: INFO2 file with Unicode record; Folder deletion possible

| offset (hex) | size (dec) |  type           | description |
|--------------|------------|-----------------|-------------|
| 0000         | 260        | char[MAX_PATH]  | Original file name and path in ANSI characters. 260 characters (including NUL terminator). Empty string if file was deleted. | 
| 0104         | 4          | DWORD           | Record number | 
| 0108         | 4          | DWORD           | Source drive; 0=A, 1=B, 2=C, ..., Z=25, @=26 (@ is the "Network home drive" of the Win95 times) | 
| 010C         | 8          | FILETIME        | Deletion time | 
| 0114         | 4          | DWORD           | Original size |
| 0118         | 520        | wchar[MAX_PATH] | Original file name and path in Unicode characters. 260 characters (including NUL terminator) | 

## $I... files of Windows Vista and above

Beginning with Windows Vista, each deleted file gets its own information record. The information record ("index file") has the name `$Ixxxxxx.ext` while the data file is renamed to `$Rxxxxxx.ext` (`xxxxxx` replaced with a random `[0-9A-Z]` string and `ext` replaced with the file name extension).

### Version 1 (Introduced in Windows Vista)

| offset (hex) | size (dec) |  type           | description |
|--------------|------------|-----------------|-------------|
| 0000         | 8          | int64           | Version, always `01 00 00 00 00 00 00 00` |
| 0008         | 8          | uint64          | Original size | 
| 0010         | 8          | FILETIME        | Deletion time | 
| 0018         | 520        | wchar[MAX_PATH] | Original file name and path in Unicode characters. 260 characters (including NUL terminator) | 

### Version 2 (Introduced somewhere in a Windows 10 release)

| offset (hex) | size (dec) |  type           | description |
|--------------|------------|-----------------|-------------|
| 0000         | 8          | int64           | Version, always `02 00 00 00 00 00 00 00` |
| 0008         | 8          | uint64          | Original size | 
| 0010         | 8          | FILETIME        | Deletion time | 
| 0018         | 4          | DWORD           | Original file name and path: Count of Unicode characters, including NUL terminator | 
| 001C         | 2*n        | wchar[]         | Original file name and path: Zero terminated Unicode string |
