unit HtmlTableDesignerAdvanced;

{$mode objfpc}{$H+}

{******************************************************************************
  HtmlTableDesignerAdvanced

  Uitbreiding op THtmlTableDesigner met een compacte toolbox voor:
    - Table tools
    - Cell tools
    - TextBlock tools
    - Settings tools

  De vier hoofdtools worden gekozen via FToolSelector. De bijbehorende
  controls staan in FToolBox op afzonderlijke, verborgen TTabSheets.
******************************************************************************}

interface

uses
  SysUtils,
  FileUtil,
  Classes,
  Controls,
  Forms,
  Math,
  Graphics,
  ImgList,
  LCLType,
  LCLIntf,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  Buttons,
  menus,
  Spin,
  Dialogs,
  IniFiles,
  LResources,
  BorderStyleButton,
  HtmlTableDesigner,
  HtmlTableDesignerLang,
  LangEditorForm,
  md5;

type
  TAdvancedTool = (atTable, atCell, atTextBlock, atSettings);

type
  TDesignerDefaultSettings = record
    DefaultColWidth: Integer;
    DefaultRowHeight: Integer;
    GridLineWidth: Integer;
    GridColor: TColor;
    HtmlBgColor:TColor;

    ShowLayoutGrid: Boolean; // met gebruik van TCheckBox
    ShowPageRulers: Boolean; // met gebruik van TCheckBox
    ShowHeaders: Boolean;    // met gebruik van TCheckBox

    PageWidth: Integer;
    PageHeight: Integer;

    Language: TUILanguage; // met gebruik van FBtLanguage / FSelectedLanguage
  end;

type

  { THtmlTableDesignerAdvanced }

  THtmlTableDesignerAdvanced = class(THtmlTableDesigner)
  private
    { ------------------------------------------------------------------------
      Algemene toestand en positionering
      ------------------------------------------------------------------------ }
    FFloatingOffsetX: Integer;
    FFloatingOffsetY: Integer;
    FActiveTool: TAdvancedTool;
    FUpdatingCellToolStates: Boolean;
    FUpdatingTableToolStates: Boolean;
    FUpdatingTextBlockToolStates:Boolean;

    { ------------------------------------------------------------------------
      Hoofdselector: Table / Cell / TextBlock / Settings
      ------------------------------------------------------------------------ }
    FTableHint: string;      //Hints voor knoppen ToolBox links
    FCellHint: string;       //Hints voor knoppen ToolBox links
    FTextBlockHint: string;  //Hints voor knoppen ToolBox links
    FSettingsHint:String;    //Hints voor knoppen ToolBox links

    { ------------------------------------------------------------------------
      Vertalingen (HtmlTableDesignerLang): onthoudt per control welke NL-sleutel
      gebruikt is, zodat ApplyLanguage() na een taalwissel alle Hints/Captions
      opnieuw kan toepassen zonder de toolbox-controls te moeten herbouwen.
      Objects[i] = de control, Strings[i] = de NL-sleutel (TR-argument).
      ------------------------------------------------------------------------ }
    FTRHintEntries: TStringList;
    FTRCaptionEntries: TStringList;
    FOnLanguageChanged: TNotifyEvent;

    function TRH(AControl: TControl; const AKey: string): string;
    function TRC(AControl: TControl; const AKey: string): string;
    procedure ApplyLanguage;
    function GetLanguage: TUILanguage;
    procedure SetLanguage(AValue: TUILanguage);

  private
    { ------------------------------------------------------------------------
      ImageLists
      ------------------------------------------------------------------------ }
    FAdvancedImages: TCustomImageList;

    { ------------------------------------------------------------------------
      Toolbox-afmetingen
      ------------------------------------------------------------------------ }
    FAantalCellButtons:integer;
    FAantalTextBlockButtons:integer;
    FAantalTableButtons:integer;
    FAantalSettingsButtons:integer;

    FTableImageIndex:Integer;     // Table Tools knop
    FCellImageIndex:Integer;      //Cell Tools knop
    FTextBlockImageIndex:Integer; //TextBlock Tools knop
    FSettingsImageIndex:Integer;  // Settings Tools knop

    { ------------------------------------------------------------------------
      Events van de hoofdselector
      ------------------------------------------------------------------------ }
    FOnTableButtonClick: TNotifyEvent;
    FOnCellButtonClick: TNotifyEvent;
    FOnTextBlockButtonClick: TNotifyEvent;
    FOnSettingsButtonClick: TNotifyEvent;
    { ------------------------------------------------------------------------
      Hoofdselector controls
      ------------------------------------------------------------------------ }
    FToolSelector: TPanel;

    FBtToolTable: TSpeedButton;
    FBtToolCell: TSpeedButton;
    FBtToolTextBlock: TSpeedButton;
    FBtToolSettings: TSpeedButton;

    { ------------------------------------------------------------------------
      Toolbox-container en pagina's
      ------------------------------------------------------------------------ }
    FToolBox: TPanel;
    FToolPages: TPageControl;

    FTabTable: TTabSheet;
    FTabCell: TTabSheet;
    FTabTextBlock: TTabSheet;
    FTabSettings: TTabSheet;

    FToolButtonWidth:Integer;
    FToolButtonHeight:Integer;

    { ------------------------------------------------------------------------
      TextBlock tools
      ------------------------------------------------------------------------ }
    FBtTBAdd:TSpeedButton;
    FBtTBDelete:TSpeedButton;
    FBtTBBold: TSpeedButton;
    FBtTBItalic: TSpeedButton;
    FBtTBUnderline: TSpeedButton;

    FBtTBAlignLeft: TSpeedButton;
    FBtTBAlignCenter: TSpeedButton;
    FBtTBAlignRight: TSpeedButton;

    FBtTBCreateHyperlink: TSpeedButton;
    FBtTBDelHyperlink: TSpeedButton;


    FBtTBColor: TColorButton;

    FBtTBGColor: TColorButton;
    FBtTBTransparent: TSpeedButton;//voor transparant zetten van TextBlock

    FBtTBFontSize: TSpinEdit;
    FBtTBBorderSize :TSpinEdit;
    FBtTBMoveX: TSpinEdit;
    FBtTBMoveY: TSpinEdit;

    FBtTBBorderStyle: TBorderStyleButton;
    // ------------------------------------------------------------
    // TextBlock ImageIndex
    // ------------------------------------------------------------
    FTBImageIndexAdd: Integer;
    FTBImageIndexDelete: Integer;
    FTBImageIndexBold: Integer;
    FTBImageIndexItalic: Integer;
    FTBImageIndexUnderline: Integer;

    FTBImageIndexAlignLeft: Integer;
    FTBImageIndexAlignCenter: Integer;
    FTBImageIndexAlignRight: Integer;

    FTBImageIndexCreateHyperlink: Integer;
    FTBImageIndexDelHyperlink: Integer;


    FTBImageIndexTransparent: Integer;

    { ------------------------------------------------------------------------
    Settings tools
    ------------------------------------------------------------------------ }

    FBtSetLoad: TSpeedButton;
    FBtSetSave: TSpeedButton;
    FBtSetReset: TSpeedButton;
    FBtSetApply: TSpeedButton;
    FBtSetLanguage: TSpeedButton;
    // Taalkeuze: vlag-knop + uitklapmenu (past in de smalle toolbox, i.t.t.
    // een combobox waarvan de dropdown-pijl de vlag afsnijdt).
    // FSelectedLanguage = wat de knop toont; wijkt tijdelijk af van de live
    // taal na Load/Reset tot "Apply" (zie SettingsToControls).
    FBtLanguage: TSpeedButton;
    FLanguagePopup: TPopupMenu;
    FSelectedLanguage: TUILanguage;

    // Image indexen buttons Settings toolbox
    FSettingsLoadImageIndex: Integer;
    FSettingsSaveImageIndex: Integer;
    FSettingsResetImageIndex: Integer;
    FSettingsApplyImageIndex: Integer;
    FSettingsLanguageImageIndex: Integer;

    // Eerste globale default-instellingen
    FSetDefaultColWidth: TSpinEdit;
    FSetDefaultRowHeight: TSpinEdit;
    FSetGridLineWidth: TSpinEdit;
    FSetGridColor: TColorButton;
    FSetHtmlBgColor:TColorButton;

    FChkShowLayoutGrid: TCheckBox;
    FChkShowPageRulers: TCheckBox;
    FChkShowHeaders: TCheckBox;

    FLblPageWidth: TLabel;// new
    FLblPageHeight: TLabel;// new
    FBtSetPageSize: TSpeedButton; //New
    FPageSizePopup: TPopupMenu; //New

    // Interne settings-data
    FDefaultSettings: TDesignerDefaultSettings;
    FUpdatingSettingsToolStates: Boolean;

    { ------------------------------------------------------------------------
      Cell tools
      ------------------------------------------------------------------------ }
    FBtCellBold: TSpeedButton;
    FBtCellItalic: TSpeedButton;
    FBtCellUnderline: TSpeedButton;
    FBtCellAlignLeft: TSpeedButton;
    FBtCellAlignCenter: TSpeedButton;
    FBtCellAlignRight: TSpeedButton;
    FBtCellCreateTextHyperlink:TSpeedButton;
    FBtCellDelTextHyperlink:TSpeedButton;
    FBtCellCopy: TSpeedButton;
    FBtCellPaste: TSpeedButton;

    FBtCellColor: TColorButton;

    FBtCellFontSize: TSpinEdit;
    FBtCellRadius : TSpinEdit;
    FBtCellBorderStyle: TBorderStyleButton;

    FBtCellCreateHyperlink: TSpeedButton;
    FBtCellDelHyperlink: TSpeedButton;

    FBtTextColor: TColorButton;

    FBtAddImage: TSpeedButton;
    FBtDelImage: TSpeedButton;
    FBtImageLeft: TSpeedButton;
    FBtImageCenter: TSpeedButton;
    FBtImageRight: TSpeedButton;
    FBtImageSize: TSpeedButton;
    FImageSizePopup: TPopupMenu;
    FBtTableMergeCells:TSpeedButton;
    FBtTableUnMergeCells:TSpeedButton;


    // Image indexen buttons cell-ToolBox ---------------------------------------
    FCellBoldImageIndex: Integer;
    FCellItalicImageIndex: Integer;
    FCellUnderlineImageIndex: Integer;
    FCellAlignLeftImageIndex: Integer;
    FCellAlignCenterImageIndex: Integer;
    FCellAlignRightImageIndex: Integer;
    FCellCopyImageIndex: Integer;
    FCellPasteImageIndex: Integer;
    FCellCreateHyperlinkImageIndex: Integer;// from Text
    FCellDelHyperlinkImageIndex: Integer;// from Text
    FCellCreateTextHyperlinkImageIndex: Integer;// from Text
    FCellDelTextHyperlinkImageIndex: Integer;// from Text

    FAddImageImageIndex: Integer;
    FDelImageImageIndex: Integer;
    FImageLeftImageIndex: Integer;
    FImageCenterImageIndex: Integer;
    FImageRightImageIndex: Integer;
    FImageSizeImageIndex: Integer;


    { ------------------------------------------------------------------------
      Table tools
      ------------------------------------------------------------------------ }
    FBtTableNew:TSpeedButton;
    FBtTableAddRow:TSpeedButton;
    FBtTableAddColumn:TSpeedButton;
    FBtTableDeleteRow:TSpeedButton;
    FBtTableDeleteColumn:TSpeedButton;


    FBtTableGridLineWidth :TSpinEdit;
    FBtTableRowHeight:TSpinEdit;
    FBtTableColumnWidth:TSpinEdit;
    FBtTableMoveX:TSpinEdit;
    FBtTableBorderColor:TColorButton;
    FBtTableMoveY:TSpinEdit;
    FBtTableBorderWidth:TSpinEdit;
    FBtTableBorderRadius:TSpinEdit;
    FBtTableBackgroundColor:TColorButton;

    FBtTableBorderStyle:TBorderStyleButton;
    FTableHeaderColor: TColorButton;//new

    // Image indexen buttons Table-ToolBox -------------------------------------
    FTableNewImageIndex: Integer;
    FTableAddRowImageIndex: Integer;
    FTableAddColumnImageIndex: Integer;
    FTableDeleteRowImageIndex: Integer;
    FTableDeleteColumnImageIndex: Integer;
    FTableMergeCellsImageIndex: Integer;
    FTableUnMergeCellsImageIndex: Integer;

    { ------------------------------------------------------------------------
      Private methoden
      ------------------------------------------------------------------------ }
    FAdvancedImagesWide: TCustomImageList;
    // Vlaggetjes in de taal-combobox (index = Ord(TUILanguage))
    FLanguageFlagImages: TCustomImageList;
    procedure SetAdvancedImagesWide(AValue: TCustomImageList);
    procedure SetLanguageFlagImages(AValue: TCustomImageList);
    procedure UpdateLanguageButton;
    procedure LanguageButtonClick(Sender: TObject);
    procedure LanguageMenuClick(Sender: TObject);

    {---------------------------------------------------------------------------
     SETTINGS TOOLS
    --------------------------------------------------------------------------}
    // click-event voor buttons op FTabSettings (TabSheet)
    procedure SettingsLoadClick(Sender: TObject);
    procedure SettingsSaveClick(Sender: TObject);

    procedure SettingsResetClick(Sender: TObject);
    procedure SettingsApplyClick(Sender: TObject);
    procedure SettingsLanguageClick(Sender: TObject);
    procedure PageSizeButtonClick(Sender:TObject);
    // setters  Settings-image indexen
    procedure SetSettingsLoadImageIndex(AValue: Integer);
    procedure SetSettingsSaveImageIndex(AValue: Integer);
    procedure SetSettingsResetImageIndex(AValue: Integer);
    procedure SetSettingsApplyImageIndex(AValue: Integer);
    procedure SetSettingsLanguageImageIndex(AValue: Integer);

    procedure SetFactoryDefaultSettings;
    procedure SettingsToControls;
    procedure ControlsToSettings;

    procedure ApplyDefaultSettings;

    procedure SettingsDefaultColWidthChanged(Sender: TObject);
    procedure SettingsDefaultRowHeightChanged(Sender: TObject);
    procedure SettingsGridLineWidthChanged(Sender: TObject);
    procedure SettingsGridColorChanged(Sender: TObject);
    procedure SettingsHtmlBgColorChanged(Sender: TObject);

    procedure SettingsShowLayoutGridChanged(Sender: TObject);
    procedure SettingsShowPageRulersChanged(Sender: TObject);
    procedure SettingsShowHeadersChanged(Sender: TObject);

    procedure CreatePageSizePopup; //new
    procedure PageSizeMenuClick(Sender: TObject);//new
    procedure UpdatePageSizeButton;// new
    //---

    //--------------------------------------------------------------------------
    { Hoofdselector ImageIndex setters }
    procedure SetTableImageIndex(AValue: Integer);
    procedure SetCellImageIndex(AValue: Integer);
    procedure SetTextBlockImageIndex(AValue: Integer);
    procedure SetSettingsImageIndex(AValue: Integer);
    // Create procedure voor FToolselector
    procedure CreateToolSelector;
    // click-event voor buttons op FToolSelector (Panel)
    procedure ToolTableClick(Sender: TObject);
    procedure ToolCellClick(Sender: TObject);
    procedure ToolTextBlockClick(Sender: TObject);
    procedure ToolSettingsClick(Sender: TObject);

    // click-events Table buttons ToolBox
    procedure TableAddNewClick(Sender: TObject);
    procedure TableAddRowClick(Sender: TObject);
    procedure TableAddColumnClick(Sender: TObject);
    procedure TableDeleteRowClick(Sender: TObject);
    procedure TableDeleteColumnClick(Sender: TObject);

    procedure TableGridLineSizeChanged(Sender: TObject);
    procedure TableRowHeightChanged(Sender: TObject);
    procedure TableColumnWidthChanged(Sender: TObject);
    procedure TableMoveXChanged(Sender: TObject);
    procedure TableMoveYChanged(Sender: TObject);
    function TableOffsetToMM(AOffset: Integer): Integer;
    function MMToTableOffset(AMM: Integer): Integer;
    procedure TableBorderColorChanged(Sender: TObject);
    procedure TableBorderWidthChanged(Sender: TObject);
    procedure TableBorderRadiusChanged(Sender: TObject);
    procedure TablebackgroundColorChanged(Sender: TObject);
    procedure TableBorderStyleChange(Sender: TObject);
    procedure TableHeaderColorChanged(Sender: TObject);//new

    // click-events Cell buttons ToolBox op FTabCell
    procedure TableMergeCellsClick(Sender: TObject);
    procedure TableUnMergeCellsClick(Sender: TObject);
    procedure CellBoldClick(Sender: TObject);
    procedure CellItalicClick(Sender: TObject);
    procedure CellUnderlineClick(Sender: TObject);
    procedure CellAlignLeftClick(Sender: TObject);
    procedure CellAlignCenterClick(Sender: TObject);
    procedure CellAlignRightClick(Sender: TObject);

    procedure CellCreateTextHyperlinkClick(Sender: TObject);
    procedure CellDelTextHyperlinkClick(Sender: TObject);

    procedure CellCopyClick(Sender: TObject);
    procedure CellPasteClick(Sender: TObject);
    procedure CellColorChanged(Sender: TObject);
    procedure CellFontSizeChanged(Sender: TObject);

    procedure CellRadiusChanged(Sender: TObject);
    procedure CellBorderStyleChange(Sender: TObject);
    procedure CellCreateHyperlinkClick(Sender: TObject);
    procedure CellDelHyperlinkClick(Sender: TObject);


    procedure TextColorChanged(Sender: TObject);

    // ------------------------------------------------------------
    // Beheer van de interne <exe>\html\images\-map: bepaalt waar
    // gekopieerde afbeeldingen terechtkomen, en ruimt kopieën op die
    // nergens in de tabel meer gebruikt worden.
    // ------------------------------------------------------------
    function GetImagesDir: string;
    function IsInImagesDir(const AFileName: string): Boolean;
    function IsImageFileUsed(const AFileName: string): Boolean;
    procedure CleanupUnusedImage(const AFileName: string);

    procedure AddImageClick(Sender: TObject);
    procedure DelImageClick(Sender: TObject);
    procedure ImageLeftClick(Sender: TObject);
    procedure ImageCenterClick(Sender: TObject);
    procedure ImageRightClick(Sender: TObject);
    procedure CreateImageSizePopup;
    procedure ImageSizeButtonClick(Sender: TObject);
    procedure ImageSizeMenuClick(Sender: TObject);
    procedure UpdateImageSizePopupChecks;

    //click -events TextBlock-tools
    procedure TBAddButtonClick(Sender: TObject);
    procedure TBDeleteButtonClick(Sender: TObject);
    procedure TBBoldClick(Sender: TObject);
    procedure TBItalicClick(Sender: TObject);
    procedure TBUnderlineClick(Sender: TObject);

    procedure TBAlignLeftClick(Sender: TObject);
    procedure TBAlignCenterClick(Sender: TObject);
    procedure TBAlignRightClick(Sender: TObject);

    procedure TBCreateHyperlinkClick(Sender: TObject);
    procedure TBDelHyperlinkClick(Sender: TObject);
    procedure TBTransparentClick(Sender: TObject);

    procedure TBBGColorChanged(Sender: TObject);

    procedure TBColorChanged(Sender: TObject);
    procedure TBFontSizeChanged(Sender: TObject);
    procedure TBBorderStyleChange(Sender: TObject);
    procedure TBBorderSizeChanged(Sender: TObject);
    procedure TBMoveXChanged(Sender: TObject);
    procedure TBMoveYChanged(Sender: TObject);
    procedure GetTextBlockRulerZero(out AZeroX, AZeroY: Integer);
    function TextBlockPosToMM(APos, AZero: Integer): Integer;

    // setters
    procedure SetToolButtonWidth(AValue: Integer);
    procedure SetToolButtonHeight(AValue: Integer);
    procedure SetActiveTool(AValue: TAdvancedTool);
    procedure SetCellBoldImageIndex(AValue: Integer);
    procedure SetCellItalicImageIndex(AValue: Integer);
    procedure SetCellUnderlineImageIndex(AValue: Integer);
    procedure SetCellAlignLeftImageIndex(AValue: Integer);
    procedure SetCellAlignCenterImageIndex(AValue: Integer);
    procedure SetCellAlignRightImageIndex(AValue: Integer);
    procedure SetCellCreateTextHyperlinkImageIndex(AValue: Integer);
    procedure SetCellDelTextHyperlinkImageIndex(AValue: Integer);
    procedure SetCellCopyImageIndex(AValue: Integer);
    procedure SetCellPasteImageIndex(AValue: Integer);
    procedure SetCellCreateHyperlinkImageIndex(AValue: Integer);
    procedure SetCellDelHyperlinkImageIndex(AValue: Integer);
    procedure SetAddImageImageIndex(AValue: Integer);
    procedure SetDelImageImageIndex(AValue: Integer);
    procedure SetImageLeftImageIndex(AValue: Integer);
    procedure SetImageCenterImageIndex(AValue: Integer);
    procedure SetImageRightImageIndex(AValue: Integer);
    procedure SetImageSizeImageIndex(AValue: Integer);

     // setters TextBlok-image indexen
    procedure SetTBImageIndexAdd(AValue: Integer);
    procedure SetTBImageIndexDelete(AValue: Integer);
    procedure SetTBImageIndexBold(AValue: Integer);
    procedure SetTBImageIndexItalic(AValue: Integer);
    procedure SetTBImageIndexUnderline(AValue: Integer);
    procedure SetTBImageIndexAlignLeft(AValue: Integer);
    procedure SetTBImageIndexAlignCenter(AValue: Integer);
    procedure SetTBImageIndexAlignRight(AValue: Integer);
    procedure SetTBImageIndexCreateHyperlink(AValue: Integer);
    procedure SetTBImageIndexDelHyperlink(AValue: Integer);
    procedure SetTBImageIndexTransparant(AValue: Integer);
    //--------------------------------------------------------------------------
    // setters Table-image indexen
    procedure SetImageIndexTableNew(AValue: Integer);
    procedure SetImageIndexTableAddRow(AValue: Integer);
    procedure SetImageIndexTableAddColumn(AValue: Integer);
    procedure SetImageIndexTableDeleteRow(AValue: Integer);
    procedure SetImageIndexTableDeleteColumn(AValue: Integer);
    procedure SetImageIndexTableMergeCells(AValue: Integer);
    procedure SetImageIndexTableUnMergeCells(AValue: Integer);
    //--------------------------------------------------------------------------
    procedure SetAantalCellButtons(AValue: Integer);

    procedure SetAantalSettingsButtons(AValue: Integer);
    procedure SetAantalTextBlockButtons(AValue: Integer);
    procedure SetAantalTableButtons(AValue: Integer);
    procedure SetAdvancedImages(AValue: TCustomImageList);

    procedure UpdateToolsHeight(AButtonCount: Integer);


    procedure UpdateActiveToolsHeight;

    // 4 bovenste knoppen Table-setting , Cell-settings en TextBlock-settings en
    procedure UpdateToolSelectorIcons;

    // knoppen procedures cell.........
    procedure CreateCellTools;
    procedure UpdateCellToolsHeight;
    procedure UpdateCellToolStates;// uitlezen cell toestand
    procedure UpdateCellToolIcons;
    procedure UpdateCellToolsLayout;

    // Table procedures row,column en merge.........
    procedure CreateTableTools;
    procedure UpdateTableToolsHeight;
    procedure UpdateTableToolStates;// uitlezen Table toestand
    procedure UpdateTableToolsIcons;
    procedure UpdateTableToolsLayout;



    //TextBlock procedures
    procedure CreateTextBlockTools;
    procedure UpdateTextBlockToolsLayout;
    procedure UpdateTextBlockToolsHeight;
    procedure UpdateTextBlockToolStates;
    procedure UpdateTextBlockToolsIcons;

    // Settings procedure
    procedure CreateSettingsTools;
    procedure UpdateSettingsToolsLayout;
    procedure UpdateSettingsToolsHeight;

    procedure UpdateSettingsToolsIcons;
    // voor defaults ini
    function DefaultSettingsFileName: string;
    procedure SaveDefaultSettings;
    procedure LoadDefaultSettings;

  { --------------------------------------------------------------------------
    LCL overrides
    -------------------------------------------------------------------------- }
 protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton;Shift: TShiftState;X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;Shift: TShiftState;X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer); override;
    procedure Notification(AComponent: TComponent;Operation: TOperation); override;
    procedure KeyDown(var Key: Word;Shift: TShiftState); override;

  { --------------------------------------------------------------------------
    Publieke API
    -------------------------------------------------------------------------- }
 public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateFloatingTools(AHorzScrollPos, AVertScrollPos: Integer);

  { --------------------------------------------------------------------------
    Gepubliceerde properties
    -------------------------------------------------------------------------- }
 published
  // Weergavetaal van de toolbox (NL/EN/FR/DU). Verandert
  // HtmlTableDesignerLang.CurrentLanguage (geldt component-breed, niet enkel
  // voor deze instantie) en past meteen alle Hints/Captions opnieuw toe.
  property Language: TUILanguage read GetLanguage write SetLanguage default langNL;

  // Wordt aangeroepen na elke ApplyLanguage (taalwissel via combobox,
  // property, Apply-knop...), zodat een host-formulier zijn eigen
  // vertaalde Hints/Captions kan verversen in dezelfde taal.
  property OnLanguageChanged: TNotifyEvent read FOnLanguageChanged write FOnLanguageChanged;

  property TableHint: string read FTableHint write FTableHint;
  property CellHint: string read FCellHint write FCellHint;
  property SettingsHint: string read FSettingsHint write FSettingsHint;
  property TextBlockHint: string read FTextBlockHint write FTextBlockHint;

  property AdvancedImages: TCustomImageList read FAdvancedImages write SetAdvancedImages;
  //----------------------------------------------------------------------------
  //image indexen voor 4 knoppen bovenaan
  property TableImageIndex: Integer read FTableImageIndex write SetTableImageIndex default -1; //FTableKnopImageIndex:
  property CellImageIndex: Integer read FCellImageIndex write SetCellImageIndex default -1;    //FTableKnopImageIndex:
  property TextBlockImageIndex: Integer read FTextBlockImageIndex write SetTextBlockImageIndex default -1;
  property SettingsImageIndex: Integer read FSettingsImageIndex write SetSettingsImageIndex default -1;
  //--------------------------------------------
  property CellCopyImageIndex: Integer read FCellCopyImageIndex write SetCellCopyImageIndex default -1;
  property CellPasteImageIndex: Integer read FCellPasteImageIndex write SetCellPasteImageIndex default -1;
  property CellCreateHyperlinkImageIndex: Integer read FCellCreateHyperlinkImageIndex write SetCellCreateHyperlinkImageIndex default -1;

  property CellDelHyperlinkImageIndex: Integer read FCellDelHyperlinkImageIndex write SetCellDelHyperlinkImageIndex default -1;
  property AddImageImageIndex: Integer read FAddImageImageIndex write SetAddImageImageIndex default -1;
  property DelImageImageIndex: Integer read FDelImageImageIndex write SetDelImageImageIndex default -1;
  property ImageLeftImageIndex: Integer read FImageLeftImageIndex write SetImageLeftImageIndex default -1;
  property ImageCenterImageIndex: Integer read FImageCenterImageIndex write SetImageCenterImageIndex default -1;
  property ImageRightImageIndex: Integer read FImageRightImageIndex write SetImageRightImageIndex default -1;
  property ImageSizeImageIndex: Integer read FImageSizeImageIndex write SetImageSizeImageIndex default -1;

  property OnTableButtonClick: TNotifyEvent read FOnTableButtonClick write FOnTableButtonClick;
  property OnCellButtonClick: TNotifyEvent read FOnCellButtonClick write FOnCellButtonClick;
  property OnTextBlockButtonClick: TNotifyEvent read FOnTextBlockButtonClick write FOnTextBlockButtonClick;

  property AantalSettingsButtons:integer read FAantalSettingsButtons write SetAantalSettingsButtons Default 17;

  property AantalCellButtons:integer read FAantalCellButtons write SetAantalCellButtons Default 24;
  property AantalTableButtons:integer read FAantalTableButtons write SetAantalTableButtons Default 23;
  property AantalTextBlockButtons:integer read FAantalTextBlockButtons write SetAantalTextBlockButtons Default 19;
  property CellBoldImageIndex: Integer read FCellBoldImageIndex write SetCellBoldImageIndex default -1;
  property CellItalicImageIndex: Integer read FCellItalicImageIndex write SetCellItalicImageIndex default -1;
  property CellUnderlineImageIndex: Integer read FCellUnderlineImageIndex write SetCellUnderlineImageIndex default -1;
  property CellAlignLeftImageIndex: Integer read FCellAlignLeftImageIndex write SetCellAlignLeftImageIndex default -1;
  property CellAlignCenterImageIndex: Integer read FCellAlignCenterImageIndex write SetCellAlignCenterImageIndex default -1;
  property CellAlignRightImageIndex: Integer read FCellAlignRightImageIndex write SetCellAlignRightImageIndex default -1;

  property ImageIndexTableNew: Integer read FTableNewImageIndex write SetImageIndexTableNew default -1;
  property ImageIndexTableAddRow: Integer read FTableAddRowImageIndex write SetImageIndexTableAddRow default -1;
  property ImageIndexTableAddColumn: Integer read FTableAddColumnImageIndex write SetImageIndexTableAddColumn default -1;
  property ImageIndexTableDeleteRow: Integer read FTableDeleteRowImageIndex write SetImageIndexTableDeleteRow default -1;
  property ImageIndexTableDeleteColumn: Integer read FTableDeleteColumnImageIndex write SetImageIndexTableDeleteColumn default -1;

  property ImageIndexTableMergeCells: Integer read FTableMergeCellsImageIndex write SetImageIndexTableMergeCells default -1;
  property ImageIndexTableUnMergeCells: Integer read FTableUnMergeCellsImageIndex write SetImageIndexTableUnMergeCells default -1;

  property TBImageIndexAdd: Integer read FTBImageIndexAdd write SetTBImageIndexAdd default -1;
  property TBImageIndexDelete: Integer read FTBImageIndexDelete write SetTBImageIndexDelete default -1;
  property TBImageIndexBold: Integer read FTBImageIndexBold write SetTBImageIndexBold default -1;
  property TBImageIndexItalic: Integer read FTBImageIndexItalic write SetTBImageIndexItalic default -1;
  property TBImageIndexUnderline: Integer read FTBImageIndexUnderline write SetTBImageIndexUnderline default -1;
  property TBImageIndexAlignLeft: Integer read FTBImageIndexAlignLeft write SetTBImageIndexAlignLeft default -1;
  property TBImageIndexAlignCenter: Integer read FTBImageIndexAlignCenter write SetTBImageIndexAlignCenter default -1;
  property TBImageIndexAlignRight: Integer read FTBImageIndexAlignRight write SetTBImageIndexAlignRight default -1;
  property TBImageIndexCreateHyperlink: Integer read FTBImageIndexCreateHyperlink write SetTBImageIndexCreateHyperlink default -1;
  property TBImageIndexDelHyperlink: Integer read FTBImageIndexDelHyperlink write SetTBImageIndexDelHyperlink default -1;
  property TBImageIndexTransparent: Integer read FTBImageIndexTransparent write SetTBImageIndexTransparant default -1;
  // voor settings tools
  property SettingsLoadImageIndex: Integer read FSettingsLoadImageIndex write SetSettingsLoadImageIndex default -1;
  property SettingsSaveImageIndex: Integer read FSettingsSaveImageIndex write SetSettingsSaveImageIndex default -1;
  property SettingsResetImageIndex: Integer read FSettingsResetImageIndex write SetSettingsResetImageIndex default -1;
  property SettingsApplyImageIndex: Integer read FSettingsApplyImageIndex write SetSettingsApplyImageIndex default -1;
  // Icoon (uit AdvancedImagesWide) voor de "Taal..."-knop die de vertaallijst opent
  property SettingsLanguageImageIndex: Integer read FSettingsLanguageImageIndex write SetSettingsLanguageImageIndex default -1;

  //-----------------------------------------------------------------------------------
  property ActiveTool: TAdvancedTool read FActiveTool write SetActiveTool default atTable;
  property ToolButtonWidth: Integer read FToolButtonWidth write SetToolButtonWidth default 37;
  property ToolButtonHeight: Integer read FToolButtonHeight write SetToolButtonHeight default 18;

  property AdvancedImagesWide: TCustomImageList read FAdvancedImagesWide write SetAdvancedImagesWide;
  // Vlaggen voor de taal-combobox: 0 = NL, 1 = EN, 2 = FR, 3 = DE
  property LanguageFlagImages: TCustomImageList read FLanguageFlagImages write SetLanguageFlagImages;
  property CellCreateTextHyperlinkImageIndex: Integer read FCellCreateTextHyperlinkImageIndex write SetCellCreateTextHyperlinkImageIndex default -1;
  property CellDelTextHyperlinkImageIndex: Integer read FCellDelTextHyperlinkImageIndex write SetCellDelTextHyperlinkImageIndex default -1;
