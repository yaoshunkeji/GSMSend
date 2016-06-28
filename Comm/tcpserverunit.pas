unit TCPServerUnit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,strutils ,math,process
  , netdb,sockets,baseunix        //cthreads,cmem 必须在ldr文件最前面引用一下
  ,SockCommUnit
  ;

type
  TTCPServer_ConsoleRedirect=class;

  TConectInfo=packed record
    Sockfd:integer;
    Connfd:integer;
    CliLen:socklen_t;
    CliAddr:sockaddr_in;
  end;

  { TTCPClient }

  TTCPClient = class(TThread)
  private
    ConectInfo:TConectInfo;
    strlst:TStringList;
    msg:TMSGData;

  protected
    procedure Execute;override;
    procedure DoProc;
  public

    constructor Create(aConectInfo:TConectInfo);
    destructor Destroy; override;
  end;

  { TTCPClient_ConsoleRedirect }

  TOnRecvMsg=procedure(var msg:TMSGData;strlst:TStringList) of Object;

  TTCPClient_ConsoleRedirect = class(TThread)
  private
    ConectInfo:TConectInfo;
    strlst:TStringList;
    msg:TMSGData;
    Server:TTCPServer_ConsoleRedirect;
  protected
    procedure Execute;override;
    procedure DoProc;
  public

    constructor Create(aServer:TTCPServer_ConsoleRedirect;aConectInfo:TConectInfo);
    destructor Destroy; override;
  end;

  { TTCPServer_ConsoleRedirect }

  TTCPServer_ConsoleRedirect = class(TThread)
  private
    FDebugOutput: Boolean;
    FOnRecvMsg: TOnRecvMsg;
    sockfd:integer;
    FCmdLine:String;
    FPort:integer;
    FAddr:string;
    FProcess:TProcess;
  protected
    procedure Execute;override;
    function DoStartServer:boolean;virtual;
    function DoRunCMD: Boolean;virtual;
  public
    Error:string;

    property OnRecvMsg:TOnRecvMsg read FOnRecvMsg write FOnRecvMsg;
    property DebugOutput:Boolean read FDebugOutput write FDebugOutput;
    function StartServer:Boolean;virtual;
    procedure Terminate;
    constructor Create(aCmdLine:string='';aPort:integer=7788);
    destructor Destroy; override;
  end;

  { TTCPServer }
  TTCPServer = class(TThread)
  private
    fHost: string;
    fPort: integer;
    sockfd:integer;
  protected
    procedure Execute;override;
    function DoStartServer:boolean;virtual;
  public
    error:string;
    property Host:string read fHost write fhost;
    property Port:integer read fPort write Fport;
    function StartServer:Boolean;
    constructor Create;
    destructor Destroy; override;
  end;


var
  TCPServer:TTCPServer=nil;
  TCPServer_ConsoleRedirect:TTCPServer_ConsoleRedirect=nil;
  ConsoleRedirect_ELFFile:string='';

  ConsoleRedirect_BasePort:integer=7800;

implementation


{ TTCPClient_ConsoleRedirect }

procedure TTCPClient_ConsoleRedirect.Execute;
var
  i:integer;
  c:integer;
  buf:AnsiString;
  e:Boolean;
  function ReadLine(MultiLine:boolean):integer;
  var
    c:integer;
    blCRLF:boolean;
    i:integer;
  begin
    Result:=0;
    blCRLF:=False;
    c:=fprecv(self.ConectInfo.Connfd,@buf[1],length(buf)-1,MSG_PEEK);
    if c<=0 then
    begin
      e:=true;
      exit;
    end;
