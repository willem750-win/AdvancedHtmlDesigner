unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  Spin, StdCtrls, HtmlTableDesignerAdvanced, HtmlTableDesigner, ExpandPanels,
  ComCtrls, SynEdit, SynHighlighterHTML, LCLIntf, HtmlTableDesignerLang, Math, uAbout;

type

  { TForm1 }

  TForm1 = class(TForm)
    btextrafunc: TSpeedButton;
    btLoad: TSpeedButton;
    btnKopToKlembord: TSpeedButton;
    btnKopToKlembord1: TSpeedButton;
    btSave: TSpeedButton;
    BtTestBrowser: TSpeedButton;
    EHtml: TSynEdit;
    EHtml1: TSynEdit;
    HtmlTableDesignerAdvanced1: THtmlTableDesignerAdvanced;
    icons16x16: TImageList;
    icons16_34: TImageList;
    flags: TImageList;
    MyRollOut1: TMyRollOut;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PSystem: TPanel;
    SaveDialogHTD: TSaveDialog;
    SavHtml: TSpeedButton;
    SavHtml1: TSpeedButton;
    ScrollBox1: TScrollBox;
    btWclose: TSpeedButton;
    btClose: TSpeedButton;
    btInfo: TSpeedButton;
    bthelp: TSpeedButton;
    SynHTMLSyn1: TSynHTMLSyn;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TimerFloatingTools: TTimer;
    procedure btCloseClick(Sender: TObject);
    procedure btextrafuncClick(Sender: TObject);
    procedure bthelpClick(Sender: TObject);
    procedure btInfoClick(Sender: TObject);
    procedure btLoadClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure BtTestBrowserClick(Sender: TObject);
    procedure btWcloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HtmlTableDesignerAdvanced1CellClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure HtmlTableDesignerAdvanced1SettingsClick(Sender: TObject);
    procedure HtmlTableDesignerAdvanced1TextBlockSettingsClick(Sender: TObject);
    procedure MyRollOut1Click(Sender: TObject);
    procedure MyRollOut1Collapse(Sender: TObject);
    procedure MyRollOut1Expand(Sender: TObject);
    procedure PSystemClick(Sender: TObject);
    procedure SavHtmlClick(Sender: TObject);
    procedure TimerFloatingToolsTimer(Sender: TObject);
    // Drag Form
    procedure PTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PTopMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PTopMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FLastScrollX: Integer;
    FLastScrollY: Integer;
    FUpdatingPreview: Boolean;
    FPendingHtml: string;
    // Drag Form
    FDragging: Boolean;
    FMouseDownPos: TPoint;
    FFormStartPos: TPoint;

    // Vertaalt de eigen knoppen/tabs/hints van dit formulier (niet die van
    // HtmlTableDesignerAdvanced1, die regelt dat zelf). Sender wordt niet
    // gebruikt; de signatuur komt overeen met TNotifyEvent zodat dit
    // rechtstreeks als OnLanguageChanged gekoppeld kan worden.
    procedure ApplyFormLanguage(Sender: TObject);


  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  // Online help (GitHub Pages), gebruikt als de map help naast de .exe ontbreekt
  HelpOnlineURL = 'https://willem750-win.github.io/AdvancedHtmlDesigner/';

{ TForm1 }

{-------------------------------------------------------------------------------
// Drag Form
-------------------------------------------------------------------------------}
procedure TForm1.PTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    if Button = mbLeft then
    begin
      FDragging := True;
      FMouseDownPos := Mouse.CursorPos;         // scherm-coords
      FFormStartPos := Point(Left, Top);        // onthoud beginpositie
      PSystEm.Cursor := crSizeAll;
    end;
  end;

  procedure TForm1.PTopMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  var
    dx, dy: Integer;
    R: TRect;
    NewLeft, NewTop: Integer;
  begin
    if FDragging then
    begin
      dx := Mouse.CursorPos.X - FMouseDownPos.X;
      dy := Mouse.CursorPos.Y - FMouseDownPos.Y;

      // binnen werkgebied van monitor houden
      if Assigned(Monitor) then
        R := Monitor.WorkareaRect
      else
        R := Screen.WorkAreaRect;

      NewLeft := FFormStartPos.X + dx;
      NewTop  := FFormStartPos.Y + dy;

      // begrenzen (mag uit als vrij slepen gewenst is)
      NewLeft := EnsureRange(NewLeft, R.Left,  R.Right  - Width);
      NewTop  := EnsureRange(NewTop,  R.Top,   R.Bottom - Height);

      SetBounds(NewLeft, NewTop, Width, Height);
    end;
  end;

  procedure TForm1.PTopMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
    if Button = mbLeft then
    begin
      FDragging := False;
      PSystem.Cursor := crHandPoint;
    end;
  end;

{------------------------------------------------------------------------------}

procedure TForm1.FormCreate(Sender: TObject);
var
  dir:String;
