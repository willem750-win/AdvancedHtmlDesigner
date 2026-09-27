unit BorderStyleButton;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  Controls,
  Graphics,
  Menus;

type
  TVisualBorderStyle = (
    vbsNone,
    vbsSolid,
    vbsDashed,
    vbsDotted,
    vbsDouble
  );

  TBorderStyleButton = class(TCustomControl)
  private
    FPressed: Boolean;
    FBorderStyle: TVisualBorderStyle;
    FPopupMenu: TPopupMenu;
    FOnChange: TNotifyEvent;

    procedure SetBorderStyle(
      AValue: TVisualBorderStyle
    );

    procedure MenuNoneClick(Sender: TObject);
    procedure MenuSolidClick(Sender: TObject);
    procedure MenuDashedClick(Sender: TObject);
    procedure MenuDottedClick(Sender: TObject);
    procedure MenuDoubleClick(Sender: TObject);

    procedure CreatePopupMenu;
    procedure UpdateMenuChecks;

  protected
    procedure Paint; override;

    procedure MouseDown(
      Button: TMouseButton;
      Shift: TShiftState;
      X, Y: Integer
    ); override;
    procedure MouseUp(
      Button: TMouseButton;
      Shift: TShiftState;
      X, Y: Integer
    ); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property BorderStyle: TVisualBorderStyle
      read FBorderStyle
      write SetBorderStyle
      default vbsNone;

    property Align;
    property Anchors;
    property Color;
    property Enabled;
    property Font;
    property Hint;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property OnChange: TNotifyEvent
      read FOnChange
      write FOnChange;
  end;

procedure Register;

implementation


