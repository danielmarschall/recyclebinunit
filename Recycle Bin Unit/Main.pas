unit Main;

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
{...}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF DEL6UP}
{$WARN UNIT_PLATFORM OFF}
{$ENDIF}

interface

uses
  Windows, SysUtils, Forms, Controls, StdCtrls,
  ExtCtrls, Classes, Dialogs;

type
  TMainForm = class(TForm)
    openDialog: TOpenDialog;
    outputMemo: TMemo;
    topPanel: TPanel;
    rightPanel: TPanel;
    btnReadOwnRecyclers: TButton;
    leftPanel: TPanel;
    btnReadRecyclerFile: TButton;
    outputPanel: TPanel;
    saveDialog: TSaveDialog;
    btnShowConfig: TButton;
    btnSaveTextDump: TButton;
    procedure btn_read_click(Sender: TObject);
    procedure btn_readown_click(Sender: TObject);
    procedure btnSaveTextDumpClick(Sender: TObject);
    procedure btnShowConfigClick(Sender: TObject);
  public
    procedure ReadRecycler(filename: string);
  end;

var
  MainForm: TMainForm;

implementation

uses
  RecyclerFunctions;

{$R *.dfm}

function _BoolToEnabledDisabled(b: boolean): string;
begin
  if b then
    result := 'Enabled'
  else
    result := 'Disabled';
end;

function _BoolToYesNo(b: boolean): string;
begin
  if b then
    result := 'Yes'
  else
    result := 'No';
end;

{$IFNDEF DEL6UP}
// Only available since Delphi 6
function DirectoryExists(const directory: string): boolean;
var
  attr: integer;
begin
  attr := getfileattributes(pchar(directory));
  result := (attr <> -1) and (file_attribute_directory and attr <> 0);
end;
{$ENDIF}

procedure TMainForm.ReadRecycler(filename: string);
var
  x: TStringList;
  i: integer;
  tmp, fn: string;
begin
  outputMemo.Visible := false;
  application.ProcessMessages;

  if (uppercase(copy(extractfilename(filename), 0, 2)) = '$I') or
     (uppercase(copy(extractfilename(filename), 0, 2)) = '$R') then
  begin
    outputMemo.Lines.Add('Reading directory:');
    tmp := extractfilepath(filename);
  end
  else
  begin
    tmp := filename;
    if directoryexists(tmp) then
      outputMemo.Lines.Add('Reading directory:')
    else
      outputMemo.Lines.Add('Reading file:');
  end;

  outputMemo.Lines.Add(tmp);
  outputMemo.lines.add('');

  if not RecyclerIsValid(filename) then
  begin
    outputMemo.lines.add('Recycler is not valid.');
    outputMemo.lines.add('');
  end
  else
  begin
    x := TStringList.Create;
    try
      RecyclerListIndexes(filename, x);
      if x.Count = 0 then
      begin
        outputMemo.lines.add('No items available.');
        outputMemo.lines.add('');
      end;
      for i := 0 to x.Count - 1 do
      begin
        fn := RecyclerCurrentFilenameAndPath(tmp, x[i]);
        outputMemo.lines.add(inttostr(i+1)+'. Entry');
        outputMemo.lines.add('# Unique ID: ' + changefileext(x[i], ''));
        outputMemo.lines.add('# Recycler filename: '+fn);

        if fileexists(fn) then
          outputMemo.lines.add('  -> Found')
        else
          outputMemo.lines.add('  -> Not found');

        {$IFDEF DEL6UP}
        outputMemo.lines.add('# Deleted: '+
          datetimetostr(RecyclerGetDateTime(tmp, x[i])));
        {$ELSE}
        outputMemo.lines.add('# Deleted: You have to compile this demo with Delphi 6 or higher.');
        {$ENDIF}
        outputMemo.lines.add('# Original filename: '+
          RecyclerGetSource(tmp, x[i]));
        outputMemo.lines.add('# Unicode filename: '+
          RecyclerGetSourceUnicode(tmp, x[i]));
        outputMemo.lines.add('# Source device: '+
          RecyclerGetSourceDrive(tmp, x[i]));
        outputMemo.lines.add('# Original size on disk: '+
          inttostr(RecyclerOriginalSize(tmp, x[i]))+' Byte');
        outputMemo.lines.add('');
      end;
    finally
      x.Free;
    end;
  end;

  outputMemo.Visible := true;