begin
   {$IFDEF LINUX}
   MyRollOut1.Visible := not MyRollOut1.Collapsed;
   {$ENDIF}

   FLastScrollX := -1;
   FLastScrollY := -1;

  // Hints laten opvallen: toepassingsbrede instelling (TApplication),
  // bewust niet in HtmlTableDesignerAdvanced zelf gezet (zie comment
  // daar) omdat het anders voor elke instantie/toepassing zou gelden.
  Application.HintColor := clYellow;

  // Tekstkleur expliciet zwart: zonder dit gebruikt GTK op Linux de
  // tekstkleur van het systeemthema (bv. lichtgrijs/wit bij een donker
  // thema), wat op de gele achtergrond onleesbaar/"leeg" oogt. Op
  // Windows viel dit niet op omdat de systeem-tooltiptekst daar sowieso
  // zwart is.
  Screen.HintFont.Color := clBlack;

  Application.HintPause := 400;      // sneller tonen
  Application.HintHidePause := 8000; // langer zichtbaar blijven

  TimerFloatingTools.Enabled := True;

    // drag op het gradient-paneel
  PSystem.OnMouseDown := @PTopMouseDown;
  PSystem.OnMouseMove := @PTopMouseMove;
  PSystem.OnMouseUp   := @PTopMouseUp;
  PSystem.Cursor := crSizeAll;



   dir:= IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

   HtmlTableDesignerAdvanced1.LoadFromHTD(dir + 'htd' + PathDelim + 'temp.htd');

   // Dialogs
  OpenDialog1.Filter := 'HTML Table Designer (*.htd)|*.htd|Alle bestanden (*.*)|*.*';
  OpenDialog1.DefaultExt := 'htd';
  OpenDialog1.InitialDir :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) + 'htd';
  //---------------------------------------------------------------------------------

   SaveDialogHTD.Filter := 'HTML Table Designer (*.htd)|*.htd|Alle bestanden (*.*)|*.*';
   SaveDialogHTD.DefaultExt := 'htd';
   SaveDialogHTD.InitialDir :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)) + 'htd';

  // Eigen knoppen/tabs/hints van dit formulier meteen in de huidige taal
  // zetten, en verder synchroon houden met de taal-combobox van de
  // designer (talen.lng werd al ingeladen bij het aanmaken van
  // HtmlTableDesignerAdvanced1, dus TR() hieronder vindt de vertalingen).
  HtmlTableDesignerAdvanced1.OnLanguageChanged := @ApplyFormLanguage;
  ApplyFormLanguage(Self);
end;

procedure TForm1.ApplyFormLanguage(Sender: TObject);
begin
  btSave.Hint := TR('Opslaan tabel designer...');
  btLoad.Hint := TR('Openen tabel designer...');

  btClose.Hint := TR('Close');
  btInfo.Hint := TR('About');
  bthelp.Hint := TR('Help');

  MyRollOut1.Hint :=
    TR(
      'Klik hier voor extra''s' + #13#10 +
      '- Html dokument code...' + #13#10 +
      '- Html tabel code ...' + #13#10 +
      '- Resultaat in interne brouwser...'
    );
  // In ingeklapte toestand hangt de muis boven de knop van de rollout,
  // niet boven het paneel zelf: de knop dus dezelfde vertaalde hint geven.
  MyRollOut1.Button.Hint := MyRollOut1.Hint;
  MyRollOut1.Button.Caption := TR('  Klik hier voor extra funkties');

  TabSheet2.Hint := TR('Html dokunent');
  TabSheet2.Caption := TR('Html-Dokument');

  btnKopToKlembord.Hint := TR('Kopieer HTML Document' + #13#10 + 'naar klembord');
  SavHtml.Hint := TR('Bewaar HTML Document...');
  BtTestBrowser.Caption := TR('Open test-browser');
  BtTestBrowser.Hint := TR('Toon het HTML document in de test-browser');

  TabSheet3.Hint := TR('Html-Panel');
  TabSheet3.Caption := TR('Html-Tabel');

  btnKopToKlembord1.Hint := TR('Kopieer HTML Document' + #13#10 + 'naar klembord');
  SavHtml1.Hint := TR('Bewaar HTML Document...');
end;

procedure TForm1.btSaveClick(Sender: TObject);
begin
  if SaveDialogHTD.Execute then
    HtmlTableDesignerAdvanced1.SaveToHTD(SaveDialogHTD.FileName);
end;


procedure TForm1.BtTestBrowserClick(Sender: TObject);
var
  FileName: string;
begin
  FileName :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) + 'previewN.html';

  if not FileExists(FileName) then
  begin
    ShowMessage('Genereer eerst een preview (klap het rolluik uit).');
    Exit;
  end;

  OpenDocument(FileName);

  BtTestBrowser.Enabled := False;
  MyRollOut1.Collapsed := True;
end;

procedure TForm1.btWcloseClick(Sender: TObject);
begin
 MyRollOut1.Collapsed:=true;;
end;

procedure TForm1.btLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    HtmlTableDesignerAdvanced1.LoadFromHTD(OpenDialog1.FileName);
end;

procedure TForm1.btCloseClick(Sender: TObject);
begin
   close;
end;

procedure TForm1.btextrafuncClick(Sender: TObject);
begin
  // Onder Linux (GTK2) blijft de PageControl van een ingeklapt rolluik
  // zichtbaar bovenop de balk; daar wordt het rolluik daarom verborgen
  // zolang het dicht is (zie MyRollOut1Collapse).
  {$IFDEF LINUX}
  if MyRollOut1.Collapsed then
    MyRollOut1.Visible := True;
  {$ENDIF}

  MyRollOut1.Collapsed := not MyRollOut1.Collapsed;
end;

procedure TForm1.btInfoClick(Sender: TObject);
begin
  ShowAbout(Self);
end;

procedure TForm1.bthelpClick(Sender: TObject);
var
  HelpDir, LangDir, FileName: string;
begin
  HelpDir :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) + 'help' + PathDelim;

  // Help in dezelfde taal als de designer (map help\nl, help\en, ...)
  case CurrentLanguage of
    langEN: LangDir := 'en';
    langFR: LangDir := 'fr';
    langDU: LangDir := 'de';
  else
    LangDir := 'nl';
  end;

  FileName := HelpDir + LangDir + PathDelim + 'index.html';

  // Ontbreekt die taal, dan terugvallen op Nederlands
  if not FileExists(FileName) then
    FileName := HelpDir + 'nl' + PathDelim + 'index.html';

  if FileExists(FileName) then
  begin
    OpenDocument(FileName);
    Exit;
  end;

  // Geen map help naast de .exe (bv. enkel de .exe gekopieerd):
  // de online help in dezelfde taal openen
  if not OpenURL(HelpOnlineURL + LangDir + '/index.html') then
    ShowMessage(TR('Help-bestanden niet gevonden:') + LineEnding + FileName +
      LineEnding + LineEnding + HelpOnlineURL);
