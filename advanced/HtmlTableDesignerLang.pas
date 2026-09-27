                                  unit HtmlTableDesignerLang;

{$mode objfpc}{$H+}

// ==============================================================================
// Lichte, eigen vertaal-("i18n")-laag voor HtmlTableDesignerAdvanced.
//
// Werking:
//   - Elke vaste tekst in de code wordt aangeroepen als TR('brontekst').
//     Die brontekst (zoals ze letterlijk in de code staat, soms toevallig
//     Engels) is de onveranderlijke opzoeksleutel (Key) - TR() blijft die
//     exacte string als argument krijgen, dus Key mag nooit wijzigen.
//   - NL/EN/FR/DU zijn daarentegen vier volwaardige, vrij te bewerken
//     vertaalkolommen. Bij aanmaak wordt NL initieel gelijk aan Key gezet
//     (praktisch startpunt), maar dat is enkel een default: via
//     SetTranslation of LoadLanguageFile kan NL nadien gewoon overschreven
//     worden met correct Nederlands, los van wat Key is.
//   - CurrentLanguage bepaalt welke kolom TR() teruggeeft. Is er (nog) geen
//     vertaling voor de huidige taal, dan valt TR() terug op NL, zodat de
//     component altijd bruikbaar blijft, ook zonder vertaalbestand.
//   - Een Key die nog niet in de tabel zit, wordt automatisch aangemaakt
//     (NL := Key, EN/FR/DU leeg). Zo bouwt de tabel zichzelf op door de
//     applicatie te gebruiken (of door LangEditor de broncode te laten
//     scannen op TR(...)-aanroepen).
//   - LoadLanguageFile/SaveLanguageFile lezen/schrijven een eenvoudig
//     TAB-gescheiden tekstbestand (1 regel per key:
//     Key<TAB>NL<TAB>EN<TAB>FR<TAB>DU), zodat het zowel door LangEditor als
//     in Excel/Kladblok te bewerken is.
// ==============================================================================

interface

uses
  Classes, SysUtils;

type
  TUILanguage = (langNL, langEN, langFR, langDU);

  TLangEntry = class
  public
    Key: string;         // onveranderlijke opzoeksleutel = het TR()-argument
    NL, EN, FR, DU: string;
  end;

var
  // Huidige weergavetaal van de component. Standaard Nederlands, zodat
  // bestaande projecten zonder verdere actie blijven werken zoals voorheen.
  CurrentLanguage: TUILanguage = langNL;

  // True zodra TR() een key heeft aangemaakt die nog niet bewaard is
  // (handig om te weten of SaveLanguageFile de moeite waard is).
  LangTableDirty: Boolean = False;

// Hoofd-functie: geef de tekst voor AKey terug in CurrentLanguage.
// Onbekende key -> automatisch geregistreerd met NL := AKey.
function TR(const AKey: string): string;

// Vertaling opvragen/instellen voor een specifieke taal.
function TRLang(const AKey: string; ALang: TUILanguage): string;
procedure SetTranslation(const AKey: string; ALang: TUILanguage; const AValue: string);

procedure LoadLanguageFile(const AFileName: string);
procedure SaveLanguageFile(const AFileName: string);

// Voor de editor: alle keys in invoegvolgorde.
function LangEntryCount: Integer;
function LangEntryByIndex(AIndex: Integer): TLangEntry;

procedure ClearLangTable;

implementation

var
  // FKeys.Objects[i] = TLangEntry; FKeys.Strings[i] = NL-tekst (key)
  FKeys: TStringList;

function FindOrCreateEntry(const AKey: string): TLangEntry;
var
  idx: Integer;
begin
  idx := FKeys.IndexOf(AKey);
  if idx >= 0 then
    Exit(TLangEntry(FKeys.Objects[idx]));

  Result := TLangEntry.Create;
  Result.Key := AKey;
  Result.NL := AKey;  // praktisch startpunt; vrij overschrijfbaar nadien
  FKeys.AddObject(AKey, Result);
  LangTableDirty := True;
end;

function TR(const AKey: string): string;
var
  E: TLangEntry;
begin
  E := FindOrCreateEntry(AKey);

  case CurrentLanguage of
    langNL: Result := E.NL;
    langEN: Result := E.EN;
    langFR: Result := E.FR;
    langDU: Result := E.DU;
  else
    Result := E.NL;
  end;

  if Result = '' then
    Result := E.NL;  // fallback: geen vertaling -> Nederlandse tekst
end;

function TRLang(const AKey: string; ALang: TUILanguage): string;
var
  E: TLangEntry;
begin
  E := FindOrCreateEntry(AKey);
  case ALang of
    langNL: Result := E.NL;
    langEN: Result := E.EN;
    langFR: Result := E.FR;
    langDU: Result := E.DU;
  else
    Result := E.NL;
  end;
end;

procedure SetTranslation(const AKey: string; ALang: TUILanguage; const AValue: string);
var
  E: TLangEntry;
