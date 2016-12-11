unit toolsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, StdCtrls, Grids, LCLIntf, LCLType, Buttons, GraphMath, Math, Spin, FPCanvas, TypInfo, LCL,
  figuresunit,scalesunit;

type

  TFigureClass = figuresunit.TFigureClass;
  TToolClass   = class of TTool;
  TParameterClass = class of TParameter;

  TTool = class
    public
    Bitmap: TBitmap;
    FigureClass: TFigureClass;
    Parameter: TParameterClass;
    Parameters: array of TParameterClass;
    procedure ParametersCreate; virtual;
    procedure Initialize(APanel: TPanel); virtual;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); virtual;
    procedure AddPoint(APoint: TPoint); virtual;
    procedure StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean); virtual;
  end;

  TTwoPointsTools = class(TTool)
  public
    procedure AddPoint(APoint: TPoint); override;
  end;

  TSpecificTools = class(TTool)
  public
  end;

  THandTool       = class(TSpecificTools)
  public
    Figure: THandFigure;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);override;
    procedure AddPoint(APoint: TPoint); override;
    procedure StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean); override;
  end;

  TPolylineTool   = class(TTool)
  public
    Figure: TPolyline;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TRectangleTool  = class(TTwoPointsTools)
  public
    Figure: TRectangle;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TRoundRectTool  = class(TTwoPointsTools)
  public
    Figure: TRectangle;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TEllipseTool    = class(TTwoPointsTools)
  public
    Figure: TEllipse;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TPolygonTool = class(TTwoPointsTools)
  public
    Figure: TPolygon;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TLineTool       = class(TTwoPointsTools)
  public
    Figure: TLine;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure ParametersCreate; override;
  end;

  TMagnifierTool  = class(TTwoPointsTools)
  public
    Figure: TRectangle;
    procedure FigureCreate(AFigureClass: TFigureClass; APoint: TPoint); override;
    procedure StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean); override;
  end;

  TRectSelectionTool = class(TTwoPointsTools)
  public
    Figure: TRectangle;
    procedure AddPoint(APoint: TPoint); override;
    procedure StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean); override;
  end;

  TParameter = class
  public
    procedure CreateEditor (APanel: TPanel); virtual; abstract;
    procedure ChangeEditor (Sender: TObject); virtual; abstract;
    procedure StyleComboBoxDrawItem(Control: TWinControl;
      Index: Integer; ARect: TRect; State: TOwnerDrawState);
  end;

  TLineWidthParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TLineStyleParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TFillStyleParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TRoundingXParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TRoundingYParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TCornersParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TAngleParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;

  TAngleModeParameter = class (TParameter)
  public
    procedure CreateEditor (APanel: TPanel); override;
    procedure ChangeEditor (Sender: TObject); override;
  end;


var
  ToolsRegister: array of TTool;
  OffsetFirstPoint: TPoint;
  AngleSpinEdit: TSpinEdit;
  AngleMode: boolean;
  CtrlBtn: boolean;
implementation

procedure TTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  SetLength(Figures,length(Figures)+1);
  Figures[high(Figures)] := AFigureClass.Create;
  with Figures[high(Figures)] do begin
    FigurePenColor := PenColor;
    FigureBrushColor := BrushColor;
    SetLength(Points,1);
    Points[high(Points)] := scalesunit.ScreenToWorld(APoint);
  end;
end;

procedure TPolylineTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TPolyline do begin
    FigurePenStyle := PenStyle;
    FigurePenWidth := PenWidth;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure THandTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  OffsetFirstPoint.x:=Offset.x+APoint.x;
  OffsetFirstPoint.y:=Offset.y+APoint.y;
end;

procedure TRectangleTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TRectangle do begin
    FigurePenStyle := PenStyle;
    FigureBrushStyle := BrushStyle;
    FigurePenWidth := PenWidth;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TRoundRectTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TRoundRect do begin
    FigurePenStyle := PenStyle;
    FigureBrushStyle := BrushStyle;
    FigurePenWidth := PenWidth;
    FigureR := RectR;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TEllipseTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TEllipse do begin
    FigurePenStyle := PenStyle;
    FigureBrushStyle := BrushStyle;
    FigurePenWidth := PenWidth;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TLineTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TLine do begin
    FigurePenStyle := PenStyle;
    FigurePenWidth := PenWidth;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TPolygonTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] as TPolygon do begin
    FigurePenStyle := PenStyle;
    FigureBrushStyle := BrushStyle;
    FigurePenWidth := PenWidth;
    FigureCorners := Corners;
    FigureAngle := Angle;
    FigureAngleMode := AngleMode;
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TMagnifierTool.FigureCreate(AFigureClass: TFigureClass; APoint: TPoint);
begin
  Inherited;
