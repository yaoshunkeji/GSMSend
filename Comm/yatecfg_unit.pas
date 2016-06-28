unit YateCFG_Unit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils,math;

type
  { TYateCFG }
  TYateCFG = class(TStringList)
  private
    fn:string;
    FReplaceFemark: Boolean;
    w:Boolean;
    function subFindVal(Section, Ident: string;notExistsInsert:Boolean): integer;
  public
    property ReplaceFemark:Boolean read FReplaceFemark write FReplaceFemark;    //如果没有项目，就替换;name=xx的项目
    function FindVal(const Section, Ident: string;notExistsInsert:Boolean): integer;
    function ReadString(const Section, Ident, Default: string): string;
    procedure WriteString(const Section, Ident, Value: String);

    function ReadInt64(const Section, Ident:string; Default: int64): int64;
    procedure WriteInt64(const Section, Ident:string; Val: int64);

    procedure UpdateFile;
    constructor Create(aFn:string);
    destructor Destroy; override;
  end;

implementation

{ TYateCFG }

function TYateCFG.subFindVal(Section, Ident: string; notExistsInsert: Boolean): integer;
var
  i:integer;
  s:string;
  l:integer;
  s1:string;
  Pos,pos2:integer;
  b:Boolean;
begin

  Result:=-1;
  Section:='['+Section+']';
  l:=length(Section);
  pos:=-1;
  pos2:=-1;
  if L=0 then
  exit;
  i:=0;

  while i<self.Count do
  begin
    s:=trim(self.Strings[i]);
//    s1:=copy(s,1,L);
    if not sysutils.SameText(Section,s) then   //
    begin
      inc(i);
      system.Continue;
    end;
    inc(i);
    Pos:=i;
    if trim(s)='' then
    system.Continue;

    l:=length(Ident);
    while i<self.Count do
    begin
      s:=trim(self.Strings[i]);
      s1:=s;
      if s='' then
      begin
        inc(i);
        system.Continue;
      end;
      pos2:=i;
      s:=copy(s,1,l);
      if (s[1]='[') then
      begin
        pos2:=-1;
        system.Break;
      end;
      if sysutils.SameText(s,Ident) then
      begin
        system.delete(s1,1,length(Ident));
        s:=s1;
        if s1<>'' then
        begin
          if s[1]='=' then
          begin
            Result:=i;
            exit;
          end;
        end;


      end;
      inc(i);
    end;
   // pos:=-1;
    system.Break;
  end;

  if not notExistsInsert then
  begin
    exit;
  end;
  if (pos=-1) then
  begin
    self.Add(Section);
    pos:=self.Count-1;
    pos2:=pos;
  end;
  pos2:=max(pos,pos2);
  pos2:=pos2+1;
  if (pos2<=pos) then
  begin
    if pos2>self.Count then
    self.Add(Ident+'=')
    else
    self.Insert(pos,Ident+'=');
  end
  else
  begin
    if pos2>=self.Count then
    self.Add(Ident+'=')
    else
    self.Insert(pos2,Ident+'=');

  end;
  Result:=min(pos2,self.Count-1);

end;

function TYateCFG.FindVal(const Section, Ident: string;notExistsInsert:Boolean): integer;
var
  c:integer;
begin
  Result:=self.subFindVal(Section,Ident,False);
  if not notExistsInsert then
  exit;
  if Result=-1 then
  begin
    Result:=self.subFindVal(Section,';'+Ident,False);
    if Result<>-1 then
    begin
      if not FReplaceFemark then
      begin
        if Result<self.Count then
        self.Insert(Result+1,ident+'=')
        else
        self.Add(ident+'=');
        Result:=Result+1;
        exit;
      end;
      Result:=Result;
      exit;
    end;
    Result:=self.subFindVal(Section,Ident,notExistsInsert);
  end;

end;

function TYateCFG.ReadString(const Section, Ident, Default: string): string;
var
  i:integer;
  s:string;
begin
  i:=self.FindVal(Section, Ident,False);
  if i=-1 then
  begin
    Result:=default;
    exit;
  end;
  s:=self.Strings[i];
  i:=length(Ident);
  system.Delete(s,1,i);
  s:=sysutils.TrimLeft(s);
  if s='' then
  begin
    Result:=default;
    exit;
  end;
  if s[1]<>'=' then
  begin
    Result:=default;
    exit;
  end;
  Result:=copy(s,2,maxint);
end;

procedure TYateCFG.WriteString(const Section, Ident, Value: String);
var
  i:integer;
  s:string;
begin
  w:=true;
  i:=self.FindVal(Section, Ident,true);
  if i=-1 then
  begin
    exit;
  end;
 self.Strings[i]:=Ident+'='+Value;
end;

function TYateCFG.ReadInt64(const Section, Ident:string;Default: int64): int64;
var
  s:string;
begin
  s:=self.ReadString(Section,Ident,inttostr(Default));
  if not sysutils.TryStrToInt64(s,Result) then
  Result:=Default;
end;

procedure TYateCFG.WriteInt64(const Section, Ident: string; Val: int64);
begin
  self.WriteString(Section,Ident,inttostr(Val));
end;

procedure TYateCFG.UpdateFile;
begin
  self.SaveToFile(fn);
end;

constructor TYateCFG.Create(aFn: string);
begin
  inherited Create;
  self.w:=False;
  self.FReplaceFemark:=False;
  self.LoadFromFile(aFn);
  self.fn:=aFn;
end;

destructor TYateCFG.Destroy;
begin
  if w then
  self.UpdateFile;
  self.fn:='';
  inherited Destroy;
end;

end.

