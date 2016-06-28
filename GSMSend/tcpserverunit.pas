unit TCPServerUnit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,strutils
  , netdb,sockets,baseunix,cthreads,cmem        //cthreads,cmem 必须在ldr文件最前面引用一下
  ,math
  ,ServerComm_Unit,fununit
  ;

type

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

  TTCPClient_ConsoleRedirect = class(TThread)
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

  { TTCPServer_ConsoleRedirect }

  TTCPServer_ConsoleRedirect = class(TThread)
  private
    sockfd:integer;
  protected
    procedure Execute;override;
    function DoStartServer:boolean;
  public
    error:string;
    function StartServer:Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  { TTCPServer }
  TTCPServer = class(TThread)
  private
    sockfd:integer;
  protected
    procedure Execute;override;
    function DoStartServer:boolean;
  public
    error:string;
    function StartServer:Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

function Send_Msg(imei,imsi,tmsi,tel,smsc:string;text:String;Encode:integer;timeout:Integer;smskey:AnsiString=''):Boolean;
function Send_Tick(imei,imsi,tmsi:string):Boolean;

function SendData_h_d(var msg:TMSGData;data:pointer;len:integer;sockcon:Pinteger=nil):Boolean;

function Test_SendSelf(Msgtyp:TMsgType;data:String):boolean;

var
  TCPServer:TTCPServer=nil;
  TCPServer_ConsoleRedirect:TTCPServer_ConsoleRedirect=nil;

implementation

{ TTCPClient }

uses
  mainform_unit,dmunit,pdu_unit,AsyncUpdateThread_Unit;


function SendData_Self(buf:Pointer;len:integer;sockcon:Pinteger=nil):Boolean;
var
  cfd:integer;
  c:integer;
  s_add:sockaddr_in;
  con:integer;
  retA,retB:integer;
  timeout:timeval;
  a:timeval;
begin
  Result:=False;
  cfd:=-1;

  if (sockcon<>nil) then
  begin
  cfd:=sockcon^;

  end;


  s_add.sin_addr.s_addr:=0;

  if cfd<0 then
  begin
    cfd := fpsocket(AF_INET, SOCK_STREAM,0);
    if cfd=-1 then
    exit;
    fillbyte(s_add,sizeof(s_add),0);
    s_add.sin_family:=AF_INET;

    s_add.sin_addr:= StrToNetAddr(ServerAddr_BTS);

    s_add.sin_port:=htons(ServerPort_BTS);
    con:=fpconnect(cfd,@s_add,sizeof(s_add));
    if con=-1 then
    exit;

    timeout.tv_sec:=10;
    timeout.tv_usec:=0;
    retA:=fpsetsockopt(cfd,SOL_SOCKET,SO_SNDTIMEO,@timeout,sizeof(timeout));
    retB:=fpsetsockopt(cfd,SOL_SOCKET,SO_RCVTIMEO,@timeout,sizeof(timeout));

  end;

  c:=fpsend(cfd,buf,len,0);
  if (c=len) then
  begin
    if sockcon=nil then
    fpclose(cfd)
    else
    sockcon^:=cfd;

    Result:=True
  end
  else
  begin
    fpclose(cfd);
    Result:=False;
  end;

end;

function Test_SendSelf(Msgtyp:TMsgType;data:String):boolean;
var
  l1,l2:integer;
  con:integer;
  msg:TMSGData;
begin
  Result:=False;
  fill_msg(@msg);
  msg.MsgType:=ord(Msgtyp);
  con:=-1;
  Result:=SendData_Self(@msg,sizeof(msg),@con);
  if Result then
  begin
    fpsend(con,@data[1],length(data),0);
  end;

  fpclose(con);

end;



function Send_Tick(imei,imsi,tmsi:string):Boolean;
var
  pdu:string;
  strlst:TStringList;
  s:ansiString;
  msg:TMSGData;
  c:integer;
  l:integer;
  i:integer;