end;

procedure TTool.AddPoint(APoint: TPoint);
begin
  with Figures[high(Figures)] do begin
    SetLength(Points,length(Points)+1);
    Points[high(Points)] := scalesunit.ScreenToWorld(APoint);
  end;
  SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TTwoPointsTools.AddPoint(APoint: TPoint);
begin
  with Figures[high(Figures)] do begin
    SetLength(Points,2);
    Points[high(Points)] := scalesunit.ScreenToWorld(APoint);
  end;
  if (ClassName <> 'TMagnifierTool') and (ClassName <> 'TSelectionTool') then
        SetMaxMinFloatPoints(ScreenToWorld(APoint));
end;

procedure TRectSelectionTool.AddPoint(APoint: TPoint);
begin
  Inherited;
  with Figures[high(Figures)] do begin
    Points[high(Points)] := scalesunit.ScreenToWorld(APoint);
  end;
end;


procedure THandTool.AddPoint(APoint: TPoint);
begin
  with Figures[high(Figures)] do begin
    SetLength(Points,2);
    Points[high(Points)].x := scalesunit.ScreenToWorld(APoint).x -
      Points[low(Points)].x;
    Points[high(Points)].y := scalesunit.ScreenToWorld(APoint).y -
      Points[low(Points)].y;
    Offset.x := OffsetFirstPoint.x-APoint.x;
    Offset.y := OffsetFirstPoint.y-APoint.y;
  end;
end;

procedure RegisterTool(ATool: TTool; AFigureClass: TFigureClass; ABitmapFile: string);
begin
  setlength(ToolsRegister,length(ToolsRegister)+1);
  ToolsRegister[high(ToolsRegister)] := ATool;
  with ToolsRegister[high(ToolsRegister)] do begin
    Bitmap := TBitmap.Create;
    Bitmap.LoadFromFile(ABitmapFile);
    FigureClass := AFigureClass;
  end;
end;

procedure TTool.StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean);
begin
end;

procedure TMagnifierTool.StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean);
var
  t: double;
begin
    with Figures[high(Figures)] do begin
      if(Points[low(Points)].x+5>Points[high(Points)].x) then
      begin
        if (not RBtn) then t := Zoom*2 else t := Zoom / 2;
        if (t>800) then
        begin
          setlength(Figures,length(Figures)-1);
          exit;
        end;
        Zoom := t;
        scalesunit.ToPointZoom(FloatPoint(X,Y));
        RBtn := false;
      end else begin
        RectZoom(AHeight, AWidth, Points[0], Points[1]);
      end;
    setlength(Figures,length(Figures)-1);
  end;
end;

procedure TRectSelectionTool.StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean);
var
  t: HRGN;
  i: integer;
  mode: boolean;
begin
  with Figures[high(Figures)] do
  begin
    FigureRegion := CreateRectRgn (WorldToScreen(Points[low(Points)]) .x,
                                   WorldToScreen(Points[low(Points)]) .y,
                                   WorldToScreen(Points[high(Points)]).x,
                                   WorldToScreen(Points[high(Points)]).y);
    if (abs(WorldToScreen(Points[low(Points)]) .x -
        WorldToScreen(Points[high(Points)]).x) < 5) then
     mode := false else mode := true;
  end;

  case mode of
  true:
  begin
    if (not CtrlBtn) then
    begin
      for i := high(Figures)-1 downto low(Figures)+1  do
      begin
        with Figures[i] do
        begin
          if (CombineRgn(t,Figures[i].FigureRegion,Figures[high(Figures)].FigureRegion,RGN_AND) <> NULLREGION) then
              Selected := false;
        end;
      end;
    end;
    for i := low(Figures)+1 to high(Figures)-1 do
    begin
        DeleteObject(Figures[i].FigureRegion);
        Figures[i].SetRegion;
        t := CreateRectRgn(1,1,2,2);
        if (CombineRgn(t,Figures[i].FigureRegion,Figures[high(Figures)].FigureRegion,RGN_AND) <> NULLREGION)  and (Figures[i].Selected = false) then
          Figures[i].Selected := true
        else if (CombineRgn(t,Figures[i].FigureRegion,Figures[high(Figures)].FigureRegion,RGN_AND) <> NULLREGION)  and (Figures[i].Selected = true) then
          Figures[i].Selected := false;
        DeleteObject(t);
    end;
  end;
  false:
  begin
      if (not CtrlBtn) then
      begin
        for i := high(Figures)-1 downto low(Figures)+1  do
        begin
          with Figures[i] do
          begin
            if (PtInRegion(FigureRegion,X,Y)=false) then
                Selected := false;
          end;
        end;
      end;
      for i := high(Figures)-1 downto low(Figures)+1  do
      begin
        with Figures[i] do
        begin
          DeleteObject(FigureRegion);
          SetRegion;
          if (PtInRegion(FigureRegion,X,Y)=true) and (Selected = false) then
          begin
            Selected := true;
            break;
          end
          else if (PtInRegion(FigureRegion,X,Y)=true) and (Selected = true) then
          begin
            Selected := false;
            break;
          end;
        end;
      end;
  end;
  end;
  setlength(Figures,length(Figures)-1);
