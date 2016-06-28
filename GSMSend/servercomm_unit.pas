unit ServerComm_Unit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils,math,sockets,UnixType,baseunix;



  { TPushDataHead }
const
  PushDataHead_Flag1='Protect';
  PushDataHead_Flag2='Check';
type
  TPushDataHead=packed record    //64
    Flag1:array[0..8-1] of AnsiChar;    //标记
    flag2:array[0..8-1] of AnsiChar;
    DataVer:WORD;
    HeadSize:WORD;        //头大小
    DataFast:WORD;        //第一个数据开始
    DataSize:DWORD;       //数据区大小
    RealSize:DWORD;       //实际解压后大小
    Salt:array[0..8-1] of AnsiChar;     //盐
    CRC:WORD;             //数据区CRC
    Compress:WORD;        //1 zlib
    DataCount:integer;    //
    Res:array[0..18-1] of byte;
  end;

const
  //监听端口
  ServerPort_BTS  = 8000;
  ServerPort_APP	= 8008;

  //监听地址
  ServerAddr_APP	= '127.0.0.1';    //
  ServerAddr_BTS  = '127.0.0.1';

  ServerAddr_APP_Log	= '127.0.0.1';    //
  ServerPort_APP_Log	= 7788;

  MsgFlag:AnsiString  = 'FLAG';

  MsgCrcKey:AnsiString=  'MSGKEY';			//CRC16时，加这个，防别人折腾

type
  TMsgType=(
    mt_none         = 0,
    mt_log          =	1,
    mt_ConnRequest  =	2,
    mt_TickConn		  =	3,      //BTS端接收                客户端不用等不返回， 返回值由系统事件返回
    mt_SendSms			=	4,      	//BTS端接收			//客户端收到，表示发送成功
    mt_Register			=	5,
    mt_UnRegister		=	6,

    mt_RecvSms		  =	7,         //Res=1表示 。过滤掉这条短信
    mt_ConnLost		  =	8,
    mt_ConnRelease	=	9,
    mt_RadioReady	  =	10,
    mt_ProgEnd		  =	11,
    mt_progStart    =	12,
    mt_sig          =	13,
    mt_Conn_Allow 	=	14,		//允许时，反回		//res=1同样是允许
    mt_Conn_deny    =	15,		//拒绝时，反回

    mt_Call         = 16,   //拨号
    mt_MeasurementReport  = 17
  );
  PMSGData=^TMSGData;
  TMSGData=packed record
    case Integer of
    0:
      (buff:array[0..16-1] of byte);
    1:(
      Flag    : array[0..8-1] of ansiChar;		//标记        但只用最后7位，避免处理时麻烦
      MsgType : integer;			//数据类型
      DataSize: integer;			//数据大小，不包括包头头头
      CRC16   : WORD;         //CRC16,    +
      xor1    : Byte;
      tmp     : Byte;         //占位，对齐
      Res     : integer;      //结果值，或是其它
      );
    //data;
  end;
{
  typedef struct TSmsInfo

  	int fun;			//用途		0	没用,1 短信，2 T人
  	const char * smsKey;				//唯一性，  用于回复时，告诉，是哪条发送成功
  	const char * imei;
  	const char * imsi;
  	const char * smsc;		//中心号码
  	const char * tmsi;
  	const char * sms;
  	const char * tel;
  	const char * pdu;		//pdu
  	char  encode;			//0	4	8
  	const char * text;		//文字  unicode/ascii!!		如果
  	int	textlen;
  	const char * textHex;		//
  	const char * textPDU;		//文字  unicode/ascii!!		如果有，就用这个，没有用用text来转
  	int MaxPPD;				//多少ms后，还没发成功，算失败,=0默认>0线程等，  <0  是等abs(x)后再返回


  	int connid;
  	const char * conn;

  tagSmsInfo;

  }

function Bin2Hex(buf:pointer;len:integer):AnsiString;
procedure Hex2Bin(Str:Ansistring;buf:pointer);
procedure fill_msg(msg:PMSGData);
procedure Msg_SetCheck(msg:PMSGData;buf:pointer);   //1. xor 2. crc
function Msg_CheckRestore(msg:PMSGData;buf:pointer):Boolean;   //1.crc16 2. xor