begin
  E := FindOrCreateEntry(AKey);
  case ALang of
    langNL: E.NL := AValue;
    langEN: E.EN := AValue;
    langFR: E.FR := AValue;
    langDU: E.DU := AValue;
  end;
  LangTableDirty := True;
end;

function LangEntryCount: Integer;
begin
  Result := FKeys.Count;
end;

function LangEntryByIndex(AIndex: Integer): TLangEntry;
begin
  Result := TLangEntry(FKeys.Objects[AIndex]);
end;

procedure ClearLangTable;
var
  i: Integer;
begin
  for i := 0 to FKeys.Count - 1 do
    FKeys.Objects[i].Free;
  FKeys.Clear;
  LangTableDirty := False;
end;

// Splits een TAB-gescheiden regel in maximaal 5 velden (Key, NL, EN, FR, DU).
// Ontbrekende velden aan het einde worden lege strings.
// Bewust geen ExtractStrings: die behandelt ' en " altijd als
// aanhalingstekens, waardoor bv. "extra's" of "qu'horizontalement" de
// velden door elkaar haalt. Hier telt enkel de TAB als scheidingsteken.
procedure SplitTabLine(const ALine: string; out F1, F2, F3, F4, F5: string);
var
  Parts: array[0..4] of string;
  i, Start, FieldIdx: Integer;
begin
  for i := 0 to High(Parts) do
    Parts[i] := '';

  FieldIdx := 0;
  Start := 1;
  for i := 1 to Length(ALine) + 1 do
  begin
    if (i > Length(ALine)) or (ALine[i] = #9) then
    begin
      if FieldIdx <= High(Parts) then
        Parts[FieldIdx] := Copy(ALine, Start, i - Start);
      Inc(FieldIdx);
      Start := i + 1;
    end;
  end;

  F1 := Parts[0];
  F2 := Parts[1];
  F3 := Parts[2];
  F4 := Parts[3];
  F5 := Parts[4];
end;

// Vervangt letterlijke newlines/tabs in een veld door escape-reeksen zodat
// het bestand netjes 1 regel per key blijft (Hints kunnen #13 bevatten).
function EscapeField(const S: string): string;
begin
  Result := StringReplace(S, #9, '\t', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

function UnescapeField(const S: string): string;
begin
  // Belangrijk: dit moet exact de regeleinde-conventie zijn die de
  // TR()-aanroepen zelf gebruiken (bv. '...' + LineEnding + '...').
  // LineEnding is #13#10 op Windows en #10 op Linux; als hier altijd
  // een vaste #13 zou staan, matcht de sleutel uit dit bestand nooit
  // de live sleutel uit TR() op het platform waar LineEnding niet
  // gelijk is aan een losse #13 - de vertaling zou dan telkens
  // stilzwijgend genegeerd worden (nieuwe, lege entry aangemaakt).
  Result := StringReplace(S, '\n', LineEnding, [rfReplaceAll]);
  Result := StringReplace(Result, '\t', #9, [rfReplaceAll]);
end;

procedure LoadLanguageFile(const AFileName: string);
var
  Lines: TStringList;
  i: Integer;
  F1, F2, F3, F4, F5: string;
  E: TLangEntry;
begin
  if not FileExists(AFileName) then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);

    for i := 0 to Lines.Count - 1 do
    begin
      if Trim(Lines[i]) = '' then
        Continue;

      SplitTabLine(Lines[i], F1, F2, F3, F4, F5);
      if F1 = '' then
        Continue;

      // F1 = Key (opzoeksleutel, = het TR()-argument in de broncode).
      E := FindOrCreateEntry(UnescapeField(F1));
      E.NL := UnescapeField(F2);
      E.EN := UnescapeField(F3);
      E.FR := UnescapeField(F4);
      E.DU := UnescapeField(F5);
    end;
  finally
    Lines.Free;
  end;

  LangTableDirty := False;
end;

procedure SaveLanguageFile(const AFileName: string);
var
  Lines: TStringList;
  i: Integer;
  E: TLangEntry;
begin
  Lines := TStringList.Create;
  try
    for i := 0 to FKeys.Count - 1 do
    begin
      E := TLangEntry(FKeys.Objects[i]);
      Lines.Add(
        EscapeField(E.Key) + #9 +
        EscapeField(E.NL) + #9 +
        EscapeField(E.EN) + #9 +
        EscapeField(E.FR) + #9 +
        EscapeField(E.DU)
      );
    end;
    Lines.SaveToFile(AFileName);
  finally
    Lines.Free;
  end;

  LangTableDirty := False;
end;

initialization
  FKeys := TStringList.Create;
  FKeys.Sorted := False;  // invoegvolgorde bewaren (leesbaarder in de editor)
  FKeys.Duplicates := dupIgnore;

finalization
  ClearLangTable;
  FKeys.Free;

end.

