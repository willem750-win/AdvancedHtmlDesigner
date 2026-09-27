{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TableDesignerHtml;

{$warn 5023 off : no warning about unused units}
interface

uses
  HtmlTableDesigner, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('HtmlTableDesigner', @HtmlTableDesigner.Register);
end;

initialization
  RegisterPackage('TableDesignerHtml', @Register);
end.