begin
  Result:=False;
  strlst:=TStringList.Create;
  strlst.Clear;
  strlst.Delimiter:=',';
  strlst.Add('smsKey='+sysutils.FormatDateTime('yyyyMMddhhnnsszzz',now));
  if length(imei)=15 then
  imei[15]:='0';

  strlst.Add('imei='+imei);
  strlst.Add('imsi='+imsi);
  strlst.Add('TMSI='+tmsi);
  strlst.Add('fun=2');

  s:='';
  for i := 0 to strlst.Count-1 do
  begin
    if s='' then
    s:=strlst.Strings[i]
    else
    s:=s+','+strlst.Strings[i];
  end;
  s:=Trim(s);
  s:=s+#0;
  l:=length(s);

  fill_msg(@msg);
  msg.MsgType:=ord(mt_TickConn);
  msg.DataSize:=length(s);
  c:=0;
  Result:=SendData_h_d(msg,@s[1],l,nil);      //不等客户端返回，由服务端事件通知
  if not Result then
  exit;

end;

function Send_Msg(imei,imsi,tmsi,tel,smsc:string;text:String;Encode:integer;timeout:Integer;smskey:AnsiString):Boolean;
var
  pdu:string;
  strlst:TStringList;
  s:ansiString;
  msg:TMSGData;
  c:integer;
  l:integer;
  i:integer;
begin
  Result:=False;
  pdu:='';

  timeout:=max(timeout,5000);

  if encode in [4,8] then
  begin
    pdu:=pdu_unit.EnCode_PDU(smsc,tel,text,encode);
  end;

  strlst:=TStringList.Create;
  strlst.Clear;
  strlst.Delimiter:=',';
  if smskey='' then
  smskey:=sysutils.FormatDateTime('yyyyMMddhhnnsszzz',now);
  strlst.Add('smsKey='+smskey);
  if length(imei)=15 then
  imei[15]:='0';

  strlst.Add('IMEI='+imei);
  strlst.Add('IMSI='+imsi);
  strlst.Add('TMSI='+tmsi);
  strlst.Add('tel='+tel);
  strlst.Add('encode:'+inttostr(encode));
  strlst.Add('smsc='+smsc);
  strlst.Add('fun=1');
  if FixSmscTimeToLocalTime then
  begin
    strlst.Add('smscTimeOffset='+inttostr(abs(sysutils.GetLocalTimeOffset*60)));
  end
  else
  begin
    strlst.Add('smscTimeOffset=0');
  end;

  if encode in [4,8] then
  begin
    strlst.Add('pdu='+pdu);
  end;
    s:=Text;
    s:=Bin2Hex(@s[1],length(s));
  strlst.Add('textHex='+s);
  if encode=0 then
  begin
    strlst.Add('timeout='+inttostr(timeout));
  end;

  s:='';
  for i := 0 to strlst.Count-1 do
  begin
    if s='' then
    s:=strlst.Strings[i]
    else
    s:=s+','+strlst.Strings[i];
  end;
  s:=Trim(s);
  s:=s+#0;
  fill_msg(@msg);
  msg.MsgType:=ord(mt_SendSms);
  msg.DataSize:=length(s);
  c:=-1;
  Result:=SendData_h_d(msg,@s[1],length(s),@c);
  if not Result then
  exit;

  fpclose(c);

//  if (msg.Res=1) then
  Result:=true;

end;

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
     if not system.Assigned(mainform) then
     exit;
//     Writeln('A');
     mainform.OnRecvMsg(msg,strlst);
     //Writeln('B');
  except
  end;
end;

constructor TTCPClient_ConsoleRedirect.Create(aConectInfo: TConectInfo);
begin
  inherited Create(True);
  self.ConectInfo:=aConectInfo;
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
          continue;
      end;
