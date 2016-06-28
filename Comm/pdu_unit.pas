unit pdu_unit;

{$mode delphi}{$H+}

//https://zh.wikipedia.org/wiki/移动设备网络代码

interface

uses
  Classes, SysUtils,dateutils;


// RP message type
// ETSI TS 124.011 Section 7.3 and 8.2:
// 1 byte (3 bits): message type
//   0: RP-DATA - MS to network
//   1: RP-DATA - network to MS
//   2: RP-ACK - MS to network
//   3: RP-ACK - network to MS
//   4: RP-ERROR - MS to network
//   5: RP-ERROR - network to MS
//   6: RP-SMMA - MS to network
const
  RP_DataFromMs = 0;
  RP_DataFromNetwork = 1;
  RP_AckFromMs = 2;
  RP_AckFromNetwork = 3;
  RP_ErrorFromMs = 4;
  RP_ErrorFromNetwork = 5;
  RP_SMMAFromMs = 6;


  //https://en.wikipedia.org/wiki/Data_Coding_Scheme
  //http://www.smartposition.nl/resources/sms_pdu.html
  //http://betelco.blogspot.jp/2009/10/sms-over-3gpp-ims-network.html

  SMSEncodeType_7bit  = $00;    //xxxx00xx
  SMSEncodeType_8bit  = $04;    //xxxx01xx
  SMSEncodeType_UCS2  = $08;    //xxxx10xx

  RP_VFP_None         = $00;    //xxxx00xx
  RP_VFP_Mode_res     = $04;    //xxxx01xx
  RP_VFP_Mode_1Byte   = $10;    //xxxx10xx
  RP_VFP_halfByte     = $14;    //xxxx11xx

  RP_UDHI             = $40;    //x1xxxxxx    //用户数据头标示。0用户数据没有头信息，1有。一般为0。
  RP_RP               = $80;    //1xxxxxxx    //是否有回复路径的标示。1有，0没有。一般为0。
  RP_SRI              = $20;    //xx1xxxxx    //1bit：(仅接收)状态报告标示。0不需要状态返回到移动设备。1需要。默认为0。
  RP_MMS              = $04;    //xxxxx1xx    //1bit：(仅接收)短消息服务中心是否有更多短消息等待移动台。1有，0无。默认为1。
  RP_RD               = $04;    //xxxxx1xx    //1bit：(仅发送)重复信元丢弃。0通知服务中心碰到同源、同目的地、同样的MR（短消息序号）的短消息接受。1抛弃，此时将在短消息提交报告中返回一个适当的FCS值。
  RP_SRR              = $20;    //xx1xxxxx    //1bit：(仅发送)状态报告要求


type
  TPDUData=packed record
    Result:Boolean;
    rpMsgType:Byte;
    MsgRef:Byte;
    UDHI:Byte;
    SMSC:array[0..32-1] of AnsiChar;
    Tel:array[0..32-1] of AnsiChar;
    RP_User_Data_len:Byte;
    TP_PID:Byte;
    TP_Data_Code:Byte;
    VFPMode:Byte;    // 有效期限格式
    VFP1:Byte;
    VFP2:Byte;
    VFP3:Byte;
    PDU:AnsiString;
    Time:TDateTime;
    TextAnsi:AnsiString;
    TextAnsi_Len:integer;
    Text:WideString;
  end;

function Decode_PDU(const apdu:AnsiString):TPDUData;
function GetSMSEncodeType(var pdu:TPDUData):integer;

Function ImeiTail(const aImeiIn:AnsiString):AnsiString;
function Text2PDU(const str:String;SMSEncodeType:integer;AppLen:boolean=True):String;
function HexStr2PDU(const aHexStr:AnsiString):AnsiString;    //反转
function EnCode_PDU(const smsc:string;const Tel:string; const Text:string;encode:integer):AnsiString;      //组织发送包
function GetModemImeiShowStr(const aimei:string;modem:boolean;Eng:Boolean=False):string;
function GetIMSIShowStr(const aIMSI:string;block:boolean):string;
function GetBlockText_LastStr(const aStr:String;len:integer=3):string;
function GetSmsKey(const imsi:String='';const imei:String='';OtherName:String='';OtherVal:string=''): String;


