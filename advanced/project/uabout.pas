unit uAbout;

{$mode objfpc}{$H+}
// Lege contactconstanten maken sommige code "onbereikbaar": dat is de bedoeling
{$WARN 6018 OFF}

// Info-venster ("Over ...") van Advanced Html Designer.
// Het venster wordt in code opgebouwd (geen .lfm nodig).
// Pas de gegevens hieronder aan; lege velden worden niet getoond.
// Het versienummer komt uit de versie-info van het project
// (Project > Projectopties > Versie-info).

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, LCLIntf,
  LCLVersion, FileInfo
  {$IFDEF WINDOWS}, WinPEImageReader{$ENDIF}
  {$IFDEF LINUX}, ElfReader{$ENDIF}
  {$IFDEF DARWIN}, MachOReader{$ENDIF},
  HtmlTableDesignerLang;

const
  // ------------------------------------------------------------
  // App- en contactgegevens: hier invullen
  // ------------------------------------------------------------
  AboutAppName     = 'Advanced Html Designer';
  AboutDescription = 'Ontwerp visueel HTML-tabellen met opgemaakte cellen, ' +
                     'afbeeldingen, hyperlinks en vrij te plaatsen tekstblokken.';
  AboutAuthor      = 'Willy Jansen';   // bv. 'Voornaam Achternaam'
  AboutEmail       = 'willyjansen@telenet.be';   // bv. 'naam@voorbeeld.be'
  AboutWebsite     = '';   // bv. 'https://www.voorbeeld.be'
  AboutCopyright   = '© 2026 Willy Jansen';   // bv. '© 2026 Voornaam Achternaam'

// Toont het Info-venster modaal boven AOwner.
procedure ShowAbout(AOwner: TCustomForm);

// Versie uit de versie-info van de .exe, bv. '1.0.0.0' ('' als die ontbreekt).
function AppVersion: string;

implementation

type

  { TAboutForm }

  TAboutForm = class(TForm)
  private
    procedure AddLabel(AParent: TWinControl; const ACaption: string;
      AStyle: TFontStyles = []; ASize: Integer = 0);
    procedure AddLink(AParent: TWinControl; const APrefix, ACaption,
      AURL: string);
    procedure LinkClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

function AppVersion: string;
var
  FVI: TFileVersionInfo;
begin
  Result := '';
  FVI := TFileVersionInfo.Create(nil);
  try
    try
      FVI.FileName := ParamStr(0);
      FVI.ReadFileInfo;
      Result := FVI.VersionStrings.Values['FileVersion'];
    except
      Result := '';
    end;
  finally
    FVI.Free;
  end;
end;

procedure ShowAbout(AOwner: TCustomForm);
var
  F: TAboutForm;
begin
  F := TAboutForm.Create(AOwner);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ TAboutForm }

procedure TAboutForm.AddLabel(AParent: TWinControl; const ACaption: string;
  AStyle: TFontStyles; ASize: Integer);
var
  L: TLabel;
begin
  L := TLabel.Create(Self);
  L.Parent := AParent;
  L.Align := alTop;
  // alTop-controls worden op Top gesorteerd: oplopend = aanmaakvolgorde
  L.Top := AParent.ControlCount * 100;
  L.WordWrap := True;
  L.AutoSize := True;
  L.Caption := ACaption;
  L.Font.Style := AStyle;
  if ASize > 0 then
    L.Font.Size := ASize;
  L.BorderSpacing.Bottom := 4;
end;

procedure TAboutForm.AddLink(AParent: TWinControl; const APrefix, ACaption,
  AURL: string);
var
  Row: TPanel;
  L: TLabel;
begin
  Row := TPanel.Create(Self);
  Row.Parent := AParent;
  Row.Align := alTop;
  Row.Top := AParent.ControlCount * 100;
  Row.BevelOuter := bvNone;
  Row.AutoSize := True;
  Row.BorderSpacing.Bottom := 2;

  L := TLabel.Create(Self);
  L.Parent := Row;
  L.Align := alLeft;
  L.Caption := APrefix;
  L.Constraints.MinWidth := 80;

  L := TLabel.Create(Self);
  L.Parent := Row;
  L.Align := alLeft;
  L.Left := 1000;
  L.Caption := ACaption;
  L.Hint := AURL;
  L.Font.Color := clBlue;
  L.Font.Style := [fsUnderline];
  L.Cursor := crHandPoint;
  L.OnClick := @LinkClick;
