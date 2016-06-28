unit BaseNetUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils,math,sockets,strutils,UnixType,baseunix,netdb,iconvenc_dyn
  ,base64;

var
  SendTimeOut:integer=5000;
  ConnTimeOut:integer=5000;
const
  CRLF=#$D#$A;


type
  TURLInfo=packed record
    OrgUrl:string;
    Protocol:String;
    UserName:String;
    PassWord:string;
    Host:string;
    Port:integer;
    Port2:string;
    URL:string;      //域名后面的所有东西 ，包括参数
    fn:string;
    BaseUrl:string; //如果是上传，需要把?后面的数据分享， 这个是?前面的部分
    Param:string;   //参数部分
  end;

  THTTP_HEAD_INFO=packed record
    HTTP_VER:string;
    Respond:integer;
    RespondStr:string;
    Server:string;
    Date:string;
    Content_Type:string;
    Transfer_Encoding:string; //[128];    //=chunked  Content_Length没值
    Content_Length:int64;
    Expires:string;
    X_Via:string;
    Connection:String;
    Cache_Control:string;
    Last_Modified:string;
    ETag:string;
    Accept_Ranges:string;
    CharSet:string;
    X_Powered_By:string;
    Set_Cookie:String;
    Vary:String;

  end;

  TMailInfo=packed record
    Enabled:Boolean;
    Smtp:array[0..256-1] of AnsiChar;
    Pop3:array[0..256-1] of AnsiChar;
    MailId:array[0..256-1] of AnsiChar;
    MailAddr:array[0..256-1] of AnsiChar;
    User:array[0..256-1] of AnsiChar;
    Pass:array[0..256-1] of AnsiChar;
    ToMailId:array[0..256-1] of AnsiChar;
    ToMailAddr:array[0..256-1] of AnsiChar;

//    MailTitle:array[0..256-1] of AnsiChar;
//    boby:string;
  end;

  THostPort=packed record
    Host:string;
    Port:integer;
  end;


function DoConect(Host:string;Port:integer;timeout_ms:integer=5000):integer;overload;

function DoConect(sockfd:integer;address:Psockaddr_in;timeout_ms:integer=5000):integer;overload;
function SendData(buf:Pointer;len:integer;sockcon:Pinteger):Boolean;overload;
function SendData(host:string;Port:integer;buf:Pointer;len:integer;sockcon:Pinteger=nil):Boolean;overload;

function HttpGet(Url:string;strlst:TStrings;RespondLst:TStrings=nil):integer;overload;
function HttpGet(Url:string;SaveFN:String;DownErr_DelFile:Boolean=True;RespondLst:TStrings=nil):integer;overload;
function HttpGet(Url:string;Stream:TStream;RespondLst:TStrings=nil;aMethod:String='GET'):integer;overload;

function HttpPost(Url:string;Stream:TStream;RespondLst:TStrings=nil):integer;overload;


function GetHostPort(addr:string;DefaultPort:integer=0):THostPort;

function AnalysisURL(URL:string;var URLInfo:TURLInfo):Boolean;
function EncodeURL(URLInfo:TURLInfo):string;
function Socket_ReadLine(con:integer;var OutStr:AnsiString;LineEnding:AnsiString=CRLF;TimeOut:integer=-1):integer;
procedure Socket_SetTimeOut(sockfd:integer; SendTimeOut:integer=120000;RecvTimeOut:integer=-1);
procedure Socket_GetTimeOut(sockfd:integer; out SendTimeOut:integer;out RecvTimeOut:integer;out blBlock:boolean);

function strncasecmp(str1,str2:string;n:integer;MatchCase:Boolean=False;blTrim:boolean=false):boolean;
function CutSubStr(src:string;startflag,endflag:String):string;overload;
function GetSubStr(src:string;Separator:String;Index:integer;blsubTrim:Boolean=False;blTrim:Boolean=True):string;overload;

procedure RespondLst2HttpHeadInfo(RespondLst:TStrings;var Info:THTTP_HEAD_INFO);

function gb2312toutf8(Src:AnsiString):AnsiString;
function utf8togb2312(const Src:ansiString):ansiString;

//text/html; charset=UTF-8  获取UTF-8
function HTTP_GetVal_Field(str:string;key:String;var dest:string):boolean;overload;
//str=Transfer-Encoding=chunked     分解
function HTTP_GetVal(str:string;key:String;var dest:string):boolean;overload;
//Str=Transfer-Encoding=chunked     分解
function HTTP_GetVal(str:string;RespondLst:TStrings):boolean;overload;
function del_html_simple(html:String):string;

function Address2Str(address:Psockaddr_in):string;

function Send_Mail(Mailinfo:TMailInfo;Title:string;boby:String;AttachFileList:TStringList=nil):integer;
function GetUserFormMailAddr(Addr:String):string;


var
  User_Agent:String='Mozilla/5.0 (i686)';

const __HTML_Mark:array[0..12-1] of string=(
    '&quot;', '&lt;','&gt;', '&amp;','&nbsp;','&times;','&divide;','&yen;','&euro;','&copy;','reg;\0','&qpos;');