function GetVal_from_SmsKey(const smskey:string;FieldName:String='IMSI';NullVal:string=''): String;

var
  FixSmscTimeToLocalTime:Boolean=True;

implementation

uses
  UTF8toUCS2_Unit,gsm_sms_util;


const
  PDU_htc8x_cn='00 d1 00 08 91683108501705f0 163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00';   //一一一一一
  pdu_htc8x_en='00e7000891683108501705f01635380781489135f20000ff0bc139d91c93cd66b49a0d';    //Asdf123456
  pdu_htc8x_cnen='00ea000891683108501705f02831390781489135f20008ff1c597d5427007100770065007200610073007300660031003200330034';
  pdu_nokia1100_cnen='0001000891683108501705f01c119c038111f10008ff1262c9002e0061006400310032003300340035';  //拉.ad12345
  pdu_ybts_welcome='010004802143f500650405802143f500005180325022230061d9775d0e0ab3d9ef71985e2683e0e8b7bb0c72bf5da0f41c84a3c572b599cc05a2a2c3ee3528ffae83cc6f3928ed9ed3c36c76da7d0665c3f4b2903a75818661361b440cdbd36450980e2287ed69326a26c3d16629';
  pdu_tmp='00f2000891683108501705f016353a0781489135f20000ff0bb1582c168bc562b1580c';
  {
  010004802143f500650405802143f500005180325045750061d9775d0e0ab3d9ef71985e2683e0e8b7bb0c72bf5da0f41c5483cd66395cce05a2a2c3ee3528ffae83cc6f3928ed9ed3c36c76da7d0665c3f4b2903a75818661361b440cdbd36450980e2287ed69326a26c3d16629
    00ee000891683108501705f016313a0781489135f20000ff0bb1582c168bc562b1580c


    01000880683108501705f0001b040780053389f90000518032505564000bb1582c168bc562b1580c
0003000739012300f2000891683108501705f016353a0781489135f20000ff0bb1582c168bc562b1580c                     //
              00f2000891683108501705f016353a0781489135f20000ff0bb1582c168bc562b1580c

}
{

http://www.verydemo.com/demo_c131_i71368.html
http://www.cnblogs.com/bastard/archive/2012/02/07/2340847.html
http://blog.csdn.net/mochouxiyan/article/details/8507855

TIFlag="false">5</TID>
  <Message type="CP-Data">
    <RPDU enc="hex">00 d1 00 08 91683108501705f0 163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00</RPDU>
  </Message>

  00                   rp mess type
  d1                     msgRef
  00                          ??
  08                0x08 len
  91                   91国际号"+"，81,A1国内号
  683108501705f0        cmcc
  16                      rplen
      BIT      7     6       5      4       3      2       1       0
      参数    RP    UDHI     SRI                  MMS      MTI     MTI

31                         tp  tpMTI = 31 & 0x03;

32

07                            addrlen, odd=addrlen and 0x01;

81                            91国际号"+"，81,A1国内号

                          BIT No. 	7 	6 	5 	4 	3 	2 	1 	0
  	                                1 	类型 	类型 	类型 	号码鉴别 	同3 	同3 	同3

                          类型：000-未知 001-国际 010-国内 111-留作扩展

                          号码鉴别：0000-未知 0001-ISDN/电话号码（E.164/E.163） 1111-留作扩展

489135f2                               8419532

00                          TP-PID    00 协议标识TP-PID：普通GSM，点到点方式
08                                     encodetype 00 7bit, 04 8bit ,08 US2             //需要按位取数据,bit 2,3
                                                                       bit 0,1
                                                                           00 class0   短消息直接显示在屏幕上,        闪信!!
                                                                           01 class1   短消息存储在SIM卡上
                                                                           10 class 2  短消息必须存储在SIM卡上，禁止直接传输到中断。
                                                                           11 class 3  短消息存贮在用户设备上。

ff                                      参数显示消息有效期,长度0,1,7
                                                                       1byte:  00-8F 	（VP+1）*5分钟 从5分钟间隔到12小时
                                                                               90-A7 	12小时+（VF-143）*30分钟
                                                                               A8-C4 	（VP-166）*1天
                                                                               C5-FF 	（VP-192）*1周


0a                                      短信长度
4e004e004e004e004e00

31320781489135f20008ff0a4e004e004e004e004e00

Bit   	7	6	5	4	3	2	1	0
参数   	RP	UDHI	SRR	VPF	VPF	RD	MTI	MTI


MTI 2bit：消息类型，00表示收，01表示发
MMS 1bit：短消息服务中心是否有更多短消息等待移动台。1有，0无。默认为1。
SRI 1bit：状态报告标示。0不需要状态返回到移动设备。1需要。默认为0。
UDHI 1bit：用户数据头标示。0用户数据没有头信息，1有。一般为0。
RP  1bit：是否有回复路径的标示。1有，0没有。一般为0。
VPF 2bit：有效期限格式。00 VP不存在；10 VP区存在用一个字节表示，是相对值；01保留；11存在，半个字节表示，绝对值。
RD  1bit：重复信元丢弃。0通知服务中心碰到同源、同目的地、同样的MR（短消息序号）的短消息接受。1抛弃，此时将在短消息提交报告中返回一个适当的FCS值。
SRR 2bit：状态报告要求。

}

