unit LangEditorForm;

{$mode objfpc}{$H+}

// ==============================================================================
// Los editortooltje voor de vertalingen van HtmlTableDesignerAdvanced.
// Toont/bewerkt de NL/EN/FR/DU-tabel uit HtmlTableDesignerLang, en kan de
// broncode scannen op TR('...')-aanroepen om nieuwe teksten te vinden die nog
// niet vertaald zijn.
//
// Gebruik:  LangEditorForm.ShowLangEditor;
// ==============================================================================

interface

uses
  Classes, SysUtils, StrUtils, Math, Forms, Controls, Grids, StdCtrls, ExtCtrls,
  Dialogs, FileUtil, HtmlTableDesignerLang;

type

  { TFLangEditor }

  TFLangEditor = class(TForm)
  private
    TopPanel: TPanel;
    Grid: TStringGrid;
    BtOpen, BtSave, BtSaveAs, BtScan, BtAddRow, BtDeleteRow: TButton;
    LblFile, LblStatus: TLabel;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    ScanDlg: TSelectDirectoryDialog;

    FCurrentFile: string;

    procedure LoadGridFromTable;
    procedure SaveGridToTable;

    procedure BtOpenClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure BtSaveAsClick(Sender: TObject);
    procedure BtScanClick(Sender: TObject);
    procedure BtAddRowClick(Sender: TObject);
    procedure BtDeleteRowClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure GridSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);

    procedure ScanFileForTRKeys(const AFileName: string; AFoundKeys: TStringList);
  public
    constructor Create(TheOwner: TComponent); override;
  end;

procedure ShowLangEditor;

implementation

const
  COL_KEY = 0;  // opzoeksleutel = het TR()-argument uit de broncode; niet bewerkbaar
  COL_NL = 1;
  COL_EN = 2;
  COL_FR = 3;
  COL_DU = 4;

procedure ShowLangEditor;
var
  F: TFLangEditor;
begin
  F := TFLangEditor.Create(Application);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ TFLangEditor }

