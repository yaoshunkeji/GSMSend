unit override_Unit;

{$mode delphi}{$H+}

interface

{.$define DateTimePicker}
{.$define DB}

uses
  Classes, SysUtils,ExtCtrls,math
  {$ifdef DateTimePicker}
  ,DateTimePicker
  {$endif}
  ,LazUTF8,Grids
  {$ifdef DB}
  ,DBGrids,db
  {$endif}
  ,dialogs,Graphics
  ,StdCtrls
  ;

type

  { TLabeledEdit }
  TCompareText=function(const s1,s2:string):integer;

  TLabeledEdit = class(ExtCtrls.TLabeledEdit)
  private
    FOnlyNum: Boolean;
    F_Max: int64;
    F_Min: int64;

    function Get_Int64: int64;
    procedure Set_Int64(AValue: int64);
    procedure Set_Max(AValue: int64);
    procedure Set_Min(AValue: int64);

  protected
    procedure KeyPress(var Key: char); override;
  public
    property _OnlyNum:Boolean read FOnlyNum write FOnlyNum;
    property _Int64:int64 read Get_Int64 write Set_Int64;
    property _Max:int64 read F_Max write Set_Max;
    property _Min:int64 read F_Min write Set_Min;
    procedure _FixText;
    constructor Create(TheOwner:TComponent);override;
    destructor Destroy; override;
  end;

  {$IFDEF TDateTimePicker}
  { TDateTimePicker }

  TDateTimePicker=class(DateTimePicker.TDateTimePicker)
  public
    constructor Create(TheOwner:TComponent);override;
    destructor Destroy; override;
  end;
  {$ENDIF}


  { TStringGrid }

  TStringGrid= class(Grids.TStringGrid)
  private
    FColNameCount: Integer;

  protected
    ColList:TStringList;
  public
    function _AddCol(ColName:String;ColTitle:string='';Width:Integer=-1;DataAlignment:TAlignment=taLeftJustify):TGridColumn;
//    function _AddCol(ColName:String;Width:Integer=-1):TGridColumn;overload;
    procedure _AddRow;
    function _ColByName(Name:string):Integer;
    function _GetValue(Name: String;aRow:integer=-1):String;
    function _GetValue_Pointer(Name: String;aRow:integer=-1):Pointer;

    function _GetValue_Int64(Name: String;Default_:integer=0;aRow:integer=-1):Int64;

    procedure _SetValue(Name: String; Val: string;aRow:integer=-1);overload;
    procedure _SetValue(Name: String; Val: int64;aRow:integer=-1);overload;
    procedure _SetValue(Name: String; Val: Pointer;aRow:integer=-1);overload;

    function _Locate(Name:string;Value:string;GotoRow:Boolean=True):integer;overload;
    function _Locate(Name:string;Value:int64;GotoRow:Boolean=True):integer;overload;
    function _Locate(Name:string;Value:Pointer;GotoRow:Boolean=True):integer;overload;
    function _Locate(Name: string; Value: string;Name2:string;Value2:string; GotoRow: Boolean): integer;overload;
    function _DelRow(Name:string;Value:Pointer):Boolean;overload;
    function _DelRow(Name:string;Value:int64):Boolean;overload;
    function _DelRow(Name:string;Value:String):Boolean;overload;
    function _CountRow(Name:string;Value:String):integer;overload;
    function _ColName(aCol:integer):string;
    function _GetSelectCount(Name:string):integer;
    procedure _SortCol_Int(Name: string;StartRow:Integer=1; EndRow:integer=-1;blDesc: Boolean=False;aCompareText:TCompareText=nil);
    procedure _ClearCol;
    procedure _Clear;