function GetBlockText_LastStr(const aStr:String;len:integer=3):string;
var
  i,len2:integer;
  str:String;
  c:integer;
begin
  str:=aStr;
  i:=length(str);
  Result:=str;
  if i<=6 then
  exit;

  len2:=len;
  c:=i-len;
  Result:=Copy(aStr,1,i-len);

  for i := 0 to len2-1  do
  begin
    Result:=Result+'*';
  end;

end;

function GetVal_from_SmsKey(const smskey:string;FieldName:String='IMSI';NullVal:string=''): String;
var
  p1:integer;
  a:String;
  c:String;
begin
  Result:=NullVal;
  a:=smskey;
  c:=sysutils.LowerCase(FieldName+'_');
  p1:=pos(c,sysutils.LowerCase(a));
  if p1=0 then
  exit;
  delete(a,1,p1+length(FieldName));
  p1:=pos('_',a);
  if p1=0 then
  begin
    result:=copy(a,1,maxint);
  end
  else
  begin
    result:=copy(a,1,p1-1);
  end;
  if Result='' then
  Result:=NullVal;
end;

function GetSmsKey(const imsi:String='';const imei:String='';OtherName:String='';OtherVal:string=''): String;
var
  a,b:string;
begin
  Result:='';
  if trim(imsi)<>'' then
  Result:='IMSI_'+trim(imsi)+'_';
  if trim(imei)<>'' then
  Result:=Result+'IMEI_'+trim(imei)+'_';;

  Result:=Result+'DT_'+sysutils.FormatDateTime('yyyyMMddhhnnsszzz',now);
  Result:=Result+'_T_'+inttostr(sysutils.GetTickCount64);
  a:=trim(OtherName);
  b:=trim(OtherVal);
  if (a<>'') and (b<>'') then
  begin
    Result:=Result+'_'+a+'_'+b;
  end;
  if (a<>'') and (b='') then
  begin
    Result:=Result+'_'+a;
  end;
  if (a='') and (b<>'') then
  begin
    Result:=Result+'_'+b;
  end;
end;

function GetIMSIShowStr(const aIMSI:string;block:boolean):string;
var
  imsi:String;
begin
  Result:='';
  IMSI:=aIMSI;
  if IMSI='(null)' then
  exit;
  if IMSI='' then
  exit;

  if length(IMSI)<>15 then
  exit;
  Result:=imsi;
  if not block then
  exit;

  //Result:=copy(IMSI,1,10)+'***';
//  46000EFM MMMABCD
  IMSI[6]:='*';
  IMSI[7]:='*';
  IMSI[8]:='*';
  Result:=IMSI;