constructor TFLangEditor.Create(TheOwner: TComponent);
begin
  inherited CreateNew(TheOwner);

  Caption := 'Vertalingen - HtmlTableDesignerAdvanced (NL / EN / FR / DU)';
  Position := poScreenCenter;
  SetBounds(Left, Top, 1100, 560);
  OnCloseQuery := @FormCloseQuery;

  // --- Knoppenbalk bovenaan (eigen alTop-paneel, zodat de grid eronder
  //     met alClient nooit over de knoppen heen valt) ---
  TopPanel := TPanel.Create(Self);
  TopPanel.Parent := Self;
  TopPanel.Align := alTop;
  TopPanel.Height := 72;
  TopPanel.BevelOuter := bvNone;

  BtOpen := TButton.Create(Self);
  BtOpen.Parent := TopPanel;
  BtOpen.SetBounds(8, 8, 90, 26);
  BtOpen.Caption := 'Openen...';
  BtOpen.OnClick := @BtOpenClick;

  BtSave := TButton.Create(Self);
  BtSave.Parent := TopPanel;
  BtSave.SetBounds(104, 8, 90, 26);
  BtSave.Caption := 'Bewaren';
  BtSave.OnClick := @BtSaveClick;

  BtSaveAs := TButton.Create(Self);
  BtSaveAs.Parent := TopPanel;
  BtSaveAs.SetBounds(200, 8, 110, 26);
  BtSaveAs.Caption := 'Bewaren als...';
  BtSaveAs.OnClick := @BtSaveAsClick;

  BtScan := TButton.Create(Self);
  BtScan.Parent := TopPanel;
  BtScan.SetBounds(320, 8, 190, 26);
  BtScan.Caption := 'Broncode scannen op TR(...)';
  BtScan.OnClick := @BtScanClick;

  BtAddRow := TButton.Create(Self);
  BtAddRow.Parent := TopPanel;
  BtAddRow.SetBounds(600, 8, 90, 26);
  BtAddRow.Caption := 'Rij +';
  BtAddRow.OnClick := @BtAddRowClick;

  BtDeleteRow := TButton.Create(Self);
  BtDeleteRow.Parent := TopPanel;
  BtDeleteRow.SetBounds(696, 8, 90, 26);
  BtDeleteRow.Caption := 'Rij -';
  BtDeleteRow.OnClick := @BtDeleteRowClick;

  LblFile := TLabel.Create(Self);
  LblFile.Parent := TopPanel;
  LblFile.SetBounds(8, 44, 880, 16);
  LblFile.Caption := '(geen bestand geopend - werk je verder op de in het geheugen opgebouwde tabel)';

  // --- Grid ---
  Grid := TStringGrid.Create(Self);
  Grid.Parent := Self;
  Grid.Align := alClient;
  Grid.FixedCols := 0;
  Grid.FixedRows := 1;
  Grid.ColCount := 5;
  Grid.RowCount := 1;
  Grid.Options := Grid.Options + [goEditing, goAutoAddRows] - [goRangeSelect];
  Grid.OnSelectCell := @GridSelectCell;
  Grid.Cells[COL_KEY, 0] := 'Key (broncode, niet wijzigen)';
  Grid.Cells[COL_NL, 0] := 'NL';
  Grid.Cells[COL_EN, 0] := 'EN';
  Grid.Cells[COL_FR, 0] := 'FR';
  Grid.Cells[COL_DU, 0] := 'DU';
  Grid.ColWidths[COL_KEY] := 260;
  Grid.ColWidths[COL_NL] := 200;
  Grid.ColWidths[COL_EN] := 200;
  Grid.ColWidths[COL_FR] := 200;
  Grid.ColWidths[COL_DU] := 200;

  LblStatus := TLabel.Create(Self);
  LblStatus.Parent := Self;
  LblStatus.Align := alBottom;
  LblStatus.Caption := Format('%d teksten geladen.', [LangEntryCount]);

  OpenDlg := TOpenDialog.Create(Self);
  OpenDlg.Filter := 'Vertaalbestand (*.lng)|*.lng|Alle bestanden (*.*)|*.*';
  OpenDlg.DefaultExt := 'lng';

  SaveDlg := TSaveDialog.Create(Self);
  SaveDlg.Filter := 'Vertaalbestand (*.lng)|*.lng|Alle bestanden (*.*)|*.*';
  SaveDlg.DefaultExt := 'lng';

  ScanDlg := TSelectDirectoryDialog.Create(Self);

  LoadGridFromTable;
end;

procedure TFLangEditor.LoadGridFromTable;
var
  i: Integer;
  E: TLangEntry;
begin
  Grid.RowCount := Max(1, LangEntryCount + 1);

  for i := 0 to LangEntryCount - 1 do
  begin
    E := LangEntryByIndex(i);
    Grid.Cells[COL_KEY, i + 1] := E.Key;
    Grid.Cells[COL_NL, i + 1] := E.NL;
    Grid.Cells[COL_EN, i + 1] := E.EN;
    Grid.Cells[COL_FR, i + 1] := E.FR;
    Grid.Cells[COL_DU, i + 1] := E.DU;
  end;

  LblStatus.Caption := Format('%d teksten geladen.', [LangEntryCount]);
end;

procedure TFLangEditor.SaveGridToTable;
var
  r: Integer;
  key: string;
begin
  ClearLangTable;

  for r := 1 to Grid.RowCount - 1 do
  begin
    // Key niet trimmen: hij moet letterlijk gelijk blijven aan het
    // TR()-argument in de broncode, inclusief eventuele voorloopspaties
    // (bv. '  Klik hier voor extra funkties').
    key := Grid.Cells[COL_KEY, r];
    if Trim(key) = '' then
      Continue;

    SetTranslation(key, langNL, Grid.Cells[COL_NL, r]);
    SetTranslation(key, langEN, Grid.Cells[COL_EN, r]);
    SetTranslation(key, langFR, Grid.Cells[COL_FR, r]);
    SetTranslation(key, langDU, Grid.Cells[COL_DU, r]);
  end;
