unit SockCommUnit;

{$mode delphi}

interface

uses
  SysUtils,math,netdb,Sockets,UnixType,baseunix;


var
  MsgCrcKey:AnsiString=  'MSGKEY';			//CRC16时，加这个，防别人折腾
  MsgFlag:AnsiString  = 'FLAG';


const
  mt_log:integer=1;

type
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
  PMSGData=^TMSGData;

function Bin2Hex(buf:pointer;len:integer):AnsiString;
procedure Hex2Bin(Str:Ansistring;buf:pointer);
procedure fill_msg(msg:PMSGData);
procedure Msg_SetCheck(msg:PMSGData;buf:pointer);   //1. xor 2. crc
function Msg_CheckRestore(msg:PMSGData;buf:pointer):Boolean;   //1.crc16 2. xor
function inet_ntoa(addr:sockaddr_in;onlyAddr:Boolean=True):String;

//function SendData_h_d(var msg:TMSGData;data:pointer;len:integer;sockcon:Pinteger=nil):Boolean;
function SendData(buf:Pointer;len:integer;sockcon:Pinteger=nil;Server:string='127.0.0.1';Port:integer=123):Boolean;

implementation

uses
  CRC16_Unit;

function inet_ntoa(addr:sockaddr_in;OnlyAddr:Boolean=True):String;
begin
  Result:=sysutils.Format('%d.%d.%d.%d',[addr.sin_addr.s_bytes[1],addr.sin_addr.s_bytes[2],addr.sin_addr.s_bytes[3],addr.sin_addr.s_bytes[4]]);
  if OnlyAddr then
  exit;
  Result:=Result+':'+inttostr(NToHs(addr.sin_port));
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

procedure Fill_msg(msg:PMSGData);
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


function SendData(buf:Pointer;len:integer;sockcon:Pinteger=nil;Server:string='127.0.0.1';Port:integer=123):Boolean;
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


    s_add.sin_addr:= StrToNetAddr(Server);

    s_add.sin_port:=htons(Port);
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