end;

function GetModemImeiShowStr(const aimei:string;modem:boolean;Eng:Boolean=False):string;
var
  imei:string;
begin
  Result:='';
  imei:=aimei;
  if imei='(null)' then
  imei:='';
  if imei='' then
  exit;
  if length(imei)=14 then
  imei:=imei+'0';

  if length(imei)<>15 then
  exit;
  imei:=ImeiTail(imei);
  if modem then
  begin
    if eng then
    Result:='*GSM*'+copy(imei,5,maxint)
    else
    Result:='*GSM模块*'+copy(imei,10,maxint)
  end
  else
  Result:=imei;

end;

function HexStr2PDU(const aHexStr:AnsiString):AnsiString;
var
  i,l:integer;
  HexStr:AnsiString;
begin
  i:=1;
  HexStr:=ahexStr;
  l:=length(hexStr);
  if (l mod 2)=1 then
  begin
    hexStr:=hexStr+'F';
    l:=l+1;
  end;

  l:=(l div 2)*2;
  Result:=HexStr;
  while i<l do
  begin
    Result[i]:=hexStr[i+1];
    Result[i+1]:=hexStr[i];
    inc(i,2);
  end;


end;

function Text2PDU(const str:String;SMSEncodeType:integer;AppLen:boolean=True):String;
var
  i:integer;
  L:integer;
  aStr:AnsiString;
  uStr:WideString;
  s:String;
  ucs:array of Byte;
  buf:PByteArray;
begin
Result:='';
if SMSEncodeType=4 then
begin
  L:=length(str);
  buf:=PByteArray(@str[1]);
  for i := 0 to l-1 do
  begin
    Result:=Result+inttohex(buf^[i],2);
  end;
  if AppLen then
  Result:=sysutils.inttohex(L,2)+Result;
end;
if SMSEncodeType=8 then
begin
  L:=Length(Str);
  L:=L*2;
  setlength(ucs,L);

  l:=UTF8toUCS2Code(@str[1],@ucs[0]);
  Result:=UCS2PDU(@ucs[0],L*2);
  if AppLen then
  Result:=sysutils.inttohex(L*2,2)+Result;
end;


//setlength(s2,length(s)*2);
//l:=UTF8toUCS2Code(@s[1],@s2[0]);
//self.Memo2.Lines.Add(UCS2PDU(@s2[0],l*2));

end;

function GetSMSEncodeType(var pdu:TPDUData):integer;
begin
  Result:=SMSEncodeType_7bit;
  if (pdu.TP_Data_Code and SMSEncodeType_7bit)=SMSEncodeType_7bit then
  Result:=SMSEncodeType_7bit;
  if (pdu.TP_Data_Code and SMSEncodeType_8bit)=SMSEncodeType_8bit then
  Result:=SMSEncodeType_8bit;
    if (pdu.TP_Data_Code and SMSEncodeType_UCS2)=SMSEncodeType_UCS2 then
  Result:=SMSEncodeType_UCS2;

end;

function Decode_Tel(const pdu:AnsiString;len:integer):AnsiString;
var
  t:byte;
  i:integer;
const
  International:byte=$10;               //x010xxxx
begin
  Result:='';
  i:=1;
  t:=strtoint('0x'+pdu[1]+pdu[2]);
  if (t and  International)=International then
  Result:='+';

  i:=i+2;
  len:=len+i;
  while i<len do
  begin
    if sysutils.SameText(pdu[i],'F') then
      Result:=Result+pdu[i+1]
      else
      Result:=Result+pdu[i+1]+pdu[i];
    i:=i+2;

  end;


end;


function Encode_Tel(const aTel:AnsiString):AnsiString;
var
  i,l:integer;
  tel:string;
begin
  result:='';
  tel:=atel;
  if tel='' then
  begin
    Result:='8100';
    exit;
  end;
  if tel[1]='+' then
    begin
      Result:='91';
      delete(tel,1,1);
    end
    else
    begin
      Result:='81';
    end;
    if tel='' then
      begin
        Result:='';
        exit;
      end;
   l:=length(tel);
   if (l mod 2)=1 then
     begin
       l:=l+1;
       tel:=tel+'F';
     end;
