unit HtmlTableDesignerAdvancedReg;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  TypInfo,
  ImgList,
  PropEdits,
  GraphPropEdits,
  HtmlTableDesignerAdvanced;

type

  { ---------------------------------------------------------------------------
    Property editor voor AdvancedImages
    Normale ImageList: 16 x 16
    --------------------------------------------------------------------------- }

  TAdvancedImageIndexPropertyEditor = class(TImageIndexPropertyEditor)
  protected
    function GetImageList: TCustomImageList; override;
  end;


  { ---------------------------------------------------------------------------
    Property editor voor AdvancedImagesWide
    Wide ImageList: 16 x 34
    --------------------------------------------------------------------------- }

  TAdvancedWideImageIndexPropertyEditor = class(TImageIndexPropertyEditor)
  protected
    function GetImageList: TCustomImageList; override;
  end;


procedure Register;


implementation


{ =============================================================================
  TAdvancedImageIndexPropertyEditor
  AdvancedImages - 16 x 16
  ============================================================================= }

function TAdvancedImageIndexPropertyEditor.GetImageList:
  TCustomImageList;
begin
  Result := nil;

  if GetComponent(0) is THtmlTableDesignerAdvanced then
  begin
    Result :=
      THtmlTableDesignerAdvanced(
        GetComponent(0)
      ).AdvancedImages;
  end;
end;


{ =============================================================================
  TAdvancedWideImageIndexPropertyEditor
  AdvancedImagesWide - 16 x 34
  ============================================================================= }

function TAdvancedWideImageIndexPropertyEditor.GetImageList:
  TCustomImageList;
begin
  Result := nil;

  if GetComponent(0) is THtmlTableDesignerAdvanced then
  begin
    Result :=
      THtmlTableDesignerAdvanced(
        GetComponent(0)
      ).AdvancedImagesWide;
  end;
end;


{ =============================================================================
  Register
  ============================================================================= }

procedure Register;
begin

  { ===========================================================================
    HOOFDKNOPPEN
    Table / Cell / TextBlock / Settings

    Deze gebruiken AdvancedImagesWide (16 x 34)
    =========================================================================== }

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TableImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // ---------------------------------------------------------------------------
  // Cell hoofdknop
  // ---------------------------------------------------------------------------

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // ---------------------------------------------------------------------------
  // TextBlock hoofdknop
  // ---------------------------------------------------------------------------

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TextBlockImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


   //---------------------------------------------------------------------------
   // Settings hoofdknop
   //---------------------------------------------------------------------------
   RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'SettingsImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );



  { ===========================================================================
  TABLE TOOLS
  Deze gebruiken AdvancedImagesWide (16 x 34)
  =========================================================================== }

  // New / Clear table

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableNew',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Add Row

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableAddRow',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Add Column

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableAddColumn',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Row

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableDeleteRow',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Column

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableDeleteColumn',
    TAdvancedWideImageIndexPropertyEditor
  );

   { ===========================================================================
    CELL TOOLS - WIDE     TEKSTOPMAAK

    Deze gebruiken AdvancedImagesWide (16 x 34)
    =========================================================================== }
  // Bold

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellBoldImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );

  // Italic

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellItalicImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );

  // Underline

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellUnderlineImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );





  { ---------------------------------------------------------------------------
    Tekstuitlijning
    --------------------------------------------------------------------------- }

  // Align Left

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellAlignLeftImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Align Center

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellAlignCenterImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Align Right

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellAlignRightImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ---------------------------------------------------------------------------
    Copy / Paste
    --------------------------------------------------------------------------- }

  // Copy

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellCopyImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Paste

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellPasteImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ---------------------------------------------------------------------------
    Tekst-hyperlinks
    --------------------------------------------------------------------------- }

  // Create Text Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellCreateTextHyperlinkImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Text Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellDelTextHyperlinkImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ---------------------------------------------------------------------------
    Afbeeldings-hyperlinks
    --------------------------------------------------------------------------- }

  // Create Image Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellCreateHyperlinkImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Image Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'CellDelHyperlinkImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ---------------------------------------------------------------------------
    Afbeelding toevoegen / verwijderen
    --------------------------------------------------------------------------- }

  // Add Image

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'AddImageImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Image

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'DelImageImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ---------------------------------------------------------------------------
    Afbeeldingsuitlijning
    --------------------------------------------------------------------------- }

  // Image Left

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageLeftImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Image Center

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageCenterImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Image Right

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageRightImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );

  // Image Size

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageSizeImageIndex',
    TAdvancedWideImageIndexPropertyEditor
  );

  { ---------------------------------------------------------------------------
    Merge / Unmerge

    Deze knoppen zijn naar FTabCell verhuisd
    en gebruiken AdvancedImagesWide.
    --------------------------------------------------------------------------- }

  // Merge Cells

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableMergeCells',
    TAdvancedWideImageIndexPropertyEditor
  );


  // UnMerge Cells

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'ImageIndexTableUnMergeCells',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ===========================================================================
    TEXTBLOCK TOOLS

    Alle onderstaande TextBlock-knoppen gebruiken
    AdvancedImagesWide (16 x 34)
    =========================================================================== }

  // Add TextBlock

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexAdd',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete TextBlock

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexDelete',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Bold

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexBold',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Italic

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexItalic',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Underline

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexUnderline',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Align Left

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexAlignLeft',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Align Center

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexAlignCenter',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Align Right

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexAlignRight',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Create Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexCreateHyperlink',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Delete Hyperlink

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexDelHyperlink',
    TAdvancedWideImageIndexPropertyEditor
  );


  // Transparent True / False

  RegisterPropertyEditor(
    TypeInfo(Integer),
    THtmlTableDesignerAdvanced,
    'TBImageIndexTransparent',
    TAdvancedWideImageIndexPropertyEditor
  );


  { ===========================================================================
    SETTINGS TOOLS

    AdvancedImagesWide (16 x 34)
    =========================================================================== }

 RegisterPropertyEditor(
  TypeInfo(Integer),
  THtmlTableDesignerAdvanced,
  'SettingsLoadImageIndex',
  TAdvancedWideImageIndexPropertyEditor
);

RegisterPropertyEditor(
  TypeInfo(Integer),
  THtmlTableDesignerAdvanced,
  'SettingsSaveImageIndex',
  TAdvancedWideImageIndexPropertyEditor
);

RegisterPropertyEditor(
  TypeInfo(Integer),
  THtmlTableDesignerAdvanced,
  'SettingsResetImageIndex',
  TAdvancedWideImageIndexPropertyEditor
);

RegisterPropertyEditor(
  TypeInfo(Integer),
  THtmlTableDesignerAdvanced,
  'SettingsApplyImageIndex',
  TAdvancedWideImageIndexPropertyEditor
);

RegisterPropertyEditor(
  TypeInfo(Integer),
  THtmlTableDesignerAdvanced,
  'SettingsLanguageImageIndex',
  TAdvancedWideImageIndexPropertyEditor
);

end;


end.