//    writeln('buffisze='+inttostr(c));
  if MultiLine then
  begin
    for i := 1 to c do
    begin
      if (buf[i] in [#10,#13]) then
      begin
        Result:=i;
        blCRLF:=True;
      end;
    end;
  end
  else
  begin
    for i := c downto 1 do
    begin
      if (buf[i] in [#10,#13]) then
      begin
        Result:=i;
        blCRLF:=True;
      end;
    end;
  end;
//  writeln('buffisze2='+inttostr(Result));
    if Result>0 then
    begin
      c:=Result;
      c:=fprecv(self.ConectInfo.Connfd,@buf[1],c,0);
      if c>0 then
      begin
        if blCRLF then
        begin
          c:=c-1;
        end;
        setlength(buf,c);
        Result:=c;
      end
      else
      begin
        buf:='';
        e:=true;
        c:=0;
      end;
    end;


  end;

begin

  FillByte(msg,sizeof(msg),0);
  msg.MsgType:=ord(mt_log);

  strlst.Clear;
  e:=false;
  i:=0;
  while not self.Terminated do
  begin
    setlength(buf,32*1024);
    FillChar(buf[1],32*1024,#0);
    i:=1;
    while not self.Terminated do
    begin
      if ReadLine(true)=0 then
      system.Break;
      //
      {
      c:=fprecv(self.ConectInfo.Connfd,@buf[i],1,0);
      if (c<=0) then
      begin
        e:=true;
//        system.Break;
      end;
      inc(i);
      if (buf[i-1] in [#10,#13]) or (e) then
      begin
        setlength(buf,i-1);
        strlst.Text:=buf;
        self.Synchronize(DoProc);
        system.Break;
      end;
      }
      strlst.Text:=buf;
      self.Synchronize(DoProc);
      if self.Server.DebugOutput then
      writeln(buf);
//      if e then
//      system.Break;
    end;
    if e then
    system.Break;


  end;




end;

procedure TTCPClient_ConsoleRedirect.DoProc;
begin
  if self=nil then
  exit;
  msg.DataSize:=0;
  try

     if not system.Assigned(self.Server.FOnRecvMsg) then
     exit;
//     Writeln('A');
     self.Server.FOnRecvMsg(msg,strlst);
     //Writeln('B');
  except
  end;
end;

constructor TTCPClient_ConsoleRedirect.Create(aServer:TTCPServer_ConsoleRedirect;aConectInfo: TConectInfo);
begin
  inherited Create(True);
  self.ConectInfo:=aConectInfo;
  self.Server:=aServer;
  self.FreeOnTerminate:=true;
  strlst:=TStringList.Create;
  self.resume;
end;

destructor TTCPClient_ConsoleRedirect.Destroy;
begin
  FpClose(self.ConectInfo.Connfd);
  sysutils.FreeAndNil(strlst);
  inherited Destroy;
end;

{ TTCPServer_ConsoleRedirect }

procedure TTCPServer_ConsoleRedirect.Execute;
var
  s:String;
  clilen:socklen_t;
  cliaddr:sockaddr_in;
  connfd:integer;
  ConectInfo:TConectInfo;
begin
  while not self.Terminated do
  begin
      fillchar(ConectInfo,sizeof(ConectInfo),0);
      clilen := sizeof(cliaddr);
//      writeln('wait fpaccept');
      ConectInfo.Connfd := fpaccept(sockfd,@ConectInfo.CliAddr,@ConectInfo.clilen);
      if(ConectInfo.Connfd = -1) then
      begin
          //perror("accept");
        if self.Terminated then
        exit;
        continue;
      end;
//      writeln('Connfd='+inttostr(ConectInfo.Connfd));
      TTCPClient_ConsoleRedirect.Create(self,ConectInfo);
  end;

end;

function TTCPServer_ConsoleRedirect.DoStartServer: boolean;
const
  BACKLOG=20;
  INET_ADDRSTRLEN=32;
var
  servaddr: sockaddr_in;
  tempaddr:sockaddr_in;
  ip_str:array[0..INET_ADDRSTRLEN-1] of char;
  ret_val:integer;
  templen:TSockLen;
//  addr:ShortString;
//  a,b:File;
  lin:linger;
  opt:integer;
  begin
  Result:=false;
  self.error:='';

  sockfd := fpsocket(AF_INET, SOCK_STREAM, 0);
  if(sockfd = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;

  opt:=1;
  ret_val:=fpsetsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, @opt, sizeof(opt));

  fillchar(lin,sizeof(lin),0);
  lin.l_onoff := 1;
  lin.l_linger := 0;
  ret_val:=fpsetsockopt(sockfd,SOL_SOCKET, SO_LINGER,@lin,sizeof(lin));

  fillchar(servaddr,sizeof(servaddr),0);
  servaddr.sin_family := AF_INET;
  //    servaddr.sin_addr.s_addr := htonl(INADDR_ANY);
  servaddr.sin_addr := StrToNetAddr(FAddr);

  servaddr.sin_port := htons(FPort);

  ret_val := fpbind(sockfd,@servaddr, sizeof(servaddr));
  if(ret_val = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;
  ret_val := fplisten(sockfd,BACKLOG);
  if(ret_val = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;
  Result:=True;
  //pthread_lock;

end;

function TTCPServer_ConsoleRedirect.DoRunCMD: Boolean;
begin
  Result:=false;
  if self.FCmdLine='' then
  begin
    Result:=true;
    exit;
  end;
  if self.FAddr='' then
  self.FAddr:='127.0.0.1';
  if self.FPort<=0 then
  self.FPort:=7788;

  FProcess:=TProcess.Create(nil);
  FProcess.Options:=FProcess.Options+[poNoConsole];

  if ConsoleRedirect_ELFFile<>'' then
  begin

    FProcess.CommandLine:=ConsoleRedirect_ELFFile+ ' /TryInterval 50 /Exec "'+FCmdLine+'" /Dest '+self.FAddr+':'+inttostr(self.FPort);
  end
  else
  begin
    FProcess.CommandLine:='./consoleredirect /TryInterval 50 /Exec "'+FCmdLine+'" /Dest '+self.FAddr+':'+inttostr(self.FPort);
  end;
  writeln(FProcess.CommandLine);
  FProcess.Environment.Add('LANG=en');
  FProcess.Environment.Add('LANGUAGE=en');

  try
  FProcess.Execute;
  except
  end;
  Result:=True;

end;

function TTCPServer_ConsoleRedirect.StartServer: Boolean;
var
  s:String;
begin
  Result:=False;
  if not self.DoStartServer then
  exit;

  if not self.DoRunCMD then
  exit;

  if self.Suspended then
  self.Resume;

  Result:=True;
end;

procedure TTCPServer_ConsoleRedirect.Terminate;
begin
  try
    if self.FProcess<>nil then
    self.FProcess.Terminate(0);
  except
  end;
  try
    if self.FProcess<>nil then
    sysutils.FreeAndNil(self.FProcess);
  except
  end;
  try
    CloseSocket(self.sockfd);
  except
  end;
end;

constructor TTCPServer_ConsoleRedirect.Create(aCmdLine:string='';aPort:integer=7788);
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
  self.FCmdLine:=aCmdLine;
  self.FAddr:='127.0.0.1';
  self.FPort:=aPort;
end;

destructor TTCPServer_ConsoleRedirect.Destroy;
begin
//  if self.FProcess<>nil then
//  self.FProcess.Terminate();

  inherited Destroy;
end;

procedure TTCPClient.DoProc;
begin
  if self=nil then
  exit;
  msg.DataSize:=0;
end;

procedure TTCPClient.Execute;
begin

end;

constructor TTCPClient.Create(aConectInfo: TConectInfo);
begin
  inherited Create(True);
  self.ConectInfo:=aConectInfo;
  self.FreeOnTerminate:=true;
  strlst:=TStringList.Create;
  self.resume;
end;

destructor TTCPClient.Destroy;
begin
  FpClose(self.ConectInfo.Connfd);
  sysutils.FreeAndNil(strlst);

  inherited Destroy;
end;

function TTCPServer.DoStartServer: boolean;
const
  BACKLOG=20;
  INET_ADDRSTRLEN=32;
var
  servaddr: sockaddr_in;
  tempaddr:sockaddr_in;
  ip_str:array[0..INET_ADDRSTRLEN-1] of char;
  ret_val:integer;
  templen:TSockLen;
  addr:ShortString;
  a,b:File;
  lin:linger;
  opt:integer;
begin
  Result:=false;
  self.error:='';

  sockfd := fpsocket(AF_INET, SOCK_STREAM, 0);
  if(sockfd = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;

  opt:=1;
  ret_val:=fpsetsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, @opt, sizeof(opt));

  fillchar(lin,sizeof(lin),0);
  lin.l_onoff := 1;
  lin.l_linger := 0;
  ret_val:=fpsetsockopt(sockfd,SOL_SOCKET, SO_LINGER,@lin,sizeof(lin));

  fillchar(servaddr,sizeof(servaddr),0);
  servaddr.sin_family := AF_INET;
  //    servaddr.sin_addr.s_addr := htonl(INADDR_ANY);
  servaddr.sin_addr := StrToNetAddr(self.fHost);

  servaddr.sin_port := htons(self.fPort);

  ret_val := fpbind(sockfd,@servaddr, sizeof(servaddr));
  if(ret_val = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;
  ret_val := fplisten(sockfd,BACKLOG);
  if(ret_val = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;
  Result:=True;
  //pthread_lock;

end;

function TTCPServer.StartServer: Boolean;
begin
  Result:=False;
  if not self.DoStartServer then
  exit;

  if self.Suspended then
  self.Resume;

  Result:=True;
end;

{ TServer }

procedure TTCPServer.Execute;
var
  s:String;
  clilen:socklen_t;
  cliaddr:sockaddr_in;
  connfd:integer;
  ConectInfo:TConectInfo;
begin
  while not self.Terminated do
  begin
      fillchar(ConectInfo,sizeof(ConectInfo),0);
      clilen := sizeof(cliaddr);
//      writeln('wait fpaccept');
      ConectInfo.Connfd := fpaccept(sockfd,@ConectInfo.CliAddr,@ConectInfo.clilen);
      if(ConectInfo.Connfd = -1) then
      begin
          //perror("accept");
          if self.Terminated then
          exit;
          continue;
      end;
//      writeln('Connfd='+inttostr(ConectInfo.Connfd));
      TTCPClient.Create(ConectInfo);
  end;
end;

constructor TTCPServer.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
  self.fHost:='0.0.0.0';
end;

destructor TTCPServer.Destroy;
begin
  inherited Destroy;
end;

function SendData_h_d(var msg:TMSGData;data:pointer;len:integer;sockcon:Pinteger=nil):Boolean;
var
  l1,l2:integer;
  con:integer;
begin
  con:=-1;

  msg.DataSize:=len;
  l1:=sizeof(TMSGData);
  l2:=len;

  Msg_SetCheck(@msg,data);

  Result:=SendData(@msg,sizeof(msg),@con);
  if not result then
  exit;
  l2:=sockets.fpsend(con,data,len,0);

  Result:=l2<>len;
  if (l2<>len) then
  begin
    fpclose(con);
    Result:=False;
    exit;
  end;
  Result:=true;
  if sockcon<>nil then
  begin
    sockcon^:=con;
  end
  else
  begin
    fpclose(con);
  end;


end;

procedure Init;
var
  fn:string;
  s:String;
begin
  s:='';
  fn:=sysutils.ExtractFilePath(system.ParamStr(0))+'consoleredirect';
  try
  if sysutils.FileExists(fn) then
  begin
    RunCommand('chmod a+sx "'+fn+'"',s);
    ConsoleRedirect_ELFFile:=fn;
  end;
  except
    ConsoleRedirect_ELFFile:='';
  end;
  fn:=sysutils.ExtractFilePath(system.ParamStr(0))+'ConsoleRedirect';
  try
  if sysutils.FileExists(fn) then
  begin
    RunCommand('chmod a+sx "'+fn+'"',s);
    ConsoleRedirect_ELFFile:=fn;
  end;
  except
    ConsoleRedirect_ELFFile:='';
  end;

  fn:=sysutils.ExtractFilePath(system.ParamStr(0))+'/tool/consoleredirect';
  try
  if sysutils.FileExists(fn) then
  begin
    RunCommand('chmod a+sx "'+fn+'"',s);
    ConsoleRedirect_ELFFile:=fn;
  end;
  except
    ConsoleRedirect_ELFFile:='';
  end;

end;

initialization
Init;

finalization



end.