//   l:=l div 2;
   i:=1;
   while(i<l) do
   begin
     Result:=Result+Tel[i+1]+Tel[i];
     inc(i,2);
   end;

end;



function EnCode_PDU(const smsc:string;const Tel:string; const Text:string;encode:integer):AnsiString;      //组织发送包
var
  s:AnsiString;
  t:TDateTime;
  st:TSystemTime;
  L:integer;
  Head:AnsiString;
begin
  Result:='';
  if smsc='' then
  exit;
  if tel='' then
  exit;
  Head:='';
//    01000780683105015000001604098021436597f8000851809251151500044e2d4e2d
{
  sms.smsc="8613500101234";
  //sms.tmsi="007b0002";
  sms.tel="123456798";
  //中中a
  //08 91683105101032F4 00 1B04 098121436597F8 00 08 518003510590 00 0A4E2D006100614E2D0061
  //08 80683105101032f4 00 1804 098021436597f8 00 08 518092220460 00 054e2d4e2d0061
}
  //08 91683105101032F4 00      088121436597F8 00 08 518003414475 00 054E2D006100614E2D0061

  //08 91683105101032F4 1100    088121436597F8 00 08 518003414475 00 054E2D006100614E2D0061

//  04 802143f5         00 6504 05802143f5     00 00 518032502223 00 61d9775d0e0ab3d9ef71985e2683e0e8b7bb0c72bf5da0f41c84a3c572b599cc05a2a2c3ee3528ffae83cc6f3928ed9ed3c36c76da7d0665c3f4b2903a75818661361b440cdbd36450980e2287ed69326a26c3d16629';

  Head:='0100';
  s:=Encode_Tel(smsc);
  Head:=Head+inttohex(length(s) div 2,2);    //长度    几组，不包括91
  Head:=Head+s;
  Head:=Head+'00';    //TP-MMS

  //  uint8_t* orig = new uint8_t[2 + (smsCaller.length() + 1) / 2];

//  Result:=Result+'1604';   // 16是目标号码到xx的长度
//  Result:=Result+'**04';   //
  if (tel[1]='+') then
  begin
    Result:=Result+inttohex(length(tel)-1,2)    //真实长度，不包括+,91
  end
  else
  begin
    Result:=Result+inttohex(length(tel),2);    //真实长度，不包括+,91
  end;

  s:=Encode_Tel(tel);

  Result:=Result+s;

  //uint8_t extra[9] =
  Result:=Result+'00';    //Protocol identifier
//  s:='00';


  Result:=Result+inttohex(encode,2);    //Data encoding scheme

  t:=now;
  if not FixSmscTimeToLocalTime then
  t:=t+sysutils.GetLocalTimeOffset*dateutils.OneMinute;

  sysutils.DateTimeToSystemTime(t,st);
  s:=sysutils.FormatDateTime('yyMMddHHnnss',t);
  s:=HexStr2PDU(s);
  Result:=Result+s;

  Result:=Result+'00';// ??

  s:=pdu_unit.Text2PDU(Text,encode);
//  Result:=Result+inttohex(length(s) div 2,2);
  Result:=Result+s;
  L:=(length(Result) div 2) +1;
  Result:=Head+inttohex(L,2)+'04'+Result;

end;

function Decode_PDU(const apdu:AnsiString):TPDUData;
var
  pdu:ansistring;
  i:integer;
  c:widestring;
  t:integer;
  s:ansistring;
  buf:array of byte;
  t1,t2,t3,t4,t5,t6:integer;