constructor TBorderStyleButton.Create(
  AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPressed := False;
  Width := 38;
  Height := 24;

  Color := clBtnFace;

  FBorderStyle := vbsNone;

  CreatePopupMenu;
end;


destructor TBorderStyleButton.Destroy;
begin
  FPopupMenu.Free;

  inherited Destroy;
end;


procedure TBorderStyleButton.CreatePopupMenu;

  procedure AddItem(
    const ACaption: string;
    AStyle: TVisualBorderStyle;
    AOnClick: TNotifyEvent
  );
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(FPopupMenu);

    Item.Caption := ACaption;
    Item.AutoCheck := False;
    Item.OnClick := AOnClick;

    // Koppel het item expliciet aan zijn stijl via Tag, zodat
    // UpdateMenuChecks hieronder niet langer op de toevallige
    // volgorde van toevoegen moet vertrouwen.
    Item.Tag := Ord(AStyle);

    FPopupMenu.Items.Add(Item);
  end;

begin
  FPopupMenu := TPopupMenu.Create(nil);

  AddItem(
    'None',
    vbsNone,
    @MenuNoneClick
  );

  AddItem(
    'Solid',
    vbsSolid,
    @MenuSolidClick
  );

  AddItem(
    'Dashed',
    vbsDashed,
    @MenuDashedClick
  );

  AddItem(
    'Dotted',
    vbsDotted,
    @MenuDottedClick
  );

  AddItem(
    'Double',
    vbsDouble,
    @MenuDoubleClick
  );

  UpdateMenuChecks;
end;


procedure TBorderStyleButton.UpdateMenuChecks;
var
  I: Integer;
begin
  if not Assigned(FPopupMenu) then
    Exit;

  for I := 0 to FPopupMenu.Items.Count - 1 do
    FPopupMenu.Items[I].Checked :=
      (FPopupMenu.Items[I].Tag = Ord(FBorderStyle));
end;


procedure TBorderStyleButton.SetBorderStyle(
  AValue: TVisualBorderStyle);
begin
  if FBorderStyle = AValue then
    Exit;

  FBorderStyle := AValue;

  UpdateMenuChecks;

  Invalidate;

  if Assigned(FOnChange) then
    FOnChange(Self);
end;


procedure TBorderStyleButton.MenuNoneClick(
  Sender: TObject);
begin
  BorderStyle := vbsNone;
end;


procedure TBorderStyleButton.MenuSolidClick(
  Sender: TObject);
begin
  BorderStyle := vbsSolid;
end;


procedure TBorderStyleButton.MenuDashedClick(
  Sender: TObject);
begin
  BorderStyle := vbsDashed;
end;


procedure TBorderStyleButton.MenuDottedClick(
  Sender: TObject);
begin
  BorderStyle := vbsDotted;
end;


procedure TBorderStyleButton.MenuDoubleClick(
  Sender: TObject);
begin
  BorderStyle := vbsDouble;
end;

procedure TBorderStyleButton.Paint;
var
  R: TRect;
  X: Integer;
  Y1, Y2: Integer;
  ArrowX, ArrowY: Integer;
  DashY: Integer;
  DotY: Integer;

begin
  inherited Paint;

  R := ClientRect;

  // ------------------------------------------------------------
  // Achtergrond
  // ------------------------------------------------------------

  Canvas.Brush.Style := bsSolid;

  if Enabled then
    Canvas.Brush.Color := Color
  else
    Canvas.Brush.Color := clBtnFace;

  Canvas.FillRect(R);

  // ------------------------------------------------------------
  // SpeedButton-achtige 3D rand
  // ------------------------------------------------------------

  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;

  if not FPressed then
  begin
    // Licht: boven + links
    Canvas.Pen.Color := clBtnHighlight;

    Canvas.MoveTo(0, Height - 1);
    Canvas.LineTo(0, 0);
    Canvas.LineTo(Width - 1, 0);

    // Donker: rechts + onder
    Canvas.Pen.Color := clBtnShadow;

    Canvas.MoveTo(Width - 1, 0);
    Canvas.LineTo(Width - 1, Height - 1);
    Canvas.LineTo(0, Height - 1);
  end
  else
  begin
    // Ingedrukt: omgekeerde 3D-rand
    Canvas.Pen.Color := clBtnShadow;

    Canvas.MoveTo(0, Height - 1);
    Canvas.LineTo(0, 0);
    Canvas.LineTo(Width - 1, 0);

    Canvas.Pen.Color := clBtnHighlight;

    Canvas.MoveTo(Width - 1, 0);
    Canvas.LineTo(Width - 1, Height - 1);
    Canvas.LineTo(0, Height - 1);
  end;

  // ------------------------------------------------------------
  // Positie verticale border
  // ------------------------------------------------------------

  X := (Width - 10) div 2;

  Y1 := 4;
  Y2 := Height - 4;

  if FPressed then
  begin
    Inc(X);
    Inc(Y1);
    Inc(Y2);
  end;

  // ------------------------------------------------------------
  // Border voorbeeld
  // ------------------------------------------------------------

  if Enabled then
    Canvas.Pen.Color := clWindowText
  else
    Canvas.Pen.Color := clGrayText;

  Canvas.Pen.Width := 2;

  case FBorderStyle of

    vbsNone:
      begin
        Canvas.Pen.Style := psSolid;

        // Accentkleur enkel wanneer actief; anders blijft de
        // clGrayText staan die hierboven al werd gezet, zodat de
        // preview ook echt grijs oogt wanneer de knop uitgeschakeld is.
        if Enabled then
          Canvas.Pen.Color := clRed;

        Canvas.MoveTo(X - 3, Y1 + 2);
        Canvas.LineTo(X + 3, Y2 - 2);

        Canvas.MoveTo(X + 3, Y1 + 2);
        Canvas.LineTo(X - 3, Y2 - 2);
      end;

    vbsSolid:
      begin
        Canvas.Pen.Style := psSolid;

        if Enabled then
          Canvas.Pen.Color := clNavy;

        Canvas.MoveTo(X, Y1);
        Canvas.LineTo(X, Y2);
      end;


    vbsDashed:
      begin
      Canvas.Pen.Style := psSolid;

      if Enabled then
        Canvas.Pen.Color := clNavy;

      // Kleine verticale streepjes
      Canvas.MoveTo(X, Y1);
      Canvas.LineTo(X, Y1 + 2);

      Canvas.MoveTo(X, Y1 + 4);
      Canvas.LineTo(X, Y1 + 6);

      Canvas.MoveTo(X, Y1 + 8);
      Canvas.LineTo(X, Y1 + 10);

      Canvas.MoveTo(X, Y1 + 12);
      Canvas.LineTo(X, Y1 + 14);

      Canvas.MoveTo(X, Y1 + 16);
      Canvas.LineTo(X, Y1 + 18);

      Canvas.MoveTo(X, Y1 + 20);
      Canvas.LineTo(X, Y1 + 22);
  end;


    vbsDotted:
     begin
       Canvas.Pen.Style := psSolid;

       if Enabled then
         Canvas.Pen.Color := clNavy;

       DotY := Y1;

      while DotY <= Y2 do
       begin
        Canvas.Pixels[X, DotY] :=
        Canvas.Pen.Color;

       Inc(DotY, 3);
     end;
  end;

    vbsDouble:
      begin
        Canvas.Pen.Style := psSolid;

        if Enabled then
          Canvas.Pen.Color := clNavy;

        Canvas.MoveTo(X - 2, Y1);
        Canvas.LineTo(X - 2, Y2);

        Canvas.MoveTo(X + 2, Y1);
        Canvas.LineTo(X + 2, Y2);
      end;
  end;

  // ------------------------------------------------------------
  // Dropdown pijltje
  // ------------------------------------------------------------

  Canvas.Pen.Style := psSolid;

  if Enabled then
    Canvas.Pen.Color := clWindowText
  else
    Canvas.Pen.Color := clGrayText;

  ArrowX := Width - 8;
  ArrowY := Height div 2;

  if FPressed then
  begin
    Inc(ArrowX);
    Inc(ArrowY);
  end;

  Canvas.MoveTo(
    ArrowX - 3,
    ArrowY - 2
  );

  Canvas.LineTo(
    ArrowX,
    ArrowY + 1
  );

  Canvas.LineTo(
    ArrowX + 3,
    ArrowY - 2
  );

  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
end;

procedure TBorderStyleButton.MouseDown(
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  inherited MouseDown(
    Button,
    Shift,
    X,
    Y
  );

  if not Enabled then
    Exit;

  if Button <> mbLeft then
    Exit;

  UpdateMenuChecks;

  // FPressed hier op True zetten en meteen hertekenen: FPopupMenu.PopUp
  // hieronder blokkeert tot het menu sluit, dus de knop toont hierdoor
  // ook echt zichtbaar ingedrukt zolang het menu open staat. MouseUp
  // zet FPressed nadien weer terug op False.
  FPressed := True;
  Invalidate;

  // ------------------------------------------------------------
  // Popup rechts naast de button
  // ------------------------------------------------------------

  P :=
    ClientToScreen(
      Point(
        Width,
        0
      )
    );

  FPopupMenu.PopUp(
    P.X,
    P.Y
  );
end;

procedure TBorderStyleButton.MouseUp(
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(
    Button,
    Shift,
    X,
    Y
  );

  if FPressed then
  begin
    FPressed := False;
    Invalidate;
  end;
end;


procedure Register;
begin
  RegisterComponents(
    'JanWilly',
    [
      TBorderStyleButton
    ]
  );
end;

end.

