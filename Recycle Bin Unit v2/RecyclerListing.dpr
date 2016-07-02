program RecyclerListing;

uses
  Forms,
  RecyclerListingMain in 'RecyclerListingMain.pas' {RecyclerListingMainForm},
  RecBinUnit2 in 'RecBinUnit2.pas',
  RecBinUnitLowLvl in 'RecBinUnitLowLvl.pas',
  SIDUnit in 'SIDUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRecyclerListingMainForm, RecyclerListingMainForm);
  Application.Run;
end.
