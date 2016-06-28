unit StrGrid_Unit;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils,Grids;

type

  { TStringGrid }

  TStringGrid= class(Grids.TStringGrid)
  private
    FColNameCount: Integer;

  protected
    ColList:TStringList;
  public
    function _AddCol(ColName,ColTitle:string;Width:Integer=-1;DataAlignment:TAlignment=taLeftJustify):TGridColumn;
    function _ColByName(Name:string):Integer;
    function _GetValue(Row:integer;Name: String):String;
    function _GetValue_Pointer(Row:integer;Name: String):Pointer;
    procedure _SetValue(Row:integer;Name: String; Val: string);overload;
    procedure _SetValue(Row:integer;Name: String; Val: int64);overload;
    procedure _SetValue(Row: integer; Name: String; Val: Pointer);overload;
    function _Locate(Name:string;Value:string;GotoRow:Boolean=True):integer;overload;
    function _Locate(Name:string;Value:int64;GotoRow:Boolean=True):integer;overload;
    function _Locate(Name:string;Value:Pointer;GotoRow:Boolean=True):integer;overload;
    function _DelRow(Name:string;Value:Pointer):Boolean;overload;
    function _DelRow(Name:string;Value:int64):Boolean;overload;
    function _DelRow(Name:string;Value:String):Boolean;overload;
    function _ColName(aCol:integer):string;
    procedure _ClearCol;
    procedure _Clear;
//    property _ColNameCount:Integer read FColNameCount;
    procedure _SetDataGrid;

    constructor Create(Owner:TComponent);override;
    destructor Destroy; override;
  published
  end;

implementation

{ TStringGrid }

function TStringGrid._AddCol(ColName, ColTitle: string; Width: Integer; DataAlignment: TAlignment): TGridColumn;
begin
  if self.RowCount=0 then
  self.RowCount:=1;
  if self.FixedRows=0 then
  self.FixedRows:=1;

  Result:=self.Columns.Add;
  Result.Alignment:=DataAlignment;
  Result.Title.Caption:=ColTitle;
  if width>0 then
  Result.Width:=width
  else
  Result.Width:=self.DefaultColWidth;

  //  ColList.Add(ColName+'='+ColTitle);
  ColList.Add(ColName);

end;

function TStringGrid._ColByName(Name: string): Integer;
begin
//  Result:=self.ColList.IndexOfName(Name);
  Result:=self.ColList.IndexOf(Name);
end;

function TStringGrid._GetValue(Row: integer; Name: String): String;
var
  i:integer;
begin
  Result:='';
  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  Result:=self.Cells[i,Row];
end;

function TStringGrid._GetValue_Pointer(Row: integer; Name: String): Pointer;
var
  s:String;
  c:int64;
  i:integer;
begin
  Result:=nil;

  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  s:=trim(self.Cells[i,Row]);
  if s='' then
  exit;
  if not sysutils.TryStrToInt64(s,c) then
  exit;

  Result:=Pointer(c);

end;

procedure TStringGrid._SetValue(Row:integer;Name: String; Val: string);
var
  i:integer;
begin
  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  self.Cells[i,Row]:=Val;
end;

procedure TStringGrid._SetValue(Row: integer; Name: String; Val: Pointer);
begin
  self._SetValue(Row,Name,'$'+sysutils.IntToHex(Int64(val),8));
end;

function TStringGrid._Locate(Name: string; Value: string; GotoRow: Boolean): integer;
var
  i,j:integer;
begin
  Result:=-1;
  j:=self._ColByName(Name);
  if j=-1 then
  exit;

  for i := 1 to self.RowCount-1 do
  begin
    if self.Cells[j,i]=Value then
    begin
      Result:=i;
      if GotoRow then
      self.Row:=i;
      exit;
    end;
  end;

end;

function TStringGrid._Locate(Name: string; Value: int64; GotoRow: Boolean): integer;
begin
  Result:=_Locate(Name,inttostr(Value),GotoRow);
end;

function TStringGrid._Locate(Name: string; Value: Pointer; GotoRow: Boolean): integer;
begin
  Result:=_Locate(Name,'$'+IntToHex(int64(Value),8),GotoRow);
end;

function TStringGrid._DelRow(Name: string; Value: Pointer): Boolean;
var
  R:integer;
begin
  Result:=false;
  R:=self._Locate(Name,Value,False);
  if R<>-1 then
  begin
    self.DeleteRow(R);
    Result:=True;
  end;
end;

function TStringGrid._DelRow(Name: string; Value: int64): Boolean;
var
  R:integer;
begin
  Result:=false;
  R:=self._Locate(Name,Value,False);
  if R<>-1 then
  begin
    self.DeleteRow(R);
    Result:=True;
  end;
end;

function TStringGrid._DelRow(Name: string; Value: String): Boolean;
var
  R:integer;
begin
  Result:=false;
  r:=self._Locate(Name,Value,False);
  if R<>-1 then
  begin
    self.DeleteRow(R);
    Result:=True;
  end;
end;

function TStringGrid._ColName(aCol: integer): string;
begin
  Result:='';
  if (self.ColList.Count>aCol) and (aCol>=0) then
  begin
    Result:=self.ColList.Names[aCol];
  end;
end;

procedure TStringGrid._SetValue(Row: integer; Name: String; Val: int64);
begin
  self._SetValue(Row,Name,inttostr(Val));
end;

procedure TStringGrid._ClearCol;
begin
  self.ColList.Clear;
  self.Columns.Clear;
end;

procedure TStringGrid._Clear;
begin
  self.RowCount:=1;
end;

procedure TStringGrid._SetDataGrid;
begin
  self.DefaultRowHeight:=20;
  self.FixedCols:=0;
  self.Options:=self.Options+[goRowSelect,goColSizing,goColSpanning,goDblClickAutoSize];
  self.TitleStyle:=tsNative;
  self.RowCount:=1;

  self.Clear;
  self._ClearCol;

end;

constructor TStringGrid.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  ColList:=TStringList.Create;
end;

destructor TStringGrid.Destroy;
begin
  inherited Destroy;
end;

end.

