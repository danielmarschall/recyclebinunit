unit RecyclerListingMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ImgList;

type
  TRecyclerListingMainForm = class(TForm)
    TreeView1: TTreeView;
    Panel1: TPanel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    LabeledEdit1: TLabeledEdit;
    ImageList1: TImageList;
    CheckBox2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
  private
    localRecyclersNode: TTreeNode;
    individualRecyclersNode: TTreeNode;
  end;

var
  RecyclerListingMainForm: TRecyclerListingMainForm;

implementation

{$R *.dfm}

uses
  RecBinUnit2, ContNrs, SIDUnit, ShellAPI;

// TODO: SID Namen auflösen und dementsprechend anzeigen
// TODO: zu jedem element mehr informationen anzeigen, nicht nur den ursprungsnamen
// TODO: Einstellungen usw anzeigen, so wie im alten Demo

procedure TRecyclerListingMainForm.Button1Click(Sender: TObject);
var
  drives: TObjectList{TRbDrive};
  iDrive: integer;
  drive: TRbDrive;
  nDrive: TTreeNode;

  bins: TObjectList{TRbRecycleBin};
  iBin: integer;
  bin: TRbRecycleBin;
  nBin: TTreeNode;

  items: TObjectList{TRbRecycleBinItem};
  iItem: integer;
  item: TRbRecycleBinItem;
  nItem: TTreeNode;
  sCaption: string;
resourcestring
  S_DRIVE = 'Drive %s';
begin
  localRecyclersNode.DeleteChildren; // TODO: Will the objects be freed? This is important to avoid memory leaks.

  TreeView1.Items.BeginUpdate;
  drives := TObjectList.Create(false);
  bins := TObjectList.Create(false);
  items := TObjectList.Create(false);
  try
    drives.Clear;
    TRecycleBinManager.ListDrives(drives);
    for iDrive := 0 to drives.Count - 1 do
    begin
      drive := drives.Items[iDrive] as TRbDrive;

      if drive.VolumeGUIDAvailable then
        nDrive := TreeView1.Items.AddChildObject(localRecyclersNode, Format(S_DRIVE, [drive.DriveLetter])+': ' + GUIDToString(drive.VolumeGUID), drive)
      else
        nDrive := TreeView1.Items.AddChildObject(localRecyclersNode, Format(S_DRIVE, [drive.DriveLetter])+':', drive);
      nDrive.ImageIndex := 6;
      nDrive.SelectedIndex := nDrive.ImageIndex;

      bins.Clear;
      if CheckBox1.Checked then
        drive.ListRecycleBins(bins, GetMySID)
      else
        drive.ListRecycleBins(bins);
      for iBin := 0 to bins.Count - 1 do
      begin
        bin := bins.Items[iBin] as TRbRecycleBin;

        nBin := TreeView1.Items.AddChildObject(nDrive, bin.FileOrDirectory, bin);
        nBin.ImageIndex := 4;
        nBin.SelectedIndex := nBin.ImageIndex;

        items.Clear;
        bin.ListItems(items);
        for iItem := 0 to items.Count - 1 do
        begin
          item := items.Items[iItem] as TRbRecycleBinItem;

          if not FileExists(item.PhysicalFile) and
             not DirectoryExists(item.PhysicalFile) and
             CheckBox2.Checked then continue;

          sCaption := item.Source;
          if item is TRbVistaItem (*item.IndexFile <> ''*) then sCaption := sCaption + ' ('+ExtractFileName(item.IndexFile)+')';
          nItem := TreeView1.Items.AddChildObject(nBin, sCaption, item);

          if FileExists(item.PhysicalFile) then
            nItem.ImageIndex := 0
          else if DirectoryExists(item.PhysicalFile) then
            nItem.ImageIndex := 10 // TODO: Feature: Read folder contents and display them in this treeview. (Also change icon to "open folder")
          else
            nItem.ImageIndex := 8;
          nItem.SelectedIndex := nItem.ImageIndex;
        end;
      end;
    end;
  finally
    drives.Free;
    bins.Free;
    items.Free;
    TreeView1.Items.EndUpdate;
  end;

  localRecyclersNode.Expand(false);
end;

procedure TRecyclerListingMainForm.Button2Click(Sender: TObject);
var
  bin: TRbRecycleBin;
  nBin: TTreeNode;

  items: TObjectList{TRbRecycleBinItem};
  iItem: integer;
  item: TRbRecycleBinItem;
  nItem: TTreeNode;
  sCaption: string;
begin
  bin := TRbRecycleBin.Create(LabeledEdit1.Text);

  nBin := TreeView1.Items.AddChildObject(individualRecyclersNode, bin.FileOrDirectory, bin);
  individualRecyclersNode.Expand(false);

  items := TObjectList.Create(false);
  try
    items.Clear;
    bin.ListItems(items);
    for iItem := 0 to items.Count - 1 do
    begin
      item := items.Items[iItem] as TRbRecycleBinItem;

      if not FileExists(item.PhysicalFile) and
         not DirectoryExists(item.PhysicalFile) and
         CheckBox2.Checked then continue;

      sCaption := item.Source;
      if item is TRbVistaItem (*item.IndexFile <> ''*) then sCaption := sCaption + ' ('+ExtractFileName(item.IndexFile)+')';
      nItem := TreeView1.Items.AddChildObject(nBin, sCaption, item);

      if FileExists(item.PhysicalFile) then
        nItem.ImageIndex := 0
      else if DirectoryExists(item.PhysicalFile) then
        nItem.ImageIndex := 10 // TODO: Feature: Read folder contents and display them in this treeview. (Also change icon to "open folder")
      else
        nItem.ImageIndex := 8;
      nItem.SelectedIndex := nItem.ImageIndex;
    end;
  finally
    items.Free;
  end;

  nBin.Expand(false);
end;

procedure TRecyclerListingMainForm.FormShow(Sender: TObject);
resourcestring
  S_LOCAL_RECYCLE_BINS = 'Local recycle bins';
  S_MANUAL_RECYCLE_BINS ='Manually added recycle bins';
begin
  localRecyclersNode := TreeView1.Items.Add(nil, S_LOCAL_RECYCLE_BINS);
  localRecyclersNode.ImageIndex := 2;
  localRecyclersNode.SelectedIndex := localRecyclersNode.ImageIndex;

  individualRecyclersNode := TreeView1.Items.Add(nil, S_MANUAL_RECYCLE_BINS);
  individualRecyclersNode.ImageIndex := 2;
  individualRecyclersNode.SelectedIndex := individualRecyclersNode.ImageIndex;
end;

procedure TRecyclerListingMainForm.TreeView1DblClick(Sender: TObject);
var
  item: TRbRecycleBinItem;
begin
  if TreeView1.Selected.ImageIndex = 0 then
  begin
    // File
    item := TRbRecycleBinItem(TreeView1.Selected.Data);
    // TODO: Does not work if the file type is unknown
    // TODO: Maybe we should add a feature to drag'n'drop a file/folder out of RecycleBinUnit into the explorer (With options copy or move, depending on the ShiftState) 
    ShellExecute(Handle, 'open', PChar(item.PhysicalFile), '', '', SW_NORMAL);
  end;
  if TreeView1.Selected.ImageIndex = 10 then
  begin
    // Folder
    item := TRbRecycleBinItem(TreeView1.Selected.Data);
    ShellExecute(Handle, 'open', PChar(item.PhysicalFile), '', '', SW_NORMAL);
  end;
end;

end.