procedure Fill_PushDataHead(var head:TPushDataHead);
procedure PushDataHead_SetData(Mem:TMemoryStream;Data:Ansistring);
function PushDataHead_GetData(head:TPushDataHead;Src:TMemoryStream;Dest:TMemoryStream):boolean;
function SendData(buf:Pointer;len:integer;sockcon:Pinteger=nil):Boolean;

implementation

uses
  CRC16_Unit;

procedure PushDataHead_SetData(Mem:TMemoryStream;Data:Ansistring);
var
  head:TPushDataHead;
begin
  Fill_PushDataHead(head);



end;

function PushDataHead_GetData(head:TPushDataHead;Src:TMemoryStream;Dest:TMemoryStream):boolean;
begin



end;

procedure Fill_PushDataHead(var head:TPushDataHead);
var
  s:AnsiString;
begin
  FillChar(head,sizeof(head),0);
  Head.Flag1:=PushDataHead_Flag1;
  Head.Flag2:=PushDataHead_Flag2;
  Head.Compress:=1;
  Head.DataVer:=1;
  Head.HeadSize:=sizeof(Head);
  Head.DataFast:=sizeof(Head);
  system.Randomize;
  s:=sysutils.FloatToStr(system.Random*10000000);
  setlength(s,sizeof(Head.Salt)-1);
  Head.Salt:=s;





end;

function Msg_CheckRestore(msg:PMSGData;buf:pointer):Boolean;
var
  z:WORD;
  b:PByteArray;
  i:integer;
begin
  Result:=True;
  if msg^.DataSize=0 then
  exit;
  b:=buf;
  if (msg^.CRC16<>$FFFF) or (msg^.CRC16<>0) then
  begin
    z:=CRC16_Unit.CalcCRC16(buf,msg^.DataSize,0);
    z:=CRC16_Unit.CalcCRC16(@MsgCrcKey[1],length(MsgCrcKey),z);
    if z<>msg^.CRC16 then
    begin
      Result:=False;
      exit;
    end;
  end;

  for i := 0 to msg^.DataSize-1 do
  begin
    b^[i]:=b^[i] xor msg^.xor1;
  end;
end;

procedure Msg_SetCheck(msg:PMSGData;buf:pointer);
var
  b:PByteArray;
  z:dword;
  i:integer;
begin
  if msg^.DataSize=0 then
  begin
    msg^.xor1:=0;
    msg^.CRC16:=0;
  end;
  b:=buf;
  system.Randomize;
  z:=GetTickCount;
  z:=z mod 255;
  msg^.xor1:=z;
  z:=max(z,20);

  for i := 0 to msg^.DataSize-1 do
  begin
    b^[i]:=b^[i] xor msg^.xor1;
  end;

  msg^.CRC16:=CRC16_Unit.CalcCRC16(buf,msg^.DataSize,0);
  msg^.CRC16:=CRC16_Unit.CalcCRC16(@MsgCrcKey[1],length(MsgCrcKey),msg^.CRC16);
end;

procedure fill_msg(msg:PMSGData);
var
  l:integer;
begin
	fillchar(msg^,sizeof(TMSGData),0);
  l:=length(MsgFlag);
  move(MsgFlag[1],msg^.Flag,l);
end;

procedure Hex2Bin(Str:Ansistring;buf:pointer);
var
  buff:PByteArray;
  s:ansistring;
  p:integer;
  len:integer;
  z:integer;
  i:integer;
begin
  str:=trim(str);
  buff:=buf;
  len:=length(str) div 2;
  fillchar(buf^,len,0);
  for i := 0 to len-1 do
  begin
    s:='0x'+str[i*2+1]+str[i*2+2];
    if not sysutils.TryStrToInt(s,z) then
    z:=0;
    buff^[i]:=z;
  end;
end;

function Bin2Hex(buf:pointer;len:integer):AnsiString;
var
  buff:PByteArray;
  s:ansistring;
  p:integer;
  i:integer;
begin
  buff:=buf;
  setlength(Result,len*2);
  p:=1;
  for i := 0 to len-1 do
  begin
    s:=inttohex(buff^[i],2);
    Result[p]:=s[1];
    Result[p+1]:=s[2];
    inc(p,2);
  end;
end;

function SendData(buf:Pointer;len:integer;sockcon:Pinteger=nil):Boolean;
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

end.