end;

procedure THandTool.StopDraw(X,Y, AHeight, AWidth: integer; RBtn: boolean);
begin
  setlength(Figures,length(Figures)-1);
end;

procedure TLineStyleParameter.ChangeEditor(Sender: TObject);
begin
  figuresunit.PenStyle := TFPPenStyle(GetEnumValue(TypeInfo(TFPPenStyle),
  (Sender as TComboBox).Items[(Sender as TComboBox).ItemIndex]));
end;

procedure TFillStyleParameter.ChangeEditor(Sender: TObject);
begin
  figuresunit.BrushStyle := TBrushStyle(GetEnumValue(TypeInfo(TBrushStyle),
  (Sender as TComboBox).Items[(Sender as TComboBox).ItemIndex]));
end;

procedure TLineWidthParameter.ChangeEditor (Sender: TObject);
begin
  PenWidth := (Sender as TSpinEdit).Value;
end;

procedure TCornersParameter.ChangeEditor (Sender: TObject);
begin
  Corners := (Sender as TSpinEdit).Value;
end;

procedure TAngleParameter.ChangeEditor (Sender: TObject);
begin
  Angle := ((Sender as TSpinEdit).Value*Pi)/180;
end;

procedure TAngleModeParameter.ChangeEditor (Sender: TObject);
begin
  if ((Sender as TCheckBox).Checked = true) then
  begin
    AngleSpinEdit.Enabled := true;
    AngleMode := true;
  end else
  begin
    AngleSpinEdit.Enabled := false;
    AngleMode := false;
  end;
end;

procedure TRoundingXParameter.ChangeEditor (Sender: TObject);
begin
  RectR.x := (Sender as TSpinEdit).Value;
end;

procedure TRoundingYParameter.ChangeEditor (Sender: TObject);
begin
  RectR.y := (Sender as TSpinEdit).Value;
end;

procedure TLineWidthParameter.CreateEditor(APanel: TPanel);
var
  LineWidthSpinEdit: TSpinEdit;
  l: Tlabel;
begin
  LineWidthSpinEdit := TSpinEdit.Create(APanel);
  LineWidthSpinEdit.Name := 'LineWidthSpinEdit';
  LineWidthSpinEdit.Parent := APanel;
  LineWidthSpinEdit.Align := alBottom;
  LineWidthSpinEdit.MaxValue := 100;
  LineWidthSpinEdit.MinValue := 1;
  LineWidthSpinEdit.Value := PenWidth;
  LineWidthSpinEdit.OnChange := @ChangeEditor;
  l := TLabel.Create(APanel);
  l.name := 'LineWidthLabel';
  l.Caption := 'Line Width';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TCornersParameter.CreateEditor(APanel: TPanel);
var
  CornersSpinEdit: TSpinEdit;
  l: TLabel;
begin
  CornersSpinEdit := TSpinEdit.Create(APanel);
  CornersSpinEdit.Name := 'CornersSpinEdit';
  CornersSpinEdit.Parent := APanel;
  CornersSpinEdit.Align := alBottom;
  CornersSpinEdit.MaxValue := 50;
  CornersSpinEdit.MinValue := 3;
  CornersSpinEdit.Value := Corners;
  CornersSpinEdit.OnChange := @ChangeEditor;
  l := TLabel.Create(APanel);
  l.name := 'CornersLabel';
  l.Caption := 'Number of corners';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TAngleParameter.CreateEditor(APanel: TPanel);
var
  l: TLabel;
