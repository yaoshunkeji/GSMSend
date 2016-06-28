
unit Process_Unit;

{$mode delphi}{$H+}

interface

Uses
  Classes,pipes,SysUtils,ctypes,unixType,Unix,Baseunix,math;

type

  { TProcess2 }

  TPCharArray = Array[Word] of pchar;
  PPCharArray = ^TPcharArray;
  TPipeEnd = (peRead,peWrite);
  TPipePair = Array[TPipeEnd] of cint;
  TProcessPriority = (ppHigh,ppIdle,ppNormal,ppRealTime);
  TProcessMode=(
    pm_Hide,
    pm_Pipes,
    pm_NewConsole
  );

  TOnOutputLine=procedure(sender:TObject;Str:string;blError:Boolean) of object;

Type
  {$ifdef UNIX}
  TProcessForkEvent = procedure(Sender : TObject) of object;
  {$endif UNIX}

  { TProcess }

  { TConsoleRedirect }
  EConsolereDirect = Class(Exception);

  TConsoleRedirect = Class (TThread)
  Private
    FOnOutputLine: TOnOutputLine;
    FProcessMode: TProcessMode;
    FProcessID : Integer;
    FStdErrToOutPut: boolean;
    FTerminalProgram: String;
    FThreadID : Integer;
    FProcessHandle : Thandle;
    FThreadHandle : Thandle;
    FFillAttribute : Cardinal;
    FApplicationName : string;
    FConsoleTitle : String;
    FCommandLine : String;
    FCurrentDirectory : String;
    FDesktop : String;
    FEnvironment : Tstrings;
    FExecutable : String;
    FParameters : TStrings;

    FInherithandles : Boolean;
    {$ifdef UNIX}
    FForkEvent : TProcessForkEvent;
    {$endif UNIX}
    FProcessPriority : TProcessPriority;
    dwXCountchars,
    dwXSize,
    dwYsize,
    dwx,
    dwYcountChars,
    dwy : Cardinal;
    FXTermProgram: String;
    FPipeBufferSize : cardinal;

    FOutputBuff:array[0..128*1024-1] of byte;
    FOutputBuffSize:integer;
    FErrBuff:array[0..128*1024-1] of AnsiChar;
    FErrBuffSize:integer;

    FCurStr:AnsiString;
    FBlErr:Boolean;

    procedure dopty_read;
    function FindCRLF(buff: PByteArray; Size: integer; FindLast: boolean): integer;
    Procedure FreeStreams;
    Function  GetExitStatus : Integer;
    Function  GetExitCode : Integer;
    Function  GetRunning : Boolean;
    Function  GetWindowRect : TRect;
    function MakeCommand: PPchar;
    procedure SetCommandLine(const AValue: String);
    procedure SetExecutable(AValue: String);
    Procedure SetWindowRect (Value : TRect);
    procedure SetApplicationName(const Value: String);
    Procedure ConvertCommandLine;
    function  PeekExitStatus: Boolean;
  Protected
    FRunning : Boolean;
    FExitCode : Cardinal;
    FInputStream  : TOutputPipeStream;
    FOutputStream : TInputPipeStream;
    FStderrStream : TInputPipeStream;
    HI,HO,HE : TPipePair;

    procedure CloseProcessHandles; virtual;
    Procedure CreateStreams(InHandle,OutHandle,ErrHandle : Longint);virtual;
    procedure FreeStream(var AStream: THandleStream);

    procedure Execute;override;
    Procedure DoRun; virtual;
    procedure DoOutput(blErr:Boolean;blEnd:Boolean);
    procedure DoOutput2;
  Public
    constructor Create(RunDoneAutoFree:Boolean=true);
    Destructor Destroy; override;
    procedure CloseInput; virtual;
    procedure CloseOutput; virtual;
    procedure CloseStderr; virtual;
    Function Terminate (AExitCode : Integer): Boolean; virtual;
    Function WaitOnExit : Boolean;
    Property WindowRect : Trect Read GetWindowRect Write SetWindowRect;
    Property Handle : THandle Read FProcessHandle;
    Property ProcessHandle : THandle Read FProcessHandle;
    Property ThreadHandle : THandle Read FThreadHandle;
    Property ProcessID : Integer Read FProcessID;
