program RecyclerListing;

uses
  Forms,
  RecyclerListingMain in 'RecyclerListingMain.pas' {RecyclerListingMainForm},
  RecBinUnit2 in 'RecBinUnit2.pas',
  RecBinUnitLowLvl in 'RecBinUnitLowLvl.pas',
  SIDUnit in 'SIDUnit.pas';

{$R *.res}

{$R XPManifest.res}

begin
  Application.Initialize;
  Application.Title := 'Recycler Listing (ViaThinkSoft Recycle Bin Unit v2 Demo)';
  Application.CreateForm(TRecyclerListingMainForm, RecyclerListingMainForm);
  Application.Run;
end.