end;

procedure TMainForm.btn_read_click(Sender: TObject);
begin
  if openDialog.Execute() then
  begin
    outputMemo.Clear;
    ReadRecycler(openDialog.filename);
  end;
end;

procedure TMainForm.btn_readown_click(Sender: TObject);
var
  x, sl: TStringList;
  i, j: integer;
  somethingfound: boolean;
begin
  outputMemo.Visible := false;
  try
    application.ProcessMessages;

    outputMemo.Clear;
    x := TStringList.Create;
    try
      RecyclerGetAllRecyclerDrives(x);
      somethingfound := false;
      if x.Count > 0 then
      begin
        for i := 0 to x.Count - 1 do
        begin
          // ReadRecycler(RecyclerGetPath(x[i][1]), true);

          sl := TStringList.Create;
          try
            RecyclerGetInfofiles(x[i][1], true, sl);
            if sl.Count > 0 then
            begin
              for j := 0 to sl.Count - 1 do
              begin
                ReadRecycler(sl.Strings[j]);
                somethingfound := true;
              end;
            end;
          finally
            sl.Free;
          end;
        end;
      end;
      if not somethingfound then
      begin
        outputMemo.lines.add('No recyclers found.');
        outputMemo.lines.add('');
      end;
    finally
      x.Free;
    end;
  finally
    outputMemo.Visible := true;
  end;
end;

procedure TMainForm.btnSaveTextDumpClick(Sender: TObject);
begin
  if saveDialog.Execute then
  begin
    outputMemo.Lines.SaveToFile(saveDialog.FileName);
  end;
end;

procedure TMainForm.btnShowConfigClick(Sender: TObject);
var
  d: char;
  sl: TStringList;
  i: integer;
