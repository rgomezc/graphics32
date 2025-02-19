unit TestPolygonIssues;

interface

uses
  Classes, Types,
  TestFramework,
  GR32_Polygons;

type
  TTestVectorUtilsIssues = class(TTestCase)
  published
    procedure RoundRect_MissingPoint;
    procedure RoundRect_NoArc;
  end;

  TTestPolygonRasterizerIssues = class(TTestCase)
  private
    FPolygonRendererClass: TPolygonRenderer32Class;
    FPolygonRenderer: TPolygonRenderer32;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

    property PolygonRenderer: TPolygonRenderer32 read FPolygonRenderer;
  public
    property PolygonRendererClass: TPolygonRenderer32Class read FPolygonRendererClass write FPolygonRendererClass;

  published
    procedure Issue272_PolygonFS;
    procedure VPR2_VerticalSegments;
  end;

implementation

uses
  SysUtils,
  Math,

  GR32_VPR2,
  GR32_Polygons.GDI,
  GR32_Polygons.GDIPlus,
  GR32_Polygons.Direct2D,
  GR32_Polygons.AggLite,

  GR32,
  GR32_Containers,
  GR32_Bindings,
  GR32_VectorUtils;

{$RANGECHECKS OFF}

procedure TTestVectorUtilsIssues.RoundRect_MissingPoint;
var
  i: integer;
  Found: boolean;
const
  Epsilon = 0.001;
begin
  var Rect := FloatRect(10, 10, 30, 20);
  var RoundedRectangle := RoundRect(Rect, 2.0);

  // The straight rectangle contains 4 vertices.
  // The rounded rectangle should at least contain 8 vertices (choppy arc; only start
  // and end point in the arc) and preferably 12 vertices (3 or more vertice in the
  // arc).
  Check(Length(RoundedRectangle) >= 12);


  //
  // Verify that RoundRect produces a polygon aligned with the X and Y axis
  //

  // Look for horizontal segment going from (x1,10) to (x2,10)
  Found := False;
  for i := 0 to High(RoundedRectangle) do
    if (RoundedRectangle[i].Y = Rect.Top) then
    begin
      Found := SameValue(Rect.Top, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].Y, Epsilon);
      if (Found) then
      begin
        CheckNotEquals(RoundedRectangle[i].X, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].X, Epsilon);
        break;
      end;
    end;
  Check(Found);

  // Look for horizontal segment going from (x1,20) to (x2,20)
  Found := False;
  for i := 0 to High(RoundedRectangle) do
    if (RoundedRectangle[i].Y = Rect.Bottom) then
    begin
      Found := SameValue(Rect.Bottom, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].Y, Epsilon);
      if (Found) then
      begin
        CheckNotEquals(RoundedRectangle[i].X, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].X, Epsilon);
        break;
      end;
    end;
  Check(Found);

  // Look for vertical segment going from (10,y1) to (10,y2)
  Found := False;
  for i := 0 to High(RoundedRectangle) do
    if (RoundedRectangle[i].X = Rect.Left) then
    begin
      Found := SameValue(Rect.Left, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].X, Epsilon);
      if (Found) then
      begin
        CheckNotEquals(RoundedRectangle[i].Y, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].Y, Epsilon);
        break;
      end;
    end;
  Check(Found);

  // Look for vertical segment going from (30,y1) to (30,y2)
  Found := False;
  for i := 0 to High(RoundedRectangle) do
    if (RoundedRectangle[i].X = Rect.Right) then
    begin
      Found := SameValue(Rect.Right, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].X, 0.001);
      if (Found) then
      begin
        CheckNotEquals(RoundedRectangle[i].Y, RoundedRectangle[(i+1) mod Length(RoundedRectangle)].Y, Epsilon);
        break;
      end;
    end;
  Check(Found);

end;

procedure TTestVectorUtilsIssues.RoundRect_NoArc;
begin
  var Rect := FloatRect(10, 10, 30, 20);
  var RoundedRectangle := RoundRect(Rect, 0.0);

  // Round with zero arc radius should just produce a straight rectangle with 4 vertices.
  Check(Length(RoundedRectangle) = 4);

  var Bounds := PolygonBounds(RoundedRectangle);
  Check(Rect = Bounds);
end;

procedure TTestPolygonRasterizerIssues.SetUp;
begin
  inherited;
  FPolygonRenderer := PolygonRendererClass.Create;
end;

procedure TTestPolygonRasterizerIssues.TearDown;
begin
  inherited;
  FPolygonRenderer.Free;
end;

