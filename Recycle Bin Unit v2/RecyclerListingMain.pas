unit RecyclerListingMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TRecyclerListingMainForm = class(TForm)
    TreeView1: TTreeView;
    Panel1: TPanel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  RecyclerListingMainForm: TRecyclerListingMainForm;

implementation

{$R *.dfm}

uses
  RecBinUnit2, ContNrs, SIDUnit;

// TODO: SID Namen auflösen und dementsprechend anzeigen
// TODO: zu jedem element mehr informationen anzeigen, nicht nur den ursprungsnamen

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
begin
  TreeView1.Items.Clear;
  TreeView1.Items.BeginUpdate;
  drives := TObjectList.Create(true);
  bins := TObjectList.Create(true);
  items := TObjectList.Create(true);
  try
    drives.Clear;
    TRecycleBinManager.ListDrives(drives);
    for iDrive := 0 to drives.Count - 1 do
    begin
      drive := drives.Items[iDrive] as TRbDrive;

      nDrive := TreeView1.Items.AddObject(nil, 'Drive '+drive.DriveLetter+': ' + GUIDToString(drive.VolumeGUID), drive);

      bins.Clear;
      if CheckBox1.Checked then
        drive.ListRecycleBins(bins, GetMySID)
      else
        drive.ListRecycleBins(bins);
      for iBin := 0 to bins.Count - 1 do
      begin
        bin := bins.Items[iBin] as TRbRecycleBin;

        nBin := TreeView1.Items.AddChildObject(nDrive, bin.FileOrDirectory, bin);

        items.Clear;
        bin.ListItems(items);
        for iItem := 0 to items.Count - 1 do
        begin
          item := items.Items[iItem] as TRbRecycleBinItem;
          nItem := TreeView1.Items.AddChildObject(nBin, item.Source, bin);
        end;
      end;
    end;
  finally
    drives.Free;
    bins.Free;
    items.Free;
    TreeView1.Items.EndUpdate;
  end;
end;

end.