begin
  AngleSpinEdit := TSpinEdit.Create(APanel);
  AngleSpinEdit.Name := 'AngleSpinEdit';
  AngleSpinEdit.Parent := APanel;
  AngleSpinEdit.Align := alBottom;
  AngleSpinEdit.MaxValue := 360;
  AngleSpinEdit.MinValue := 0;
  AngleSpinEdit.Value := Angle;
  AngleSpinEdit.OnChange := @ChangeEditor;
  AngleSpinEdit.Enabled := false;
  l := TLabel.Create(APanel);
  l.name := 'AngleLabel';
  l.Caption := 'Rotate Angle';
  l.Parent := APanel;
  l.Align := alBottom;
end;
procedure TAngleModeParameter.CreateEditor(APanel: TPanel);
var
  c: TCheckBox;
begin
  c := TCheckBox.Create(APanel);
  c.Parent := APanel;
  c.name := 'AngleModeCheckBox';
  c.caption := 'Manual angle control';
  c.onChange := @ChangeEditor;
  c.Align := alBottom;
end;

procedure TRoundingXParameter.CreateEditor(APanel: TPanel);
var
  l: TLabel;
  RSpinEditX: TSpinEdit;
begin
  RSpinEditX := TSpinEdit.Create(APanel);
  RSpinEditX.Name := 'RSpinEditX';
  RSpinEditX.Parent := APanel;
  RSpinEditX.Align := alBottom;
  RSpinEditX.MaxValue := 500;
  RSpinEditX.MinValue := 0;
  RSpinEditX.Value := RectR.x;
  RSpinEditX.OnChange := @ChangeEditor;

  l := TLabel.Create(APanel);
  l.name := 'RSpinEditLabelX';
  l.Caption := 'Rounding Radius (X)';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TRoundingYParameter.CreateEditor(APanel: TPanel);
var
  l: TLabel;
  RSpinEditY: TSpinEdit;
begin
  RSpinEditY := TSpinEdit.Create(APanel);
  RSpinEditY.Name := 'RSpinEditY';
  RSpinEditY.Parent := APanel;
  RSpinEditY.Align := alBottom;
  RSpinEditY.MaxValue := 500;
  RSpinEditY.MinValue := 0;
  RSpinEditY.Value := RectR.y;
  RSpinEditY.OnChange := @ChangeEditor;

  l := TLabel.Create(APanel);
  l.name := 'RSpinEditLabelY';
  l.Caption := 'Rounding Radius (Y)';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TLineStyleParameter.CreateEditor(APanel: TPanel);
var
  LineStyleComboBox: TComboBox;
  i: integer;
  l: TLabel;