//    property _ColNameCount:Integer read FColNameCount;
    procedure _SetDataGrid;

    constructor Create(Owner:TComponent);override;
    destructor Destroy; override;
  end;
  {$IFDEF DB}
  { TDBGrid }

  TDBGrid = class(DBGrids.TDbGrid)
  private

  protected

  public
    procedure _SaveToFile(Title:string='');
    procedure _SaveToHtml(fn: string; Title: string='');
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;
  {$ENDIF}

  { TEdit }

  TEdit= class(StdCtrls.TEdit)
  private
    aInt_Min:int64;
    aInt_Max:int64;
    aInt_Fmt:string;
    aInt_Step:int64;
    aInt_Default:int64;

    aFlt_Min:Double;
    aFlt_Max:Double;
    aFlt_Fmt:string;
    aFlt_Step:Double;
    aFlt_Default:Double;

    aMode:integer;

    procedure Edit1KeyDown_SpinInt(Sender: TObject; var Key: Word; Shift: TShiftState);

  public
    procedure DoSpin_Int(default:int64;aMin:int64=-MaxInt;aMax:int64=MaxInt;DefaultStep:integer=1);
    procedure DoSpin_Flt(default:Double;fmt:string='0.0';aMin:Double=-MaxInt;aMax:Double=MaxInt;DefaultStep:Double=0.1);
    function Get_Int64(default: int64=0): integer;
    function Get_Flt(default: Double=0): Double;
    function Add_Int(step:Int64=1;loop:boolean=true):int64;
    function Add_Flt(step:Double=0.1;loop:boolean=true):Double;

    function Calc_Add_Int(CurValue:Int64;step:integer=1;loop:boolean=true):Int64;
    function Calc_Add_Flt(CurValue:Double;step:Double=0.1;loop:boolean=true):Double;

    function Default_Add(Oldvalue:String;isDec:boolean=True;setToText:Boolean=true): string;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation


{ TDBGrid }


function GetRValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb);
end;

function GetGValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 8);
end;

function GetBValue(rgb: DWORD): Byte;
begin
  Result := Byte(rgb shr 16);
end;

function ColorToHtml(mColor: TColor): string;
begin
  mColor := ColorToRGB(mColor);
  Result := Format('#%.2x%.2x%.2x',
    [GetRValue(mColor), GetGValue(mColor), GetBValue(mColor)]);
end; { ColorToHtml }


function StrToHtml(mStr: string; mFont: TFont = nil): string;
var
  vLeft, vRight: string;
begin
  Result := mStr;
  Result := StringReplace(Result, '&', '&AMP;', [rfReplaceAll]);
  Result := StringReplace(Result, ',','&LT;', [rfReplaceAll]);
  Result := StringReplace(Result, '', '&GT;', [rfReplaceAll]);
  if not Assigned(mFont) then Exit;
  vLeft := Format('',
    [mFont.Name, ColorToHtml(mFont.Color)]);
  vRight := '';
  if fsBold in mFont.Style then begin
    vLeft := vLeft + '';
    vRight := '' + vRight;
  end;
  if fsItalic in mFont.Style then begin
    vLeft := vLeft + '';
    vRight := '' + vRight;
  end;
  if fsUnderline in mFont.Style then begin
    vLeft := vLeft + '';
    vRight := '' + vRight;
  end;
  if fsStrikeOut in mFont.Style then begin
    vLeft := vLeft + '';
    vRight := '' + vRight;
  end;
  Result := vLeft + Result + vRight;
end; { StrToHtml }

{$ifdef DB}

function DBGridToHtmlTable(DBGrid: TDBGrid; Strings: TStrings; Caption: String = ''): Boolean;
const
  cAlignText: array[TAlignment] of string = ('LEFT', 'RIGHT', 'CENTER');
var
  vColFormat: string;
  vColText: string;
  vAllWidth: Integer;
  vWidths: array of Integer;
  BookMark:TBookMark;
  I, J: Integer;