//    Property ThreadID : Integer Read FThreadID;
    Property Input  : TOutputPipeStream Read FInputStream;
    Property Output : TInputPipeStream  Read FOutputStream;
    Property Stderr : TinputPipeStream  Read FStderrStream;
    Property ExitStatus : Integer Read GetExitStatus;
    Property ExitCode : Integer Read GetExitCode;
    {$ifdef UNIX}
    property OnForkEvent : TProcessForkEvent Read FForkEvent Write FForkEvent;
    {$endif UNIX}

    property OnOutputLine:TOnOutputLine read FOnOutputLine write FOnOutputLine;

    function Run:Boolean;
  Published
    property PipeBufferSize : cardinal read FPipeBufferSize write FPipeBufferSize default 1024;
    Property ApplicationName : String Read FApplicationName Write SetApplicationName; deprecated;
    Property CommandLine : String Read FCommandLine Write SetCommandLine ; deprecated;
    Property Executable : String Read FExecutable Write SetExecutable;

    Property Parameters : TStrings Read FParameters;
    Property ConsoleTitle : String Read FConsoleTitle Write FConsoleTitle;
    Property CurrentDirectory : String Read FCurrentDirectory Write FCurrentDirectory;
    Property Desktop : String Read FDesktop Write FDesktop;
    Property Environment : TStrings Read FEnvironment;
    Property Priority : TProcessPriority Read FProcessPriority Write FProcessPriority;
    Property Running : Boolean Read GetRunning;
    Property WindowColumns : Cardinal Read dwXCountChars Write dwXCountChars;
    Property WindowHeight : Cardinal Read dwYSize Write dwYSize;
    Property WindowLeft : Cardinal Read dwX Write dwX;
    Property WindowRows : Cardinal Read dwYCountChars Write dwYCountChars;
    Property WindowTop : Cardinal Read dwY Write dwY;
    Property WindowWidth : Cardinal Read dwXSize Write dwXSize;
    Property FillAttribute : Cardinal read FFillAttribute Write FFillAttribute;
    Property XTermProgram : String Read FXTermProgram Write FXTermProgram;
    property ProcessMode:TProcessMode read FProcessMode write FProcessMode;
    property StdErrToOutPut:boolean read FStdErrToOutPut write FStdErrToOutPut;

  end;

{$ifdef unix}
Var
  TryTerminals : Array of string;
  XTermProgram : String;
  Function DetectXTerm : String;
{$endif unix}


implementation

Resourcestring
  SNoCommandLine        = 'Cannot execute empty command-line';
  SErrNoSuchProgram     = 'Executable not found: "%s"';
  SErrNoTerminalProgram = 'Could not detect X-Terminal program';
  SErrCannotFork        = 'Failed to Fork process';
  SErrCannotCreatePipes = 'Failed to create pipes';

Const
  PriorityConstants : Array [TProcessPriority] of Integer =
                      (20,20,0,-20);

Const
  GeometryOption : String = '-geometry';
  TitleOption : String ='-title';






