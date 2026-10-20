program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, pexpandpanels
  // De ingebouwde CEF-browser (MiniBrowser) voor het voorbeeld en de help wordt
  // enkel onder Windows gebruikt; onder Linux opent alles in de systeembrowser.
  {$IFDEF WINDOWS}
  , uMiniBrowser, uPreferences, uSimpleTextViewer, uCEFApplication
  {$ENDIF}
  ;

{$R *.res}

begin
  {$IFDEF WINDOWS}
  CreateGlobalCEFApp;
  // scheidt het hoofdproces van de hulpprocessen van CEF
  if not GlobalCEFApp.StartMainProcess then
    Exit;
  {$ENDIF}

  RequireDerivedFormResource:=True;
  Application.Title:='Advanced Html Designer';
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

