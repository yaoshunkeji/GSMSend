unit LinuxCompress_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils,Process,BaseUnix,Unix,forms;



type
  { TLinuxCompress }
  TCompressProgress=procedure(Src:string;Dest:string;Cur:int64;Size:int64;StartTime:TDateTime) of object;

  //http://www.semicomplete.com/blog/geekery/gzip-and-other-file-progress.html

  TLinuxCompress = class(TThread)
  private
    pid:integer;
    SrcSize:int64;
    OnProgress:TCompressProgress;
    StartTime:TDateTime;
    Source:string;
    Dest:string;
    CurPos:int64;
    SrcfdInfo:string;
    Done:Boolean;
    procedure DoProgress;
    function GetSrcfdInfo: string;
    function ProcExists:Boolean;
  protected
    procedure Execute;override;
    function GetSrcFilePos:int64;
  public

    constructor Create(aPid:integer;aSource:string;aDest:string;aOnProgress:TCompressProgress);
    destructor Destroy; override;
  end;

function LinuxCompress(sourcefn:string;destfn:string;OnProgress:TCompressProgress;cmd:string='zip';CompressLevel:integer=5):Boolean;

implementation

uses
  CommFunUnit;

function LinuxCompress(sourcefn:string;destfn:string;OnProgress:TCompressProgress;cmd:string='zip';CompressLevel:integer=5):Boolean;
var
  lc:TLinuxCompress;
  pid:integer;
  proc:TProcess;
  Source:string;
  dest:string;
begin
  Result:=false;
  source:=Delete_Surplus_DirSep(SourceFn,'/');
  dest:=Delete_Surplus_DirSep(destFn,'/');
  proc:=TProcess.Create(nil);
  proc.Options:=[poNoConsole,poUsePipes,poRunSuspended];
  proc.CommandLine:=cmd+' -j -'+inttostr(CompressLevel)+' "'+dest+'" "'+source+'"';
  writeln(proc.CommandLine);

  try
    proc.Execute;
  except
    sysutils.FreeAndNil(proc);
    exit;
  end;
  writeln(proc.ProcessID);
  lc:=TLinuxCompress.Create(proc.ProcessID,Source,Dest,OnProgress);
  proc.Resume;
  while proc.Running do
  begin
    sleep(300);
    application.ProcessMessages;
  end;
//  writeln(proc.Input.ReadAnsiString);
  sysutils.FreeAndNil(proc);
    Result:=true;
end;

{ TLinuxCompress }

function TLinuxCompress.GetSrcfdInfo: string;
var
  s,s2:String;
  SR:TSearchRec;
  R:integer;
begin

  Result:='';
  s:='/proc/'+inttostr(self.pid)+'/fd/';
  if not sysutils.DirectoryExists(s) then
  exit;
  fillchar(SR,sizeof(SR),0);
  r:=sysutils.FindFirst(s+'*',faSymLink,SR);
  while R=0  do
  begin
    if not ((SR.Name='.') or (SR.Name='..')) then
    begin
      s2:=s+sr.Name;
      s2:=fpreadlink(s2);
      if s2=self.Source then
      begin
        s:='/proc/'+inttostr(self.pid)+'/fdinfo/';
        Result:=s+sr.Name;
        system.Break;
      end;
    end;
    R:=sysutils.FindNext(sr);
  end;
  sysutils.FindClose(sr);
end;

function TLinuxCompress.ProcExists: Boolean;
var
  s:String;
begin
  Result:=false;
  s:='/proc/'+inttostr(self.pid);
  if sysutils.DirectoryExists(s) then
  Result:=true;
end;

function TLinuxCompress.GetSrcFilePos: int64;
var
  s:string;
  strlst:TStringList;
begin
  Result:=-1;
  strlst:=nil;
  if self.SrcfdInfo='' then
  self.SrcfdInfo:=self.GetSrcfdInfo;

  if not sysutils.FileExists(self.SrcfdInfo) then
  begin
    self.SrcfdInfo:=self.GetSrcfdInfo;
    if self.SrcfdInfo='' then
    begin
      self.SrcSize:=self.CurPos;
//      Done:=true;
      exit;
    end;
  end;

  try
    if (SrcfdInfo='') or (not sysutils.FileExists(self.SrcfdInfo)) then
    exit;
    strlst:=TStringList.Create;
    strlst.LoadFromFile(self.SrcfdInfo);
  except
    sysutils.FreeAndNil(strlst);
    Result:=-1;
    exit;
  end;
  s:=CommFunUnit.GetValue(strlst,'pos',':');
  sysutils.FreeAndNil(strlst);
  if not sysutils.TryStrToInt64(s,Result) then
  Result:=-1;
end;

procedure TLinuxCompress.DoProgress;
begin
  if not system.Assigned(self.OnProgress) then
  exit;
  self.OnProgress(self.Source,self.Dest,self.CurPos,self.SrcSize,self.StartTime);

end;

procedure TLinuxCompress.Execute;
var
  b:Boolean;
  t:int64;
begin
  b:=false;
  t:=0;
  while not self.Terminated do
  begin
    if not ProcExists then
    begin
      self.CurPos:=self.SrcSize;
      self.DoProgress;
      system.Break;
    end;
    if not b then
    begin
      SrcfdInfo:=GetSrcfdInfo;
      if SrcfdInfo='' then
      begin
        sleep(50);
        inc(t,50);
        if t>15000 then
        system.Break;

        system.Continue;
      end;

    end;
    b:=true;

    CurPos:=GetSrcFilePos;
    self.Synchronize(DoProgress);
    sleep(300);

  end;
  sleep(1);
end;

constructor TLinuxCompress.Create(aPid:integer;aSource:string;aDest:string;aOnProgress:TCompressProgress);
begin
  Inherited Create(True);
  Done:=False;
  self.FreeOnTerminate:=True;
  self.StartTime:=now;
  self.SrcSize:=GetFileSize(aSource);
  self.Source:=aSource;
  self.Dest:=aDest;
  self.pid:=aPid;
  self.OnProgress:=aOnProgress;
  self.Resume;
end;

destructor TLinuxCompress.Destroy;
begin
  inherited Destroy;
end;

end.