Procedure CommandToList(S : String; List : TStrings);
  Function GetNextWord : String;

  Const
    WhiteSpace = [' ',#9,#10,#13];
    Literals = ['"',''''];

  Var
    Wstart,wend : Integer;
    InLiteral : Boolean;
    LastLiteral : char;

  begin
    WStart:=1;
    While (WStart<=Length(S)) and (S[WStart] in WhiteSpace) do
      Inc(WStart);
    WEnd:=WStart;
    InLiteral:=False;
    LastLiteral:=#0;
    While (Wend<=Length(S)) and (Not (S[Wend] in WhiteSpace) or InLiteral) do
      begin
      if S[Wend] in Literals then
        If InLiteral then
          InLiteral:=Not (S[Wend]=LastLiteral)
        else
          begin
          InLiteral:=True;
          LastLiteral:=S[Wend];
          end;
       inc(wend);
       end;

     Result:=Copy(S,WStart,WEnd-WStart);

     if  (Length(Result) > 0)
     and (Result[1] = Result[Length(Result)]) // if 1st char = last char and..
     and (Result[1] in Literals) then // it's one of the literals, then
       Result:=Copy(Result, 2, Length(Result) - 2); //delete the 2 (but not others in it)

     While (WEnd<=Length(S)) and (S[Wend] in WhiteSpace) do
       inc(Wend);
     Delete(S,1,WEnd-1);

  end;

Var
  W : String;

begin
  While Length(S)>0 do
    begin
    W:=GetNextWord;
    If (W<>'') then
      List.Add(W);
    end;
end;



Function StringsToPCharList(List : TStrings) : PPChar;
Var
  I : Integer;
  S : String;

begin
  I:=(List.Count)+1;
  GetMem(Result,I*sizeOf(PChar));
  PPCharArray(Result)^[List.Count]:=Nil;
  For I:=0 to List.Count-1 do
    begin
    S:=List[i];
    Result[i]:=StrNew(PChar(S));
    end;
end;

Procedure FreePCharList(List : PPChar);

Var
  I : integer;

begin
  I:=0;
  While List[i]<>Nil do
    begin
    StrDispose(List[i]);
    Inc(I);
    end;
  FreeMem(List);
end;



Function DetectXterm : String;

  Function TestTerminal(S : String) : Boolean;

  begin
    Result:=FileSearch(s,GetEnvironmentVariable('PATH'),False)<>'';
    If Result then
      XTermProgram:=S;
  end;

  Function TestTerminals(Terminals : Array of String) : Boolean;

  Var
    I : integer;
  begin
    I:=Low(Terminals);
    Result:=False;
    While (Not Result) and (I<=High(Terminals)) do
      begin
      Result:=TestTerminal(Terminals[i]);
      inc(i);
      end;
  end;

Const
  Konsole   = 'konsole';
  GNomeTerm = 'gnome-terminal';
  DefaultTerminals : Array [1..6] of string
                   = ('x-terminal-emulator','xterm','aterm','wterm','rxvt','xfce4-terminal');

Var
  D :String;

begin
  If (XTermProgram='') then
    begin
    // try predefined
    If Length(TryTerminals)>0 then
      TestTerminals(TryTerminals);
    // try session-specific terminal
    if (XTermProgram='') then
      begin
      D:=LowerCase(GetEnvironmentVariable('DESKTOP_SESSION'));
      If (Pos('kde',D)<>0) then
        begin
        TestTerminal('konsole');
        end
      else if (D='gnome') then
        begin
        TestTerminal('gnome-terminal');
        end
      else if (D='windowmaker') then
        begin
        If not TestTerminal('aterm') then
          TestTerminal('wterm');
        end
      else if (D='xfce') then
        TestTerminal('xfce4-terminal');
      end;
    if (XTermProgram='') then
      TestTerminals(DefaultTerminals)
    end;
  Result:=XTermProgram;
  If (Result='') then
    Raise EConsolereDirect.Create(SErrNoTerminalProgram);
end;

function TConsoleRedirect.MakeCommand: PPchar;

{$ifdef darwin}
Const
  TerminalApp = 'open';
{$endif}
{$ifdef haiku}
Const
  TerminalApp = 'Terminal';
{$endif}

Var
  Cmd : String;
  S  : TStringList;
  G : String;

begin
  If (self.CommandLine='') then
    Raise EConsolereDirect.Create(SNoCommandline);
  S:=TStringList.Create;
  try
      S.Assign(self.Parameters);
      S.Insert(0,self.Executable);
    if self.ProcessMode=pm_NewConsole then
      begin
      S.Insert(0,'-e');
      If (self.ApplicationName<>'') then
        begin
        S.Insert(0,self.ApplicationName);
        S.Insert(0,'-title');
        end;
      if (self.dwXCountChars>0) and (self.dwYCountChars>0) then
        begin
        S.Insert(0,Format('%dx%d',[self.dwXCountChars,self.dwYCountChars]));
        S.Insert(0,'-geometry');
        end;
      If (self.XTermProgram<>'') then
        S.Insert(0,self.XTermProgram)
      else
        S.Insert(0,DetectXterm);
      end;

    if (self.ApplicationName<>'') then
      begin
      S.Add(TitleOption);
      S.Add(self.ApplicationName);
      end;
    G:='';
    if (self.dwXSize>0) and (self.dwYsize>0) then
      g:=format('%dx%d',[self.dwXSize,self.dwYsize]);
    if (self.dwx<>-1) and (self.dwy<>-1) then
      g:=g+Format('+%d+%d',[self.dwX,self.dwY]);
    if G<>'' then
      begin
      S.Add(GeometryOption);
      S.Add(g);
      end;

    Result:=StringsToPcharList(S);
  Finally
    S.free;
  end;
end;

Function GetLastError : Integer;

begin
  Result:=-1;
end;

Procedure CreatePipes(Var HI,HO,HE : TPipePair; CE : Boolean);

  Procedure CreatePair(Var P : TPipePair);

   begin
    If not CreatePipeHandles(P[peRead],P[peWrite]) then
      Raise EConsolereDirect.Create(SErrCannotCreatePipes);
   end;

  Procedure ClosePair(Var P : TPipePair);

  begin
    if (P[peRead]<>-1) then
      FileClose(P[peRead]);
    if (P[peWrite]<>-1) then
      FileClose(P[peWrite]);
  end;

begin
  HO[peRead]:=-1;HO[peWrite]:=-1;
  HI[peRead]:=-1;HI[peWrite]:=-1;
  HE[peRead]:=-1;HE[peWrite]:=-1;
  Try
    CreatePair(HO);
    CreatePair(HI);
    If CE then
      CreatePair(HE);
  except
    ClosePair(HO);
    ClosePair(HI);
    If CE then
      ClosePair(HE);
    Raise;
  end;
end;

Function safefpdup2(fildes, fildes2 : cInt): cInt;
begin
  repeat
    Result:=fpdup2(fildes,fildes2);
  until (Result<>-1) or (fpgeterrno<>ESysEINTR);
end;

constructor TConsoleRedirect.Create(RunDoneAutoFree: Boolean);
begin
  Inherited Create(True);
  FProcessPriority:=ppNormal;
  self.FProcessMode:=pm_Pipes;
  FInheritHandles:=True;
  {$ifdef UNIX}
  FForkEvent:=nil;
  {$endif UNIX}
  FPipeBufferSize := 1024;
  FEnvironment:=TStringList.Create;
  FParameters:=TStringList.Create;
  self.dwYsize:=-1;
  self.dwXSize:=-1;

  fillchar(FOutputBuff[0],sizeof(FOutputBuff),0);
  FOutputBuffsize:=0;
  fillchar(FErrBuff[0],sizeof(FErrBuff),0);
  FErrBuffSize:=0;

  FEnvironment :=TStringList.Create;
  FParameters :=TStringList.Create;

  self.Priority:=ppIdle;
end;

destructor TConsoleRedirect.Destroy;
begin
  FParameters.Free;
  FEnvironment.Free;
  FreeStreams;
  CloseProcessHandles;
  Inherited Destroy;
end;



function rdline(buff:PAnsiChar;bufflen:integer;FileHandle:integer):integer;
var
  c:integer;
  cc:byte;
  s:pbyte;
  z:integer;
begin
  c:=0;
  FillByte(buff^,bufflen,0);

  while (c<bufflen) do
  begin
    z:=fpread(FileHandle,cc,1);
    if (z=0) then
        break;
    if (cc=10) then
        break;
    if (cc=255) then
        break;

    buff[c]:=ansiChar(cc);
    inc(c);
  end;
  result:=c;
end;


procedure TConsoleRedirect.dopty_read();
var
  ret:integer;
  reads:TFDSet;
  pty:integer;
begin
ret:=0;
pty:=self.HO[peRead];

//  struct stat tStat= {0};
  while(true) do
  begin
    fpFD_ZERO(reads);
    fpFD_SET(pty, reads );

    ret := fpselect( pty+1, @reads, nil, nil, nil);

    if ( ret = -1 ) then
      begin
       //perror( "select11" );
       //          exit(0);
       break;
      end;

    ret := rdline(@self.FErrBuff[0], 4096,pty);
    if (FErrBuff='select: Bad file descriptor') then
        break;
    if (( ret <= 0 ) or (ret=4096)) then
    begin
      system.Break;
    end;
    FErrBuffSize:=ret;
    self.DoOutput(False,False);

  end;
end;



procedure TConsoleRedirect.Execute;
var
    numbytes,bytesread: integer;
    outputlength, stderrlength : integer;
    stderrnumbytes,stderrbytesread : integer;
    Available1,Available2:Integer;
    f:TFileStream;

    procedure DoRead(blEnd:Boolean);
    begin
      available1:=self.Output.NumBytesAvailable;
      if Available1 > 0 then
        begin
          Available1:=Min(Available1,16*1024);
          NumBytes := self.Output.Read(FOutputBuff[FOutputBuffsize], available1);
          FOutputBuffsize:=FOutputBuffsize+NumBytes;
          self.DoOutput(False,blEnd);
//          writeln(pchar(@FOutputBuff[0]));;
        //  f.Write(FOutputBuff[1],FOutputBuffsize);

        end
      // The check for assigned(P.stderr) is mainly here so that
      // if we use poStderrToOutput in p.Options, we do not access invalid memory.
      else if assigned(self.stderr) and (self.StdErr.NumBytesAvailable > 0) then
        begin
          Available2:=Min(Available2,16*1024);
          NumBytes := self.Stderr.Read(FErrBuff[FErrBuffsize], Available2);
          FErrBuffSize:=FErrBuffSize+NumBytes;
          self.DoOutput(True,blEnd);
        //  f.Write(FErrBuff[1],FErrBuffsize);
        end
      else
        if (Available1=-1) or (Available1=-1) then
        begin
//          self.DoOutput(Fale,True);
        end;
        Sleep(100);
    end;

begin
  dopty_read;
  exit;

  try
//    F:=TFileStream.Create('/tmp/aaaa.txt',fmcreate);
  while self.Running do
    begin
      DoRead(False);
    end;
      DoRead(True);
   //   f.Free;
  except
   end;
if self.FreeOnTerminate then
begin
end;
end;

{
procedure TConsoleRedirect.Execute;
var
    numbytes,bytesread: integer;
    outputlength, stderrlength : integer;
    stderrnumbytes,stderrbytesread : integer;
    Available1,Available2:Integer;
    f:TFileStream;

    procedure DoRead(blEnd:Boolean);
    begin
      available1:=self.Output.NumBytesAvailable;
      if Available1 > 0 then
        begin
          Available1:=Min(Available1,16*1024);
          NumBytes := self.Output.Read(FOutputBuff[FOutputBuffsize], available1);
          FOutputBuffsize:=FOutputBuffsize+NumBytes;
          self.DoOutput(False,blEnd);
//          writeln(pchar(@FOutputBuff[0]));;
        //  f.Write(FOutputBuff[1],FOutputBuffsize);

        end
      // The check for assigned(P.stderr) is mainly here so that
      // if we use poStderrToOutput in p.Options, we do not access invalid memory.
      else if assigned(self.stderr) and (self.StdErr.NumBytesAvailable > 0) then
        begin
          Available2:=Min(Available2,16*1024);
          NumBytes := self.Stderr.Read(FErrBuff[FErrBuffsize], Available2);
          FErrBuffSize:=FErrBuffSize+NumBytes;
          self.DoOutput(True,blEnd);
        //  f.Write(FErrBuff[1],FErrBuffsize);
        end
      else
        if (Available1=-1) or (Available1=-1) then
        begin
//          self.DoOutput(Fale,True);
        end;
        Sleep(100);
    end;

begin

  try
//    F:=TFileStream.Create('/tmp/aaaa.txt',fmcreate);
  while self.Running do
    begin
      DoRead(False);
    end;
      DoRead(True);
   //   f.Free;
  except
   end;
if self.FreeOnTerminate then
begin
end;
end;
}
procedure TConsoleRedirect.DoRun;
Var
  PID      : Longint;
  FEnv     : PPChar;
  Argv     : PPChar;
  fd       : Integer;
  res      : cint;
  FoundName,
  PName    : String;

begin
  If (self.ProcessMode=pm_Pipes) then
    CreatePipes(HI,HO,HE,Not FStdErrToOutPut);

  Try
    if FEnvironment.Count<>0 then
      FEnv:=StringsToPcharList(FEnvironment)
    else
      FEnv:=Nil;
    Try
      Argv:=MakeCommand();
      Try
        If (Argv<>Nil) and (ArgV[0]<>Nil) then
          PName:=StrPas(Argv[0])
        else
          begin
          // This should never happen, actually.
          PName:=ApplicationName;
          If (PName='') then
            PName:=CommandLine;
          end;

        if not FileExists(PName) then begin
          FoundName := ExeSearch(Pname,fpgetenv('PATH'));
          if FoundName<>'' then
            PName:=FoundName
          else
            raise EConsolereDirect.CreateFmt(SErrNoSuchProgram,[PName]);
        end;
        Pid:=fpfork;
        if Pid<0 then
          Raise EConsolereDirect.Create(SErrCannotFork);
        if (PID>0) then
          begin
            // Parent process. Copy process information.
            FProcessHandle:=PID;
            FThreadHandle:=PID;
            FProcessId:=PID;
            //FThreadId:=PID;
          end
        else
          begin
            { We're in the child }
            if (FCurrentDirectory<>'') then
               begin
{$push}{$i-}
                 ChDir(FCurrentDirectory);
                 { exit if the requested working directory does not exist (can
                   use DirectoryExists, that would not be atomic; cannot change
                   before forking because that would also change the CWD of the
                   parent, which could influence other threads }
                 if ioresult<>0 then
                   fpexit(127);
{$pop}
               end;
            if self.ProcessMode=pm_Pipes then
              begin
                FileClose(HI[peWrite]);
                safefpdup2(HI[peRead],0);
                FileClose(HO[peRead]);
                safefpdup2(HO[peWrite],1);
                if (StdErrToOutPut) then
                  safefpdup2(HO[peWrite],2)
                else
                  begin
                    FileClose(HE[peRead]);
                    safefpdup2(HE[peWrite],2);
                  end
              end;
               if self.ProcessMode=pm_Hide then
              begin
                fd:=FileOpen('/dev/null',fmOpenReadWrite or fmShareDenyNone);
                safefpdup2(fd,0);
                safefpdup2(fd,1);
                safefpdup2(fd,2);
              end;
            if Assigned(FForkEvent) then
              FForkEvent(Self);
            if FEnv<>Nil then
              fpexecve(PName,Argv,Fenv)
            else
              fpexecv(PName,argv);
            fpExit(127);
          end
      Finally
        FreePcharList(Argv);
      end;
    Finally
      If (FEnv<>Nil) then
        FreePCharList(FEnv);
    end;
  Finally
    if self.ProcessMode=pm_Pipes then
      begin
        FileClose(HO[peWrite]);
        FileClose(HI[peRead]);
        if Not (StdErrToOutPut) then
        FileClose(HE[peWrite]);
      //  CreateStreams(HI[peWrite],HO[peRead],HE[peRead]);
      end;
  end;
  FRunning:=True;
  //if not (csDesigning in ComponentState) and // This would hang the IDE !
  //   (poWaitOnExit in FProcessOptions) and
  //    not (poRunSuspended in FProcessOptions) then
  //  WaitOnExit;

end;

function TConsoleRedirect.FindCRLF(buff:PByteArray;Size:integer;FindLast:boolean):integer;
var
  i:integer;
begin
  Result:=-1;
  i:=0;
  while i<size do
  begin
    if (buff^[i] in [10,13]) then
    begin
      Result:=i;
      if not FindLast then
      exit;
    end;

  end;


end;

procedure TConsoleRedirect.DoOutput(blErr: Boolean; blEnd: Boolean);
var
  c:integer;
begin

  setlength(self.FCurStr,FErrBuffSize);
  move(FErrBuff[0],FCurStr[1],FErrBuffSize);
  self.Synchronize(self.DoOutput2);

  exit;
  if (blErr or BlEnd ) and (self.FErrBuffSize>0) then
  begin
    if BlEnd then
    begin
      setlength(self.FCurStr,FErrBuffSize);
      move(FErrBuff[0],FCurStr[1],FErrBuffSize);
      self.Synchronize(self.DoOutput2);
      FErrBuffSize:=0;
    end
    else
    begin
      c:=self.FindCRLF(@FErrBuff[0],FErrBuffSize,True);
      setlength(self.FCurStr,c);
      move(FErrBuff[0],FCurStr[1],c);
      if blEnd then
      c:=c+1;
      move(FErrBuff[0],FErrBuff[c],FErrBuffSize-c);
      self.Synchronize(self.DoOutput2);
    end;
  end;

  if ((not blErr) or BlEnd ) and (self.FOutputBuffSize>0) then
  begin
    if BlEnd then
    begin
      setlength(self.FCurStr,FOutputBuffSize);
      move(FOutputBuff[0],FCurStr[1],FOutputBuffSize);
      self.Synchronize(self.DoOutput2);
      FErrBuffSize:=0;
    end
    else
    begin
      c:=self.FindCRLF(@FOutputBuff[0],FOutputBuffSize,True);
      setlength(self.FCurStr,c);
      move(FOutputBuff[0],FCurStr[1],c);
      if blEnd then
      c:=c+1;
      move(FOutputBuff[0],FOutputBuff[c],FErrBuffSize-c);
      self.Synchronize(self.DoOutput2);
    end;
  end;


end;

procedure TConsoleRedirect.DoOutput2;
begin
  if system.Assigned(self.FOnOutputLine) then
  self.FOnOutputLine(self,FCurStr,FBlErr);
end;

function TConsoleRedirect.Terminate(AExitCode: Integer): Boolean;
begin
  Result:=False;
  Result:=fpkill(Handle,SIGTERM)=0;
  If Result then
    begin
    If Running then
      Result:=fpkill(Handle,SIGKILL)=0;
    end;
  { the fact that the signal has been sent does not
    mean that the process has already handled the
    signal -> wait instead of calling getexitstatus }
  if Result then
    WaitOnExit;
end;

function TConsoleRedirect.WaitOnExit: Boolean;
var
  R:DWORD;
begin
    if FRunning then
      fexitcode:=waitprocess(handle);
    Result:=(fexitcode>=0);
    FRunning:=False;
end;

function TConsoleRedirect.Run: Boolean;
begin
  self.DoRun;
  self.Resume;
end;

procedure TConsoleRedirect.FreeStreams;
begin
  If FStderrStream<>FOutputStream then
    FreeStream(THandleStream(FStderrStream));
  FreeStream(THandleStream(FOutputStream));
  FreeStream(THandleStream(FInputStream));
end;


function TConsoleRedirect.GetExitStatus: Integer;
begin
  GetRunning;
  Result:=FExitCode;
end;

{$IFNDEF OS_HASEXITCODE}
function TConsoleRedirect.GetExitCode: Integer;
begin
  if Not Running then
    Result:=GetExitStatus
  else
    Result:=0
end;
{$ENDIF}

function TConsoleRedirect.GetRunning: Boolean;
begin
  IF FRunning then
    FRunning:=Not PeekExitStatus;
  Result:=FRunning;

end;


procedure TConsoleRedirect.CreateStreams(InHandle, OutHandle, ErrHandle: Longint);
begin
  FreeStreams;

  FInputStream:=TOutputPipeStream.Create (InHandle);
  FOutputStream:=TInputPipeStream.Create (OutHandle);
  if Not (self.StdErrToOutPut) then
    FStderrStream:=TInputPipeStream.Create(ErrHandle);
end;

procedure TConsoleRedirect.FreeStream(var AStream: THandleStream);
begin
  if AStream = nil then exit;
  FreeAndNil(AStream);
end;

procedure TConsoleRedirect.CloseInput;
begin
  FreeStream(THandleStream(FInputStream));
end;

procedure TConsoleRedirect.CloseOutput;
begin
  FreeStream(THandleStream(FOutputStream));
end;

procedure TConsoleRedirect.CloseStderr;
begin
  FreeStream(THandleStream(FStderrStream));
end;

function TConsoleRedirect.GetWindowRect: TRect;
begin
  With Result do
    begin
      Left:=dwx;
      Right:=dwx+dwxSize;
      Top:=dwy;
      Bottom:=dwy+dwysize;
    end;
end;

procedure TConsoleRedirect.SetCommandLine(const AValue: String);
begin
  if FCommandLine=AValue then exit;
  FCommandLine:=AValue;
    ConvertCommandLine;
end;

procedure TConsoleRedirect.SetExecutable(AValue: String);
begin
  if FExecutable=AValue then Exit;
  FExecutable:=AValue;
  ConvertCommandLine;
end;

procedure TConsoleRedirect.SetWindowRect(Value: TRect);
begin
  With Value do
    begin
    dwx:=Left;
    dwxSize:=Right-Left;
    dwy:=Top;
    dwySize:=Bottom-top;
    end;
end;


procedure TConsoleRedirect.SetApplicationName(const Value: String);
begin
  FApplicationName := Value;
  FCommandLine:=Value;
end;

procedure TConsoleRedirect.ConvertCommandLine;
begin
  FParameters.Clear;
  CommandToList(FCommandLine,FParameters);
  If FParameters.Count>0 then
    begin
    FExecutable:=FParameters[0];
    FParameters.Delete(0);
    end;
end;

function TConsoleRedirect.PeekExitStatus: Boolean;
var
  res: cint;
begin
  repeat
    res:=fpWaitPid(Handle,pcint(@FExitCode),WNOHANG);
  until (res<>-1) or (fpgeterrno<>ESysEINTR);
  result:=res=Handle;
  If Not Result then
    FexitCode:=cardinal(-1); // was 0, better testable for abnormal exit.
end;

procedure TConsoleRedirect.CloseProcessHandles;
begin

end;


end.