//      writeln('Connfd='+inttostr(ConectInfo.Connfd));
      TTCPClient_ConsoleRedirect.create(ConectInfo);
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
  servaddr.sin_addr := StrToNetAddr(ServerAddr_APP_Log);

  servaddr.sin_port := htons(ServerPort_APP_Log);

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

function TTCPServer_ConsoleRedirect.StartServer: Boolean;
begin
  Result:=False;
  if not self.DoStartServer then
  exit;

  if self.Suspended then
  self.Resume;

  Result:=True;
end;

constructor TTCPServer_ConsoleRedirect.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
end;

destructor TTCPServer_ConsoleRedirect.Destroy;
begin
  inherited Destroy;
end;

procedure TTCPClient.DoProc;
begin
  if self=nil then
  exit;
  msg.DataSize:=0;
  try
     if not system.Assigned(mainform) then
     exit;
//     Writeln('A');
     mainform.OnRecvMsg(msg,strlst);
     //Writeln('B');
  except
  end;
end;

procedure TTCPClient.Execute;
var
  i:integer;
  c:integer;
  s:string;
  buf:ansiString;
  di:TDeviceInfo;
  pdu:TPDUData;
begin
//fprecv(Reg
  buf:='';
  di:=nil;
  strlst.Clear;
  FillByte(di,sizeof(di),0);
  c:=fprecv(self.ConectInfo.Connfd,@msg,sizeof(msg),0);
  if c<>sizeof(msg) then
  begin
    Writeln('ERROR1');
    exit;
  end;
  if not sysutils.SameText(msg.Flag,MsgFlag) then
  begin
    Writeln('ERROR2');
    exit;
  end;
  if msg.MsgType=5 then
    begin
      beep;
    end;

  if msg.DataSize>0 then
  begin
    setlength(buf,msg.DataSize);
    i:=fprecv(self.ConectInfo.Connfd,@buf[1],msg.DataSize,0);

    if msg.DataSize<i then
    begin
      Writeln('ERROR3');
      exit;
    end;

    if not Msg_CheckRestore(@msg,@buf[1]) then
    begin
      Writeln('ERROR4');
       exit;
    end;
    strlst:=TStringList.Create;
    if TMsgType(msg.MsgType)=mt_log then
    strlst.Text:=buf
    else
    strlst.DelimitedText:=buf;
  //  strlst.SaveToFile('/tmp/a.txt');
  end;


   case TMsgType(msg.MsgType) of
    mt_none   :
        begin

        end;
    mt_log:
        begin
         // self.Synchronize(DoProc);
        end;
    mt_ConnRequest:
        begin
          self.Synchronize(DoProc);
          fpsend(self.ConectInfo.Connfd,@msg,sizeof(msg),0);
        end;
    mt_TickConn:    //BTS端接收
        begin
           //none code
        end;
    mt_SendSms:    //BTS端接收  ,或收到发送的确认消息
        begin
          //send    ,nodecode
         //self.Synchronize(DoProc);
        end;
    mt_Register:
        begin
        //  self.Synchronize(DoProc);
        end;
    mt_UnRegister:
        begin
        //  self.Synchronize(DoProc);
        end;
    mt_RecvSms:
        begin
          pdu:=Decode_PDU(strlst.Values['pdu']);
          if strlst.Values['Tel']='' then
          strlst.Values['Tel']:=trim(pdu.Tel);
          if strlst.Values['SMSC']='' then
          strlst.Values['SMSC']:=trim(pdu.SMSC);

          strlst.Values['EncodeStr']:='7Bit';
          if GetSMSEncodeType(pdu)=SMSEncodeType_7bit then
          begin
            strlst.Values['Text']:=pdu.TextAnsi;
            strlst.Values['EncodeStr']:='7bit';
          end;

          if GetSMSEncodeType(pdu)=SMSEncodeType_8bit then
          begin
            strlst.Values['Text']:=pdu.TextAnsi;
            strlst.Values['EncodeStr']:='8bit';
          end;
          if GetSMSEncodeType(pdu)=SMSEncodeType_UCS2 then
          begin
            strlst.Values['EncodeStr']:='UCS2';
            strlst.Values['Text']:=pdu.Text;
          end;