end;

procedure Register;

implementation

const
  // TableOffsetX/Y waarbij de tabel exact op nul van de rulers staat
  // (RulerSize 20 + 1 px rand). De Move X/Y-spinedits tonen de positie
  // relatief t.o.v. dit nulpunt, in mm (zelfde eenheid als de rulers).
  TableRulerZero = 21;

{ =============================================================================
  INITIALISATIE EN ALGEMENE TOOLBOX
  ============================================================================= }

constructor THtmlTableDesignerAdvanced.Create(AOwner: TComponent);
var
  DefaultLangFile: string;
begin
 inherited Create(AOwner);

  FTRHintEntries := TStringList.Create;
  FTRCaptionEntries := TStringList.Create;

  // Vertalingen voor het bouwen van de toolbox inladen (indien 'talen.lng'
  // naast de .exe staat), zodat de TRH/TRC-aanroepen hieronder de bestaande
  // vertalingen meteen vinden i.p.v. lege NL-only entries aan te maken. Zo
  // werkt de taal-combobox/Language-property meteen bij de eerste wissel,
  // ook zonder eerst de "Taal..."-editor geopend te hebben.
  if not (csDesigning in ComponentState) then
    begin
    DefaultLangFile :=
      IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
      'talen.lng';

    if FileExists(DefaultLangFile) then
      HtmlTableDesignerLang.LoadLanguageFile(DefaultLangFile);
    end;

  FFloatingOffsetX := 0;
  FFloatingOffsetY := 0;
  FUpdatingCellToolStates := False;
  FUpdatingTableToolStates:= False;
  FUpdatingTextBlockToolStates:=False;
  FUpdatingSettingsToolStates := False;


  FAantalCellButtons := 24;
  FAantalTableButtons := 23;
  FAantalTextBlockButtons := 19;
  FAantalSettingsButtons := 17;

  // Bewust GEEN Application.HintColor/HintPause/HintHidePause meer
  // hier instellen: dit zijn toepassingsbrede instellingen (TApplication),
  // geen componentinstellingen. Ze golden voorheen voor élk hint in de
  // hele toepassing zodra dit component ergens werd geplaatst, en bij
  // meerdere instanties overschreven ze elkaar telkens opnieuw. Wil de
  // gebruiker van dit component toch gele hints met een korte vertraging
  // in zijn eigen toepassing, dan stelt hij dat zelf in (bv. in het
  // OnCreate van zijn hoofdformulier).

  FTableHint := TR('Table settings');
  FCellHint := TR('Cell settings');
  FTextBlockHint := TR('Text block settings');
  FSettingsHint := TR('Global settings');

  WorkspaceOffsetX := 22;

  FAdvancedImagesWide := nil;
  FAdvancedImages := nil;

  FTableImageIndex := -1;
  FCellImageIndex := -1;
  FTextBlockImageIndex:= -1;

  FSettingsLoadImageIndex := -1;
  FSettingsSaveImageIndex := -1;
  FSettingsResetImageIndex := -1;
  FSettingsApplyImageIndex := -1;
  FSettingsLanguageImageIndex := -1;

  FCellBoldImageIndex := -1;
  FCellItalicImageIndex := -1;
  FCellUnderlineImageIndex := -1;
  FCellAlignLeftImageIndex := -1;
  FCellAlignCenterImageIndex := -1;

  FCellCreateTextHyperlinkImageIndex := -1;
  FCellDelTextHyperlinkImageIndex := -1;

  FCellAlignRightImageIndex := -1;
  FCellCopyImageIndex := -1;
  FCellPasteImageIndex := -1;
  FCellCreateHyperlinkImageIndex := -1;
  FCellDelHyperlinkImageIndex := -1;
  FAddImageImageIndex := -1;
  FDelImageImageIndex := -1;
  FImageLeftImageIndex := -1;
  FImageCenterImageIndex := -1;
  FImageRightImageIndex := -1;
  FImageSizeImageIndex := -1;

  FTableNewImageIndex := -1;
  FTableAddRowImageIndex := -1;
  FTableAddColumnImageIndex := -1;
  FTableDeleteRowImageIndex := -1;
  FTableDeleteColumnImageIndex := -1;
  FTableMergeCellsImageIndex := -1;
  FTableUnMergeCellsImageIndex := -1;

  FTBImageIndexAdd:= -1;
  FTBImageIndexDelete:= -1;
  FTBImageIndexBold:= -1;
  FTBImageIndexItalic:= -1;
  FTBImageIndexUnderline:= -1;
  FTBImageIndexAlignLeft:= -1;
  FTBImageIndexAlignCenter:= -1;
  FTBImageIndexAlignRight:= -1;
  FTBImageIndexCreateHyperlink:= -1;
  FTBImageIndexDelHyperlink:= -1;
  FTBImageIndexTransparent:= -1;


  FToolButtonHeight:= 18;
  FToolButtonWidth := 34;

  CreateToolSelector;
  // ------------------------------------------------------------
  // Interne toolbox   (Panel)
  // ------------------------------------------------------------

  FToolBox := TPanel.Create(Self);
  FToolBox.Parent := Self;
  FToolBox.Left:=1;
  FToolBox.Top:=109;
  FToolBox.Width:=50;
  FToolBox.BevelOuter := bvRaised;//
  FToolBox.BevelWidth:= 2;
  FToolBox.Caption := '';
  FToolBox.BorderStyle:=bsNone;
  FToolBox.ParentColor := false;
  // ------------------------------------------------------------
  // PageControl
  // ------------------------------------------------------------

  FToolPages := TPageControl.Create(Self);
  FToolPages.Parent := FToolBox;
  FToolPages.ShowTabs:=false;
  FToolPages.Width:=44;
  FToolPages.Left:=3;
  FToolPages.Top:=2;
  UpdateCellToolsHeight;
  // ------------------------------------------------------------
  // Table pagina
  // ------------------------------------------------------------

  FTabTable := TTabSheet.Create(Self);
  FTabTable.PageControl := FToolPages;

  FTabTable.Caption :='';

  FTabTable.Visible:=true;
  // ------------------------------------------------------------
  // Cell pagina
  // ------------------------------------------------------------

  FTabCell := TTabSheet.Create(Self);
  FTabCell.PageControl := FToolPages;
  FTabCell.Caption := '';
  FTabCell.Visible:=true;

  // ------------------------------------------------------------
  // TextBlock pagina
  // ------------------------------------------------------------

  FTabTextBlock := TTabSheet.Create(Self);
  FTabTextBlock.PageControl := FToolPages;
  FTabTextBlock.Caption :='';
  FTabTextBlock.Visible:=true;

  // ------------------------------------------------------------
  // Settings pagina
  // ------------------------------------------------------------

  FTabSettings := TTabSheet.Create(Self);
  FTabSettings.PageControl := FToolPages;
  FTabSettings.Caption :='';
  FTabSettings.Visible:=true;


  CreateCellTools;
  CreateTableTools;
  CreateTextBlockTools;
  CreateSettingsTools;

  SetFactoryDefaultSettings;
  SettingsToControls;

  UpdateCellToolStates;
  UpdateTableToolStates;
  UpdateTextBlockToolStates;

  SetActiveTool(atCell);
end;

destructor THtmlTableDesignerAdvanced.Destroy;
begin
  FreeAndNil(FTRHintEntries);
  FreeAndNil(FTRCaptionEntries);
  inherited Destroy;
end;

// Vertaalt AKey en onthoudt (AControl, AKey), zodat ApplyLanguage() de Hint
// van AControl later opnieuw kan vertalen na een taalwissel.
function THtmlTableDesignerAdvanced.TRH(AControl: TControl; const AKey: string): string;
begin
  Result := TR(AKey);
  if Assigned(FTRHintEntries) and Assigned(AControl) then
    FTRHintEntries.AddObject(AKey, AControl);
end;

// Zelfde principe als TRH, maar voor de Caption-eigenschap.
function THtmlTableDesignerAdvanced.TRC(AControl: TControl; const AKey: string): string;
begin
  Result := TR(AKey);
  if Assigned(FTRCaptionEntries) and Assigned(AControl) then
    FTRCaptionEntries.AddObject(AKey, AControl);
end;

// Past de huidige HtmlTableDesignerLang.CurrentLanguage opnieuw toe op alle
// controls die via TRH/TRC geregistreerd werden, zonder de toolbox te
// herbouwen. UpdatePageSizeButton herleidt zelf al de samengestelde
// pagina-afmeting-Hints (Format+TR), dus die hoeven hier niet apart.
procedure THtmlTableDesignerAdvanced.ApplyLanguage;
var
  i: Integer;
begin
  if Assigned(FTRHintEntries) then
    for i := 0 to FTRHintEntries.Count - 1 do
      if Assigned(FTRHintEntries.Objects[i]) then
        TControl(FTRHintEntries.Objects[i]).Hint := TR(FTRHintEntries[i]);

  if Assigned(FTRCaptionEntries) then
    for i := 0 to FTRCaptionEntries.Count - 1 do
      if Assigned(FTRCaptionEntries.Objects[i]) then
        TControl(FTRCaptionEntries.Objects[i]).Caption := TR(FTRCaptionEntries[i]);

  UpdatePageSizeButton;

  // Combobox synchroon houden als de taal van buitenaf gewijzigd werd
  // (property, .lfm-streaming) i.p.v. via de combobox zelf.
  FSelectedLanguage := HtmlTableDesignerLang.CurrentLanguage;
  UpdateLanguageButton;

  Invalidate;

  if Assigned(FOnLanguageChanged) then
    FOnLanguageChanged(Self);
end;

function THtmlTableDesignerAdvanced.GetLanguage: TUILanguage;
begin
  Result := HtmlTableDesignerLang.CurrentLanguage;
end;

procedure THtmlTableDesignerAdvanced.SetLanguage(AValue: TUILanguage);
begin
  if HtmlTableDesignerLang.CurrentLanguage = AValue then
    Exit;

  HtmlTableDesignerLang.CurrentLanguage := AValue;

  // Tijdens .lfm-streaming (csLoading) bestaan de toolbox-controls al
  // (aangemaakt in Create, vóór de published properties gestreamd worden),
  // dus ApplyLanguage kan altijd veilig aangeroepen worden.
  ApplyLanguage;
end;

procedure THtmlTableDesignerAdvanced.UpdateFloatingTools(
  AHorzScrollPos, AVertScrollPos: Integer);
const
  SelectorTopOffset = 16;
  ToolBoxGap        = 3;
begin
  if (FFloatingOffsetX = AHorzScrollPos) and
     (FFloatingOffsetY = AVertScrollPos) then
    Exit;

  FFloatingOffsetX := AHorzScrollPos;
  FFloatingOffsetY := AVertScrollPos;



  if Assigned(FToolSelector) then
  begin
    FToolSelector.Left := FFloatingOffsetX + 1;
    FToolSelector.Top := FFloatingOffsetY + SelectorTopOffset;
    FToolSelector.BringToFront;
  end;

  if Assigned(FToolBox) then
  begin
    FToolBox.Left := FFloatingOffsetX;

    if Assigned(FToolSelector) then
      FToolBox.Top :=
        FToolSelector.Top +
        FToolSelector.Height +
        ToolBoxGap
    else
      FToolBox.Top :=
        FFloatingOffsetY + 109;

    FToolBox.BringToFront;
  end;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetToolButtonWidth(
  AValue: Integer);
begin
  if FToolButtonWidth = AValue then
    Exit;

  FToolButtonWidth := AValue;

  UpdateTableToolsLayout;
  UpdateCellToolsLayout;
  UpdateTextBlockToolsLayout;

  UpdateSettingsToolsLayout;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetToolButtonHeight(
  AValue: Integer);
begin
  if FToolButtonHeight = AValue then
    Exit;

  FToolButtonHeight := AValue;

  UpdateTableToolsLayout;
  UpdateCellToolsLayout;
  UpdateTextBlockToolsLayout;

  UpdateSettingsToolsLayout;

  UpdateActiveToolsHeight;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetActiveTool(
  AValue: TAdvancedTool
);
begin
  if FActiveTool = AValue then
    Exit;

  FActiveTool := AValue;

  //-----------------------------------------------------------------
  if Assigned(FBtToolTable) then
  FBtToolTable.Down := FActiveTool = atTable;

if Assigned(FBtToolCell) then
  FBtToolCell.Down := FActiveTool = atCell;

if Assigned(FBtToolTextBlock) then
  FBtToolTextBlock.Down := FActiveTool = atTextBlock;

if Assigned(FBtToolSettings) then
  FBtToolSettings.Down := FActiveTool = atSettings;
  //-----------------------------------------------------------------

  case FActiveTool of

    atTable:
      begin
        if Assigned(FToolPages) and
           Assigned(FTabTable) then
          FToolPages.ActivePage := FTabTable;
      end;

    atCell:
      begin
        if Assigned(FToolPages) and
           Assigned(FTabCell) then
          FToolPages.ActivePage := FTabCell;
      end;

    atTextBlock:
      begin
        if Assigned(FToolPages) and
           Assigned(FTabTextBlock) then
          FToolPages.ActivePage := FTabTextBlock;
      end;
    atSettings:
      begin
        if Assigned(FToolPages) and
           Assigned(FTabSettings) then
          FToolPages.ActivePage := FTabSettings;
      end;
  end;

  UpdateActiveToolsHeight;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetAantalTableButtons(
  AValue: Integer
);
begin
  if AValue < 1 then
    AValue := 1;

  if FAantalTableButtons = AValue then
    Exit;

  FAantalTableButtons := AValue;

  if FActiveTool = atTable then
    UpdateActiveToolsHeight;
end;

procedure THtmlTableDesignerAdvanced.SetAantalCellButtons(
  AValue: Integer
);
begin
  if AValue < 1 then
    AValue := 1;

  if FAantalCellButtons = AValue then
    Exit;

  FAantalCellButtons := AValue;

  if FActiveTool = atCell then
    UpdateActiveToolsHeight;
end;

procedure THtmlTableDesignerAdvanced.SetAantalTextBlockButtons(
  AValue: Integer
);
begin
  if AValue < 1 then
    AValue := 1;

  if FAantalTextBlockButtons = AValue then
    Exit;

  FAantalTextBlockButtons := AValue;

  if FActiveTool = atTextBlock then
    UpdateActiveToolsHeight;
end;

procedure THtmlTableDesignerAdvanced.SetAantalSettingsButtons(
  AValue: Integer
);
begin
  if AValue < 1 then
    AValue := 1;

  if FAantalSettingsButtons = AValue then
    Exit;

  FAantalSettingsButtons := AValue;

  if FActiveTool = atSettings then
    UpdateActiveToolsHeight;
end;

procedure THtmlTableDesignerAdvanced.UpdateToolsHeight(
  AButtonCount: Integer
);
const
  Gap          = 1;
  TopMargin    = 2;
  BottomMargin = 10;
var
  NewHeight: Integer;
begin
  if AButtonCount < 1 then
    AButtonCount := 1;

  NewHeight :=
    TopMargin +
    (AButtonCount * FToolButtonHeight) +
    ((AButtonCount - 1) * Gap) +
    BottomMargin + 25;

  if Assigned(FToolPages) then
    FToolPages.Height := NewHeight;

  if Assigned(FToolBox) then
  begin
    if Assigned(FToolPages) then
      FToolBox.Height :=
        FToolPages.Top +
        FToolPages.Height +
        6
    else
      FToolBox.Height := NewHeight + 6;
  end;
end;

procedure THtmlTableDesignerAdvanced.UpdateActiveToolsHeight;
begin
  case FActiveTool of

    atTable:
      UpdateToolsHeight(
        FAantalTableButtons
      );

    atCell:
      UpdateToolsHeight(
        FAantalCellButtons
      );

    atTextBlock:
      UpdateToolsHeight(
        FAantalTextBlockButtons
      );

    atSettings:
      UpdateToolsHeight(
        FAantalSettingsButtons
      );
  end;
end;

{ =============================================================================
  HOOFDSELECTOR
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.CreateToolSelector;
const
  StartX = 4;
  StartY = 2;
  Gap    = 3;
  SelectorButtonWidth  = 38;
  SelectorButtonHeight = 20;
var
  Y: Integer;
begin
  // ------------------------------------------------------------
  // Panel voor de vier hoofdknoppen
  // ------------------------------------------------------------

  FToolSelector := TPanel.Create(Self);
  FToolSelector.Parent := Self;

  FToolSelector.Left := 4;
  FToolSelector.Top := 19;
  FToolSelector.Width := 45;
  FToolSelector.Height := 90;
  FToolSelector.Hint := TRH(FToolSelector, 'Tool selector') ;
  FToolSelector.Caption := '';
  FToolSelector.BevelOuter := bvRaised;
  FToolSelector.BevelWidth := 2;
  FToolSelector.BorderStyle := bsNone;
  FToolSelector.ParentColor := False;

  Y := StartY;

  // ------------------------------------------------------------
  // Table
  // ------------------------------------------------------------

  FBtToolTable := TSpeedButton.Create(Self);
  FBtToolTable.Parent := FToolSelector;
  FBtToolTable.SetBounds(
    StartX,
    Y,
   SelectorButtonWidth,
  SelectorButtonHeight
  );
  FBtToolTable.ShowHint := True;
  FBtToolTable.Hint := TRH(FBtToolTable, 'Table settings');
  FBtToolTable.Caption := 'T';
  FBtToolTable.GroupIndex := 1;
  FBtToolTable.AllowAllUp := False;
  FBtToolTable.OnClick := @ToolTableClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Cell
  // ------------------------------------------------------------

  FBtToolCell := TSpeedButton.Create(Self);
  FBtToolCell.Parent := FToolSelector;
  FBtToolCell.SetBounds(
    StartX,
    Y,
    SelectorButtonWidth,
  SelectorButtonHeight
  );
  FBtToolCell.ShowHint := True;
  FBtToolCell.Hint := TRH(FBtToolCell, 'Cell settings');
  FBtToolCell.Caption := 'C';
  FBtToolCell.GroupIndex := 1;
  FBtToolCell.AllowAllUp := False;
  FBtToolCell.OnClick := @ToolCellClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // TextBlock
  // ------------------------------------------------------------

  FBtToolTextBlock := TSpeedButton.Create(Self);
  FBtToolTextBlock.Parent := FToolSelector;
  FBtToolTextBlock.SetBounds(
    StartX,
    Y,
    SelectorButtonWidth,
  SelectorButtonHeight
  );
  FBtToolTextBlock.ShowHint := True;
  FBtToolTextBlock.Hint := TRH(FBtToolTextBlock, 'Text block settings');
  FBtToolTextBlock.Caption := 'B';
  FBtToolTextBlock.GroupIndex := 1;
  FBtToolTextBlock.AllowAllUp := False;
  FBtToolTextBlock.OnClick := @ToolTextBlockClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Settings
  // ------------------------------------------------------------

  FBtToolSettings := TSpeedButton.Create(Self);
  FBtToolSettings.Parent := FToolSelector;
  FBtToolSettings.SetBounds(
    StartX,
    Y,
    SelectorButtonWidth,
  SelectorButtonHeight
  );
  FBtToolSettings.ShowHint := True;
  FBtToolSettings.Hint := TRH(FBtToolSettings, 'Global settings');
  FBtToolSettings.Caption := 'S';
  FBtToolSettings.GroupIndex := 1;
  FBtToolSettings.AllowAllUp := False;
  FBtToolSettings.OnClick := @ToolSettingsClick;

  UpdateToolSelectorIcons;
end;

{ click-events procedures voor speedbuttons op Panel Ftoolselector ------------}

procedure THtmlTableDesignerAdvanced.UpdateToolSelectorIcons;

  procedure LoadIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string
  );
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
      AButton.Caption := AFallbackCaption;
  end;

