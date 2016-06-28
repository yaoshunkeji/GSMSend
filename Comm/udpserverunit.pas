unit UDPServerUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil,strutils ,math
  , netdb,sockets,baseunix        //cthreads,cmem 必须在ldr文件最前面引用一下
  ,SockCommUnit
  ;

type
  TConectInfo=packed record
    Sockfd:integer;
    Connfd:integer;
    CliLen:socklen_t;
    CliAddr:sockaddr_in;
  end;

  { TUDPServer }
  TUDPServer = class(TThread)
  private
    FHost: string;
    fPort: integer;
    procedure PError(str: String);

  protected
    RecvBuff:array[0..4096-1] of Byte;
    RecvBuffLen:integer;
    Clienthost:string;
    sockfd:integer;
    servaddr: sockaddr_in;
    procedure Execute;override;
    function DoStartServer:boolean;
    procedure UDPRead(Connfd: integer);virtual;
    procedure OnUDPRead();virtual;
  public
    Error:string;
    property Host:string read FHost write Fhost;
    property Port:integer read fPort write Fport;
    function StartServer:Boolean;
    constructor Create;virtual;
    destructor Destroy; override;
  end;

var
  UDPServer:TUDPServer=nil;

implementation



function TUDPServer.DoStartServer: boolean;
const
  BACKLOG=20;
  INET_ADDRSTRLEN=32;
var
  ip_str:array[0..INET_ADDRSTRLEN-1] of char;
  ret_val:integer;
  templen:TSockLen;
  optval:integer;
begin
  Result:=false;
  self.error:='';

//  sockfd := fpsocket(AF_INET, SOCK_STREAM, 0);
  sockfd := fpsocket(AF_INET, SOCK_DGRAM, 0);
  if(sockfd = -1) then
  begin
    self.error:=sysutils.SysErrorMessage(fpgeterrno);
    exit;
  end;


  optval := 1;
  fpsetsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, @optval , sizeof(int));


  fillchar(servaddr,sizeof(servaddr),0);
  servaddr.sin_family := AF_INET;
  servaddr.sin_addr := StrToNetAddr(self.FHost);
  servaddr.sin_port := htons(self.FPort);

    ret_val := fpbind(sockfd,@servaddr, sizeof(servaddr));
    if(ret_val = -1) then
    begin
      self.error:=sysutils.SysErrorMessage(fpgeterrno);
      exit;
    end;

  {
    ret_val := fplisten(sockfd,BACKLOG);
    if(ret_val = -1) then
    begin
      self.error:=sysutils.SysErrorMessage(fpgeterrno);
      exit;
    end;
  }
  Result:=True;
  //pthread_lock;

end;

function TUDPServer.StartServer: Boolean;
begin
  Result:=False;
  if not self.DoStartServer then
  exit;

  if self.Suspended then
  self.Resume;

  Result:=True;
end;

{ TServer }

procedure TUDPServer.PError(str:String);
begin

end;


procedure TUDPServer.UDPRead(Connfd:integer);
var
  n:integer;
  ClientAddr:sockaddr_in;
  host:THostEntry;
  hostaddr:string;
  l:integer;
const
  clientlen:DWord=sizeof(sockaddr_in);
begin
  FillChar(RecvBuff,sizeof(RecvBuff),0);
  FillChar(ClientAddr,sizeof(ClientAddr),0);
  l:=sizeof(servaddr);

//  n:=fprecvfrom(sockfd,@RecvBuff[0],SizeOf(RecvBuff),0,@ClientAddr,@ClientLen);

  n:=fprecvfrom(sockfd,@RecvBuff[0],SizeOf(RecvBuff),0,@ClientAddr,@ClientLen);
  RecvBuffLen:=n;
  if (n < 0) then
  begin
    PError('ERROR in recvfrom');
    exit;
  end;

//  hostp = gethostbyaddr(@clientaddr.sin_addr.s_addr,sizeof(clientaddr.sin_addr.s_addr), AF_INET);
  if not GetHostByAddr(ClientAddr.sin_addr,host) then
  begin
    PError('ERROR on gethostbyaddr');
//    exit;
  end;


  self.Clienthost:=inet_ntoa(ClientAddr);
  OnUDPRead();

//      printf("server received datagram from %s (%s)\n",
//  	   hostp->h_name, hostaddrp);
//      printf("server received %d/%d bytes: %s\n", strlen(buf), n, buf);



end;

procedure TUDPServer.OnUDPRead;
begin

end;


procedure TUDPServer.Execute;
var
  s:String;
  clilen:socklen_t;
  cliaddr:sockaddr_in;
  connfd:integer;
  ConectInfo:TConectInfo;
begin
  while not self.Terminated do
  begin
      {
      fillchar(ConectInfo,sizeof(ConectInfo),0);
      clilen := sizeof(cliaddr);
//      writeln('wait fpaccept');
      ConectInfo.Connfd := fpaccept(sockfd,@ConectInfo.CliAddr,@ConectInfo.clilen);
      if(ConectInfo.Connfd = -1) then
      begin
          //perror("accept");
          continue;
      end;

      UDPRead(ConectInfo.Connfd);
//      writeln('Connfd='+inttostr(ConectInfo.Connfd));
     // TTCPClient.create(ConectInfo);
     }
    self.UDPRead(self.sockfd);

  end;
end;

constructor TUDPServer.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
  self.FHost:='127.0.0.1';
end;

destructor TUDPServer.Destroy;
begin
  inherited Destroy;
end;


end.