end;

procedure TAboutForm.LinkClick(Sender: TObject);
begin
  OpenURL((Sender as TLabel).Hint);
end;

constructor TAboutForm.Create(AOwner: TComponent);
var
  PnlHead, PnlTitle, PnlBody, PnlButtons: TPanel;
  Img: TImage;
  BtnClose: TButton;
  Ver, Url: string;
begin
  // CreateNew: formulier zonder .lfm-resource
  inherited CreateNew(AOwner);

  Caption := Format(TR('Over %s'), [AboutAppName]);
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  Width := 460;
  Constraints.MinWidth := 460;
  Constraints.MaxWidth := 460;
  AutoSize := True;
  Color := clWindow;

  // ---------- kop: icoon + naam + versie ----------
  PnlHead := TPanel.Create(Self);
  PnlHead.Parent := Self;
  PnlHead.Align := alTop;
  PnlHead.BevelOuter := bvNone;
  PnlHead.AutoSize := True;
  PnlHead.BorderSpacing.Around := 16;

  Img := TImage.Create(Self);
  Img.Parent := PnlHead;
  Img.Align := alLeft;
  Img.Width := 48;
  Img.Height := 48;
  Img.Stretch := True;
  Img.Proportional := True;
  Img.Center := True;
  Img.BorderSpacing.Right := 14;
  if not Application.Icon.Empty then
    Img.Picture.Icon.Assign(Application.Icon);

  PnlTitle := TPanel.Create(Self);
  PnlTitle.Parent := PnlHead;
  PnlTitle.Align := alClient;
  PnlTitle.BevelOuter := bvNone;
  PnlTitle.AutoSize := True;

  AddLabel(PnlTitle, AboutAppName, [fsBold], 14);
  Ver := AppVersion;
  if Ver <> '' then
    AddLabel(PnlTitle, Format(TR('Versie %s'), [Ver]));
  AddLabel(PnlTitle, Format(TR('Gebouwd op %s'), [{$I %DATE%}]));

  // ---------- inhoud ----------
  PnlBody := TPanel.Create(Self);
  PnlBody.Parent := Self;
  PnlBody.Align := alTop;
  PnlBody.Top := 1000;
  PnlBody.BevelOuter := bvNone;
  PnlBody.AutoSize := True;
  PnlBody.BorderSpacing.Left := 16;
  PnlBody.BorderSpacing.Right := 16;

  AddLabel(PnlBody, TR(AboutDescription));

  if (AboutAuthor <> '') or (AboutEmail <> '') or (AboutWebsite <> '') then
  begin
    AddLabel(PnlBody, '');
    AddLabel(PnlBody, TR('Contact'), [fsBold]);
    if AboutAuthor <> '' then
      AddLabel(PnlBody, TR('Auteur:') + ' ' + AboutAuthor);
    if AboutEmail <> '' then
      AddLink(PnlBody, TR('E-mail:'), AboutEmail, 'mailto:' + AboutEmail);
    if AboutWebsite <> '' then
    begin
      Url := AboutWebsite;
      if Pos('://', Url) = 0 then
        Url := 'https://' + Url;
      AddLink(PnlBody, TR('Website:'), AboutWebsite, Url);
    end;
  end;

  AddLabel(PnlBody, '');
  if AboutCopyright <> '' then
    AddLabel(PnlBody, AboutCopyright);
  AddLabel(PnlBody, Format(TR('Gemaakt met Lazarus %s en Free Pascal %s'),
    [lcl_version, {$I %FPCVERSION%}]));

  // ---------- knop ----------
  PnlButtons := TPanel.Create(Self);
  PnlButtons.Parent := Self;
  PnlButtons.Align := alTop;
  PnlButtons.Top := 2000;
  PnlButtons.BevelOuter := bvNone;
  PnlButtons.Height := 48;
  PnlButtons.Color := clBtnFace;
  PnlButtons.ParentBackground := False;
  PnlButtons.BorderSpacing.Top := 12;

  BtnClose := TButton.Create(Self);
  BtnClose.Parent := PnlButtons;
  BtnClose.Caption := TR('Sluiten');
  BtnClose.ModalResult := mrOK;
  BtnClose.Default := True;
  BtnClose.Cancel := True;
  BtnClose.AutoSize := True;
  BtnClose.Constraints.MinWidth := 90;
  BtnClose.Align := alRight;
  BtnClose.BorderSpacing.Around := 10;
end;

end.