begin
  LoadIcon(
    FBtToolTable,
    FTableImageIndex,
    'T'
  );

  LoadIcon(
    FBtToolCell,
    FCellImageIndex,
    'C'
  );

  LoadIcon(
    FBtToolTextBlock,
    FTextBlockImageIndex,
    'B'
  );

  LoadIcon(
    FBtToolSettings,
    FSettingsImageIndex,
    'S'
  );
end;

{------------------------------------------------------------------------------}

procedure THtmlTableDesignerAdvanced.ToolTableClick(Sender: TObject);
begin
  ActiveTool := atTable;

   UpdateTableToolStates;

  if Assigned(FOnTableButtonClick) then
    FOnTableButtonClick(Self);
end;

procedure THtmlTableDesignerAdvanced.ToolCellClick(Sender: TObject);
begin
  ActiveTool := atCell;

    UpdateCellToolStates;

  if Assigned(FOnCellButtonClick) then
    FOnCellButtonClick(Self);
end;

procedure THtmlTableDesignerAdvanced.ToolTextBlockClick(Sender: TObject);
begin
  ActiveTool := atTextBlock;

    UpdateTextBlockToolStates;

  if Assigned(FOnTextBlockButtonClick) then
    FOnTextBlockButtonClick(Self);
end;

procedure THtmlTableDesignerAdvanced.ToolSettingsClick(Sender: TObject);
begin
  ActiveTool := atSettings;

  if Assigned(FOnSettingsButtonClick) then
    FOnSettingsButtonClick(Self);
end;


{------------------------------------------------------------------------------}

{ =============================================================================
  IMAGELISTS
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.SetAdvancedImages(
  AValue: TCustomImageList);
begin
  if FAdvancedImages = AValue then
    Exit;

  if Assigned(FAdvancedImages) then
    FAdvancedImages.RemoveFreeNotification(Self);

  FAdvancedImages := AValue;

  if Assigned(FAdvancedImages) then
    FAdvancedImages.FreeNotification(Self);

  UpdateCellToolIcons;
  UpdateTextBlockToolsIcons;
  UpdateTableToolsIcons;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetAdvancedImagesWide(
  AValue: TCustomImageList);
begin
  if FAdvancedImagesWide = AValue then
    Exit;

  if Assigned(FAdvancedImagesWide) then
    FAdvancedImagesWide.RemoveFreeNotification(Self);

  FAdvancedImagesWide := AValue;

  if Assigned(FAdvancedImagesWide) then
    FAdvancedImagesWide.FreeNotification(Self);

  UpdateCellToolIcons;
  UpdateTextBlockToolsIcons;
  UpdateTableToolsIcons;
  UpdateSettingsToolsIcons;
  UpdateToolSelectorIcons;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SetLanguageFlagImages(
  AValue: TCustomImageList);
begin
  if FLanguageFlagImages = AValue then
    Exit;

  if Assigned(FLanguageFlagImages) then
    FLanguageFlagImages.RemoveFreeNotification(Self);

  FLanguageFlagImages := AValue;

  if Assigned(FLanguageFlagImages) then
    FLanguageFlagImages.FreeNotification(Self);

  UpdateLanguageButton;
end;

// Bouwt het uitklapmenu (vlag + taalnaam) en toont op de knop de vlag van
// de gekozen taal. Zonder vlaggen-ImageList: knop met de taalcode als tekst.
procedure THtmlTableDesignerAdvanced.UpdateLanguageButton;
const
  LangNames: array[TUILanguage] of string =
    ('Nederlands', 'English', 'Français', 'Deutsch');
  LangCodes: array[TUILanguage] of string =
    ('NL', 'EN', 'FR', 'DU');
var
  L: TUILanguage;
  MI: TMenuItem;
  HasFlags: Boolean;
begin
  if not Assigned(FBtLanguage) then
    Exit;

  HasFlags := Assigned(FLanguageFlagImages) and
    (FLanguageFlagImages.Count > Ord(High(TUILanguage)));

  if not Assigned(FLanguagePopup) then
    FLanguagePopup := TPopupMenu.Create(Self);

  FLanguagePopup.Items.Clear;
  FLanguagePopup.Images := FLanguageFlagImages;

  for L := Low(TUILanguage) to High(TUILanguage) do
  begin
    MI := TMenuItem.Create(FLanguagePopup);
    MI.Caption := LangNames[L];
    MI.Tag := Ord(L);
    MI.RadioItem := True;
    MI.GroupIndex := 1;
    MI.Checked := L = FSelectedLanguage;
    if HasFlags then
      MI.ImageIndex := Ord(L)
    else
      MI.ImageIndex := -1;
    MI.OnClick := @LanguageMenuClick;
    FLanguagePopup.Items.Add(MI);
  end;

  FBtLanguage.Images := FLanguageFlagImages;
  if HasFlags then
  begin
    FBtLanguage.Caption := '';
    FBtLanguage.ImageIndex := Ord(FSelectedLanguage);
  end
  else
  begin
    FBtLanguage.ImageIndex := -1;
    FBtLanguage.Caption := LangCodes[FSelectedLanguage];
  end;
end;

procedure THtmlTableDesignerAdvanced.LanguageButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  P := FBtLanguage.ClientToScreen(Point(0, FBtLanguage.Height));
  FLanguagePopup.PopUp(P.X, P.Y);
end;

procedure THtmlTableDesignerAdvanced.LanguageMenuClick(Sender: TObject);
begin
  FSelectedLanguage := TUILanguage((Sender as TMenuItem).Tag);
  UpdateLanguageButton;

  // Rechtstreeks kiezen schakelt meteen om (zoals Load/Reset niet doen).
  Language := FSelectedLanguage;
end;

{ -----------------------------------------------------------------------------
  Hoofdselector ImageIndex setters
  Verversen onmiddellijk de vier selector-knoppen wanneer een ImageIndex
  in de Object Inspector of via code wordt gewijzigd.
  ----------------------------------------------------------------------------- }

procedure THtmlTableDesignerAdvanced.SetTableImageIndex(
  AValue: Integer);
begin
  if FTableImageIndex = AValue then
    Exit;

  FTableImageIndex := AValue;
  UpdateToolSelectorIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellImageIndex(
  AValue: Integer);
begin
  if FCellImageIndex = AValue then
    Exit;

  FCellImageIndex := AValue;
  UpdateToolSelectorIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTextBlockImageIndex(
  AValue: Integer);
begin
  if FTextBlockImageIndex = AValue then
    Exit;

  FTextBlockImageIndex := AValue;
  UpdateToolSelectorIcons;
end;

procedure THtmlTableDesignerAdvanced.SetSettingsImageIndex(
  AValue: Integer);
begin
  if FSettingsImageIndex = AValue then
    Exit;

  FSettingsImageIndex := AValue;
  UpdateToolSelectorIcons;
end;

// create ToolSelector panel en speedbuttons
{ =============================================================================
  SETTINGS TOOLS
  ============================================================================= }
procedure THtmlTableDesignerAdvanced.SettingsLoadClick(
  Sender: TObject);
begin
  LoadDefaultSettings;

  SettingsToControls;
  UpdatePageSizeButton;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SettingsSaveClick(
  Sender: TObject);
begin
  ControlsToSettings;

  SaveDefaultSettings;
end;

procedure THtmlTableDesignerAdvanced.SettingsResetClick(Sender: TObject);
begin
   SetFactoryDefaultSettings;
  SettingsToControls;

end;

procedure THtmlTableDesignerAdvanced.SettingsApplyClick(Sender: TObject);
begin
  ApplyDefaultSettings;

end;

procedure THtmlTableDesignerAdvanced.SettingsLanguageClick(Sender: TObject);
var
  DefaultLangFile: string;
begin
  // Automatisch 'talen.lng' naast de .exe inladen als het er staat, zodat
  // de editor meteen met de vertalingen van deze toepassing opent (i.p.v.
  // een lege NL-kolom met toevallig-Engelse broncodetekst). Onschadelijk om
  // dit elke keer opnieuw te doen: bestaande keys worden gewoon herladen.
  DefaultLangFile :=
    IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    'talen.lng';

  if FileExists(DefaultLangFile) then
    HtmlTableDesignerLang.LoadLanguageFile(DefaultLangFile);

  LangEditorForm.ShowLangEditor;

  // De gebruiker kan in de editor net de vertaling van de actieve taal
  // hebben aangepast: meteen opnieuw toepassen zodat de toolbox-hints
  // kloppen zonder dat de gebruiker Language expliciet moet omzetten.
  ApplyLanguage;
end;

procedure THtmlTableDesignerAdvanced.PageSizeButtonClick(
  Sender: TObject);
var
  P: TPoint;
begin
  if not Assigned(FBtSetPageSize) then
    Exit;

  if not Assigned(FPageSizePopup) then
    Exit;

  // Linksonder van de SpeedButton omzetten naar schermcoördinaten
  P := FBtSetPageSize.ClientToScreen(
    Point(0, FBtSetPageSize.Height)
  );

  // Popup direct onder de knop tonen
  FPageSizePopup.PopUp(
    P.X,
    P.Y
  );
end;

procedure THtmlTableDesignerAdvanced.SetSettingsLoadImageIndex(
  AValue: Integer);
begin
  if FSettingsLoadImageIndex = AValue then
    Exit;

  FSettingsLoadImageIndex := AValue;
  UpdateSettingsToolsIcons;
end;


procedure THtmlTableDesignerAdvanced.SetSettingsSaveImageIndex(
  AValue: Integer);
begin
  if FSettingsSaveImageIndex = AValue then
    Exit;

  FSettingsSaveImageIndex := AValue;
  UpdateSettingsToolsIcons;
end;


procedure THtmlTableDesignerAdvanced.SetSettingsResetImageIndex(
  AValue: Integer);
begin
  if FSettingsResetImageIndex = AValue then
    Exit;

  FSettingsResetImageIndex := AValue;
  UpdateSettingsToolsIcons;
end;


procedure THtmlTableDesignerAdvanced.SetSettingsApplyImageIndex(
  AValue: Integer);
begin
  if FSettingsApplyImageIndex = AValue then
    Exit;

  FSettingsApplyImageIndex := AValue;
  UpdateSettingsToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetSettingsLanguageImageIndex(
  AValue: Integer);
begin
  if FSettingsLanguageImageIndex = AValue then
    Exit;

  FSettingsLanguageImageIndex := AValue;
  UpdateSettingsToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetFactoryDefaultSettings;
begin
  // ------------------------------------------------------------
  // Table
  // ------------------------------------------------------------

  FDefaultSettings.DefaultColWidth := 95;
  FDefaultSettings.DefaultRowHeight := 26;

  // ------------------------------------------------------------
  // Grid
  // ------------------------------------------------------------

  FDefaultSettings.GridLineWidth := 1;
  FDefaultSettings.GridColor := clSilver;

  // ------------------------------------------------------------
  // Page
  // ------------------------------------------------------------

  FDefaultSettings.HtmlBgColor := clInfoBk;

  FDefaultSettings.ShowLayoutGrid := False;
  FDefaultSettings.ShowPageRulers := True;
  FDefaultSettings.ShowHeaders := True;

  FDefaultSettings.PageWidth := 794;
  FDefaultSettings.PageHeight := 1123;

  // ------------------------------------------------------------
  // Taal
  // ------------------------------------------------------------

  FDefaultSettings.Language := langNL;

  Invalidate;
end;

procedure THtmlTableDesignerAdvanced.SettingsToControls;
begin
  if FUpdatingSettingsToolStates then
    Exit;

  FUpdatingSettingsToolStates := True;
  try
    if Assigned(FSetDefaultColWidth) then
      FSetDefaultColWidth.Value :=
        FDefaultSettings.DefaultColWidth;

    if Assigned(FSetDefaultRowHeight) then
      FSetDefaultRowHeight.Value :=
        FDefaultSettings.DefaultRowHeight;

    if Assigned(FSetGridLineWidth) then
      FSetGridLineWidth.Value :=
        FDefaultSettings.GridLineWidth;

    if Assigned(FSetGridColor) then
      FSetGridColor.ButtonColor :=
        FDefaultSettings.GridColor;

    if Assigned(FSetHtmlBgColor) then
      FSetHtmlBgColor.ButtonColor :=
        FDefaultSettings.HtmlBgColor;

    if Assigned(FChkShowLayoutGrid) then
      FChkShowLayoutGrid.Checked :=
        FDefaultSettings.ShowLayoutGrid;

    if Assigned(FChkShowPageRulers) then
      FChkShowPageRulers.Checked :=
        FDefaultSettings.ShowPageRulers;

    if Assigned(FChkShowHeaders) then
      FChkShowHeaders.Checked :=
        FDefaultSettings.ShowHeaders;

    // Toont enkel de bewaarde taal op de vlag-knop; omschakelen gebeurt
    // pas bij "Apply" (zoals bij de andere instellingen).
    FSelectedLanguage := FDefaultSettings.Language;
    UpdateLanguageButton;

    UpdatePageSizeButton;

  finally
    FUpdatingSettingsToolStates := False;
  end;
end;

procedure THtmlTableDesignerAdvanced.ControlsToSettings;
begin
  if Assigned(FSetDefaultColWidth) then
    FDefaultSettings.DefaultColWidth :=
      FSetDefaultColWidth.Value;

  if Assigned(FSetDefaultRowHeight) then
    FDefaultSettings.DefaultRowHeight :=
      FSetDefaultRowHeight.Value;

  if Assigned(FSetGridLineWidth) then
    FDefaultSettings.GridLineWidth :=
      FSetGridLineWidth.Value;

  if Assigned(FSetGridColor) then
    FDefaultSettings.GridColor :=
      FSetGridColor.ButtonColor;

  if Assigned(FSetHtmlBgColor) then
    FDefaultSettings.HtmlBgColor :=
      FSetHtmlBgColor.ButtonColor;

  if Assigned(FChkShowLayoutGrid) then
    FDefaultSettings.ShowLayoutGrid :=
      FChkShowLayoutGrid.Checked;

  if Assigned(FChkShowPageRulers) then
    FDefaultSettings.ShowPageRulers :=
      FChkShowPageRulers.Checked;

  if Assigned(FChkShowHeaders) then
    FDefaultSettings.ShowHeaders :=
      FChkShowHeaders.Checked;

  FDefaultSettings.Language := FSelectedLanguage;

end;

procedure THtmlTableDesignerAdvanced.ApplyDefaultSettings;
begin
  ControlsToSettings;

  ApplyColWidthTable(
    FDefaultSettings.DefaultColWidth
  );

  ApplyRowHeightTable(
    FDefaultSettings.DefaultRowHeight
  );

  ApplyGridWidthTable(
    FDefaultSettings.GridLineWidth
  );

  ApplyGridColorTable(
    FDefaultSettings.GridColor
  );

  HtmlBgColor :=
    FDefaultSettings.HtmlBgColor;

  ShowLayoutGrid :=
    FDefaultSettings.ShowLayoutGrid;

  ShowPageRulers :=
    FDefaultSettings.ShowPageRulers;

  ShowHeaders :=
    FDefaultSettings.ShowHeaders;
  // oud
  PageWidth :=
    FDefaultSettings.PageWidth;

  // new
  PageHeight :=
     FDefaultSettings.PageHeight;

  Language := FDefaultSettings.Language;

  UpdateTableToolStates;

  Invalidate;
  DoChange;
end;
procedure THtmlTableDesignerAdvanced.SettingsDefaultColWidthChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not Assigned(FSetDefaultColWidth) then
    Exit;

  FDefaultSettings.DefaultColWidth :=
    FSetDefaultColWidth.Value;
end;


procedure THtmlTableDesignerAdvanced.SettingsDefaultRowHeightChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not Assigned(FSetDefaultRowHeight) then
    Exit;

  FDefaultSettings.DefaultRowHeight :=
    FSetDefaultRowHeight.Value;
end;


procedure THtmlTableDesignerAdvanced.SettingsGridLineWidthChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not Assigned(FSetGridLineWidth) then
    Exit;

  FDefaultSettings.GridLineWidth :=
    FSetGridLineWidth.Value;
end;


procedure THtmlTableDesignerAdvanced.SettingsGridColorChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not Assigned(FSetGridColor) then
    Exit;

  FDefaultSettings.GridColor :=
    FSetGridColor.ButtonColor;
end;

procedure THtmlTableDesignerAdvanced.SettingsHtmlBgColorChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not Assigned(FSetHtmlBgColor) then
    Exit;

  FDefaultSettings.HtmlBgColor :=
    FSetHtmlBgColor.ButtonColor;
end;

procedure THtmlTableDesignerAdvanced.SettingsShowLayoutGridChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if Assigned(FChkShowLayoutGrid) then
    FDefaultSettings.ShowLayoutGrid :=
      FChkShowLayoutGrid.Checked;
end;


procedure THtmlTableDesignerAdvanced.SettingsShowPageRulersChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if Assigned(FChkShowPageRulers) then
    FDefaultSettings.ShowPageRulers :=
      FChkShowPageRulers.Checked;
end;


procedure THtmlTableDesignerAdvanced.SettingsShowHeadersChanged(
  Sender: TObject);
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if Assigned(FChkShowHeaders) then
    FDefaultSettings.ShowHeaders :=
      FChkShowHeaders.Checked;
end;


//new
procedure THtmlTableDesignerAdvanced.CreatePageSizePopup;
var
  Item: TMenuItem;

  procedure AddPageSizeItem(
    const ACaption: string;
    ATag: Integer;
    ASeparatorBefore: Boolean = False);
  begin
    // Eventueel eerst een scheidingslijn
    if ASeparatorBefore then
    begin
      Item := TMenuItem.Create(FPageSizePopup);
      Item.Caption := '-';
      FPageSizePopup.Items.Add(Item);
    end;

    // Eigenlijke menu-item
    Item := TMenuItem.Create(FPageSizePopup);
    Item.Caption := ACaption;
    Item.Tag := ATag;
    Item.OnClick := @PageSizeMenuClick;

    FPageSizePopup.Items.Add(Item);
  end;

begin
  // ------------------------------------------------------------
  // Popup menu
  // ------------------------------------------------------------

  FPageSizePopup := TPopupMenu.Create(Self);

  // ------------------------------------------------------------
  // ISO papierformaten
  // ------------------------------------------------------------

  AddPageSizeItem(
    'A3 Portrait',
    0
  );

  AddPageSizeItem(
    'A3 Landscape',
    1
  );

  AddPageSizeItem(
    'A4 Portrait',
    2,
    True
  );

  AddPageSizeItem(
    'A4 Landscape',
    3
  );

  AddPageSizeItem(
    'A5 Portrait',
    4,
    True
  );

  AddPageSizeItem(
    'A5 Landscape',
    5
  );

  // ------------------------------------------------------------
  // US Letter
  // ------------------------------------------------------------

  AddPageSizeItem(
    'Letter Portrait',
    6,
    True
  );

  AddPageSizeItem(
    'Letter Landscape',
    7
  );
end;

procedure THtmlTableDesignerAdvanced.PageSizeMenuClick(
  Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  if FUpdatingSettingsToolStates then
    Exit;

  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);

  case MenuItem.Tag of

    0: begin // A3 Portrait
         FDefaultSettings.PageWidth  := 1123;
         FDefaultSettings.PageHeight := 1587;
       end;

    1: begin // A3 Landscape
         FDefaultSettings.PageWidth  := 1587;
         FDefaultSettings.PageHeight := 1123;
       end;

    2: begin // A4 Portrait
         FDefaultSettings.PageWidth  := 794;
         FDefaultSettings.PageHeight := 1123;
       end;

    3: begin // A4 Landscape
         FDefaultSettings.PageWidth  := 1123;
         FDefaultSettings.PageHeight := 794;
       end;

    4: begin // A5 Portrait
         FDefaultSettings.PageWidth  := 559;
         FDefaultSettings.PageHeight := 794;
       end;

    5: begin // A5 Landscape
         FDefaultSettings.PageWidth  := 794;
         FDefaultSettings.PageHeight := 559;
       end;

    6: begin // Letter Portrait
         FDefaultSettings.PageWidth  := 816;
         FDefaultSettings.PageHeight := 1056;
       end;

    7: begin // Letter Landscape
         FDefaultSettings.PageWidth  := 1056;
         FDefaultSettings.PageHeight := 816;
       end;

  else
    Exit;
  end;

 { // Tijdelijke PageWidth SpinEdit synchroniseren
  if Assigned(FSetPageWidth) then
    FSetPageWidth.Value :=
      FDefaultSettings.PageWidth;}

  UpdatePageSizeButton;
end;

procedure THtmlTableDesignerAdvanced.UpdatePageSizeButton;
var
  S: string;
begin
  // ------------------------------------------------------------
  // Bepaal het huidige papierformaat
  // ------------------------------------------------------------

  S := '';

  // A3
  if (FDefaultSettings.PageWidth = 1123) and
     (FDefaultSettings.PageHeight = 1587) then
    S := 'A3 Portrait'

  else if (FDefaultSettings.PageWidth = 1587) and
          (FDefaultSettings.PageHeight = 1123) then
    S := 'A3 Landscape'

  // A4
  else if (FDefaultSettings.PageWidth = 794) and
          (FDefaultSettings.PageHeight = 1123) then
    S := 'A4 Portrait'

  else if (FDefaultSettings.PageWidth = 1123) and
          (FDefaultSettings.PageHeight = 794) then
    S := 'A4 Landscape'

  // A5
  else if (FDefaultSettings.PageWidth = 559) and
          (FDefaultSettings.PageHeight = 794) then
    S := 'A5 Portrait'

  else if (FDefaultSettings.PageWidth = 794) and
          (FDefaultSettings.PageHeight = 559) then
    S := 'A5 Landscape'

  // Letter
  else if (FDefaultSettings.PageWidth = 816) and
          (FDefaultSettings.PageHeight = 1056) then
    S := 'Letter Portrait'

  else if (FDefaultSettings.PageWidth = 1056) and
          (FDefaultSettings.PageHeight = 816) then
    S := 'Letter Landscape'

  // Custom
  else
    S := Format(
      'Custom %d x %d',
      [
        FDefaultSettings.PageWidth,
        FDefaultSettings.PageHeight
      ]
    );

  // ------------------------------------------------------------
  // Page Size button
  // ------------------------------------------------------------

  if Assigned(FBtSetPageSize) then
  begin
    // S blijft in het Engels (interne detectiewaarde voor de Pos()-checks
    // hieronder); enkel de weergegeven Hint wordt vertaald.
    FBtSetPageSize.Hint := TRH(FBtSetPageSize, S);
    FBtSetPageSize.ShowHint := True;

    // Korte tekst op de smalle knop
    if Pos('A3 ', S) = 1 then
      FBtSetPageSize.Caption := 'A3'

    else if Pos('A4 ', S) = 1 then
      FBtSetPageSize.Caption := 'A4'

    else if Pos('A5 ', S) = 1 then
      FBtSetPageSize.Caption := 'A5'

    else if Pos('Letter ', S) = 1 then
      FBtSetPageSize.Caption := 'L'

    else
      FBtSetPageSize.Caption := '?';
  end;

  // ------------------------------------------------------------
  // Page Width label
  // ------------------------------------------------------------

  if Assigned(FLblPageWidth) then
  begin
    FLblPageWidth.Caption :=
      IntToStr(FDefaultSettings.PageWidth);

    FLblPageWidth.Hint :=
      Format(TR('Page width: %d px'), [FDefaultSettings.PageWidth]);
  end;

  // ------------------------------------------------------------
  // Page Height label
  // ------------------------------------------------------------

  if Assigned(FLblPageHeight) then
  begin
    FLblPageHeight.Caption :=
      IntToStr(FDefaultSettings.PageHeight);

    FLblPageHeight.Hint :=
      Format(TR('Page height: %d px'), [FDefaultSettings.PageHeight]);
  end;
end;

{ =============================================================================
  TABLE TOOLS
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.SetImageIndexTableNew(
  AValue: Integer);
begin
  if FTableNewImageIndex = AValue then
    Exit;
  FTableNewImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableAddRow(
  AValue: Integer);
begin
  if FTableAddRowImageIndex = AValue then
    Exit;

  FTableAddRowImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableAddColumn(
  AValue: Integer);
begin
  if FTableAddColumnImageIndex = AValue then
    Exit;

  FTableAddColumnImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableDeleteRow(
  AValue: Integer);
begin
  if FTableDeleteRowImageIndex = AValue then
    Exit;

  FTableDeleteRowImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableDeleteColumn(
  AValue: Integer);
begin
  if FTableDeleteColumnImageIndex = AValue then
    Exit;

  FTableDeleteColumnImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableMergeCells(
  AValue: Integer);
begin
  if FTableMergeCellsImageIndex = AValue then
    Exit;

  FTableMergeCellsImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageIndexTableUnMergeCells(
  AValue: Integer);
begin
  if FTableUnMergeCellsImageIndex = AValue then
    Exit;

  FTableUnMergeCellsImageIndex := AValue;
  UpdateTableToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.CreateTableTools;
const
  Gap     = 3;
  StartX  = 0;
  StartY  = 0;
var
  Y: Integer;
begin
  Y := StartY;


  // Add new table  1
  FBtTableNew := TSpeedButton.Create(Self);
  FBtTableNew.Parent := FTabTable;
  FBtTableNew.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableNew.GroupIndex := 0;
  FBtTableNew.AllowAllUp := True;
  FBtTableNew.OnClick := @TableAddNewClick ;
  FBtTableNew.Caption := 'NT';
  FBtTableNew.Font.Style := [];
  FBtTableNew.Hint := TRH(FBtTableNew, 'Clear table-cells content');
  FBtTableNew.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // add Row   2
  FBtTableAddRow := TSpeedButton.Create(Self);
  FBtTableAddRow.Parent := FTabTable;
  FBtTableAddRow.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableAddRow.GroupIndex := 0;
  FBtTableAddRow.AllowAllUp := True;
  FBtTableAddRow.OnClick := @TableAddRowClick ;
  FBtTableAddRow.Caption := 'AR';
  FBtTableAddRow.Font.Style := [];
  FBtTableAddRow.Hint := TRH(FBtTableAddRow, 'Add row');
  FBtTableNew.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // add column  3
  FBtTableAddColumn := TSpeedButton.Create(Self);
  FBtTableAddColumn.Parent := FTabTable;
  FBtTableAddColumn.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableAddColumn.GroupIndex := 0;
  FBtTableAddColumn.AllowAllUp := True;
  FBtTableAddColumn.OnClick := @TableAddColumnClick ;
  FBtTableAddColumn.Caption := 'AC';
  FBtTableAddColumn.Font.Style := [];
  FBtTableAddColumn.Hint := TRH(FBtTableAddColumn, 'Add column');
  FBtTableAddColumn.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // delete row  4
  FBtTableDeleteRow := TSpeedButton.Create(Self);
  FBtTableDeleteRow.Parent := FTabTable;
  FBtTableDeleteRow.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableDeleteRow.GroupIndex := 0;
  FBtTableDeleteRow.AllowAllUp := True;
  FBtTableDeleteRow.OnClick := @TableDeleteRowClick ;
  FBtTableDeleteRow.Caption := 'DR';
  FBtTableDeleteRow.Font.Style := [];
  FBtTableDeleteRow.Hint := TRH(FBtTableDeleteRow, 'Delete row');
  FBtTableAddColumn.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // delete column  5
  FBtTableDeleteColumn := TSpeedButton.Create(Self);
  FBtTableDeleteColumn.Parent := FTabTable;
  FBtTableDeleteColumn.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableDeleteColumn.GroupIndex := 0;
  FBtTableDeleteColumn.AllowAllUp := True;
  FBtTableDeleteColumn.OnClick := @TableDeleteColumnClick ;
  FBtTableDeleteColumn.Caption := 'DC';
  FBtTableDeleteColumn.Font.Style := [];
  FBtTableDeleteColumn.Hint := TRH(FBtTableDeleteColumn, 'Delete column');
  FBtTableDeleteColumn.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // Merge cells
  FBtTableMergeCells := TSpeedButton.Create(Self);
  FBtTableMergeCells.Parent := FTabTable;
  FBtTableMergeCells.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableMergeCells.GroupIndex := 0;
  FBtTableMergeCells.AllowAllUp := True;
  FBtTableMergeCells.OnClick := @TableMergeCellsClick ;
  FBtTableMergeCells.Caption := 'MC';
  FBtTableMergeCells.Font.Style := [];
  FBtTableMergeCells.Hint := TRH(FBtTableMergeCells, 'Merge cells');
  FBtTableMergeCells.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);

  // Unmerge cells
  FBtTableUnMergeCells := TSpeedButton.Create(Self);
  FBtTableUnMergeCells.Parent := FTabTable;
  FBtTableUnMergeCells.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTableUnMergeCells.GroupIndex := 0;
  FBtTableUnMergeCells.AllowAllUp := True;
  FBtTableUnMergeCells.OnClick := @TableUnMergeCellsClick ;
  FBtTableUnMergeCells.Caption := 'UMC';
  FBtTableUnMergeCells.Font.Style := [];
  FBtTableUnMergeCells.Hint := TRH(FBtTableUnMergeCells, 'UnMerge cells');
  FBtTableUnMergeCells.ShowHint := True;

  Inc(Y, FToolButtonHeight + Gap);
  //----------------------------------------------------------------------------
  // nog bij te voegen
  //----------------------------------------------------------------------------

  // Grid Line width  6
  FBtTableGridLineWidth := TSpinEdit.Create(Self);
  FBtTableGridLineWidth.Parent := FTabTable;
  FBtTableGridLineWidth.Hint := TRH(FBtTableGridLineWidth, 'Change Grid Line width');
  FBtTableGridLineWidth.ShowHint := True;
  FBtTableGridLineWidth.AutoSize :=false;
  FBtTableGridLineWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtTableGridLineWidth.MinValue := 1;
  FBtTableGridLineWidth.MaxValue := 5;
  FBtTableGridLineWidth.Value := 1;
  FBtTableGridLineWidth.Increment:=1;
  FBtTableGridLineWidth.OnChange := @TableGridLineSizeChanged;

  Inc(Y, FToolButtonHeight + Gap);

   // Grid Row height  7
  FBtTableRowHeight := TSpinEdit.Create(Self);
  FBtTableRowHeight.Parent := FTabTable;
  FBtTableRowHeight.Hint := TRH(FBtTableRowHeight, 'Grid Row height');
  FBtTableRowHeight.ShowHint := True;
  FBtTableRowHeight.AutoSize :=false;
  FBtTableRowHeight.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtTableRowHeight.MinValue := 15;
  FBtTableRowHeight.MaxValue := 50;
  FBtTableRowHeight.Value := 26;
  FBtTableRowHeight.Increment:=3;
  FBtTableRowHeight.OnChange := @TableRowHeightChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // Grid Column Width   8
  FBtTableColumnWidth := TSpinEdit.Create(Self);
  FBtTableColumnWidth.Parent := FTabTable;
  FBtTableColumnWidth.Hint := TRH(FBtTableColumnWidth, 'Grid Column width');
  FBtTableColumnWidth.ShowHint := True;
  FBtTableColumnWidth.AutoSize :=false;
  FBtTableColumnWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtTableColumnWidth.MinValue := 15;
  FBtTableColumnWidth.MaxValue := 200;
  FBtTableColumnWidth.Value := 26;
  FBtTableColumnWidth.Increment:=3;
    FBtTableColumnWidth.OnChange := @TableColumnWidthChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // Table move  X    9

  FBtTableMoveX := TSpinEdit.Create(Self);
  FBtTableMoveX.Parent := FTabTable;
  FBtTableMoveX.Hint := TRH(FBtTableMoveX, ' Hold Ctrl and drag the table with the mouse' + LineEnding +
                        ' OR'  + LineEnding +'change only Horizontally( X )');


  FBtTableMoveX.ShowHint := True;
  FBtTableMoveX.AutoSize :=false;
  FBtTableMoveX.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtTableMoveX.MinValue := 0;
  FBtTableMoveX.MaxValue := 500;
  FBtTableMoveX.Value := 0;
  FBtTableMoveX.Increment:=1;
     FBtTableMoveX.OnChange := @TableMoveXChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // Table move  Y   10

  FBtTableMoveY := TSpinEdit.Create(Self);
  FBtTableMoveY.Parent := FTabTable;
  FBtTableMoveY.Hint := TRH(FBtTableMoveY, ' Hold Ctrl and drag the table with the mouse' + LineEnding +
                        ' OR'  + LineEnding +
                        ' change only Vertically( Y )');
  FBtTableMoveY.ShowHint := True;
  FBtTableMoveY.AutoSize :=false;
  FBtTableMoveY.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtTableMoveY.MinValue := 0;
  FBtTableMoveY.MaxValue := 500;
  FBtTableMoveY.Value := 0;
  FBtTableMoveY.Increment:=1;
      FBtTableMoveY.OnChange := @TableMoveYChanged;

    Inc(Y, FToolButtonHeight + Gap);

  // Table border color     11

  FBtTableBorderColor := TColorButton.Create(Self);
  FBtTableBorderColor.Parent := FTabTable;
  FBtTableBorderColor.Hint := TRH(FBtTableBorderColor, 'Table border color');
  FBtTableBorderColor.ShowHint := True;

  FBtTableBorderColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );

   FBtTableBorderColor.OnColorChanged := @TableBorderColorChanged;

   Inc(Y, FToolButtonHeight + Gap);

  // Table Border width 12

  FBtTableBorderWidth := TSpinEdit.Create(Self);
  FBtTableBorderWidth.Parent := FTabTable;
  FBtTableBorderWidth.Hint := TRH(FBtTableBorderWidth, 'Table border width');
  FBtTableBorderWidth.ShowHint := True;
  FBtTableBorderWidth.AutoSize :=false;
  FBtTableBorderWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
   FBtTableBorderWidth.MinValue := 1;
   FBtTableBorderWidth.MaxValue := 5;
   FBtTableBorderWidth.Value := 1;

   FBtTableBorderWidth.OnChange := @TableBorderWidthChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // Table border radius 13
  FBtTableBorderRadius := TSpinEdit.Create(Self);
  FBtTableBorderRadius.Parent:=FTabTable;

  FBtTableBorderRadius.Hint := TRH(FBtTableBorderRadius, 'Table border radius');
  FBtTableBorderRadius.ShowHint := True;
  FBtTableBorderRadius.Parent := FTabTable;
  FBtTableBorderRadius.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
   FBtTableBorderRadius.MinValue := 0;
   FBtTableBorderRadius.MaxValue := 90;
   FBtTableBorderRadius.Value := 0;
   FBtTableBorderRadius.Increment:=5;

   FBtTableBorderRadius.OnChange := @TableBorderRadiusChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // Cell corner radius (geldt voor alle cellen van de tabel)
  FBtCellRadius := TSpinEdit.Create(Self);
  FBtCellRadius.Parent := FTabTable;
  FBtCellRadius.Hint := TRH(FBtCellRadius, 'Corner radius " cells" ');
  FBtCellRadius.ShowHint := True;
  FBtCellRadius.AutoSize :=false;
  FBtCellRadius.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );
  FBtCellRadius.MinValue := 0;
  FBtCellRadius.MaxValue := 90;
  FBtCellRadius.Value := 0;
  FBtCellRadius.Increment:= 5;
  FBtCellRadius.OnChange := @CellRadiusChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // TableBackground Color 14

   FBtTableBackgroundColor := TColorButton.Create(Self);
   FBtTableBackgroundColor.Parent := FTabTable;
   FBtTableBackgroundColor.Hint := TRH(FBtTableBackgroundColor, 'Table background color');
   FBtTableBackgroundColor.ShowHint := True;

   FBtTableBackgroundColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );

  FBtTableBackgroundColor.OnColorChanged := @TablebackgroundColorChanged;

   Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Header Color
  // ------------------------------------------------------------

   FTableHeaderColor := TColorButton.Create(Self);
   FTableHeaderColor.Parent := FTabTable;
   FTableHeaderColor.ButtonColor := HeaderColor;
   FTableHeaderColor.Hint := TRH(FTableHeaderColor, 'Header color');
   FTableHeaderColor.ShowHint := True;
   FTableHeaderColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
    );

   FTableHeaderColor.OnColorChanged :=
     @TableHeaderColorChanged;


   Inc(Y, FToolButtonHeight + Gap);


  // Table border style 15

   FBtTableBorderStyle := TBorderStyleButton.Create(Self);
   FBtTableBorderStyle.Parent:= FTabTable;
   FBtTableBorderStyle.BorderStyle := vbsSolid;
   FBtTableBorderStyle.Color:=clInfoBk;
   FBtTableBorderStyle.SetBounds(
    StartX,
    Y + 8,
    FToolButtonWidth,
    25
  );
  FBtTableBorderStyle.ShowHint := True;
  FBtTableBorderStyle.Hint := TRH(FBtTableBorderStyle, 'Table Border Style');

  FBtTableBorderStyle.OnChange := @TableBorderStyleChange;

 UpdateTableToolsIcons;
 UpdateTableToolsLayout;
