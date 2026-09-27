{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit HtmlTableDesigner_advanced;

{$warn 5023 off : no warning about unused units}
interface

uses
  HtmlTableDesignerAdvanced, HtmlTableDesignerAdvancedreg, BorderStyleButton, 
  HtmlTableDesignerLang, LangEditorForm, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('HtmlTableDesignerAdvanced', @HtmlTableDesignerAdvanced.Register
    );
  RegisterUnit('HtmlTableDesignerAdvancedreg', 
    @HtmlTableDesignerAdvancedreg.Register);
  RegisterUnit('BorderStyleButton', @BorderStyleButton.Register);
end;

initialization
  RegisterPackage('HtmlTableDesigner_advanced', @Register);
end.