begin
  outputMemo.Visible := false;
  try
    application.ProcessMessages;

    outputMemo.Clear;

    outputMemo.Lines.Add(RecyclerLibraryVersion);

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Possible recyclers (fixed drives) =');
    outputMemo.Lines.Add('');

    for d := 'A' to 'Z' do
    begin
      outputMemo.Lines.Add('Recycler is possible at drive '+d+': ' + _BoolToYesNo(RecyclerIsPossible(d)));
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Valid recyclers =');
    outputMemo.Lines.Add('');

    for d := 'A' to 'Z' do
    begin
      outputMemo.Lines.Add('Drive '+d+': ' + _BoolToYesNo(RecyclerIsValid(d)));
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Current status =');
    outputMemo.Lines.Add('');

    if RecyclerQueryFunctionAvailable then
    begin
      outputMemo.Lines.Add('GLOBAL Empty = ' + _BoolToYesNo(RecyclerIsEmpty));
      outputMemo.Lines.Add('GLOBAL Number of items = ' + IntToStr(RecyclerGetNumItems));
      outputMemo.Lines.Add('GLOBAL Size = ' + IntToStr(RecyclerGetSize) + ' Bytes');
      for d := 'A' to 'Z' do
      begin
        // if not RecyclerIsPossible(d) then Continue;
        outputMemo.Lines.Add('Drive '+d+' Empty = ' + _BoolToYesNo(RecyclerIsEmpty(d)));
        outputMemo.Lines.Add('Drive '+d+' Number of items = ' + IntToStr(RecyclerGetNumItems(d)));
        outputMemo.Lines.Add('Drive '+d+' Size = ' + IntToStr(RecyclerGetSize(d)) + ' Bytes');
      end;
    end
    else
    begin
      outputMemo.Lines.Add('Empty, Number of items, Size:');
      outputMemo.Lines.Add('        Functionality not working with your operating system.');
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Name and Infotips =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Name: '+RecyclerGetName());
    outputMemo.Lines.Add('Info Tip: '+RecyclerGetInfoTip());
    outputMemo.Lines.Add('Intro Text: '+RecyclerGetIntroText());
    outputMemo.Lines.Add('Class-ID: '+RecyclerGetCLSID());

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Icons =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Default Icon: '+RecyclerGetDefaultIconString());
    if RecyclerQueryFunctionAvailable then
    begin
      outputMemo.Lines.Add('Current Icon (Empty / Full): '+RecyclerGetCurrentIconString());
    end
    else
    begin
      outputMemo.Lines.Add('Current Icon (Empty / Full):');
      outputMemo.Lines.Add('        Functionality not working with your operating system.');
    end;
    outputMemo.Lines.Add('Full Icon: '+RecyclerGetFullIconString());
    outputMemo.Lines.Add('Empty Icon: '+RecyclerGetEmptyIconString());

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Events =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Empty Event Name: '+RecyclerEmptyEventGetName());
    outputMemo.Lines.Add('Empty Event Current Sound: '+RecyclerEmptyEventGetCurrentSound());
    outputMemo.Lines.Add('Empty Event Default Sound: '+RecyclerEmptyEventGetDefaultSound());

    sl := TStringList.Create;
    try
      RecyclerEmptyEventGetSoundCategories(sl);
      for i := 0 to sl.Count - 1 do
      begin
        outputMemo.Lines.Add(Format('Event "%s" = %s', [sl.Strings[i], RecyclerEmptyEventGetSound(sl.Strings[i])]));
      end;
    finally
      sl.Free;
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Nuke on Delete =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Group policy setting: ' + GPBoolToString(RecyclerGroupPolicyNoRecycleFiles));
    outputMemo.Lines.Add('Global settings selected: ' + _BoolToYesNo(RecyclerHasGlobalSettings));
    outputMemo.Lines.Add('Global setting: ' + _BoolToEnabledDisabled(RecyclerGlobalIsNukeOnDelete()));
    for d := 'A' to 'Z' do
    begin
      // if not RecyclerIsPossible(d) then Continue;
      outputMemo.Lines.Add('Individual setting for drive '+d+': ' + _BoolToEnabledDisabled(RecyclerSpecificIsNukeOnDelete(d)));
      outputMemo.Lines.Add('Auto determinated setting for drive '+d+' (includes group policy and global setting): ' + _BoolToEnabledDisabled(RecyclerIsNukeOnDeleteAutoDeterminate(d)));
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Usage Percent =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Group policy setting: ' + IntToStr(RecyclerGroupPolicyRecycleBinSize));
    outputMemo.Lines.Add('Global settings selected: ' + _BoolToYesNo(RecyclerHasGlobalSettings));
    outputMemo.Lines.Add('Global setting: ' + IntToStr(RecyclerGlobalGetPercentUsage()));
    for d := 'A' to 'Z' do
    begin
      // if not RecyclerIsPossible(d) then Continue;
      outputMemo.Lines.Add('Setting for drive '+d+': ' + IntToStr(RecyclerSpecificGetPercentUsage(d)));
      outputMemo.Lines.Add('Auto determinated setting for drive '+d+' (includes group policy and global setting): ' + IntToStr(RecyclerGetPercentUsageAutoDeterminate(d)));
    end;

    outputMemo.Lines.Add('');
    outputMemo.Lines.Add('= Confirmation Dialog =');
    outputMemo.Lines.Add('');

    outputMemo.Lines.Add('Setting in Shell: ' + _BoolToEnabledDisabled(RecyclerShellStateConfirmationDialogEnabled()));
    outputMemo.Lines.Add('Setting in Group Policy: ' + GPBoolToString(RecyclerGroupPolicyConfirmFileDelete()));
    outputMemo.Lines.Add('Resulting Setting (Group policy before Shell): ' + _BoolToEnabledDisabled(RecyclerConfirmationDialogEnabled()));
  finally
    outputMemo.Visible := true;
  end;
end;

end.