begin
//  参考ybts.cpp  int decodeRP(uint8_t*& b, unsigned int& len, uint8_t& rpMsgType,

  fillchar(Result,sizeof(TPDUData),0);
  if length(apdu)<4 then
  exit;

  pdu:=apdu;


  //  00 d1 00 08 91683108501705f0 163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00
  Result.rpMsgType:=strtoint('0x'+pdu[1]+pdu[2]);
  Result.rpMsgType:=Result.rpMsgType and $07;
  Result.MsgRef:=strtoint('0x'+pdu[3]+pdu[4]);
  if (Result.rpMsgType <> RP_DataFromMs) and (Result.rpMsgType <> RP_DataFromNetwork) then
		exit;
  if (Result.rpMsgType = RP_DataFromMs) then
  delete(pdu,1,4);
  if (Result.rpMsgType = RP_DataFromNetwork) then
  delete(pdu,1,2);



  //  00 08 91683108501705f0 163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00
  delete(pdu,1,2);
  //  08 91683108501705f0 163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00
  i:=strtoint('0x'+pdu[1]+pdu[2])*2-2;    //
  delete(pdu,1,2);
  Result.SMSC:=Decode_Tel(pdu,i);
  delete(pdu,1,i+2);
  //163132 0781 489135f2 0008ff 0a 4e004e004e004e004e00
  //if (result.rpMessType and $07)=ord(RPDataFromMs) then   //不知道是什么，跳过再说
  //begin
  //  delete(pdu,1,6);
  //end;

  Result.RP_User_Data_len:=strtoint('0x'+pdu[3]+pdu[4]);  //16
  Result.TP_PID:=strtoint('0x'+pdu[3]+pdu[4]);  //31
  Result.MsgRef:=strtoint('0x'+pdu[5]+pdu[6]);  //32
  delete(pdu,1,6);

  Result.VFPMode:=Result.TP_PID and $18;    //xxx11xxx
  Result.UDHI:=Result.TP_PID and RP_UDHI;

  //0781 489135f2 0008ff 0a 4e004e004e004e004e00
  i:=strtoint('0x'+pdu[1]+pdu[2]);
  delete(pdu,1,2);
//  i:=i*2-2-1;   //    2 + (Length + 1) / 2 = 8
  result.Tel:=Decode_Tel(pdu,i);
  if (i mod 2)>0 then               //F
    i:=i+1;
  delete(pdu,1,i+2);
  //0008ff 0a 4e004e004e004e004e00
  Result.TP_PID:=strtoint('0x'+pdu[1]+pdu[2]);
  Result.TP_Data_Code:=strtoint('0x'+pdu[3]+pdu[4]);
  delete(pdu,1,4);

  if (Result.rpMsgType = RP_DataFromNetwork) then
  begin
    s:=copy(pdu,1,12);
//    delete(pdu,1,12);   //datetime
    s:=HexStr2PDU(s);
    t1:=sysutils.StrToInt(copy(s,1,2));

    t3:=sysutils.StrToInt(copy(s,5,2));
    t4:=sysutils.StrToInt(copy(s,7,2));
    t5:=sysutils.StrToInt(copy(s,9,2));
    t6:=sysutils.StrToInt(copy(s,11,2));
    Result.Time:=sysutils.EncodeDate(t1,t2,t3);
    Result.Time:=Result.Time+sysutils.EncodeTime(t4,t5,t6,0);
    Result.Time:=Result.Time+sysutils.GetLocalTimeOffset*dateutils.OneMinute;
  end;

  case Result.VFPMode of
    RP_VFP_None    :
              begin

              end;
    RP_VFP_Mode_res:
              begin
                //错误，未定义值
              end;
    RP_VFP_Mode_1Byte:
              begin
                delete(pdu,1,2);
              end;
    RP_VFP_halfByte:
              begin
                delete(pdu,1,1);
              end;
  end;
  // 0a 4e004e004e004e004e00
  t:=strtoint('0x'+pdu[1]+pdu[2]);
  delete(pdu,1,2);
  if Result.UDHI<>0 then
  begin
    t2:=strtoint('0x'+pdu[1]+pdu[2]);    //记录长短信的标识
    delete(pdu,1,t2*2);   //跳过再说
  end;
  Result.TextAnsi_Len:=T;
  if (Result.TP_Data_Code and SMSEncodeType_7bit)=SMSEncodeType_7bit then
  begin