end;

procedure TForm1.HtmlTableDesignerAdvanced1CellClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  HtmlTableDesignerAdvanced1.ActiveTool := atCell;
end;





procedure TForm1.HtmlTableDesignerAdvanced1SettingsClick(Sender: TObject);
begin
   HtmlTableDesignerAdvanced1.ActiveTool := atTable;
end;

procedure TForm1.HtmlTableDesignerAdvanced1TextBlockSettingsClick(
  Sender: TObject);
begin
   HtmlTableDesignerAdvanced1.ActiveTool := atTextBlock;
end;

procedure TForm1.MyRollOut1Click(Sender: TObject);
begin

end;

procedure TForm1.MyRollOut1Collapse(Sender: TObject);
begin
   {$IFDEF LINUX}
   MyRollOut1.Visible := False;
   {$ENDIF}

   BtTestBrowser.Enabled:=False;
   EHtml.ClearAll;
   EHtml1.ClearAll;
end;

procedure TForm1.MyRollOut1Expand(Sender: TObject);
var
   FileName,URL: string;
   SL: TStringList;
  begin
  FPendingHtml := HtmlTableDesignerAdvanced1.ToHTMLDocument;

  EHtml.Lines.Text  := FPendingHtml;
  EHtml1.Lines.Text := HtmlTableDesignerAdvanced1.ToHTML;

  FileName :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) + 'previewN.html';

  SL := TStringList.Create;
  try
    SL.Text := FPendingHtml;
    SL.SaveToFile(FileName);
  finally
    SL.Free;
  end;

  TabSheet3.TabVisible := true;
  PageControl1.ActivePage:= PageControl1.Pages[0];
  BtTestBrowser.Enabled:=True;
end;

procedure TForm1.PSystemClick(Sender: TObject);
begin

end;

procedure TForm1.SavHtmlClick(Sender: TObject);
var
   DialogS:TSaveDialog;
begin
    DialogS:=TSaveDialog.Create(Self);
    try
       // Set DailogS properties
      DialogS.Title :=  'Bewaar HTML-bestand';
      DialogS.Filter := 'HTML Document (*.html)|*.html|Alle bestanden (*.*)|*.*';
      DialogS.DefaultExt := 'html';
      DialogS.InitialDir :=
         IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'html';

      if DialogS.Execute then
       begin
        EHtml.Lines.SaveToFile(DialogS.FileName);
       end;
   finally
    // Always free the dialog from memory after use
    DialogS.Free;
  end;
end;


procedure TForm1.TimerFloatingToolsTimer(Sender: TObject);
var
  X, Y: Integer;
begin
  X := ScrollBox1.HorzScrollBar.Position;
  Y := ScrollBox1.VertScrollBar.Position;

  // Alleen bijwerken wanneer werkelijk gescrold word
  if (X = FLastScrollX) and (Y = FLastScrollY) then
    Exit;

  FLastScrollX := X;
  FLastScrollY := Y;

  HtmlTableDesignerAdvanced1.UpdateFloatingTools(X, Y);
end;

end.