end;

procedure TFLangEditor.GridSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := True;

  // Key-kolom is de opzoeksleutel waarmee TR() in de broncode werkt: eens
  // ingevuld mag die niet per ongeluk via de grid gewijzigd worden. Op een
  // nog lege rij (bv. net toegevoegd via "Rij +") blijft hij wel
  // bewerkbaar, anders zou zo'n nieuwe rij nooit een key kunnen krijgen.
  if (aCol = COL_KEY) and (aRow > 0) and
     (Trim(Grid.Cells[COL_KEY, aRow]) <> '') then
    CanSelect := False;
end;

procedure TFLangEditor.BtOpenClick(Sender: TObject);
begin
  if not OpenDlg.Execute then
    Exit;

  ClearLangTable;
  LoadLanguageFile(OpenDlg.FileName);
  FCurrentFile := OpenDlg.FileName;
  LblFile.Caption := FCurrentFile;
  LoadGridFromTable;
end;

procedure TFLangEditor.BtSaveClick(Sender: TObject);
begin
  if FCurrentFile = '' then
  begin
    BtSaveAsClick(Sender);
    Exit;
  end;

  SaveGridToTable;
  SaveLanguageFile(FCurrentFile);
  LblStatus.Caption := Format('Bewaard: %s (%d teksten).', [FCurrentFile, LangEntryCount]);
end;

procedure TFLangEditor.BtSaveAsClick(Sender: TObject);
begin
  if not SaveDlg.Execute then
    Exit;

  FCurrentFile := SaveDlg.FileName;
  LblFile.Caption := FCurrentFile;
  BtSaveClick(Sender);
end;