end;

procedure THtmlTableDesignerAdvanced.UpdateTableToolsLayout;
const
  Gap      = 4;
  GroupGap = 10;
  StartX   = 0;
  StartY   = 0;
var
  Y: Integer;

  procedure PlaceControl(
    AControl: TControl;
    AGroupEnd: Boolean = False);
  begin
    if not Assigned(AControl) then
      Exit;

    AControl.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight + 5
    );

    if AGroupEnd then
      Inc(Y, FToolButtonHeight + GroupGap)
    else
      Inc(Y, FToolButtonHeight + Gap);
  end;

begin
  Y := StartY;

  // ------------------------------------------------------------
  // Table structure
  // ------------------------------------------------------------

  PlaceControl(FBtTableNew);
  PlaceControl(FBtTableAddRow);
  PlaceControl(FBtTableAddColumn);
  PlaceControl(FBtTableDeleteRow);
  PlaceControl(FBtTableDeleteColumn, True);

  // ------------------------------------------------------------
  // Merge / unmerge cells
  // ------------------------------------------------------------

  PlaceControl(FBtTableMergeCells);
  PlaceControl(FBtTableUnMergeCells, True);

  // ------------------------------------------------------------
  // Table dimensions / grid
  // ------------------------------------------------------------

  PlaceControl(FBtTableGridLineWidth);
  PlaceControl(FBtTableRowHeight);
  PlaceControl(FBtTableColumnWidth, True);

  // ------------------------------------------------------------
  // Table position
  // ------------------------------------------------------------

  PlaceControl(FBtTableMoveX);
  PlaceControl(FBtTableMoveY, True);

  // ------------------------------------------------------------
  // Table colors
  // ------------------------------------------------------------

  PlaceControl(FBtTableBackgroundColor);
  PlaceControl(FTableHeaderColor);
  PlaceControl(FBtTableBorderColor, True);

  // ------------------------------------------------------------
  // Table border
  // ------------------------------------------------------------

  PlaceControl(FBtTableBorderWidth);
  PlaceControl(FBtTableBorderRadius);
  PlaceControl(FBtCellRadius, True);

  // ------------------------------------------------------------
  // Border style - altijd als laatste
  // ------------------------------------------------------------

  if Assigned(FBtTableBorderStyle) then
  begin
    FBtTableBorderStyle.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      28
    );
  end;
end;
procedure THtmlTableDesignerAdvanced.UpdateTableToolsHeight;
begin
  UpdateToolsHeight(
    FAantalTableButtons
  );
end;

procedure THtmlTableDesignerAdvanced.UpdateTableToolStates;
begin
  if FUpdatingTableToolStates then
    Exit;

  FUpdatingTableToolStates := True;
  try
    if Assigned(FBtTableGridLineWidth) then
      FBtTableGridLineWidth.Value := GridLineWidth;

    if Assigned(FBtTableRowHeight) then
      FBtTableRowHeight.Value := DefaultRowHeight;

    if Assigned(FBtTableColumnWidth) then
      FBtTableColumnWidth.Value := DefaultColWidth;

    if Assigned(FBtTableMoveX) then
      FBtTableMoveX.Value := TableOffsetToMM(TableOffsetX);

    if Assigned(FBtTableMoveY) then
      FBtTableMoveY.Value := TableOffsetToMM(TableOffsetY);

    if Assigned(FBtTableBorderColor) then
      FBtTableBorderColor.ButtonColor := ExportTableBorderColor;


    if Assigned(FBtTableBorderWidth) then
      FBtTableBorderWidth.Value := ExportTableBorderWidth;

    if Assigned(FBtTableBorderRadius) then
      FBtTableBorderRadius.Value := ExportTableBorderRadius;

    if Assigned(FBtCellRadius) then
      FBtCellRadius.Value := CellAfronding;

    if Assigned(FBtTableBackgroundColor) then
      FBtTableBackgroundColor.ButtonColor := ExportTableBgColor;

    if Assigned(FTableHeaderColor) then
      FTableHeaderColor.ButtonColor := HeaderColor;

    if Assigned(FBtTableBorderStyle) then
    begin
      case ExportTableBorderStyle of
        cbsNone:
          FBtTableBorderStyle.BorderStyle := vbsNone;

        cbsSolid:
          FBtTableBorderStyle.BorderStyle := vbsSolid;

        cbsDashed:
          FBtTableBorderStyle.BorderStyle := vbsDashed;

        cbsDotted:
          FBtTableBorderStyle.BorderStyle := vbsDotted;

        cbsDouble:
          FBtTableBorderStyle.BorderStyle := vbsDouble;
      end;
    end;

  finally
    FUpdatingTableToolStates := False;
  end;
end;

// click-events Crll buttons ToolBox

procedure THtmlTableDesignerAdvanced.UpdateTableToolsIcons;

  procedure LoadButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
    begin
      AButton.Caption := AFallbackCaption;
    end;
  end;

  procedure LoadWideButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
      AButton.Caption := AFallbackCaption;
  end;


begin
  LoadWideButtonIcon(
    FBtTableNew,
    FTableNewImageIndex,
    'NT'
  );

  LoadWideButtonIcon(
    FBtTableAddRow,
    FTableAddRowImageIndex,
    'AR'
  );

  LoadWideButtonIcon(
    FBtTableAddColumn,
    FTableAddColumnImageIndex,
    'AC'
  );

  LoadWideButtonIcon(
    FBtTableDeleteRow,
    FTableDeleteRowImageIndex,
    'DR'
  );

  LoadWideButtonIcon(
    FBtTableDeleteColumn,
    FTableDeleteColumnImageIndex,
    'DC'
  );

  LoadWideButtonIcon(
    FBtTableMergeCells,
    FTableMergeCellsImageIndex,
    'MC'
  );

  LoadWideButtonIcon(
    FBtTableUnMergeCells,
    FTableUnMergeCellsImageIndex,
    'UMC'
  );
end;

procedure THtmlTableDesignerAdvanced.TableAddNewClick(Sender: TObject);
Begin
 Clear;
 Invalidate;
end;

procedure THtmlTableDesignerAdvanced.TableAddRowClick(Sender: TObject);
Begin
  RowCount := RowCount + 1;
  //invalidate;
end;

procedure THtmlTableDesignerAdvanced.TableAddColumnClick(Sender: TObject);
Begin
 ColCount := ColCount + 1;
// invalidate;
end;

procedure THtmlTableDesignerAdvanced.TableDeleteRowClick(Sender: TObject);
Begin
   if SelectionMode <> smRow then
  begin
    ShowMessage(TR('Klik eerst op een rijheader.'));
    Exit;
  end;

  if RowTouchesMergedCell(SelectedRow) then
     UnmergeRow(SelectedRow);

  DeleteRow(SelectedRow);
end;

procedure THtmlTableDesignerAdvanced.TableDeleteColumnClick(Sender: TObject);
Begin
   if SelectionMode <> smCol then
  begin
    ShowMessage(TR('Klik eerst op een kolomheader.'));
    Exit;
  end;

  if ColTouchesMergedCell(SelectedCol) then
    UnmergeCol(SelectedCol);

  DeleteCol(SelectedCol);
end;
{
procedure THtmlTableDesignerAdvanced.TableGridLineSizeChanged(Sender: TObject);
begin
  showMessage('Grid Line width');
end;

procedure THtmlTableDesignerAdvanced.TableRowHeightChanged(Sender: TObject);
begin
  showMessage('Row height');
end;

procedure THtmlTableDesignerAdvanced.TableColumnWidthChanged(Sender: TObject);
begin
  showMessage('Column width');
end;

procedure THtmlTableDesignerAdvanced.TableMoveXChanged(Sender: TObject);
begin
  showMessage('Table move X');
end;

procedure THtmlTableDesignerAdvanced.TableMoveYChanged(Sender: TObject);
begin
  showMessage('Table move Y');
end;

procedure THtmlTableDesignerAdvanced.TableBorderColorChanged(Sender: TObject);
begin
  showMessage('Table border color');
end;

procedure THtmlTableDesignerAdvanced.TableBorderWidthChanged(Sender: TObject);
begin
  showMessage('Table border width');
end;

procedure THtmlTableDesignerAdvanced.TableBorderRadiusChanged(Sender: TObject);
begin
  showMessage('Table border radius');
end;

procedure THtmlTableDesignerAdvanced.TablebackgroundColorChanged(Sender: TObject);
begin
  showMessage('Table bachground color');
end;

procedure THtmlTableDesignerAdvanced.TableBorderStyleChange(Sender: TObject);
begin
  showMessage('Table border style');
end;}

procedure THtmlTableDesignerAdvanced.TableGridLineSizeChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableGridLineWidth) then
    Exit;

  ApplyGridWidthTable(
    FBtTableGridLineWidth.Value
  );
end;


procedure THtmlTableDesignerAdvanced.TableRowHeightChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableRowHeight) then
    Exit;

  ApplyRowHeightTable(
    FBtTableRowHeight.Value
  );
end;


procedure THtmlTableDesignerAdvanced.TableColumnWidthChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableColumnWidth) then
    Exit;

  ApplyColWidthTable(
    FBtTableColumnWidth.Value
  );
end;


procedure THtmlTableDesignerAdvanced.TableMoveXChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableMoveX) then
    Exit;

  if TableOffsetX = MMToTableOffset(FBtTableMoveX.Value) then
    Exit;

  TableOffsetX := MMToTableOffset(FBtTableMoveX.Value);

  Invalidate;
  DoChange;
end;


procedure THtmlTableDesignerAdvanced.TableMoveYChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableMoveY) then
    Exit;

  if TableOffsetY = MMToTableOffset(FBtTableMoveY.Value) then
    Exit;

  TableOffsetY := MMToTableOffset(FBtTableMoveY.Value);

  Invalidate;
  DoChange;
end;

// Pixel-offset (TableOffsetX/Y) -> mm op de ruler
function THtmlTableDesignerAdvanced.TableOffsetToMM(
  AOffset: Integer): Integer;
var
  PxPerMM: Double;
begin
  // MMToPX(1000) i.p.v. MMToPX(1) om afrondingsfouten te vermijden
  PxPerMM := MMToPX(1000) / 1000;

  if PxPerMM <= 0 then
    Exit(0);

  Result := Round((AOffset - TableRulerZero) / PxPerMM);
end;

// mm op de ruler -> pixel-offset (TableOffsetX/Y)
function THtmlTableDesignerAdvanced.MMToTableOffset(
  AMM: Integer): Integer;
begin
  Result := TableRulerZero + MMToPX(AMM);
end;


procedure THtmlTableDesignerAdvanced.TableBorderColorChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableBorderColor) then
    Exit;

  ApplyKaderColorTable(
    FBtTableBorderColor.ButtonColor
  );
end;


procedure THtmlTableDesignerAdvanced.TableBorderWidthChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableBorderWidth) then
    Exit;

  ApplyBorderWidthTable(
    FBtTableBorderWidth.Value
  );
end;


procedure THtmlTableDesignerAdvanced.TableBorderRadiusChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableBorderRadius) then
    Exit;

  ApplyBorderRadiusTable(
    FBtTableBorderRadius.Value
  );
end;


procedure THtmlTableDesignerAdvanced.TablebackgroundColorChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableBackgroundColor) then
    Exit;

  ApplyBgColorTable(
    FBtTableBackgroundColor.ButtonColor
  );
end;


procedure THtmlTableDesignerAdvanced.TableBorderStyleChange(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FBtTableBorderStyle) then
    Exit;

  case FBtTableBorderStyle.BorderStyle of
    vbsNone:
      ApplyBorderStyleTable(cbsNone);

    vbsSolid:
      ApplyBorderStyleTable(cbsSolid);

    vbsDashed:
      ApplyBorderStyleTable(cbsDashed);

    vbsDotted:
      ApplyBorderStyleTable(cbsDotted);

    vbsDouble:
      ApplyBorderStyleTable(cbsDouble);
  end;
end;
// new
procedure THtmlTableDesignerAdvanced.TableHeaderColorChanged(
  Sender: TObject);
begin
  if FUpdatingTableToolStates then
    Exit;

  if not Assigned(FTableHeaderColor) then
    Exit;

  HeaderColor := FTableHeaderColor.ButtonColor;

  Invalidate;
  DoChange;
end;

procedure THtmlTableDesignerAdvanced.TableMergeCellsClick(Sender: TObject);
Begin
 MergeSelection;
end;

procedure THtmlTableDesignerAdvanced.TableUnMergeCellsClick(Sender: TObject);
Begin
   UnMergeSelection;
end;

//------------------------------------------------------------------------------

