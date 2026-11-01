program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  // Onder Linux (GTK2) start uCefGtk2Widgetset eerst CEF (ingebouwde browser,
  // zie uMiniBrowserLinux) en maakt pas daarna de widgetset aan.
  {$IF DEFINED(LINUX) AND DEFINED(LCLGTK2)}
  uCefGtk2Widgetset,
  {$ELSE}
  Interfaces, // this includes the LCL widgetset
  {$ENDIF}
  Forms, Unit1, pexpandpanels
  // De ingebouwde CEF-browser (MiniBrowser) voor het voorbeeld, de help en
  // de PDF; onder Windows hier, onder Linux in uCefGtk2Widgetset/uMiniBrowserLinux.
  {$IFDEF WINDOWS}
  , uPreferences, uSimpleTextViewer, uMiniBrowser, uCEFApplication
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