procedure TTestPolygonRasterizerIssues.Issue272_PolygonFS;
const
  PolyX = 4;
  PolyY = 3;
  Expected: Double = (PolyX * PolyY) / 2;

  procedure DoTest(const p: TArrayOfFloatPoint; MaxDelta: Double);
  var
    Bitmap: TBitmap32;
    i: integer;
    Actual: Double;
  begin
    Bitmap := TBitmap32.Create;
    try
      Bitmap.SetSize(5, 5);
      Bitmap.Clear(0);
      PolygonRenderer.Bitmap := Bitmap;
      PolygonRenderer.Color := clBlack32;
      PolygonRenderer.PolygonFS(p);

      Actual := 0;

      // Sum actual polygon coverage
      for i := 0 to (Bitmap.Width * Bitmap.Height)-1 do
        Actual := Actual + TColor32Entry(Bitmap.Bits[i]).A / 255;

    finally
      Bitmap.Free;
    end;

    CheckEquals(Expected, Actual, MaxDelta);
  end;

var
  p: TArrayOfFloatPoint;
  i: integer;
begin

  SetLength(p, 3);

  p[0] := FloatPoint(0, 0);
  p[1] := FloatPoint(PolyX, 0);
  p[2] := FloatPoint(0, PolyY);

  DoTest(p, 0.01);

  // Now translate the polygon 0,5 pixels down and to the right and repeat the test
  for i := 0 to High(p) do
  begin
    p[i].X := p[i].X + 0.5;
    p[i].Y := p[i].Y + 0.5;
  end;

  DoTest(p, 0.1);
end;


procedure TTestPolygonRasterizerIssues.VPR2_VerticalSegments;
const
  // CalculateCircleSteps calculates the steps to 11.
  // Made constant here to ensure we test the right thing.
  Steps = 11;
  Center: TFloatPoint = (X: 5; Y: 3);
  Radius: TFloatPoint = (X: 5; Y: 3);
var
  Bitmap: TBitmap32;
  Ellipse: TArrayOfFloatPoint;
  x, y: integer;
  Color: TColor32Entry;
  IsDecreasing: boolean;
  LastAlpha: integer;
begin
  Bitmap := TBitmap32.Create;
  try
    Bitmap.SetSize(16, 16);
    Bitmap.Clear(0);

    PolygonRenderer.Color := clRed32;
    PolygonRenderer.Bitmap := Bitmap;


    Ellipse := GR32_VectorUtils.Ellipse(Center, Radius, Steps);

    PolygonRenderer.PolyPolygonFS([Ellipse]);


    // Alpha of vertical cross section should increase and then decrease
    for x := 0 to Bitmap.Width-1 do
    begin
      IsDecreasing := False;
      LastAlpha := 0;
      for y := 0 to Bitmap.Height-1 do
      begin
        Color := TColor32Entry(Bitmap.Pixel[x, y]);

        if (Color.A < LastAlpha) then
          IsDecreasing := True
        else
        if (Color.A > LastAlpha) then
          Check(not IsDecreasing, 'Alpha hole');

        LastAlpha := Color.A;
      end;
    end;


    // Verify that drawn polygon is max 7x11
    // 6x10 for those that has the pixel origin at the upper left corner, and
    // 7x11 for those that has it in the center of the pixel (GDI+).
    // 6x11 for the ClearType rasterizers.
    for y := 0 to Bitmap.Height-1 do
      for x := 0 to Bitmap.Width-1 do
      begin
        Color := TColor32Entry(Bitmap.Pixel[x, y]);

        if (x >= 11) or (y >= 7) then
          Check(Color.A = 0, 'Polygon too big');
      end;

  finally
    Bitmap.Free;
  end;

end;

type
  TPolygonRendererTestSuite = class(TTestSuite)
  private
    FPolygonRendererClass: TPolygonRenderer32Class;
  public
    procedure AddTest(ATest: ITest); override;
    property PolygonRendererClass: TPolygonRenderer32Class read FPolygonRendererClass write FPolygonRendererClass;
  end;

procedure TPolygonRendererTestSuite.AddTest(ATest: ITest);
begin
  inherited;
  if (ATest is TTestPolygonRasterizerIssues) then
    TTestPolygonRasterizerIssues(ATest).PolygonRendererClass := PolygonRendererClass;
end;

procedure InitializeTestSuites;
var
  PolygonRendererTestSuite: TPolygonRendererTestSuite;
  PolygonRendererClass: TPolygonRenderer32Class;
begin
  RegisterTest(TTestVectorUtilsIssues.Suite);

  for PolygonRendererClass in PolygonRendererList do
  begin
    PolygonRendererTestSuite := TPolygonRendererTestSuite.Create(PolygonRendererClass.ClassName);
    PolygonRendererTestSuite.PolygonRendererClass := PolygonRendererClass;

    PolygonRendererTestSuite.AddTests(TTestPolygonRasterizerIssues);

    RegisterTest(PolygonRendererTestSuite);
  end;
end;

initialization
  InitializeTestSuites;
end.