{ =============================================================================
  CELL TOOLS
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.SetCellBoldImageIndex(
  AValue: Integer);
begin
  if FCellBoldImageIndex = AValue then Exit;
  FCellBoldImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellItalicImageIndex(
  AValue: Integer);
begin
  if FCellItalicImageIndex = AValue then Exit;
  FCellItalicImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellUnderlineImageIndex(
  AValue: Integer);
begin
  if FCellUnderlineImageIndex = AValue then Exit;
  FCellUnderlineImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellAlignLeftImageIndex(
  AValue: Integer);
begin
  if FCellAlignLeftImageIndex = AValue then Exit;
  FCellAlignLeftImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellAlignCenterImageIndex(
  AValue: Integer);
begin
  if FCellAlignCenterImageIndex = AValue then Exit;
  FCellAlignCenterImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellAlignRightImageIndex(
  AValue: Integer);
begin
  if FCellAlignRightImageIndex = AValue then Exit;
  FCellAlignRightImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellCreateTextHyperlinkImageIndex(
  AValue: Integer);
begin
  if FCellCreateTextHyperlinkImageIndex = AValue then
    Exit;

  FCellCreateTextHyperlinkImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellDelTextHyperlinkImageIndex(
  AValue: Integer);
begin
  if FCellDelTextHyperlinkImageIndex = AValue then
    Exit;

  FCellDelTextHyperlinkImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellCopyImageIndex(
  AValue: Integer);
begin
  if FCellCopyImageIndex = AValue then
    Exit;

  FCellCopyImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellPasteImageIndex(
  AValue: Integer);
begin
  if FCellPasteImageIndex = AValue then
    Exit;

  FCellPasteImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellCreateHyperlinkImageIndex(
  AValue: Integer);
begin
  if FCellCreateHyperlinkImageIndex = AValue then
    Exit;

  FCellCreateHyperlinkImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetCellDelHyperlinkImageIndex(
  AValue: Integer);
begin
  if FCellDelHyperlinkImageIndex = AValue then
    Exit;

  FCellDelHyperlinkImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetAddImageImageIndex(
  AValue: Integer);
begin
  if FAddImageImageIndex = AValue then
    Exit;

  FAddImageImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetDelImageImageIndex(
  AValue: Integer);
begin
  if FDelImageImageIndex = AValue then
    Exit;

  FDelImageImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageLeftImageIndex(
  AValue: Integer);
begin
  if FImageLeftImageIndex = AValue then
    Exit;

  FImageLeftImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageCenterImageIndex(
  AValue: Integer);
begin
  if FImageCenterImageIndex = AValue then
    Exit;

  FImageCenterImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageRightImageIndex(
  AValue: Integer);
begin
  if FImageRightImageIndex = AValue then
    Exit;

  FImageRightImageIndex := AValue;
  UpdateCellToolIcons;
end;

procedure THtmlTableDesignerAdvanced.SetImageSizeImageIndex(
  AValue: Integer);
begin
  if FImageSizeImageIndex = AValue then
    Exit;

  FImageSizeImageIndex := AValue;
  UpdateCellToolIcons;
end;

// setter  Settings-image indexen

procedure THtmlTableDesignerAdvanced.CreateCellTools;
const
  Gap     = 3;
  StartX  = 0;
  StartY  = 0;
var
  Y: Integer;
begin
  Y := StartY;

  // ------------------------------------------------------------
  // Bold
  // ------------------------------------------------------------

  FBtCellBold := TSpeedButton.Create(Self);
  FBtCellBold.Parent := FTabCell;
  FBtCellBold.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight //BtnSize
  );
  FBtCellBold.GroupIndex := 1;
  FBtCellBold.AllowAllUp := True;

  FBtCellBold.Caption := 'B';
  FBtCellBold.Font.Style := [fsBold];
  FBtCellBold.Hint := TRH(FBtCellBold, 'Bold');
  FBtCellBold.ShowHint := True;
  FBtCellBold.OnClick := @CellBoldClick;


  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Italic
  // ------------------------------------------------------------

  FBtCellItalic := TSpeedButton.Create(Self);
  FBtCellItalic.Parent := FTabCell;
  FBtCellItalic.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight //BtnSize
  );
  FBtCellItalic.GroupIndex := 2;
  FBtCellItalic.AllowAllUp := True;

  FBtCellItalic.Caption := 'I';
  FBtCellItalic.Font.Style := [fsItalic];
  FBtCellItalic.Hint := TRH(FBtCellItalic, 'Italic');
  FBtCellItalic.ShowHint := True;
  FBtCellItalic.OnClick := @CellItalicClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Underline
  // ------------------------------------------------------------

  FBtCellUnderline := TSpeedButton.Create(Self);
  FBtCellUnderline.Parent := FTabCell;
  FBtCellUnderline.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight //BtnSize
  );
  FBtCellUnderline.GroupIndex := 3;
  FBtCellUnderline.AllowAllUp := True;

  FBtCellUnderline.Caption := 'U';
  FBtCellUnderline.Font.Style := [fsUnderline];
  FBtCellUnderline.Hint := TRH(FBtCellUnderline, 'Underline');
  FBtCellUnderline.ShowHint := True;
  FBtCellUnderline.OnClick := @CellUnderlineClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Align Left
  // ------------------------------------------------------------

  FBtCellAlignLeft := TSpeedButton.Create(Self);
  FBtCellAlignLeft.Parent := FTabCell;
  FBtCellAlignLeft.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight //BtnSize
  );
  FBtCellAlignLeft.GroupIndex := 10;
  FBtCellAlignLeft.AllowAllUp := False;

  FBtCellAlignLeft.Caption := 'L';
  FBtCellAlignLeft.Hint := TRH(FBtCellAlignLeft, 'Align left');
  FBtCellAlignLeft.ShowHint := True;
  FBtCellAlignLeft.OnClick := @CellAlignLeftClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Align Center
  // ------------------------------------------------------------

  FBtCellAlignCenter := TSpeedButton.Create(Self);
  FBtCellAlignCenter.Parent := FTabCell;
  FBtCellAlignCenter.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight //BtnSize
  );
  FBtCellAlignCenter.GroupIndex := 10;
  FBtCellAlignCenter.AllowAllUp := False;

  FBtCellAlignCenter.Caption := 'C';
  FBtCellAlignCenter.Hint := TRH(FBtCellAlignCenter, 'Align center');
  FBtCellAlignCenter.ShowHint := True;
  FBtCellAlignCenter.OnClick := @CellAlignCenterClick;

  Inc(Y, FToolButtonHeight + Gap);


  // ------------------------------------------------------------
  // Align Right
  // ------------------------------------------------------------

  FBtCellAlignRight := TSpeedButton.Create(Self);
  FBtCellAlignRight.Parent := FTabCell;
  FBtCellAlignRight.Flat:=false;
  FBtCellAlignRight.Transparent:=True;
  FBtCellAlignRight.Alignment:=taCenter;
  FBtCellAlignRight.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtCellAlignRight.GroupIndex := 10;
  FBtCellAlignRight.AllowAllUp := False;

  FBtCellAlignRight.Caption := 'R';
  FBtCellAlignRight.Hint := TRH(FBtCellAlignRight, 'Align right');
  FBtCellAlignRight.ShowHint := True;
  FBtCellAlignRight.OnClick := @CellAlignRightClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // create Hyperlink  Text
  // ------------------------------------------------------------

  FBtCellCreateTextHyperlink := TSpeedButton.Create(Self);
  FBtCellCreateTextHyperlink.Parent := FTabCell;
  FBtCellCreateTextHyperlink.SetBounds(
  StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtCellCreateTextHyperlink.Caption := 'TH+';
  FBtCellCreateTextHyperlink.Hint := TRH(FBtCellCreateTextHyperlink, 'Create text hyperlink');
  FBtCellCreateTextHyperlink.ShowHint := True;
  FBtCellCreateTextHyperlink.OnClick := @CellCreateTextHyperlinkClick;

  Inc(Y, FToolButtonHeight + Gap);
  // ------------------------------------------------------------
  // Delete Hyperlink  Text
  // ------------------------------------------------------------

  FBtCellDelTextHyperlink := TSpeedButton.Create(Self);
  FBtCellDelTextHyperlink.Parent := FTabCell;
  FBtCellDelTextHyperlink.SetBounds(
  StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtCellDelTextHyperlink.Caption := 'TH-';
  FBtCellDelTextHyperlink.Hint := TRH(FBtCellDelTextHyperlink, 'Delete text hyperlink');
  FBtCellDelTextHyperlink.ShowHint := True;
  FBtCellDelTextHyperlink.OnClick := @CellDelTextHyperlinkClick;

  Inc(Y, FToolButtonHeight + Gap );

  // Copy
  FBtCellCopy := TSpeedButton.Create(Self);
  FBtCellCopy.Parent := FTabCell;
  FBtCellCopy.SetBounds(
  StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtCellCopy.Caption := 'CP';
  FBtCellCopy.Hint := TRH(FBtCellCopy, 'Copy cell');
  FBtCellCopy.ShowHint := True;
  FBtCellCopy.OnClick := @CellCopyClick;

  Inc(Y, FToolButtonHeight + Gap);

  // Paste
  FBtCellPaste := TSpeedButton.Create(Self);
  FBtCellPaste.Parent := FTabCell;
  FBtCellPaste.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
  );
  FBtCellPaste.Caption := 'PS';
  FBtCellPaste.Hint := TRH(FBtCellPaste, 'Paste cell');
  FBtCellPaste.ShowHint := True;
  FBtCellPaste.OnClick := @CellPasteClick;

  Inc(Y, FToolButtonHeight + Gap);

  FBtCellColor := TColorButton.Create(Self);
  FBtCellColor.Parent := FTabCell;
  FBtCellColor.SetBounds(
   StartX,
   Y,
  FToolButtonWidth,
  FToolButtonHeight
  );
  FBtCellColor.Hint := TRH(FBtCellColor, 'Cell color');
  FBtCellColor.ShowHint := True;
  FBtCellColor.OnColorChanged := @CellColorChanged;


  Inc(Y, FToolButtonHeight + Gap);

  FBtCellFontSize := TSpinEdit.Create(Self);
  FBtCellFontSize.Parent := FTabCell;
  FBtCellFontSize.Hint := TRH(FBtCellFontSize, 'Change fontSize');
  FBtCellFontSize.ShowHint := True;
  FBtCellFontSize.AutoSize :=false;
  FBtCellFontSize.SetBounds(
  StartX,
  Y,
  FToolButtonWidth,
  FToolButtonHeight
  );
  FBtCellFontSize.MinValue := 1;
  FBtCellFontSize.MaxValue := 96;
  FBtCellFontSize.Value := 10;
  FBtCellFontSize.OnChange := @CellFontSizeChanged;



  Inc(Y, FToolButtonHeight + Gap);

  FBtTextColor := TColorButton.Create(Self);
  FBtTextColor.Parent := FTabCell;
  FBtTextColor.SetBounds(
  StartX,
  Y,
  FToolButtonWidth,
  FToolButtonHeight
  );
  FBtTextColor.Hint := TRH(FBtTextColor, 'Text color');
  FBtTextColor.ShowHint := True;
  FBtTextColor.OnColorChanged := @TextColorChanged;

  Inc(Y, FToolButtonHeight + Gap);

  FBtAddImage := TSpeedButton.Create(Self);
  FBtAddImage.Parent := FTabCell;
  FBtAddImage.SetBounds(
  StartX,
  Y,
  FToolButtonWidth,
  FToolButtonHeight
  );
  FBtAddImage.Caption := 'IMG+';
  FBtAddImage.Hint := TRH(FBtAddImage, 'Add image');
  FBtAddImage.ShowHint := True;
  FBtAddImage.OnClick := @AddImageClick;

  Inc(Y, FToolButtonHeight + Gap);

  FBtDelImage := TSpeedButton.Create(Self);
  FBtDelImage.Parent := FTabCell;
  FBtDelImage.SetBounds(
   StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtDelImage.Caption := 'IMG-';
  FBtDelImage.Hint := TRH(FBtDelImage, 'Delete image');
  FBtDelImage.ShowHint := True;
  FBtDelImage.OnClick := @DelImageClick;

  Inc(Y, FToolButtonHeight + Gap);

  FBtImageLeft := TSpeedButton.Create(Self);
  FBtImageLeft.Parent := FTabCell;
  FBtImageLeft.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
   );
  FBtImageLeft.Caption := 'IL';
  FBtImageLeft.Hint := TRH(FBtImageLeft, 'Image left');
  FBtImageLeft.ShowHint := True;
  FBtImageLeft.ImageWidth:=32;
  FBtImageLeft.GroupIndex := 20;
  FBtImageLeft.AllowAllUp := False;
  FBtImageLeft.OnClick := @ImageLeftClick;

Inc(Y, FToolButtonHeight + Gap);

  FBtImageCenter := TSpeedButton.Create(Self);
  FBtImageCenter.Parent := FTabCell;
  FBtImageCenter.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
   );
  FBtImageCenter.Caption := 'IC';
  FBtImageCenter.Hint := TRH(FBtImageCenter, 'Image center');
  FBtImageCenter.ShowHint := True;
  FBtImageCenter.GroupIndex := 20;
  FBtImageCenter.AllowAllUp := False;
  FBtImageCenter.OnClick := @ImageCenterClick;

Inc(Y, FToolButtonHeight + Gap);

  FBtImageRight := TSpeedButton.Create(Self);
  FBtImageRight.Parent := FTabCell;
  FBtImageRight.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
   );
  FBtImageRight.Caption := 'IR';
  FBtImageRight.Hint := TRH(FBtImageRight, 'Image right');
  FBtImageRight.ShowHint := True;
  FBtImageRight.GroupIndex := 20;
  FBtImageRight.AllowAllUp := False;

  FBtImageRight.OnClick := @ImageRightClick;

Inc(Y, FToolButtonHeight + Gap);

  // Image size (Original / Fit / Stretch) via popup
  CreateImageSizePopup;

  FBtImageSize := TSpeedButton.Create(Self);
  FBtImageSize.Parent := FTabCell;
  FBtImageSize.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
   );
  FBtImageSize.Caption := 'IS';
  FBtImageSize.Hint := TRH(FBtImageSize, 'Image size');
  FBtImageSize.ShowHint := True;
  FBtImageSize.OnClick := @ImageSizeButtonClick;

Inc(Y, (FToolButtonHeight) + Gap);

  // Create Hperlink Image
  FBtCellCreateHyperlink := TSpeedButton.Create(Self);
  FBtCellCreateHyperlink.Parent := FTabCell;
  FBtCellCreateHyperlink.SetBounds(
   StartX,
   Y,
   FToolButtonWidth,
   FToolButtonHeight
   );
  FBtCellCreateHyperlink.Caption := 'HL+';
  FBtCellCreateHyperlink.Hint := TRH(FBtCellCreateHyperlink, 'Create image hyperlink');
  FBtCellCreateHyperlink.ShowHint := True;
  FBtCellCreateHyperlink.OnClick := @CellCreateHyperlinkClick;

  // Delete Hperlink Image
  Inc(Y, FToolButtonHeight + Gap);

  FBtCellDelHyperlink := TSpeedButton.Create(Self);
  FBtCellDelHyperlink.Parent := FTabCell;
  FBtCellDelHyperlink.SetBounds(
  StartX,
  Y,
  FToolButtonWidth,
  FToolButtonHeight
  );
  FBtCellDelHyperlink.Caption := 'HL-';
  FBtCellDelHyperlink.Hint := TRH(FBtCellDelHyperlink, 'Delete image hyperlink');
  FBtCellDelHyperlink.ShowHint := True;
  FBtCellDelHyperlink.OnClick := @CellDelHyperlinkClick;

  Inc(Y, FToolButtonHeight + Gap + 8);

  // Cell border style
  FBtCellBorderStyle := TBorderStyleButton.Create(Self);
  FBtCellBorderStyle.Parent := FTabCell;
  FBtCellBorderStyle.BorderStyle := vbsSolid;
  FBtCellBorderStyle.Color := clInfoBk;
  FBtCellBorderStyle.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    30
  );
  FBtCellBorderStyle.ShowHint := True;
  FBtCellBorderStyle.Hint := TRH(FBtCellBorderStyle, 'Cell Border Style');
  FBtCellBorderStyle.OnChange := @CellBorderStyleChange;

  UpdateCellToolIcons;

end;

procedure THtmlTableDesignerAdvanced.UpdateCellToolsLayout;
const
  Gap    = 0;
  StartX = 0;
  StartY = 0;
var
  Y: Integer;

begin
  Y := StartY;

  // ------------------------------------------------------------
  // Bold
  // ------------------------------------------------------------

  if Assigned(FBtCellBold) then
  begin
    FBtCellBold.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    Inc(Y, FToolButtonHeight + Gap);
  end;

  // ------------------------------------------------------------
  // Italic
  // ------------------------------------------------------------

  if Assigned(FBtCellItalic) then
  begin
    FBtCellItalic.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    Inc(Y, FToolButtonHeight + Gap);
  end;

  // ------------------------------------------------------------
  // Underline
  // ------------------------------------------------------------

  if Assigned(FBtCellUnderline) then
  begin
    FBtCellUnderline.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    Inc(Y, FToolButtonHeight + Gap +5);
  end;

  // ------------------------------------------------------------
  // Text align left
  // ------------------------------------------------------------

  if Assigned(FBtCellAlignLeft) then
  begin
    FBtCellAlignLeft.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    Inc(Y, FToolButtonHeight + Gap);
  end;

  // ------------------------------------------------------------
  // Text align center
  // ------------------------------------------------------------

  if Assigned(FBtCellAlignCenter) then
  begin
    FBtCellAlignCenter.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;

  // ------------------------------------------------------------
  // Text align right
  // ------------------------------------------------------------

  if Assigned(FBtCellAlignRight) then
  begin
    FBtCellAlignRight.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap + 5);
  end;
  // ------------------------------------------------------------
  // Create HyperLink cell
  // ------------------------------------------------------------
  if Assigned(FBtCellCreateTextHyperlink) then
  begin
   FBtCellCreateTextHyperlink.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
   );
  Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Delete HyperLink cell
  // ------------------------------------------------------------
  if Assigned(FBtCellDelTextHyperlink) then
  begin
   FBtCellDelTextHyperlink.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
   );
  Inc(Y, FToolButtonHeight + Gap +5);
  end;
  // ------------------------------------------------------------
  // Copy
  // ------------------------------------------------------------
  if Assigned(FBtCellCopy) then
  begin
    FBtCellCopy.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Paste
  // ------------------------------------------------------------
  if Assigned(FBtCellPaste) then
  begin
    FBtCellPaste.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap +5 );
  end;
  // ------------------------------------------------------------
  // Cell color
  // ------------------------------------------------------------
  if Assigned(FBtCellColor) then
  begin
    FBtCellColor.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Text color
  // ------------------------------------------------------------
  if Assigned(FBtTextColor) then
  begin
    FBtTextColor.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Font size
  // ------------------------------------------------------------
  if Assigned(FBtCellFontSize) then
  begin
    FBtCellFontSize.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,//SpinWidth,
      FToolButtonHeight + 5
    );

    Inc(Y, FToolButtonHeight + Gap + 5);
  end;
  // ------------------------------------------------------------
  // Add image
  // ------------------------------------------------------------
  if Assigned(FBtAddImage) then
  begin
    FBtAddImage.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Delete image
  // ------------------------------------------------------------
  if Assigned(FBtDelImage) then
  begin
    FBtDelImage.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Image left
  // ------------------------------------------------------------
  if Assigned(FBtImageLeft) then
  begin
    FBtImageLeft.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Image center
  // ------------------------------------------------------------
  if Assigned(FBtImageCenter) then
  begin
    FBtImageCenter.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;

  // ------------------------------------------------------------
  // Image right
  // ------------------------------------------------------------
  if Assigned(FBtImageRight) then
  begin
    FBtImageRight.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Image size (popup)
  // ------------------------------------------------------------
  if Assigned(FBtImageSize) then
  begin
    FBtImageSize.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
  end;
    Inc(Y, FToolButtonHeight + Gap + 5);
  // ------------------------------------------------------------
  // Create hyperlink
  // ------------------------------------------------------------
  if Assigned(FBtCellCreateHyperlink) then
  begin
    FBtCellCreateHyperlink.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap);
  end;
  // ------------------------------------------------------------
  // Delete hyperlink
  // ------------------------------------------------------------
  if Assigned(FBtCellDelHyperlink) then
  begin
    FBtCellDelHyperlink.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );
    Inc(Y, FToolButtonHeight + Gap + 8 );
  end;

  // ------------------------------------------------------------
  // Border style
  // ------------------------------------------------------------

  if Assigned(FBtCellBorderStyle) then
  begin
    FBtCellBorderStyle.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      25
    );
  end;
end;

procedure THtmlTableDesignerAdvanced.UpdateCellToolsHeight;
begin
  UpdateToolsHeight(
    FAantalCellButtons
  );
end;

procedure THtmlTableDesignerAdvanced.UpdateCellToolStates;
var
  Cell: THtmlCell;
  CellSelected: Boolean;
  HasImage: Boolean;
  HasTextLink: Boolean;
  HasImageLink: Boolean;
begin
  if FUpdatingCellToolStates then
    Exit;

  // Alle Cell-tool-controls hieronder worden samen aangemaakt in
  // CreateCellTools en nooit afzonderlijk vrijgegeven: bestaat er één
  // niet, dan bestaat geen enkele van hen. Deze ene gecombineerde guard
  // volstaat dus om te voorkomen dat deze methode ooit op een
  // niet-bestaande control werkt - net zoals UpdateTableToolStates en
  // UpdateTextBlockToolStates dat elk afzonderlijk al deden.
  if not (
    Assigned(FBtCellBold) and Assigned(FBtCellItalic) and
    Assigned(FBtCellUnderline) and Assigned(FBtCellAlignLeft) and
    Assigned(FBtCellAlignCenter) and Assigned(FBtCellAlignRight) and
    Assigned(FBtCellCopy) and Assigned(FBtCellPaste) and
    Assigned(FBtCellColor) and Assigned(FBtCellFontSize) and
    Assigned(FBtTextColor) and Assigned(FBtCellCreateTextHyperlink) and
    Assigned(FBtCellDelTextHyperlink) and Assigned(FBtAddImage) and
    Assigned(FBtDelImage) and Assigned(FBtImageLeft) and
    Assigned(FBtImageCenter) and Assigned(FBtImageRight) and
    Assigned(FBtCellCreateHyperlink) and Assigned(FBtCellDelHyperlink) and
    Assigned(FBtCellBorderStyle)
  ) then
    Exit;

  FUpdatingCellToolStates := True;
  try
    // ----------------------------------------------------------
    // Is er een geldige celselectie?
    // ----------------------------------------------------------

    CellSelected :=
      (SelectionMode = smCell) and
      not Assigned(SelectedTextBlock) and
      (SelectedCol >= 0) and
      (SelectedCol < ColCount) and
      (SelectedRow >= 0) and
      (SelectedRow < RowCount);

    // ----------------------------------------------------------
    // Algemene controls
    // ----------------------------------------------------------

    FBtCellBold.Enabled        := CellSelected;
    FBtCellItalic.Enabled      := CellSelected;
    FBtCellUnderline.Enabled   := CellSelected;

    FBtCellAlignLeft.Enabled   := CellSelected;
    FBtCellAlignCenter.Enabled := CellSelected;
    FBtCellAlignRight.Enabled  := CellSelected;

    FBtCellCopy.Enabled        := CellSelected;
    FBtCellPaste.Enabled       := CellSelected;

    FBtCellColor.Enabled       := CellSelected;
    FBtCellFontSize.Enabled    := CellSelected;
    FBtTextColor.Enabled       := CellSelected;
    FBtCellBorderStyle.Enabled := CellSelected;

    FBtCellCreateTextHyperlink.Enabled := CellSelected;
    FBtCellDelTextHyperlink.Enabled    := False;

    FBtAddImage.Enabled := CellSelected;
    FBtDelImage.Enabled := False;

    FBtImageLeft.Enabled   := False;
    FBtImageCenter.Enabled := False;
    FBtImageRight.Enabled  := False;

    if Assigned(FBtImageSize) then
      FBtImageSize.Enabled := False;

    FBtCellCreateHyperlink.Enabled := False;
    FBtCellDelHyperlink.Enabled    := False;

    // ----------------------------------------------------------
    // Geen geldige cel
    // ----------------------------------------------------------

    if not CellSelected then
    begin
      FBtCellBold.Down        := False;
      FBtCellItalic.Down      := False;
      FBtCellUnderline.Down   := False;

      FBtCellAlignLeft.Down   := False;
      FBtCellAlignCenter.Down := False;
      FBtCellAlignRight.Down  := False;

      FBtImageLeft.Down       := False;
      FBtImageCenter.Down     := False;
      FBtImageRight.Down      := False;

      Exit;
    end;

    // ----------------------------------------------------------
    // Geselecteerde cel ophalen
    // ----------------------------------------------------------

    Cell := Cells[
      SelectedCol,
      SelectedRow
    ];

    if not Assigned(Cell) then
      Exit;

    // ----------------------------------------------------------
    // Huidige toestand bepalen
    // ----------------------------------------------------------

    HasImage :=
      Cell.ShowImage and
      (Cell.ImageFile <> '');

    HasTextLink :=
      Cell.IsLink and
      (Trim(Cell.LinkURL) <> '');

    HasImageLink :=
      Cell.ImageIsLink and
      (Trim(Cell.ImageLinkURL) <> '');

    // ----------------------------------------------------------
    // Fontstijlen
    // ----------------------------------------------------------

    FBtCellBold.Down :=
      fsBold in Cell.FontStyles;

    FBtCellItalic.Down :=
      fsItalic in Cell.FontStyles;

    FBtCellUnderline.Down :=
      fsUnderline in Cell.FontStyles;

    // ----------------------------------------------------------
    // Tekstuitlijning
    // ----------------------------------------------------------

    FBtCellAlignLeft.Down :=
      Cell.Align = caLeft;

    FBtCellAlignCenter.Down :=
      Cell.Align = caCenter;

    FBtCellAlignRight.Down :=
      Cell.Align = caRight;

    // ----------------------------------------------------------
    // Font size
    // ----------------------------------------------------------

    if Cell.FontSize >= FBtCellFontSize.MinValue then
      FBtCellFontSize.Value := Cell.FontSize;

    // ----------------------------------------------------------
    // Kleuren
    // ----------------------------------------------------------

    FBtCellColor.ButtonColor :=
      Cell.BgColor;

    FBtTextColor.ButtonColor :=
      Cell.FontColor;

    // ----------------------------------------------------------
    // Randstijl (TCellBorderStyle -> TVisualBorderStyle)
    // ----------------------------------------------------------

    case Cell.BorderStyle of
      cbsNone:
        FBtCellBorderStyle.BorderStyle := vbsNone;
      cbsSolid:
        FBtCellBorderStyle.BorderStyle := vbsSolid;
      cbsDashed:
        FBtCellBorderStyle.BorderStyle := vbsDashed;
      cbsDotted:
        FBtCellBorderStyle.BorderStyle := vbsDotted;
      cbsDouble:
        FBtCellBorderStyle.BorderStyle := vbsDouble;
    end;

    // ----------------------------------------------------------
    // Tekst-hyperlink
    // ----------------------------------------------------------

    FBtCellCreateTextHyperlink.Enabled :=
      CellSelected;

    FBtCellDelTextHyperlink.Enabled :=
      HasTextLink;

    // ----------------------------------------------------------
    // Afbeelding
    // ----------------------------------------------------------

    FBtAddImage.Enabled :=
      CellSelected;

    FBtDelImage.Enabled :=
      HasImage;

    FBtImageLeft.Enabled :=
      HasImage;

    FBtImageCenter.Enabled :=
      HasImage;

    FBtImageRight.Enabled :=
      HasImage;

    if Assigned(FBtImageSize) then
      FBtImageSize.Enabled :=
        HasImage;

    // ----------------------------------------------------------
    // Image alignment
    // ----------------------------------------------------------

    if HasImage then
    begin
      FBtImageLeft.Down :=
        Cell.ImageAlign = iaLeft;

      FBtImageCenter.Down :=
        Cell.ImageAlign = iaCenter;

      FBtImageRight.Down :=
        Cell.ImageAlign = iaRight;
    end
    else
    begin
      FBtImageLeft.Down := False;
      FBtImageCenter.Down := False;
      FBtImageRight.Down := False;
    end;

    // ----------------------------------------------------------
    // Afbeeldings-hyperlink
    // ----------------------------------------------------------

    FBtCellCreateHyperlink.Enabled :=
      HasImage;

    FBtCellDelHyperlink.Enabled :=
      HasImage and HasImageLink;

  finally
    FUpdatingCellToolStates := False;
  end;