//          self.Synchronize(DoProc);
//          fpsend(self.ConectInfo.Connfd,@msg,sizeof(msg),0);
        end;
    mt_ConnLost:
        begin
//          self.Synchronize(DoProc);
        end;
    mt_ConnRelease:
        begin
//          self.Synchronize(DoProc);
        end;
    mt_RadioReady:
        begin

        end;
    mt_ProgEnd:
        begin

        end;
    mt_progStart:
        begin
//          self.Synchronize(DoProc);
        end;
    mt_sig:
        begin

        end;
    mt_Conn_Allow:
        begin

        end;
    mt_Conn_deny:
        begin

        end;
  end;

   if TmsgType(Msg.MsgType) in [mt_log, mt_TickConn, mt_SendSms, mt_Register
                                ,mt_UnRegister, mt_RecvSms,  mt_ConnLost,mt_ConnRelease
                                ,mt_RadioReady,mt_ProgEnd, mt_progStart,mt_sig, mt_Conn_Allow, mt_Conn_deny
                                ] then
  begin
    PushAsyncUpdate(msg,strlst);

  end;


  {

  case TMsgType(msg.MsgType) of
    mt_none   :
        begin

        end;
    mt_log  :
        begin
          self.Synchronize(DoProc);
        end;
    mt_ConnRequest:
        begin
          self.Synchronize(DoProc);
          fpsend(self.ConectInfo.Connfd,@msg,sizeof(msg),0);
        end;
    mt_TickConn:    //BTS端接收
        begin
           //none code
        end;
    mt_SendSms:    //BTS端接收  ,或收到发送的确认消息
        begin
          //send    ,nodecode

        end;
    mt_Register:
        begin
          self.Synchronize(DoProc);
        end;
    mt_UnRegister:
        begin
          self.Synchronize(DoProc);
        end;
    mt_RecvSms:
        begin
          pdu:=Decode_PDU(strlst.Values['pdu']);
          if strlst.Values['Tel']='' then
          strlst.Values['Tel']:=trim(pdu.Tel);
          if strlst.Values['SMSC']='' then
          strlst.Values['SMSC']:=trim(pdu.SMSC);

          strlst.Values['EncodeStr']:='7Bit';
          if GetSMSEncodeType(pdu)=SMSEncodeType_8bit then
          begin
            strlst.Values['Text']:=pdu.TextAnsi;
            strlst.Values['EncodeStr']:='8bit';
          end;
          if GetSMSEncodeType(pdu)=SMSEncodeType_UCS2 then
          begin
            strlst.Values['EncodeStr']:='UCS2';
            strlst.Values['Text']:=pdu.Text;
          end;
          self.Synchronize(DoProc);
          fpsend(self.ConectInfo.Connfd,@msg,sizeof(msg),0);
        end;
    mt_ConnLost:
        begin
          self.Synchronize(DoProc);
        end;
    mt_ConnRelease:
        begin
          self.Synchronize(DoProc);
        end;
    mt_RadioReady:
        begin

        end;
    mt_ProgEnd:
        begin

        end;
    mt_progStart:
        begin
          self.Synchronize(DoProc);
        end;
    mt_sig:
        begin

        end;
    mt_Conn_Allow:
        begin

        end;
    mt_Conn_deny:
        begin

        end;
  end;

  }



//  close(self.ConectInfo.Connfd);
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
  servaddr.sin_addr := StrToNetAddr(ServerAddr_APP);

  servaddr.sin_port := htons(ServerPort_APP);

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
          continue;
      end;
//      writeln('Connfd='+inttostr(ConectInfo.Connfd));
      TTCPClient.create(ConectInfo);
  end;
end;

constructor TTCPServer.Create;
begin
  inherited Create(True);
  self.FreeOnTerminate:=true;
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

end.