const __HTML_Char:array[0..12-1] of string=(
    '"','>','&','\',' ','*','÷','¥','€','©','®',#39);


const
  Def_MailBody:string='From: "%s"<%s>"'+CRLF
                      +'To:  "%s"<%s>\'+CRLF
                      +'Subject:%s'+CRLF
                      +'MIME-Version:1.0'+CRLF
                      +'Content-Type: text/plain; charset="UTF-8"'+CRLF
                      +'Content-Transfer-Encoding: base64'+CRLF
                      +CRLF
                      +'%s'
                      +CRLF+CRLF+CRLF+'.'+CRLF;

const
  Def_MailInfo:String='IDX:%d'+CRLF
                      +'smtp: %s'+CRLF
                      +'地址: %s'+CRLF
                      +'送给: %s'+CRLF
                      +'用户: %s'+CRLF
                      +'密码: %s'+CRLF
                      +'标题: %s'+CRLF+CRLF;


  Def_SEND_ProtectionInfo:String='邮件信息:'+CRLF
                            +'%s'
                            +CRLF
                            +'IP1: %s'+CRLF
                            +'所在地1: %s'+CRLF
                            +'IP2: %s'+CRLF
                            +'所在地2: %s'+CRLF
                            +CRLF
                            +'CPUID: %s'+CRLF
                            +'网卡: %s'+CRLF
                            +'主板: %s'+CRLF
                            +'硬盘: '+CRLF
                            +'%s'+CRLF
                            +CRLF
                            +'机器码: %s'+CRLF
                            +'注册码: %s'+CRLF
                            +'用户码: %s'+CRLF
                            +'注册状态: %d'+CRLF
                            +'ttyUSB: %d'+CRLF
                            +CRLF
                            +'SoftVer:%s'+CRLF
                            +'Cpu: %s'+CRLF
                            +'Mem: %s'+CRLF;

const
  SmtpDefaultPort:integer=25;


var
  Allow_HTTPGET_Content_Length_No:boolean=False;

var
  DebugMode_SendMail:Boolean=false;


  Mail_EHLO_Flag:string='abcdefg-PC';


type
  pifaddrs=^ifaddrs;
  ifaddrs=packed record
    ifa_next:Pifaddrs;	  // Pointer to the next structure.
    ifa_name:PansiChar;		// Name of this network interface.
    ifa_flags:DWORD;	    // Flags as from SIOCGIFFLAGS ioctl.

    ifa_addr:Psockaddr;	// Network address of this interface.  */
    ifa_netmask:Psockaddr; // Netmask of this interface.  */

     //  At most one of the following two is valid.  If the IFF_BROADCAST
     //  bit is set in `ifa_flags', then `ifa_broadaddr' is valid.  If the
     //  IFF_POINTOPOINT bit is set, then `ifa_dstaddr' is valid.
     //  It is never the case that both these bits are set at once.
    //case integer of
    //0: (ifu_broadaddr:Psockaddr);   //Broadcast address of this interface.
    //1: (ifu_dstaddr:Psockaddr);     //Point-to-point destination address.
    //end;
    ifa_ifu:Psockaddr;
    // These very same macros are defined by <net/if.h> for `struct ifaddr'.
    // So if they are defined already, the existing definitions will be fine.
    ifa_data:Pointer;		// Address-specific data (may be unused).
  end;
//var
//  libc_dll_handle:TLibHandle=0;
//  getifaddrs:function(ifap: pifaddrs): Integer; cdecl; //external 'libc.co' name 'getifaddrs'; {do not localize}
//  freeifaddrs:procedure(ifap: pifaddrs); cdecl; //external 'libc.so' name 'freeifaddrs'; {do not localize}

  function getifaddrs(ifap: pifaddrs): Integer; cdecl; external 'libc.so' name 'getifaddrs'; {do not localize}
  procedure freeifaddrs(ifap: pifaddrs); cdecl; external 'libc.so' name 'freeifaddrs'; {do not localize}


const
   IF_NAMESIZE = 16;

type
   Pif_nameindex = ^_if_nameindex;
   _if_nameindex = record
        if_index : dword;
        if_name : Pchar;
     end;
   P_if_nameindex = ^_if_nameindex;

   Const
     IFF_UP = $1;
     IFF_BROADCAST = $2;
     IFF_DEBUG = $4;
     IFF_LOOPBACK = $8;
     IFF_POINTOPOINT = $10;
     IFF_NOTRAILERS = $20;
     IFF_RUNNING = $40;
     IFF_NOARP = $80;
     IFF_PROMISC = $100;
     IFF_ALLMULTI = $200;
     IFF_MASTER = $400;
     IFF_SLAVE = $800;
     IFF_MULTICAST = $1000;
     IFF_PORTSEL = $2000;
     IFF_AUTOMEDIA = $4000;

type
   Pifaddr = ^ifaddr;
   ifaddr = record
        ifa_addr : sockaddr;
        ifa_ifu : record
            case longint of
               0 : ( ifu_broadaddr : sockaddr );
               1 : ( ifu_dstaddr : sockaddr );
            end;
        ifa_ifp : Pointer; // Piface;
        ifa_next : Pifaddr;
     end;

   Pifmap = ^ifmap;
   ifmap = record
        mem_start : dword;
        mem_end : dword;
        base_addr : word;
        irq : byte;
        dma : byte;
        port : byte;
     end;


const
   IFHWADDRLEN = 6;
   IFNAMSIZ = IF_NAMESIZE;

type
  __caddr_t = pchar;


  Pifreq = ^ifreq;
  ifreq = record
      ifr_ifrn : record
          case longint of
             0 : ( ifrn_name : array[0..(IFNAMSIZ)-1] of char );
          end;
      ifr_ifru : record
          case longint of
             0 : ( ifru_addr : sockaddr );
             1 : ( ifru_dstaddr : sockaddr );
             2 : ( ifru_broadaddr : sockaddr );
             3 : ( ifru_netmask : sockaddr );
             4 : ( ifru_hwaddr : sockaddr );
             5 : ( ifru_flags : smallint );
             6 : ( ifru_ivalue : longint );
             7 : ( ifru_mtu : longint );
             8 : ( ifru_map : ifmap );
             9 : ( ifru_slave : array[0..(IFNAMSIZ)-1] of char );
             10 : ( ifru_newname : array[0..(IFNAMSIZ)-1] of char );
             11 : ( ifru_data : __caddr_t );
          end;
   end;

Type
  TIfNameIndex = _if_nameindex;
  PIfNameIndex = ^TIfNameIndex;

  TIfAddr = ifaddr;
  TIFreq = ifreq;

const
  SIOCGIFHWADDR = $8927;



function Send_Mail_TEST():boolean;

implementation

function HttpPost(Url:string;Stream:TStream;RespondLst:TStrings=nil):integer;overload;
begin


end;

function GetUserFormMailAddr(Addr:String):string;
var
  p:integer;
begin
  Result:='';
  p:=pos('@',Addr);
  if p>0 then
  begin
    Result:=copy(Addr,1,p-1);
  end;
end;

function GetHostPort(addr:string;DefaultPort:integer=0):THostPort;
var
  p:integer;
  s:String;
begin
  Addr:=trim(addr);
  FillChar(Result,sizeof(Result),0);
  p:=pos(':',Addr);
  if (p=1) then
  begin
    exit;
  end;
  if (p>1) then
  begin
    Result.Host:=copy(addr,1,p-1);
    s:=trim(copy(addr,p+1,maxint));
    if sysutils.TryStrToInt(s,Result.Port) then
    begin
      if Result.Port>65535 then
      begin
        Result.Port:=-1;
      end;
    end
    else
    begin
      Result.Port:=DefaultPort;
    end;
  end
  else
  begin
    Result.Host:=Addr;
    Result.Port:=DefaultPort;
  end;


end;


function InitMailInfo_Boby(MailInfo:TMailInfo;Title:String;Boby:string):string;
var
  bobysize:integer;
  aBoby:string;
  aTitle:string;
begin
//   boby:=utf8togb2312(boby);
  aBoby:=EncodeStringBase64(boby);
//  aTitle:=EncodeStringBase64(Title);
  aTitle:=Title;

  Result:=sysutils.Format(Def_MailBody,
      [

        MailInfo.MailId,MailInfo.MailAddr,
        MailInfo.ToMailId,MailInfo.ToMailAddr,
        aTitle,aBoby
      ]);
end;


function Send_Mail_TEST():boolean;
begin


end;

function Send_Mail(Mailinfo:TMailInfo;Title:string;boby:String;AttachFileList:TStringList=nil):integer;
var
  s,s2:String;
  aboby:string;
  b:integer;
  sock:integer;
  hp:THostPort;
//  rbuf:array[0..4096-1] of ansiChar;
  rbuf:String;
  c:integer;
  RepoID:integer;

  AUTH_LOGIN_PLAIN:boolean;
  AUTH_LOGIN_CRAM_MD5:boolean;
  MIME_8BIT:boolean;
  T:integer;
const
  DefRecvTimeOut=8000;

  function GetRepoID:integer;
  var
    s:String;
  begin
    Result:=0;
    s:=GetSubStr(rbuf,' ',0,true);
    if not sysutils.TryStrToInt(s,Result) then
    Result:=0;
    if (Result=0) then
    begin
      if length(rbuf)>=4 then
      begin
        if (rbuf[4]='-') then
        begin
          s:=GetSubStr(rbuf,'-',0,true);
          if not sysutils.TryStrToInt(s,Result) then
          Result:=0;
        end;
      end;

    end;
  end;

  function RecvData(TimeOut:integer=DefRecvTimeOut;TimeOutNoClose:boolean=False):Boolean;
  begin
    RepoID:=0;

    Result:=false;
  //  FillChar(rbuf[0], length(rbuf), 0);
    c:=Socket_ReadLine(sock,rbuf,CRLF,TimeOut);
//    c:=fprecv(sock,@rbuf[0],,MSG_WAITALL);

    if c<=0 then
    begin
      if TimeOut=-1 then
      begin
        if (DebugMode_SendMail) then
        writeln('RECV ERR');
        if not TimeOutNoClose then
        FpClose(sock);
      end;
      exit;
    end;
    if (DebugMode_SendMail) then
      writeln(rbuf);

    if (pos('502 ',rbuf)=1) then
    begin
      FpClose(sock);
      exit;
    end;
   RepoID:=GetRepoID;


    Result:=True;
  end;

  function SendData():Boolean;
  begin
    Result:=false;
    c:=fpsend(sock, @s[1], length(s), 0);
    if c<=0 then
    begin
      if (DebugMode_SendMail) then
      writeln('SEND ERR');

      FpClose(sock);
      exit;
    end;
    if DebugMode_SendMail then
    writeln(s);
    Result:=True;
  end;

  function SendUserOrPass():Boolean;
  begin
    Result:=false;
    s2:=base64.DecodeStringBase64(GetSubStr(rbuf,' ',1));
    s2:=trim(sysutils.LowerCase(s2));
    b:=0;
    if pos('username',s2)>0 then
    begin
      s:=base64.EncodeStringBase64(MailInfo.User)+CRLF;
      if SendData then
      b:=1;
    end
    else
    if pos('password',s2)>0 then
    begin
      s:=base64.EncodeStringBase64(MailInfo.Pass)+CRLF;
      if SendData then
      b:=1;
    end;
    Result:=b=1;
  end;

begin
  Result:=-1;
  sock:=-1;
  b:=0;
  AUTH_LOGIN_PLAIN:=False;
  AUTH_LOGIN_CRAM_MD5:=false;
  MIME_8BIT:=false;

  hp:=GetHostPort(Mailinfo.Smtp,SmtpDefaultPort);
  if (hp.Port=-1) or (hp.Host='') then
  exit;

  aboby:=InitMailInfo_Boby(mailinfo,Title,boby);
  if aboby='' then
  exit;


  sock:=DoConect(hp.Host,hp.Port,150000);
  if sock=-1 then
  exit;

  Socket_SetTimeOut(sock,120000,120000);

  if not RecvData then
  exit;

// EHLO */

s:='EHLO '+Mail_EHLO_Flag+CRLF;
if not SendData then
exit;

if not RecvData then
exit;

if not math.InRange(RepoID,200,299) then
begin
  FpClose(sock);
  exit;
end;


//S: 250 AUTH LOGIN PLAIN CRAM-MD5
//250-AUTH=LOGIN PLAIN    250-AUTH LOGIN PLAIN


T:=DefRecvTimeOut;
while RecvData(T,true) do
begin
  //250-PIPELINING
  //250-AUTH LOGIN PLAIN
  //250-AUTH=LOGIN PLAIN
  //250 LOGIN PLAIN CRAM-MD5
  if rbuf='' then
  system.Break;

  T:=1000;

  if RepoID=250 then
  begin
    delete(rbuf,1,4);
    rbuf:=trim(rbuf);
    s:=copy(rbuf,1,4);
    if not sysutils.SameText('AUTH',s) then
    begin
      system.Continue;
    end;
    delete(rbuf,1,4);
    rbuf:=trim(rbuf);
    if rbuf='' then
    system.Continue;
    if rbuf[1]='=' then
    delete(rbuf,1,1);
    rbuf:=trim(rbuf);
    s:=copy(rbuf,1,5);

    if not sysutils.SameText('LOGIN',s) then
    system.Continue;

    if pos('PLAIN',rbuf)>=1 then
    begin
      AUTH_LOGIN_PLAIN:=true;
    end;
    if pos('CRAM-MD5',rbuf)>=1 then
    begin
      AUTH_LOGIN_CRAM_MD5:=true;
    end;


  end;
end;



//AUTH LOGIN

s:='AUTH LOGIN'+CRLF;
if not SendData then
exit;

if not RecvData then
exit;

if RepoID=0 then
begin
  FpClose(sock);
  exit;
end;

if not math.InRange(RepoID,200,399) then  //334 dXNlcm5hbWU6
begin
  Result:=RepoID;
  FpClose(sock);
  exit;
end;

if not SendUserOrPass then
begin
  exit;
end;

if not RecvData then
begin
  FpClose(sock);
  Result:=RepoID;
  exit;
end;

if not math.InRange(RepoID,200,399) then  //334 dXNlcm5hbWU6
begin
  Result:=RepoID;
  FpClose(sock);
  exit;
end;

if not SendUserOrPass then
exit;

if not RecvData then
exit;

if (pos('failed',rbuf)>0) or (RepoID=535) then
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(rbuf);
    writeln('\033[31m邮箱帐户认证错误！请确认用户名密码是否配置正确\033[0m\n');
  end;
  fpclose(sock);
  exit;
end;


if (pos('successful',rbuf)=0) and (RepoID<>235) then
begin
//ok
//  writeln(s);
//  writeln(rbuf);
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
  end;

  fpclose(sock);
  exit;
end;





// MAIL FROM */

s:=format('MAIL FROM: <%s>',[mailinfo.mailaddr])+CRLF;
if not sendData then
exit;

if not RecvData then
exit;

if (RepoID=553) or (RepoID=501) then
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
    writeln('\033[31m错误：发件人必须和帐号相同，即：这个服务器禁止代发邮件\033[0m\n');
  end;
  fpclose(sock);
  exit;
end;

if ((pos('MI:SPB',rbuf)>0) or (RepoID=554)) and (RepoID<>250) then
begin
  //http://feedback.mail.126.com/antispam/complain.php?user=xxx@163.com
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
    writeln('\033[31m错误：邮箱可能有反垃圾功能，请参考以上信息进行设置\033[0m\n');
  end;
  fpclose(sock);
  exit;
end;

if (RepoID<>250) then
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
  end;
  exit;
end;

// rcpt to 第一个收件人
s:=format('RCPT TO:<%s>',[mailinfo.tomailaddr])+CRLF;
if not SendData() then
exit;

if not RecvData() then
exit;

if (RepoID<>250) then
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
  end;
  fpclose(sock);
  exit;
end;

// DATA email connext ready  */

s:='DATA'+CRLF;
if not SendData() then
exit;

if not RecvData() then
begin
  Result:=RepoID;
  fpclose(sock);
  exit;
end;

if (RepoID>=400) then //354 End data with <CR><LF>.<CR><LF>
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
  end;
  fpclose(sock);
  exit;
end;

// send email connext \r\n.\r\n end*/

s:=aboby+CRLF+'.'+CRLF;


if not SendData() then
exit;

if not RecvData() then
begin
  Result:=RepoID;
  fpclose(sock);
  exit;
end;

if (RepoID<>250) then
begin
  Result:=RepoID;
  if DebugMode_SendMail then
  begin
    writeln(s);
    writeln(rbuf);
  end;
  fpclose(sock);
  exit;
end;


if pos('queued as',rbuf)>0 then
begin
//  if (DebugMode_SendMail) then
//      writeln('邮件排队中(服务器上)');
end;
Result:=RepoID;

// QUIT */

s:='QUIT'+CRLF;
SendData();
RecvData();
fpclose(sock);

end;

procedure Socket_GetTimeOut(sockfd:integer; out SendTimeOut:integer;out RecvTimeOut:integer;out blBlock:boolean);
var
  tv:TTimeVal;
  flags:integer;
  BLOCK:integer;

begin

  SendTimeOut:=-1;
  RecvTimeOut:=-1;
  blBlock:=true;

  flags := fpfcntl( sockfd, F_GETFL, 0 );
  BLOCK :=  ( flags and O_NONBLOCK );
  blBLOCK:=BLOCK<>0;
  fillchar(tv,sizeof(tv),0);
  if( fpsetsockopt( sockfd, SOL_SOCKET, SO_SNDTIMEO, @tv,sizeof(tv)) < 0 ) then
  begin
    SendTimeOut:=tv.tv_sec*1000+(tv.tv_usec div 1000);
  end;
  fillchar(tv,sizeof(tv),0);
  if( fpsetsockopt( sockfd, SOL_SOCKET, SO_RCVTIMEO, @tv,sizeof(tv)) < 0 ) then
    begin
      SendTimeOut:=tv.tv_sec*1000+(tv.tv_usec div 1000);
    end;

end;

procedure Socket_SetTimeOut(sockfd:integer; SendTimeOut:integer=120000;RecvTimeOut:integer=-1);
var
  r:integer;
  tv:TTimeVal;
  flags:integer;
  blBLOCK:integer;
begin
  flags := fpfcntl( sockfd, F_GETFL, 0 );
  blBLOCK :=  ( flags and O_NONBLOCK );

  if (SendTimeOut=-1) and (RecvTimeOut=-1) then
  begin
    fpfcntl( sockfd, F_SETFL, flags and (not O_NONBLOCK));
    exit;
  end;


  fpfcntl( sockfd,F_SETFL,flags and (O_NONBLOCK) );

  if (RecvTimeOut=-1) then
  begin
    tv.tv_sec := MaxLongInt;
    tv.tv_usec := 0;
  end
  else
  begin
    tv.tv_sec := SendTimeOut div 1000;
    tv.tv_usec := (SendTimeOut mod 1000)*1000;
  end;

  if( fpsetsockopt( sockfd, SOL_SOCKET, SO_SNDTIMEO, @tv,sizeof(tv)) < 0 ) then
    begin
//      if (PrintSendErr) then
//        printf( "setsockopt failed\n" );
    end;

  if (RecvTimeOut=-1) then
  begin
    tv.tv_sec := MaxLongInt;
    tv.tv_usec := 0;
  end
  else
  begin
    tv.tv_sec := RecvTimeOut div 1000;
    tv.tv_usec := (RecvTimeOut mod 1000)*1000;
  end;

  if fpsetsockopt( sockfd, SOL_SOCKET, SO_RCVTIMEO, @tv,sizeof(tv)) < 0  then
    begin
//      if( PrintSendErr ) then
//        printf( "setsockopt failed\n" );
    end;

end;

procedure RespondLst2HttpHeadInfo(RespondLst:TStrings;var Info:THTTP_HEAD_INFO);
var
  s:string;
begin
  fillchar(info,sizeof(info),0);
  info.Accept_Ranges:=RespondLst.Values['Accept_Ranges'];
  info.HTTP_VER:=RespondLst.Values['HTTP_VER'];
  s:=RespondLst.Values['Respond'];
  if not sysutils.TryStrToInt(s,info.Respond) then
  info.Respond:=0;

  info.RespondStr:=RespondLst.Values['RespondStr'];

  info.Server:=RespondLst.Values['Server'];

  info.Date:=RespondLst.Values['Date'];
  info.Content_Type:=RespondLst.Values['Content-Type'];

  info.Transfer_Encoding:=RespondLst.Values['Transfer-Encoding'];

  info.Expires:=RespondLst.Values['Expires'];
  info.X_Via:=RespondLst.Values['X-Via'];

  info.Connection:=RespondLst.Values['Connection'];

  info.Cache_Control:=RespondLst.Values['Cache-Control'];

  info.Last_Modified:=RespondLst.Values['Last-Modified'];
  info.ETag:=RespondLst.Values['ETag'];

  info.Accept_Ranges:=RespondLst.Values['Accept_Ranges'];

  info.charset:=RespondLst.Values['CharSet'];
  info.X_Powered_By:=RespondLst.Values['X_Powered_By'];
  info.Set_Cookie:=RespondLst.Values['Set-Cookie'];
  if trim(info.charset)='' then
  begin
    HTTP_GetVal_Field(info.Content_Type,'charset',info.CharSet);
  end;
  info.Vary:=RespondLst.Values['Vary'];


end;

function strncasecmp(str1,str2:string;n:integer;MatchCase:Boolean=False;blTrim:boolean=false):boolean;
var
  i:integer;
  s1,s2:string;
begin
Result:=false;
  if length(str1)<n then
  exit;
  if length(str2)<n then
  exit;
  s1:=copy(str1,1,n);
  s2:=copy(str2,1,n);
  if blTrim then
  begin
    s1:=trim(s1);
    s2:=trim(s2);
  end;
  if not MatchCase then
  result:=sysutils.SameText(s1,s2)
  else
  result:=s1=s2;
end;

function EncodeURL(URLInfo:TURLInfo):string;
begin
  Result:='';
  Result:=urlinfo.Protocol;
  if (urlinfo.UserName<>'') and (urlinfo.PassWord<>'') then
  begin
    Result:=Result+urlinfo.UserName+':'+urlinfo.PassWord+'@';
  end
  else
  if (urlinfo.UserName<>'') and (urlinfo.PassWord='') then
  begin
    Result:=Result+urlinfo.UserName+':@';
  end;
    Result:=Result+urlinfo.Host;
    if urlinfo.Port2<>'' then
    Result:=Result+':'+urlinfo.Port2;

    Result:=Result+urlinfo.URL;
end;

//  Analysis('http://aaa:bbb@127.0.0.1/aaaa/aaa.pas',urlinfo);
//  Analysis('http://aaa@127.0.0.1/aaaa/aaa.pas',urlinfo);
//  Analysis('http://aaa@127.0.0.1',urlinfo);
//  Analysis('http://127.0.0.1:11',urlinfo);
//  Analysis('http://127.0.0.1:11/',urlinfo);
function AnalysisURL(URL:string;var URLInfo:TURLInfo):Boolean;
var
  p1,p2:integer;
  s,s2:String;
begin
  Result:=false;
  URLInfo.UserName:='';
  URLInfo.PassWord:='';
  URLInfo.Host:='';
  URLInfo.Port:=0;
  URLInfo.Port2:='';
  URLInfo.Protocol:='';
  URLInfo.URL:='';
  URLInfo.FN:='';
  URLInfo.OrgUrl:=URL;
  URLInfo.BaseUrl:='';
  URLInfo.Param:='';
//  fillchar(URLInfo,sizeof(URLInfo),0);
//http://xxx.www.163.com:/aaaa/aaaa';
  p1:=pos('://',url);
  if p1>0 then
  begin
//    urlinfo.Protocol:=;
    urlinfo.Protocol:=copy(url,1,p1+2);
    delete(url,1,p1+2);
  end;
  if sysutils.SameText(urlinfo.Protocol,'http://') then
  begin
    urlinfo.Port:=80;
  end;
  if sysutils.SameText(urlinfo.Protocol,'https://') then
  begin
    urlinfo.Port:=433;
  end;
  if sysutils.SameText(urlinfo.Protocol,'ftp://') then
  begin
    urlinfo.Port:=21;
  end;
  if sysutils.SameText(urlinfo.Protocol,'SOCKS5://') or sysutils.SameText(urlinfo.Protocol,'SOCKS4://') or sysutils.SameText(urlinfo.Protocol,'SOCKS4a://') then
  begin
    urlinfo.Port:=1080;
  end;
  if sysutils.SameText(urlinfo.Protocol,'ssh://') then
  begin
    urlinfo.Port:=22;
  end;
  if sysutils.SameText(urlinfo.Protocol,'telnet://') then
  begin
    urlinfo.Port:=23;
  end;
  if sysutils.SameText(urlinfo.Protocol,'vnc://') then
  begin
    urlinfo.Port:=5900;
  end;
  if sysutils.SameText(urlinfo.Protocol,'rdp://') then
  begin
    urlinfo.Port:=3389;
  end;

  p1:=pos('@',url);
  p2:=pos('/',url);
  s:='';
  if ((p2>p1) and (p1>1) and  (p1<>0)) or ((p2=0) and (p1<>0))  then
  begin
    if p2=0 then
    s:=url
    else
    s:=copy(url,1,p2-1);
    delete(url,1,p1);
    p2:=pos(':',s);
    if p2=0 then
    begin
      urlinfo.UserName:=copy(s,1,p1-1);;
      urlinfo.PassWord:='';
    end
    else
    begin
      urlinfo.UserName:=copy(s,1,p2-1);
      urlinfo.PassWord:=copy(s,p2+1,p1-p2-1);
    end;
  end;
  p1:=pos('/',url);
  if p1=0 then
  begin
    p1:=pos(':',URL);
    if p1=0 then
    begin
      urlinfo.Host:=url;
      urlinfo.URL:='/';
    end
    else
    begin
      urlinfo.Host:=copy(url,1,p1-1);
      s:=copy(url,p1+1,maxint);
      if not sysutils.TryStrToInt(s,urlinfo.Port) then
      exit;
      if (urlinfo.Port>=65535) or (urlinfo.Port<=0) then
      exit;
      urlinfo.Port2:=inttostr(urlinfo.Port);
      urlinfo.URL:='/';
    end;
    Result:=true;
    exit;
  end;
  s:=copy(url,1,p1-1);
  delete(url,1,p1-1);
  p2:=pos(':',s);
  if p2>0 then
  begin
    s2:=copy(s,p2+1,maxint);
    delete(s,p2,length(s2)+1);
    if not sysutils.TryStrToInt(s2,urlinfo.Port) then
    exit;
    if (urlinfo.Port>=65535) or (urlinfo.Port<=0) then
    exit;
    urlinfo.Port2:=inttostr(urlinfo.Port);
  end;

  urlinfo.Host:=s;
  if URL='' then
  URL:=URL;
  URL:=AnsiReplaceStr(URL,'//','/');
  URL:=AnsiReplaceStr(URL,'//','/');
  URL:=AnsiReplaceStr(URL,'//','/');

  urlinfo.URL:=URL;
  urlinfo.BaseUrl:=URL;
  p1:=pos('?',URL);
  if p1>0 then
  begin
    urlinfo.Param:=copy(urlinfo.BaseUrl,p1+1,maxint);
    setlength(urlinfo.BaseUrl,p1-1);
  end
  else
  begin
    urlinfo.BaseUrl:=url;
    urlinfo.Param:='';
  end;

  urlinfo.FN:=sysutils.ExtractFileName(urlinfo.BaseUrl);
  Result:=true;
end;

function HttpGet(Url:string;strlst:TStrings;RespondLst:TStrings=nil):integer;overload;
var
  mem:TMemoryStream;
begin
  mem:=TMemoryStream.Create;;
  Result:=HttpGet(url,mem);
  if math.InRange(Result,200,299) then
  strlst.LoadFromStream(mem);
  sysutils.FreeAndNil(mem);
end;

function HttpGet(Url:string;SaveFN:String;DownErr_DelFile:Boolean;RespondLst:TStrings=nil):integer;overload;
var
  f:TFileStream;
  E:Boolean;
begin
  E:=False;
  F:=nil;
  try
    f:=TFileStream.Create(SaveFN,fmCreate);
    Result:=HttpGet(Url,f,RespondLst);

    if not math.InRange(Result,200,299) then
    begin
      E:=True;
    end;
  except
    E:=True;
  end;
  if F<>nil then
  sysutils.freeandnil(f);
  if DownErr_DelFile  and E then
  begin
    deletefile(SaveFN);
  end;
end;

function memcmp(p1:PByte;p2:PByte;len:integer):boolean;
var
  i:integer;
begin
  Result:=false;
  for i := 0 to len-1 do
  begin
    if p1^<>p2^ then
    exit;
  end;
  Result:=true;
end;

function Socket_ReadLine(con:integer;var OutStr:AnsiString;LineEnding:AnsiString=CRLF;TimeOut:integer=-1):integer;
var
  buff:array[0..4096-1] of char;
  c,i,j,k:integer;
  l2:integer;

  st,rt:integer;
  b:boolean;
  flags:integer;
  Buff2:ansistring;
begin
Result:=-1;
FillChar(buff[0],length(buff),0);
l2:=length(LineEnding);
OutStr:='';
j:=0;

k:=length(LineEnding);
setlength(Buff2,k);

if TimeOut<>-1 then
begin
  Socket_GetTimeOut(con,st,rt,b);
  Socket_SetTimeOut(con,-1,TimeOut);

  flags := fpfcntl( con, F_GETFL, 0 );
  flags :=  ( flags and O_NONBLOCK );
  fpfcntl( con, F_SETFL, flags);
end;

while True do
begin
  c:=fprecv(con,@buff[0],4096,MSG_PEEK);
  if c<0 then
  exit;

  if c>l2 then
  begin
    for i := j to c-l2 do
    begin
      if memcmp(PByte(@buff[i]),pByte(@LineEnding[1]),l2) then
      begin
        try
        setlength(OutStr,i);
        except
          writeln(i);
        end;

        if i=0 then
        begin
          c:=fprecv(con,@buff2[1],l2,0);
          Result:=0;
          exit;
        end;

        try
        c:=fprecv(con,@OutStr[1],i,0);
        //writeln(outstr);
        if OutStr='Connection: close' then
        sleep(0);
        except
          writeln(i);
        end;
        try
        fprecv(con,@buff[0],l2,0);
        except
          writeln(buff);
        end;
        Result:=c;
        exit;
      end;
    end;
    j:=c-l2;    //减少比较量
  end;
  Sleep(1);
end;

  if TimeOut<>-1 then
  begin
    flags := fpfcntl( con, F_GETFL, 0 );
    if b then
    begin
      flags :=  ( flags and (not O_NONBLOCK ));
    end
    else
    begin
      flags :=  ( flags and (O_NONBLOCK ));
    end;
    fpfcntl( con, F_SETFL, flags);
  end;

end;

//text/html; charset=UTF-8  获取UTF-8
function HTTP_GetVal_Field(str:string;key:String;var dest:string):boolean;overload;
var
  p:integer;
  s1,s2:string;
begin
  Result:=False;
  dest:='';
//  str:='text/html; charset=UTF-8;adad=ada;';
  while str<>'' do
  begin
    str:=TrimLeft(str);
    if length(str)<length(key)+1 then
    exit;

    s1:=copy(str,1,length(key));
    if sysutils.SameText(s1,key) then
    begin
      s1:=copy(str,length(key)+1,maxint);
      s1:=trimleft(s1);
      if s1='' then
      exit;
      if s1[1]='=' then
      begin
        p:=pos(';',s1);
        if p=0 then
        begin
          dest:=trim(copy(s1,2,maxint));
          result:=true;
          exit;
        end
        else
        begin
          dest:=trim(copy(s1,2,p-2));
          result:=true;
          exit;
        end;
      end;
    end;

    p:=pos(';',str);
    if p=0 then
    exit;
    delete(str,1,p+1);
    str:=trim(str);


  end;



end;

function HTTP_GetVal(str:string;key:String;var dest:string):boolean;overload;
var
  p1:integer;
begin
Result:=false;
dest:='';
  if strncasecmp(str,key,length(key)) then
  begin
    p1:=pos(':',str);
    if p1>1 then
    begin
      delete(str,1,p1+1);
    end;
    dest:=copy(str,1,maxint);
    dest:=TrimLeft(dest);
    Result:=true;
  end;
end;

function HTTP_GetVal(str:string;RespondLst:TStrings):boolean;overload;
var
  p1:integer;
  s1,s2:String;
begin
  Result:=false;
  p1:=pos(':',str);
  if p1<=1 then
  exit;
  s1:=copy(str,1,p1-1);
  s2:=copy(str,p1+1,maxint);
  s2:=trimLeft(s2);
  if RespondLst<>nil then
  RespondLst.Add(s1+'='+s2);
  Result:=true;
end;

function GetSubStr(src:string;Separator:String;Index:integer;blsubTrim:Boolean=False;blTrim:Boolean=True):string;overload;
var
  i:integer;
  l:integer;
  buf,buf2:PChar;
  p1,p2:integer;
  idx:integer;
  lastpos:integer;
  c:integer;
  function FindNoSpace:integer;
  var
    j:integer;
  begin
    Result:=0;
    for j := i to l do
    begin
      if src[j] in [' '] then
      begin
        inc(Result);
      end
      else
      begin
        system.Break;
      end;
    end;

  end;

begin
  Result:='';
  if (Separator='') then
  begin
    //以后，改成返回第几行？
    exit;
  end;
  idx:=0;

  if blsubTrim then
  begin
    src:=trim(src);
  end;

  l:=length(src);
  buf:=@src[1];
  lastpos:=1;
  idx:=0;

  i:=1;
  while i<=l do
  begin
    p1:=pos(Separator,buf);
    if idx=Index then
    begin
      if p1>0 then
      begin
        result:=copy(src,lastpos,p1-1);
      end
      else
      begin
        result:=copy(src,lastpos,maxint);
      end;
      system.Break;

    end;
    if p1=0 then
    system.Break;

    lastpos:=i+p1+length(Separator)-1;

    inc(buf,p1+length(Separator)-1);
    inc(i,p1+length(Separator)-1);



    if blsubTrim then
    begin
      c:=FindNoSpace;
      inc(buf,c);
      inc(i,c);
      inc(lastpos,c);
    end;

    inc(idx);
  end;


  if blTrim then
  result:=Trim(Result);

end;

function CutSubStr(src:string;startflag,endflag:String):string;
var
  r,l:integer;
  p1,p2:integer;
begin
  result:='';
  if (startflag<>'') then
    begin
      p1:=pos(startflag,src);
    end
    else
    begin
      p1:=1;
    end;

  if (p1=0) then
  exit;

  if (p1>1) then
  delete(src,1,p1+length(startflag)-1);

  p1:=1;

  if (endflag<>'') then
    begin
      p2:=pos(endflag,src);
      if p2=0 then
      exit;
      p2:=p2-1;
    end
    else
    begin
      p2:=length(src);
    end;
  Result:=copy(src,1,p2);
end;



function HttpGet(Url:string;Stream:TStream;RespondLst:TStrings=nil;aMethod:String='GET'):integer;overload;
var
  urlinfo:TURLInfo;
  con:integer;
  s,s1:string;
  r:integer;
  Content_Length:int64;
  Content_Length2:int64;
  Content_Length_Error:Boolean;
  buff:array[0..64*1024-1] of AnsiChar;
  buff2:array[0..64*1024-1] of Byte;
  l,len,len2:integer;
  p1,p2:integer;
  blhttp:boolean;
  RespondCode:integer;
  length_Chunked:boolean;
  c:integer;
  Method:string;
  e:boolean;
  function DownData(Datalen:integer):integer;
  var
    len,len2:integer;
  begin
    Result:=0;
    while (Datalen>0) or (Content_Length_Error) do
    begin
      len:=Datalen;
      len:=min(len,sizeof(buff));
      len2:=fprecv(con,@buff[0],len,MSG_WAITALL);
      if len2<>len then
      begin
//        writeln('fprecv('+inttostr(len)+')='+inttostr(len2)+',URL='+urlinfo.OrgUrl+' error:'+sysutils.SysErrorMessage(socketerror));

        Result:=-1;
        system.Break;
      end;
      Datalen:=Datalen-len2;
      Stream.Write(buff[0],len2);
      Result:=Result+len2;
    end;
  end;

begin
  Result:=-1;
  RespondCode:=-1;
  blhttp:=false;
  length_Chunked:=false;
  fillchar(urlinfo,sizeof(urlinfo),0);
  if not AnalysisURL(URL,urlinfo) then
  exit;

  Method:=trim(sysutils.UpperCase(aMethod));
  if Method='' then
  Method:='GET';

//  writeln('1 '+urlinfo.Host);
  con:=DoConect(urlinfo.Host,urlinfo.Port,10000);
//  writeln('2');
//  writeln({$i %FILE%}+':'+{$i %LINE%});
//  writeln(urlinfo.Host+':'+inttostr(urlinfo.Port));
  if con=-1 then
  begin
//    writeln('conect '+urlinfo.Host+' error: '+sysutils.SysErrorMessage(socketerror));
    exit;
  end;
  Socket_SetTimeOut(con,120000,120000);
//  Socket_SetTimeOut(con,-1,-1);
//writeln({$i %FILE%}+':'+{$i %LINE%});
//writeln(con);
  while true do
  begin

  fillchar(buff[0],sizeof(buff),#0);
  if Method='POST' then
    s:=Method+' '+urlinfo.BaseUrl+' HTTP/1.1'+CRLF
    else
    s:=Method+' '+urlinfo.URL+' HTTP/1.1'+CRLF;
//  writeln(con);
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  begin
//    writeln('ada');
    system.Break;
  end;

//  writeln('3');
  s:='Host: '+urlinfo.Host+CRLF;
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  system.Break;
  s:='Connection: Close'+CRLF;
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  system.Break;
  s:='User-Agent: '+User_Agent+CRLF;
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  system.Break;
  s:='Accept: text/html,application/xhtml+xml,application/xml'+CRLF;
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  system.Break;

  s:='Accept-Language: zh-CN,en'+CRLF;
  if fpsend(con,@s[1],length(s),0)<>length(s) then
  system.Break;

  s:='';

  if Method='POST' then
  begin
    s:='Content-Transfer-Encoding: 8bit';
    if fpsend(con,@s[1],length(s),0)<>length(s) then
    system.Break;

    if urlinfo.Param<>'' then
    begin
      s:='Content-Length: '+inttostr(length(urlinfo.Param));
      if fpsend(con,@s[1],length(s),0)<>length(s) then
      system.Break;
      s:='Content-Type: application/x-www-form-urlencoded';
    end
    else if Stream.Size>0 then
    begin
        s:='Content-Length: '+inttostr(Stream.Size);
        if fpsend(con,@s[1],length(s),0)<>length(s) then
        system.Break;
//        s:='Content-Type: application/x-www-form-urlencoded';
    end;
  end;

  s:=CRLF;

  l:=fpsend(con,@s[1],length(s),0);
  if l<>length(s) then
  system.Break;

  if (Method='POST') then
  begin
    if urlinfo.Param<>'' then
    begin
      s:=urlinfo.Param;
      if fpsend(con,@s[1],length(s),0)<>length(s) then
      system.Break;
    end
    else
    begin
      if Stream.Size>0 then
      begin
        Stream.Position:=0;
        len2:=length(buff2);
        e:=false;
        while Stream.Position<Stream.Size do
        begin
          len:=Stream.Read(buff2[0],len2);
          if len=0 then
          system.Break;
          if fpsend(con,@buff2[1],len,0)<>len then
          begin
            e:=true;
            system.Break;
          end;

        end;
        Stream.Position:=0;
        if e then
        system.Break;
      end;
    end;
  end;

  Content_Length:=-1;
  Content_Length2:=0;
  length_Chunked:=false;
  Content_Length_Error:=false;
  while true do
  begin
    r:=Socket_ReadLine(con,s,CRLF);
    if r=-1 then
    begin
//      writeln('Socket_ReadLine,URL='+urlinfo.OrgUrl+' error:'+sysutils.SysErrorMessage(socketerror));
      exit;
    end;

    if s='' then
    system.Break;

    if not blhttp then
    begin
      if s='' then
      system.break;

      if pos('HTTP/',s)<>1 then
      begin
        system.break;
      end;    //HTTP/1.1 200 OK

      p1:=pos(' ',s);
      if p1=0 then
      system.break;

      if RespondLst<>nil then
      RespondLst.Add('HTTP_VER='+copy(s,1,p1-1));

      delete(s,1,p1);
      p1:=pos(' ',s);
      if p1=0 then
      begin
        system.Break;
      end;
      s1:=copy(s,1,p1-1);
      if not sysutils.TryStrToInt(s1,result) then
      system.break;

      RespondCode:=Result;

      p1:=pos(' ',s);

      if RespondLst<>nil then
      RespondLst.Add('RespondStr='+copy(s,p1+1,maxint));

      blhttp:=true;
      system.Continue;
    end;

    HTTP_GetVal(s,RespondLst);

    if HTTP_GetVal(s,'Content-Type',s1) then    //chartset
    begin
      Continue;
    end;
    if HTTP_GetVal(s,'Content-Length',s1) then
    begin
      if not sysutils.TryStrToInt64(s1,Content_Length) then
      system.Break;
      Continue;
    end;
    if HTTP_GetVal(s,'Transfer-Encoding',s1) then
    begin
      length_Chunked:=length_Chunked or sysutils.SameText(s1,'chunked');
    end;
  end;

  if (not blhttp) then
  begin
    fpclose(con);
    exit;
  end;

//  RespondLst.SaveToFile('/tmp/c.txt');
  if length_Chunked then
  begin
    c:=0;       //结束时，正常是2个换行，多个就退
    while true do
    begin
      r:=Socket_ReadLine(con,s,CRLF);
      if (r=-1) then
      begin
        result:=-1;
        system.Break;
      end;
      if (s='') then
      begin
        inc(c);
        if c>=2 then
        begin
          Result:=-1;
          system.Break;
        end
        else
        begin
          system.Continue;
        end;
      end;
      s:='0x'+s;
      if not sysutils.TryStrToInt(s,len) then
      begin
        result:=-1;
        system.Break;
      end;
      c:=0;
      if len=0 then
      begin
//        beep;
        system.Break;   //正常0后面两个换行的，没细调，单个0就退
      end;
     len2:=DownData(Len);
     if len2<>len then
     begin
       result:=-1;
       system.Break;
     end;
     r:=Socket_ReadLine(con,s,CRLF);
     if (r=-1) or (s<>'') then
     begin
       result:=-1;
       system.Break;
     end;

    end;

  end
  else
  begin

    if (not blhttp) then
    begin
      fpclose(con);
      exit;
    end;
    if (Content_Length=-1) then
    begin
      if not Allow_HTTPGET_Content_Length_No then
      begin
        fpclose(con);
        exit;
      end;
      Content_Length_Error:=true;

    end;

    len:=DownData(Content_Length);
    if len<>Content_Length then
    begin
      Result:=-1;
    end;

  end;
  break;
end;
//  writeln('111');
  FpClose(con);


end;

function DoConect(Host:string;Port:integer;timeout_ms:integer=5000):integer;overload;
var
  r:integer;
  fdset:TFDSet;
  tv:TTimeVal;
  flags:integer;
  blBLOCK:integer;
  so_error:integer;
  len:socklen_t;
  s_add:sockaddr_in;
  h:THostEntry;
  cfd:integer;
  con:integer;
begin
  Result:=-1;
  FillChar(h,sizeof(h),0);
//  writeln({$i %FILE%}+':'+{$i %LINE%});
  if not ResolveHostByName(Host,H) then
  begin
    writeln(sysutils.SysErrorMessage(socketerror));
    exit;
  end;

//  writeln(inttostr(h.Addr.s_bytes[1])+'.'+inttostr(h.Addr.s_bytes[2])+'.'+inttostr(h.Addr.s_bytes[3])+'.'+inttostr(h.Addr.s_bytes[4]));
//writeln({$i %FILE%}+':'+{$i %LINE%});
  cfd := fpsocket(AF_INET, SOCK_STREAM,0);
  if cfd=-1 then
  begin
    writeln({$i %FILE%}+':'+{$i %LINE%});
    exit;
  end;
  fillbyte(s_add,sizeof(s_add),0);
  s_add.sin_family:=AF_INET;

  s_add.sin_addr:= h.Addr;

  s_add.sin_port:=htons(port);
  con:=DoConect(cfd,@s_add,timeout_ms);
  if con=-1 then
  exit;
//  writeln({$i %FILE%}+':'+{$i %LINE%});
//  tv.tv_sec:=10;
//  tv.tv_usec:=0;
//  retA:=fpsetsockopt(cfd,SOL_SOCKET,SO_SNDTIMEO,@timeout,sizeof(timeout));
//  retB:=fpsetsockopt(cfd,SOL_SOCKET,SO_RCVTIMEO,@timeout,sizeof(timeout));
  Result:=cfd;

end;


//
//网络不正常时(ping不通，但可能查到ip)，发送，会程序崩溃
//

function Address2Str(address:Psockaddr_in):string;
begin
  Result:=sysutils.Format('%d.%d.%d.%d',[address^.sin_addr.s_bytes[1],address^.sin_addr.s_bytes[2],address^.sin_addr.s_bytes[3],address^.sin_addr.s_bytes[4]]);

  Result:=Result+':'+inttostr(sockets.htons(address^.sin_port));

end;

function DoConect(sockfd:integer;address:Psockaddr_in;timeout_ms:integer=5000):integer;
var
  r,r2:integer;
  fdset:TFDSet;
  tv:TTimeVal;
  flags:integer;
  blBLOCK:integer;
  so_error:integer;
  len:socklen_t;
begin
  Result:=-1;
  r:=-1;
  so_error:=1;
  fillchar(fdset,sizeof(fdset),0);
  fillchar(tv,sizeof(tv),0);
//  writeln(address^.sin_addr.s_bytes[1]);


  flags := fpfcntl( sockfd, F_GETFL, 0 );
  blBLOCK :=  ( flags and O_NONBLOCK );

//  if( blBLOCK<>0 ) then
  fpfcntl( sockfd, F_SETFL, blBLOCK );
//  writeln({$i %FILE%}+':'+{$i %LINE%});
  fpFD_ZERO(fdset );
  fpFD_SET( sockfd, fdset );

  tv.tv_sec := timeout_ms div 1000;
  tv.tv_usec := timeout_ms mod 1000;
  r:=fpconnect( sockfd, Psockaddr(address), sizeof(address^) );
//  writeln({$i %FILE%}+':'+{$i %LINE%});
  if fpselect( sockfd + 1, nil, @fdset, nil, @tv )=1 then
    begin
      so_error:=1;
      len := sizeof( so_error );
//      writeln({$i %FILE%}+':'+{$i %LINE%});

      r2:=fpgetsockopt( sockfd, SOL_SOCKET, SO_ERROR, @so_error, @len );

      if (so_error=0) then
        begin
          r:=0;
//          writeln(Address2Str(address)+' is open');
        end;
    end
  else
  begin
    writeln({$i %FILE%}+':'+{$i %LINE%});
    exit;
  end;
//  if (blBLOCK<>0) then
    fpfcntl( sockfd,F_SETFL,flags );



  Result:=R;
end;

function SendData(buf:Pointer;len:integer;sockcon:Pinteger):Boolean;overload;
begin
  if sockcon^=-1 then
  begin
    Result:=False;
    exit;
  end;
  Result:=SendData(buf,len,sockcon);
end;

function SendData(host:string;Port:integer;buf:Pointer;len:integer;sockcon:Pinteger=nil):Boolean;overload;
var
  cfd:integer;
  c:integer;
  s_add:sockaddr_in;
  con:integer;
  retA,retB:integer;
  timeout:timeval;
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


    s_add.sin_addr:= StrToNetAddr(host);

    s_add.sin_port:=htons(port);
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


function utf8togb2312(const Src:ansiString):ansiString;
var
  c:integer;
begin
  Result:='';
  if not IconvLibFound then
  begin
    Result:=Src;
    exit;
  end;
  c:=Iconvert(Src,Result,'utf-8','gb2312');
end;


function gb2312toutf8(Src:AnsiString):AnsiString;
var
  cd:iconv_t;
  s,d:ppchar;
  sl,dl:integer;
  p1,p2:Pointer;
  c:integer;
begin
  Result:='';
  if not IconvLibFound then
  begin
    Result:=Src;
    exit;
  end;
  c:=Iconvert(Src,Result,'gb2312','utf-8');

//
//  cd:=iconv_open('gb2312','utf-8');
//  if cd=nil then
//  exit;
//
//  p1:=@Src[1];
//  s:=@(p1);
//
//  sl:=length(src);
//  setlength(Result,sl);
//  dl:=length(Result);
//  p2:=@Result[1];
//  d:=@p2;
//
//  dl:=(Iconvert(cd,s,@sl,d,@dl));
//  if dl<0 then
//  begin
//    Result:='';
//  end
//  else
//  begin
//    setlength(Result,dl);
//  end;
//  iconv_close(cd);

end;


function del_html_simple(html:AnsiString):AnsiString;
type
  TArrayChar=array[0..16384-1] of ansiChar;
  PArrayChar=^TArrayChar;
var
  i:integer;
  len:integer;
  l:integer;
  j:integer;
  b:boolean;
  p:PChar;
  d:PArrayChar;
  s2,s3:string;
  p1,p2:integer;
  rl:integer;
begin
Result:='';
b:=false;
i:=0;
len:=length(html);
j:=0;
l:=0;
p:=@html[1];
setlength(Result,len+1024);  //防止有些长度符号大于1 ,极短情况下，全部是这些符号时，会溢出的
d:=@Result[1];
rl:=0;
while (i<len) do
begin
  b:=false;
  if strncasecmp('</li>',p,5) then
  begin
    d[0]:=#13;
    d[1]:=#10;
    inc(rl,2);
    d:=@D^[2];
    i:=i+length('</li>');
    inc(p,length('</li>'));
    system.Continue;
  end;
  for j := 0 to length(__HTML_Mark)-1 do
  begin
    s2:=__HTML_Mark[j];
     if strncasecmp(s2,p,length(s2)) then
      begin
         s3:=__HTML_Char[j];
         move(s3[1],d^[0],length(s3));
         inc(rl,length(s3));
         d:=@d^[length(s3)];
         i:=i+length(s2);
         inc(p,length(s2));
         b:=true;
         break;
      end;
  end;
  if b then
  system.Continue;

  p2:=pos('>',p);
  if (p^='<') and (p2>1) then
  begin
    i:=i+p2;
    inc(p,p2);
  end
  else
  begin
    d^[0]:=p^;
    d:=@d^[1];
    inc(i);
    inc(p);
    inc(rl);
  end;
end;
setlength(Result,rl);

end;

procedure Init;
var
  e:string;
begin
  if not IconvLibFound then
  begin
    if not InitIconv(e) then
    begin
      writeln(e);
    end;
  end;
//
//  libc_dll_handle := LoadLibrary('libc.so');
//  if libc_dll_handle<>0 then
//  begin
//    getifaddrs:=GetProcedureAddress(libc_dll_handle,'getifaddrs');
//    freeifaddrs:=GetProcedureAddress(libc_dll_handle,'freeifaddrs');
//    if not system.Assigned(getifaddrs) then
//    begin
//      writeln('GetProc: libc.so->getifaddrs=nil');
//    end;
//    if not system.Assigned(getifaddrs) then
//    begin
//      writeln('GetProc: libc.so->freeifaddrs=nil');
//    end;
//  end
//  else
//  begin
//    writeln('LoadLibrary(libc.so)=0');
//  end;
//

end;

initialization
Init;



end.