begin
  Result := False;
  if not Assigned(Strings) then Exit;
  if not Assigned(DBGrid) then Exit;
  if not Assigned(DBGrid.DataSource) then Exit;
  if not Assigned(DBGrid.DataSource.DataSet) then Exit;
  if not DBGrid.DataSource.DataSet.Active then Exit;

  BookMark:=DBGrid.DataSource.DataSet.Bookmark;
  DBGrid.DataSource.DataSet.DisableControls;
  try
    J := 0;
    vAllWidth := 0;
    for I := 0 to DBGrid.Columns.Count - 1 do
      if DBGrid.Columns[I].Visible then begin
        Inc(J);
        SetLength(vWidths, J);
        vWidths[J - 1] := DBGrid.Columns[I].Width;
        Inc(vAllWidth, DBGrid.Columns[I].Width);
      end;
    if J=0 then Exit;
    Strings.Clear;
    Strings.Add(Format('',[ColorToHtml(DBGrid.Color)]));
    if Caption<>'' then
      Strings.Add(Format('%s', [StrToHtml(Caption)]));
    vColFormat := '';
    vColText := '';
    vColFormat := vColFormat + ''#13#10;
    vColText := vColText + ''#13#10;
    J := 0;
    for I := 0 to DBGrid.Columns.Count - 1 do
      if DBGrid.Columns[I].Visible then
      begin
        vColFormat := vColFormat + Format('  DisplayText%d'#13#10,[ColorToHtml(DBGrid.Columns[I].Color),cAlignText[DBGrid.Columns[I].Alignment],Round(vWidths[J] / vAllWidth * 100), J]);
        vColText := vColText + Format('  %s'#13#10,[ColorToHtml(DBGrid.Columns[I].Title.Color), cAlignText[DBGrid.Columns[I].Alignment],Round(vWidths[J] / vAllWidth * 100),
        StrToHtml(DBGrid.Columns[I].Title.Caption,DBGrid.Columns[I].Title.Font)]);
        Inc(J);
      end;
    vColFormat := vColFormat + ''#13#10;
    vColText := vColText + ''#13#10;
    Strings.Text := Strings.Text + vColText;
    DBGrid.DataSource.DataSet.First;
    while not DBGrid.DataSource.DataSet.Eof do
    begin
      J := 0;
      vColText := vColFormat;
      for I := 0 to DBGrid.Columns.Count - 1 do
        if DBGrid.Columns[I].Visible then begin
          vColText := StringReplace(vColText, Format('DisplayText%d', [J]), Format('%s', [StrToHtml(DBGrid.Columns[I].Field.DisplayText,DBGrid.Columns[I].Font)]),
            [rfReplaceAll]);
          Inc(J);
        end;
      Strings.Text := Strings.Text + vColText;
      DBGrid.DataSource.DataSet.Next;
    end;
    Strings.Add('');
  finally
    DBGrid.DataSource.DataSet.Bookmark := BookMark;
    DBGrid.DataSource.DataSet.EnableControls;
    vWidths := nil;
  end;
  Result := True;
end; { DBGridToHtmlTable }


procedure TDBGrid._SaveToFile(Title:string='');
var
  dlg:TSaveDialog;
begin
dlg:=TSaveDialog.Create(self);
dlg.DefaultExt:='.html';
dlg.Filter:='HTML File(*.html)|(*.html)|Word File(*.rtf)|(*.rtf)|AllFile(*.*)|(*.*)';
dlg.FilterIndex:=0;
dlg.Options:=dlg.Options+[ofOverwritePrompt];
if dlg.Execute then
begin
  self._SaveToHtml(dlg.FileName,title);
end;
sysutils.FreeAndNil(dlg);


end;

procedure TDBGrid._SaveToHtml(fn: string;Title:string='');
var
  strlst:TStringList;
begin
  strlst:=TStringList.Create;
  DBGridToHtmlTable(self,strlst,Title);
end;

constructor TDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;


destructor TDBGrid.Destroy;
begin
  inherited Destroy;
end;

{$ENDIF}

///////End Source

{$IFDEF TDateTimePicker}

{ TDateTimePicker }

constructor TDateTimePicker.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  self.DateSeparator:='-';
end;

destructor TDateTimePicker.Destroy;
begin
  inherited Destroy;
end;
{$ENDIF}

{ TLabeledEdit }

procedure TLabeledEdit.Set_Int64(AValue: int64);
begin
  if self.Text=inttostr(AValue) then
  Exit;

  self.Text:=inttostr(AValue);
  self._FixText;
end;

procedure TLabeledEdit._FixText;
var
  c:int64;
begin
if not self.FOnlyNum then
exit;

  c:=self.Get_Int64;

  c:=Min(c,self.F_Max);
  c:=Max(c,self.F_Min);
  if self.Get_Int64<>c then
  self.Text:=inttostr(c);

end;

procedure TLabeledEdit.Set_Max(AValue: int64);
begin
  self.F_Max:=AValue;
  self._FixText;
end;

procedure TLabeledEdit.Set_Min(AValue: int64);
begin
  self.F_Min:=AValue;
  self._FixText;
end;

function TLabeledEdit.Get_Int64: int64;
begin
if not sysutils.TryStrToInt64(trim(self.Text),Result) then
Result:=0;

Result:=Min(Result,self.F_Max);
Result:=Max(Result,self.F_Min);

