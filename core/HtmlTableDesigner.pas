// VERSIE 1.0.0 Final
unit HtmlTableDesigner;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, Controls,Graphics, Types, StdCtrls, ExtCtrls, LCLType, LCLIntf,
LCLProc, Clipbrd, LResources, IniFiles, Math, Dialogs, ExtDlgs, FileUtil , Forms, Contnrs,
ImgList,  LazLogger, LazUTF8, base64;

type
TCellAlign = (caLeft, caCenter, caRight);
TImageAlign = (iaLeft, iaCenter, iaRight);
TSelectionMode = (smCell, smRow, smCol);
TTableChangeEvent = procedure(Sender: TObject) of object;
TCellBorderStyle = (cbsNone, cbsSolid, cbsDashed, cbsDotted, cbsDouble);
TImageSizeMode = (
ismOriginal,  // originele grootte
ismFit,       // proportioneel passend maken
ismStretch    // volledig uitrekken
);
TSettingsClickEvent = procedure(Sender: TObject) of object;// voor knopje in cell-panel eigenschappen
TTextBlockSettingsClickEvent = procedure(Sender: TObject) of object; // vvor knopje in textBlok

type
TDesignerTextLink = class
public
StartPos: Integer;
Length: Integer;
URL: string;

constructor Create;
end;


// Eén bereik met een expliciete (bold/italic/underline) opmaak die
// afwijkt van de blok-brede FontStyles - voor opmaak per woord/
// geselecteerd tekstdeel in een TextBlock.
TDesignerStyleRun = class
public
StartPos: Integer;
Length: Integer;
Styles: TFontStyles;

constructor Create;
end;


// Eén bereik met een expliciete tekstkleur die afwijkt van de
// blok-brede FontColor - voor kleur per woord/geselecteerd
// tekstdeel in een TextBlock.
TDesignerColorRun = class
public
StartPos: Integer;
Length: Integer;
Color: TColor;

constructor Create;
end;


TDesignerTextBlock = class
public
Text: string;
Rect: TRect;
FontStyles: TFontStyles;
FontSize: Integer;
FontColor: TColor;
Links: TObjectList;
StyleRuns: TObjectList; // TDesignerStyleRun-lijst: opmaak per tekstbereik
ColorRuns: TObjectList; // TDesignerColorRun-lijst: kleur per tekstbereik
LineHeight: Integer;
Alignment: TAlignment;
BgColor: TColor;
Transparent: Boolean;
BorderColor: TColor;
BorderWidth: Integer;
BorderStyle: TCellBorderStyle;
BorderRadius: Integer;
Padding: Integer;
WordWrap: Boolean;
Selected: Boolean;
//HintText
FHintText: string;


// Hyperlink  textBlock
IsLink: Boolean;
LinkURL: string;
LinkStart: Integer;
LinkLength: Integer;

// Hyperlink toevoegen aan Links
function AddLink(
AStartPos: Integer;
ALength: Integer;
const AURL: string
): TDesignerTextLink;

// Effectieve (bold/italic/underline) stijl op karakterpositie APos
// (0-based): StyleRuns overschrijven de blok-brede FontStyles.
function EffectiveStyleAt(APos: Integer): TFontStyles;

// Bold/italic/underline togglen voor exact het bereik
// [AStartPos, AStartPos+ALength); bestaande overlappende runs
// worden gesplitst zodat StyleRuns altijd niet-overlappend blijft.
procedure ToggleStyleRun(
AStartPos: Integer;
ALength: Integer;
AStyle: TFontStyle
);

// Effectieve tekstkleur op karakterpositie APos (0-based):
// ColorRuns overschrijven de blok-brede FontColor.
function EffectiveColorAt(APos: Integer): TColor;

// Tekstkleur instellen voor exact het bereik
// [AStartPos, AStartPos+ALength); zelfde splits-aanpak als
// ToggleStyleRun, maar direct instellen i.p.v. togglen.
procedure SetColorRun(
AStartPos: Integer;
ALength: Integer;
AColor: TColor
);

constructor Create;
destructor Destroy; override;


end;

////////////////////////////////
THtmlCell = class(TPersistent)
private
// voor borderstyle cell
FBorderStyle: TCellBorderStyle;
// voor font instellingen
FFontStyles: TFontStyles;
FFontSize: Integer;
//-----------------
// Teksthyperlink
FLinkURL: string;
FLinkText: string;
FIsLink: Boolean;
// Afbeeldingshyperlink
FImageIsLink: Boolean;
FImageLinkURL: string;
//---------------
//voor merge  cellen
FColSpan: Integer;
FRowSpan: Integer;
FMerged: Boolean;
FMasterCol: Integer;
FMasterRow: Integer;
FOriginalTextBeforeMerge: string;
FBackupText: string;
FBackupValid: Boolean;

FBorder:Boolean;
FText: string;
FBgColor: TColor;
FFontColor: TColor;
FAlign: TCellAlign;
FBold: Boolean;
FPicture: TPicture;
FImageFile: string;

FImageSizeMode: TImageSizeMode;
FShowImage: Boolean;
FImageStretch: Boolean;
FImageAlign: TImageAlign;
// voor HintText
FHintText: string;
public
constructor Create;
destructor Destroy; override;
published
property Text: string read FText write FText;
property BgColor: TColor read FBgColor write FBgColor;
property FontColor: TColor read FFontColor write FFontColor;
property Align: TCellAlign read FAlign write FAlign;

property Bold: Boolean read FBold write FBold;
property FontStyles: TFontStyles read FFontStyles write FFontStyles;
property FontSize: Integer read FFontSize write FFontSize;

property Picture: TPicture read FPicture;
property ImageFile: string read FImageFile write FImageFile;
property ShowImage: Boolean read FShowImage write FShowImage;
property ImageSizeMode: TImageSizeMode read FImageSizeMode write FImageSizeMode;
//modes : ismOriginal, // originele grootte ismFit,// proportioneel passend maken
// ismStretch    // volledig uitrekken
property ImageStretch: Boolean read FImageStretch write FImageStretch;
property ImageAlign: TImageAlign read FImageAlign write FImageAlign;

property Border: Boolean read FBorder write FBorder;
//voor HyperLink text
property IsLink: Boolean read FIsLink write FIsLink;
property LinkURL: string read FLinkURL write FLinkURL;
property LinkText: string read FLinkText write FLinkText;
// Afbeeldingshyperlink
property ImageIsLink: Boolean read FImageIsLink write FImageIsLink;
property ImageLinkURL: string read FImageLinkURL write FImageLinkURL;

//voor merge twee cellen
property ColSpan: Integer read FColSpan write FColSpan;
property RowSpan: Integer read FRowSpan write FRowSpan;
property Merged: Boolean read FMerged write FMerged;
property MasterCol: Integer read FMasterCol write FMasterCol;
property MasterRow: Integer read FMasterRow write FMasterRow;
property OriginalTextBeforeMerge: string read FOriginalTextBeforeMerge write FOriginalTextBeforeMerge;
property BackupText: string read FBackupText write FBackupText;
property BackupValid: Boolean read FBackupValid write FBackupValid;
// voor borderstyle cell
property BorderStyle: TCellBorderStyle read FBorderStyle write FBorderStyle;
property HintText: string read FHintText write FHintText;
end;
//

TCellClickEvent = procedure(Sender: TObject; ACol, ARow: Integer) of object;
TCellEditedEvent = procedure(Sender: TObject; ACol, ARow: Integer;const AText: string) of object;


type
THtmlCellData = record
Text: string;
BgColor: TColor;
FontColor: TColor;
FontSize: Integer;
FontStyles: TFontStyles;
Bold: Boolean;
Align: TCellAlign;

ImageFile: string;
ShowImage: Boolean;
ImageStretch: Boolean;
ImageSizeMode: TImageSizeMode; // nieuw
ImageAlign: TImageAlign;
Border: Boolean;
BorderStyle: TCellBorderStyle;
// Teksthyperlink
IsLink: Boolean;
LinkURL: string;
LinkText: string;
// Afbeeldingshyperlink
ImageIsLink: Boolean;
ImageLinkURL: string;

ColSpan: Integer;
RowSpan: Integer;
Merged: Boolean;
end;



THtmlTableDesigner = class(TCustomControl)
private
OpenPictureDialog1: TOpenPictureDialog;

FCells: array of array of THtmlCell;

FRowCount: Integer;
FColCount: Integer;

FSelectedCol: Integer;
FSelectedRow: Integer;

// NIEUW voor textBlock
FTextBlocks: TObjectList;
FSelectedTextBlock: TDesignerTextBlock;
FDraggingTextBlock: Boolean;
FTextBlockDragOffset: TPoint;
FResizingTextBlock: Boolean;
FTextBlockResizeStart: TPoint;
FTextBlockResizeOrigRect: TRect;
FEditingTextBlock: Boolean;

FTextBlockSelStart: Integer;
FTextBlockSelLength: Integer;

//
FGridColor: TColor;
FSelectionColor: TColor;
FSelectionMode: TSelectionMode;
// True zodra de gebruiker echt een cel/rij/kolom heeft geselecteerd;
// bepaalt of DrawSelection het rode kader tekent. Zonder deze vlag
// blijft het kader van de initiele (0,0)-cel getekend staan, ook
// wanneer er een TextBlock geselecteerd is of naast de tabel geklikt
// wordt, omdat FSelectedCol/FSelectedRow dan nog altijd geldig zijn.
FHasSelection: Boolean;
FShowGrid: Boolean;


FInplaceEdit: TMemo;

FEditing: Boolean;
FEditorCol: Integer;
FEditorRow: Integer;
FEditorOriginalText: string;

FDefaultColWidth: Integer;
FDefaultRowHeight: Integer;
//Header
FShowHeaders: Boolean;
FHeaderHeight: Integer;
FHeaderWidth: Integer;
FHeaderColor: TColor;
FHeaderFontColor: TColor;

FOnCellClick: TCellClickEvent;
FOnSelectionChange: TCellClickEvent;
FOnCellEdited: TCellEditedEvent;
FUpdatingEditorBounds: Boolean;
//Dynamisch
FColWidths: array of Integer;
FRowHeights: array of Integer;
FResizingCol: Integer;
FResizingRow: Integer;
FIsResizingCol: Boolean;
FIsResizingRow: Boolean;
FResizeStartX: Integer;
FResizeStartY: Integer;
FResizeOrigSize: Integer;
//multi-select
FMultiSelecting: Boolean;
FSelStartCol: Integer;
FSelStartRow: Integer;
FSelEndCol: Integer;
FSelEndRow: Integer;
// copy/Paste
FCopyBuffer: array of array of THtmlCellData;
FCopyCols: Integer;
FCopyRows: Integer;
FCopyColWidths: array of Integer;//5jun
FCopyRowHeights: array of Integer;//5jun
// resize
FAutoStretchTable: Boolean;
FAutoFitTable:Boolean;
// voor onchange
FOnChange: TTableChangeEvent;
// voor lijndikte
FGridLineWidth: Integer;
// achtergrond kleur
FHtmlBgColor: TColor;
// Pagina A4
FPageEnabled: Boolean;
FPageWidth: Integer;
FPageMarginX: Integer;
FPageMarginY: Integer;
FPageHeight: Integer;
FTableOffsetX: Integer;

// Extra vrije ruimte links voor afgeleide componenten
FWorkspaceOffsetX: Integer;

FTableOffsetY: Integer;
// tabel-sleepmodus slepen met Ctrl + linkermuisknop op de tabel/pagina.
FDraggingTable: Boolean;
FDragStartX: Integer;
FDragStartY: Integer;
FDragOrigOffsetX: Integer;
FDragOrigOffsetY: Integer;
//Rulers
FShowPageRulers :Boolean;
FRulerSize : Integer;
FRulerStep : Integer;
FPixelsPerMM: Double;

FExportTableBgColor: TColor;
FExportTableBorderColor: TColor;
FExportTableBorderWidth: Integer;
FExportTableBorderStyle: TCellBorderStyle;//WJ

FExportTableBorderRadius: Integer;

FExportCellBorderColor: TColor;
FExportCellBorderRadius: Integer;
FExportCellPadding: Integer;

FCellAfronding:Integer;

FImages: TCustomImageList;
FSettingsImageIndex: Integer;

FOnSettingsClick: TSettingsClickEvent;

FSettingsButtonHint: string;
FMoveTableHint:String;

FOnTextBlockSettingsClick: TTextBlockSettingsClickEvent;// voor knopje in textBlok
FTextBlockButtonHint: string;

FMouseX: Integer; // voor knopje in textBlok
FMouseY: Integer; // voor knopje in textBlok
FLastDesignerClickX: Integer;
FLastDesignerClickY: Integer;
FHasDesignerClickPos: Boolean;

GChangeCount: Integer;
// TextBlocks
//nodig voor inline memo
FPendingEditCol: Integer;
FPendingEditRow: Integer;

// zacht Grid
FShowLayoutGrid: Boolean;
FLayoutGridSize: Integer;
FLayoutGridColor: TColor;




function GetCellImageRect(ACol, ARow: Integer;const ACellRect: TRect): TRect;

procedure SetPageWidth(AValue: Integer);
procedure SetPageHeight(AValue: Integer);
procedure SetPageEnabled(AValue: Boolean);
procedure SetTableOffsetX(AValue: Integer);
procedure SetTableOffsetY(AValue: Integer);
procedure SetShowPageRulers(AValue: Boolean);

procedure DelayedStartCellEdit(Data: PtrInt);
procedure DelayedStartTextBlockEdit(Data: PtrInt);

procedure DrawTextBlocks;
procedure DrawTextBlock(ABlock: TDesignerTextBlock);
function TextBlockFromPoint(X, Y: Integer): TDesignerTextBlock;
function TextBlockResizeHandleRect(ABlock: TDesignerTextBlock): TRect;
function TextBlockOnResizeHandle(ABlock: TDesignerTextBlock; X, Y: Integer): Boolean;
procedure ClearTextBlockSelection;


procedure StartTextBlockEdit(ABlock: TDesignerTextBlock);

function TextBlockSettingsButtonRect(ABlock: TDesignerTextBlock): TRect; // voor knopje in textBlok
procedure DrawTextBlockSettingsButton(ABlock: TDesignerTextBlock);// voor knopje in textBlok

procedure SetWorkspaceOffsetX(AValue: Integer);
procedure SetImages(AValue: TCustomImageList);
procedure SetTableSettingsImageIndex(AValue: Integer);
procedure ReadLegacySettingsImageIndex(Reader: TReader);
procedure SetDefaultColWidth(AValue: Integer);
procedure SetExportTableBgColor(AValue: TColor);
procedure SetExportTableBorderColor(AValue: TColor);
procedure SetExportTableBorderWidth(AValue: Integer);
procedure SetExportTableBorderRadius(AValue: Integer);
procedure SetExportCellBorderColor(AValue: TColor);
procedure SetExportTableBorderStyle(AValue: TCellBorderStyle);//WJ
procedure SetExportCellBorderRadius(AValue: Integer);
procedure SetExportCellPadding(AValue: Integer);
procedure SetShowHeaders(AValue: Boolean);
procedure SetHeaderHeight(AValue: Integer);
procedure SetHeaderWidth(AValue: Integer);
procedure SetHeaderColor(AValue: TColor);
procedure SetHeaderFontColor(AValue: TColor);
procedure SetAutoStretchTable(AValue: Boolean);
procedure SetAutoFitTable(AValue: Boolean);
procedure DrawRulerMarker(const PageR: TRect;AX, AY: Integer);
procedure DrawPageRulers(const PageR: TRect);
procedure SetHtmlBgColor(AValue: TColor);
procedure NormalizeSelection(out L, T, R, B: Integer);
function TextToHTML(const S: string): string;
function HasMultiSelection: Boolean;
procedure CellToData(ACell: THtmlCell; out AData: THtmlCellData);
procedure DataToCell(const AData: THtmlCellData; ACell: THtmlCell);

procedure InitColRowSizes;
procedure SetRowCount(AValue: Integer);
procedure SetColCount(AValue: Integer);
procedure SetDefaultRowHeight(AValue: Integer);
procedure SetGridColor(AValue: TColor);
// zacht Grid -------------------------------
procedure SetShowLayoutGrid(AValue: Boolean);
procedure SetLayoutGridSize(AValue: Integer);
procedure SetLayoutGridColor(AValue: TColor);
//--------------------------------------------
procedure SetSelectionColor(AValue: TColor);
procedure SetShowGrid(AValue: Boolean);
procedure SetGridLineWidth(AValue: Integer);

procedure AllocateCells;
procedure FreeCells;

function GetCellRect(ACol, ARow: Integer): TRect;
function CellFromPoint(X, Y: Integer; out ACol, ARow: Integer): Boolean;
procedure DrawCell(ACol, ARow: Integer; const R: TRect);

procedure DrawSelection;
function ColBorderFromPoint(X, Y: Integer; out ACol: Integer): Boolean;
function RowBorderFromPoint(X, Y: Integer; out ARow: Integer): Boolean;
function EscapeHTML(const S: string): string;
function ColorToHTML(AColor: TColor): string;
function AlignToHTML(AAlign: TCellAlign): string;
function ColumnToName(ACol: Integer): string;// voor Header
function TextBlocksToHTML: string;// voor textBlock
function RowHeaderFromPoint(X, Y: Integer; out ARow: Integer): Boolean;
function ColHeaderFromPoint(X, Y: Integer; out ACol: Integer): Boolean;

function TotalTableWidth: Integer;
function TotalTableHeight: Integer;
function CellInCurrentSelection(ACol, ARow: Integer): Boolean;
function GetMergedCellRect(ACol, ARow: Integer): TRect;

function SmartImagePath(const AFileName: string): string;
function CopyImageToProjectImages(const ASourceFile: string): string;

procedure SetSelectedCell(ACol, ARow: Integer);
procedure CreateInplaceEditor;
procedure UpdateEditorBounds;
procedure StartEdit(ACol, ARow: Integer);
procedure EndEdit(AAccept: Boolean);

procedure InplaceEditEditingDone(Sender: TObject);
procedure InplaceEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure DrawHeaders;
procedure DrawSettingsButton;
procedure DrawCellImage(ACell: THtmlCell; const R: TRect);
procedure SelectMergedBlock(ACol, ARow: Integer);

function GetTableRect: TRect;
function GetHtmlTablePos: TPoint;

protected
procedure Paint; override;
// zacht grid
procedure DrawLayoutGrid;