//     s:=GSM7bit2AscII(pdu,length(pdu));
//     s:=gsm_sms_util.Decode7Bit(pdu,length(pdu));
//     setlength(Result.TextAnsi,length(s));
//     system.Move(s[1],Result.TextAnsi[1],length(s));
      Result.TextAnsi:=decodeGSM7Bit(pdu);
      Result.TextAnsi_Len:=length(Result.TextAnsi);


  end;
  if (Result.TP_Data_Code and SMSEncodeType_8bit)=SMSEncodeType_8bit then
  begin
    Result.TextAnsi_Len:=T;
    t:=1;
    T2:=0;
    setlength(Result.TextAnsi,T);
    while t<t2 do
    begin
      s:=copy(pdu,t,2);
      Result.TextAnsi[t]:=chr(strtoint('0x'+s));
      t:=t+2;
    end;
    Setlength(Result.Text,t2 div 2);
    system.Move(Result.TextAnsi[1],Result.Text[1],t2);
  end;
  if (Result.TP_Data_Code and SMSEncodeType_UCS2)=SMSEncodeType_UCS2 then
  begin
    t2:=(t div 2)*2;   //肯定是双字节的
    t:=1;
    Result.TextAnsi_Len:=t2;
    setlength(Result.TextAnsi,t2);
    while t<t2 do
    begin
//      if t>=135 then
//      beep;
      if length(pdu)<4 then
      begin
        beep;
        system.Break;
      end;
      s:=copy(pdu,3,2);
      Result.TextAnsi[t]:=chr(strtoint('0x'+s));
      s:=copy(pdu,1,2);
      Result.TextAnsi[t+1]:=chr(strtoint('0x'+s));
      delete(pdu,1,4);
      t:=t+2;
    end;
    Setlength(Result.Text,t2 div 2);
    system.Move(Result.TextAnsi[1],Result.Text[1],t2);
  end;

Result.Result:=true;

end;

{
IMEI校验码算法：
(1).将偶数位数字分别乘以2，分别计算个位数和十位数之和
(2).将奇数位数字相加，再加上上一步算得的值
(3).如果得出的数个位是0则校验位为0，否则为10减去个位数
如：35 89 01 80 69 72 41 偶数位乘以2得到5*2=10 9*2=18 1*2=02 0*2=00 9*2=18 2*2=04 1*2=02,
计算奇数位数字之和和偶数位个位十位之和，
得到 3+(1+0)+8+(1+8)+0+(0+2)+8+(0+0)+6+(1+8)+7+(0+4)+4+(0+2)=63 => 校验位 10-3 = 7

}
Function ImeiTail(const aImeiIn:AnsiString):AnsiString;
var
  iTemp1,iTemp2,i:integer;
  ImeiT:AnsiString;
  l:integer;
  ImeiIn:AnsiString;
begin
//'输入IMEI前14位，返回IMEI第15位，如果返回空值，表示程序出错
Result:='';
ImeiIn:=aImeiIn;
l:=Length(ImeiIn);
if l<14 then
begin
  exit;
end;
  If (l <> 14) and (l <> 15) Then
  begin
    Result:=ImeiIn;
    exit;
  end;
  iTemp1:=0;
  for i:=1 to 14 do   // '计算IMEI校验位
  begin
    if(i mod 2<>0) then
    begin
      iTemp2:=strToInt(copy(ImeiIn, i, 1));
    end
    else
    begin
      iTemp2:= strToInt(copy(ImeiIn, i, 1)) * 2;
      If (iTemp2 >= 10) Then
      begin
        iTemp2 := 1 + (iTemp2 Mod 10);
      end;
    end;
    iTemp1:= iTemp1 + iTemp2;
  end;
  If (iTemp1 Mod 10)= 0 Then
  begin
    ImeiT:= '0';
  end
  Else
  begin
    ImeiT:= IntToStr(10 - (iTemp1 Mod 10));
  End;
  if l=14 then
  Result:=Imeiin+ImeiT;
  if l=15 then
  begin
    Imeiin[15]:=ImeiT[1];
    Result:=Imeiin;
  end;

end;


end.