begin
  LineStyleComboBox := TComboBox.Create(APanel);
  LineStyleComboBox.Name := ('LineStyleComboBox');
  LineStyleComboBox.Parent := APanel;
  LineStyleComboBox.Align := alBottom;
  LineStyleComboBox.ReadOnly := true;
  for i := ord(low(TFPPenStyle)) to ord(high(TFPPenStyle))-3 do
  begin
    LineStyleComboBox.Items.Add(GetEnumName(TypeInfo(TFPPenStyle),i));
  end;
  LineStyleComboBox.Items.Add(GetEnumName(TypeInfo(TFPPenStyle),
    ord(high(TFPPenStyle))));
  LineStyleComboBox.ItemIndex := ord(PenStyle);
  LineStyleComboBox.OnSelect  := @ChangeEditor;
  LineStyleComboBox.Style := csOwnerDrawFixed;
  LineStyleComboBox.OnDrawItem := @StyleComboBoxDrawItem;
  l := TLabel.Create(APanel);
  l.name := 'LineStyleLabel';
  l.Caption := 'Line Style';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TParameter.StyleComboBoxDrawItem(Control: TWinControl;
Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  GraphicsRect: TRect;
  t: TComboBox;
begin
    t := (Control as TComboBox);
    GraphicsRect.Left   := ARect.Left   + 2;
    GraphicsRect.Right  := ARect.Left   + 18;
    GraphicsRect.Top    := ARect.Top    + 1;
    GraphicsRect.Bottom := ARect.Bottom - 1;

   t.Canvas.FillRect(ARect);
   t.Canvas.TextRect(ARect, 22, ARect.Top, (Control as TComboBox).Items[Index]);
   t.Canvas.Pen.Style := TFPPenStyle(GetEnumValue(TypeInfo(TFPPenStyle),
     t.Items[Index]));
   t.Canvas.Brush.Style := TBrushStyle(GetEnumValue(TypeInfo(TBrushStyle),
     t.Items[Index]));
   t.Canvas.Brush.Color := clBlack;

   //костыль для bsClear
   if TBrushStyle(GetEnumValue(TypeInfo(TBrushStyle),
     t.Items[Index])) = TBrushStyle(bsClear) then
   begin
     t.Canvas.Brush.Style := bsSolid;
     t.Canvas.Brush.Color := clWhite;
   end;

   t.Canvas.Rectangle(GraphicsRect);
end;

procedure TFillStyleParameter.CreateEditor(APanel: TPanel);
var
  FillStyleComboBox: TComboBox;
  i: integer;
  l: TLabel;
begin
  FillStyleComboBox := TComboBox.Create(APanel);
  FillStyleComboBox.Name := ('FillStyleComboBox');
  FillStyleComboBox.Parent := APanel;
  FillStyleComboBox.Align := alBottom;
  FillStyleComboBox.ReadOnly := true;
  for i := ord(low(TBrushStyle)) to ord(high(TBrushStyle))-2 do
  begin
    FillStyleComboBox.Items.Add(GetEnumName(TypeInfo(TBrushStyle),i));
  end;
  FillStyleComboBox.ItemIndex := ord(BrushStyle);
  FillStyleComboBox.OnSelect  := @ChangeEditor;
  FillStyleComboBox.Style := csOwnerDrawFixed;
  FillStyleComboBox.OnDrawItem := @StyleComboBoxDrawItem;
  l := TLabel.Create(APanel);
  l.name := 'FillStyleLabel';
  l.Caption := 'Fill Style';
  l.Parent := APanel;
  l.Align := alBottom;
end;

procedure TTool.ParametersCreate;
begin
end;

procedure TPolylineTool.ParametersCreate;
begin
  setlength (Parameters, 1);
  Parameters[0] := TLineWidthParameter;
end;

procedure TRectangleTool.ParametersCreate;
begin
  setlength (Parameters, 3);
  Parameters[0] := TLineWidthParameter;
  Parameters[1] := TLineStyleParameter;
  Parameters[2] := TFillStyleParameter;
end;

procedure TEllipseTool.ParametersCreate;
begin
  setlength (Parameters, 3);
  Parameters[0] := TLineWidthParameter;
  Parameters[1] := TLineStyleParameter;
  Parameters[2] := TFillStyleParameter;
end;

procedure TLineTool.ParametersCreate;
begin
  setlength (Parameters, 2);
  Parameters[0] := TLineWidthParameter;
  Parameters[1] := TLineStyleParameter;
end;

procedure TPolygonTool.ParametersCreate;
begin
  setlength (Parameters, 5);
  Parameters[0] := TLineWidthParameter;
  Parameters[1] := TLineStyleParameter;
  Parameters[2] := TFillStyleParameter;
  Parameters[3] := TCornersParameter;
  Parameters[4] := TAngleParameter;
end;

procedure TRoundRectTool.ParametersCreate;
begin
  setlength (Parameters, 5);
  Parameters[0] := TLineWidthParameter;
  Parameters[1] := TLineStyleParameter;
  Parameters[2] := TFillStyleParameter;
  Parameters[3] := TRoundingXParameter;
  Parameters[4] := TRoundingYParameter;
end;

procedure TTool.Initialize(APanel: TPanel);
var
  i: integer;
begin
  ParametersCreate;
  for i := low(Parameters) to high(Parameters) do
  begin
    //Parameter :=
    Parameters[i].Create.CreateEditor(APanel);
  end;
end;

initialization
RegisterTool (TPolylineTool.Create, TPolyline, 'Pencil.bmp');
RegisterTool (TRectangleTool.Create, TRectangle, 'Rectangle.bmp');
RegisterTool (TEllipseTool.Create, TEllipse, 'Ellipse.bmp');
RegisterTool (TLineTool.Create, TLine, 'Line.bmp');
RegisterTool (TMagnifierTool.Create, TMagnifierFrame, 'Magnifier.bmp');
RegisterTool (THandTool.Create, THandFigure, 'Hand.bmp');
RegisterTool (TPolygonTool.Create, TPolygon, 'Polygon.bmp');
RegisterTool (TRoundRectTool.Create, TRoundRect, 'RoundRect.bmp');
RegisterTool (TRectSelectionTool.Create, TMagnifierFrame, 'Selection.bmp');
AngleMode := false;
RectR := Point(50,50);
end.