end;

procedure THtmlTableDesignerAdvanced.UpdateCellToolIcons;

  procedure LoadButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImages) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImages.Count) then
    begin
      FAdvancedImages.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
      AButton.Caption := AFallbackCaption;
  end;


  procedure LoadWideButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
      AButton.Caption := AFallbackCaption;
  end;

begin
  // ------------------------------------------------------------
  // Tekstopmaak
  // ------------------------------------------------------------

  LoadWideButtonIcon(
    FBtCellBold,
    FCellBoldImageIndex,
    'B'
  );

  LoadWideButtonIcon(
    FBtCellItalic,
    FCellItalicImageIndex,
    'I'
  );

  LoadWideButtonIcon(
    FBtCellUnderline,
    FCellUnderlineImageIndex,
    'U'
  );


  // ------------------------------------------------------------
  // Afbeeldingsuitlijning
  // Deze  gebruiken AdvancedImagesWide
  // ------------------------------------------------------------

  LoadWideButtonIcon(
    FBtCellAlignLeft,
    FCellAlignLeftImageIndex,
    'L'
  );

  LoadWideButtonIcon(
    FBtCellAlignCenter,
    FCellAlignCenterImageIndex,
    'C'
  );

  LoadWideButtonIcon(
    FBtCellAlignRight,
    FCellAlignRightImageIndex,
    'R'
  );
 //
  LoadWideButtonIcon(
    FBtCellCreateTextHyperlink,
    FCellCreateTextHyperlinkImageIndex,
    'TH+'
   );

  LoadWideButtonIcon(
    FBtCellDelTextHyperlink,
    FCellDelTextHyperlinkImageIndex,
    'TH-'
   );

//
  LoadWideButtonIcon(
    FBtCellCopy,
    FCellCopyImageIndex,
    'CP'
  );

   LoadWideButtonIcon(
    FBtCellPaste,
    FCellPasteImageIndex,
    'PS'
  );

  LoadWideButtonIcon(
    FBtCellCreateHyperlink,
    FCellCreateHyperlinkImageIndex,
    'HL+'
  );

  LoadWideButtonIcon(
    FBtCellDelHyperlink,
    FCellDelHyperlinkImageIndex,
    'HL-'
  );

  LoadWideButtonIcon(
    FBtAddImage,
    FAddImageImageIndex,
    'IMG+'
  );

  LoadWideButtonIcon(
    FBtDelImage,
    FDelImageImageIndex,
    'IMG-'
  );

  LoadWideButtonIcon(
    FBtImageLeft,
    FImageLeftImageIndex,
    'IL'
  );

  LoadWideButtonIcon(
    FBtImageCenter,
    FImageCenterImageIndex,
    'IC'
  );

  LoadWideButtonIcon(
    FBtImageRight,
    FImageRightImageIndex,
    'IR'
  );

  LoadWideButtonIcon(
    FBtImageSize,
    FImageSizeImageIndex,
    'IS'
  );

end;

procedure THtmlTableDesignerAdvanced.CellBoldClick(Sender: TObject);
begin
  ToggleStyleSelection(fsBold);
  UpdateCellToolStates;
end;

procedure THtmlTableDesignerAdvanced.CellItalicClick(Sender: TObject);
begin
  ToggleStyleSelection(fsItalic);
  UpdateCellToolStates;
end;

procedure THtmlTableDesignerAdvanced.CellUnderlineClick(Sender: TObject);
begin
  ToggleStyleSelection(fsUnderline);
  UpdateCellToolStates;
end;

procedure THtmlTableDesignerAdvanced.CellAlignLeftClick(Sender: TObject);
begin
  ApplyTextAlignToSelection(caLeft);
  UpdateCellToolStates;
end;

procedure THtmlTableDesignerAdvanced.CellAlignCenterClick(Sender: TObject);
begin
  ApplyTextAlignToSelection(caCenter);
  UpdateCellToolStates;
end;

procedure THtmlTableDesignerAdvanced.CellAlignRightClick(Sender: TObject);
begin
  ApplyTextAlignToSelection(caRight);
  UpdateCellToolStates;
end;

// ------------------------------------------------------------
// Extra Cell ToolBox click-events
// ------------------------------------------------------------

procedure THtmlTableDesignerAdvanced.CellCreateTextHyperlinkClick(Sender:TObject);
var
 URLText: string;
 DisplayText: string;
begin
  if SelectionMode <> smCell then
    Exit;

  URLText := InputBox(
    TR('Hyperlink'),
    TR('URL:'),
    'https://'
  );

  if Trim(URLText) = '' then
    Exit;

  DisplayText := InputBox(
    TR('Hyperlink'),
    TR('Tekst:'),
    Cells[
      SelectedCol,
      SelectedRow
    ].Text
  );
  if Trim(DisplayText) = '' then
  DisplayText := URLText;

  SetLinkToSelection(URLText, DisplayText);
end;

procedure THtmlTableDesignerAdvanced.CellDelTextHyperlinkClick(Sender:TObject);
begin
   if SelectionMode <> smCell then Exit;
   ClearLinkFromSelection;
end;

procedure THtmlTableDesignerAdvanced.CellCopyClick(Sender: TObject);
begin
 CopySelection;
end;

procedure THtmlTableDesignerAdvanced.CellPasteClick(Sender: TObject);
begin
  PasteSelection;
end;

procedure THtmlTableDesignerAdvanced.CellColorChanged(Sender: TObject);
begin
  ApplyBgColorToSelection(FBtCellColor.ButtonColor);
end;

procedure THtmlTableDesignerAdvanced.CellFontSizeChanged(Sender: TObject);
var
  C, R: Integer;
  Cell: THtmlCell;
begin
  if SelectionMode <> smCell then
    Exit;

  if FUpdatingCellToolStates then
    Exit;

  C := SelectedCol;
  R := SelectedRow;

  if (C < 0) or
     (C >= ColCount) or
     (R < 0) or
     (R >= RowCount) then
    Exit;

  Cell :=Cells[C, R];

  if not Assigned(Cell) then
    Exit;

  // Bij een slavecel naar de mastercel gaan
  if Cell.Merged then
  begin
    C := Cell.MasterCol;
    R := Cell.MasterRow;

    if (C < 0) or
       (C >= ColCount) or
       (R < 0) or
       (R >= RowCount) then
      Exit;

    Cell :=Cells[C, R];

    if not Assigned(Cell) then
      Exit;
  end;
  Cell.FontSize := FBtCellFontSize.Value;

  Invalidate;
  DoChange;
end;

procedure THtmlTableDesignerAdvanced.CellRadiusChanged(Sender: TObject);
begin
   if FUpdatingTableToolStates then
     Exit;

   if CellAfronding = FBtCellRadius.Value then
     Exit;

   CellAfronding := FBtCellRadius.Value;
   invalidate;
   DoChange;
end;

procedure THtmlTableDesignerAdvanced.CellBorderStyleChange(Sender: TObject);
begin
  if FUpdatingCellToolStates then
    Exit;

  if not Assigned(FBtCellBorderStyle) then
    Exit;

  case FBtCellBorderStyle.BorderStyle of
    vbsNone:
      ApplyBorderStyleToSelection(cbsNone);

    vbsSolid:
      ApplyBorderStyleToSelection(cbsSolid);

    vbsDashed:
      ApplyBorderStyleToSelection(cbsDashed);

    vbsDotted:
      ApplyBorderStyleToSelection(cbsDotted);

    vbsDouble:
      ApplyBorderStyleToSelection(cbsDouble);
  end;
end;

procedure THtmlTableDesignerAdvanced.TextColorChanged(Sender: TObject);
begin
  if FUpdatingCellToolStates then
    Exit;
  ApplyFontColorToSelection(FBtTextColor.ButtonColor);
end;

function THtmlTableDesignerAdvanced.GetImagesDir: string;
begin
  // <Application>\html\images\
  Result :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) +
    'html' + PathDelim +
    'images';
end;

function THtmlTableDesignerAdvanced.IsInImagesDir(
  const AFileName: string
): Boolean;
var
  Dir, FilePath: string;
begin
  // Enkel bestanden binnen onze eigen beheerde images-map mogen
  // automatisch opgeruimd worden - nooit een extern/gebruikersbestand
  // aanraken waar een ouder of handmatig aangepast .htd-project
  // toevallig naar verwijst.
  Dir := IncludeTrailingPathDelimiter(GetImagesDir);
  FilePath := IncludeTrailingPathDelimiter(ExtractFilePath(AFileName));

  {$IFDEF WINDOWS}
  Result := SameText(Copy(FilePath, 1, Length(Dir)), Dir);
  {$ELSE}
  Result := (Copy(FilePath, 1, Length(Dir)) = Dir);
  {$ENDIF}
end;

function THtmlTableDesignerAdvanced.IsImageFileUsed(
  const AFileName: string
): Boolean;
var
  C, Row: Integer;
begin
  Result := False;

  for C := 0 to ColCount - 1 do
    for Row := 0 to RowCount - 1 do
      if SameFileName(Cells[C, Row].ImageFile, AFileName) then
        Exit(True);
end;

procedure THtmlTableDesignerAdvanced.CleanupUnusedImage(
  const AFileName: string
);
begin
  if Trim(AFileName) = '' then
    Exit;

  if not IsInImagesDir(AFileName) then
    Exit;

  if IsImageFileUsed(AFileName) then
    Exit;

  if FileExists(AFileName) then
    DeleteFile(AFileName);
end;

procedure THtmlTableDesignerAdvanced.AddImageClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  ImagesDir: string;
  DestFile: string;
  OldImageFile: string;

  // ------------------------------------------------------------
  // Bepaalt een veilige doelbestandsnaam in ADir voor ASourceFile.
  //
  // Zonder deze check zou een tweede, ANDER bestand met toevallig
  // dezelfde bestandsnaam (bv. "icoon.png" uit een andere map) de
  // eerder gekopieerde afbeelding stil overschrijven. Op dat moment
  // merk je er niets van (Cell.Picture van de eerste cel staat nog
  // gewoon in het geheugen) - maar bij de eerstvolgende LoadFromHTD
  // laadt die eerste cel opnieuw vanaf hetzelfde pad, en toont dan
  // plots de verkeerde afbeelding.
  //
  // Bestaat het doelbestand al MET identieke inhoud, dan wordt het
  // gerust hergebruikt (geen nodeloze duplicaten wanneer dezelfde
  // afbeelding in meerdere cellen wordt gebruikt). Bestaat het al
  // met ANDERE inhoud, dan wordt een uniek achtervoegsel toegevoegd.
  // ------------------------------------------------------------
  function UniqueDestFile(
    const ADir, ASourceFile: string
  ): string;
  var
    FullName, Ext, NameOnly: string;
    Candidate: string;
    Counter: Integer;
  begin
    FullName := ExtractFileName(ASourceFile);
    Ext := ExtractFileExt(FullName);
    NameOnly := Copy(FullName, 1, Length(FullName) - Length(Ext));

    Candidate := IncludeTrailingPathDelimiter(ADir) + FullName;

    if not FileExists(Candidate) then
      Exit(Candidate);

    if MD5Print(MD5File(Candidate)) = MD5Print(MD5File(ASourceFile)) then
      Exit(Candidate);

    Counter := 1;

    repeat
      Candidate :=
        IncludeTrailingPathDelimiter(ADir) +
        NameOnly + '_' + IntToStr(Counter) + Ext;

      Inc(Counter);
    until not FileExists(Candidate) or
          (MD5Print(MD5File(Candidate)) = MD5Print(MD5File(ASourceFile)));

    Result := Candidate;
  end;

begin
  if SelectionMode <> smCell then
    Exit;

  if (SelectedCol < 0) or
     (SelectedCol >= ColCount) or
     (SelectedRow < 0) or
     (SelectedRow >= RowCount) then
    Exit;

  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Title := 'Afbeelding invoegen';

    Dlg.Filter :=
      'Afbeeldingen|*.png;*.jpg;*.jpeg;*.bmp;*.gif|' +
      'Alle bestanden|*.*';

    if not Dlg.Execute then
      Exit;

    ImagesDir := GetImagesDir;

    // Map maken indien ze nog niet bestaat
    if not DirectoryExists(ImagesDir) then
      ForceDirectories(ImagesDir);

    // Doelbestand: botsingsbestendig bepaald, zie UniqueDestFile hierboven.
    DestFile := UniqueDestFile(ImagesDir, Dlg.FileName);

    // Alleen kopiëren wanneer bron en doel niet hetzelfde zijn
    if not SameFileName(Dlg.FileName, DestFile) then
    begin
      if not CopyFile(Dlg.FileName, DestFile) then
      begin
        ShowMessage(
          TR('De afbeelding kon niet naar de images-map worden gekopieerd.')
        );
        Exit;
      end;
    end;

    // De afbeelding die deze cel tot nu toe had, bewaren zodat we ze
    // hieronder kunnen opruimen als ze nergens anders meer gebruikt
    // wordt - LoadCellImage hieronder overschrijft Cell.ImageFile.
    OldImageFile := Cells[SelectedCol, SelectedRow].ImageFile;

    // Afbeelding vanuit de interne html/images-map laden
    LoadCellImage(
      SelectedCol,
      SelectedRow,
      DestFile
    );

    // Oude afbeelding van deze cel opruimen, tenzij het toevallig
    // dezelfde afbeelding is als de nieuwe (dan hebben we ze net pas
    // geladen) of ze nog door een andere cel gebruikt wordt.
    if not SameFileName(OldImageFile, DestFile) then
      CleanupUnusedImage(OldImageFile);

  finally
    Dlg.Free;
  end;
end;

procedure THtmlTableDesignerAdvanced.DelImageClick(Sender: TObject);
var
  L, T, R, B: Integer;
  C, Row: Integer;
  OldFiles: TStringList;
  I: Integer;
begin
  // Verzamel eerst de ImageFile-paden binnen de huidige selectie,
  // VOOR RemoveImageFromSelection ze wist - anders zijn we ze kwijt
  // en kan er niets meer opgeruimd worden.
  OldFiles := TStringList.Create;
  try
    OldFiles.Sorted := True;
    OldFiles.Duplicates := dupIgnore;

    GetSelectionBounds(L, T, R, B);

    for C := L to R do
      for Row := T to B do
        if Trim(Cells[C, Row].ImageFile) <> '' then
          OldFiles.Add(Cells[C, Row].ImageFile);

    RemoveImageFromSelection;

    // Nu pas opruimen: de selectie zelf verwijst nergens meer naar
    // deze bestanden, dus IsImageFileUsed hieronder kijkt enkel nog
    // naar cellen buiten de (voormalige) selectie.
    for I := 0 to OldFiles.Count - 1 do
      CleanupUnusedImage(OldFiles[I]);
  finally
    OldFiles.Free;
  end;
end;

procedure THtmlTableDesignerAdvanced.ImageLeftClick(Sender: TObject);
begin
  ApplyImageAlignToSelection(HtmlTableDesigner.iaLeft);
  DoChange;
end;

procedure THtmlTableDesignerAdvanced.ImageCenterClick(Sender: TObject);
begin
  ApplyImageAlignToSelection(HtmlTableDesigner.iaCenter);
  DoChange;
end;

procedure THtmlTableDesignerAdvanced.ImageRightClick(Sender: TObject);
begin
  ApplyImageAlignToSelection(HtmlTableDesigner.iaRight);
  DoChange;
end;

// ------------------------------------------------------------
// Image size popup: Original / Fit / Stretch
// Tag van elk menu-item = Ord(TImageSizeMode)
// ------------------------------------------------------------
procedure THtmlTableDesignerAdvanced.CreateImageSizePopup;

  procedure AddImageSizeItem(AMode: TImageSizeMode);
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(FImageSizePopup);
    Item.Tag := Ord(AMode);
    Item.RadioItem := True;
    Item.GroupIndex := 1;
    Item.OnClick := @ImageSizeMenuClick;
    FImageSizePopup.Items.Add(Item);
  end;

begin
  FImageSizePopup := TPopupMenu.Create(Self);

  AddImageSizeItem(ismOriginal);
  AddImageSizeItem(ismFit);
  AddImageSizeItem(ismStretch);
end;

procedure THtmlTableDesignerAdvanced.UpdateImageSizePopupChecks;
var
  i: Integer;
  Cell: THtmlCell;
begin
  if not Assigned(FImageSizePopup) then
    Exit;

  // Captions hier zetten, zodat een taalwissel meteen zichtbaar is
  for i := 0 to FImageSizePopup.Items.Count - 1 do
    case TImageSizeMode(FImageSizePopup.Items[i].Tag) of
      ismOriginal: FImageSizePopup.Items[i].Caption := TR('Image original');
      ismFit:      FImageSizePopup.Items[i].Caption := TR('Image fit');
      ismStretch:  FImageSizePopup.Items[i].Caption := TR('Image stretch');
    end;

  Cell := nil;
  if (SelectedCol >= 0) and (SelectedCol < ColCount) and
     (SelectedRow >= 0) and (SelectedRow < RowCount) then
    Cell := Cells[SelectedCol, SelectedRow];

  for i := 0 to FImageSizePopup.Items.Count - 1 do
    FImageSizePopup.Items[i].Checked :=
      Assigned(Cell) and
      (Ord(Cell.ImageSizeMode) = FImageSizePopup.Items[i].Tag);
end;

procedure THtmlTableDesignerAdvanced.ImageSizeButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  if not Assigned(FBtImageSize) then
    Exit;

  if not Assigned(FImageSizePopup) then
    Exit;

  if SelectionMode <> smCell then
    Exit;

  UpdateImageSizePopupChecks;

  // Linksonder van de SpeedButton omzetten naar schermcoördinaten
  P := FBtImageSize.ClientToScreen(
    Point(0, FBtImageSize.Height)
  );

  // Popup direct onder de knop tonen
  FImageSizePopup.PopUp(
    P.X,
    P.Y
  );
end;

procedure THtmlTableDesignerAdvanced.ImageSizeMenuClick(Sender: TObject);
var
  L, T, R, B: Integer;
  C, Row: Integer;
  Mode: TImageSizeMode;
begin
  if not (Sender is TMenuItem) then
    Exit;

  if SelectionMode <> smCell then
    Exit;

  Mode := TImageSizeMode(TMenuItem(Sender).Tag);

  // Toepassen op de volledige selectie (zoals image align)
  GetSelectionBounds(L, T, R, B);

  for C := L to R do
    for Row := T to B do
      Cells[C, Row].ImageSizeMode := Mode;

  Invalidate;
  DoChange;
end;

procedure THtmlTableDesignerAdvanced.CellCreateHyperlinkClick(Sender: TObject);
var
  URLText: string;
  Cell: THtmlCell;
begin
  if SelectionMode <> smCell then
    Exit;

  Cell := Cells[SelectedCol,SelectedRow];

  if not Cell.ShowImage then
  begin
    MessageDlg(
      TR('Afbeeldingshyperlink'),
      TR('De geselecteerde cel bevat geen afbeelding.'),
      mtInformation,
      [mbOK],
      0
    );
    Exit;
  end;

  URLText := InputBox(
    TR('Afbeeldingshyperlink'),
    TR('URL:'),
    'https://'
  );

  if Trim(URLText) = '' then
    Exit;

  SetImageLinkToSelection(URLText);
end;

procedure THtmlTableDesignerAdvanced.CellDelHyperlinkClick(Sender: TObject);
begin
  if SelectionMode <> smCell then Exit;
   ClearImageLinkFromSelection;
end;

// click-events Table buttons ToolBox