end;

procedure TLabeledEdit.KeyPress(var Key: char);
begin
  if self.FOnlyNum then
  begin
    if not (key in ['0'..'9',#13,#10,#$b,#08,#127]) then
    begin
      key:=#0;
      exit;
    end;
  end;

  inherited KeyPress(Key);

end;

constructor TLabeledEdit.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  self.F_Max:=High(int64);
  self.F_Min:=Low(int64);
end;

destructor TLabeledEdit.Destroy;
begin
  inherited Destroy;
end;

{ TStringGrid }

function TStringGrid._AddCol(ColName: String; ColTitle: string; Width: Integer; DataAlignment: TAlignment): TGridColumn;
begin
  if self.RowCount=0 then
  self.RowCount:=1;
  if self.FixedRows=0 then
  self.FixedRows:=1;

  if ColTitle='' then
  ColTitle:=ColName;

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

procedure TStringGrid._AddRow;
begin
  self.RowCount:=self.RowCount+1;
end;

function TStringGrid._ColByName(Name: string): Integer;
begin
//  Result:=self.ColList.IndexOfName(Name);
  Result:=self.ColList.IndexOf(Name);
end;

function TStringGrid._GetValue(Name: String;aRow: integer): String;
var
  i:integer;
begin
  Result:='';
  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  if Arow=-1 then
  ARow:=self.Row;
  if ARow=-1 then
  exit;

  Result:=self.Cells[i,aRow];
end;

function TStringGrid._GetValue_Pointer(Name: String;aRow: integer): Pointer;
var
  s:String;
  c:int64;
  i:integer;
begin
  Result:=nil;

  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  if Arow=-1 then
  ARow:=self.Row;
  if ARow=-1 then
  exit;

  s:=trim(self.Cells[i,aRow]);
  if s='' then
  exit;
  if not sysutils.TryStrToInt64(s,c) then
  exit;

  Result:=Pointer(c);

end;

function TStringGrid._GetValue_Int64(Name: String; Default_: integer; aRow: integer): Int64;
var
  s:string;
begin
  s:=self._GetValue(Name,aRow);
  if not sysutils.TryStrToInt64(s,Result) then
  Result:=Default_;
end;



procedure TStringGrid._SetValue(Name: String; Val: string;aRow: integer);
var
  i:integer;
begin
  i:=self._ColByName(Name);
  if i=-1 then
  exit;

  if Arow=-1 then
  ARow:=self.Row;
  if ARow=-1 then
  exit;

  self.Cells[i,aRow]:=Val;
end;

procedure TStringGrid._SetValue(Name: String; Val: Pointer;aRow: integer);
begin
  self._SetValue(Name,'$'+sysutils.IntToHex(Int64(val),8),aRow);
end;

function TStringGrid._Locate(Name: string; Value: string;Name2:string;Value2:string; GotoRow: Boolean): integer;
var
  i,j,k:integer;
begin
  Result:=-1;
  j:=self._ColByName(Name);
  k:=self._ColByName(Name2);
  if j=-1 then
  exit;
  if k=-1 then
  exit;

  for i := 1 to self.RowCount-1 do
  begin
    if (self.Cells[j,i]=Value) and (self.Cells[k,i]=Value2) then
    begin
      Result:=i;
      if GotoRow then
      self.Row:=i;
      exit;
    end;
  end;
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

function TStringGrid._CountRow(Name: string; Value: String): integer;
var
  i,j:integer;
begin
  Result:=0;
  j:=self._ColByName(Name);
  if j=-1 then
  exit;

  for i := 1 to self.RowCount-1 do
  begin
    if self.Cells[j,i]=Value then
    begin
      inc(Result);
    end;
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

function TStringGrid._GetSelectCount(Name: string): integer;
var
  i:integer;
  idx:integer;
  s:String;
begin
Result:=-1;

idx:=self._ColByName(Name);
if idx=-1 then
exit;

if idx>=self.Columns.Count then
exit;

if self.Columns.Items[idx].ButtonStyle<>cbsCheckboxColumn then
exit;

Result:=0;

for i := 1  to  self.RowCount-1 do
begin
  s:=self.Cells[idx,i];
  if s='1' then
  inc(Result);
end;


end;


function CompareText_Int(const s1,s2:string):integer;
var
  a,b:int64;
begin
  if not sysutils.TryStrToInt64(s1,a) then
  begin
    Result:=1;
    exit;
  end;
  if not sysutils.TryStrToInt64(s2,b) then
  begin
    Result:=1;
    exit;
  end;
  Result:=a-b;
end;

procedure TStringGrid._SortCol_Int(Name: string;StartRow:Integer=1; EndRow:integer=-1;blDesc: Boolean=False;aCompareText:TCompareText=nil);
var
  FCompareCells:TCompareText;
  col:integer;
  var
    s1,s2:string;

  function DoCompareCells(Acol, ARow, Bcol, BRow: Integer): Integer;
  begin
    s1:=Cells[ACol,ARow];
    s2:=Cells[BCol,BRow];
    Result:=FCompareCells(s1, s2);
    if blDesc then
      result:=-result;
  end;

  procedure QuickSort(L,R: Integer);
  var
    I,J: Integer;
    P{,Q}: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      P:=(L+R) div 2;
      repeat
          while DoCompareCells(Col, P, Col, I)>0 do
            I:=I+1;
          while DoCompareCells(Col, P, Col, J)<0 do
          J:=J-1;
        if (I<=J) then
        begin
          if (I<>J) and (s1<>s2) then
          begin
            if not StrictSort or (DoCompareCells(Col, I, Col, J)<>0) then
              DoOPExchangeColRow(False, I,J);
          end;

          if P=I then
            P:=J
          else
          if P=J then
            P:=I;

          I:=I+1;
          J:=J-1;
        end;
      until I>J;

      if L<J then
        QuickSort(L,J);

      L:=I;
    until I>=R;
  end;
begin
  if FixedRows>=RowCount then
  exit;

  if StartRow=-1 then
  StartRow:=1;
  if EndRow=-1 then
  EndRow:=self.RowCount-1;

  EndRow:=Min(self.RowCount-1,EndRow);
  EndRow:=Max(1,EndRow);


  Col:=self._ColByName(Name);
  if col=-1 then
  exit;

  FCompareCells:=aCompareText;
  if not system.Assigned(FCompareCells) then
  begin
    FCompareCells:=CompareText_Int; //UTF8CompareText;
  end;

  BeginUpdate;
  try
  QuickSort(StartRow, EndRow);

  finally
    EndUpdate;
  end;



end;

procedure TStringGrid._SetValue(Name: String; Val: int64;aRow: integer);
begin
  self._SetValue(Name,inttostr(Val),aRow);
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
  self.DefaultRowHeight:=20;
  self.HeaderPushZones:=self.HeaderPushZones+[gzFixedRows];
  self.HeaderHotZones:=self.HeaderHotZones+[gzFixedRows];

end;

destructor TStringGrid.Destroy;
begin
  inherited Destroy;
end;

{ TEdit }

procedure TEdit.Edit1KeyDown_SpinInt(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (key in [ord('0') .. ord('9')]) then
  begin
    key:=0;
  end;
end;

procedure TEdit.DoSpin_Int(default: int64; aMin: int64; aMax: int64; DefaultStep: integer);
begin
   self.OnKeyDown:=Edit1KeyDown_SpinInt;
   self.aInt_Max:=AMax;
   self.aInt_Min:=AMin;
   self.aInt_Step:=DefaultStep;
   self.aMode:=1;

   self.Text:=inttostr(default);
end;

procedure TEdit.DoSpin_Flt(default: Double; fmt: string; aMin: Double; aMax: Double; DefaultStep: Double);
begin
   self.OnKeyDown:=Edit1KeyDown_SpinInt;
   self.aFlt_Fmt:=Fmt;
   self.aFlt_Max:=AMax;
   self.aFlt_Min:=AMin;
   self.aFlt_Step:=DefaultStep;
   self.aMode:=2;

   self.Text:=sysutils.FormatFloat(fmt,Default);

end;

function TEdit.Get_Int64(default: int64): integer;
var
  s:string;
begin
  s:=trim(self.Text);
  if not sysutils.TryStrToInt(s,Result) then
  Result:=default;

  Result:=Max(Result,aInt_Min);
  Result:=Min(Result,aInt_Max);

end;

function TEdit.Get_Flt(default: Double): Double;
var
  s:string;
begin
  s:=trim(self.Text);
  if not sysutils.TryStrToFloat(s,Result) then
  Result:=default;

  Result:=Max(Result,aFlt_Min);
  Result:=Min(Result,aFlt_Max);

end;

function TEdit.Add_Int(step: Int64; loop: boolean):int64;
var
  t1,t2:int64;
begin
  if Step=0 then
  begin
    exit;
  end;

  t1:=self.Calc_Add_Int(self.Get_Int64(self.aInt_Default),step,loop);
  self.Text:=inttostr(t1);
  Result:=T1;
end;

function TEdit.Add_Flt(step: Double; loop: boolean):Double;
var
  t1,t2:Double;
begin
  if Step=0 then
  begin
    exit;
  end;
  t1:=self.Calc_Add_Flt(self.Get_Flt(self.aFlt_Default),step,loop);
  self.Text:=sysutils.FormatFloat(self.aFlt_Fmt,t1);
  self.Caption:=self.Text;
  Result:=T1;
end;

function TEdit.Calc_Add_Int(CurValue: Int64; step: integer; loop: boolean): Int64;
var
  t1,t2:int64;
begin
  if Step=0 then
  begin
    exit;
  end;

  t2:=CurValue;
  T1:=T2+Step;
  if Step>0 then
  begin
     if T1>self.aInt_Max then
     begin
       if loop then
       T1:=self.aInt_Min
       else
       t1:=self.aInt_Max;
     end;
  end
  else
  begin
    if T1<self.aInt_Min then
    begin
      if loop then
      T1:=self.aInt_Max
      else
      t1:=self.aInt_Min;
    end;
  end;
  Result:=T1;
end;

function TEdit.Calc_Add_Flt(CurValue: Double; step: Double; loop: boolean): Double;
var
  t1,t2:Double;
begin
  if Step=0 then
  begin
    exit;
  end;

  t2:=CurValue;
  T1:=T2+Step;
  if Step>0 then
  begin
     if T1>self.aFlt_Max then
     begin
       if loop then
       T1:=self.aFlt_Min
       else
       t1:=self.aFlt_Max;
     end;
  end
  else
  begin
    if T1<self.aFlt_Min then
    begin
      if loop then
      T1:=self.aFlt_Max
      else
      t1:=self.aFlt_Min;
    end;
  end;
  Result:=T1;

end;

function TEdit.Default_Add(Oldvalue:String;isDec:boolean;setToText:Boolean=true): string;
var
  s:String;
  t:int64;
  t2:Double;
begin
  Result:=oldValue;
  case self.aMode of
    1:
      begin
        if not sysutils.TryStrToInt64(Oldvalue,T) then
        T:=self.aInt_Default;

        if isDec then
        T:=self.Calc_Add_int(T,self.aInt_Step)
        else
        T:=self.Calc_Add_int(T,-self.aInt_Step);

        Result:=inttostr(T);

      end;
    2:
      begin
        if not sysutils.TryStrToFloat(Oldvalue,T2) then
        T2:=self.aFlt_Default;

        if isDec then
        T2:=self.Calc_Add_Flt(T2,self.aFlt_Step)
        else
        T2:=self.Calc_Add_Flt(T2,-self.aFlt_Step);

        Result:=sysutils.FormatFloat(self.aFlt_Fmt,T2);

      end;
  end;

  if SetToText then
  self.Text:=Result;

end;


constructor TEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
   self.aInt_Max:=Maxint;
   self.aInt_Min:=-Maxint;
   self.aFlt_Max:=Maxint;
   self.aFlt_Min:=-Maxint;
   self.aMode:=0;
end;

destructor TEdit.Destroy;
begin
  inherited Destroy;
end;


procedure SetDateFormat;
begin
  sysutils.LongTimeFormat:='HH:nn:ss';
  sysutils.DateSeparator:='-';
  sysutils.TimeSeparator:=':';
  sysutils.FormatSettings.TimeSeparator:=':';
  sysutils.FormatSettings.DateSeparator:='-';
  sysutils.FormatSettings.LongTimeFormat:='HH:nn:ss';
  sysutils.FormatSettings.LongDateFormat:='yyyy-MM-dd';
  sysutils.FormatSettings.ShortTimeFormat:='HH:nn:ss';
  sysutils.FormatSettings.ShortDateFormat:='yyyy-MM-dd';

end;



initialization
  SetDateFormat;


end.