// Zoekt in ASource alle TR('...'), TRH(control, '...') en TRC(control, '...')
// aanroepen en geeft de resulterende sleutel terug in AFoundKeys. Bij TRH/TRC
// wordt het eerste (control-)argument overgeslagen. Ondersteunt letterlijke
// strings, verdubbelde aanhalingstekens ('' = ingesloten '), en samenvoeging
// met + van strings en #NNN char-codes, bv.:
//   TR('tekst1' + #13 + 'tekst2')
//   TRH(FBtCellBold, 'Bold')
procedure TFLangEditor.ScanFileForTRKeys(const AFileName: string; AFoundKeys: TStringList);
var
  SL: TStringList;
  Src: string;
  p, len: Integer;

  function SkipWhite(pp: Integer): Integer;
  begin
    while (pp <= len) and (Src[pp] in [' ', #9, #13, #10]) do
      Inc(pp);
    Result := pp;
  end;

  // Parseert vanaf pp één term: 'string' of #NNN. Geeft de tekstwaarde
  // terug en zet pp door na de term. Result=False als er geen geldige
  // term staat (einde van de TR(...)-expressie).
  function ParseTerm(var pp: Integer; out AValue: string): Boolean;
  var
    codeStr: string;
  begin
    AValue := '';
    pp := SkipWhite(pp);
    if pp > len then
      Exit(False);

    if Src[pp] = '''' then
      begin
      Inc(pp);
      while pp <= len do
        begin
        if (Src[pp] = '''') then
          begin
          if (pp < len) and (Src[pp+1] = '''') then
            begin
            AValue := AValue + '''';
            Inc(pp, 2);
            end
          else
            begin
            Inc(pp);
            Break;
            end;
          end
        else
          begin
          AValue := AValue + Src[pp];
          Inc(pp);
          end;
        end;
      Result := True;
      end
    else if Src[pp] = '#' then
      begin
      Inc(pp);
      codeStr := '';
      while (pp <= len) and (Src[pp] in ['0'..'9']) do
        begin
        codeStr := codeStr + Src[pp];
        Inc(pp);
        end;
      if codeStr = '' then
        Exit(False);
      AValue := Chr(StrToIntDef(codeStr, 32));
      Result := True;
      end
    else
      Result := False;
  end;

  // pp wijst net na de openende '('. Bouwt de volledige sleutel op uit
  // term (+ term)*.
  function ParseTRArgument(var pp: Integer; out AKey: string): Boolean;
  var
    term: string;
  begin
    AKey := '';
    if not ParseTerm(pp, term) then
      Exit(False);
    AKey := term;

    pp := SkipWhite(pp);
    while (pp <= len) and (Src[pp] = '+') do
      begin
      Inc(pp);
      if not ParseTerm(pp, term) then
        Break;
      AKey := AKey + term;
      pp := SkipWhite(pp);
      end;

    Result := True;
  end;

  // Slaat het eerste (control-)argument van TRH/TRC over, tot en met de
  // komma die het scheidt van het tekst-argument. In onze code is dit
  // altijd een eenvoudige identifier, geen geneste haakjes/strings.
  function SkipControlArgument(var pp: Integer): Boolean;
  begin
    while (pp <= len) and (Src[pp] <> ',') and (Src[pp] <> ')') do
      Inc(pp);

    if (pp > len) or (Src[pp] <> ',') then
      Exit(False);

    Inc(pp); // komma zelf overslaan
    Result := True;
  end;

  procedure ScanPrefix(const APrefix: string; ASkipControlArg: Boolean);
  var
    startPos, pp: Integer;
    key: string;
  begin
    p := 1;
    while p <= len do
      begin
      startPos := PosEx(APrefix, Src, p);
      if startPos = 0 then
        Break;

      // Los woord: niet laten matchen als deel van een langere naam
      // (bv. 'TR(' mag niet matchen binnen 'TRH(' of 'TRC(').
      if (startPos > 1) and
         (Src[startPos - 1] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
        begin
        p := startPos + 1;
        Continue;
        end;

      pp := startPos + Length(APrefix);

      if ASkipControlArg then
        if not SkipControlArgument(pp) then
          begin
          p := startPos + Length(APrefix);
          Continue;
          end;

      if ParseTRArgument(pp, key) then
        if (key <> '') and (AFoundKeys.IndexOf(key) < 0) then
          AFoundKeys.Add(key);

      p := startPos + Length(APrefix);
      end;
  end;

begin
  if not FileExists(AFileName) then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFileName);
    Src := SL.Text;
  finally
    SL.Free;
  end;

  len := Length(Src);

  ScanPrefix('TR(', False);
  ScanPrefix('TRH(', True);
  ScanPrefix('TRC(', True);
end;

procedure TFLangEditor.BtScanClick(Sender: TObject);
var
  Files, Found: TStringList;
  i, beforeCount, addedCount: Integer;
begin
  if not ScanDlg.Execute then
    Exit;

  Files := FindAllFiles(ScanDlg.FileName, '*.pas', True);
  Found := TStringList.Create;
  try
    for i := 0 to Files.Count - 1 do
      ScanFileForTRKeys(Files[i], Found);

    // TRLang(key, langNL) maakt de key aan (via FindOrCreateEntry) als hij nog
    // niet bestond; bestaande keys blijven ongewijzigd (idempotent).
    beforeCount := LangEntryCount;
    for i := 0 to Found.Count - 1 do
      TRLang(Found[i], langNL);
    addedCount := LangEntryCount - beforeCount;

    LoadGridFromTable;
    ShowMessage(Format('%d bestanden gescand, %d teksten gevonden, %d nieuw toegevoegd.',
      [Files.Count, Found.Count, addedCount]));
  finally
    Found.Free;
    Files.Free;
  end;
end;

procedure TFLangEditor.BtAddRowClick(Sender: TObject);
begin
  Grid.RowCount := Grid.RowCount + 1;
  Grid.Row := Grid.RowCount - 1;
end;

procedure TFLangEditor.BtDeleteRowClick(Sender: TObject);
begin
  if (Grid.RowCount > 2) and (Grid.Row >= 1) then
    Grid.DeleteRow(Grid.Row);
end;

procedure TFLangEditor.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  SaveGridToTable;
  CanClose := True;
end;

end.