{ =============================================================================
  TEXTBLOCK TOOLS
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.SetTBImageIndexAdd(
  AValue: Integer);
begin
  if FTBImageIndexAdd = AValue then
    Exit;

  FTBImageIndexAdd := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexDelete(
  AValue: Integer);
Begin
  if FTBImageIndexDelete = AValue then
    Exit;

  FTBImageIndexDelete := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexBold(
  AValue: Integer);
begin
  if FTBImageIndexBold = AValue then
    Exit;

  FTBImageIndexBold := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexItalic(
  AValue: Integer);
begin
  if FTBImageIndexItalic = AValue then
    Exit;

  FTBImageIndexItalic := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexUnderline(
  AValue: Integer);
begin
  if FTBImageIndexUnderline = AValue then
    Exit;

  FTBImageIndexUnderline := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexAlignLeft(
  AValue: Integer);
begin
  if FTBImageIndexAlignLeft = AValue then
    Exit;

  FTBImageIndexAlignLeft := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexAlignCenter(
  AValue: Integer);
begin
  if FTBImageIndexAlignCenter = AValue then
    Exit;

  FTBImageIndexAlignCenter := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexAlignRight(
  AValue: Integer);
begin
  if FTBImageIndexAlignRight = AValue then
    Exit;

  FTBImageIndexAlignRight := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexCreateHyperlink(
  AValue: Integer);
begin
  if FTBImageIndexCreateHyperlink = AValue then
    Exit;

  FTBImageIndexCreateHyperlink := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexDelHyperlink(
  AValue: Integer);
begin
  if FTBImageIndexDelHyperlink = AValue then
    Exit;
  FTBImageIndexDelHyperlink := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.SetTBImageIndexTransparant(
  AValue: Integer);
begin
  if FTBImageIndexTransparent = AValue then
    Exit;
  FTBImageIndexTransparent := AValue;
  UpdateTextBlockToolsIcons;
end;

procedure THtmlTableDesignerAdvanced.CreateTextBlockTools;
const
  Gap    = 3;
  StartX = 0;
  StartY = 0;
  GroupGap= 10;
var
  Y: Integer;
begin
  Y := StartY;

  // ------------------------------------------------------------
  // Add TextBlock
  // ------------------------------------------------------------
  FBtTBAdd := TSpeedButton.Create(Self);
  FBtTBAdd.Parent := FTabTextBlock;
  FBtTBAdd.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBAdd.Caption := 'TBA';
  FBtTBAdd.Hint := TRH(FBtTBAdd, 
    'Klik eerst op de plaats in designer' +
    LineEnding +
    'waar je het tekstblok wil zetten.');
  FBtTBAdd.ShowHint := True;
  FBtTBAdd.OnClick := @TBAddButtonClick;

  Inc(Y, FToolButtonHeight + Gap);

   // ------------------------------------------------------------
  // Delete TextBlock
  // ------------------------------------------------------------
  FBtTBDelete := TSpeedButton.Create(Self);
  FBtTBDelete.Parent := FTabTextBlock;
  FBtTBDelete.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBDelete.Caption := 'TBD';
  FBtTBDelete.Hint := TRH(FBtTBDelete, 
    'Selecteer tekstblock  in designer' +
    LineEnding +
    'om te verwijderen.');
  FBtTBDelete.ShowHint := True;
  FBtTBDelete.OnClick := @TBDeleteButtonClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Move X (mm t.o.v. nulpunt rulers)
  // ------------------------------------------------------------
  FBtTBMoveX := TSpinEdit.Create(Self);
  FBtTBMoveX.Parent := FTabTextBlock;
  FBtTBMoveX.Color := clInfoBk;
  FBtTBMoveX.AutoSize := False;
  FBtTBMoveX.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBMoveX.MinValue := 0;
  FBtTBMoveX.MaxValue := 500;
  FBtTBMoveX.Value := 0;
  FBtTBMoveX.Increment := 1;
  FBtTBMoveX.ShowHint := True;
  FBtTBMoveX.Hint := TRH(FBtTBMoveX, ' Drag the TextBlock with the mouse' + LineEnding +
                        ' OR' + LineEnding +
                        ' change only Horizontally( X )');
  FBtTBMoveX.OnChange := @TBMoveXChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Move Y (mm t.o.v. nulpunt rulers)
  // ------------------------------------------------------------
  FBtTBMoveY := TSpinEdit.Create(Self);
  FBtTBMoveY.Parent := FTabTextBlock;
  FBtTBMoveY.Color := clInfoBk;
  FBtTBMoveY.AutoSize := False;
  FBtTBMoveY.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBMoveY.MinValue := 0;
  FBtTBMoveY.MaxValue := 500;
  FBtTBMoveY.Value := 0;
  FBtTBMoveY.Increment := 1;
  FBtTBMoveY.ShowHint := True;
  FBtTBMoveY.Hint := TRH(FBtTBMoveY, ' Drag the TextBlock with the mouse' + LineEnding +
                        ' OR' + LineEnding +
                        ' change only Vertically( Y )');
  FBtTBMoveY.OnChange := @TBMoveYChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Bold
  // ------------------------------------------------------------
  FBtTBBold := TSpeedButton.Create(Self);
  FBtTBBold.Parent := FTabTextBlock;
  FBtTBBold.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBBold.Caption := 'B';
  FBtTBBold.Font.Style := [fsBold];
  FBtTBBold.AllowAllUp := True;
  FBtTBBold.ShowHint := True;
  FBtTBBold.Hint := TRH(FBtTBBold, 'Bold');
  FBtTBBold.OnClick := @TBBoldClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Italic
  // ------------------------------------------------------------
  FBtTBItalic := TSpeedButton.Create(Self);
  FBtTBItalic.Parent := FTabTextBlock;
  FBtTBItalic.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBItalic.Caption := 'I';
  FBtTBItalic.Font.Style := [fsItalic];
  FBtTBItalic.AllowAllUp := True;
  FBtTBItalic.ShowHint := True;
  FBtTBItalic.Hint := TRH(FBtTBItalic, 'Italic');
  FBtTBItalic.OnClick := @TBItalicClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Underline
  // ------------------------------------------------------------
  FBtTBUnderline := TSpeedButton.Create(Self);
  FBtTBUnderline.Parent := FTabTextBlock;
  FBtTBUnderline.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBUnderline.Caption := 'U';
  FBtTBUnderline.Font.Style := [fsUnderline];
  FBtTBUnderline.AllowAllUp := True;
  FBtTBUnderline.ShowHint := True;
  FBtTBUnderline.Hint := TRH(FBtTBUnderline, 'Underline');
  FBtTBUnderline.OnClick := @TBUnderlineClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Align Left
  // ------------------------------------------------------------
  FBtTBAlignLeft := TSpeedButton.Create(Self);
  FBtTBAlignLeft.Parent := FTabTextBlock;
  FBtTBAlignLeft.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBAlignLeft.Caption := 'L';
  FBtTBAlignLeft.GroupIndex := 30;
  FBtTBAlignLeft.AllowAllUp := False;
  FBtTBAlignLeft.ShowHint := True;
  FBtTBAlignLeft.Hint := TRH(FBtTBAlignLeft, 'Align Left');
  FBtTBAlignLeft.OnClick := @TBAlignLeftClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Align Center
  // ------------------------------------------------------------
  FBtTBAlignCenter := TSpeedButton.Create(Self);
  FBtTBAlignCenter.Parent := FTabTextBlock;
  FBtTBAlignCenter.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBAlignCenter.Caption := 'C';
  FBtTBAlignCenter.GroupIndex := 30;
  FBtTBAlignCenter.AllowAllUp := False;
  FBtTBAlignCenter.ShowHint := True;
  FBtTBAlignCenter.Hint := TRH(FBtTBAlignCenter, 'Align Center');
  FBtTBAlignCenter.OnClick := @TBAlignCenterClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Align Right
  // ------------------------------------------------------------
  FBtTBAlignRight := TSpeedButton.Create(Self);
  FBtTBAlignRight.Parent := FTabTextBlock;
  FBtTBAlignRight.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBAlignRight.Caption := 'R';
  FBtTBAlignRight.GroupIndex := 30;
  FBtTBAlignRight.AllowAllUp := False;
  FBtTBAlignRight.ShowHint := True;
  FBtTBAlignRight.Hint := TRH(FBtTBAlignRight, 'Align Right');
  FBtTBAlignRight.OnClick := @TBAlignRightClick;

  Inc(Y, FToolButtonHeight + Gap);
  // ------------------------------------------------------------
  // Text Color
  // ------------------------------------------------------------
  FBtTBColor := TColorButton.Create(Self);
  FBtTBColor.Parent := FTabTextBlock;
  FBtTBColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBColor.ShowHint := True;
  FBtTBColor.Hint := TRH(FBtTBColor, 'Text Color');
  FBtTBColor.OnColorChanged := @TBColorChanged;

  Inc(Y, FToolButtonHeight + Gap);

   // ------------------------------------------------------------
  // Font Size
  // ------------------------------------------------------------
  FBtTBFontSize := TSpinEdit.Create(Self);
  FBtTBFontSize.Parent := FTabTextBlock;
  FBtTBFontSize.Color:=clInfoBk;
  FBtTBFontSize.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBFontSize.MinValue := 8;
  FBtTBFontSize.MaxValue := 20;
  FBtTBFontSize.Value := 12;
  FBtTBFontSize.ShowHint := True;
  FBtTBFontSize.Hint := TRH(FBtTBFontSize, 'Font Size');
  FBtTBFontSize.OnChange := @TBFontSizeChanged;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Create Hyperlink
  // ------------------------------------------------------------
  FBtTBCreateHyperlink := TSpeedButton.Create(Self);
  FBtTBCreateHyperlink.Parent := FTabTextBlock;
  FBtTBCreateHyperlink.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBCreateHyperlink.Caption := 'HL+';
  FBtTBCreateHyperlink.ShowHint := True;
  FBtTBCreateHyperlink.Hint := TRH(FBtTBCreateHyperlink, 'Create Hyperlink');
  FBtTBCreateHyperlink.OnClick := @TBCreateHyperlinkClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Delete Hyperlink
  // ------------------------------------------------------------
  FBtTBDelHyperlink := TSpeedButton.Create(Self);
  FBtTBDelHyperlink.Parent := FTabTextBlock;
  FBtTBDelHyperlink.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBDelHyperlink.Caption := 'HL-';
  FBtTBDelHyperlink.ShowHint := True;
  FBtTBDelHyperlink.Hint := TRH(FBtTBDelHyperlink, 'Delete Hyperlink');
  FBtTBDelHyperlink.OnClick := @TBDelHyperlinkClick;

  Inc(Y, FToolButtonHeight + Gap);

  //------------------------------------------------------------
  // Transparant TextBlok
  // ------------------------------------------------------------
  FBtTBTransparent := TSpeedButton.Create(Self);
  FBtTBTransparent.Parent := FTabTextBlock;
  FBtTBTransparent.AllowAllUp := True;
  FBtTBTransparent.GroupIndex := 0;
  FBtTBTransparent.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBTransparent.Caption := 'TRA';
  FBtTBTransparent.ShowHint := True;
  FBtTBTransparent.Hint := TRH(FBtTBTransparent, 'Set TextBlock transparancy True/False ');
  FBtTBTransparent.OnClick := @TBTransparentClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Color TextBox
  // ------------------------------------------------------------
  FBtTBGColor:= TColorButton.Create(Self);
  FBtTBGColor.Parent := FTabTextBlock;
  FBtTBGColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBGColor.ShowHint := True;
  FBtTBGColor.Hint := TRH(FBtTBGColor, 'TextBlock color');
  FBtTBGColor.OnColorChanged := @TBBGColorChanged;

  Inc(Y, FToolButtonHeight + Gap);



  // Border Width
  // ------------------------------------------------------------
  FBtTBBorderSize := TSpinEdit.Create(Self);
  FBtTBBorderSize.Parent := FTabTextBlock;
  FBtTBBorderSize.Color:=clInfoBk;

  FBtTBBorderSize.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtTBBorderSize.MinValue := 1;
  FBtTBBorderSize.MaxValue := 5;
  FBtTBBorderSize.Value := 1;
  FBtTBBorderSize.ShowHint := True;
  FBtTBBorderSize.Hint := TRH(FBtTBBorderSize, 'Border width');
  FBtTBBorderSize.OnChange := @TBBorderSizeChanged;

  Inc(Y, FToolButtonHeight + Gap);
  // ------------------------------------------------------------
  // Border Style
  // ------------------------------------------------------------
  // Border Style - iets hoger voor duidelijkere weergave
  FBtTBBorderStyle :=TBorderStyleButton.Create(Self);
  FBtTBBorderStyle.Parent := FTabTextBlock;
  FBtTBBorderStyle.BorderStyle := vbsSolid;
  FBtTBBorderStyle.Color:=clInfoBk;
  FBtTBBorderStyle.SetBounds(
    StartX,
    Y + 8,
    FToolButtonWidth,
    25
  );
  FBtTBBorderStyle.ShowHint := True;
  FBtTBBorderStyle.Hint := TRH(FBtTBBorderStyle, 'Border Style');
  FBtTBBorderStyle.OnChange := @TBBorderStyleChange;
end;

procedure THtmlTableDesignerAdvanced.UpdateTextBlockToolsLayout;
const
  Gap      = 3;
  GroupGap = 8;
  StartX   = 0;
  StartY   = 0;
var
  Y: Integer;

  procedure PlaceControl(
    AControl: TControl;
    AGroupEnd: Boolean = False);
  begin
    if not Assigned(AControl) then
      Exit;

    AControl.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    if AGroupEnd then
      Inc(Y, FToolButtonHeight + GroupGap)
    else
      Inc(Y, FToolButtonHeight + Gap);
  end;

begin
  Y := StartY;

  // Add / Delete
  PlaceControl(FBtTBAdd);
  PlaceControl(FBtTBDelete, True);

  // Positie
  PlaceControl(FBtTBMoveX);
  PlaceControl(FBtTBMoveY, True);

  // Font style
  PlaceControl(FBtTBBold);
  PlaceControl(FBtTBItalic);
  PlaceControl(FBtTBUnderline, True);

  // Alignment
  PlaceControl(FBtTBAlignLeft);
  PlaceControl(FBtTBAlignCenter);
  PlaceControl(FBtTBAlignRight);
  PlaceControl(FBtTBColor);
  PlaceControl(FBtTBFontSize,True);

  // Hyperlink
  PlaceControl(FBtTBCreateHyperlink);
  PlaceControl(FBtTBDelHyperlink, True);

  // Transparent
  PlaceControl(FBtTBTransparent);

  // background color
  PlaceControl(FBtTBGColor);

  // Border Width
  PlaceControl(FBtTBBorderSize);

  // Border Style - altijd als laatste
  if Assigned(FBtTBBorderStyle) then
  begin
    FBtTBBorderStyle.SetBounds(
      StartX,
      Y + 8,
      FToolButtonWidth,
      28
    );
  end;
end;

procedure THtmlTableDesignerAdvanced.UpdateTextBlockToolsHeight;
begin
  UpdateToolsHeight(
    FAantalTextBlockButtons
  );
end;

procedure THtmlTableDesignerAdvanced.UpdateTextBlockToolStates;
var
  B: TDesignerTextBlock;
  HasTextBlock: Boolean;
  ZeroX, ZeroY: Integer;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  FUpdatingTextBlockToolStates := True;
  try
    // ------------------------------------------------------------
    // Is er een TextBlock geselecteerd?
    // ------------------------------------------------------------

    HasTextBlock := Assigned(SelectedTextBlock);

    // ------------------------------------------------------------
    // Add blijft altijd beschikbaar
    // ------------------------------------------------------------

    if Assigned(FBtTBAdd) then
      FBtTBAdd.Enabled := True;

    // ------------------------------------------------------------
    // Algemene TextBlock controls
    // ------------------------------------------------------------

    if Assigned(FBtTBDelete) then
      FBtTBDelete.Enabled := HasTextBlock;

    if Assigned(FBtTBMoveX) then
      FBtTBMoveX.Enabled := HasTextBlock;

    if Assigned(FBtTBMoveY) then
      FBtTBMoveY.Enabled := HasTextBlock;

    if Assigned(FBtTBBold) then
      FBtTBBold.Enabled := HasTextBlock;

    if Assigned(FBtTBItalic) then
      FBtTBItalic.Enabled := HasTextBlock;

    if Assigned(FBtTBUnderline) then
      FBtTBUnderline.Enabled := HasTextBlock;

    if Assigned(FBtTBAlignLeft) then
      FBtTBAlignLeft.Enabled := HasTextBlock;

    if Assigned(FBtTBAlignCenter) then
      FBtTBAlignCenter.Enabled := HasTextBlock;

    if Assigned(FBtTBAlignRight) then
      FBtTBAlignRight.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Hyperlinks
    // ------------------------------------------------------------

    if Assigned(FBtTBCreateHyperlink) then
      FBtTBCreateHyperlink.Enabled := HasTextBlock;

    if Assigned(FBtTBDelHyperlink) then
      FBtTBDelHyperlink.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Kleuren
    // ------------------------------------------------------------

    if Assigned(FBtTBColor) then
      FBtTBColor.Enabled := HasTextBlock;

    if Assigned(FBtTBGColor) then
      FBtTBGColor.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Transparant
    // ------------------------------------------------------------

    if Assigned(FBtTBTransparent) then
      FBtTBTransparent.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Font size
    // ------------------------------------------------------------

    if Assigned(FBtTBFontSize) then
      FBtTBFontSize.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Border
    // ------------------------------------------------------------

    if Assigned(FBtTBBorderSize) then
      FBtTBBorderSize.Enabled := HasTextBlock;

    if Assigned(FBtTBBorderStyle) then
      FBtTBBorderStyle.Enabled := HasTextBlock;

    // ------------------------------------------------------------
    // Geen TextBlock geselecteerd
    // ------------------------------------------------------------

    if not HasTextBlock then
    begin
      if Assigned(FBtTBBold) then
        FBtTBBold.Down := False;

      if Assigned(FBtTBItalic) then
        FBtTBItalic.Down := False;

      if Assigned(FBtTBUnderline) then
        FBtTBUnderline.Down := False;

      if Assigned(FBtTBAlignLeft) then
        FBtTBAlignLeft.Down := False;

      if Assigned(FBtTBAlignCenter) then
        FBtTBAlignCenter.Down := False;

      if Assigned(FBtTBAlignRight) then
        FBtTBAlignRight.Down := False;

      if Assigned(FBtTBTransparent) then
        FBtTBTransparent.Down := False;

      Exit;
    end;

    // ------------------------------------------------------------
    // Geselecteerd TextBlock ophalen
    // ------------------------------------------------------------

    B := SelectedTextBlock;

    if not Assigned(B) then
      Exit;

    // ------------------------------------------------------------
    // Positie (mm t.o.v. nulpunt rulers)
    // ------------------------------------------------------------

    GetTextBlockRulerZero(ZeroX, ZeroY);

    if Assigned(FBtTBMoveX) then
      FBtTBMoveX.Value := TextBlockPosToMM(B.Rect.Left, ZeroX);

    if Assigned(FBtTBMoveY) then
      FBtTBMoveY.Value := TextBlockPosToMM(B.Rect.Top, ZeroY);

    // ------------------------------------------------------------
    // Font styles
    // ------------------------------------------------------------

    if Assigned(FBtTBBold) then
      FBtTBBold.Down :=
        fsBold in B.FontStyles;

    if Assigned(FBtTBItalic) then
      FBtTBItalic.Down :=
        fsItalic in B.FontStyles;

    if Assigned(FBtTBUnderline) then
      FBtTBUnderline.Down :=
        fsUnderline in B.FontStyles;

    // ------------------------------------------------------------
    // Alignment
    // ------------------------------------------------------------

    if Assigned(FBtTBAlignLeft) then
      FBtTBAlignLeft.Down :=
        B.Alignment = taLeftJustify;

    if Assigned(FBtTBAlignCenter) then
      FBtTBAlignCenter.Down :=
        B.Alignment = taCenter;

    if Assigned(FBtTBAlignRight) then
      FBtTBAlignRight.Down :=
        B.Alignment = taRightJustify;

    // ------------------------------------------------------------
    // Font size
    // ------------------------------------------------------------

    if Assigned(FBtTBFontSize) then
    begin
      if B.FontSize < FBtTBFontSize.MinValue then
        FBtTBFontSize.Value := FBtTBFontSize.MinValue
      else if B.FontSize > FBtTBFontSize.MaxValue then
        FBtTBFontSize.Value := FBtTBFontSize.MaxValue
      else
        FBtTBFontSize.Value := B.FontSize;
    end;

    // ------------------------------------------------------------
    // Text color
    // ------------------------------------------------------------

    if Assigned(FBtTBColor) then
      FBtTBColor.ButtonColor := B.FontColor;

    // ------------------------------------------------------------
    // Background color
    // ------------------------------------------------------------

    if Assigned(FBtTBGColor) then
      FBtTBGColor.ButtonColor := B.BgColor;

    // ------------------------------------------------------------
    // Transparant
    // ------------------------------------------------------------

    if Assigned(FBtTBTransparent) then
      FBtTBTransparent.Down := B.Transparent;

    // ------------------------------------------------------------
    // Border width
    // ------------------------------------------------------------

    if Assigned(FBtTBBorderSize) then
    begin
      if B.BorderWidth < FBtTBBorderSize.MinValue then
        FBtTBBorderSize.Value := FBtTBBorderSize.MinValue
      else if B.BorderWidth > FBtTBBorderSize.MaxValue then
        FBtTBBorderSize.Value := FBtTBBorderSize.MaxValue
      else
        FBtTBBorderSize.Value := B.BorderWidth;
    end;

    // ------------------------------------------------------------
    // Border style
    //
    // TCellBorderStyle -> TVisualBorderStyle
    // ------------------------------------------------------------

    if Assigned(FBtTBBorderStyle) then
    begin
      case B.BorderStyle of
        cbsNone:
          FBtTBBorderStyle.BorderStyle := vbsNone;

        cbsSolid:
          FBtTBBorderStyle.BorderStyle := vbsSolid;

        cbsDashed:
          FBtTBBorderStyle.BorderStyle := vbsDashed;

        cbsDotted:
          FBtTBBorderStyle.BorderStyle := vbsDotted;

        cbsDouble:
          FBtTBBorderStyle.BorderStyle := vbsDouble;
      end;
    end;

  finally
    FUpdatingTextBlockToolStates := False;
  end;
end;

procedure THtmlTableDesignerAdvanced.UpdateTextBlockToolsIcons;

  procedure LoadWideButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
    begin
      AButton.Caption := AFallbackCaption;
    end;
  end;

begin
  // ----------------------------------------------------------
  // TextBlock tools - AdvancedImagesWide
  // ----------------------------------------------------------

  LoadWideButtonIcon(
    FBtTBAdd,
    FTBImageIndexAdd,
    'TBA'
  );

  LoadWideButtonIcon(
    FBtTBDelete,
    FTBImageIndexDelete,
    'TBD'
  );

  LoadWideButtonIcon(
    FBtTBBold,
    FTBImageIndexBold,
    'B'
  );

  LoadWideButtonIcon(
    FBtTBItalic,
    FTBImageIndexItalic,
    'I'
  );

  LoadWideButtonIcon(
    FBtTBUnderline,
    FTBImageIndexUnderline,
    'U'
  );

  LoadWideButtonIcon(
    FBtTBAlignLeft,
    FTBImageIndexAlignLeft,
    'L'
  );

  LoadWideButtonIcon(
    FBtTBAlignCenter,
    FTBImageIndexAlignCenter,
    'C'
  );

  LoadWideButtonIcon(
    FBtTBAlignRight,
    FTBImageIndexAlignRight,
    'R'
  );

  LoadWideButtonIcon(
    FBtTBCreateHyperlink,
    FTBImageIndexCreateHyperlink,
    'HL+'
  );

  LoadWideButtonIcon(
    FBtTBDelHyperlink,
    FTBImageIndexDelHyperlink,
    'HL-'
  );

  LoadWideButtonIcon(
    FBtTBTransparent,
    FTBImageIndexTransparent,
    'TRA'
  );

end;

procedure THtmlTableDesignerAdvanced.TBAddButtonClick(Sender: TObject);
begin
  AddTextBlock;
   UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.TBDeleteButtonClick(Sender: TObject);
begin
   if Assigned(SelectedTextBlock) then
  begin
    DeleteSelectedTextBlock;
  end
  else
    ShowMessage(TR('Geen tekstblok geselecteerd.'));

  Invalidate;
  DoChange;
  exit;
end;

procedure THtmlTableDesignerAdvanced.TBBoldClick(Sender: TObject);
begin
  if FUpdatingTextBlockToolStates then
  Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  // ToggleTextBlockStyle kijkt zelf of er tekst geselecteerd is in de
  // inplace-editor: zo ja, enkel dat tekstdeel togglen; anders (zoals
  // voorheen) het hele tekstblok.
  ToggleTextBlockStyle(fsBold);

  UpdateTextBlockToolStates;
end;


procedure THtmlTableDesignerAdvanced.TBItalicClick(Sender: TObject);
begin
  if FUpdatingTextBlockToolStates then
  Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  ToggleTextBlockStyle(fsItalic);

  UpdateTextBlockToolStates;
end;


procedure THtmlTableDesignerAdvanced.TBUnderlineClick(Sender: TObject);
begin
  if FUpdatingTextBlockToolStates then
  Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  ToggleTextBlockStyle(fsUnderline);

  UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.TBAlignLeftClick(Sender: TObject);
 var
   B: TDesignerTextBlock;
 begin
   if FUpdatingTextBlockToolStates then
  Exit;
   if not Assigned(SelectedTextBlock) then
    Exit;

   B := SelectedTextBlock;

   if Assigned(B) then
         begin
           B.Alignment := taLeftJustify;

           TextBlockChanged;
         end;
 end;

procedure THtmlTableDesignerAdvanced.TBAlignCenterClick(Sender: TObject);
 var
    B: TDesignerTextBlock;
  begin
    if FUpdatingTextBlockToolStates then
  Exit;

    if not Assigned(SelectedTextBlock) then
     Exit;

    B := SelectedTextBlock;

    if Assigned(B) then
          begin
            B.Alignment := taCenter;

            TextBlockChanged;
          end;
  end;

procedure THtmlTableDesignerAdvanced.TBAlignRightClick(Sender: TObject);
var
    B: TDesignerTextBlock;
  begin
    if FUpdatingTextBlockToolStates then
  Exit;
    if not Assigned(SelectedTextBlock) then
     Exit;

    B := SelectedTextBlock;

    if Assigned(B) then
          begin
            B.Alignment := taRightJustify;

            TextBlockChanged;
          end;
end;

procedure THtmlTableDesignerAdvanced.TBCreateHyperlinkClick(
  Sender: TObject);
var
  URLText: string;
  LinkStart: Integer;
  LinkLength: Integer;
begin
  if FUpdatingTextBlockToolStates then
  Exit;
  if not Assigned(SelectedTextBlock) then
  begin
    ShowMessage(TR('Selecteer eerst een tekstblok.'));
    Exit;
  end;

  // Er moet tekst geselecteerd zijn in de TextBlock-editor
  if not GetTextBlockSelection(
    LinkStart,
    LinkLength
  ) then
  begin
    ShowMessage(
      TR('Selecteer eerst het tekstgedeelte dat een hyperlink moet worden.')
    );
    Exit;
  end;

  URLText :=
    InputBox(
      TR('Hyperlink'),
      TR('URL:'),
      ''
    );

  URLText := Trim(URLText);

  if URLText = '' then
    Exit;

  // Voeg het geselecteerde tekstbereik toe aan de nieuwe Links-lijst.
  SetTextBlockLink(
    LinkStart,
    LinkLength,
    URLText
  );
end;

procedure THtmlTableDesignerAdvanced.TBDelHyperlinkClick(
  Sender: TObject);
begin
  if FUpdatingTextBlockToolStates then
  Exit;
  if not Assigned(SelectedTextBlock) then
  begin
    ShowMessage(TR('Selecteer eerst een tekstblok.'));
    Exit;
  end;
  ClearTextBlockLink;
end;

procedure THtmlTableDesignerAdvanced.TBTransparentClick(Sender: TObject);
var
  B: TDesignerTextBlock;
begin
  if FUpdatingTextBlockToolStates then
  Exit;
  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  B.Transparent := not B.Transparent;

  TextBlockChanged;
  UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.TBBGColorChanged(Sender: TObject);
var
  B: TDesignerTextBlock;
begin
  if FUpdatingTextBlockToolStates then
  Exit;
  if not Assigned(SelectedTextBlock) then
    Exit;

 B := SelectedTextBlock;

  B.BgColor := FBtTBGColor.ButtonColor;

  // Zodra een achtergrondkleur gekozen wordt,
  // moet het TextBlock niet meer transparant zijn.
  B.Transparent := False;

  TextBlockChanged;

  UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.TBColorChanged(Sender: TObject);
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  // ApplyTextBlockFontColor kijkt zelf of er tekst geselecteerd is in
  // de inplace-editor: zo ja, enkel dat tekstdeel kleuren; anders
  // (zoals voorheen) het hele tekstblok.
  ApplyTextBlockFontColor(FBtTBColor.ButtonColor);
end;


procedure THtmlTableDesignerAdvanced.TBFontSizeChanged(Sender: TObject);
var
  B: TDesignerTextBlock;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  B.FontSize := FBtTBFontSize.Value;

  TextBlockChanged;
end;


procedure THtmlTableDesignerAdvanced.TBBorderStyleChange(Sender: TObject);
var
  B: TDesignerTextBlock;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  case FBtTBBorderStyle.BorderStyle of
    vbsNone:
      B.BorderStyle := cbsNone;

    vbsSolid:
      B.BorderStyle := cbsSolid;

    vbsDashed:
      B.BorderStyle := cbsDashed;

    vbsDotted:
      B.BorderStyle := cbsDotted;

    vbsDouble:
      B.BorderStyle := cbsDouble;
  end;

  TextBlockChanged;
  UpdateTextBlockToolStates;
end;


procedure THtmlTableDesignerAdvanced.TBBorderSizeChanged(Sender: TObject);
var
  B: TDesignerTextBlock;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  B.BorderWidth := FBtTBBorderSize.Value;

  TextBlockChanged;
  UpdateTextBlockToolStates;
end;


// Schermpositie (pixels) van het nulpunt van de rulers, zodat de
// TextBlock Move X/Y-spinedits dezelfde mm tonen als de rulers en
// dezelfde nulpunt-conventie gebruiken als Table Move X/Y.
procedure THtmlTableDesignerAdvanced.GetTextBlockRulerZero(
  out AZeroX, AZeroY: Integer);
begin
  GetPageOffset(AZeroX, AZeroY);

  // GetPageOffset telt TableOffsetX/Y mee als de pagina actief is
  if PageEnabled then
  begin
    Dec(AZeroX, TableOffsetX - TableRulerZero);
    Dec(AZeroY, TableOffsetY - TableRulerZero);
  end;
end;

// Schermpositie (pixels) -> mm op de ruler
function THtmlTableDesignerAdvanced.TextBlockPosToMM(
  APos, AZero: Integer): Integer;
var
  PxPerMM: Double;
begin
  // MMToPX(1000) i.p.v. MMToPX(1) om afrondingsfouten te vermijden
  PxPerMM := MMToPX(1000) / 1000;

  if PxPerMM <= 0 then
    Exit(0);

  Result := Round((APos - AZero) / PxPerMM);
end;


procedure THtmlTableDesignerAdvanced.TBMoveXChanged(Sender: TObject);
var
  B: TDesignerTextBlock;
  ZeroX, ZeroY: Integer;
  NewLeft: Integer;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  GetTextBlockRulerZero(ZeroX, ZeroY);

  NewLeft := ZeroX + MMToPX(FBtTBMoveX.Value);

  if B.Rect.Left = NewLeft then
    Exit;

  OffsetRect(B.Rect, NewLeft - B.Rect.Left, 0);

  TextBlockChanged;
end;


procedure THtmlTableDesignerAdvanced.TBMoveYChanged(Sender: TObject);
var
  B: TDesignerTextBlock;
  ZeroX, ZeroY: Integer;
  NewTop: Integer;
begin
  if FUpdatingTextBlockToolStates then
    Exit;

  if not Assigned(SelectedTextBlock) then
    Exit;

  B := SelectedTextBlock;

  GetTextBlockRulerZero(ZeroX, ZeroY);

  NewTop := ZeroY + MMToPX(FBtTBMoveY.Value);

  if B.Rect.Top = NewTop then
    Exit;

  OffsetRect(B.Rect, 0, NewTop - B.Rect.Top);

  TextBlockChanged;
end;


//------------------------------------------------------------------------------

{ =============================================================================
  SETTINGS TOOLS
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.CreateSettingsTools;
const
  Gap    = 3;
  StartX = 0;
  StartY = 0;
var
  Y: Integer;
begin
  Y := StartY;

  // ------------------------------------------------------------
  // Load defaults
  // ------------------------------------------------------------

  FBtSetLoad := TSpeedButton.Create(Self);
  FBtSetLoad.Parent := FTabSettings;
  FBtSetLoad.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtSetLoad.Caption := 'Load';
  FBtSetLoad.Hint := TRH(FBtSetLoad, 'Load default settings');
  FBtSetLoad.ShowHint := True;
  FBtSetLoad.OnClick := @SettingsLoadClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Save defaults
  // ------------------------------------------------------------

  FBtSetSave := TSpeedButton.Create(Self);
  FBtSetSave.Parent := FTabSettings;
  FBtSetSave.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtSetSave.Caption := 'Save';
  FBtSetSave.Hint := TRH(FBtSetSave, 'Save default settings');
  FBtSetSave.ShowHint := True;
  FBtSetSave.OnClick := @SettingsSaveClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Reset defaults
  // ------------------------------------------------------------

  FBtSetReset := TSpeedButton.Create(Self);
  FBtSetReset.Parent := FTabSettings;
  FBtSetReset.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtSetReset.Caption := 'Reset';
  FBtSetReset.Hint := TRH(FBtSetReset, 'Restore factory defaults');
  FBtSetReset.ShowHint := True;
  FBtSetReset.OnClick := @SettingsResetClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Apply defaults
  // ------------------------------------------------------------

  FBtSetApply := TSpeedButton.Create(Self);
  FBtSetApply.Parent := FTabSettings;
  FBtSetApply.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtSetApply.Caption := 'Apply';
  FBtSetApply.Hint := TRH(FBtSetApply, 'Apply defaults to current document');
  FBtSetApply.ShowHint := True;
  FBtSetApply.OnClick := @SettingsApplyClick;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Taal / vertalingen
  // ------------------------------------------------------------

  FBtSetLanguage := TSpeedButton.Create(Self);
  FBtSetLanguage.Parent := FTabSettings;
  FBtSetLanguage.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtSetLanguage.Caption := 'Taal...';
  FBtSetLanguage.Hint := TRH(FBtSetLanguage, 'Vertalingen bewerken (NL/EN/FR/DU)');
  FBtSetLanguage.ShowHint := True;
  FBtSetLanguage.OnClick := @SettingsLanguageClick;

  Inc(Y, FToolButtonHeight + Gap);

  FBtLanguage := TSpeedButton.Create(Self);
  FBtLanguage.Parent := FTabSettings;
  FSelectedLanguage := Language;
  FBtLanguage.Hint := TRH(FBtLanguage, 'Weergavetaal van de toolbox');
  FBtLanguage.ShowHint := True;
  FBtLanguage.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );
  FBtLanguage.OnClick := @LanguageButtonClick;
  UpdateLanguageButton;

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default column width
  // ------------------------------------------------------------

  FSetDefaultColWidth := TSpinEdit.Create(Self);
  FSetDefaultColWidth.Parent := FTabSettings;
  FSetDefaultColWidth.MinValue := 20;
  FSetDefaultColWidth.MaxValue := 500;
  FSetDefaultColWidth.Value := 100;
  FSetDefaultColWidth.Increment := 5;
  FSetDefaultColWidth.Hint := TRH(FSetDefaultColWidth, 'Default column width');
  FSetDefaultColWidth.ShowHint := True;
  FSetDefaultColWidth.OnChange :=
    @SettingsDefaultColWidthChanged;

  FSetDefaultColWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default row height
  // ------------------------------------------------------------

  FSetDefaultRowHeight := TSpinEdit.Create(Self);
  FSetDefaultRowHeight.Parent := FTabSettings;
  FSetDefaultRowHeight.MinValue := 10;
  FSetDefaultRowHeight.MaxValue := 200;
  FSetDefaultRowHeight.Value := 26;
  FSetDefaultRowHeight.Increment := 2;
  FSetDefaultRowHeight.Hint := TRH(FSetDefaultRowHeight, 'Default row height');
  FSetDefaultRowHeight.ShowHint := True;
  FSetDefaultRowHeight.OnChange :=
    @SettingsDefaultRowHeightChanged;

  FSetDefaultRowHeight.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default grid line width
  // ------------------------------------------------------------

  FSetGridLineWidth := TSpinEdit.Create(Self);
  FSetGridLineWidth.Parent := FTabSettings;
  FSetGridLineWidth.MinValue := 1;
  FSetGridLineWidth.MaxValue := 10;
  FSetGridLineWidth.Value := 1;
  FSetGridLineWidth.Increment := 1;
  FSetGridLineWidth.Hint := TRH(FSetGridLineWidth, 'Default grid line width');
  FSetGridLineWidth.ShowHint := True;
  FSetGridLineWidth.OnChange :=
    @SettingsGridLineWidthChanged;

  FSetGridLineWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default grid color
  // ------------------------------------------------------------

  FSetGridColor := TColorButton.Create(Self);
  FSetGridColor.Parent := FTabSettings;
  FSetGridColor.ButtonColor := clSilver;
  FSetGridColor.Hint := TRH(FSetGridColor, 'Default grid color');
  FSetGridColor.ShowHint := True;
  FSetGridColor.OnColorChanged :=
    @SettingsGridColorChanged;

  FSetGridColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default HTML-Body color
  // ------------------------------------------------------------

  FSetHtmlBgColor := TColorButton.Create(Self);
  FSetHtmlBgColor.Parent := FTabSettings;
  FSetHtmlBgColor.ButtonColor := clInfoBk;
  FSetHtmlBgColor.Hint := TRH(FSetHtmlBgColor, 'Default HTML-Body color');
  FSetHtmlBgColor.ShowHint := True;
  FSetHtmlBgColor.OnColorChanged :=
    @SettingsHtmlBgColorChanged;

  FSetHtmlBgColor.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default Show Layout Grid
  // ------------------------------------------------------------

  FChkShowLayoutGrid := TCheckBox.Create(Self);
  FChkShowLayoutGrid.Parent := FTabSettings;
  FChkShowLayoutGrid.Caption := 'Show layout grid';
  FChkShowLayoutGrid.Checked := False;
  FChkShowLayoutGrid.Hint := TRH(FChkShowLayoutGrid, 'Default show layout grid');
  FChkShowLayoutGrid.ShowHint := True;
  FChkShowLayoutGrid.OnChange :=
    @SettingsShowLayoutGridChanged;

  FChkShowLayoutGrid.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default Show Page Rulers
  // ------------------------------------------------------------

  FChkShowPageRulers := TCheckBox.Create(Self);
  FChkShowPageRulers.Parent := FTabSettings;
  FChkShowPageRulers.Caption := 'Show page rulers';
  FChkShowPageRulers.Checked := True;
  FChkShowPageRulers.Hint := TRH(FChkShowPageRulers, 'Default show page rulers');
  FChkShowPageRulers.ShowHint := True;
  FChkShowPageRulers.OnChange :=
    @SettingsShowPageRulersChanged;

  FChkShowPageRulers.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default Show Headers
  // ------------------------------------------------------------

  FChkShowHeaders := TCheckBox.Create(Self);
  FChkShowHeaders.Parent := FTabSettings;
  FChkShowHeaders.Caption := 'Show headers';
  FChkShowHeaders.Checked := True;
  FChkShowHeaders.Hint := TRH(FChkShowHeaders, 'Default show headers');
  FChkShowHeaders.ShowHint := True;
  FChkShowHeaders.OnChange :=
    @SettingsShowHeadersChanged;

  FChkShowHeaders.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);
  Inc(Y, 5);

  // ------------------------------------------------------------
  // Default Page Size
  // ------------------------------------------------------------

  FBtSetPageSize := TSpeedButton.Create(Self);
  FBtSetPageSize.Parent := FTabSettings;
  FBtSetPageSize.Caption := 'A4';
  FBtSetPageSize.Hint := TRH(FBtSetPageSize, 'A4 Portrait');
  FBtSetPageSize.ShowHint := True;
  FBtSetPageSize.Flat := True;
  FBtSetPageSize.OnClick :=
    @PageSizeButtonClick;

  FBtSetPageSize.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  CreatePageSizePopup;

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Page Width label
  // ------------------------------------------------------------

  FLblPageWidth := TLabel.Create(Self);
  FLblPageWidth.Parent := FTabSettings;
  FLblPageWidth.AutoSize := False;
  FLblPageWidth.Alignment := taCenter;
  FLblPageWidth.Layout := tlCenter;
  FLblPageWidth.Transparent := False;
  FLblPageWidth.Color := clYellow;
  FLblPageWidth.Font.Style := [];
  FLblPageWidth.Font.Color := clNavy;
  FLblPageWidth.Caption := '794';
  FLblPageWidth.Hint := Format(TR('Page width: %d px'), [794]);
  FLblPageWidth.ShowHint := True;

  FLblPageWidth.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  Inc(Y, FToolButtonHeight + Gap);

  // ------------------------------------------------------------
  // Page Height label
  // ------------------------------------------------------------

  FLblPageHeight := TLabel.Create(Self);
  FLblPageHeight.Parent := FTabSettings;
  FLblPageHeight.AutoSize := False;
  FLblPageHeight.Alignment := taCenter;
  FLblPageHeight.Layout := tlCenter;
  FLblPageHeight.Transparent := False;
  FLblPageHeight.Color := clYellow;
  FLblPageHeight.Font.Style := [];
  FLblPageHeight.Font.Color := clNavy;
  FLblPageHeight.Caption := '1123';
  FLblPageHeight.Hint := Format(TR('Page height: %d px'), [1123]);
  FLblPageHeight.ShowHint := True;

  FLblPageHeight.SetBounds(
    StartX,
    Y,
    FToolButtonWidth,
    FToolButtonHeight
  );

  // ------------------------------------------------------------
  // Final update
  // ------------------------------------------------------------

  UpdateSettingsToolsIcons;
  UpdateSettingsToolsLayout;
  UpdatePageSizeButton;