procedure GetPageOffset(out OffsetX, OffsetY: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
procedure DblClick; override;
procedure Resize; override;
procedure KeyDown(var Key: Word; Shift: TShiftState); override;

// Wordt door de VCL/LCL aangeroepen wanneer een component waar dit
// component naar verwijst (Images) verwijderd wordt.
// Zonder deze override blijft FImages een "dangling pointer" als
// de gebruiker de gekoppelde ImageList van het formulier verwijdert,
// met een crash bij de eerstvolgende Paint tot gevolg.
procedure Notification(AComponent: TComponent; Operation: TOperation); override;

// Leest de oude eigenschapsnaam SettingsImageIndex uit bestaande .lfm's.
procedure DefineProperties(Filer: TFiler); override;

public
constructor Create(AOwner: TComponent); override;
destructor Destroy; override;

function TextBlockIsEditing: Boolean;
function GetTextBlockSelection(out AStart, ALength: Integer): Boolean;
procedure DeleteSelectedTextBlock;
procedure SetColWidth(ACol, AWidth: Integer);
procedure SetRowHeight(ARow, AHeight: Integer);

//procedure SetTextBlockLink(const AURL: string);

procedure SetTextBlockLink(AStartPos: Integer;ALength: Integer;const AURL: string);

// Bold/Italic/Underline togglen: enkel op de huidige tekstselectie
// in het geselecteerde TextBlock indien die bestaat, anders (zoals
// voorheen) op het hele tekstblok.
procedure ToggleTextBlockStyle(AStyle: TFontStyle);

// Tekstkleur toepassen: enkel op de huidige tekstselectie in het
// geselecteerde TextBlock indien die bestaat, anders (zoals
// voorheen) op het hele tekstblok.
procedure ApplyTextBlockFontColor(AColor: TColor);


procedure ClearTextBlockLink;

function GetSettingsButtonRect: TRect;
function GetCell(ACol, ARow: Integer): THtmlCell;
procedure AddTextBlock;// TextBlock
property SelectedTextBlock: TDesignerTextBlock read FSelectedTextBlock;// TextBlock
//Save en Load
procedure SaveToHTD(const AFileName: string);
procedure LoadFromHTD(const AFileName: string);
procedure SaveToHTDStream(AStream: TStream);
procedure LoadFromHTDStream(AStream: TStream);
procedure GetSelectionBounds(out L, T, R, B: Integer);
procedure ToggleStyleSelection(AStyle: TFontStyle);
procedure ChangeFontSizeSelection(Delta: Integer);
procedure DoChange;
procedure TextBlockChanged;
procedure ApplyBgColorToSelection(AColor: TColor);
procedure ApplyFontColorToSelection(AColor: TColor);
procedure ApplyTextAlignToSelection(AAlign: TCellAlign);
procedure ApplyImageAlignToSelection(AAlign: TImageAlign);
procedure ApplyBorderToSelection(ABorder: Boolean);
procedure ApplyBorderStyleToSelection(AStyle: TCellBorderStyle);

procedure ApplyBorderStyleTable(AStyle: TCellBorderStyle);
procedure ApplyBorderWidthTable(waarde: Integer);
procedure ApplyRowHeightTable(Waarde: Integer);
procedure ApplyGridWidthTable(waarde: Integer);

procedure ApplyColWidthTable(waarde:integer);

procedure ApplyBorderRadiusTable(waarde: Integer);
procedure ApplyBgColorTable(AColor: TColor);
procedure ApplyGridColorTable(AColor: TColor);
procedure ApplyKaderColorTable(AColor: TColor);

procedure Clear;
procedure SetCellText(ACol, ARow: Integer; const AText: string);
procedure SetCellColor(ACol, ARow: Integer; AColor: TColor);
procedure SetCellAlign(ACol, ARow: Integer; AAlign: TCellAlign);
procedure SetCellImageAlign(ACol, ARow: Integer; AAlign: TImageAlign);
procedure LoadCellImage(ACol, ARow: Integer; const AFileName: string);
procedure ClearCellImage(ACol, ARow: Integer);
procedure SetCellAfronding(AValue:Integer);

procedure DeleteRow(ARow: Integer);
procedure DeleteCol(ACol: Integer);
procedure RemoveImageFromSelection;
procedure InsertImageInSelectedCell;
procedure UpdateDesignerSize;
function ToHTML: string;
function ToHTMLDocument: string;

property Cells[ACol, ARow: Integer]: THtmlCell read GetCell;
//copy/paste
procedure CopySelection;
procedure PasteSelection;
function HasCopyBuffer: Boolean;
// Teksthyperlink
procedure SetLinkToSelection(const AURL, AText: string);
procedure ClearLinkFromSelection;
// Afbeeldingshyperlink
procedure SetImageLinkToSelection(const AURL: string);
procedure ClearImageLinkFromSelection;

function MMToPX(AMM: Double): Integer;
//voor merge cellen
function IsCellCovered(ACol, ARow: Integer): Boolean;
procedure MergeSelection;
procedure UnmergeSelection;
function SelectionContainsMergedCell: Boolean;
function CanMergeSelection: Boolean;
function RowTouchesMergedCell(ARow: Integer): Boolean;
function ColTouchesMergedCell(ACol: Integer): Boolean;
procedure UnmergeRow(ARow: Integer);
procedure UnmergeCol(ACol: Integer);
procedure FitTableToClient(AFitRows: Boolean = False);

function GetTablePixelWidth: Integer;
function GetTablePixelHeight: Integer;
procedure CenterTableOnPage;


published
property OnSettingsClick: TSettingsClickEvent  // voor knopje in tabel
read FOnSettingsClick
write FOnSettingsClick;
property Images: TCustomImageList
read FImages
write SetImages;

// Index in Images voor het instellingen-knopje linksboven in de tabel
// (en in een geselecteerd tekstblok). Heette vroeger SettingsImageIndex;
// die naam botste met de gelijknamige eigenschap van
// THtmlTableDesignerAdvanced. Oude .lfm-bestanden worden nog gelezen
// via DefineProperties.
property TableSettingsImageIndex: Integer
read FSettingsImageIndex
write SetTableSettingsImageIndex default 0;

property OnTextBlockSettingsClick: TTextBlockSettingsClickEvent // voor knopje in TextBlok
read FOnTextBlockSettingsClick
write FOnTextBlockSettingsClick;

property WorkspaceOffsetX: Integer
read FWorkspaceOffsetX
write SetWorkspaceOffsetX
default 0;

property Align;
property Anchors;
property Constraints;
property Width;
property Height;
property Left;
property Top;
property Color;
property Hint;
property ShowHint;
property ColCount: Integer read FColCount write SetColCount default 5;
property RowCount: Integer read FRowCount write SetRowCount default 5;
property CellAfronding:Integer read FCellAfronding write SetCellAfronding default 1;
property DefaultColWidth: Integer read FDefaultColWidth write SetDefaultColWidth default 100;
property DefaultRowHeight: Integer read FDefaultRowHeight write SetDefaultRowHeight default 28;
property GridColor: TColor read FGridColor write SetGridColor default clSilver;
// zacht grid
property ShowLayoutGrid: Boolean read FShowLayoutGrid write SetShowLayoutGrid default False;
property LayoutGridSize: Integer read FLayoutGridSize write SetLayoutGridSize default 10;
property LayoutGridColor: TColor read FLayoutGridColor write SetLayoutGridColor default clSilver;


property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clRed;
property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
property Font;
property ParentColor;
property ParentFont;
property PopupMenu;
property TabStop default True;
property SelectedCol: Integer read FSelectedCol default 0;
property SelectedRow: Integer read FSelectedRow default 0;
property Visible;
property GridLineWidth: Integer read FGridLineWidth write SetGridLineWidth default 1;
property OnCellClick: TCellClickEvent read FOnCellClick write FOnCellClick;
property OnSelectionChange: TCellClickEvent read FOnSelectionChange write FOnSelectionChange;
property OnCellEdited: TCellEditedEvent read FOnCellEdited write FOnCellEdited;

property HtmlBgColor: TColor read FHtmlBgColor write SetHtmlBgColor;
property OnClick;
property OnDblClick;
property OnMouseDown;
property OnMouseMove;
property OnMouseUp;
property OnChange: TTableChangeEvent read FOnChange write FOnChange;
// header
property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders default True;
property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 22;
property HeaderWidth: Integer read FHeaderWidth write SetHeaderWidth default 32;
property HeaderColor: TColor read FHeaderColor write SetHeaderColor default clBtnFace;
property HeaderFontColor: TColor read FHeaderFontColor write SetHeaderFontColor default clBlack;

property SelectionMode: TSelectionMode read FSelectionMode;
property AutoStretchTable: Boolean read FAutoStretchTable write SetAutoStretchTable default False;
property AutoFitTable: Boolean read FAutoFitTable write SetAutoFitTable default False;
// voor pagina groote
property PageEnabled: Boolean read FPageEnabled write SetPageEnabled default False;

property PageWidth: Integer read FPageWidth write SetPageWidth default 794;
property PageHeight: Integer read FPageHeight write SetPageHeight default 1123;

property TableOffsetX: Integer read FTableOffsetX write SetTableOffsetX default 40;
property TableOffsetY: Integer read FTableOffsetY write SetTableOffsetY default 40;
property ShowPageRulers:Boolean read FShowPageRulers write SetShowPageRulers default True;

property ExportTableBgColor: TColor read FExportTableBgColor write SetExportTableBgColor default clWhite;
property ExportTableBorderColor: TColor read FExportTableBorderColor write SetExportTableBorderColor default clBlack;
property ExportTableBorderWidth: Integer read FExportTableBorderWidth write SetExportTableBorderWidth default 1;
property ExportTableBorderRadius: Integer read FExportTableBorderRadius write SetExportTableBorderRadius default 0;
property ExportCellBorderColor: TColor read FExportCellBorderColor write SetExportCellBorderColor default clBlack;
property ExportCellBorderRadius: Integer read FExportCellBorderRadius write SetExportCellBorderRadius default 1;
property ExportCellPadding: Integer read FExportCellPadding write SetExportCellPadding default 0;
property ExportTableBorderStyle: TCellBorderStyle read FExportTableBorderStyle write SetExportTableBorderStyle default cbsSolid;//WJ
property SettingsButtonHint: string read FSettingsButtonHint write FSettingsButtonHint;
property TextBlokButtonHint: string read FTextBlockButtonHint write FTextBlockButtonHint;
Property MoveTableHint: String read  FMoveTableHint write  FMoveTableHint;
end;

procedure Register;

implementation

procedure Register;
begin
{$I tabledesignerhtml.lrs}
RegisterComponents('JanWilly', [THtmlTableDesigner]);

end;

constructor TDesignerTextLink.Create;
begin
inherited Create;

StartPos := -1;
Length := 0;
URL := '';
end;

function TDesignerTextBlock.AddLink(
AStartPos: Integer;
ALength: Integer;
const AURL: string
): TDesignerTextLink;
var
LURL: string;
begin
Result := nil;

LURL := Trim(AURL);

// StartPos gebruikt overal in de designer een 0-based positie.
if (AStartPos < 0) or
(AStartPos >= System.Length(Text)) or
(ALength <= 0) or
(LURL = '') then
Exit;

// Een bereik mag niet voorbij het einde van de tekst lopen.
if ALength > System.Length(Text) - AStartPos then
ALength := System.Length(Text) - AStartPos;

Result := TDesignerTextLink.Create;
Result.StartPos := AStartPos;
Result.Length := ALength;
Result.URL := LURL;

Links.Add(Result);
end;

constructor TDesignerStyleRun.Create;
begin
inherited Create;

StartPos := -1;
Length := 0;
Styles := [];
end;

function TDesignerTextBlock.EffectiveStyleAt(APos: Integer): TFontStyles;
var
I: Integer;
R: TDesignerStyleRun;
begin
// Standaard: de blok-brede opmaak. Een StyleRun die APos bevat
// overschrijft dit volledig voor dat bereik (StyleRuns zijn altijd
// niet-overlappend, zie ToggleStyleRun).
Result := FontStyles;

if not Assigned(StyleRuns) then
Exit;

for I := 0 to StyleRuns.Count - 1 do
begin
R := TDesignerStyleRun(StyleRuns[I]);

if Assigned(R) and
(APos >= R.StartPos) and
(APos < R.StartPos + R.Length) then
begin
Result := R.Styles;
Exit;
end;
end;
end;

procedure TDesignerTextBlock.ToggleStyleRun(
AStartPos: Integer;
ALength: Integer;
AStyle: TFontStyle
);
var
SelStart, SelEnd: Integer;
NewStyles: TFontStyles;
NewRuns: TObjectList;
I: Integer;
R, NR: TDesignerStyleRun;
RStart, REnd, PieceStart, PieceLen: Integer;
begin
if not Assigned(StyleRuns) then
Exit;

if (ALength <= 0) or
(AStartPos < 0) or
(AStartPos >= System.Length(Text)) then
Exit;

SelStart := AStartPos;
SelEnd := AStartPos + ALength; // exclusief

if SelEnd > System.Length(Text) then
SelEnd := System.Length(Text);

if SelEnd <= SelStart then
Exit;

// Referentie: de effectieve stijl bij het eerste teken van de
// selectie bepaalt of AStyle voor de hele selectie AAN- of
// UITgezet wordt (zelfde gedrag als de bestaande blok-brede
// Bold/Italic/Underline-knoppen, nu toegepast op de selectie).
NewStyles := EffectiveStyleAt(SelStart);

if AStyle in NewStyles then
Exclude(NewStyles, AStyle)
else
Include(NewStyles, AStyle);

// Nieuwe, niet-overlappende runlijst opbouwen: bestaande runs
// buiten [SelStart, SelEnd) blijven bestaan (desnoods afgeknot
// aan de rand), het geselecteerde bereik wordt precies één
// nieuwe run.
NewRuns := TObjectList.Create(True);
try
for I := 0 to StyleRuns.Count - 1 do
begin
R := TDesignerStyleRun(StyleRuns[I]);

if not Assigned(R) then
Continue;

RStart := R.StartPos;
REnd := R.StartPos + R.Length;

// Deel van de run vóór de selectie.
if RStart < SelStart then
begin
PieceStart := RStart;
PieceLen := Min(REnd, SelStart) - RStart;

if PieceLen > 0 then
begin
NR := TDesignerStyleRun.Create;
NR.StartPos := PieceStart;
NR.Length := PieceLen;
NR.Styles := R.Styles;
NewRuns.Add(NR);
end;
end;

// Deel van de run na de selectie.
if REnd > SelEnd then
begin
PieceStart := Max(RStart, SelEnd);
PieceLen := REnd - PieceStart;

if PieceLen > 0 then
begin
NR := TDesignerStyleRun.Create;
NR.StartPos := PieceStart;
NR.Length := PieceLen;
NR.Styles := R.Styles;
NewRuns.Add(NR);
end;
end;
end;

// De geselecteerde run zelf: alleen bewaren als de nieuwe stijl
// afwijkt van de blok-basisstijl (anders volstaat de standaard
// FontStyles en is er geen expliciete run nodig).
if NewStyles <> FontStyles then
begin
NR := TDesignerStyleRun.Create;
NR.StartPos := SelStart;
NR.Length := SelEnd - SelStart;
NR.Styles := NewStyles;
NewRuns.Add(NR);
end;

StyleRuns.Free;
StyleRuns := NewRuns;
except
NewRuns.Free;
raise;
end;
end;

constructor TDesignerColorRun.Create;
begin
inherited Create;

StartPos := -1;
Length := 0;
Color := clBlack;
end;

function TDesignerTextBlock.EffectiveColorAt(APos: Integer): TColor;
var
I: Integer;
R: TDesignerColorRun;
begin
// Standaard: de blok-brede FontColor. Een ColorRun die APos bevat
// overschrijft dit volledig voor dat bereik (ColorRuns zijn altijd
// niet-overlappend, zie SetColorRun).
Result := FontColor;

if not Assigned(ColorRuns) then
Exit;

for I := 0 to ColorRuns.Count - 1 do
begin
R := TDesignerColorRun(ColorRuns[I]);

if Assigned(R) and
(APos >= R.StartPos) and
(APos < R.StartPos + R.Length) then
begin
Result := R.Color;
Exit;
end;
end;
end;

procedure TDesignerTextBlock.SetColorRun(
AStartPos: Integer;
ALength: Integer;
AColor: TColor
);
var
SelStart, SelEnd: Integer;
NewRuns: TObjectList;
I: Integer;
R, NR: TDesignerColorRun;
RStart, REnd, PieceStart, PieceLen: Integer;
begin
if not Assigned(ColorRuns) then
Exit;

if (ALength <= 0) or
(AStartPos < 0) or
(AStartPos >= System.Length(Text)) then
Exit;

SelStart := AStartPos;
SelEnd := AStartPos + ALength; // exclusief

if SelEnd > System.Length(Text) then
SelEnd := System.Length(Text);

if SelEnd <= SelStart then
Exit;

// Nieuwe, niet-overlappende runlijst opbouwen: bestaande runs
// buiten [SelStart, SelEnd) blijven bestaan (desnoods afgeknot
// aan de rand), het geselecteerde bereik wordt precies één
// nieuwe run met AColor.
NewRuns := TObjectList.Create(True);
try
for I := 0 to ColorRuns.Count - 1 do
begin
R := TDesignerColorRun(ColorRuns[I]);

if not Assigned(R) then
Continue;

RStart := R.StartPos;
REnd := R.StartPos + R.Length;

// Deel van de run vóór de selectie.
if RStart < SelStart then
begin
PieceStart := RStart;
PieceLen := Min(REnd, SelStart) - RStart;

if PieceLen > 0 then
begin
NR := TDesignerColorRun.Create;
NR.StartPos := PieceStart;
NR.Length := PieceLen;
NR.Color := R.Color;
NewRuns.Add(NR);
end;
end;

// Deel van de run na de selectie.
if REnd > SelEnd then
begin
PieceStart := Max(RStart, SelEnd);
PieceLen := REnd - PieceStart;

if PieceLen > 0 then
begin
NR := TDesignerColorRun.Create;
NR.StartPos := PieceStart;
NR.Length := PieceLen;
NR.Color := R.Color;
NewRuns.Add(NR);
end;
end;
end;

// De geselecteerde run zelf: alleen bewaren als de nieuwe kleur
// afwijkt van de blok-basiskleur (anders volstaat de standaard
// FontColor en is er geen expliciete run nodig).
if AColor <> FontColor then
begin
NR := TDesignerColorRun.Create;
NR.StartPos := SelStart;
NR.Length := SelEnd - SelStart;
NR.Color := AColor;
NewRuns.Add(NR);
end;

ColorRuns.Free;
ColorRuns := NewRuns;
except
NewRuns.Free;
raise;
end;
end;

{ TTDesignerTextBlock }

constructor TDesignerTextBlock.Create;
begin
inherited Create;
Text := 'Nieuwe tekst';
Rect := Classes.Rect(80, 80, 360, 120);
FontSize := 10;
FontStyles := [];
FontColor := clRed;
LineHeight := 15;
Alignment := taCenter;
Selected := False;

BgColor := clWhite;
Transparent := True;
BorderColor := clGray;
BorderWidth := 1;
BorderStyle := cbsSolid;
BorderRadius := 0;
Padding := 4;
WordWrap:= True;
// HyperLink TextBlock
{
IsLink     = hyperlink actief?
LinkURL    = bestemming
LinkStart  = positie waar de linktekst begint
LinkLength = aantal tekens van de hyperlink
}
IsLink := False;
LinkURL := '';
LinkStart := -1;
LinkLength := 0;

Links := TObjectList.Create(True);
StyleRuns := TObjectList.Create(True);
ColorRuns := TObjectList.Create(True);
end;


destructor TDesignerTextBlock.Destroy;
begin
ColorRuns.Free;
StyleRuns.Free;
Links.Free;
inherited Destroy;
end;

{ THtmlCell }

constructor THtmlCell.Create;
begin
inherited Create;
FText := '';
FBgColor := clWhite;
FFontColor := clBlack;
FAlign := caLeft;
//--------Font instellingen
FBold := False;
FFontStyles := [];
FFontSize := 10;
// Voor image
FPicture := TPicture.Create;
FImageFile := '';
FShowImage := False;
FImageAlign := iaCenter;
FBorder:=True;
FImageStretch:=False;
FImageSizeMode := ismOriginal;
// Teksthyperlink
FIsLink := False;
FLinkURL := '';
FLinkText := '';
// Afbeeldingshyperlink
FImageIsLink := False;
FImageLinkURL := '';

// voor merge cellen
FColSpan := 1;
FRowSpan := 1;
FMerged := False;
FMasterCol := -1;
FMasterRow := -1;
FOriginalTextBeforeMerge := '';
FBackupText := '';
FBackupValid := False;
// voor borderstyle
FBorderStyle := cbsSolid;
// voor hint
FHintText := '';
end;

destructor THtmlCell.Destroy;
begin
FPicture.Free;
inherited Destroy;
end;

{ THtmlTableDesigner }

constructor THtmlTableDesigner.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
ControlStyle := ControlStyle + [csOpaque, csDoubleClicks, csClickEvents];
TabStop := True;

FGridLineWidth := 1;
Width := 520;
Height := 200;
Color := clWhite;


FRowCount := 5;
FColCount := 5;
FDefaultColWidth := 95;
FDefaultRowHeight := 26;
FSelectedCol := 0;
FSelectedRow := 0;
FHasSelection := False;
FGridColor := clSilver;
FSelectionColor := clRed;
FShowGrid := True;

FEditing := False;
FEditorCol := -1;
FEditorRow := -1;
//header
FShowHeaders := True;
FHeaderHeight := 22;
FHeaderWidth := 32;
FHeaderColor := clBtnFace;
FHeaderFontColor := clBlack;
FSelectionMode := smCell;
//resizing
FResizingCol := -1;
FResizingRow := -1;
FIsResizingCol := False;
FIsResizingRow := False;
AllocateCells;
SetLength(FColWidths, FColCount);
SetLength(FRowHeights, FRowCount);
InitColRowSizes;

// multiselect
FMultiSelecting := False;
FSelStartCol := 0;
FSelStartRow := 0;
FSelEndCol := 0;
FSelEndRow := 0;

//
FCopyCols := 0;
FCopyRows := 0;
// achtergrond kleur html
FHtmlBgColor := clWhite;

CreateInplaceEditor;
FAutoFitTable := False;
// voor pagina grote A4
{A4 portrait  = 794 x 1123 px
A4 landscape = 1123 x 794 px }
FPageEnabled := True;
FPageWidth := 794;
FPageHeight := 1123;
FPageMarginX := 20;
FPageMarginY := 20;
FTableOffsetX := 21;
FTableOffsetY := 21;
FWorkspaceOffsetX := 0;

FExportTableBgColor := clWhite;
FExportTableBorderColor := clBlack;
FExportTableBorderWidth := 1;
FExportTableBorderRadius := 10;

FExportTableBorderStyle := cbsSolid;

FExportCellBorderColor := clBlack;
FExportCellBorderRadius := 0;
FExportCellPadding := 0;
//Rulers
FShowPageRulers := True;
FRulerSize := 20;
FRulerStep := 50;
FPixelsPerMM := Screen.PixelsPerInch / 25.4;
UpdateDesignerSize;

// textBlock
FTextBlocks := TObjectList.Create(True);
FSelectedTextBlock := nil;
FDraggingTextBlock := False;

// ButtonHint
ShowHint := True;
FSettingsButtonHint := 'Tabel instellingen';
FTextBlockButtonHint := 'Text blok instellinen';
///nodig voor inline memo
FPendingEditCol := -1;
FPendingEditRow := -1;
// zacht Grid
FShowLayoutGrid := False;
FLayoutGridSize := 10;
FLayoutGridColor := clSilver;
end;

destructor THtmlTableDesigner.Destroy;
begin
// DelayedStartCellEdit / DelayedStartTextBlockEdit worden via
// Application.QueueAsyncCall ingepland (bv. na een dubbelklik).
// Wordt dit component ondertussen vrijgegeven vóórdat die
// ingeplande aanroep is afgevuurd, dan draait de callback op een
// reeds vrijgegeven object. Dit moet daarom de allereerste regel
// van de destructor zijn, vóór er iets anders wordt opgeruimd.
Application.RemoveAsyncCalls(Self);

FreeAndNil(FTextBlocks);
FreeAndNil(FInplaceEdit);
FreeCells;
inherited Destroy;
end;

function THtmlTableDesigner.TextBlockIsEditing: Boolean;
begin
Result := FEditingTextBlock;
end;


function THtmlTableDesigner.GetSettingsButtonRect: TRect;
var
X0, Y0: Integer;
begin
GetPageOffset(
X0,
Y0
);

Result := Rect(
X0 + 2,
Y0 + 2,
X0 + FHeaderWidth - 2,
Y0 + FHeaderHeight - 2
);
end;


// voor textBloks
procedure THtmlTableDesigner.AddTextBlock;
var
B: TDesignerTextBlock;
X, Y: Integer;
begin
B := TDesignerTextBlock.Create;

if FHasDesignerClickPos then
begin
X := FLastDesignerClickX;
Y := FLastDesignerClickY;
end
else
begin
X := 80;
Y := 80;
end;

B.Rect := Rect(
X,
Y,
X + 189,  // maat van memoText in settings frame
Y + 88    //  maat van memoText in settings frame
);

FTextBlocks.Add(B);

ClearTextBlockSelection;
B.Selected := True;
FSelectedTextBlock := B;

// Nieuw TextBlock geselecteerd: eventueel rood celkader verbergen
FHasSelection := False;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.ClearTextBlockSelection;
var
I: Integer;
begin
for I := 0 to FTextBlocks.Count - 1 do
TDesignerTextBlock(FTextBlocks[I]).Selected := False;
FSelectedTextBlock := nil;
end;

procedure THtmlTableDesigner.StartTextBlockEdit(
ABlock: TDesignerTextBlock);
begin
if not Assigned(ABlock) then
Exit;

if not Assigned(FInplaceEdit) then
Exit;

FEditingTextBlock := True;
FSelectedTextBlock := ABlock;

// Vorige selectie wissen
FTextBlockSelStart := -1;
FTextBlockSelLength := 0;

FInplaceEdit.BoundsRect := ABlock.Rect;
FInplaceEdit.Text := ABlock.Text;
FInplaceEdit.Font.Assign(Font);
FInplaceEdit.Font.Size := ABlock.FontSize;
FInplaceEdit.WordWrap := True;

FInplaceEdit.Visible := True;
FInplaceEdit.BringToFront;
FInplaceEdit.SelectAll;
FInplaceEdit.SetFocus;
end;

function THtmlTableDesigner.GetTextBlockSelection(
out AStart, ALength: Integer): Boolean;
var
CharStart: Integer;
CharLength: Integer;
ByteEnd: Integer;
EditText: string;
begin
AStart := -1;
ALength := 0;
Result := False;

if not Assigned(FSelectedTextBlock) then
Exit;

// ----------------------------------------------------------
// Editor is nog actief
// ----------------------------------------------------------

if FEditingTextBlock and
Assigned(FInplaceEdit) and
FInplaceEdit.Visible then
begin
CharStart :=
FInplaceEdit.SelStart;

CharLength :=
FInplaceEdit.SelLength;

EditText := FInplaceEdit.Text;
end

// ----------------------------------------------------------
// Editor verloor reeds focus.
// Gebruik de zojuist opgeslagen selectie.
// ----------------------------------------------------------

else
begin
CharStart :=
FTextBlockSelStart;

CharLength :=
FTextBlockSelLength;

EditText := FSelectedTextBlock.Text;
end;

if (CharStart < 0) or
(CharLength <= 0) then
Exit;

// TMemo.SelStart/SelLength tellen zichtbare UTF-8-tekens.
// TDesignerTextLink en DrawTextBlock gebruiken byteposities in string.
// Zet daarom zowel het begin als het einde van de selectie om.
AStart :=
System.Length(
UTF8Copy(EditText, 1, CharStart)
);

ByteEnd :=
System.Length(
UTF8Copy(EditText, 1, CharStart + CharLength)
);

ALength := ByteEnd - AStart;

Result :=
(AStart >= 0) and
(ALength > 0);
end;



function THtmlTableDesigner.TextBlockSettingsButtonRect(
ABlock: TDesignerTextBlock): TRect;
begin
Result := Rect(
ABlock.Rect.Left + 2,
ABlock.Rect.Top + 2,
ABlock.Rect.Left + 22,
ABlock.Rect.Top + 22
);
end;

procedure THtmlTableDesigner.DrawTextBlockSettingsButton(
ABlock: TDesignerTextBlock);
var
R: TRect;
X, Y: Integer;
begin
if not Assigned(ABlock) then Exit;
if not ABlock.Selected then Exit;

R := TextBlockSettingsButtonRect(ABlock);

Canvas.Pen.Style := psSolid;
Canvas.Pen.Width := 1;
Canvas.Pen.Color := clGray;

Canvas.Brush.Style := bsSolid;

if PtInRect(R, Point(FMouseX, FMouseY)) then
Canvas.Brush.Color := clYellow
else
Canvas.Brush.Color := clBtnFace;

Canvas.Rectangle(R);

if Assigned(FImages) and
(FSettingsImageIndex >= 0) and
(FSettingsImageIndex < FImages.Count) then
begin
X := R.Left + ((R.Right - R.Left) - FImages.Width) div 2;
Y := R.Top + ((R.Bottom - R.Top) - FImages.Height) div 2;

FImages.Draw(Canvas, X, Y, FSettingsImageIndex, True);
end
else
begin
Canvas.Brush.Style := bsClear;
Canvas.Font.Assign(Font);
Canvas.Font.Style := [fsBold];
Canvas.Font.Size := 9;
Canvas.Font.Color := clBlack;

DrawText(
Canvas.Handle,
PChar('⚙'),
Length('⚙'),
R,
DT_CENTER or DT_VCENTER or DT_SINGLELINE
);
end;

Canvas.Brush.Style := bsSolid;
Canvas.Pen.Style := psSolid;
Canvas.Pen.Width := 1;
end;



function THtmlTableDesigner.TextBlockFromPoint(X, Y: Integer): TDesignerTextBlock;
var
I: Integer;
B: TDesignerTextBlock;
begin
Result := nil;

for I := FTextBlocks.Count - 1 downto 0 do
begin
B := TDesignerTextBlock(FTextBlocks[I]);
if PtInRect(B.Rect, Point(X, Y)) then
Exit(B);
end;
end;

function THtmlTableDesigner.TextBlockResizeHandleRect(
ABlock: TDesignerTextBlock): TRect;
begin
Result := Rect(
ABlock.Rect.Right - 6,
ABlock.Rect.Bottom - 6,
ABlock.Rect.Right + 2,
ABlock.Rect.Bottom + 2
);
end;

function THtmlTableDesigner.TextBlockOnResizeHandle(
ABlock: TDesignerTextBlock; X, Y: Integer): Boolean;
begin
Result :=
Assigned(ABlock) and
PtInRect(TextBlockResizeHandleRect(ABlock), Point(X, Y));
end;

function THtmlTableDesigner.GetCellImageRect(
ACol, ARow: Integer;
const ACellRect: TRect
): TRect;
var
Cell: THtmlCell;
AvailableRect: TRect;
ImageW, ImageH: Integer;
AvailableW, AvailableH: Integer;
Scale: Double;
begin
Result := Rect(0, 0, 0, 0);

if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

Cell := FCells[ACol, ARow];

if not Assigned(Cell) then
Exit;

if not Cell.ShowImage then
Exit;

if not Assigned(Cell.Picture) then
Exit;

if (Cell.Picture.Width <= 0) or
(Cell.Picture.Height <= 0) then
Exit;

AvailableRect := ACellRect;

InflateRect(
AvailableRect,
-FExportCellPadding,
-FExportCellPadding
);

AvailableW :=
AvailableRect.Right -
AvailableRect.Left;

AvailableH :=
AvailableRect.Bottom -
AvailableRect.Top;

if (AvailableW <= 0) or
(AvailableH <= 0) then
Exit;

case Cell.ImageSizeMode of
ismOriginal:
begin
ImageW := Cell.Picture.Width;
ImageH := Cell.Picture.Height;
end;

ismFit:
begin
Scale := Min(
AvailableW / Cell.Picture.Width,
AvailableH / Cell.Picture.Height
);

ImageW := Round(Cell.Picture.Width * Scale);
ImageH := Round(Cell.Picture.Height * Scale);
end;

ismStretch:
begin
ImageW := AvailableW;
ImageH := AvailableH;
end;
else
begin
ImageW := Cell.Picture.Width;
ImageH := Cell.Picture.Height;
end;
end;

// De originele afbeelding mag niet buiten de cel komen
if ImageW > AvailableW then
ImageW := AvailableW;

if ImageH > AvailableH then
ImageH := AvailableH;

case Cell.ImageAlign of
iaLeft:
Result.Left := AvailableRect.Left;

iaCenter:
Result.Left :=
AvailableRect.Left +
(AvailableW - ImageW) div 2;

iaRight:
Result.Left :=
AvailableRect.Right -
ImageW;
else
Result.Left := AvailableRect.Left;
end;

Result.Top :=
AvailableRect.Top +
(AvailableH - ImageH) div 2;

Result.Right := Result.Left + ImageW;
Result.Bottom := Result.Top + ImageH;
end;


procedure THtmlTableDesigner.SetPageWidth(
AValue: Integer);
begin
if AValue < 1 then
AValue := 1;

if FPageWidth = AValue then
Exit;

FPageWidth := AValue;

UpdateDesignerSize;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.SetPageHeight(
AValue: Integer);
begin
if AValue < 1 then
AValue := 1;

if FPageHeight = AValue then
Exit;

FPageHeight := AValue;

UpdateDesignerSize;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetPageEnabled(AValue: Boolean);
begin
if FPageEnabled = AValue then Exit;

FPageEnabled := AValue;

// UpdateDesignerSize doet enkel iets wanneer FPageEnabled True is,
// maar moet ook aangeroepen worden wanneer de pagina net is
// uitgeschakeld (om de eerder ingestelde Width/Height niet onnodig
// te laten staan) - Invalidate zorgt sowieso voor een herteken.
UpdateDesignerSize;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetTableOffsetX(AValue: Integer);
begin
if FTableOffsetX = AValue then Exit;

FTableOffsetX := AValue;

// Verschuift de positie van de tabel op de pagina; heeft geen
// invloed op de buitenafmeting van het component (die hangt enkel
// af van PageWidth/PageHeight), dus geen UpdateDesignerSize nodig.
if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetTableOffsetY(AValue: Integer);
begin
if FTableOffsetY = AValue then Exit;

FTableOffsetY := AValue;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetShowPageRulers(AValue: Boolean);
begin
if FShowPageRulers = AValue then Exit;

FShowPageRulers := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.DelayedStartCellEdit(Data: PtrInt);
begin
if (FPendingEditCol >= 0) and (FPendingEditRow >= 0) then
StartEdit(FPendingEditCol, FPendingEditRow);
end;

procedure THtmlTableDesigner.DelayedStartTextBlockEdit(Data: PtrInt);
begin
if Assigned(FSelectedTextBlock) then
StartTextBlockEdit(FSelectedTextBlock);
end;


procedure THtmlTableDesigner.DrawTextBlocks;
var
I: Integer;
begin
for I := 0 to FTextBlocks.Count - 1 do
DrawTextBlock(TDesignerTextBlock(FTextBlocks[I]));
end;

procedure THtmlTableDesigner.DrawTextBlock(
ABlock: TDesignerTextBlock);
type
TTextLine = record
StartPos: Integer; // 0-based positie in ABlock.Text
Len: Integer;
end;

TTextLineArray = array of TTextLine;

var
R, TextR: TRect;
TextLines: TTextLineArray;

I: Integer;
Y: Integer;
LineHeight: Integer;

// ------------------------------------------------------------
// Geeft de hyperlink terug waartoe karakterpositie APos behoort.
// APos en TDesignerTextLink.StartPos zijn beide 0-based.
// ------------------------------------------------------------

function LinkAtPos(APos: Integer): TDesignerTextLink;
var
LinkIndex: Integer;
LLink: TDesignerTextLink;
begin
Result := nil;

if (APos < 0) or
not Assigned(ABlock.Links) then
Exit;

for LinkIndex := 0 to ABlock.Links.Count - 1 do
begin
LLink :=
TDesignerTextLink(ABlock.Links[LinkIndex]);

if Assigned(LLink) and
(Trim(LLink.URL) <> '') and
(LLink.StartPos >= 0) and
(LLink.Length > 0) and
(APos >= LLink.StartPos) and
(APos < LLink.StartPos + LLink.Length) then
begin
Result := LLink;
Exit;
end;
end;
end;


// ------------------------------------------------------------
// Regel toevoegen
// ------------------------------------------------------------

procedure AddTextLine(
AStartPos: Integer;
ALen: Integer);
var
N: Integer;
begin
N := Length(TextLines);

SetLength(
TextLines,
N + 1
);

TextLines[N].StartPos := AStartPos;
TextLines[N].Len := ALen;
end;

// ------------------------------------------------------------
// Tekst opdelen in regels
//
// Bij WordWrap = True:
//   automatisch afbreken op spaties.
//
// Bij WordWrap = False:
//   alleen expliciete regeleinden respecteren.
// ------------------------------------------------------------

procedure BuildTextLines;
var
P: Integer;
LineStart: Integer;
LastSpace: Integer;
TestLen: Integer;
TestText: string;
NewStart: Integer;
TextLen: Integer;
MaxWidth: Integer;
begin
SetLength(TextLines, 0);

TextLen := Length(ABlock.Text);
MaxWidth := TextR.Right - TextR.Left;

if MaxWidth <= 0 then
Exit;

if TextLen = 0 then
begin
AddTextLine(0, 0);
Exit;
end;

P := 0;
LineStart := 0;
LastSpace := -1;

while P < TextLen do
begin
// --------------------------------------------------------
// CR/LF behandelen
// --------------------------------------------------------

if ABlock.Text[P + 1] = #13 then
begin
AddTextLine(
LineStart,
P - LineStart
);

Inc(P);

// CRLF
if (P < TextLen) and
(ABlock.Text[P + 1] = #10) then
Inc(P);

LineStart := P;
LastSpace := -1;

Continue;
end;

if ABlock.Text[P + 1] = #10 then
begin
AddTextLine(
LineStart,
P - LineStart
);

Inc(P);

LineStart := P;
LastSpace := -1;

Continue;
end;

// --------------------------------------------------------
// Laatste mogelijke woordafbreking onthouden
// --------------------------------------------------------

if ABlock.Text[P + 1] = ' ' then
LastSpace := P;

// --------------------------------------------------------
// Alleen automatisch afbreken indien WordWrap actief is
// --------------------------------------------------------

if ABlock.WordWrap then
begin
TestLen :=
P - LineStart + 1;

TestText :=
Copy(
ABlock.Text,
LineStart + 1,
TestLen
);

if Canvas.TextWidth(TestText) > MaxWidth then
begin
// ----------------------------------------------------
// Liefst op laatste spatie afbreken
// ----------------------------------------------------

if LastSpace >= LineStart then
begin
AddTextLine(
LineStart,
LastSpace - LineStart
);

NewStart :=
LastSpace + 1;

// Eventuele bijkomende spaties aan begin
// van volgende regel overslaan
while (NewStart < TextLen) and
(ABlock.Text[NewStart + 1] = ' ') do
Inc(NewStart);

LineStart := NewStart;
P := NewStart;
LastSpace := -1;

Continue;
end

// ----------------------------------------------------
// Geen spatie gevonden:
// lang woord op karakterpositie afbreken
// ----------------------------------------------------

else if P > LineStart then
begin
AddTextLine(
LineStart,
P - LineStart
);

LineStart := P;
LastSpace := -1;

Continue;
end;
end;
end;

Inc(P);
end;

// Laatste regel
if LineStart <= TextLen then
begin
AddTextLine(
LineStart,
TextLen - LineStart
);
end;
end;

// ------------------------------------------------------------
// Eén tekstregel tekenen.
//
// Normale tekst gebruikt de TextBlock-opmaak.
// Alleen hyperlinkkarakters worden blauw + onderlijnd.
// ------------------------------------------------------------

procedure DrawStyledLine(
const ALine: TTextLine;
AY: Integer);
var
J: Integer;
Pos0: Integer;
X: Integer;

LineText: string;
Ch: string;

LineWidth: Integer;
CharWidth: Integer;

LinkChar: Boolean;
PreviousLinkChar: Boolean;

CurStyles, PreviousStyles: TFontStyles;
CurColor, PreviousColor: TColor;

PartStart: Integer;
PartLen: Integer;
PartText: string;

// AStyles is de effectieve (bold/italic/underline) stijl voor dit
// deel: ofwel ABlock.FontStyles, ofwel een StyleRun die dat
// overschrijft voor een geselecteerd woord/tekstdeel.
procedure SetFont(AStyles: TFontStyles; AColor: TColor);
begin
Canvas.Font.Assign(Font);
Canvas.Font.Size := ABlock.FontSize;
Canvas.Font.Style := AStyles;
Canvas.Font.Color := AColor;
end;

procedure SetNormalFont;
begin
SetFont(ABlock.FontStyles, ABlock.FontColor);
end;

procedure DrawPart(
AStart: Integer;
ALength: Integer;
AIsLink: Boolean;
AStyles: TFontStyles;
AColor: TColor);
begin
if ALength <= 0 then
Exit;

PartText :=
Copy(
ABlock.Text,
AStart + 1,
ALength
);

// Een hyperlink forceert altijd blauw + onderlijnd (zoals
// voorheen), maar respecteert daarbovenop een eventuele
// per-woord bold/italic van AStyles. Een per-woord tekstkleur
// (AColor) geldt enkel voor niet-gelinkte tekst.
if AIsLink then
SetFont(AStyles + [fsUnderline], clBlue)
else
SetFont(AStyles, AColor);

Canvas.TextOut(
X,
AY,
PartText
);

Inc(
X,
Canvas.TextWidth(PartText)
);
end;

begin
if ALine.Len < 0 then
Exit;

// ----------------------------------------------------------
// Breedte van volledige regel bepalen
// ----------------------------------------------------------

SetNormalFont;

LineText :=
Copy(
ABlock.Text,
ALine.StartPos + 1,
ALine.Len
);

LineWidth :=
Canvas.TextWidth(LineText);

// ----------------------------------------------------------
// Horizontale uitlijning
// ----------------------------------------------------------

case ABlock.Alignment of

taLeftJustify:
X := TextR.Left;

taCenter:
X :=
TextR.Left +
((TextR.Right - TextR.Left - LineWidth) div 2);

taRightJustify:
X :=
TextR.Right -
LineWidth;

else
X := TextR.Left;
end;

// Lege regel
if ALine.Len = 0 then
Exit;

// ----------------------------------------------------------
// Regel opdelen in normale en hyperlink-delen
// ----------------------------------------------------------

PartStart := ALine.StartPos;

PreviousLinkChar :=
Assigned(LinkAtPos(PartStart));

PreviousStyles :=
ABlock.EffectiveStyleAt(PartStart);

PreviousColor :=
ABlock.EffectiveColorAt(PartStart);

J := 0;

while J < ALine.Len do
begin
Pos0 :=
ALine.StartPos + J;

LinkChar :=
Assigned(LinkAtPos(Pos0));

CurStyles :=
ABlock.EffectiveStyleAt(Pos0);

CurColor :=
ABlock.EffectiveColorAt(Pos0);

// Opmaak verandert (link aan/uit, bold/italic/underline van
// een StyleRun, of kleur van een ColorRun): vorig gedeelte
// tekenen.
if (LinkChar <> PreviousLinkChar) or
(CurStyles <> PreviousStyles) or
(CurColor <> PreviousColor) then
begin
PartLen :=
Pos0 - PartStart;

DrawPart(
PartStart,
PartLen,
PreviousLinkChar,
PreviousStyles,
PreviousColor
);

PartStart := Pos0;
PreviousLinkChar := LinkChar;
PreviousStyles := CurStyles;
PreviousColor := CurColor;
end;

Inc(J);
end;

// Laatste gedeelte tekenen
PartLen :=
(ALine.StartPos + ALine.Len) -
PartStart;

DrawPart(
PartStart,
PartLen,
PreviousLinkChar,
PreviousStyles,
PreviousColor
);
end;

begin
if not Assigned(ABlock) then
Exit;

R := ABlock.Rect;
TextR := R;

if ABlock.Padding > 0 then
InflateRect(
TextR,
-ABlock.Padding,
-ABlock.Padding
);

// ------------------------------------------------------------
// Achtergrond
// ------------------------------------------------------------

if not ABlock.Transparent then
begin
Canvas.Brush.Style := bsSolid;
Canvas.Brush.Color := ABlock.BgColor;
Canvas.FillRect(R);
end;

// ------------------------------------------------------------
// Kader van het tekstblok
// ------------------------------------------------------------

if (ABlock.BorderStyle <> cbsNone) and
(ABlock.BorderWidth > 0) then
begin
Canvas.Brush.Style := bsClear;
Canvas.Pen.Color := ABlock.BorderColor;

case ABlock.BorderStyle of

cbsSolid:
begin
Canvas.Pen.Style := psSolid;
Canvas.Pen.Width := ABlock.BorderWidth;
end;

cbsDashed:
begin
Canvas.Pen.Style := psDash;
Canvas.Pen.Width := 1;
end;

cbsDotted:
begin
Canvas.Pen.Style := psDot;
Canvas.Pen.Width := 1;
end;

cbsDouble:
begin
Canvas.Pen.Style := psSolid;

Canvas.Pen.Width :=
Max(
1,
ABlock.BorderWidth
);
end;

else
begin
Canvas.Pen.Style := psSolid;
Canvas.Pen.Width := 1;
end;
end;

// Buitenste kader
if ABlock.BorderRadius > 0 then
begin
Canvas.RoundRect(
R.Left,
R.Top,
R.Right,
R.Bottom,
ABlock.BorderRadius,
ABlock.BorderRadius
);
end
else
Canvas.Rectangle(R);

// Tweede binnenste lijn voor dubbel kader
if ABlock.BorderStyle = cbsDouble then
begin
InflateRect(
R,
-3,
-3
);

if ABlock.BorderRadius > 0 then
begin
Canvas.RoundRect(
R.Left,
R.Top,
R.Right,
R.Bottom,
Max(
0,
ABlock.BorderRadius - 3
),
Max(
0,
ABlock.BorderRadius - 3
)
);
end
else
Canvas.Rectangle(R);

R := ABlock.Rect;
end;

Canvas.Pen.Width := 1;
Canvas.Pen.Style := psSolid;
end;

// ------------------------------------------------------------
// Basis font
// ------------------------------------------------------------

Canvas.Brush.Style := bsClear;

Canvas.Font.Assign(Font);
Canvas.Font.Style := ABlock.FontStyles;
Canvas.Font.Size := ABlock.FontSize;
Canvas.Font.Color := ABlock.FontColor;

// ------------------------------------------------------------
// Regelhoogte
// ------------------------------------------------------------

LineHeight := ABlock.LineHeight;

if LineHeight <= 0 then
LineHeight :=
Canvas.TextHeight('Ag');

// Zorg dat letters niet over elkaar worden getekend
if LineHeight < Canvas.TextHeight('Ag') then
LineHeight :=
Canvas.TextHeight('Ag');

// ------------------------------------------------------------
// Tekstregels bepalen
// ------------------------------------------------------------

BuildTextLines;

// ------------------------------------------------------------
// Tekst tekenen
// ------------------------------------------------------------

Y := TextR.Top;

for I := 0 to High(TextLines) do
begin
if Y >= TextR.Bottom then
Break;

DrawStyledLine(
TextLines[I],
Y
);

Inc(
Y,
LineHeight
);
end;

// ------------------------------------------------------------
// Canvas font herstellen
// ------------------------------------------------------------

Canvas.Font.Assign(Font);
Canvas.Font.Style := ABlock.FontStyles;
Canvas.Font.Size := ABlock.FontSize;
Canvas.Font.Color := ABlock.FontColor;

// ------------------------------------------------------------
// Selectiekader + handles + settingsknop
// ------------------------------------------------------------

if ABlock.Selected then
begin
R := ABlock.Rect;

Canvas.Pen.Style := psDash;
Canvas.Pen.Color := clBlue;
Canvas.Pen.Width := 1;
Canvas.Brush.Style := bsClear;

Canvas.Rectangle(R);

Canvas.Pen.Style := psSolid;
Canvas.Brush.Style := bsSolid;
Canvas.Brush.Color := clWhite;
Canvas.Pen.Color := clBlue;

Canvas.Rectangle(
TextBlockResizeHandleRect(ABlock)
);

DrawTextBlockSettingsButton(
ABlock
);
end;
end;


// einde voor textBloks


procedure THtmlTableDesigner.GetSelectionBounds(out L, T, R, B: Integer);
begin
if HasMultiSelection then
NormalizeSelection(L, T, R, B)
else
begin
L := FSelectedCol;
T := FSelectedRow;
R := FSelectedCol;
B := FSelectedRow;
end;
end;
{
procedure THtmlTableDesigner.UpdateDesignerSize;
begin
if FPageEnabled then
begin
Width  := FPageMarginX + FPageWidth  + FPageMarginX;
Height := FPageMarginY + FPageHeight + FPageMarginY;
end;
end;
}
procedure THtmlTableDesigner.UpdateDesignerSize;
begin
if FPageEnabled then
begin
Width :=
FWorkspaceOffsetX +
FPageMarginX +
FPageWidth +
FPageMarginX;

Height :=
FPageMarginY +
FPageHeight +
FPageMarginY;
end;
end;

procedure THtmlTableDesigner.ToggleStyleSelection(AStyle: TFontStyle);
var
L, T, R, B, C, Row: Integer;
Styles: TFontStyles;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
Styles := FCells[C, Row].FontStyles;

if AStyle in Styles then
Exclude(Styles, AStyle)
else
Include(Styles, AStyle);

FCells[C, Row].FontStyles := Styles;


end;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ChangeFontSizeSelection(Delta: Integer);
var
L, T, R, B: Integer;
C, Row: Integer;
N: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
N := FCells[C, Row].FontSize + Delta;

if N < 6 then
N := 6;

if N > 72 then
N := 72;

FCells[C, Row].FontSize := N;
end;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.CellToData(ACell: THtmlCell; out AData: THtmlCellData);
begin
if not Assigned(ACell) then Exit;

AData.Text := ACell.Text;

AData.BgColor := ACell.BgColor;
AData.FontColor := ACell.FontColor;
AData.FontSize := ACell.FontSize;
AData.FontStyles := ACell.FontStyles;
AData.Bold := ACell.Bold;
AData.Align := ACell.Align;

AData.ImageFile := ACell.ImageFile;
AData.ShowImage := ACell.ShowImage;
AData.ImageStretch := ACell.ImageStretch;
AData.ImageSizeMode := ACell.ImageSizeMode;
AData.ImageAlign := ACell.ImageAlign;

AData.Border := ACell.Border;
AData.BorderStyle := ACell.BorderStyle;

AData.IsLink := ACell.IsLink;
AData.LinkURL := ACell.LinkURL;
AData.LinkText := ACell.LinkText;

AData.ImageIsLink := ACell.ImageIsLink;
AData.ImageLinkURL := ACell.ImageLinkURL;

AData.ColSpan := ACell.ColSpan;
AData.RowSpan := ACell.RowSpan;
AData.Merged := ACell.Merged;
end;


procedure THtmlTableDesigner.DataToCell(
const AData: THtmlCellData;
ACell: THtmlCell);
begin
if not Assigned(ACell) then Exit;

ACell.Text := AData.Text;

ACell.BgColor := AData.BgColor;
ACell.FontColor := AData.FontColor;
ACell.FontSize := AData.FontSize;
ACell.FontStyles := AData.FontStyles;
ACell.Bold := AData.Bold;
ACell.Align := AData.Align;

ACell.ImageFile := AData.ImageFile;
ACell.ShowImage := AData.ShowImage;
ACell.ImageStretch := AData.ImageStretch;
ACell.ImageSizeMode := AData.ImageSizeMode;
ACell.ImageAlign := AData.ImageAlign;

ACell.Border := AData.Border;
ACell.BorderStyle := AData.BorderStyle;

ACell.IsLink := AData.IsLink;
ACell.LinkURL := AData.LinkURL;
ACell.LinkText := AData.LinkText;

ACell.ImageIsLink := AData.ImageIsLink;
ACell.ImageLinkURL := AData.ImageLinkURL;

ACell.ColSpan := AData.ColSpan;
ACell.RowSpan := AData.RowSpan;
ACell.Merged := AData.Merged;

// Afbeelding opnieuw laden
ACell.Picture.Clear;

if ACell.ShowImage and
(ACell.ImageFile <> '') and
FileExists(ACell.ImageFile) then
begin
try
ACell.Picture.LoadFromFile(ACell.ImageFile);
except
// eventueel loggen
end;
end;
end;

function THtmlTableDesigner.HasCopyBuffer: Boolean;
begin
Result := (FCopyCols > 0) and (FCopyRows > 0);
end;


procedure THtmlTableDesigner.CopySelection;
var
L, T, R, B: Integer;
C, Y: Integer;
begin
if FSelectionMode <> smCell then Exit;

GetSelectionBounds(L, T, R, B);

FCopyCols := R - L + 1;
FCopyRows := B - T + 1;

SetLength(FCopyBuffer, FCopyCols, FCopyRows);
SetLength(FCopyColWidths, FCopyCols);
SetLength(FCopyRowHeights, FCopyRows);

for C := 0 to FCopyCols - 1 do
FCopyColWidths[C] := FColWidths[L + C];

for Y := 0 to FCopyRows - 1 do
FCopyRowHeights[Y] := FRowHeights[T + Y];

for C := 0 to FCopyCols - 1 do
for Y := 0 to FCopyRows - 1 do
CellToData(FCells[L + C, T + Y], FCopyBuffer[C, Y]);
end;



procedure THtmlTableDesigner.PasteSelection;
var
StartCol, StartRow: Integer;
C, Y: Integer;
DestCol, DestRow: Integer;
begin
if not HasCopyBuffer then Exit;
if FSelectionMode <> smCell then Exit;

StartCol := FSelectedCol;
StartRow := FSelectedRow;

// breedtes mee plakken
for C := 0 to FCopyCols - 1 do
if (StartCol + C >= 0) and (StartCol + C < FColCount) then
FColWidths[StartCol + C] := FCopyColWidths[C];

// hoogtes mee plakken
for Y := 0 to FCopyRows - 1 do
if (StartRow + Y >= 0) and (StartRow + Y < FRowCount) then
FRowHeights[StartRow + Y] := FCopyRowHeights[Y];

// cellen plakken
for C := 0 to FCopyCols - 1 do
for Y := 0 to FCopyRows - 1 do
begin
DestCol := StartCol + C;
DestRow := StartRow + Y;

if (DestCol >= 0) and (DestCol < FColCount) and
(DestRow >= 0) and (DestRow < FRowCount) then
DataToCell(FCopyBuffer[C, Y], FCells[DestCol, DestRow]);
end;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetLinkToSelection(const AURL, AText: string);
var
L, T, R, B, C, Row: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
FCells[C, Row].IsLink := True;
FCells[C, Row].LinkURL := AURL;
FCells[C, Row].LinkText := AText;

if AText <> '' then
FCells[C, Row].Text := AText;
end;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ClearLinkFromSelection;
var
L, T, R, B, C, Row: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
FCells[C, Row].IsLink := False;
FCells[C, Row].LinkURL := '';
FCells[C, Row].LinkText := '';
end;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.SetImageLinkToSelection(
const AURL: string
);
var
L, T, R, B: Integer;
C, Row: Integer;
begin
if FSelectionMode <> smCell then
Exit;

if Trim(AURL) = '' then
Exit;

GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
if not Assigned(FCells[C, Row]) then
Continue;

// Alleen toepassen wanneer er werkelijk een afbeelding is
if FCells[C, Row].ShowImage then
begin
FCells[C, Row].ImageIsLink := True;
FCells[C, Row].ImageLinkURL := Trim(AURL);
end;
end;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ClearImageLinkFromSelection;
var
L, T, R, B: Integer;
C, Row: Integer;
begin
if FSelectionMode <> smCell then
Exit;

GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
if not Assigned(FCells[C, Row]) then
Continue;

FCells[C, Row].ImageIsLink := False;
FCells[C, Row].ImageLinkURL := '';
end;

Invalidate;
DoChange;
end;

function THtmlTableDesigner.IsCellCovered(ACol, ARow: Integer): Boolean;
begin
Result := Cells[ACol, ARow].Merged;
end;

function THtmlTableDesigner.SelectionContainsMergedCell: Boolean;
var
L, T, R, B: Integer;
C, Row: Integer;
begin
Result := False;

if FSelectionMode <> smCell then
Exit;

GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
if FCells[C, Row].Merged or
(FCells[C, Row].ColSpan > 1) or
(FCells[C, Row].RowSpan > 1) then
Exit(True);
end;

function THtmlTableDesigner.CanMergeSelection: Boolean;
var
L, T, R, B: Integer;
begin
Result := False;

if FSelectionMode <> smCell then
Exit;

GetSelectionBounds(L, T, R, B);

// minstens 2 cellen geselecteerd
Result := (L <> R) or (T <> B);

// niet opnieuw mergen als er al merge in zit
if SelectionContainsMergedCell then
Result := False;
end;

function THtmlTableDesigner.RowTouchesMergedCell(ARow: Integer): Boolean;
var
C: Integer;
begin
Result := False;

if (ARow < 0) or (ARow >= FRowCount) then
Exit;

for C := 0 to FColCount - 1 do
if FCells[C, ARow].Merged or
(FCells[C, ARow].ColSpan > 1) or
(FCells[C, ARow].RowSpan > 1) then
Exit(True);
end;

function THtmlTableDesigner.ColTouchesMergedCell(ACol: Integer): Boolean;
var
R: Integer;
begin
Result := False;

if (ACol < 0) or (ACol >= FColCount) then
Exit;

for R := 0 to FRowCount - 1 do
if FCells[ACol, R].Merged or
(FCells[ACol, R].ColSpan > 1) or
(FCells[ACol, R].RowSpan > 1) then
Exit(True);
end;

function THtmlTableDesigner.SmartImagePath(const AFileName: string): string;
var
BaseDir: string;
FullName: string;
begin
BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
FullName := ExpandFileName(AFileName);

if Pos(UpperCase(BaseDir), UpperCase(FullName)) = 1 then
Result := ExtractRelativePath(BaseDir, FullName)
else
Result := FullName;

Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

function THtmlTableDesigner.CopyImageToProjectImages(const ASourceFile: string): string;
var
BaseDir, ImagesDir: string;
FileNameOnly, DestFile, Ext, NameOnly: string;
N: Integer;
begin
Result := '';

if not FileExists(ASourceFile) then
Exit;

BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
ImagesDir := IncludeTrailingPathDelimiter(BaseDir + 'images');

ForceDirectories(ImagesDir);

FileNameOnly := ExtractFileName(ASourceFile);
DestFile := ImagesDir + FileNameOnly;

// Als bestand al bestaat, unieke naam maken
if FileExists(DestFile) then
begin
Ext := ExtractFileExt(FileNameOnly);
NameOnly := ChangeFileExt(FileNameOnly, '');
N := 1;

repeat
DestFile := ImagesDir + NameOnly + '_' + IntToStr(N) + Ext;
Inc(N);
until not FileExists(DestFile);
end;

CopyFile(ASourceFile, DestFile);

// HTML-pad teruggeven
Result := 'images/' + ExtractFileName(DestFile);
end;

//Veilige GetMergedCellRect

function THtmlTableDesigner.GetMergedCellRect(
ACol, ARow: Integer
): TRect;
var
Cell: THtmlCell;
LastCol, LastRow: Integer;
R1, R2: TRect;
begin
Result := Rect(0, 0, 0, 0);

if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

Cell := FCells[ACol, ARow];

if not Assigned(Cell) then
Exit;

R1 := GetCellRect(ACol, ARow);
Result := R1;

if (Cell.ColSpan <= 1) and
(Cell.RowSpan <= 1) then
Exit;

LastCol := ACol + Max(1, Cell.ColSpan) - 1;
LastRow := ARow + Max(1, Cell.RowSpan) - 1;

// Begrenzen tot de bestaande tabel
if LastCol >= FColCount then
LastCol := FColCount - 1;

if LastRow >= FRowCount then
LastRow := FRowCount - 1;

R2 := GetCellRect(LastCol, LastRow);

Result := Rect(
R1.Left,
R1.Top,
R2.Right,
R2.Bottom
);
end;

{
function THtmlTableDesigner.GetMergedCellRect(ACol, ARow: Integer): TRect;
var
Cell: THtmlCell;
C, R: Integer;
R1, R2: TRect;
begin
Result := GetCellRect(ACol, ARow);

Cell := FCells[ACol, ARow];

if (Cell.ColSpan <= 1) and (Cell.RowSpan <= 1) then
Exit;

R1 := GetCellRect(ACol, ARow);
R2 := GetCellRect(
ACol + Cell.ColSpan - 1,
ARow + Cell.RowSpan - 1
);

Result.Left := R1.Left;
Result.Top := R1.Top;
Result.Right := R2.Right;
Result.Bottom := R2.Bottom;
end;
}
procedure THtmlTableDesigner.UnmergeRow(ARow: Integer);
var
C: Integer;
begin
if (ARow < 0) or (ARow >= FRowCount) then Exit;

for C := 0 to FColCount - 1 do
begin
if FCells[C, ARow].Merged then
begin
FSelStartCol := FCells[C, ARow].MasterCol;
FSelStartRow := FCells[C, ARow].MasterRow;
FSelEndCol := FSelStartCol;
FSelEndRow := FSelStartRow;
UnmergeSelection;
end
else
if (FCells[C, ARow].ColSpan > 1) or
(FCells[C, ARow].RowSpan > 1) then
begin
FSelStartCol := C;
FSelStartRow := ARow;
FSelEndCol := C;
FSelEndRow := ARow;
UnmergeSelection;
end;
end;
end;

procedure THtmlTableDesigner.UnmergeCol(ACol: Integer);
var
R: Integer;
begin
if (ACol < 0) or (ACol >= FColCount) then Exit;

for R := 0 to FRowCount - 1 do
begin
if FCells[ACol, R].Merged then
begin
FSelStartCol := FCells[ACol, R].MasterCol;
FSelStartRow := FCells[ACol, R].MasterRow;
FSelEndCol := FSelStartCol;
FSelEndRow := FSelStartRow;
UnmergeSelection;
end
else
if (FCells[ACol, R].ColSpan > 1) or
(FCells[ACol, R].RowSpan > 1) then
begin
FSelStartCol := ACol;
FSelStartRow := R;
FSelEndCol := ACol;
FSelEndRow := R;
UnmergeSelection;
end;
end;
end;

procedure THtmlTableDesigner.MergeSelection;
var
L, T, R, B: Integer;
C, Row: Integer;
Master: THtmlCell;
MergedText: string;
begin
if FSelectionMode <> smCell then Exit;

GetSelectionBounds(L, T, R, B);

if (L = R) and (T = B) then Exit;

// Eerst bestaande merge in selectie losmaken
UnmergeSelection;

// Originele tekst van ALLE cellen bewaren
for Row := T to B do
for C := L to R do
begin
FCells[C, Row].BackupText := FCells[C, Row].Text;
FCells[C, Row].BackupValid := True;
end;

// Teksten samenvoegen voor master-cell
MergedText := '';
for Row := T to B do
for C := L to R do
begin
if FCells[C, Row].Text <> '' then
begin
if MergedText <> '' then
MergedText := MergedText + LineEnding;

MergedText := MergedText + FCells[C, Row].Text;
end;
end;

Master := FCells[L, T];
Master.Text := MergedText;
Master.ColSpan := R - L + 1;
Master.RowSpan := B - T + 1;
Master.Merged := False;
Master.MasterCol := -1;
Master.MasterRow := -1;

for C := L to R do
for Row := T to B do
begin
if (C = L) and (Row = T) then
Continue;

FCells[C, Row].Merged := True;
FCells[C, Row].MasterCol := L;
FCells[C, Row].MasterRow := T;
FCells[C, Row].ColSpan := 1;
FCells[C, Row].RowSpan := 1;
end;

FSelectedCol := L;
FSelectedRow := T;
FSelStartCol := L;
FSelStartRow := T;
FSelEndCol := L;
FSelEndRow := T;
FSelectionMode := smCell;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.UnmergeSelection;
var
L, T, R, B: Integer;
C, Row: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
// Originele tekst herstellen indien beschikbaar
if FCells[C, Row].BackupValid then
begin
FCells[C, Row].Text := FCells[C, Row].BackupText;
FCells[C, Row].BackupText := '';
FCells[C, Row].BackupValid := False;
end;

FCells[C, Row].Merged := False;
FCells[C, Row].MasterCol := -1;
FCells[C, Row].MasterRow := -1;
FCells[C, Row].ColSpan := 1;
FCells[C, Row].RowSpan := 1;
end;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.FitTableToClient(AFitRows: Boolean);
var
AvailableW, AvailableH: Integer;
C, R: Integer;
NewW, NewH: Integer;
begin
if FColCount <= 0 then Exit;

AvailableW := ClientWidth;

if FShowHeaders then
Dec(AvailableW, FHeaderWidth);

if AvailableW < FColCount * 20 then
AvailableW := FColCount * 20;

NewW := AvailableW div FColCount;

for C := 0 to FColCount - 1 do
FColWidths[C] := NewW;

if AFitRows then
begin
if FRowCount <= 0 then Exit;

AvailableH := ClientHeight;

if FShowHeaders then
Dec(AvailableH, FHeaderHeight);

if AvailableH < FRowCount * 16 then
AvailableH := FRowCount * 16;

NewH := AvailableH div FRowCount;

for R := 0 to FRowCount - 1 do
FRowHeights[R] := NewH;
end;

if FEditing then
UpdateEditorBounds;

Invalidate;
end;

function THtmlTableDesigner.GetTablePixelWidth: Integer;
var
C: Integer;
begin
Result := 0;

for C := 0 to FColCount - 1 do
Inc(Result, FColWidths[C]);
end;

function THtmlTableDesigner.GetTablePixelHeight: Integer;
var
R: Integer;
begin
Result := 0;

for R := 0 to FRowCount - 1 do
Inc(Result, FRowHeights[R]);
end;

procedure THtmlTableDesigner.CenterTableOnPage;
begin
if not FPageEnabled then Exit;

FTableOffsetX := (FPageWidth - GetTablePixelWidth - 20 ) div 2;

if FTableOffsetX < 0 then
FTableOffsetX := 0;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.DoChange;
begin
if Assigned(FOnChange) then
FOnChange(Self);
end;

procedure THtmlTableDesigner.TextBlockChanged;
begin
Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.ApplyFontColorToSelection(AColor: TColor);
var
L, T, R, B: Integer;
C, Y: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Y := T to B do
FCells[C, Y].FontColor := AColor;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyBgColorToSelection(AColor: TColor);
var
L, T, R, B: Integer;
C, Rw: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Rw := T to B do
FCells[C, Rw].BgColor := AColor;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyTextAlignToSelection(AAlign: TCellAlign);
var
L, T, R, B: Integer;
C, Rw: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Rw := T to B do
FCells[C, Rw].Align := AAlign;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyImageAlignToSelection(AAlign: TImageAlign);
var
L, T, R, B: Integer;
C, Y: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Y := T to B do
FCells[C, Y].ImageAlign := AAlign;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyBorderToSelection(ABorder: Boolean);
var
L, T, R, B: Integer;
C, Y: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Y := T to B do
FCells[C, Y].Border := ABorder;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyBorderStyleToSelection(AStyle: TCellBorderStyle);
var
L, T, R, B: Integer;
C, Row: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
FCells[C, Row].BorderStyle := AStyle;

Invalidate;
DoChange;
end;



procedure THtmlTableDesigner.ApplyBorderStyleTable(AStyle: TCellBorderStyle);
begin
if (FExportTableBorderStyle = AStyle) and
((AStyle <> cbsDouble) or (FExportTableBorderWidth >= 3)) then
Exit;

ExportTableBorderStyle := AStyle;

if AStyle = cbsDouble then
begin
if FExportTableBorderWidth < 3 then
ExportTableBorderWidth := 3;
end
else if FExportTableBorderWidth < 1 then
ExportTableBorderWidth := 1;

DoChange;
end;

procedure THtmlTableDesigner.ApplyBorderWidthTable(waarde: Integer);
begin
if waarde < 0 then
waarde := 0;

if waarde > 0 then
begin
if FExportTableBorderStyle = cbsNone then
ExportTableBorderStyle := cbsSolid;

if (FExportTableBorderStyle = cbsDouble) and (waarde < 3) then
waarde := 3;
end;

if FExportTableBorderWidth = waarde then Exit;

ExportTableBorderWidth := waarde;
DoChange;
end;

procedure THtmlTableDesigner.ApplyColWidthTable(Waarde: Integer);
var
C: Integer;
begin
if Waarde < 20 then
Waarde := 20;

FDefaultColWidth := Waarde;

for C := 0 to FColCount - 1 do
FColWidths[C] := Waarde;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyRowHeightTable(Waarde: Integer);
var
C: Integer;
begin
if Waarde < 10 then
Waarde := 10;

FDefaultRowHeight := Waarde;

for C := 0 to FRowCount - 1 do
FRowHeights[C] := Waarde;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyGridWidthTable(waarde: Integer);
begin
if waarde < 1 then
waarde := 1;
if FGridLineWidth = waarde then Exit;
GridLineWidth := waarde;

self.Invalidate;
self.DoChange;
end;

procedure THtmlTableDesigner.ApplyBorderRadiusTable(waarde: Integer);
begin
if waarde < 0 then
waarde := 0;

if FExportTableBorderRadius = waarde then Exit;

ExportTableBorderRadius := waarde;
DoChange;
end;

procedure THtmlTableDesigner.ApplyBgColorTable(AColor: TColor);
begin
if FExportTableBgColor = AColor then Exit;
ExportTableBgColor := AColor;
DoChange;
end;

procedure THtmlTableDesigner.ApplyGridColorTable(AColor: TColor);
begin
if FGridColor = AColor then Exit;
FGridColor:=AColor;
invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ApplyKaderColorTable(AColor: TColor);
begin
if FExportTableBorderColor= AColor then Exit;
ExportTableBorderColor:= AColor;
DoChange;
end;

procedure THtmlTableDesigner.CreateInplaceEditor;
begin
FInplaceEdit := TMemo.Create(Self);
FInplaceEdit.Parent := Self;
FInplaceEdit.Visible := False;
FInplaceEdit.BorderStyle := bsSingle;
FInplaceEdit.ScrollBars := ssNone;
FInplaceEdit.WordWrap := True;
FInplaceEdit.WantReturns := True;
FInplaceEdit.WantTabs := False;
// FInplaceEdit.Anchors := [akLeft, akTop];

FInplaceEdit.Left:=100;
FInplaceEdit.Top:=200;

FInplaceEdit.OnEditingDone := @InplaceEditEditingDone;
FInplaceEdit.OnKeyDown := @InplaceEditKeyDown;
end;

procedure THtmlTableDesigner.FreeCells;
var
C, R: Integer;
begin
for C := Low(FCells) to High(FCells) do
for R := Low(FCells[C]) to High(FCells[C]) do
FreeAndNil(FCells[C, R]);

SetLength(FCells, 0, 0);
end;

procedure THtmlTableDesigner.AllocateCells;
var
C, R: Integer;
begin
SetLength(FCells, FColCount, FRowCount);
for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
FCells[C, R] := THtmlCell.Create;
end;




procedure THtmlTableDesigner.InitColRowSizes;
var
I: Integer;
begin
for I := 0 to FColCount - 1 do
if FColWidths[I] <= 0 then
FColWidths[I] := FDefaultColWidth;

for I := 0 to FRowCount - 1 do
if FRowHeights[I] <= 0 then
FRowHeights[I] := FDefaultRowHeight;
end;

procedure THtmlTableDesigner.SetRowCount(AValue: Integer);
var
OldCells: array of array of THtmlCell;
OldCols, OldRows, C, R, CopyCols, CopyRows: Integer;
OldHeights: array of Integer;
I, OldCount: Integer;
NewRowHeight: Integer;
begin
if AValue < 1 then AValue := 1;
if FRowCount = AValue then Exit;

if FEditing then
EndEdit(True);

OldCols := FColCount;
OldRows := FRowCount;
OldCells := FCells;

OldHeights := FRowHeights;
OldCount := Length(OldHeights);

// Hoogte voor nieuwe rijen bepalen
if OldCount > 0 then
NewRowHeight := OldHeights[OldCount - 1]   // zelfde hoogte als vorige laatste rij
else
NewRowHeight := FDefaultRowHeight;

FRowCount := AValue;
SetLength(FCells, FColCount, FRowCount);

for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
FCells[C, R] := nil;

CopyCols := OldCols;
if CopyCols > FColCount then CopyCols := FColCount;

CopyRows := OldRows;
if CopyRows > FRowCount then CopyRows := FRowCount;

for C := 0 to CopyCols - 1 do
for R := 0 to CopyRows - 1 do
begin
FCells[C, R] := OldCells[C, R];
OldCells[C, R] := nil;
end;

for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
if FCells[C, R] = nil then
FCells[C, R] := THtmlCell.Create;

for C := 0 to High(OldCells) do
for R := 0 to High(OldCells[C]) do
if Assigned(OldCells[C, R]) then
OldCells[C, R].Free;

SetLength(FRowHeights, FRowCount);
for I := 0 to FRowCount - 1 do
begin
if I < OldCount then
FRowHeights[I] := OldHeights[I]
else
FRowHeights[I] := NewRowHeight;
end;

if FSelectedRow >= FRowCount then
FSelectedRow := FRowCount - 1;

if FSelectedRow < 0 then
FSelectedRow := 0;

Invalidate;
end;

procedure THtmlTableDesigner.SetColCount(AValue: Integer);
var
OldCells: array of array of THtmlCell;
OldCols, OldRows, C, R, CopyCols, CopyRows: Integer;
OldWidths: array of Integer;
I, OldCount: Integer;
begin
if AValue < 1 then AValue := 1;
if FColCount = AValue then Exit;

if FEditing then
EndEdit(True);

OldCols := FColCount;
OldRows := FRowCount;
OldCells := FCells;

OldWidths := FColWidths;
OldCount := Length(OldWidths);

FColCount := AValue;
SetLength(FCells, FColCount, FRowCount);

for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
FCells[C, R] := nil;

CopyCols := OldCols;
if CopyCols > FColCount then CopyCols := FColCount;
CopyRows := OldRows;
if CopyRows > FRowCount then CopyRows := FRowCount;

for C := 0 to CopyCols - 1 do
for R := 0 to CopyRows - 1 do
begin
FCells[C, R] := OldCells[C, R];
OldCells[C, R] := nil;
end;

for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
if FCells[C, R] = nil then
FCells[C, R] := THtmlCell.Create;

for C := 0 to High(OldCells) do
for R := 0 to High(OldCells[C]) do
if Assigned(OldCells[C, R]) then
OldCells[C, R].Free;

SetLength(FColWidths, FColCount);
for I := 0 to FColCount - 1 do
begin
if I < OldCount then
FColWidths[I] := OldWidths[I]
else
FColWidths[I] := FDefaultColWidth;
end;

if FSelectedCol >= FColCount then
FSelectedCol := FColCount - 1;

if FSelectedCol < 0 then
FSelectedCol := 0;

if FAutoFitTable then
FitTableToClient(False)
else
Invalidate;
end;


procedure THtmlTableDesigner.SetDefaultColWidth(AValue: Integer);
begin
if AValue < 20 then AValue := 20;
if FDefaultColWidth = AValue then Exit;
FDefaultColWidth := AValue;
if FEditing then UpdateEditorBounds;
Invalidate;
end;

procedure THtmlTableDesigner.SetDefaultRowHeight(AValue: Integer);
begin
if AValue < 16 then AValue := 16;
if FDefaultRowHeight = AValue then Exit;
FDefaultRowHeight := AValue;
if FEditing then UpdateEditorBounds;
Invalidate;
end;

procedure THtmlTableDesigner.SetGridColor(AValue: TColor);
begin
if FGridColor = AValue then Exit;
FGridColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetGridLineWidth(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FGridLineWidth = AValue then Exit;
FGridLineWidth := AValue;
Invalidate;
end;

// zacht Grid setters
procedure THtmlTableDesigner.SetShowLayoutGrid(AValue: Boolean);
begin
if FShowLayoutGrid = AValue then
Exit;

FShowLayoutGrid := AValue;

Invalidate;
end;

procedure THtmlTableDesigner.SetLayoutGridSize(AValue: Integer);
begin
if AValue < 2 then
AValue := 2;

if FLayoutGridSize = AValue then
Exit;

FLayoutGridSize := AValue;

Invalidate;
end;

procedure THtmlTableDesigner.SetLayoutGridColor(AValue: TColor);
begin
if FLayoutGridColor = AValue then
Exit;

FLayoutGridColor := AValue;

Invalidate;
end;

//------------------------------------------------------------------------------

procedure THtmlTableDesigner.SetSelectionColor(AValue: TColor);
begin
if FSelectionColor = AValue then Exit;
FSelectionColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetShowGrid(AValue: Boolean);
begin
if FShowGrid = AValue then Exit;
FShowGrid := AValue;
Invalidate;
end;

function THtmlTableDesigner.GetCell(ACol, ARow: Integer): THtmlCell;
begin
if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
raise Exception.Create('Cell index out of bounds');

Result := FCells[ACol, ARow];
end;
{
// veilige GetCellRect
function THtmlTableDesigner.GetCellRect(
ACol, ARow: Integer
): TRect;
var
XOff, YOff: Integer;
OffsetX, OffsetY: Integer;
I, XPos, YPos: Integer;
begin
Result := Rect(0, 0, 0, 0);

if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

if FShowHeaders then
begin
XOff := FHeaderWidth;
YOff := FHeaderHeight;
end
else
begin
XOff := 0;
YOff := 0;
end;

OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin
OffsetX := FPageMarginX + FTableOffsetX;
OffsetY := FPageMarginY + FTableOffsetY;
end;



XPos := XOff;

for I := 0 to ACol - 1 do
Inc(XPos, FColWidths[I]);

YPos := YOff;

for I := 0 to ARow - 1 do
Inc(YPos, FRowHeights[I]);

Result.Left := OffsetX + XPos;
Result.Top := OffsetY + YPos;

Result.Right :=
Result.Left + FColWidths[ACol];

Result.Bottom :=
Result.Top + FRowHeights[ARow];
end;}
{
function THtmlTableDesigner.GetCellRect(ACol, ARow: Integer): TRect;
var
XOff, YOff: Integer;
OffsetX, OffsetY: Integer;
I, XPos, YPos: Integer;
begin
// Headers
if FShowHeaders then
begin
XOff := FHeaderWidth;
YOff := FHeaderHeight;
end
else
begin
XOff := 0;
YOff := 0;
end;

// Pagina / tabel offset
OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin
OffsetX := FPageMarginX + FTableOffsetX;
OffsetY := FPageMarginY + FTableOffsetY;
end;

// X positie berekenen
XPos := XOff;
for I := 0 to ACol - 1 do
Inc(XPos, FColWidths[I]);

// Y positie berekenen
YPos := YOff;
for I := 0 to ARow - 1 do
Inc(YPos, FRowHeights[I]);

// Resultaat
Result.Left := OffsetX + XPos;
Result.Top := OffsetY + YPos;

Result.Right := Result.Left + FColWidths[ACol];
Result.Bottom := Result.Top + FRowHeights[ARow];
end;}

function THtmlTableDesigner.GetCellRect(
ACol, ARow: Integer
): TRect;
var
XOff, YOff: Integer;
OffsetX, OffsetY: Integer;
I, XPos, YPos: Integer;
begin
Result := Rect(0, 0, 0, 0);

if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

if FShowHeaders then
begin
XOff := FHeaderWidth;
YOff := FHeaderHeight;
end
else
begin
XOff := 0;
YOff := 0;
end;

// Centrale workspace/page/table offset
GetPageOffset(
OffsetX,
OffsetY
);

XPos := XOff;

for I := 0 to ACol - 1 do
Inc(XPos, FColWidths[I]);

YPos := YOff;

for I := 0 to ARow - 1 do
Inc(YPos, FRowHeights[I]);

Result.Left := OffsetX + XPos;
Result.Top := OffsetY + YPos;

Result.Right :=
Result.Left + FColWidths[ACol];

Result.Bottom :=
Result.Top + FRowHeights[ARow];
end;

function THtmlTableDesigner.CellFromPoint(X, Y: Integer; out ACol, ARow: Integer): Boolean;
var
XOff, YOff: Integer;
I, P: Integer;
begin
ACol := -1;
ARow := -1;

if FShowHeaders then
begin
XOff := FHeaderWidth;
YOff := FHeaderHeight;
end
else
begin
XOff := 0;
YOff := 0;
end;

if (X < XOff) or (Y < YOff) then
Exit(False);

P := XOff;
for I := 0 to FColCount - 1 do
begin
if (X >= P) and (X < P + FColWidths[I]) then
begin
ACol := I;
Break;
end;
Inc(P, FColWidths[I]);
end;

P := YOff;
for I := 0 to FRowCount - 1 do
begin
if (Y >= P) and (Y < P + FRowHeights[I]) then
begin
ARow := I;
Break;
end;
Inc(P, FRowHeights[I]);
end;

Result := (ACol >= 0) and (ARow >= 0);
end;

function BorderStyleToHTML(AStyle: TCellBorderStyle): string;
begin
case AStyle of
cbsSolid:  Result := 'solid';
cbsDashed: Result := 'dashed';
cbsDotted: Result := 'dotted';
cbsDouble: Result := 'double';
else
Result := 'none';
end;
end;

procedure THtmlTableDesigner.DrawCell(ACol, ARow: Integer; const R: TRect);
var
Cell: THtmlCell;
TxtR: TRect;
DrawR: TRect;
Flags: Longint;
HasImage: Boolean;
Radius: Integer;
begin
Cell := FCells[ACol, ARow];

Radius := FCellAfronding;//CellAfronding //
// Radius := FExportCellBorderRadius;
Canvas.Pen.Color := $00D0D0D0;
Canvas.Brush.Style := bsSolid;
Canvas.Brush.Color := Cell.BgColor;

if Radius > 0 then
begin
Canvas.Pen.Style := psClear;
Canvas.RoundRect(
R.Left,
R.Top,
R.Right,
R.Bottom,
Radius,
Radius
);
Canvas.Pen.Style := psSolid;
end
else
Canvas.FillRect(R);

HasImage :=
Cell.ShowImage and
Assigned(Cell.Picture.Graphic) and
(not Cell.Picture.Graphic.Empty);

if HasImage then
DrawCellImage(Cell, R);

if (Cell.Text <> '') and
not (FEditing and (ACol = FEditorCol) and (ARow = FEditorRow)) then
begin
Canvas.Font.Assign(Font);
Canvas.Font.Color := Cell.FontColor;
Canvas.Font.Size := Cell.FontSize;
Canvas.Font.Style := Cell.FontStyles;

if Cell.Bold then
Canvas.Font.Style := Canvas.Font.Style + [fsBold];

if Cell.IsLink then
begin
Canvas.Font.Color := clBlue;
Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
end;

TxtR := Rect(R.Left + 4, R.Top + 4, R.Right - 4, R.Bottom - 4);

if HasImage then
TxtR.Top := R.Top + ((R.Bottom - R.Top) div 2);

Flags := DT_WORDBREAK or DT_EDITCONTROL;

case Cell.Align of
caLeft:   Flags := Flags or DT_LEFT;
caCenter: Flags := Flags or DT_CENTER;
caRight:  Flags := Flags or DT_RIGHT;
end;

if Cell.IsLink and (Cell.LinkText <> '') then
DrawText(Canvas.Handle, PChar(Cell.LinkText), Length(Cell.LinkText), TxtR, Flags)
else
DrawText(Canvas.Handle, PChar(Cell.Text), Length(Cell.Text), TxtR, Flags);
end;

if FShowGrid and (Cell.BorderStyle <> cbsNone) then
begin
DrawR := R;
Canvas.Pen.Color := FGridColor;
Canvas.Pen.Width := FGridLineWidth;
Canvas.Brush.Style := bsClear;

case Cell.BorderStyle of
cbsSolid:
Canvas.Pen.Style := psSolid;

cbsDashed:
Canvas.Pen.Style := psDash;

cbsDotted:
Canvas.Pen.Style := psDot;

cbsDouble:
Canvas.Pen.Style := psSolid;
end;

if Radius > 0 then
Canvas.RoundRect(
DrawR.Left,
DrawR.Top,
DrawR.Right,
DrawR.Bottom,
Radius,
Radius
)
else
Canvas.Rectangle(DrawR);

if Cell.BorderStyle = cbsDouble then
begin
InflateRect(DrawR, -3, -3);

if Radius > 0 then
Canvas.RoundRect(
DrawR.Left,
DrawR.Top,
DrawR.Right,
DrawR.Bottom,
Radius,
Radius
)
else
Canvas.Rectangle(DrawR);
end;

Canvas.Pen.Style := psSolid;
Canvas.Pen.Width := 1;
end;
end;

function THtmlTableDesigner.TextToHTML(const S: string): string;
begin
Result := EscapeHTML(S);
Result := StringReplace(Result, LineEnding, '<br>', [rfReplaceAll]);
Result := StringReplace(Result, #13#10, '<br>', [rfReplaceAll]);
Result := StringReplace(Result, #10, '<br>', [rfReplaceAll]);
Result := StringReplace(Result, #13, '<br>', [rfReplaceAll]);
end;

function THtmlTableDesigner.HasMultiSelection: Boolean;
begin
Result :=
(FSelectionMode = smCell) and
((FSelStartCol <> FSelEndCol) or (FSelStartRow <> FSelEndRow));
end;

function THtmlTableDesigner.MMToPX(AMM: Double): Integer;
begin
Result := Round(AMM * FPixelsPerMM);
end;

procedure THtmlTableDesigner.DrawPageRulers(const PageR: TRect);
var
MM, PX: Integer;
S: string;
MaxMMX, MaxMMY: Integer;
TickLen: Integer;
OriginX, OriginY: Integer;
begin
if not FShowPageRulers then Exit;

OriginX := PageR.Left + FRulerSize;
OriginY := PageR.Top  + FRulerSize;

Canvas.Brush.Color := clBtnFace;
Canvas.Pen.Color := clGray;
Canvas.Font.Color := clBlack;
Canvas.Font.Size := 7;

MaxMMX := Round(FPageWidth / FPixelsPerMM);
MaxMMY := Round(FPageHeight / FPixelsPerMM);

// hoek linksboven
Canvas.Rectangle(PageR.Left, PageR.Top, OriginX, OriginY);

// bovenste ruler: start na linkse ruler
Canvas.Rectangle(OriginX, PageR.Top, OriginX + FPageWidth, OriginY);

for MM := 0 to MaxMMX do
begin
PX := MMToPX(MM);

if MM mod 10 = 0 then
TickLen := 10
else if MM mod 5 = 0 then
TickLen := 7
else
TickLen := 3;

Canvas.MoveTo(OriginX + PX, OriginY);
Canvas.LineTo(OriginX + PX, OriginY - TickLen);

if MM mod 10 = 0 then
begin
S := IntToStr(MM);
Canvas.TextOut(OriginX + PX + 2, PageR.Top + 2, S);
end;
end;

// linkse ruler: start onder bovenste ruler
Canvas.Rectangle(PageR.Left, OriginY, OriginX, OriginY + FPageHeight);

for MM := 0 to MaxMMY do
begin
PX := MMToPX(MM);

if MM mod 10 = 0 then
TickLen := 10
else if MM mod 5 = 0 then
TickLen := 7
else
TickLen := 3;

Canvas.MoveTo(OriginX, OriginY + PX);
Canvas.LineTo(OriginX - TickLen, OriginY + PX);

if MM mod 10 = 0 then
begin
S := IntToStr(MM);
Canvas.TextOut(PageR.Left + 2, OriginY + PX + 2, S);
end;
end;
end;



procedure THtmlTableDesigner.SetHtmlBgColor(AValue: TColor);
begin
if FHtmlBgColor = AValue then Exit;

FHtmlBgColor := AValue;
Invalidate;
end;


procedure THtmlTableDesigner.NormalizeSelection(out L, T, R, B: Integer);
begin
if FSelStartCol < FSelEndCol then
begin
L := FSelStartCol;
R := FSelEndCol;
end
else
begin
L := FSelEndCol;
R := FSelStartCol;
end;

if FSelStartRow < FSelEndRow then
begin
T := FSelStartRow;
B := FSelEndRow;
end
else
begin
T := FSelEndRow;
B := FSelStartRow;
end;
end;
{
procedure THtmlTableDesigner.DrawSelection;
var
R: TRect;
TotalW, TotalH: Integer;
I: Integer;
L, T, RR, B: Integer;
OffsetX, OffsetY: Integer;
begin
Canvas.Brush.Style := bsClear;
Canvas.Pen.Color := FSelectionColor;
Canvas.Pen.Width := 2;

OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin
OffsetX := FPageMarginX + FTableOffsetX;
OffsetY := FPageMarginY + FTableOffsetY;
end;

if HasMultiSelection then
begin
NormalizeSelection(L, T, RR, B);

R := GetCellRect(L, T);
R.Right := GetCellRect(RR, B).Right;
R.Bottom := GetCellRect(RR, B).Bottom;

Canvas.Rectangle(R);
Canvas.Pen.Width := 1;
Exit;
end;

TotalW := 0;
for I := 0 to FColCount - 1 do
Inc(TotalW, FColWidths[I]);

TotalH := 0;
for I := 0 to FRowCount - 1 do
Inc(TotalH, FRowHeights[I]);

case FSelectionMode of
smCell:
begin
if (FSelectedCol < 0) or (FSelectedCol >= FColCount) or
(FSelectedRow < 0) or (FSelectedRow >= FRowCount) then Exit;

R := GetCellRect(FSelectedCol, FSelectedRow);
Canvas.Rectangle(R);
end;

smRow:
begin
if (FSelectedRow < 0) or (FSelectedRow >= FRowCount) then Exit;

R := GetCellRect(0, FSelectedRow);

// inclusief rijheader
R.Left := OffsetX;
R.Right := OffsetX + FHeaderWidth + TotalW;

Canvas.Rectangle(R);
end;

smCol:
begin
if (FSelectedCol < 0) or (FSelectedCol >= FColCount) then Exit;

R := GetCellRect(FSelectedCol, 0);

// inclusief kolomheader
R.Top := OffsetY;
R.Bottom := OffsetY + FHeaderHeight + TotalH;

Canvas.Rectangle(R);
end;
end;

Canvas.Pen.Width := 1;
end; }

procedure THtmlTableDesigner.DrawSelection;
var
R: TRect;
TotalW, TotalH: Integer;
I: Integer;
L, T, RR, B: Integer;
OffsetX, OffsetY: Integer;
begin
// Geen rode selectiekader tekenen zolang er geen echte cel/rij/kolom-
// selectie is (bv. bij opstart, of nadat een TextBlock geselecteerd
// werd of naast de tabel geklikt is).
if not FHasSelection then
Exit;

Canvas.Brush.Style := bsClear;
Canvas.Pen.Color := FSelectionColor;
Canvas.Pen.Width := 2;

// ------------------------------------------------------------
// Centrale offset gebruiken
// Inclusief WorkspaceOffsetX
// ------------------------------------------------------------

GetPageOffset(
OffsetX,
OffsetY
);

// ------------------------------------------------------------
// Meervoudige celselectie
// ------------------------------------------------------------

if HasMultiSelection then
begin
NormalizeSelection(L, T, RR, B);

R := GetCellRect(L, T);

R.Right :=
GetCellRect(RR, B).Right;

R.Bottom :=
GetCellRect(RR, B).Bottom;

Canvas.Rectangle(R);

Canvas.Pen.Width := 1;
Exit;
end;

// ------------------------------------------------------------
// Totale tabelbreedte
// ------------------------------------------------------------

TotalW := 0;

for I := 0 to FColCount - 1 do
Inc(TotalW, FColWidths[I]);

// ------------------------------------------------------------
// Totale tabelhoogte
// ------------------------------------------------------------

TotalH := 0;

for I := 0 to FRowCount - 1 do
Inc(TotalH, FRowHeights[I]);

// ------------------------------------------------------------
// Selectie tekenen
// ------------------------------------------------------------

case FSelectionMode of

// ----------------------------------------------------------
// Cel
// ----------------------------------------------------------

smCell:
begin
if (FSelectedCol < 0) or
(FSelectedCol >= FColCount) or
(FSelectedRow < 0) or
(FSelectedRow >= FRowCount) then
Exit;

R :=
GetCellRect(
FSelectedCol,
FSelectedRow
);

Canvas.Rectangle(R);
end;

// ----------------------------------------------------------
// Rij
// ----------------------------------------------------------

smRow:
begin
if (FSelectedRow < 0) or
(FSelectedRow >= FRowCount) then
Exit;

R :=
GetCellRect(
0,
FSelectedRow
);

// Rijheader + volledige tabelbreedte
R.Left := OffsetX;

R.Right :=
OffsetX +
FHeaderWidth +
TotalW;

Canvas.Rectangle(R);
end;

// ----------------------------------------------------------
// Kolom
// ----------------------------------------------------------

smCol:
begin
if (FSelectedCol < 0) or
(FSelectedCol >= FColCount) then
Exit;

R :=
GetCellRect(
FSelectedCol,
0
);

// Kolomheader + volledige tabelhoogte
R.Top := OffsetY;

R.Bottom :=
OffsetY +
FHeaderHeight +
TotalH;

Canvas.Rectangle(R);
end;
end;

Canvas.Pen.Width := 1;
end;

function THtmlTableDesigner.ColBorderFromPoint(X, Y: Integer; out ACol: Integer): Boolean;
var
I, P, Tol: Integer;
begin
Result := False;
ACol := -1;
Tol := 4;

if not FShowHeaders then Exit;
if (Y < 0) or (Y > FHeaderHeight + 4) then Exit;

P := FHeaderWidth;
for I := 0 to FColCount - 1 do
begin
Inc(P, FColWidths[I]);
if Abs(X - P) <= Tol then
begin
ACol := I;
Exit(True);
end;
end;
end;

function THtmlTableDesigner.RowBorderFromPoint(X, Y: Integer; out ARow: Integer): Boolean;
var
I, P, Tol: Integer;
begin
Result := False;
ARow := -1;
Tol := 4;

if not FShowHeaders then Exit;
if (X < 0) or (X > FHeaderWidth + 4) then Exit;

P := FHeaderHeight;
for I := 0 to FRowCount - 1 do
begin
Inc(P, FRowHeights[I]);
if Abs(Y - P) <= Tol then
begin
ARow := I;
Exit(True);
end;
end;
end;


function THtmlTableDesigner.EscapeHTML(const S: string): string;
begin
Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;

function THtmlTableDesigner.ColorToHTML(AColor: TColor): string;
var
C: LongInt;
R, G, B: Byte;
begin
C := ColorToRGB(AColor);
R := C and $FF;
G := (C shr 8) and $FF;
B := (C shr 16) and $FF;
Result := Format('#%.2x%.2x%.2x', [R, G, B]);
end;

function THtmlTableDesigner.AlignToHTML(AAlign: TCellAlign): string;
begin
case AAlign of
caLeft:   Result := 'left';
caCenter: Result := 'center';
caRight:  Result := 'right';
else
Result := 'left';
end;
end;

function THtmlTableDesigner.ColumnToName(ACol: Integer): string;
begin
Result := '';
Inc(ACol);
while ACol > 0 do
begin
Result := Chr(Ord('A') + ((ACol - 1) mod 26)) + Result;
ACol := (ACol - 1) div 26;
end;
end;

function HtmlEscapeText(const S: string): string;
begin
Result := S;
Result := StringReplace(Result, '&', '&amp;', [rfReplaceAll]);
Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
Result := StringReplace(Result, LineEnding, '<br>', [rfReplaceAll]);
end;

function HtmlEscapeTextBlockText(const S: string): string;
var
T: string;
begin
T := S;

while (Length(T) > 0) and (T[Length(T)] in [#10, #13]) do
Delete(T, Length(T), 1);

T := StringReplace(T, '&', '&amp;', [rfReplaceAll]);
T := StringReplace(T, '<', '&lt;', [rfReplaceAll]);
T := StringReplace(T, '>', '&gt;', [rfReplaceAll]);
T := StringReplace(T, '"', '&quot;', [rfReplaceAll]);

Result := T;
end;

function THtmlTableDesigner.TextBlocksToHTML: string;
var
I: Integer;
B: TDesignerTextBlock;
AlignStr: string;
BorderStyleStr: string;
FontWeightStr: string;
FontStyleStr: string;
TextDecorationStr: string;
BgStr: string;
TextContent: string;
L, T, W, H: Integer;
Cell0Rect: TRect;
HtmlTablePos: TPoint;
LH: Integer;
SB: TStringBuilder;

// Voor het opbouwen van TextContent met (meerdere) hyperlinks
// (B.Links) en per-woord bold/italic/underline (B.StyleRuns),
// door de tekst in aaneengesloten segmenten met gelijke opmaak
// op te delen.
RawText: string;
CursorPos: Integer;
CharPos: Integer;
PrevURL, CurURL: string;
PrevStyles, CurStyles: TFontStyles;
PrevColor, CurColor: TColor;

// ----------------------------------------------------------
// Escaped een los tekstfragment (zonder de trailing-newline
// afkap die HtmlEscapeTextBlockText doet - dat gebeurt al
// eenmalig op RawText voordat we opsplitsen).
// ----------------------------------------------------------
function EscapeSeg(const S: string): string;
begin
Result := S;
Result := StringReplace(Result, '&', '&amp;', [rfReplaceAll]);
Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;

// ----------------------------------------------------------
// Hyperlink-URL op karakterpositie APos (0-based), of '' als
// er geen link is - zelfde voorrangsregels als LinkAtPos in
// DrawTextBlock, met terugval op de legacy single-link velden
// wanneer B.Links leeg is (compatibiliteit met oudere .htd's).
// ----------------------------------------------------------
function LinkURLAtPos(APos: Integer): string;
var
LI2: Integer;
LLink: TDesignerTextLink;
begin
Result := '';

if Assigned(B.Links) then
for LI2 := 0 to B.Links.Count - 1 do
begin
LLink := TDesignerTextLink(B.Links[LI2]);

if Assigned(LLink) and
(Trim(LLink.URL) <> '') and
(LLink.StartPos >= 0) and
(LLink.Length > 0) and
(APos >= LLink.StartPos) and
(APos < LLink.StartPos + LLink.Length) then
begin
Result := LLink.URL;
Exit;
end;
end;

if (Result = '') and
(not Assigned(B.Links) or (B.Links.Count = 0)) and
B.IsLink and (Trim(B.LinkURL) <> '') then
Result := B.LinkURL;
end;

// ----------------------------------------------------------
// Bouwt de HTML voor één ongesplitst tekstsegment (zelfde link
// + zelfde effectieve bold/italic/underline over het hele
// segment).
// ----------------------------------------------------------
function BuildSegmentHTML(
const ASegText: string;
const AURL: string;
AStyles: TFontStyles;
AColor: TColor): string;
var
Inner: string;
FWStr, FSStr, TDStr: string;
SpanStyle: string;
begin
if ASegText = '' then
begin
Result := '';
Exit;
end;

Inner := EscapeSeg(ASegText);

// Enkel een <span> toevoegen wanneer dit segment een expliciet
// afwijkende stijl en/of kleur heeft (per-woord StyleRun/
// ColorRun) - de blok-brede opmaak staat al op het omringende
// <div>. Een kleur op tekst die ook een link is, wordt genegeerd:
// net als op het scherm forceert de link zelf altijd blauw.
SpanStyle := '';

if AStyles <> B.FontStyles then
begin
if fsBold in AStyles then FWStr := 'bold' else FWStr := 'normal';
if fsItalic in AStyles then FSStr := 'italic' else FSStr := 'normal';
if fsUnderline in AStyles then TDStr := 'underline' else TDStr := 'none';

SpanStyle :=
SpanStyle +
'font-weight:' + FWStr + '; ' +
'font-style:' + FSStr + '; ' +
'text-decoration:' + TDStr + '; ';
end;

if (AURL = '') and (AColor <> B.FontColor) then
SpanStyle := SpanStyle + 'color:' + ColorToHTML(AColor) + '; ';

if SpanStyle <> '' then
Inner := '<span style="' + SpanStyle + '">' + Inner + '</span>';

if AURL <> '' then
Result :=
'<a href="' + EscapeHTML(AURL) +
'" style="color:#0000FF; text-decoration:underline;">' +
Inner + '</a>'
else
Result := Inner;
end;

begin
HtmlTablePos := GetHtmlTablePos;
Cell0Rect := GetCellRect(0, 0);

// Zelfde reden als in ToHTML: bij veel tekstblokken voorkomt
// TStringBuilder dat elke toevoeging de volledige, tot dan toe
// opgebouwde HTML opnieuw kopieert.
SB := TStringBuilder.Create;
try
for I := 0 to FTextBlocks.Count - 1 do
begin
B := TDesignerTextBlock(FTextBlocks[I]);

case B.Alignment of
taLeftJustify:  AlignStr := 'left';
taCenter:       AlignStr := 'center';
taRightJustify: AlignStr := 'right';
else
AlignStr := 'left';
end;

case B.BorderStyle of
cbsNone:   BorderStyleStr := 'none';
cbsSolid:  BorderStyleStr := 'solid';
cbsDashed: BorderStyleStr := 'dashed';
cbsDotted: BorderStyleStr := 'dotted';
cbsDouble: BorderStyleStr := 'double';
else
BorderStyleStr := 'none';
end;

if fsBold in B.FontStyles then
FontWeightStr := 'bold'
else
FontWeightStr := 'normal';

if fsItalic in B.FontStyles then
FontStyleStr := 'italic'
else
FontStyleStr := 'normal';

if fsUnderline in B.FontStyles then
TextDecorationStr := 'underline'
else
TextDecorationStr := 'none';

if B.Transparent then
BgStr := 'transparent'
else
BgStr := ColorToHTML(B.BgColor);

W := B.Rect.Right - B.Rect.Left;
H := B.Rect.Bottom - B.Rect.Top;

LH := B.LineHeight;

if LH <= 0 then
LH := Round(B.FontSize * 1.20);

L :=
HtmlTablePos.X +
(B.Rect.Left - Cell0Rect.Left);

T :=
B.Rect.Top -
FHeaderHeight -
FPageMarginY -
FTableOffsetY + 2;

// ----------------------------------------------------------
// TextBlock inhoud
// ----------------------------------------------------------

// RawText: zelfde trailing-newline afkap als HtmlEscapeTextBlockText,
// maar nog niet HTML-geescaped: de Links-posities (StartPos/Length)
// zijn 0-based posities in de ongeescapte tekst (zelfde conventie
// als LinkAtPos in DrawTextBlock).
RawText := B.Text;
while (Length(RawText) > 0) and
(RawText[Length(RawText)] in [#10, #13]) do
Delete(RawText, Length(RawText), 1);

TextContent := '';

// Tekst opdelen in aaneengesloten segmenten met identieke
// opmaak (zelfde link + zelfde effectieve bold/italic/
// underline + zelfde effectieve kleur), en per segment de
// juiste HTML opbouwen. Zelfde aanpak als de
// DrawStyledLine-segmentatie op het scherm.
if Length(RawText) > 0 then
begin
CursorPos := 0;
PrevURL := LinkURLAtPos(0);
PrevStyles := B.EffectiveStyleAt(0);
PrevColor := B.EffectiveColorAt(0);

for CharPos := 1 to Length(RawText) - 1 do
begin
CurURL := LinkURLAtPos(CharPos);
CurStyles := B.EffectiveStyleAt(CharPos);
CurColor := B.EffectiveColorAt(CharPos);

if (CurURL <> PrevURL) or
(CurStyles <> PrevStyles) or
(CurColor <> PrevColor) then
begin
TextContent :=
TextContent +
BuildSegmentHTML(
Copy(RawText, CursorPos + 1, CharPos - CursorPos),
PrevURL,
PrevStyles,
PrevColor
);

CursorPos := CharPos;
PrevURL := CurURL;
PrevStyles := CurStyles;
PrevColor := CurColor;
end;
end;

// Laatste segment.
TextContent :=
TextContent +
BuildSegmentHTML(
Copy(RawText, CursorPos + 1, Length(RawText) - CursorPos),
PrevURL,
PrevStyles,
PrevColor
);
end;

// ----------------------------------------------------------
// HTML
// ----------------------------------------------------------

SB.Append(
'<div class="designer-textblock" style="' +
'position:absolute; ' +
'left:' + IntToStr(L) + 'px; ' +
'top:' + IntToStr(T) + 'px; ' +
'width:' + IntToStr(W) + 'px; ' +
'height:' + IntToStr(H) + 'px; ' +
'box-sizing:border-box; ' +
'padding:' + IntToStr(B.Padding) + 'px; ' +
'font-size:' + IntToStr(B.FontSize) + 'pt; '
);

if B.WordWrap then
SB.Append('line-height:normal; ')
else
SB.Append(
'line-height:' +
IntToStr(LH) +
'px; '
);

SB.Append(
'color:' +
ColorToHTML(B.FontColor) +
'; ' +

'font-weight:' +
FontWeightStr +
'; ' +

'font-style:' +
FontStyleStr +
'; ' +

'text-decoration:' +
TextDecorationStr +
'; ' +

'text-align:' +
AlignStr +
'; ' +

'background-color:' +
BgStr +
'; ' +

'border:' +
IntToStr(B.BorderWidth) +
'px ' +
BorderStyleStr +
' ' +
ColorToHTML(B.BorderColor) +
'; ' +

'border-radius:' +
IntToStr(B.BorderRadius) +
'px; ' +

'overflow:hidden; ' +
'white-space:pre-wrap; ' +
'overflow-wrap:break-word; ' +
'z-index:10; ' +

'">' +

TextContent +

'</div>' +
LineEnding
);
end;

Result := SB.ToString;
finally
SB.Free;
end;
end;


function THtmlTableDesigner.RowHeaderFromPoint(X, Y: Integer; out ARow: Integer): Boolean;
var
I: Integer;
YPos: Integer;
begin
Result := False;
ARow := -1;

if not FShowHeaders then Exit;

// Alleen klikken in de linker rij-header
if (X < 0) or (X >= FHeaderWidth) then Exit;
if Y < FHeaderHeight then Exit;

YPos := FHeaderHeight;

for I := 0 to FRowCount - 1 do
begin
if (Y >= YPos) and (Y < YPos + FRowHeights[I]) then
begin
ARow := I;
Result := True;
Exit;
end;

Inc(YPos, FRowHeights[I]);
end;
end;


function THtmlTableDesigner.TotalTableWidth: Integer;
var
I: Integer;
begin
Result := 0;
for I := 0 to FColCount - 1 do
Inc(Result, FColWidths[I]);
end;

function THtmlTableDesigner.TotalTableHeight: Integer;
var
I: Integer;
begin
Result := 0;
for I := 0 to FRowCount - 1 do
Inc(Result, FRowHeights[I]);
end;

function THtmlTableDesigner.CellInCurrentSelection(ACol, ARow: Integer): Boolean;
var
L, T, R, B: Integer;
begin
GetSelectionBounds(L, T, R, B);

Result :=
(ACol >= L) and (ACol <= R) and
(ARow >= T) and (ARow <= B);
end;

function THtmlTableDesigner.ColHeaderFromPoint(X, Y: Integer; out ACol: Integer): Boolean;
var
I, XPos: Integer;
begin
Result := False;
ACol := -1;

if not FShowHeaders then Exit;
if (Y < 0) or (Y >= FHeaderHeight) then Exit;
if X < FHeaderWidth then Exit;

XPos := FHeaderWidth;

for I := 0 to FColCount - 1 do
begin
if (X >= XPos) and (X < XPos + FColWidths[I]) then
begin
ACol := I;
Exit(True);
end;

Inc(XPos, FColWidths[I]);
end;
end;

procedure THtmlTableDesigner.SetSelectedCell(ACol, ARow: Integer);
begin
if ACol < 0 then ACol := 0;
if ACol >= FColCount then ACol := FColCount - 1;
if ARow < 0 then ARow := 0;
if ARow >= FRowCount then ARow := FRowCount - 1;

if (FSelectedCol = ACol) and (FSelectedRow = ARow) and FHasSelection then Exit;

FSelectedCol := ACol;
FSelectedRow := ARow;
FHasSelection := True;
Invalidate;

if Assigned(FOnSelectionChange) then
FOnSelectionChange(Self, FSelectedCol, FSelectedRow);
end;

procedure THtmlTableDesigner.UpdateEditorBounds;
var
R: TRect;
NewLeft, NewTop, NewWidth, NewHeight: Integer;
begin
if FUpdatingEditorBounds then Exit;
if not Assigned(FInplaceEdit) then Exit;
if (FEditorCol < 0) or (FEditorCol >= FColCount) then Exit;
if (FEditorRow < 0) or (FEditorRow >= FRowCount) then Exit;

R := GetCellRect(FEditorCol, FEditorRow);
InflateRect(R, -1, -1);

NewLeft   := R.Left + 1;
NewTop    := R.Top + 1;
NewWidth  := (R.Right - R.Left) - 2;
NewHeight := (R.Bottom - R.Top) - 2;

if NewWidth < 8 then NewWidth := 8;
if NewHeight < 8 then NewHeight := 8;

if (FInplaceEdit.Left = NewLeft) and
(FInplaceEdit.Top = NewTop) and
(FInplaceEdit.Width = NewWidth) and
(FInplaceEdit.Height = NewHeight) then
Exit;

FUpdatingEditorBounds := True;
try
FInplaceEdit.SetBounds(NewLeft, NewTop, NewWidth, NewHeight);
finally
FUpdatingEditorBounds := False;
end;
end;

procedure THtmlTableDesigner.StartEdit(ACol, ARow: Integer);
begin
if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then Exit;

if FEditing then
EndEdit(True);

FEditorCol := ACol;
FEditorRow := ARow;
FEditorOriginalText := FCells[ACol, ARow].Text;

FInplaceEdit.Font.Assign(Font);
FInplaceEdit.Text := FEditorOriginalText;
FInplaceEdit.Color := FCells[ACol, ARow].BgColor;
FInplaceEdit.Font.Color := FCells[ACol, ARow].FontColor;

FEditing := True;
UpdateEditorBounds;

FInplaceEdit.Visible := True;
FInplaceEdit.BringToFront;
FInplaceEdit.SelectAll;
FInplaceEdit.SetFocus;

// Invalidate;
end;

procedure THtmlTableDesigner.EndEdit(AAccept: Boolean);
var
NewText: string;
begin
if not FEditing then Exit;

if AAccept then
begin
NewText := FInplaceEdit.Text;

FCells[FEditorCol, FEditorRow].Text := NewText;

if FCells[FEditorCol, FEditorRow].Text <> NewText then
begin
FCells[FEditorCol, FEditorRow].Text := NewText;
DoChange;
end;

if Assigned(FOnCellEdited) then
FOnCellEdited(Self, FEditorCol, FEditorRow, NewText);
DoChange;
end
else
FInplaceEdit.Text := FEditorOriginalText;

FInplaceEdit.Visible := False;
FEditing := False;
FEditorCol := -1;
FEditorRow := -1;

SetFocus;
Invalidate;
end;

procedure THtmlTableDesigner.InplaceEditEditingDone(
Sender: TObject);
begin
// ----------------------------------------------------------
// TextBlock editor
// ----------------------------------------------------------

if FEditingTextBlock then
begin
// BELANGRIJK:
// selectie bewaren voordat de editor wordt verborgen.
FTextBlockSelStart :=
FInplaceEdit.SelStart;

FTextBlockSelLength :=
FInplaceEdit.SelLength;

if Assigned(FSelectedTextBlock) then
FSelectedTextBlock.Text :=
FInplaceEdit.Text;

FInplaceEdit.Visible := False;
FEditingTextBlock := False;

Invalidate;
DoChange;
Exit;
end;

// ----------------------------------------------------------
// Cel editor
// ----------------------------------------------------------

if FEditing then
EndEdit(True);
end;

procedure THtmlTableDesigner.InplaceEditKeyDown(Sender: TObject; var Key: Word;
Shift: TShiftState);
begin
case Key of
VK_RETURN:
begin
if ssCtrl in Shift then
begin
EndEdit(True);
Key := 0;
end;
end;

VK_ESCAPE:
begin
EndEdit(False);
Key := 0;
end;
end;
end;

procedure THtmlTableDesigner.DrawHeaders;
var
C, R: Integer;
HR: TRect;
S: string;
XPos, YPos: Integer;
OffsetX, OffsetY: Integer;
begin
if not FShowHeaders then Exit;

OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin
// OffsetX := FPageMarginX + FTableOffsetX;
// OffsetY := FPageMarginY + FTableOffsetY;
GetPageOffset(OffsetX,OffsetY);
end;

Canvas.Brush.Style := bsSolid;
Canvas.Font.Assign(Font);
Canvas.Font.Color := FHeaderFontColor;
Canvas.Font.Style := [fsBold];

Canvas.Pen.Color := FGridColor;
Canvas.Pen.Width := FGridLineWidth;

// Hoekvak linksboven
HR := Rect(
OffsetX,
OffsetY,
OffsetX + FHeaderWidth,
OffsetY + FHeaderHeight
);

Canvas.Brush.Color := FHeaderColor;
Canvas.FillRect(HR);
Canvas.Rectangle(HR);

// Kolomheaders: A, B, C, ...
XPos := OffsetX + FHeaderWidth;

for C := 0 to FColCount - 1 do
begin
HR := Rect(
XPos,
OffsetY,
XPos + FColWidths[C],
OffsetY + FHeaderHeight
);

Canvas.Brush.Color := FHeaderColor;
Canvas.FillRect(HR);
Canvas.Rectangle(HR);

S := ColumnToName(C);
DrawText(Canvas.Handle, PChar(S), Length(S), HR,
DT_CENTER or DT_VCENTER or DT_SINGLELINE);

Inc(XPos, FColWidths[C]);
end;

// Rijheaders: 1, 2, 3, ...
YPos := OffsetY + FHeaderHeight;

for R := 0 to FRowCount - 1 do
begin
HR := Rect(
OffsetX,
YPos,
OffsetX + FHeaderWidth,
YPos + FRowHeights[R]
);

Canvas.Brush.Color := FHeaderColor;
Canvas.FillRect(HR);
Canvas.Rectangle(HR);

S := IntToStr(R + 1);
DrawText(Canvas.Handle, PChar(S), Length(S), HR,
DT_CENTER or DT_VCENTER or DT_SINGLELINE);

Inc(YPos, FRowHeights[R]);
end;

Canvas.Pen.Width := 1;
end;

procedure THtmlTableDesigner.DrawSettingsButton;
var
R: TRect;
X, Y: Integer;
begin
if not FShowHeaders then Exit;

R := GetSettingsButtonRect;

Canvas.Brush.Color := clBtnFace;
Canvas.Pen.Color := clGray;
Canvas.Rectangle(R);

if Assigned(FImages) and
(FSettingsImageIndex >= 0) and
(FSettingsImageIndex < FImages.Count) then
begin
X := R.Left + ((R.Right - R.Left) - FImages.Width) div 2;
Y := R.Top + ((R.Bottom - R.Top) - FImages.Height) div 2;

FImages.Draw(Canvas, X, Y, FSettingsImageIndex, True);
end
else
begin
Canvas.Font.Assign(Font);
Canvas.Font.Style := [fsBold];
Canvas.Font.Size := 10;
Canvas.Font.Color := clBlack;

DrawText(
Canvas.Handle,
PChar('⚙'),
Length('⚙'),
R,
DT_CENTER or DT_VCENTER or DT_SINGLELINE
);
end;
end;


procedure THtmlTableDesigner.DrawCellImage(ACell: THtmlCell; const R: TRect);
var
ImgRect: TRect;
CellW, CellH: Integer;
ImgW, ImgH: Integer;
NewW, NewH: Integer;
Ratio: Double;
begin
if not Assigned(ACell) then Exit;
if not ACell.ShowImage then Exit;
if not Assigned(ACell.Picture.Graphic) then Exit;
if ACell.Picture.Graphic.Empty then Exit;

CellW := (R.Right - R.Left) - 4;
CellH := (R.Bottom - R.Top) - 4;

if (CellW <= 0) or (CellH <= 0) then Exit;

ImgW := ACell.Picture.Width;
ImgH := ACell.Picture.Height;

if (ImgW <= 0) or (ImgH <= 0) then Exit;

case ACell.ImageSizeMode of

ismOriginal:
begin
NewW := ImgW;
NewH := ImgH;

if NewW > CellW then NewW := CellW;
if NewH > CellH then NewH := CellH;
end;

ismFit:
begin
Ratio := ImgW / ImgH;

NewW := CellW;
NewH := Round(NewW / Ratio);

if NewH > CellH then
begin
NewH := CellH;
NewW := Round(NewH * Ratio);
end;
end;

ismStretch:
begin
ImgRect := Rect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2);
Canvas.StretchDraw(ImgRect, ACell.Picture.Graphic);
Exit;
end;

else
begin
NewW := ImgW;
NewH := ImgH;
end;
end;

case ACell.ImageAlign of
iaLeft:
ImgRect.Left := R.Left + 2;

iaCenter:
ImgRect.Left := R.Left + ((R.Right - R.Left) - NewW) div 2;

iaRight:
ImgRect.Left := R.Right - NewW - 2;
else
ImgRect.Left := R.Left + 2;
end;

ImgRect.Top := R.Top + ((R.Bottom - R.Top) - NewH) div 2;
ImgRect.Right := ImgRect.Left + NewW;
ImgRect.Bottom := ImgRect.Top + NewH;

Canvas.StretchDraw(ImgRect, ACell.Picture.Graphic);
end;

procedure THtmlTableDesigner.SelectMergedBlock(ACol, ARow: Integer);
var
MasterCol, MasterRow: Integer;
Cell: THtmlCell;
begin
if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

Cell := FCells[ACol, ARow];

// Als het een slave-cell is, master zoeken
if Cell.Merged then
begin
MasterCol := Cell.MasterCol;
MasterRow := Cell.MasterRow;
end
else
begin
MasterCol := ACol;
MasterRow := ARow;
end;

if (MasterCol < 0) or (MasterCol >= FColCount) or
(MasterRow < 0) or (MasterRow >= FRowCount) then
Exit;

Cell := FCells[MasterCol, MasterRow];

FSelectedCol := MasterCol;
FSelectedRow := MasterRow;

FSelStartCol := MasterCol;
FSelStartRow := MasterRow;
FSelEndCol := MasterCol + Cell.ColSpan - 1;
FSelEndRow := MasterRow + Cell.RowSpan - 1;

FSelectionMode := smCell;
FMultiSelecting := False;
FHasSelection := True;

Invalidate;

if Assigned(FOnCellClick) then
FOnCellClick(Self, MasterCol, MasterRow);
end;

function THtmlTableDesigner.GetTableRect: TRect;
var
R1, R2: TRect;
begin
if (FColCount <= 0) or (FRowCount <= 0) then
begin
Result := Rect(0, 0, 0, 0);
Exit;
end;

R1 := GetCellRect(0, 0);
R2 := GetCellRect(FColCount - 1, FRowCount - 1);

Result := Rect(
R1.Left,
R1.Top,
R2.Right,
R2.Bottom
);
end;

function THtmlTableDesigner.GetHtmlTablePos: TPoint;
begin
Result.X := FTableOffsetX + FHeaderWidth + FRulerSize - 3;
Result.Y := FTableOffsetY - FHeaderHeight - FRulerSize + 25;

end;

procedure THtmlTableDesigner.MouseMove(
Shift: TShiftState;
X, Y: Integer
);
var
Idx: Integer;
NewSize: Integer;
C, R: Integer;
OffsetX, OffsetY: Integer;
LX, LY: Integer;
W, H: Integer;
P: TPoint;
OverSettingsBtn: Boolean;
OverTextBlockBtn: Boolean;
PageR: TRect;
TableR: TRect;
HeaderR: TRect;
OverPageNotTable: Boolean;
CellR: TRect;
begin
FMouseX := X;
FMouseY := Y;

P := Point(X, Y);

inherited MouseMove(Shift, X, Y);

// ------------------------------------------------------------
// Eerst actieve acties afhandelen
// ------------------------------------------------------------

if FResizingTextBlock and
Assigned(FSelectedTextBlock) then
begin
FSelectedTextBlock.Rect := Rect(
FTextBlockResizeOrigRect.Left,
FTextBlockResizeOrigRect.Top,

Max(
FTextBlockResizeOrigRect.Left + 40,
FTextBlockResizeOrigRect.Right +
(X - FTextBlockResizeStart.X)
),

Max(
FTextBlockResizeOrigRect.Top + 20,
FTextBlockResizeOrigRect.Bottom +
(Y - FTextBlockResizeStart.Y)
)
);

Cursor := crSizeNWSE;

Invalidate;
DoChange;
Exit;
end;

if FDraggingTextBlock and
Assigned(FSelectedTextBlock) then
begin
W :=
FSelectedTextBlock.Rect.Right -
FSelectedTextBlock.Rect.Left;

H :=
FSelectedTextBlock.Rect.Bottom -
FSelectedTextBlock.Rect.Top;

FSelectedTextBlock.Rect := Rect(
X - FTextBlockDragOffset.X,
Y - FTextBlockDragOffset.Y,

X - FTextBlockDragOffset.X + W,
Y - FTextBlockDragOffset.Y + H
);

Cursor := crSizeAll;

Invalidate;
DoChange;
Exit;
end;

if FDraggingTable then
begin
FTableOffsetX :=
FDragOrigOffsetX +
(X - FDragStartX);

FTableOffsetY :=
FDragOrigOffsetY +
(Y - FDragStartY);

if FEditing then
UpdateEditorBounds;

Cursor := crSizeAll;

Invalidate;
DoChange;
Exit;
end;

// ------------------------------------------------------------
// Lokale tabelcoördinaten berekenen
// ------------------------------------------------------------

OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin
GetPageOffset(
OffsetX,
OffsetY
);
end;

LX := X - OffsetX;
LY := Y - OffsetY;

// ------------------------------------------------------------
// Kolom aanpassen
// ------------------------------------------------------------

if FIsResizingCol then
begin
NewSize :=
FResizeOrigSize +
(LX - FResizeStartX);

if NewSize < 20 then
NewSize := 20;

FColWidths[FResizingCol] := NewSize;

if FEditing then
UpdateEditorBounds;

Cursor := crHSplit;

Invalidate;
DoChange;
Exit;
end;

// ------------------------------------------------------------
// Rij aanpassen
// ------------------------------------------------------------

if FIsResizingRow then
begin
NewSize :=
FResizeOrigSize +
(LY - FResizeStartY);

if NewSize < 16 then
NewSize := 16;

FRowHeights[FResizingRow] := NewSize;

if FEditing then
UpdateEditorBounds;

Cursor := crVSplit;

Invalidate;
DoChange;
Exit;
end;

// ------------------------------------------------------------
// Meervoudige selectie
// ------------------------------------------------------------

if FMultiSelecting then
begin
if CellFromPoint(LX, LY, C, R) then
begin
FSelEndCol := C;
FSelEndRow := R;

FSelectedCol := C;
FSelectedRow := R;

FSelectionMode := smCell;

Invalidate;
end;

Exit;
end;

// ------------------------------------------------------------
// Hover boven instellingenknoppen
// ------------------------------------------------------------

OverSettingsBtn :=
PtInRect(
GetSettingsButtonRect,
P
);

OverTextBlockBtn :=
Assigned(FSelectedTextBlock) and
PtInRect(
TextBlockSettingsButtonRect(
FSelectedTextBlock
),
P
);

if OverSettingsBtn then
begin
Cursor := crHandPoint;

Application.CancelHint;

Hint :=
StringReplace(
FSettingsButtonHint,
'|',
LineEnding,
[rfReplaceAll]
);

Application.ActivateHint(
ClientToScreen(P)
);

Exit;
end;

if OverTextBlockBtn then
begin
Cursor := crHandPoint;

Application.CancelHint;

Hint :=
StringReplace(
FTextBlockButtonHint,
'|',
LineEnding,
[rfReplaceAll]
);

Application.ActivateHint(
ClientToScreen(P)
);

Exit;
end;

// ------------------------------------------------------------
// Hint voor het verplaatsen van de tabel
// ------------------------------------------------------------

OverPageNotTable := False;

if FPageEnabled then
begin
{PageR := Rect(
FPageMarginX,
FPageMarginY,

FPageMarginX +
FPageWidth,

FPageMarginY +
FPageHeight
);}
PageR := Rect(
FWorkspaceOffsetX + FPageMarginX,
FPageMarginY,

FWorkspaceOffsetX +
FPageMarginX +
FPageWidth,

FPageMarginY +
FPageHeight
);

TableR := GetTableRect;

{HeaderR := Rect(
FPageMarginX +
FTableOffsetX,

FPageMarginY +
FTableOffsetY,

FPageMarginX +
FTableOffsetX +
FHeaderWidth +
GetTablePixelWidth,

FPageMarginY +
FTableOffsetY +
FHeaderHeight
);}
HeaderR := Rect(
OffsetX,
OffsetY,

OffsetX +
FHeaderWidth +
GetTablePixelWidth,

OffsetY +
FHeaderHeight
);


OverPageNotTable :=
PtInRect(PageR, P) and
not PtInRect(TableR, P) and
not PtInRect(HeaderR, P) and
not PtInRect(GetSettingsButtonRect, P) and
not OverTextBlockBtn;
end;

if OverPageNotTable then
begin
Cursor := crDefault;

Hint :=
StringReplace(
FMoveTableHint,
'|',
LineEnding,
[rfReplaceAll]
);

Application.ShowHint := True;

Exit;
end;

// ------------------------------------------------------------
// Geen actieve hint meer
// ------------------------------------------------------------

Application.CancelHint;
Hint := '';

// ------------------------------------------------------------
// Voorrang geven aan resize-randen
// ------------------------------------------------------------

if ColBorderFromPoint(LX, LY, Idx) then
begin
Cursor := crHSplit;
Exit;
end;

if RowBorderFromPoint(LX, LY, Idx) then
begin
Cursor := crVSplit;
Exit;
end;

// ------------------------------------------------------------
// Handcursor boven tekst- of afbeeldingshyperlink
// ------------------------------------------------------------

for R := 0 to FRowCount - 1 do
begin
for C := 0 to FColCount - 1 do
begin
if not Assigned(FCells[C, R]) then
Continue;

// Slavecellen van een merge overslaan.
// Alleen de mastercel wordt getest.
if FCells[C, R].Merged then
Continue;

// Volledige gewone of gemergede celrechthoek bepalen.
if (FCells[C, R].ColSpan > 1) or
(FCells[C, R].RowSpan > 1) then
begin
CellR := GetMergedCellRect(C, R);
end
else
begin
CellR := GetCellRect(C, R);
end;

// GetCellRect en GetMergedCellRect gebruiken
// clientcoördinaten, net zoals P.
if not PtInRect(CellR, P) then
Continue;

// Afbeeldingshyperlink:
// volledige gewone of gemergede cel toont de handcursor.
if FCells[C, R].ShowImage and
FCells[C, R].ImageIsLink and
(Trim(FCells[C, R].ImageLinkURL) <> '') then
begin
Cursor := crHandPoint;
Exit;
end;

// Teksthyperlink
if FCells[C, R].IsLink and
(Trim(FCells[C, R].LinkURL) <> '') then
begin
Cursor := crHandPoint;
Exit;
end;

// De muis staat in deze cel, maar ze bevat geen hyperlink.
Cursor := crDefault;
Exit;
end;
end;

Cursor := crDefault;
end;


procedure THtmlTableDesigner.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
inherited MouseUp(Button, Shift, X, Y);

FDraggingTextBlock := False;//TextBlock
FResizingTextBlock := False; //TextBlock

FMultiSelecting := False;
if Button = mbLeft then
begin
FIsResizingCol := False;
FIsResizingRow := False;
FResizingCol := -1;
FResizingRow := -1;
FDraggingTable := False;
Cursor := crDefault;
end;
end;

procedure THtmlTableDesigner.SetWorkspaceOffsetX(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FWorkspaceOffsetX = AValue then
Exit;

FWorkspaceOffsetX := AValue;

UpdateDesignerSize;

if FEditing then
UpdateEditorBounds;

Invalidate;
end;

procedure THtmlTableDesigner.SetImages(AValue: TCustomImageList);
begin
if FImages = AValue then Exit;
FImages := AValue;

// Laat ons op de hoogte stellen als deze ImageList ooit van het
// formulier verwijderd wordt, zodat FImages niet blijft verwijzen
// naar een vrijgegeven object (zie Notification hieronder).
if Assigned(FImages) then
FImages.FreeNotification(Self);

Invalidate;
end;

procedure THtmlTableDesigner.SetTableSettingsImageIndex(AValue: Integer);
begin
if FSettingsImageIndex = AValue then Exit;
FSettingsImageIndex := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.ReadLegacySettingsImageIndex(Reader: TReader);
begin
FSettingsImageIndex := Reader.ReadInteger;
end;

procedure THtmlTableDesigner.DefineProperties(Filer: TFiler);
begin
inherited DefineProperties(Filer);

// Enkel lezen, nooit meer wegschrijven. Bij THtmlTableDesignerAdvanced
// komt dit niet in actie: daar is SettingsImageIndex een eigen
// gepubliceerde eigenschap die de streaming eerst vindt.
Filer.DefineProperty('SettingsImageIndex',
@ReadLegacySettingsImageIndex, nil, False);
end;

procedure THtmlTableDesigner.Notification(
AComponent: TComponent;
Operation: TOperation);
begin
inherited Notification(AComponent, Operation);

if Operation = opRemove then
begin
// De gekoppelde ImageList wordt op dit moment vrijgegeven
// (bijvoorbeeld omdat de gebruiker het component van het
// formulier verwijdert). Zonder deze controle blijft FImages
// verwijzen naar vrijgegeven geheugen, met een crash bij de
// eerstvolgende Paint tot gevolg.
if AComponent = FImages then
begin
FImages := nil;
Invalidate;
end;
end;
end;

procedure THtmlTableDesigner.SetExportTableBgColor(AValue: TColor);
begin
if FExportTableBgColor = AValue then Exit;
FExportTableBgColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportTableBorderColor(AValue: TColor);
begin
if FExportTableBorderColor = AValue then Exit;
FExportTableBorderColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportTableBorderWidth(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FExportTableBorderWidth = AValue then Exit;

FExportTableBorderWidth := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportTableBorderRadius(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FExportTableBorderRadius = AValue then Exit;

FExportTableBorderRadius := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportTableBorderStyle(AValue: TCellBorderStyle);
begin
if FExportTableBorderStyle = AValue then Exit;
FExportTableBorderStyle := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportCellBorderColor(AValue: TColor);
begin
if FExportCellBorderColor = AValue then Exit;

FExportCellBorderColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportCellBorderRadius(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FExportCellBorderRadius = AValue then Exit;

FExportCellBorderRadius := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetExportCellPadding(AValue: Integer);
begin
if AValue < 0 then
AValue := 0;

if FExportCellPadding = AValue then Exit;

FExportCellPadding := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetShowHeaders(AValue: Boolean);
begin
if FShowHeaders = AValue then Exit;

FShowHeaders := AValue;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetHeaderHeight(AValue: Integer);
begin
if FHeaderHeight = AValue then Exit;

FHeaderHeight := AValue;

// Bepaalt mee waar cellen getekend worden (zie GetCellRect e.a.),
// dus zelfde behandeling als ShowHeaders hierboven.
if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetHeaderWidth(AValue: Integer);
begin
if FHeaderWidth = AValue then Exit;

FHeaderWidth := AValue;

if FEditing then
UpdateEditorBounds;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetHeaderColor(AValue: TColor);
begin
if FHeaderColor = AValue then Exit;

FHeaderColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetHeaderFontColor(AValue: TColor);
begin
if FHeaderFontColor = AValue then Exit;

FHeaderFontColor := AValue;
Invalidate;
end;

procedure THtmlTableDesigner.SetAutoStretchTable(AValue: Boolean);
begin
if FAutoStretchTable = AValue then Exit;

FAutoStretchTable := AValue;

// Let op: deze property wordt momenteel nergens elders in de code
// gelezen (enkel opgeslagen/geladen in het HTD-bestand) - zetten
// ervan heeft dus voorlopig geen zichtbaar effect. De Invalidate
// hier is puur voor consistentie met de andere setters.
Invalidate;
end;

procedure THtmlTableDesigner.SetAutoFitTable(AValue: Boolean);
begin
if FAutoFitTable = AValue then Exit;

FAutoFitTable := AValue;

// Direct toepassen zodra de optie wordt aangezet, in plaats van
// te wachten op de eerstvolgende Resize of kolomwijziging.
if FAutoFitTable then
FitTableToClient(False);

Invalidate;
end;

procedure THtmlTableDesigner.DrawRulerMarker(
const PageR: TRect;
AX, AY: Integer);
begin
if not FShowPageRulers then Exit;

Canvas.Pen.Color := clRed;
Canvas.Pen.Width := 2;

// marker op bovenste ruler
if (AX >= PageR.Left) and (AX <= PageR.Right) then
begin
Canvas.MoveTo(AX, PageR.Top);
Canvas.LineTo(AX, PageR.Top + FRulerSize);
end;

// marker op linkse ruler
if (AY >= PageR.Top) and (AY <= PageR.Bottom) then
begin
Canvas.MoveTo(PageR.Left, AY);
Canvas.LineTo(PageR.Left + FRulerSize, AY);
end;

Canvas.Pen.Width := 1;
end;

procedure THtmlTableDesigner.DrawLayoutGrid;
var
X, Y: Integer;
PageR: TRect;
begin
if not FShowLayoutGrid then
Exit;

if not FPageEnabled then
Exit;

if FLayoutGridSize < 2 then
Exit;

PageR := Rect(
FWorkspaceOffsetX + FPageMarginX,
FPageMarginY,
FWorkspaceOffsetX + FPageMarginX + FPageWidth,
FPageMarginY + FPageHeight
);

Y := PageR.Top + FLayoutGridSize;

while Y < PageR.Bottom do
begin
X := PageR.Left + FLayoutGridSize;

while X < PageR.Right do
begin
Canvas.Pixels[X, Y] := FLayoutGridColor;
Inc(X, FLayoutGridSize);
end;

Inc(Y, FLayoutGridSize);
end;
end;

procedure THtmlTableDesigner.Paint;
var
C, R: Integer;
CellR: TRect;
PageR: TRect;
TableR: TRect;
BorderOffset: Integer;
begin
// Achtergrond buiten de pagina
Canvas.Brush.Color := clWhite;//FHtmlBgColor;
Canvas.Brush.Style := bsSolid;
Canvas.FillRect(ClientRect);

// Pagina tekenen
if FPageEnabled then
begin

PageR := Rect(
FWorkspaceOffsetX + FPageMarginX,
FPageMarginY,

FWorkspaceOffsetX +
FPageMarginX +
FPageWidth,

FPageMarginY +
FPageHeight
);
Canvas.Brush.Color := FHtmlBgColor;// clWhite;
Canvas.Pen.Color := clGray;
Canvas.Pen.Width := 1;
Canvas.Pen.Style := psSolid;
Canvas.Rectangle(PageR);

DrawLayoutGrid;

DrawPageRulers(PageR);

if FShowPageRulers then
DrawRulerMarker(
PageR,
PageR.Left + FTableOffsetX,
PageR.Top + FTableOffsetY
);

if FIsResizingCol and (FResizingCol >= 0) then
DrawRulerMarker(
PageR,
GetCellRect(FResizingCol, 0).Right,
PageR.Top + FTableOffsetY
);

if FIsResizingRow and (FResizingRow >= 0) then
DrawRulerMarker(
PageR,
PageR.Left + FTableOffsetX,
GetCellRect(0, FResizingRow).Bottom
);
end;


DrawHeaders;

DrawSettingsButton;



// Tabel achtergrond
TableR := GetTableRect;

Canvas.Brush.Style := bsSolid;
Canvas.Brush.Color := FExportTableBgColor;
Canvas.Pen.Style := psClear;

if FExportTableBorderRadius > 0 then
Canvas.RoundRect(
TableR.Left,
TableR.Top,
TableR.Right,
TableR.Bottom,
FExportTableBorderRadius,
FExportTableBorderRadius
)
else
Canvas.FillRect(TableR);

Canvas.Pen.Style := psSolid;

for R := 0 to FRowCount - 1 do
for C := 0 to FColCount - 1 do
begin
if FCells[C, R].Merged then
Continue;

CellR := GetMergedCellRect(C, R);

if (CellR.Right > 0) and
(CellR.Bottom > 0) and
(CellR.Left < ClientWidth) and
(CellR.Top < ClientHeight) then
begin
DrawCell(C, R, CellR);
end;
end;

// Tabel buitenrand met radius
if (FExportTableBorderWidth > 0) and
(FExportTableBorderStyle <> cbsNone) then
begin
TableR := GetTableRect;

if FExportTableBorderWidth > 1 then
BorderOffset := FExportTableBorderWidth div 2
else
BorderOffset := 0;

InflateRect(TableR, -BorderOffset, -BorderOffset);

Canvas.Brush.Style := bsClear;
Canvas.Pen.Color := FExportTableBorderColor;
Canvas.Pen.Width := FExportTableBorderWidth;

case FExportTableBorderStyle of
cbsSolid:
Canvas.Pen.Style := psSolid;

cbsDashed:
Canvas.Pen.Style := psDash;

cbsDotted:
Canvas.Pen.Style := psDot;

cbsDouble:
Canvas.Pen.Style := psSolid;
else
Canvas.Pen.Style := psClear;
end;

if FExportTableBorderRadius > 0 then
Canvas.RoundRect(
TableR.Left,
TableR.Top,
TableR.Right - 1,
TableR.Bottom - 1,
FExportTableBorderRadius,
FExportTableBorderRadius
)
else
Canvas.Rectangle(
TableR.Left,
TableR.Top,
TableR.Right - 1,
TableR.Bottom - 1
);

if FExportTableBorderStyle = cbsDouble then
begin
InflateRect(TableR, -3, -3);

if FExportTableBorderRadius > 0 then
Canvas.RoundRect(
TableR.Left,
TableR.Top,
TableR.Right - 1,
TableR.Bottom - 1,
FExportTableBorderRadius,
FExportTableBorderRadius
)
else
Canvas.Rectangle(
TableR.Left,
TableR.Top,
TableR.Right - 1,
TableR.Bottom - 1
);
end;

Canvas.Pen.Width := 1;
Canvas.Pen.Style := psSolid;
Canvas.Brush.Style := bsSolid;
end;

DrawSelection;
DrawTextBlocks;//TextBloks
end;

procedure THtmlTableDesigner.GetPageOffset(
out OffsetX, OffsetY: Integer);
begin
// WorkspaceOffsetX geldt altijd
OffsetX := FWorkspaceOffsetX;
OffsetY := 0;

if FPageEnabled then
begin
Inc(
OffsetX,
FPageMarginX + FTableOffsetX
);

Inc(
OffsetY,
FPageMarginY + FTableOffsetY
);
end;
end;

procedure THtmlTableDesigner.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
C, R: Integer;
OffsetX, OffsetY: Integer;
LX, LY: Integer;
B: TDesignerTextBlock;
begin
FMouseX := X;
FMouseY := Y;

FLastDesignerClickX := X;
FLastDesignerClickY := Y;
FHasDesignerClickPos := True;

if CanFocus then
SetFocus;

inherited MouseDown(Button, Shift, X, Y);

if CanFocus then
SetFocus;

// Settings knop linksboven in tabel-header
if (Button = mbLeft) and
PtInRect(GetSettingsButtonRect, Point(X, Y)) then
begin
if Assigned(FOnSettingsClick) then
FOnSettingsClick(Self);
Exit;
end;

// TextBlock selecteren / deselecteren / verplaatsen
if Button = mbLeft then
begin
B := TextBlockFromPoint(X, Y);

if Assigned(B) then
begin
ClearTextBlockSelection;

FSelectedTextBlock := B;
FSelectedTextBlock.Selected := True;

// TextBlock geselecteerd: eventueel rood celkader verbergen
FHasSelection := False;

Invalidate;
DoChange; //aktief gezet

// Settings-knop van geselecteerd TextBlock
if PtInRect(TextBlockSettingsButtonRect(B), Point(X, Y)) then
begin
if Assigned(FOnTextBlockSettingsClick) then
FOnTextBlockSettingsClick(Self);
Exit;
end;

// Resize-handle van TextBlock
if TextBlockOnResizeHandle(B, X, Y) then
begin
FResizingTextBlock := True;
FTextBlockResizeStart := Point(X, Y);
FTextBlockResizeOrigRect := B.Rect;
Cursor := crSizeNWSE;
end
else
begin
FDraggingTextBlock := True;
FTextBlockDragOffset := Point(
X - B.Rect.Left,
Y - B.Rect.Top
);
Cursor := crSizeAll;
end;

Exit;
end
else
begin
// Klik op lege ruimte: TextBlock-selectie weg
if Assigned(FSelectedTextBlock) then
begin
ClearTextBlockSelection;
FSelectedTextBlock := nil;
FDraggingTextBlock := False;
FResizingTextBlock := False;

Invalidate;
DoChange;  // aktief gezet
end;
end;
end;

if not (Button in [mbLeft, mbRight]) then
Exit;

if FEditing then
EndEdit(True);

// Volledige tabel verplaatsen met CTRL + linkermuisknop
if (Button = mbLeft) and (ssCtrl in Shift) and FPageEnabled then
begin
FDraggingTable := True;
FDragStartX := X;
FDragStartY := Y;
FDragOrigOffsetX := FTableOffsetX;
FDragOrigOffsetY := FTableOffsetY;
Cursor := crSizeAll;
Exit;
end;

// Pagina/tabel offset omzetten naar lokale tabel-coördinaten
OffsetX := 0;
OffsetY := 0;

if FPageEnabled then
begin

GetPageOffset(
OffsetX,
OffsetY
);
end;

LX := X - OffsetX;
LY := Y - OffsetY;

// Kolombreedte wijzigen
if (Button = mbLeft) and ColBorderFromPoint(LX, LY, C) then
begin
FMultiSelecting := False;

FIsResizingCol := True;
FIsResizingRow := False;
FResizingCol := C;
FResizingRow := -1;
FResizeStartX := LX;
FResizeOrigSize := FColWidths[C];
Exit;
end;

// Rijhoogte wijzigen
if (Button = mbLeft) and RowBorderFromPoint(LX, LY, R) then
begin
FMultiSelecting := False;

FIsResizingRow := True;
FIsResizingCol := False;
FResizingRow := R;
FResizingCol := -1;
FResizeStartY := LY;
FResizeOrigSize := FRowHeights[R];
Exit;
end;

// Rijheader selecteren
if RowHeaderFromPoint(LX, LY, R) then
begin
FMultiSelecting := False;
FIsResizingCol := False;
FIsResizingRow := False;

FSelectedRow := R;
FSelectionMode := smRow;
FHasSelection := True;
Invalidate;

if Assigned(FOnCellClick) then
FOnCellClick(Self, -1, R);

Exit;
end;

// Kolomheader selecteren
if ColHeaderFromPoint(LX, LY, C) then
begin
FMultiSelecting := False;
FIsResizingCol := False;
FIsResizingRow := False;

FSelectedCol := C;
FSelectionMode := smCol;
FHasSelection := True;
Invalidate;

if Assigned(FOnCellClick) then
FOnCellClick(Self, C, -1);

Exit;
end;

// Gewone cel selecteren
if CellFromPoint(LX, LY, C, R) then
begin
if FCells[C, R].Merged or
(FCells[C, R].ColSpan > 1) or
(FCells[C, R].RowSpan > 1) then
begin
SelectMergedBlock(C, R);
Exit;
end;

if (Button = mbRight) and
HasMultiSelection and
CellInCurrentSelection(C, R) then
begin
FSelectedCol := C;
FSelectedRow := R;
FMultiSelecting := False;
FHasSelection := True;

if Assigned(FOnCellClick) then
FOnCellClick(Self, C, R);

Exit;
end;

ClearTextBlockSelection;
FSelectedTextBlock := nil;

FSelectedCol := C;
FSelectedRow := R;

FSelStartCol := C;
FSelStartRow := R;
FSelEndCol := C;
FSelEndRow := R;

FMultiSelecting := Button = mbLeft;
FSelectionMode := smCell;
FHasSelection := True;

Invalidate;


if Assigned(FOnCellClick) then
FOnCellClick(Self, C, R);

Exit;
end;

FMultiSelecting := False;

// Klik trof geen instellingenknop, TextBlock, rand, header of cel:
// echt lege ruimte naast/buiten de tabel. Celselectiekader verbergen.
if FHasSelection then
begin
FHasSelection := False;
Invalidate;
end;
end;

procedure THtmlTableDesigner.DblClick;
begin
inherited DblClick;
// QueueAsyncCall nodig:
// anders verliest de inline editor onmiddellijk zijn focus
// tijdens de DblClick-afhandeling.

if Assigned(FSelectedTextBlock) then
begin
Application.QueueAsyncCall(@DelayedStartTextBlockEdit, 0);
Exit;
end;

if FSelectionMode = smCell then
begin
FPendingEditCol := FSelectedCol;
FPendingEditRow := FSelectedRow;
Application.QueueAsyncCall(@DelayedStartCellEdit, 0);
Exit;
end;
end;

procedure THtmlTableDesigner.Resize;
begin
inherited Resize;

if FAutoFitTable then
FitTableToClient(False); // alleen kolommen automatisch

if FEditing then
UpdateEditorBounds;

Invalidate;
end;

procedure THtmlTableDesigner.KeyDown(var Key: Word; Shift: TShiftState);
begin
inherited KeyDown(Key, Shift);

if FEditing then Exit;

if (ssCtrl in Shift) and (Key = Ord('C')) then
begin
CopySelection;
Key := 0;
Exit;
end;

if (ssCtrl in Shift) and (Key = Ord('V')) then
begin
PasteSelection;
Key := 0;
Exit;
end;

case Key of
VK_F2:
begin
if Assigned(FSelectedTextBlock) then
StartTextBlockEdit(FSelectedTextBlock)
else if FSelectionMode = smCell then
StartEdit(FSelectedCol, FSelectedRow);

Key := 0;
end;

VK_DELETE:
begin
// Eerst geselecteerd tekstblok verwijderen
if Assigned(FSelectedTextBlock) then
begin

DeleteSelectedTextBlock;
Key := 0;
Exit;
end;

// Anders gewone celinhoud wissen
if (FSelectionMode = smCell) and
(FSelectedCol >= 0) and
(FSelectedRow >= 0) then
begin
FCells[FSelectedCol, FSelectedRow].Text := '';
Invalidate;
DoChange;
Key := 0;
end;
end;

VK_LEFT:
begin
ClearTextBlockSelection;
SetSelectedCell(FSelectedCol - 1, FSelectedRow);
Key := 0;
end;

VK_RIGHT:
begin
ClearTextBlockSelection;
SetSelectedCell(FSelectedCol + 1, FSelectedRow);
Key := 0;
end;

VK_UP:
begin
ClearTextBlockSelection;
SetSelectedCell(FSelectedCol, FSelectedRow - 1);
Key := 0;
end;

VK_DOWN:
begin
ClearTextBlockSelection;
SetSelectedCell(FSelectedCol, FSelectedRow + 1);
Key := 0;
end;

VK_RETURN:
begin
if Assigned(FSelectedTextBlock) then
StartTextBlockEdit(FSelectedTextBlock)
else if FSelectionMode = smCell then
StartEdit(FSelectedCol, FSelectedRow);

Key := 0;
end;
end;
end;

procedure THtmlTableDesigner.DeleteSelectedTextBlock;
var
Idx: Integer;
begin
if not Assigned(FSelectedTextBlock) then Exit;

Idx := FTextBlocks.IndexOf(FSelectedTextBlock);

if Idx >= 0 then
FTextBlocks.Delete(Idx);

FSelectedTextBlock := nil;

Invalidate;
DoChange;
end;


procedure THtmlTableDesigner.SetColWidth(ACol, AWidth: Integer);
begin
if (ACol < 0) or (ACol >= FColCount) then
Exit;

if AWidth < 20 then
AWidth := 20;

if FColWidths[ACol] = AWidth then
Exit;

FColWidths[ACol] := AWidth;

if FEditing then
UpdateEditorBounds;

UpdateDesignerSize;
Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetRowHeight(
ARow, AHeight: Integer
);
begin
// Controleren of de rij geldig is
if (ARow < 0) or (ARow >= FRowCount) then
Exit;

// Dezelfde minimumhoogte als bij het slepen
if AHeight < 16 then
AHeight := 16;

// Niets doen wanneer de hoogte niet verandert
if FRowHeights[ARow] = AHeight then
Exit;

FRowHeights[ARow] := AHeight;

// Eventuele actieve editor opnieuw positioneren
if FEditing then
UpdateEditorBounds;

UpdateDesignerSize;
Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetTextBlockLink(
AStartPos: Integer;
ALength: Integer;
const AURL: string);
begin
if not Assigned(FSelectedTextBlock) then
Exit;

if FSelectedTextBlock.AddLink(
AStartPos,
ALength,
AURL
) = nil then
Exit;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ToggleTextBlockStyle(AStyle: TFontStyle);
var
SelStart, SelLength: Integer;
begin
if not Assigned(FSelectedTextBlock) then
Exit;

if GetTextBlockSelection(SelStart, SelLength) and
(SelLength > 0) then
begin
// Enkel de geselecteerde tekst togglen.
FSelectedTextBlock.ToggleStyleRun(SelStart, SelLength, AStyle);
end
else
begin
// Geen selectie: zelfde gedrag als voorheen, het hele blok.
if AStyle in FSelectedTextBlock.FontStyles then
Exclude(FSelectedTextBlock.FontStyles, AStyle)
else
Include(FSelectedTextBlock.FontStyles, AStyle);
end;

TextBlockChanged;
end;

procedure THtmlTableDesigner.ApplyTextBlockFontColor(AColor: TColor);
var
SelStart, SelLength: Integer;
begin
if not Assigned(FSelectedTextBlock) then
Exit;

if GetTextBlockSelection(SelStart, SelLength) and
(SelLength > 0) then
begin
// Enkel de geselecteerde tekst kleuren.
FSelectedTextBlock.SetColorRun(SelStart, SelLength, AColor);
end
else
begin
// Geen selectie: zelfde gedrag als voorheen, het hele blok.
FSelectedTextBlock.FontColor := AColor;
end;

TextBlockChanged;
end;


procedure THtmlTableDesigner.ClearTextBlockLink;
begin
if not Assigned(FSelectedTextBlock) then
Exit;

// Nieuwe hyperlinklijst volledig leegmaken.
if Assigned(FSelectedTextBlock.Links) then
FSelectedTextBlock.Links.Clear;

// Oude velden eveneens resetten voor compatibiliteit met
// bestaande HTD-bestanden en nog niet omgezette code.
FSelectedTextBlock.IsLink := False;
FSelectedTextBlock.LinkURL := '';
FSelectedTextBlock.LinkStart := -1;
FSelectedTextBlock.LinkLength := 0;

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.Clear;
var
C, R: Integer;
begin
if FEditing then
EndEdit(True);

for C := 0 to FColCount - 1 do
for R := 0 to FRowCount - 1 do
begin
FCells[C, R].Text := '';
FCells[C, R].BgColor := clWhite;
FCells[C, R].FontColor := clBlack;
FCells[C, R].Align := caLeft;
FCells[C, R].Bold := False;
FCells[C, R].Picture.Clear;
FCells[C, R].ImageFile := '';
FCells[C, R].ShowImage := False;
FCells[C, R].ImageStretch := True;
FCells[C, R].BorderStyle:= cbsSolid;
end;
Invalidate;
end;


procedure THtmlTableDesigner.SetCellText(ACol, ARow: Integer; const AText: string);
begin
if (ACol < 0) or (ACol >= FColCount) or
(ARow < 0) or (ARow >= FRowCount) then
Exit;

FCells[ACol, ARow].Text :=
StringReplace(AText, '|', LineEnding, [rfReplaceAll]);

Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetCellColor(ACol, ARow: Integer; AColor: TColor);
begin
if Cells[ACol, ARow].BgColor = AColor then Exit;

Cells[ACol, ARow].BgColor := AColor;
Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetCellAlign(ACol, ARow: Integer; AAlign: TCellAlign);
begin
Cells[ACol, ARow].Align := AAlign;
Invalidate;
end;

procedure THtmlTableDesigner.SetCellImageAlign(ACol, ARow: Integer;
AAlign: TImageAlign);
begin
Cells[ACol, ARow].ImageAlign := AAlign;
Invalidate;
end;

procedure THtmlTableDesigner.LoadCellImage(ACol, ARow: Integer; const AFileName: string);
begin
if not FileExists(AFileName) then
raise Exception.Create('Image file not found: ' + AFileName);

Cells[ACol, ARow].Picture.LoadFromFile(AFileName);
Cells[ACol, ARow].ImageFile := AFileName;
Cells[ACol, ARow].ShowImage := True;
Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.ClearCellImage(ACol, ARow: Integer);
begin
Cells[ACol, ARow].Picture.Clear;
Cells[ACol, ARow].ImageFile := '';
Cells[ACol, ARow].ShowImage := False;
Invalidate;
DoChange;
end;

procedure THtmlTableDesigner.SetCellAfronding(AValue:Integer);
begin
if FCellAfronding = AValue then Exit;
FCellAfronding := AValue;
ExportCellBorderRadius:= AValue;
Invalidate;
end;


procedure THtmlTableDesigner.DeleteRow(ARow: Integer);
var
C, R: Integer;
begin
if FRowCount <= 1 then Exit;
if (ARow < 0) or (ARow >= FRowCount) then Exit;

if FEditing then
EndEdit(True);

for C := 0 to FColCount - 1 do
begin
FCells[C, ARow].Free;

for R := ARow to FRowCount - 2 do
FCells[C, R] := FCells[C, R + 1];

FCells[C, FRowCount - 1] := nil;
end;

Dec(FRowCount);
SetLength(FCells, FColCount, FRowCount);

if FSelectedRow >= FRowCount then
FSelectedRow := FRowCount - 1;

if FSelectedRow < 0 then
FSelectedRow := 0;

Invalidate;
end;

procedure THtmlTableDesigner.DeleteCol(ACol: Integer);
var
C, R: Integer;
begin
if FColCount <= 1 then Exit;
if (ACol < 0) or (ACol >= FColCount) then Exit;

if FEditing then
EndEdit(True);

for R := 0 to FRowCount - 1 do
begin
FCells[ACol, R].Free;
end;

for C := ACol to FColCount - 2 do
for R := 0 to FRowCount - 1 do
FCells[C, R] := FCells[C + 1, R];

for R := 0 to FRowCount - 1 do
FCells[FColCount - 1, R] := nil;

Dec(FColCount);
SetLength(FCells, FColCount, FRowCount);

if FSelectedCol >= FColCount then
FSelectedCol := FColCount - 1;

if FSelectedCol < 0 then
FSelectedCol := 0;

Invalidate;
end;

procedure THtmlTableDesigner.InsertImageInSelectedCell;
var
Dlg: TOpenPictureDialog;
FullFileName: string;
HtmlImagePath: string;
C, R: Integer;
begin
if SelectionMode <> smCell then Exit;

C := SelectedCol;
R := SelectedRow;

if (C < 0) or (R < 0) then Exit;
if (C >= ColCount) or (R >= RowCount) then Exit;

Dlg := TOpenPictureDialog.Create(nil);
try
Dlg.Title := 'Afbeelding kiezen';
Dlg.Filter :=
'Afbeeldingen|*.png;*.jpg;*.jpeg;*.bmp;*.gif|Alle bestanden|*.*';

if Dlg.Execute then
begin
FullFileName := Dlg.FileName;

HtmlImagePath := CopyImageToProjectImages(FullFileName);
if HtmlImagePath = '' then Exit;

LoadCellImage(C, R, FullFileName);

Cells[C, R].ImageFile := HtmlImagePath;

Invalidate;
DoChange;
end;

finally
Dlg.Free;
end;
end;

procedure THtmlTableDesigner.RemoveImageFromSelection;
var
L, T, R, B: Integer;
C, Row: Integer;
begin
GetSelectionBounds(L, T, R, B);

for C := L to R do
for Row := T to B do
begin
FCells[C, Row].ShowImage := False;
FCells[C, Row].ImageFile := '';
end;

Invalidate;
DoChange;   // ← ook hier!
end;
// helper voor LoadFrom
function IntegerToFontStyles(AValue: Integer): TFontStyles;
begin
Result := [];

if (AValue and 1) <> 0 then
Include(Result, fsBold);

if (AValue and 2) <> 0 then
Include(Result, fsItalic);

if (AValue and 4) <> 0 then
Include(Result, fsUnderline);

if (AValue and 8) <> 0 then
Include(Result, fsStrikeOut);
end;

// helper voor SaveTo (symmetrisch met IntegerToFontStyles)
function FontStylesToInteger(const AStyles: TFontStyles): Integer;
begin
Result := 0;

if fsBold in AStyles then
Inc(Result, 1);

if fsItalic in AStyles then
Inc(Result, 2);

if fsUnderline in AStyles then
Inc(Result, 4);

if fsStrikeOut in AStyles then
Inc(Result, 8);
end;

// Gedeelde HTD-sectienamen, gebruikt door zowel SaveToHTD als
// LoadFromHTD. Op één plaats gedefinieerd zodat beide routines
// nooit uit elkaar kunnen lopen door een verkeerd getypte naam.
const
HTD_SecTable      = 'Table';
HTD_SecColWidths  = 'ColWidths';
HTD_SecRowHeights = 'RowHeights';
HTD_SecTextBlocks = 'TextBlocks';
HTD_PrefixCell      = 'Cell_';
HTD_PrefixTextBlock = 'TextBlock_';

function EncodeHTDText(const S: string): string;
begin
Result := S;
Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
end;

function DecodeHTDText(const S: string): string;
var
I, Len: Integer;
SB: TStringBuilder;
begin
// ----------------------------------------------------------------
// BELANGRIJK: dit moet één enkele links-naar-rechts scan zijn, geen
// twee losse StringReplace-aanroepen na elkaar.
//
// EncodeHTDText verdubbelt eerst ALLE backslashes en vervangt pas
// daarna regeleindes door '\n'. Het resultaat is dat élke backslash
// in de gecodeerde tekst altijd gevolgd wordt door ofwel nog een
// backslash (een letterlijke '\' uit de oorspronkelijke tekst) of
// door de letter 'n' (een regeleinde). Er komt in gecodeerde tekst
// dus nooit een backslash voor die niet bij zo'n paar hoort.
//
// De oude implementatie deed dit in twee aparte stappen:
//   1) alle '\n'-paren -> regeleinde
//   2) alle '\\'-paren -> '\'
// Bij tekst die toevallig een letterlijke backslash gevolgd door de
// letter 'n' bevat (bv. "C:\naam"), werd die na het coderen tot
// "C:\\naam", en de oude decoder herkende daarin per ongeluk eerst
// een '\n'-paar (de tweede backslash + de 'n'), wat de tekst
// corrumpeerde tot "C:\" + regeleinde + "aam".
//
// Door van links naar rechts te scannen en telkens één backslash
// samen met precies het daaropvolgende teken te verwerken, wordt
// dit ondubbelzinnig en exact de inverse van EncodeHTDText.
// ----------------------------------------------------------------

Len := Length(S);

SB := TStringBuilder.Create;
try
I := 1;

while I <= Len do
begin
// Alleen een geldig escape-paar consumeren als de backslash
// ook echt gevolgd wordt door 'n' of nog een backslash. In elk
// ander geval (inclusief een backslash als allerlaatste teken)
// wordt gewoon het huidige teken overgenomen en één positie
// opgeschoven - dit dekt ook oude/onverwachte data veilig af.
if (S[I] = '\') and (I < Len) and
((S[I + 1] = 'n') or (S[I + 1] = '\')) then
begin
if S[I + 1] = 'n' then
SB.Append(LineEnding)
else
SB.Append('\');

Inc(I, 2);
end
else
begin
SB.Append(S[I]);
Inc(I);
end;
end;

Result := SB.ToString;
finally
SB.Free;
end;
end;

procedure THtmlTableDesigner.SaveToHTD(
const AFileName: string);
var
Ini: TIniFile;
C, R, I, L: Integer;
Cell: THtmlCell;
B: TDesignerTextBlock;
TextLink: TDesignerTextLink;
StyleRun: TDesignerStyleRun;
ColorRun: TDesignerColorRun;
S: string;
LinkSection: string;
StyleRunSection: string;
ColorRunSection: string;
Sections: TStringList;
TempFileName: string;

begin
// ============================================================
// Er wordt eerst naar een tijdelijk bestand geschreven en pas
// op het einde over het doelbestand heen hernoemd. Zo blijft
// een al bestaand .htd-bestand intact als het opslaan halverwege
// faalt (schijf vol, geen schrijfrechten, exception, ...).
// ============================================================

TempFileName := AFileName + '.tmp';

if FileExists(TempFileName) then
DeleteFile(TempFileName);

Ini := TIniFile.Create(TempFileName);
try
// CacheUpdates: alle Write*-aanroepen gaan naar het geheugen-
// beeld van de ini; er wordt pas naar schijf geschreven bij de
// expliciete UpdateFile hieronder. Zonder dit schrijft TIniFile
// bij ELKE afzonderlijke Write* het volledige bestand opnieuw,
// wat bij een tabel met veel cellen en tekstblokken duizenden
// nodeloze schijfschrijvingen betekent.
Ini.CacheUpdates := True;

// ============================================================
// Algemene tabelinstellingen
// ============================================================

Ini.WriteInteger(HTD_SecTable, 'Cols', FColCount);
Ini.WriteInteger(HTD_SecTable, 'Rows', FRowCount);
Ini.WriteInteger(HTD_SecTable, 'DefaultColWidth', FDefaultColWidth);
Ini.WriteInteger(HTD_SecTable, 'DefaultRowHeight', FDefaultRowHeight);
Ini.WriteInteger(HTD_SecTable, 'GridColor', FGridColor);
Ini.WriteInteger(HTD_SecTable, 'GridLineWidth', FGridLineWidth);
Ini.WriteBool(HTD_SecTable, 'ShowGrid', FShowGrid);
Ini.WriteBool(HTD_SecTable, 'ShowLayoutGrid', FShowLayoutGrid);
Ini.WriteInteger(HTD_SecTable, 'LayoutGridSize', FLayoutGridSize);
Ini.WriteInteger(HTD_SecTable, 'LayoutGridColor', FLayoutGridColor);
Ini.WriteInteger(HTD_SecTable, 'SelectionColor', FSelectionColor);
Ini.WriteInteger(HTD_SecTable, 'HtmlBgColor', FHtmlBgColor);
Ini.WriteBool(HTD_SecTable, 'AutoStretchTable', FAutoStretchTable);
Ini.WriteBool(HTD_SecTable, 'AutoFitTable', FAutoFitTable);
Ini.WriteInteger(HTD_SecTable, 'CellAfronding', FCellAfronding);


// ============================================================
// Headers
// ============================================================

Ini.WriteBool(HTD_SecTable, 'ShowHeaders', FShowHeaders);
Ini.WriteInteger(HTD_SecTable, 'HeaderHeight', FHeaderHeight);
Ini.WriteInteger(HTD_SecTable, 'HeaderWidth', FHeaderWidth);
Ini.WriteInteger(HTD_SecTable, 'HeaderColor', FHeaderColor);
Ini.WriteInteger(HTD_SecTable, 'HeaderFontColor', FHeaderFontColor);


// ============================================================
// Pagina
// ============================================================

Ini.WriteBool(HTD_SecTable, 'PageEnabled', FPageEnabled);
Ini.WriteInteger(HTD_SecTable, 'PageWidth', FPageWidth);
Ini.WriteInteger(HTD_SecTable, 'PageHeight', FPageHeight);
Ini.WriteInteger(HTD_SecTable, 'PageMarginX', FPageMarginX);
Ini.WriteInteger(HTD_SecTable, 'PageMarginY', FPageMarginY);
Ini.WriteInteger(HTD_SecTable, 'TableOffsetX', FTableOffsetX);
Ini.WriteInteger(HTD_SecTable, 'TableOffsetY', FTableOffsetY);


// ============================================================
// Linialen
// ============================================================

Ini.WriteBool(HTD_SecTable, 'ShowPageRulers', FShowPageRulers);
Ini.WriteInteger(HTD_SecTable, 'RulerSize', FRulerSize);
Ini.WriteInteger(HTD_SecTable, 'RulerStep', FRulerStep);
Ini.WriteFloat(HTD_SecTable, 'PixelsPerMM', FPixelsPerMM);


// ============================================================
// Export - tabel
// ============================================================

Ini.WriteInteger(HTD_SecTable, 'ExportTableBgColor', FExportTableBgColor);
Ini.WriteInteger(HTD_SecTable, 'ExportTableBorderColor', FExportTableBorderColor);
Ini.WriteInteger(HTD_SecTable, 'ExportTableBorderWidth', FExportTableBorderWidth);
Ini.WriteInteger(HTD_SecTable, 'ExportTableBorderRadius', FExportTableBorderRadius);
Ini.WriteInteger(HTD_SecTable, 'ExportTableBorderStyle', Ord(FExportTableBorderStyle));


// ============================================================
// Export - cellen
// ============================================================

Ini.WriteInteger(HTD_SecTable, 'ExportCellBorderColor', FExportCellBorderColor);
Ini.WriteInteger(HTD_SecTable, 'ExportCellBorderRadius', FExportCellBorderRadius);
Ini.WriteInteger(HTD_SecTable, 'ExportCellPadding', FExportCellPadding);


// ============================================================
// Kolombreedtes / Rijhoogtes
// ============================================================

Ini.EraseSection(HTD_SecColWidths);

for C := 0 to FColCount - 1 do
Ini.WriteInteger(HTD_SecColWidths, IntToStr(C), FColWidths[C]);

Ini.EraseSection(HTD_SecRowHeights);

for R := 0 to FRowCount - 1 do
Ini.WriteInteger(HTD_SecRowHeights, IntToStr(R), FRowHeights[R]);


// ============================================================
// Oude Cell_* en TextBlock_*-secties (incl. hyperlinksecties
// TextBlock_x_Link_y) in één keer verwijderen. Dit voorkomt dat
// er bij een kleiner geworden tabel of minder tekstblokken oude
// secties blijven rondslingeren in het HTD-bestand.
// ============================================================

Sections := TStringList.Create;
try
Ini.ReadSections(Sections);

for I := Sections.Count - 1 downto 0 do
begin
S := Sections[I];

if (Pos(HTD_PrefixCell, S) = 1) or (Pos(HTD_PrefixTextBlock, S) = 1) then
Ini.EraseSection(S);
end;
finally
Sections.Free;
end;


// ============================================================
// Cellen
// ============================================================

for C := 0 to FColCount - 1 do
begin
for R := 0 to FRowCount - 1 do
begin
Cell := FCells[C, R];

if not Assigned(Cell) then
Continue;

S := HTD_PrefixCell + IntToStr(C) + '_' + IntToStr(R);

// --------------------------------------------------------
// Cel - tekst
// --------------------------------------------------------

Ini.WriteString(S, 'Text', EncodeHTDText(Cell.Text));
Ini.WriteString(S, 'BackupText', EncodeHTDText(Cell.BackupText));
Ini.WriteBool(S, 'BackupValid', Cell.BackupValid);
Ini.WriteString(S, 'HintText', EncodeHTDText(Cell.HintText));

// --------------------------------------------------------
// Cel - opmaak
// --------------------------------------------------------

Ini.WriteInteger(S, 'BgColor', Cell.BgColor);
Ini.WriteInteger(S, 'FontColor', Cell.FontColor);
Ini.WriteInteger(S, 'Align', Ord(Cell.Align));
Ini.WriteInteger(S, 'FontSize', Cell.FontSize);
Ini.WriteInteger(S, 'FontStyles', FontStylesToInteger(Cell.FontStyles));

// --------------------------------------------------------
// Cel - kader
// --------------------------------------------------------

Ini.WriteBool(S, 'Border', Cell.Border);
Ini.WriteInteger(S, 'BorderStyle', Ord(Cell.BorderStyle));

// --------------------------------------------------------
// Cel - mergegegevens
// --------------------------------------------------------

Ini.WriteInteger(S, 'ColSpan', Cell.ColSpan);
Ini.WriteInteger(S, 'RowSpan', Cell.RowSpan);
Ini.WriteBool(S, 'Merged', Cell.Merged);
Ini.WriteInteger(S, 'MasterCol', Cell.MasterCol);
Ini.WriteInteger(S, 'MasterRow', Cell.MasterRow);

// --------------------------------------------------------
// Cel - afbeelding
// --------------------------------------------------------

Ini.WriteBool(S, 'ShowImage', Cell.ShowImage);
Ini.WriteString(S, 'ImageFile', Cell.ImageFile);
Ini.WriteInteger(S, 'ImageAlign', Ord(Cell.ImageAlign));
Ini.WriteBool(S, 'ImageStretch', Cell.ImageStretch);
Ini.WriteInteger(S, 'ImageSizeMode', Ord(Cell.ImageSizeMode));

// --------------------------------------------------------
// Cel - teksthyperlink
// --------------------------------------------------------

Ini.WriteBool(S, 'IsLink', Cell.IsLink);
Ini.WriteString(S, 'LinkURL', EncodeHTDText(Cell.LinkURL));
Ini.WriteString(S, 'LinkText', EncodeHTDText(Cell.LinkText));

// --------------------------------------------------------
// Cel - afbeeldingshyperlink
// --------------------------------------------------------

Ini.WriteBool(S, 'ImageIsLink', Cell.ImageIsLink);
Ini.WriteString(S, 'ImageLinkURL', EncodeHTDText(Cell.ImageLinkURL));
end;
end;


// ============================================================
// TextBlocks
// ============================================================

Ini.EraseSection(HTD_SecTextBlocks);

if Assigned(FTextBlocks) then
Ini.WriteInteger(HTD_SecTextBlocks, 'Count', FTextBlocks.Count)
else
Ini.WriteInteger(HTD_SecTextBlocks, 'Count', 0);

if Assigned(FTextBlocks) then
begin
for I := 0 to FTextBlocks.Count - 1 do
begin
B := TDesignerTextBlock(FTextBlocks[I]);

if not Assigned(B) then
Continue;

S := HTD_PrefixTextBlock + IntToStr(I);

// --------------------------------------------------------
// TextBlock - positie
// --------------------------------------------------------

Ini.WriteInteger(S, 'Left', B.Rect.Left);
Ini.WriteInteger(S, 'Top', B.Rect.Top);
Ini.WriteInteger(S, 'Right', B.Rect.Right);
Ini.WriteInteger(S, 'Bottom', B.Rect.Bottom);

// --------------------------------------------------------
// TextBlock - tekst
// --------------------------------------------------------

Ini.WriteString(S, 'Text', EncodeHTDText(B.Text));

// --------------------------------------------------------
// TextBlock - oude single hyperlink
//
// Voorlopig behouden voor compatibiliteit met oudere
// HTD-bestanden.
// --------------------------------------------------------

Ini.WriteBool(S, 'IsLink', B.IsLink);
Ini.WriteString(S, 'LinkURL', EncodeHTDText(B.LinkURL));
Ini.WriteInteger(S, 'LinkStart', B.LinkStart);
Ini.WriteInteger(S, 'LinkLength', B.LinkLength);

// --------------------------------------------------------
// TextBlock - multiple hyperlinks
// --------------------------------------------------------

if Assigned(B.Links) then
begin
Ini.WriteInteger(S, 'LinkCount', B.Links.Count);

for L := 0 to B.Links.Count - 1 do
begin
TextLink := TDesignerTextLink(B.Links[L]);

if not Assigned(TextLink) then
Continue;

LinkSection := S + '_Link_' + IntToStr(L);

Ini.WriteInteger(LinkSection, 'StartPos', TextLink.StartPos);
Ini.WriteInteger(LinkSection, 'Length', TextLink.Length);
Ini.WriteString(LinkSection, 'URL', EncodeHTDText(TextLink.URL));
end;
end
else
Ini.WriteInteger(S, 'LinkCount', 0);

// --------------------------------------------------------
// TextBlock - bold/italic/underline per tekstbereik
// --------------------------------------------------------

if Assigned(B.StyleRuns) then
begin
Ini.WriteInteger(S, 'StyleRunCount', B.StyleRuns.Count);

for L := 0 to B.StyleRuns.Count - 1 do
begin
StyleRun := TDesignerStyleRun(B.StyleRuns[L]);

if not Assigned(StyleRun) then
Continue;

StyleRunSection := S + '_Style_' + IntToStr(L);

Ini.WriteInteger(StyleRunSection, 'StartPos', StyleRun.StartPos);
Ini.WriteInteger(StyleRunSection, 'Length', StyleRun.Length);
Ini.WriteInteger(
StyleRunSection,
'Styles',
FontStylesToInteger(StyleRun.Styles)
);
end;
end
else
Ini.WriteInteger(S, 'StyleRunCount', 0);

// --------------------------------------------------------
// TextBlock - tekstkleur per tekstbereik
// --------------------------------------------------------

if Assigned(B.ColorRuns) then
begin
Ini.WriteInteger(S, 'ColorRunCount', B.ColorRuns.Count);

for L := 0 to B.ColorRuns.Count - 1 do
begin
ColorRun := TDesignerColorRun(B.ColorRuns[L]);

if not Assigned(ColorRun) then
Continue;

ColorRunSection := S + '_Color_' + IntToStr(L);

Ini.WriteInteger(ColorRunSection, 'StartPos', ColorRun.StartPos);
Ini.WriteInteger(ColorRunSection, 'Length', ColorRun.Length);
Ini.WriteInteger(ColorRunSection, 'Color', ColorRun.Color);
end;
end
else
Ini.WriteInteger(S, 'ColorRunCount', 0);

// --------------------------------------------------------
// TextBlock - tekstuitlijning / font
// --------------------------------------------------------

Ini.WriteInteger(S, 'Alignment', Ord(B.Alignment));
Ini.WriteInteger(S, 'FontSize', B.FontSize);
Ini.WriteInteger(S, 'FontColor', B.FontColor);
Ini.WriteInteger(S, 'FontStyles', FontStylesToInteger(B.FontStyles));
Ini.WriteInteger(S, 'LineHeight', B.LineHeight);

// --------------------------------------------------------
// TextBlock - achtergrond
// --------------------------------------------------------

Ini.WriteInteger(S, 'BgColor', B.BgColor);
Ini.WriteBool(S, 'Transparent', B.Transparent);

// --------------------------------------------------------
// TextBlock - kader
// --------------------------------------------------------

Ini.WriteInteger(S, 'BorderColor', B.BorderColor);
Ini.WriteInteger(S, 'BorderWidth', B.BorderWidth);
Ini.WriteInteger(S, 'BorderStyle', Ord(B.BorderStyle));
Ini.WriteInteger(S, 'BorderRadius', B.BorderRadius);

// --------------------------------------------------------
// TextBlock - layout
// --------------------------------------------------------

Ini.WriteInteger(S, 'Padding', B.Padding);
Ini.WriteBool(S, 'WordWrap', B.WordWrap);

// --------------------------------------------------------
// TextBlock - selectie
//
// Dit is tijdelijke editorstatus en wordt bewust niet
// als actieve selectie opgeslagen.
// --------------------------------------------------------

Ini.WriteBool(S, 'Selected', False);
end;
end;

// Eén enkele, volledige schrijfactie naar het tijdelijke bestand.
Ini.UpdateFile;
finally
Ini.Free;
end;

// ============================================================
// Pas nu, na een geslaagde schrijfactie naar het tijdelijke
// bestand, het doelbestand vervangen. Trad er hierboven een
// exception op (voor UpdateFile klaar was), dan is er nooit
// naar schijf geschreven en komen we hier niet eens aan; een
// eventueel bestaand AFileName blijft dan gewoon ongewijzigd.
// ============================================================

try
if FileExists(AFileName) then
DeleteFile(AFileName);

if not RenameFile(TempFileName, AFileName) then
raise Exception.CreateFmt(
'Kan HTD-bestand niet wegschrijven naar "%s".',
[AFileName]
);
except
if FileExists(TempFileName) then
DeleteFile(TempFileName);
raise;
end;
end;


procedure THtmlTableDesigner.LoadFromHTD(
const AFileName: string);
var
Ini: TIniFile;
C, R, I, L, Count, LinkCount, StyleRunCount, ColorRunCount: Integer;
Cell: THtmlCell;
S, LinkSection, StyleRunSection, ColorRunSection: string;
B: TDesignerTextBlock;
TextLink: TDesignerTextLink;
StyleRun: TDesignerStyleRun;
ColorRun: TDesignerColorRun;

// ------------------------------------------------------------
// "New*"-variabelen: hierin wordt de volledige nieuwe toestand
// opgebouwd. Pas als alles - inclusief elke cel en elk
// tekstblok - zonder fouten is ingelezen, wordt deze toestand
// in één keer overgenomen in de F*-velden van het component.
//
// Faalt het laden halverwege (corrupt bestand, een cel met een
// ongeldige waarde, te weinig geheugen, ...), dan is er nog
// niets aan de huidige, zichtbare tabel gewijzigd: de exception
// wordt gewoon doorgegeven aan de aanroeper.
// ------------------------------------------------------------

NewColCount, NewRowCount: Integer;
NewDefaultColWidth, NewDefaultRowHeight: Integer;
NewGridColor: TColor;
NewGridLineWidth: Integer;
NewShowGrid, NewShowLayoutGrid: Boolean;
NewLayoutGridSize: Integer;
NewLayoutGridColor: TColor;
NewSelectionColor: TColor;
NewHtmlBgColor: TColor;
NewAutoStretchTable, NewAutoFitTable: Boolean;
NewCellAfronding: Integer;

NewShowHeaders: Boolean;
NewHeaderHeight, NewHeaderWidth: Integer;
NewHeaderColor, NewHeaderFontColor: TColor;

NewPageEnabled: Boolean;
NewPageWidth, NewPageHeight: Integer;
NewPageMarginX, NewPageMarginY: Integer;
NewTableOffsetX, NewTableOffsetY: Integer;

NewShowPageRulers: Boolean;
NewRulerSize, NewRulerStep: Integer;
NewPixelsPerMM: Double;

NewExportTableBgColor, NewExportTableBorderColor: TColor;
NewExportTableBorderWidth, NewExportTableBorderRadius: Integer;
NewExportTableBorderStyle: TCellBorderStyle;

NewExportCellBorderColor: TColor;
NewExportCellBorderRadius, NewExportCellPadding: Integer;

NewColWidths, NewRowHeights: array of Integer;
NewCells: array of array of THtmlCell;
NewTextBlocks: TObjectList;

begin
if not FileExists(AFileName) then
Exit;

// TObjectList is geen managed type: expliciet op nil zetten,
// zodat de opruimcode in het except-blok hieronder altijd veilig
// is, ook als de exception optreedt voordat de lijst is aangemaakt.
NewTextBlocks := nil;

Ini := TIniFile.Create(AFileName);
try
// ============================================================
// Algemene tabelinstellingen
// ============================================================

NewColCount := Ini.ReadInteger(HTD_SecTable, 'Cols', 1);
NewRowCount := Ini.ReadInteger(HTD_SecTable, 'Rows', 1);

if NewColCount < 1 then
NewColCount := 1;

if NewRowCount < 1 then
NewRowCount := 1;

NewDefaultColWidth := Ini.ReadInteger(HTD_SecTable, 'DefaultColWidth', 100);
NewDefaultRowHeight := Ini.ReadInteger(HTD_SecTable, 'DefaultRowHeight', 28);
NewGridColor := Ini.ReadInteger(HTD_SecTable, 'GridColor', clSilver);
NewGridLineWidth := Ini.ReadInteger(HTD_SecTable, 'GridLineWidth', 1);
NewShowGrid := Ini.ReadBool(HTD_SecTable, 'ShowGrid', True);
NewShowLayoutGrid := Ini.ReadBool(HTD_SecTable, 'ShowLayoutGrid', False);

NewLayoutGridSize := Ini.ReadInteger(HTD_SecTable, 'LayoutGridSize', 10);

if NewLayoutGridSize < 2 then
NewLayoutGridSize := 2;

NewLayoutGridColor := Ini.ReadInteger(HTD_SecTable, 'LayoutGridColor', clSilver);
NewSelectionColor := Ini.ReadInteger(HTD_SecTable, 'SelectionColor', clRed);
NewHtmlBgColor := Ini.ReadInteger(HTD_SecTable, 'HtmlBgColor', clWhite);
NewAutoStretchTable := Ini.ReadBool(HTD_SecTable, 'AutoStretchTable', False);
NewAutoFitTable := Ini.ReadBool(HTD_SecTable, 'AutoFitTable', False);
NewCellAfronding := Ini.ReadInteger(HTD_SecTable, 'CellAfronding', 1);


// ============================================================
// Headers
// ============================================================

NewShowHeaders := Ini.ReadBool(HTD_SecTable, 'ShowHeaders', True);
NewHeaderHeight := Ini.ReadInteger(HTD_SecTable, 'HeaderHeight', 22);
NewHeaderWidth := Ini.ReadInteger(HTD_SecTable, 'HeaderWidth', 32);
NewHeaderColor := Ini.ReadInteger(HTD_SecTable, 'HeaderColor', clBtnFace);
NewHeaderFontColor := Ini.ReadInteger(HTD_SecTable, 'HeaderFontColor', clBlack);


// ============================================================
// Pagina
// ============================================================

NewPageEnabled := Ini.ReadBool(HTD_SecTable, 'PageEnabled', False);
NewPageWidth := Ini.ReadInteger(HTD_SecTable, 'PageWidth', 794);
NewPageHeight := Ini.ReadInteger(HTD_SecTable, 'PageHeight', 1123);

if NewPageWidth < 1 then
NewPageWidth := 794;

if NewPageHeight < 1 then
NewPageHeight := 1123;

NewPageMarginX := Ini.ReadInteger(HTD_SecTable, 'PageMarginX', 40);
NewPageMarginY := Ini.ReadInteger(HTD_SecTable, 'PageMarginY', 40);
NewTableOffsetX := Ini.ReadInteger(HTD_SecTable, 'TableOffsetX', 40);
NewTableOffsetY := Ini.ReadInteger(HTD_SecTable, 'TableOffsetY', 40);


// ============================================================
// Linialen
// ============================================================

NewShowPageRulers := Ini.ReadBool(HTD_SecTable, 'ShowPageRulers', True);
NewRulerSize := Ini.ReadInteger(HTD_SecTable, 'RulerSize', 20);
NewRulerStep := Ini.ReadInteger(HTD_SecTable, 'RulerStep', 10);
NewPixelsPerMM := Ini.ReadFloat(HTD_SecTable, 'PixelsPerMM', 3.7795275591);


// ============================================================
// Export - tabel
// ============================================================

NewExportTableBgColor := Ini.ReadInteger(HTD_SecTable, 'ExportTableBgColor', clWhite);
NewExportTableBorderColor := Ini.ReadInteger(HTD_SecTable, 'ExportTableBorderColor', clBlack);
NewExportTableBorderWidth := Ini.ReadInteger(HTD_SecTable, 'ExportTableBorderWidth', 1);
NewExportTableBorderRadius := Ini.ReadInteger(HTD_SecTable, 'ExportTableBorderRadius', 0);

NewExportTableBorderStyle :=
TCellBorderStyle(
Ini.ReadInteger(HTD_SecTable, 'ExportTableBorderStyle', Ord(cbsSolid))
);


// ============================================================
// Export - cellen
// ============================================================

NewExportCellBorderColor := Ini.ReadInteger(HTD_SecTable, 'ExportCellBorderColor', clBlack);
NewExportCellBorderRadius := Ini.ReadInteger(HTD_SecTable, 'ExportCellBorderRadius', 1);
NewExportCellPadding := Ini.ReadInteger(HTD_SecTable, 'ExportCellPadding', 0);


// ============================================================
// Cellen, afmetingen en tekstblokken volledig opbouwen in de
// New*-structuren. Alles hierbinnen dat misgaat (corrupte
// waarde, te grote afmetingen, beschadigd bestand, ...) wordt
// hieronder opgevangen: wat al is aangemaakt, wordt weer
// vrijgegeven en de exception gaat door naar de aanroeper,
// zonder dat de huidige tabel is aangeraakt.
// ============================================================

try
SetLength(NewColWidths, NewColCount);

for C := 0 to NewColCount - 1 do
NewColWidths[C] :=
Ini.ReadInteger(HTD_SecColWidths, IntToStr(C), NewDefaultColWidth);

SetLength(NewRowHeights, NewRowCount);

for R := 0 to NewRowCount - 1 do
NewRowHeights[R] :=
Ini.ReadInteger(HTD_SecRowHeights, IntToStr(R), NewDefaultRowHeight);


// --------------------------------------------------------
// Cellen aanmaken en laden
// --------------------------------------------------------

SetLength(NewCells, NewColCount, NewRowCount);

for C := 0 to NewColCount - 1 do
for R := 0 to NewRowCount - 1 do
NewCells[C, R] := THtmlCell.Create;

for C := 0 to NewColCount - 1 do
begin
for R := 0 to NewRowCount - 1 do
begin
Cell := NewCells[C, R];

S := HTD_PrefixCell + IntToStr(C) + '_' + IntToStr(R);

// ------------------------------------------------------
// Cel - tekst
// ------------------------------------------------------

Cell.Text := DecodeHTDText(Ini.ReadString(S, 'Text', ''));
Cell.BackupText := DecodeHTDText(Ini.ReadString(S, 'BackupText', ''));
Cell.BackupValid := Ini.ReadBool(S, 'BackupValid', False);
Cell.HintText := DecodeHTDText(Ini.ReadString(S, 'HintText', ''));

// ------------------------------------------------------
// Cel - opmaak
// ------------------------------------------------------

Cell.BgColor := Ini.ReadInteger(S, 'BgColor', clWhite);
Cell.FontColor := Ini.ReadInteger(S, 'FontColor', clBlack);

Cell.Align :=
TCellAlign(Ini.ReadInteger(S, 'Align', Ord(caLeft)));

Cell.FontSize := Ini.ReadInteger(S, 'FontSize', 10);

Cell.FontStyles :=
IntegerToFontStyles(Ini.ReadInteger(S, 'FontStyles', 0));

// ------------------------------------------------------
// Cel - kader
// ------------------------------------------------------

Cell.Border := Ini.ReadBool(S, 'Border', True);

Cell.BorderStyle :=
TCellBorderStyle(Ini.ReadInteger(S, 'BorderStyle', Ord(cbsSolid)));

// ------------------------------------------------------
// Cel - mergegegevens
// ------------------------------------------------------

Cell.ColSpan := Ini.ReadInteger(S, 'ColSpan', 1);
Cell.RowSpan := Ini.ReadInteger(S, 'RowSpan', 1);
Cell.Merged := Ini.ReadBool(S, 'Merged', False);
Cell.MasterCol := Ini.ReadInteger(S, 'MasterCol', -1);
Cell.MasterRow := Ini.ReadInteger(S, 'MasterRow', -1);

// ------------------------------------------------------
// Cel - afbeelding
// ------------------------------------------------------

Cell.ShowImage := Ini.ReadBool(S, 'ShowImage', False);
Cell.ImageFile := Ini.ReadString(S, 'ImageFile', '');

Cell.ImageAlign :=
TImageAlign(Ini.ReadInteger(S, 'ImageAlign', Ord(iaCenter)));

Cell.ImageStretch := Ini.ReadBool(S, 'ImageStretch', False);

if Ini.ValueExists(S, 'ImageSizeMode') then
begin
Cell.ImageSizeMode :=
TImageSizeMode(Ini.ReadInteger(S, 'ImageSizeMode', Ord(ismOriginal)));
end
else
begin
// Compatibiliteit met oudere HTD-bestanden
if Cell.ImageStretch then
Cell.ImageSizeMode := ismStretch
else
Cell.ImageSizeMode := ismOriginal;
end;

// ------------------------------------------------------
// Cel - teksthyperlink
// ------------------------------------------------------

Cell.IsLink := Ini.ReadBool(S, 'IsLink', False);
Cell.LinkURL := DecodeHTDText(Ini.ReadString(S, 'LinkURL', ''));
Cell.LinkText := DecodeHTDText(Ini.ReadString(S, 'LinkText', ''));

// ------------------------------------------------------
// Cel - afbeeldingshyperlink
// ------------------------------------------------------

Cell.ImageIsLink := Ini.ReadBool(S, 'ImageIsLink', False);
Cell.ImageLinkURL := DecodeHTDText(Ini.ReadString(S, 'ImageLinkURL', ''));

// Zonder afbeelding kan geen afbeeldingslink actief zijn.
if not Cell.ShowImage then
begin
Cell.ImageIsLink := False;
Cell.ImageLinkURL := '';
end;

// ------------------------------------------------------
// Cel - afbeelding opnieuw laden
// ------------------------------------------------------

Cell.Picture.Clear;

if Cell.ShowImage and
(Trim(Cell.ImageFile) <> '') and
FileExists(Cell.ImageFile) then
begin
try
Cell.Picture.LoadFromFile(Cell.ImageFile);
except
// Beschadigd of ongeldig afbeeldingsbestand.
Cell.Picture.Clear;
end;
end;
end;
end;


// --------------------------------------------------------
// TextBlocks aanmaken en laden
// --------------------------------------------------------

NewTextBlocks := TObjectList.Create(True);

Count := Ini.ReadInteger(HTD_SecTextBlocks, 'Count', 0);

if Count < 0 then
Count := 0;

for I := 0 to Count - 1 do
begin
S := HTD_PrefixTextBlock + IntToStr(I);

B := TDesignerTextBlock.Create;

try
// ------------------------------------------------------
// TextBlock - positie
// ------------------------------------------------------

B.Rect := Rect(
Ini.ReadInteger(S, 'Left', 0),
Ini.ReadInteger(S, 'Top', 0),
Ini.ReadInteger(S, 'Right', 160),
Ini.ReadInteger(S, 'Bottom', 60)
);

// ------------------------------------------------------
// TextBlock - tekst
// ------------------------------------------------------

B.Text := DecodeHTDText(Ini.ReadString(S, 'Text', ''));

// ------------------------------------------------------
// TextBlock - oude single hyperlink
//
// Deze blijven we lezen voor compatibiliteit met
// oudere HTD-bestanden.
// ------------------------------------------------------

B.IsLink := Ini.ReadBool(S, 'IsLink', False);
B.LinkURL := DecodeHTDText(Ini.ReadString(S, 'LinkURL', ''));
B.LinkStart := Ini.ReadInteger(S, 'LinkStart', -1);
B.LinkLength := Ini.ReadInteger(S, 'LinkLength', 0);

if Trim(B.LinkURL) = '' then
B.IsLink := False;

// ------------------------------------------------------
// TextBlock - nieuwe multiple hyperlinks
// ------------------------------------------------------

if Assigned(B.Links) then
B.Links.Clear;

LinkCount := Ini.ReadInteger(S, 'LinkCount', 0);

if LinkCount < 0 then
LinkCount := 0;

for L := 0 to LinkCount - 1 do
begin
LinkSection := S + '_Link_' + IntToStr(L);

TextLink := TDesignerTextLink.Create;

try
TextLink.StartPos := Ini.ReadInteger(LinkSection, 'StartPos', -1);
TextLink.Length := Ini.ReadInteger(LinkSection, 'Length', 0);
TextLink.URL := DecodeHTDText(Ini.ReadString(LinkSection, 'URL', ''));

// Alleen geldige hyperlinks toevoegen.
if (TextLink.StartPos >= 0) and
(TextLink.Length > 0) and
(Trim(TextLink.URL) <> '') then
begin
B.Links.Add(TextLink);
TextLink := nil;
end;
finally
TextLink.Free;
end;
end;

// ------------------------------------------------------
// Backward compatibility:
//
// Alleen voor oude HTD-bestanden waarin 'LinkCount'
// nog niet bestond.
//
// Oude IsLink / LinkURL / LinkStart / LinkLength gegevens
// worden dan omgezet naar de nieuwe Links-lijst.
//
// Belangrijk:
// Wanneer LinkCount wel bestaat en 0 is, betekent dit
// expliciet dat het TextBlock geen hyperlinks heeft.
// In dat geval mag de oude hyperlink niet opnieuw worden
// geactiveerd.
// ------------------------------------------------------

if not Ini.ValueExists(S, 'LinkCount') then
begin
if Assigned(B.Links) and
(B.Links.Count = 0) and
B.IsLink and
(B.LinkStart >= 0) and
(B.LinkLength > 0) and
(Trim(B.LinkURL) <> '') then
begin
TextLink := TDesignerTextLink.Create;

try
TextLink.StartPos := B.LinkStart;
TextLink.Length := B.LinkLength;
TextLink.URL := B.LinkURL;

B.Links.Add(TextLink);
TextLink := nil;
finally
TextLink.Free;
end;
end;
end;

// ------------------------------------------------------
// TextBlock - bold/italic/underline per tekstbereik
// ------------------------------------------------------

if Assigned(B.StyleRuns) then
B.StyleRuns.Clear;

StyleRunCount := Ini.ReadInteger(S, 'StyleRunCount', 0);

if StyleRunCount < 0 then
StyleRunCount := 0;

for L := 0 to StyleRunCount - 1 do
begin
StyleRunSection := S + '_Style_' + IntToStr(L);

StyleRun := TDesignerStyleRun.Create;

try
StyleRun.StartPos :=
Ini.ReadInteger(StyleRunSection, 'StartPos', -1);

StyleRun.Length :=
Ini.ReadInteger(StyleRunSection, 'Length', 0);

StyleRun.Styles :=
IntegerToFontStyles(
Ini.ReadInteger(StyleRunSection, 'Styles', 0)
);

// Alleen geldige bereiken toevoegen.
if (StyleRun.StartPos >= 0) and
(StyleRun.Length > 0) then
begin
B.StyleRuns.Add(StyleRun);
StyleRun := nil;
end;
finally
StyleRun.Free;
end;
end;

// ------------------------------------------------------
// TextBlock - tekstkleur per tekstbereik
// ------------------------------------------------------

if Assigned(B.ColorRuns) then
B.ColorRuns.Clear;

ColorRunCount := Ini.ReadInteger(S, 'ColorRunCount', 0);

if ColorRunCount < 0 then
ColorRunCount := 0;

for L := 0 to ColorRunCount - 1 do
begin
ColorRunSection := S + '_Color_' + IntToStr(L);

ColorRun := TDesignerColorRun.Create;

try
ColorRun.StartPos :=
Ini.ReadInteger(ColorRunSection, 'StartPos', -1);

ColorRun.Length :=
Ini.ReadInteger(ColorRunSection, 'Length', 0);

ColorRun.Color :=
Ini.ReadInteger(ColorRunSection, 'Color', clBlack);

// Alleen geldige bereiken toevoegen.
if (ColorRun.StartPos >= 0) and
(ColorRun.Length > 0) then
begin
B.ColorRuns.Add(ColorRun);
ColorRun := nil;
end;
finally
ColorRun.Free;
end;
end;

// ------------------------------------------------------
// TextBlock - uitlijning
// ------------------------------------------------------

B.Alignment :=
TAlignment(Ini.ReadInteger(S, 'Alignment', Ord(taLeftJustify)));

// ------------------------------------------------------
// TextBlock - lettertype
// ------------------------------------------------------

B.FontSize := Ini.ReadInteger(S, 'FontSize', 10);
B.FontColor := Ini.ReadInteger(S, 'FontColor', clBlack);

B.FontStyles :=
IntegerToFontStyles(Ini.ReadInteger(S, 'FontStyles', 0));

B.LineHeight := Ini.ReadInteger(S, 'LineHeight', 15);

// ------------------------------------------------------
// TextBlock - achtergrond
// ------------------------------------------------------

B.BgColor := Ini.ReadInteger(S, 'BgColor', clWhite);
B.Transparent := Ini.ReadBool(S, 'Transparent', True);

// ------------------------------------------------------
// TextBlock - kader
// ------------------------------------------------------

B.BorderColor := Ini.ReadInteger(S, 'BorderColor', clGray);
B.BorderWidth := Ini.ReadInteger(S, 'BorderWidth', 1);

B.BorderStyle :=
TCellBorderStyle(Ini.ReadInteger(S, 'BorderStyle', Ord(cbsSolid)));

B.BorderRadius := Ini.ReadInteger(S, 'BorderRadius', 0);

// ------------------------------------------------------
// TextBlock - layout
// ------------------------------------------------------

B.Padding := Ini.ReadInteger(S, 'Padding', 4);
B.WordWrap := Ini.ReadBool(S, 'WordWrap', True);

// ------------------------------------------------------
// TextBlock - selectie
// ------------------------------------------------------

B.Selected := False;

NewTextBlocks.Add(B);

// Vanaf hier is NewTextBlocks eigenaar van B.
B := nil;
finally
B.Free;
end;
end;
except
// ----------------------------------------------------------
// Iets is misgegaan tijdens het opbouwen van de nieuwe
// toestand. Alles wat al is aangemaakt in New* weer
// vrijgeven; de huidige, zichtbare tabel is op geen enkel
// moment aangeraakt en blijft dus intact.
// ----------------------------------------------------------

for C := Low(NewCells) to High(NewCells) do
for R := Low(NewCells[C]) to High(NewCells[C]) do
FreeAndNil(NewCells[C, R]);

SetLength(NewCells, 0, 0);

FreeAndNil(NewTextBlocks);

raise;
end;


// ============================================================
// Alles is zonder fouten ingelezen: nu pas de huidige toestand
// in één keer vervangen door de nieuwe.
// ============================================================

FreeCells;
FCells := NewCells;
NewCells := nil;

FreeAndNil(FTextBlocks);
FTextBlocks := NewTextBlocks;
NewTextBlocks := nil;

FColCount := NewColCount;
FRowCount := NewRowCount;
FColWidths := NewColWidths;
FRowHeights := NewRowHeights;

FDefaultColWidth := NewDefaultColWidth;
FDefaultRowHeight := NewDefaultRowHeight;
FGridColor := NewGridColor;
FGridLineWidth := NewGridLineWidth;
FShowGrid := NewShowGrid;
FShowLayoutGrid := NewShowLayoutGrid;
FLayoutGridSize := NewLayoutGridSize;
FLayoutGridColor := NewLayoutGridColor;
FSelectionColor := NewSelectionColor;
FHtmlBgColor := NewHtmlBgColor;
FAutoStretchTable := NewAutoStretchTable;
FAutoFitTable := NewAutoFitTable;
FCellAfronding := NewCellAfronding;

FShowHeaders := NewShowHeaders;
FHeaderHeight := NewHeaderHeight;
FHeaderWidth := NewHeaderWidth;
FHeaderColor := NewHeaderColor;
FHeaderFontColor := NewHeaderFontColor;

FPageEnabled := NewPageEnabled;
FPageWidth := NewPageWidth;
FPageHeight := NewPageHeight;
FPageMarginX := NewPageMarginX;
FPageMarginY := NewPageMarginY;
FTableOffsetX := NewTableOffsetX;
FTableOffsetY := NewTableOffsetY;

FShowPageRulers := NewShowPageRulers;
FRulerSize := NewRulerSize;
FRulerStep := NewRulerStep;
FPixelsPerMM := NewPixelsPerMM;

FExportTableBgColor := NewExportTableBgColor;
FExportTableBorderColor := NewExportTableBorderColor;
FExportTableBorderWidth := NewExportTableBorderWidth;
FExportTableBorderRadius := NewExportTableBorderRadius;
FExportTableBorderStyle := NewExportTableBorderStyle;

FExportCellBorderColor := NewExportCellBorderColor;
FExportCellBorderRadius := NewExportCellBorderRadius;
FExportCellPadding := NewExportCellPadding;


// ============================================================
// Selectiestatus herstellen
// ============================================================

FSelectedTextBlock := nil;

FSelectedCol := 0;
FSelectedRow := 0;

FSelStartCol := 0;
FSelStartRow := 0;

FSelEndCol := 0;
FSelEndRow := 0;

FSelectionMode := smCell;
FMultiSelecting := False;
FHasSelection := False;


// ============================================================
// Designer na volledig laden éénmaal actualiseren
// ============================================================

UpdateDesignerSize;
Invalidate;
DoChange;

finally
Ini.Free;
end;
end;


procedure THtmlTableDesigner.SaveToHTDStream(
AStream: TStream);
var
TempFile: string;
FS: TFileStream;
begin
if not Assigned(AStream) then
Exit;

TempFile :=
IncludeTrailingPathDelimiter(GetTempDir(False)) +
'temp_htd_' +
IntToStr(Random(MaxInt)) +
'.htd';

try
// Gebruik de centrale HTD save-routine
SaveToHTD(TempFile);

FS := TFileStream.Create(
TempFile,
fmOpenRead or fmShareDenyWrite
);
try
AStream.Size := 0;
AStream.Position := 0;

AStream.CopyFrom(
FS,
FS.Size
);

AStream.Position := 0;
finally
FS.Free;
end;

finally
if FileExists(TempFile) then
DeleteFile(TempFile);
end;
end;


procedure THtmlTableDesigner.LoadFromHTDStream(
AStream: TStream);
var
TempFile: string;
FS: TFileStream;
begin
if not Assigned(AStream) then
Exit;

TempFile :=
IncludeTrailingPathDelimiter(GetTempDir(False)) +
'temp_htd_' +
IntToStr(Random(MaxInt)) +
'.htd';

try
FS := TFileStream.Create(
TempFile,
fmCreate
);
try
AStream.Position := 0;

FS.CopyFrom(
AStream,
AStream.Size
);
finally
FS.Free;
end;

// Gebruik de centrale HTD load-routine
LoadFromHTD(TempFile);

finally
if FileExists(TempFile) then
DeleteFile(TempFile);
end;
end;

function ImageToDataURI(
APicture: TPicture;
const AFileName: string
): string;
var
MS: TMemoryStream;
RawData: RawByteString;
MimeType: string;
Ext: string;
begin
// ----------------------------------------------------------------
// Codeert een reeds geladen afbeelding (Cell.Picture) om naar een
// "data:" URI, zodat de geëxporteerde HTML geen padverwijzing naar
// een lokaal bestand meer bevat. Nodig omdat een absoluut pad zoals
// "C:\...\pijlUp.png" hoe dan ook niet werkt in een browser: het
// gebruikt backslashes in plaats van de vereiste forward slashes,
// en zelfs correct omgezet blijft het afhankelijk van diezelfde
// schijfletter/map op diezelfde machine - onbruikbaar zodra de HTML
// wordt doorgestuurd, op een andere pc geopend, of (straks) op
// Linux gegenereerd/bekeken wordt.
//
// Er wordt bewust vanuit Cell.Picture gewerkt (al in het geheugen)
// in plaats van het bestand op AFileName opnieuw te lezen: zo blijft
// de export ook werken wanneer het originele bestand ondertussen
// verplaatst of verwijderd is, zolang de afbeelding indertijd correct
// is ingeladen.
// ----------------------------------------------------------------

Result := '';

if not Assigned(APicture) or not Assigned(APicture.Graphic) then
Exit;

Ext := LowerCase(ExtractFileExt(AFileName));

if (Ext = '.jpg') or (Ext = '.jpeg') then
MimeType := 'image/jpeg'
else if Ext = '.gif' then
MimeType := 'image/gif'
else if Ext = '.bmp' then
MimeType := 'image/bmp'
else
// Standaard/fallback: ook wanneer de extensie ontbreekt of
// onbekend is. Png is lossless en de meest gangbare keuze hier.
MimeType := 'image/png';

MS := TMemoryStream.Create;
try
try
// Slaat de afbeelding op in haar eigen, oorspronkelijke formaat
// (TPortableNetworkGraphic -> PNG-bytes, TJPEGImage -> JPEG-bytes,
// enz.) - geen kwaliteitsverlies door hercompressie.
APicture.Graphic.SaveToStream(MS);
except
// Kan om welke reden dan ook niet gecodeerd worden: geen kapotte
// <img> tonen in de export, gewoon overslaan.
Exit;
end;

if MS.Size = 0 then
Exit;

SetLength(RawData, MS.Size);
Move(MS.Memory^, RawData[1], MS.Size);

Result :=
'data:' + MimeType + ';base64,' +
EncodeStringBase64(RawData);
finally
MS.Free;
end;
end;

function ImageSizeModeToHTMLStyle(
AMode: TImageSizeMode;
ImgW, ImgH, CellW, CellH: Integer): string;
var
NewW, NewH: Integer;
Ratio: Double;
begin
if (ImgW <= 0) or (ImgH <= 0) then
begin
Result := 'width:auto; height:auto; vertical-align:middle;';
Exit;
end;

case AMode of

ismOriginal:
Result :=
'width:' + IntToStr(ImgW) + 'px; ' +
'height:' + IntToStr(ImgH) + 'px; ' +
'vertical-align:middle;';

ismFit:
begin
Ratio := ImgW / ImgH;

NewW := CellW;
NewH := Round(NewW / Ratio);

if NewH > CellH then
begin
NewH := CellH;
NewW := Round(NewH * Ratio);
end;

Result :=
'width:' + IntToStr(NewW) + 'px; ' +
'height:' + IntToStr(NewH) + 'px; ' +
'vertical-align:middle;';
end;

ismStretch:
Result :=
'width:100%; ' +
'height:100%; ' +
'vertical-align:middle;';

else
Result := 'width:auto; height:auto; vertical-align:middle;';
end;
end;

function THtmlTableDesigner.ToHTML: string;
var
C, R: Integer;
I: Integer;
Cell: THtmlCell;
StyleText: string;
CellContent: string;
TextContent: string;
ImageContent: string;
ImageDataURI: string;
CellHeight: Integer;
CellTextAlign: string;
P: TPoint;
SB: TStringBuilder;
begin
P := GetHtmlTablePos;

// ------------------------------------------------------------
// De HTML wordt opgebouwd in een TStringBuilder in plaats van
// via "Result := Result + ...". Bij een gewone string kopieert
// elke "+" de volledige, tot dan toe opgebouwde tekst opnieuw;
// bij honderden cellen loopt dat kwadratisch op (bij 2000 cellen
// al gauw miljoenen nodeloos gekopieerde bytes). TStringBuilder
// houdt een intern buffer bij dat enkel groeit wanneer nodig,
// waardoor het opbouwen lineair verloopt in het aantal cellen.
// ------------------------------------------------------------

SB := TStringBuilder.Create;
try
SB.Append(
'<table cellspacing="0" cellpadding="0" ' +
'style="' +
'margin-left:' + IntToStr(P.X) + 'px; ' +
'margin-top:' + IntToStr(P.Y) + 'px; ' +
'background-color:' + ColorToHTML(FExportTableBgColor) + '; ' +
'border:' + IntToStr(FExportTableBorderWidth) + 'px ' +
BorderStyleToHTML(FExportTableBorderStyle) + ' ' +
ColorToHTML(FExportTableBorderColor) + '; ' +
'border-radius:' + IntToStr(FExportTableBorderRadius) + 'px; ' +
'border-collapse:separate; ' +
'border-spacing:0; ' +
'overflow:hidden;">' +
LineEnding
);

for R := 0 to FRowCount - 1 do
begin
SB.Append(
'  <tr style="height:' +
IntToStr(FRowHeights[R]) +
'px;">' +
LineEnding
);

for C := 0 to FColCount - 1 do
begin
Cell := FCells[C, R];

if not Assigned(Cell) then
Continue;

// Onderliggende cellen van een merge niet exporteren
if Cell.Merged then
Continue;

CellHeight := FRowHeights[R];

// Totale hoogte van een verticaal samengevoegde cel bepalen
if Cell.RowSpan > 1 then
begin
CellHeight := 0;

for I := R to R + Cell.RowSpan - 1 do
if (I >= 0) and (I < FRowCount) then
Inc(CellHeight, FRowHeights[I]);
end;

// Uitlijning van de celinhoud
if Cell.ShowImage and (Trim(Cell.ImageFile) <> '') then
begin
case Cell.ImageAlign of
iaLeft:
CellTextAlign := 'left';

iaCenter:
CellTextAlign := 'center';

iaRight:
CellTextAlign := 'right';
else
CellTextAlign := AlignToHTML(Cell.Align);
end;
end
else
CellTextAlign := AlignToHTML(Cell.Align);

StyleText :=
' style="' +
'width:' + IntToStr(FColWidths[C]) + 'px; ' +
'height:' + IntToStr(CellHeight) + 'px; ' +
'background-color:' + ColorToHTML(Cell.BgColor) + '; ' +
'color:' + ColorToHTML(Cell.FontColor) + '; ' +
'text-align:' + CellTextAlign + '; ' +
'vertical-align:middle; ' +
'font-size:' + IntToStr(Cell.FontSize) + 'pt; ' +
'padding:' + IntToStr(FExportCellPadding) + 'px; ' +
'box-sizing:border-box; ' +
'border-radius:' +
IntToStr(FExportCellBorderRadius) + 'px; ';

if fsBold in Cell.FontStyles then
StyleText := StyleText + 'font-weight:bold; ';

if fsItalic in Cell.FontStyles then
StyleText := StyleText + 'font-style:italic; ';

if fsUnderline in Cell.FontStyles then
StyleText := StyleText + 'text-decoration:underline; ';

if fsStrikeOut in Cell.FontStyles then
StyleText :=
StyleText + 'text-decoration:line-through; ';

if Cell.BorderStyle <> cbsNone then
begin
if Cell.BorderStyle = cbsDouble then
begin
StyleText :=
StyleText +
'border:' +
IntToStr(Max(FGridLineWidth, 3)) + 'px ' +
BorderStyleToHTML(Cell.BorderStyle) + ' ' +
ColorToHTML(FGridColor) + '; ';
end
else
begin
StyleText :=
StyleText +
'border:' +
IntToStr(FGridLineWidth) + 'px ' +
BorderStyleToHTML(Cell.BorderStyle) + ' ' +
ColorToHTML(FGridColor) + '; ';
end;
end
else
StyleText := StyleText + 'border:0; ';

StyleText := StyleText + '"';

CellContent := '';

// =====================================================
// Afbeelding
// =====================================================

if Cell.ShowImage and (Trim(Cell.ImageFile) <> '') then
begin
// Geen lokaal bestandspad meer in de HTML: dat werkt sowieso
// niet in een browser (backslashes, en afhankelijk van diezelfde
// schijf/map op dezelfde machine). De afbeelding wordt in
// plaats daarvan als data-URI ingebed, vanuit de al in het
// geheugen geladen Cell.Picture.
ImageDataURI :=
ImageToDataURI(Cell.Picture, Cell.ImageFile);

if ImageDataURI <> '' then
begin
ImageContent :=
'<img src="' +
ImageDataURI +
'" alt="" style="' +
ImageSizeModeToHTMLStyle(
Cell.ImageSizeMode,
Cell.Picture.Width,
Cell.Picture.Height,
FColWidths[C],
CellHeight
) +
'">';

// Afbeelding als hyperlink exporteren
if Cell.ImageIsLink and
(Trim(Cell.ImageLinkURL) <> '') then
begin
ImageContent :=
'<a href="' +
EscapeHTML(Cell.ImageLinkURL) +
'">' +
ImageContent +
'</a>';
end;

CellContent := ImageContent;
end;
// Kon de afbeelding niet omgezet worden (bv. Picture leeg
// omdat het bestand ontbrak bij het laden): CellContent blijft
// leeg in plaats van een kapotte <img> te tonen; eventuele
// celtekst hieronder wordt gewoon nog getoond.
end;

// =====================================================
// Tekst
// =====================================================

if Cell.Text <> '' then
begin
if CellContent <> '' then
CellContent := CellContent + '<br>';

// Bestaande teksthyperlink
if Cell.IsLink and
(Trim(Cell.LinkURL) <> '') then
begin
if Cell.LinkText <> '' then
TextContent := TextToHTML(Cell.LinkText)
else
TextContent := TextToHTML(Cell.Text);

CellContent :=
CellContent +
'<a href="' +
EscapeHTML(Cell.LinkURL) +
'">' +
TextContent +
'</a>';
end
else
begin
CellContent :=
CellContent +
TextToHTML(Cell.Text);
end;
end;

if CellContent = '' then
CellContent := '&nbsp;';

SB.Append('    <td');

if Cell.ColSpan > 1 then
begin
SB.Append(
' colspan="' +
IntToStr(Cell.ColSpan) +
'"'
);
end;

if Cell.RowSpan > 1 then
begin
SB.Append(
' rowspan="' +
IntToStr(Cell.RowSpan) +
'"'
);
end;

SB.Append(
StyleText +
'>' +
CellContent +
'</td>' +
LineEnding
);
end;

SB.Append('  </tr>' + LineEnding);
end;

SB.Append('</table>');

Result := SB.ToString;
finally
SB.Free;
end;
end;


function THtmlTableDesigner.ToHTMLDocument: string;
begin
Result :=
'<!DOCTYPE html>' + LineEnding +
'<html lang="nl">' + LineEnding +
'<head>' + LineEnding +
'  <meta charset="UTF-8">' + LineEnding +
'  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + LineEnding +
'  <title>HTML Table Designer</title>' + LineEnding +
'  <style>' + LineEnding +
'    html, body {' + LineEnding +
'      margin: 0;' + LineEnding +
'      padding: 0;' + LineEnding +
'      font-family: Arial, Helvetica, sans-serif;' + LineEnding +
'      background: ' + ColorToHTML(FHtmlBgColor) + ';' + LineEnding +
'      color: #222;' + LineEnding +
'    }' + LineEnding +
'    table {' + LineEnding +
'      box-sizing: border-box;' + LineEnding +
'    }' + LineEnding +
'    td {' + LineEnding +
'      box-sizing: border-box;' + LineEnding +
'    }' + LineEnding +
'    img {' + LineEnding +
'      vertical-align: middle;' + LineEnding +
'    }' + LineEnding +
'    a {' + LineEnding +
'      color: #0066cc;' + LineEnding +
'      text-decoration: underline;' + LineEnding +
'    }' + LineEnding +
'    .page-designer {' + LineEnding +
'      position: relative;' + LineEnding +
'      width: 100%;' + LineEnding +
'      min-height: 100vh;' + LineEnding +
'    }' + LineEnding +
'    .designer-textblock {' + LineEnding +
'      position: absolute;' + LineEnding +
'      box-sizing: border-box;' + LineEnding +
'      white-space: pre-wrap;' + LineEnding +
'      overflow: hidden;' + LineEnding +
'    }' + LineEnding +
'  </style>' + LineEnding +
'</head>' + LineEnding +
'<body>' + LineEnding +
'<div class="page-designer">' + LineEnding +
TextBlocksToHTML +
ToHTML + LineEnding +
'</div>' + LineEnding +
'</body>' + LineEnding +
'</html>';
end;


end.