end;

procedure THtmlTableDesignerAdvanced.UpdateSettingsToolsLayout;
const
  Gap      = 0;
  GroupGap = 10;
  StartX   = 0;
  StartY   = 0;
var
  Y: Integer;

  procedure PlaceControl(
    AControl: TControl;
    AGroupEnd: Boolean = False);
  begin
    if not Assigned(AControl) then
      Exit;

    AControl.SetBounds(
      StartX,
      Y,
      FToolButtonWidth,
      FToolButtonHeight
    );

    if AGroupEnd then
      Inc(Y, FToolButtonHeight + GroupGap)
    else
      Inc(Y, FToolButtonHeight + Gap);
  end;

begin
  Y := StartY;

  // ------------------------------------------------------------
  // Bestandsbeheer
  // ------------------------------------------------------------

  PlaceControl(FBtSetLoad);
  PlaceControl(FBtSetSave);
  PlaceControl(FBtSetReset);
  PlaceControl(FBtSetApply,True);
  PlaceControl(FBtSetLanguage);
  PlaceControl(FBtLanguage, True);

  // ------------------------------------------------------------
  // Table / Grid defaults
  // ------------------------------------------------------------

  PlaceControl(FSetDefaultColWidth);
  PlaceControl(FSetDefaultRowHeight);
  PlaceControl(FSetGridLineWidth, True);

  // ------------------------------------------------------------
  // Kleuren
  // ------------------------------------------------------------

  PlaceControl(FSetGridColor);
  PlaceControl(FSetHtmlBgColor, True);

  // ------------------------------------------------------------
  // Weergave defaults
  // ------------------------------------------------------------

  PlaceControl(FChkShowLayoutGrid);
  PlaceControl(FChkShowPageRulers);
  PlaceControl(FChkShowHeaders, True);

  // ------------------------------------------------------------
  // Page defaults
  // ------------------------------------------------------------

  PlaceControl(FBtSetPageSize);
  PlaceControl(FLblPageWidth);
  PlaceControl(FLblPageHeight, True);

end;

procedure THtmlTableDesignerAdvanced.UpdateSettingsToolsHeight;
begin
   UpdateToolsHeight(
    FAantalSettingsButtons
  );
end;

procedure THtmlTableDesignerAdvanced.UpdateSettingsToolsIcons;

  procedure LoadWideButtonIcon(
    AButton: TSpeedButton;
    AImageIndex: Integer;
    const AFallbackCaption: string);
  begin
    if not Assigned(AButton) then
      Exit;

    AButton.Glyph.Clear;

    if Assigned(FAdvancedImagesWide) and
       (AImageIndex >= 0) and
       (AImageIndex < FAdvancedImagesWide.Count) then
    begin
      FAdvancedImagesWide.GetBitmap(
        AImageIndex,
        AButton.Glyph
      );

      AButton.Caption := '';
    end
    else
      AButton.Caption := AFallbackCaption;
  end;

begin
  LoadWideButtonIcon(
    FBtSetLoad,
    FSettingsLoadImageIndex,
    'Load'
  );

  LoadWideButtonIcon(
    FBtSetSave,
    FSettingsSaveImageIndex,
    'Save'
  );

  LoadWideButtonIcon(
    FBtSetReset,
    FSettingsResetImageIndex,
    'Reset'
  );

  LoadWideButtonIcon(
    FBtSetApply,
    FSettingsApplyImageIndex,
    'Apply'
  );

  LoadWideButtonIcon(
    FBtSetLanguage,
    FSettingsLanguageImageIndex,
    'Taal...'
  );
end;
// Bestandsnaal
function THtmlTableDesignerAdvanced.DefaultSettingsFileName: string;
begin
  Result :=
    IncludeTrailingPathDelimiter(
      ExtractFilePath(Application.ExeName)
    ) +
    'DesignerDefaults.ini';
end;

//SaveDefaultsSettings
procedure THtmlTableDesignerAdvanced.SaveDefaultSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(DefaultSettingsFileName);
  try
    // Slechts een handvol sleutels, dus qua snelheid maakt dit hier
    // nauwelijks verschil - vooral voor consistentie met SaveToHTD
    // in de basisunit, waar dit bij honderden writes wél telt.
    Ini.CacheUpdates := True;

    // ----------------------------------------------------------
    // Table
    // ----------------------------------------------------------

    Ini.WriteInteger(
      'Table',
      'DefaultColWidth',
      FDefaultSettings.DefaultColWidth
    );

    Ini.WriteInteger(
      'Table',
      'DefaultRowHeight',
      FDefaultSettings.DefaultRowHeight
    );

    // ----------------------------------------------------------
    // Grid
    // ----------------------------------------------------------

    Ini.WriteInteger(
      'Grid',
      'LineWidth',
      FDefaultSettings.GridLineWidth
    );

    Ini.WriteInteger(
      'Grid',
      'Color',
      Integer(FDefaultSettings.GridColor)
    );

    // ----------------------------------------------------------
    // Page
    // ----------------------------------------------------------

    Ini.WriteInteger(
      'Page',
      'HtmlBgColor',
      Integer(FDefaultSettings.HtmlBgColor)
    );

    Ini.WriteBool(
      'Page',
      'ShowLayoutGrid',
      FDefaultSettings.ShowLayoutGrid
    );

    Ini.WriteBool(
      'Page',
      'ShowPageRulers',
      FDefaultSettings.ShowPageRulers
    );

    Ini.WriteBool(
      'Page',
      'ShowHeaders',
      FDefaultSettings.ShowHeaders
    );

    Ini.WriteInteger(
      'Page',
      'Width',
      FDefaultSettings.PageWidth
    );

    Ini.WriteInteger(
      'Page',
      'Height',
      FDefaultSettings.PageHeight
    );

    // ----------------------------------------------------------
    // Taal
    // ----------------------------------------------------------

    Ini.WriteInteger(
      'Language',
      'Language',
      Ord(FDefaultSettings.Language)
    );

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

//LoadDefaultSettings
procedure THtmlTableDesignerAdvanced.LoadDefaultSettings;
var
  Ini: TIniFile;
  FileName: string;
begin
  // Begin altijd met geldige factory defaults.
  SetFactoryDefaultSettings;

  FileName := DefaultSettingsFileName;

  // Geen INI aanwezig:
  // factory defaults gewoon behouden.
  if not FileExists(FileName) then
    Exit;

  Ini := TIniFile.Create(FileName);
  try
    // ----------------------------------------------------------
    // Table
    // ----------------------------------------------------------

    FDefaultSettings.DefaultColWidth :=
      Ini.ReadInteger(
        'Table',
        'DefaultColWidth',
        FDefaultSettings.DefaultColWidth
      );

    FDefaultSettings.DefaultRowHeight :=
      Ini.ReadInteger(
        'Table',
        'DefaultRowHeight',
        FDefaultSettings.DefaultRowHeight
      );

    // ----------------------------------------------------------
    // Grid
    // ----------------------------------------------------------

    FDefaultSettings.GridLineWidth :=
      Ini.ReadInteger(
        'Grid',
        'LineWidth',
        FDefaultSettings.GridLineWidth
      );

    FDefaultSettings.GridColor :=
      TColor(
        Ini.ReadInteger(
          'Grid',
          'Color',
          Integer(FDefaultSettings.GridColor)
        )
      );

    // ----------------------------------------------------------
    // Page
    // ----------------------------------------------------------

    FDefaultSettings.HtmlBgColor :=
      TColor(
        Ini.ReadInteger(
          'Page',
          'HtmlBgColor',
          Integer(FDefaultSettings.HtmlBgColor)
        )
      );

    FDefaultSettings.ShowLayoutGrid :=
      Ini.ReadBool(
        'Page',
        'ShowLayoutGrid',
        FDefaultSettings.ShowLayoutGrid
      );

    FDefaultSettings.ShowPageRulers :=
      Ini.ReadBool(
        'Page',
        'ShowPageRulers',
        FDefaultSettings.ShowPageRulers
      );

    FDefaultSettings.ShowHeaders :=
      Ini.ReadBool(
        'Page',
        'ShowHeaders',
        FDefaultSettings.ShowHeaders
      );

    FDefaultSettings.PageWidth :=
      Ini.ReadInteger(
        'Page',
        'Width',
        FDefaultSettings.PageWidth
      );

    FDefaultSettings.PageHeight :=
      Ini.ReadInteger(
        'Page',
        'Height',
        FDefaultSettings.PageHeight
      );

    // ----------------------------------------------------------
    // Taal
    // ----------------------------------------------------------

    FDefaultSettings.Language :=
      TUILanguage(
        EnsureRange(
          Ini.ReadInteger(
            'Language',
            'Language',
            Ord(FDefaultSettings.Language)
          ),
          Ord(Low(TUILanguage)),
          Ord(High(TUILanguage))
        )
      );

  finally
    Ini.Free;
  end;
end;
{ =============================================================================
  LCL OVERRIDES EN NOTIFICATIES
  ============================================================================= }

procedure THtmlTableDesignerAdvanced.Paint;
begin
  inherited Paint;


end;

procedure THtmlTableDesignerAdvanced.MouseDown(
   Button: TMouseButton;
   Shift: TShiftState;
   X, Y: Integer
 );
 begin
   inherited MouseDown(
     Button,
     Shift,
     X,
     Y
   );

   UpdateCellToolStates;
   UpdateTextBlockToolStates;
 end;

procedure THtmlTableDesignerAdvanced.MouseUp(
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer
);
begin
  inherited MouseUp(Button, Shift, X, Y);

  // De basisklasse kan de definitieve selectie pas bij MouseUp vastleggen.
  // Lees daarom hier opnieuw de actuele selectie uit, zodat de TextBlock-
  // knoppen onmiddellijk worden in- of uitgeschakeld.
  UpdateCellToolStates;
  UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.MouseMove(
  Shift: TShiftState;
  X, Y: Integer
);
begin
  inherited MouseMove(
    Shift,
    X,
    Y
  );

   // Table tools synchroniseren tijdens Ctrl + mouse move
  if ssCtrl in Shift then
    UpdateTableToolStates;

  // TextBlock Move X/Y synchroniseren tijdens slepen van een TextBlock
  if (ssLeft in Shift) and Assigned(SelectedTextBlock) then
    UpdateTextBlockToolStates;
end;

{------------------------------------------------------------------------------}

procedure THtmlTableDesignerAdvanced.KeyDown(
  var Key: Word;
  Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  UpdateCellToolStates;
  UpdateTextBlockToolStates;
end;

procedure THtmlTableDesignerAdvanced.Notification(
  AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation <> opRemove then
    Exit;

  // ------------------------------------------------------------
  // Gewone Advanced ImageList
  // ------------------------------------------------------------

  if AComponent = FAdvancedImages then
  begin
    FAdvancedImages := nil;

    UpdateCellToolIcons;
    UpdateTextBlockToolsIcons;
    UpdateTableToolsIcons;
    UpdateSettingsToolsIcons;
    Invalidate;
    Exit;
  end;

  // ------------------------------------------------------------
  // Wide ImageList
  // Alleen gebruikt voor Image Left / Center / Right
  // ------------------------------------------------------------

  if AComponent = FAdvancedImagesWide then
  begin
    FAdvancedImagesWide := nil;

    // Hierdoor vallen de drie wide-buttons
    // terug op hun fallback-caption.
    UpdateCellToolIcons;

    Invalidate;
    Exit;
  end;

  // Vlaggen weg: taal-combobox toont weer alleen tekst
  if AComponent = FLanguageFlagImages then
  begin
    FLanguageFlagImages := nil;
    UpdateLanguageButton;
    Exit;
  end;
end;

{ =============================================================================
  COMPONENTREGISTRATIE
  ============================================================================= }

procedure Register;
begin
  RegisterComponents(
    'JanWilly',
    [THtmlTableDesignerAdvanced]
  );
end;

end.



