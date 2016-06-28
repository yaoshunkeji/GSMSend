unit RegUnit;

{$mode delphi}{$H+}

{.$DEFINE DEBUG}

{.$DEFINE UseDog}

interface

uses
  Classes, SysUtils,process,math,baseunix;

type

  PRegHW=^TRegHW;
  TRegHW=packed record
    xor_1:Byte;
    Xor_2:Byte;                        //暂时不用 $FF
    V1:Byte;                          //1   default1    考虑只用$0F  $F0下次用
    product:Byte;                     //4   init=10

    SDR:WORD;
    MBSN:WORD;                      //系统级的系列号,如主板

    LastCount:WORD;
    AllCount:WORD;

    PayCount:WORD;
    CRC:Byte;
    Xor_4:Byte;    //最后一关    上面全部都由这个xor处理一下
  end;

  TRegCode=packed record
    Xor_1:Byte;
    Xor_2:Byte;                         //机器码的CRC
    V1:Byte;                          //1   default1
    product:Byte;                     //4   init=10

    SDR:WORD;
    MBSN:WORD;

    Count:WORD;
//    Res:WORD;
    CRC:Byte;
    Xor_4:Byte;    //最后一关    上面全部都由这个xor处理一下
  end;

  TMacID=packed record
    SysBrdSN:WORD;
    SysUUIDSN:WORD;

    SysSDRSN:WORD;
    res:WORD;

    CRC:Byte;
    XorKey1:Byte;
    XorKey2:Byte;
//    res
  end;


const
  CRCSalt='CRCSalt';


type                //一起写入， 总大小不超4K
  TRegFile_Head=packed record   //sizeof=128
    Flag:array[0..8-1] of AnsiChar;
    Ver:integer;
    DataSize:integer;
    HeadSize:integer;
    DataCRC1:WORD;    //盘上实际数据
    DataCRC2:WORD;    //明文数据

    DataSalt:array[0..24-1] of AnsiChar;   //xor crcdata    2015-01-01 12:12:12
//    Product:integer;
    DataCount:integer;
    Res:array[0..19-1] of integer;
  end;

  PRegFile_DataItemArray=^TRegFile_DataItemArray;
  TRegFile_DataItemArray=array[0..128-1] of TRegFile_DataItem;
  TRegFile_DataItem=packed record   //sizeof=64
    Name:Array[0..8-1] of AnsiChar;     //
    Data:array[0..48-1] of AnsiChar;
    DataSalt:array[0..4-1] of AnsiChar;   //xor crcdata
    CRC:WORD;
    Res:WORD;
  end;
  TRegFile_Data=packed record         //640
    CPUID:TRegFile_DataItem;
    SysUUID:TRegFile_DataItem;
    SysSN:TRegFile_DataItem;
    SysBrdSN:TRegFile_DataItem;
    DiskInfo:TRegFile_DataItem;

    Count:TRegFile_DataItem;
    OtherCount:TRegFile_DataItem;
    Fun:TRegFile_DataItem;

    HWInfo:TRegFile_DataItem;     //专用硬件信息
    DogInfo:TRegFile_DataItem;
//    Res:TRegFile_DataItem;
    //后面的，Name必须不为空，才是有效的，否则不检查CRC
  end;

  PRegFileALL=^TRegFileALL;
  TRegFile=packed record      //768
    Head:TRegFile_Head;
    Data:TRegFile_Data;
  end;


const
  mmcblk0rpmb_Flag='eMMC';
  mmcblk0rpmb_Ver =10000;



function FillRegHW(var R:TRegHW):Boolean;
function GetMacHWForReg(R:PRegHW=nil):string;
function Str2RegHW(MacHWStr:string;var R:TRegHW):Boolean;   // xor 恢复原有数据!!
function Str2RegCode(RegCodeStr:string;out R:TRegCode):Boolean;    //xor 恢复原有数据!!

function NewRegCode(Count:integer;RegHW:PRegHW=nil):string;//充值码生成  RegHW是已经解码后的

function DoRegCheck(RegStr:string;MacStr:string):boolean;
function DoReg(RegStr:string;MacStr:string):integer;

function NewDecCountCode(Count:integer):string;

function GetSDRSN(onlySDRSN:boolean=false):String;

function SysinfoWhere:string;

function GetSys_SN:string;            //System Information->Serial Number

function GetSysBrd_SN:string;         //Base Board Information->Serial Number

function GetSysBrd_SN_D:DWORD;

function GetSys_UUID:string;          //System Information->UUID

function isMySysBoard:Boolean;

function mmcblk0rpmb_Fill(var R:Tmmcblk0rpmb):Boolean;    //空的
function mmcblk0rpmb_Read(var R:Tmmcblk0rpmb;FailedDoInit:Boolean=False):Boolean;    //读成明文 如果读错，就Init状态
function mmcblk0rpmb_Write(var R:Tmmcblk0rpmb):Boolean;   //写成密文

function mmcblk0rpmb_Init(Count:integer):Boolean;           //全新的
function mmcblk0rpmb_CheckBoardMatch(mmc:Pmmcblk0rpmb=nil):Boolean;

procedure mmcblk0rpmb_SetData(var D:TRegFile_DataItem;Name:ansiString;Data:AnsiString);

procedure mmcblk0rpmb_EncodeItem(var D:TRegFile_DataItem);
function mmcblk0rpmb_DecodeItem(var D:TRegFile_DataItem):Boolean;

function GetMacID():String;
function Str2MacID(str:String;out M:TMacID):Boolean;



function NewBindIMEICode(idx:integer;IMEI:String;Method:string;R:TRegHW):string;
function BindIMEI(BindIMEICode:AnsiString;R:TRegHW;OnlyCheck:Boolean=False):String;overload;
function BindIMEI(BindIMEICode:AnsiString;MacStr:AnsiString;OnlyCheck:Boolean=False):String;overload;
function GetMainDisk_Feature:string;
function GetCPUID_Str:string;

var
  mmcblk0rpmb:Boolean=True;

var
  //'/lib/tables/mmcblk0rpmb';
  mmcblk0rpmb_File:AnsiString='';

implementation

uses
  CRC16_Unit,CRC8_Unit,hw_fununit;


const                          //改成一个列表，用于查找可用的mmc
  mmcblk0rpmb_File_Str='17405D54174D535A54654B03595B5B5B5E530872484156';
  mmcblk0rpmb_File_Str2='46892885';

procedure mmcblk0rpmb_File_Get;
var
  f:TFileStream;
  buf:array of byte;
  s:string;
  c:integer;
begin
F:=nil;

  if (mmcblk0rpmb_File='') then
  begin
    if not XorDecode2HexStr(mmcblk0rpmb_File_Str,mmcblk0rpmb_File_Str2,mmcblk0rpmb_File) then
    begin
      mmcblk0rpmb_File:='ERROR';
      writeln('Decode2 File_Str ERROR');
      exit;
    end;
    if not sysutils.FileExists(mmcblk0rpmb_File) then
    begin
      s:=sysutils.ExtractFileDir(mmcblk0rpmb_File);
      sysutils.ForceDirectories(s);
      exit;
    end;
    try
      F:=TFileStream.Create(mmcblk0rpmb_File,fmOpenRead);
      setlength(buf,512);
      c:=F.Read(buf[0],512);
      if c<>512 then
      begin
//        mmcblk0rpmb_File:='ERROR';
        writeln(' MMC Failed:'+sysutils.SysErrorMessage(sysutils.GetLastOSError)+' !');
      end;
      sysutils.FreeAndNil(F);
    except
    end;
  end;

end;


function mmcblk0rpmb_Init(Count:integer):Boolean;
var
  R:Tmmcblk0rpmb;
  F:TFileStream;
  m:WORD;
  s:ansiString;
  l:integer;
begin
  Result:=False;
  mmcblk0rpmb_Fill(R);

  Result:=false;

  if Count>=0 then
  begin
    mmcblk0rpmb_SetData(R.Data.SDRSN,'SDRSN',SDRSN);
    mmcblk0rpmb_SetData(R.Data.SysBrdSN,'SysBrdSN',SysBrdSN);
    mmcblk0rpmb_SetData(R.Data.SysUUID,'SysUUID',SysUUID);
    mmcblk0rpmb_SetData(R.Data.SysSN,'SysSN',SysSN);
    mmcblk0rpmb_SetData(R.Data.PayCount,'DiskInfo',DiskInfo);
  end;
  Count:=Max(Count,0);

  mmcblk0rpmb_SetData(R.Data.Count,'Count',inttostr(Count));
  mmcblk0rpmb_SetData(R.Data.AllCount,'AllCount',inttostr(Count));
  mmcblk0rpmb_SetData(R.Data.PayCount,'PayCount','0');

  mmcblk0rpmb_Write(R);

  Result:=True;

end;

function mmcblk0rpmb_CheckBoardMatch(mmc:Pmmcblk0rpmb=nil):Boolean;
var
  R:Tmmcblk0rpmb;
  l:integer;
  s,s2:AnsiString;
  MaxL:integer;
begin
  Result:=false;
  if mmc<>nil then
  begin
    R:=mmc^;
  end
  else
  begin
    if not mmcblk0rpmb_Read(R) then
    exit;
  end;

//  MaxL:=sizeof(R.Data.SDRSN.Data)-1;

//  s:=trim(R.Data.SDRSN.Data);
//  if not SameText_N(s,SDRSN,MaxL) then
//  exit;
  s:=trim(R.Data.SysBrdSN.Data);
  if not SameText_N(s,SysBrdSN,MaxL) then
  exit;
  s:=trim(R.Data.SysUUID.Data);
  if not SameText_N(s,SysUUID,MaxL) then
  exit;
  s:=trim(R.Data.SysSN.Data);
  if not SameText_N(s,SysSN,MaxL) then
  exit;

  s:=trim(R.Data.DiskInfo.Name);
  if s<>'' then
  begin
    s:=trim(R.Data.DiskInfo.Data);
    if not SameText_N(s,DiskInfo,MaxL) then
    exit;
  end;

  Result:=True;

end;

function mmcblk0rpmb_Write(var R:Tmmcblk0rpmb):Boolean;   //
var
  F:TFileStream;
  buf:PByteArray;
  i:integer;
  s:AnsiString;
  l:integer;
  fn:string;
begin
  Result:=false;
  F:=nil;
  if not mmcblk0rpmb then
  exit;
  mmcblk0rpmb_File_Get;

  if mmcblk0rpmb_File='ERROR' then
  begin
    exit;
  end;
  fn:=mmcblk0rpmb_File;
//  if mmcblk0rpmb_File='ERROR' then
//  fn:=mmcblk1rpmb_File;

  R.Head.DataSize:=sizeof(R.Data);
  R.Head.DataCount:=sizeof(R.Data) div sizeof(R.Data.Count);
  R.Head.HeadSize:=Sizeof(R.Head);
  R.Head.Flag:=mmcblk0rpmb_Flag;

  fillchar(R.Head.DataSalt[0],sizeof(R.Head.DataSalt),0);
  s:=sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',now);
  l:=min(sizeof(R.Head.DataSalt),length(s));
  move(s[1],R.Head.DataSalt[0],l);

  mmcblk0rpmb_EncodeItem(R.Data.SDRSN);
  mmcblk0rpmb_EncodeItem(R.Data.SysUUID);
  mmcblk0rpmb_EncodeItem(R.Data.SysSN);
  mmcblk0rpmb_EncodeItem(R.Data.SysBrdSN);

  mmcblk0rpmb_EncodeItem(R.Data.Count);
  mmcblk0rpmb_EncodeItem(R.Data.AllCount);
  mmcblk0rpmb_EncodeItem(R.Data.PayCount);
//  mmcblk0rpmb_SetData(R.Data.DiskInfo,'','');
  if trim(R.Data.DiskInfo.Name)='' then
  begin
    mmcblk0rpmb_SetData(R.Data.DiskInfo,'DiskInfo',DiskInfo);
  end;
  mmcblk0rpmb_EncodeItem(R.Data.DiskInfo);

  XorEncode(@R.Data,sizeof(R.Data),@R.Head.DataSalt[0],sizeof(R.Head.DataSalt));
  R.Head.DataCRC1:=CRC16_Unit.CalcCRC16(@R.Data,sizeof(R.Data),0);
  R.Head.DataCRC1:=CRC16_Unit.CalcCRC16(@CRCSalt[1],length(CRCSalt),R.Head.DataCRC1);

try
  if sysutils.FileExists(fn) then
  begin
    try
      F:=TFileStream.Create(fn,fmOpenReadWrite)
    except
      on e:Exception do
      begin
        writeln('FileStream.Create(Read) ='+e.Message+'  ,LastOSError='+sysutils.SysErrorMessage(sysutils.GetLastOSError));
      end;

    end;
  end
  else
  begin
    sysutils.ForceDirectories(sysutils.ExtractFileDir(fn));
    try
    F:=TFileStream.Create(fn,fmCreate);
    except
      on e:Exception do
      begin
        writeln('FileStream.Create ='+e.Message+'  ,LastOSError='+sysutils.SysErrorMessage(sysutils.GetLastOSError));
      end;
    end;
  end;

  if F.Write(R,sizeof(R))<>sizeof(R) then
  begin
    writeln('Write Device(0) ERROR!!!');
  end;
  sysutils.FreeAndNil(F);

  Result:=True;
except
  Result:=False;
end;

end;


function mmcblk0rpmb_DecodeItem(var D:TRegFile_DataItem):Boolean;
var
  z:WORD;
begin
  Result:=False;
  if (trim(d.Data)='') and (Trim(d.Name)='') then
  begin
    Result:=True;
    exit;
  end;

  z:=CRC16_Unit.CalcCRC16(@D.Data[0],sizeof(D.Data),0);
  z:=CRC16_Unit.CalcCRC16(@CRCSalt[1],length(CRCSalt),z);
  if z<>D.CRC then
  begin
    fillchar(D,sizeof(d),0);
    exit;
  end;

  XorDecode(@D.Data[0],sizeof(D.Data),@D.DataSalt[0],sizeof(D.DataSalt));
  Result:=True;

end;

procedure mmcblk0rpmb_EncodeItem(var D:TRegFile_DataItem);
begin
  GetDataSalt(D.DataSalt[0],length(D.DataSalt));
  XorEncode(@D.Data,sizeof(D.Data),@D.DataSalt[0],sizeof(D.DataSalt));
  D.CRC:=CRC16_Unit.CalcCRC16(@D.Data[0],sizeof(D.Data),0);
  D.CRC:=CRC16_Unit.CalcCRC16(@CRCSalt[1],length(CRCSalt),D.CRC);
end;

procedure mmcblk0rpmb_SetData(var D:TRegFile_DataItem;Name:ansiString;Data:AnsiString);
var
  l:integer;
begin
  Fillchar(D,sizeof(d),0);
  if Name='' then
  exit;
  if Data='' then
  exit;


  l:=sizeof(D.Name)-1;
  l:=min(l,length(Name));
  move(Name[1],D.Name[0],l);

  l:=sizeof(D.Data)-1;
  l:=min(l,length(Data));
  move(Data[1],D.Data[0],l);
end;

function DoMmcblk0rpmb_Read(var R:Tmmcblk0rpmb):Boolean;
var
  F:TFileStream;
  i:integer;
  buff:array of byte;
  z:WORD;
  L:integer;
  f2:integer;
  fn:string;
begin
  Result:=false;
  mmcblk0rpmb_File_Get;

  F:=nil;
  Fillchar(R,sizeof(R),0);

  fn:=mmcblk0rpmb_File;
  if fn='ERROR' then
  exit;

  if not sysutils.FileExists(fn) then
  exit;
try
  try
    F:=TFileStream.Create(fn,fmOpenRead or fmShareDenyWrite);
  except
    on e:Exception do
    begin
      writeln('FileStream.Create ='+e.Message+'  ,LastOSError='+sysutils.SysErrorMessage(sysutils.GetLastOSError));
    end;
  end;

  L:=F.Read(R.Head,sizeof(R.Head));
  if L<>sizeof(R.Head) then
  begin
    sysutils.FreeAndNil(F);
//    f2:=baseunix.FpOpen(mmcblk0rpmb_File,O_RDONLY);
//    L:=baseunix.FpRead(f2,R.Head,sizeof(R.Head));
    if L<>sizeof(R.Head) then
    begin
      writeln(sysutils.SysErrorMessage(sysutils.GetLastOSError));
      exit;
    end;
  end;


  if not sysutils.SameText(mmcblk0rpmb_Flag,R.Head.Flag) then
  exit;

  if R.Head.Ver<>mmcblk0rpmb_Ver then
  exit;

  if not math.InRange(R.Head.DataSize,64,1024*1024) then
  exit;

  if not math.InRange(R.Head.HeadSize,64,4096) then
  exit;

  setlength(buff,R.Head.DataSize);
  F.Position:=R.Head.HeadSize;
  if F.Read(buff[0],R.Head.DataSize)<>R.Head.DataSize then
  exit;

  z:=CRC16_Unit.CalcCRC16(@buff[0],R.Head.DataSize,0);
  z:=CRC16_Unit.CalcCRC16(@CRCSalt[1],length(CRCSalt),z);

  if z<>R.Head.DataCRC1 then
  exit;

  XorDecode(@Buff[0],R.Head.DataSize,@R.Head.DataSalt[0],sizeof(R.Head.DataSalt));
  L:=sizeof(R.Data)*sizeof(R.Data.Count);
  L:=Min(R.Head.DataSize,L);

  system.Move(Buff[0],R.Data,L);

  if not mmcblk0rpmb_DecodeItem(R.Data.SDRSN) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.SysUUID) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.SysBrdSN) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.SysSN) then
  exit;

  if not mmcblk0rpmb_DecodeItem(R.Data.Count) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.AllCount) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.PayCount) then
  exit;
  if not mmcblk0rpmb_DecodeItem(R.Data.DiskInfo) then
  exit;

  Result:=True;

  finally
    if f<>nil then
    sysutils.FreeAndNil(F);
    if not Result then
    Fillchar(R,sizeof(R),0);;
  end;

end;

function mmcblk0rpmb_Read(var R:Tmmcblk0rpmb;FailedDoInit:Boolean=False):Boolean;
begin
  Result:=doMmcblk0rpmb_Read(R);
  if not Result then
  begin
    if FailedDoInit then
    begin
      mmcblk0rpmb_Init(0);
      Result:=doMmcblk0rpmb_Read(R);
    end;
  end;

end;

function mmcblk0rpmb_Fill(var R:Tmmcblk0rpmb):Boolean;
var
  T:integer;
  zz:int64Rec;
  l:integer;
  s:AnsiString;
begin
  Result:=false;
  Fillchar(R,sizeof(R),0);
//  mmcblk0rpmb_Read(R);
  R.Head.Flag:=mmcblk0rpmb_Flag;
  R.Head.Ver:=mmcblk0rpmb_Ver;
  R.Head.DataSize:=sizeof(R.Data);

  s:=sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',now);
  l:=length(s);
  l:=min(l,sizeof(R.Head.DataSalt));

  move(s[1],R.Head.DataSalt[0],l);

  R.Head.HeadSize:=sizeof(R.Head);

end;

function isMySysBoard:Boolean;
var
  s:String;
  R:Tmmcblk0rpmb;
begin
  Result:=False; //dmidecode -s system-serial-number        检测是否FB打头
  s:=SysBrdSN;
//  s:=GetSysBrd_SN;
//  if pos('FB',s)=1 then
  //Result:=true;

  {$IFDEF DEBUG}
    Result:=True;
//    exit;
  {$ENDIF}

  if pos('VMware-56 4d 8d',s)=1 then
  begin
    Result:=true;
//    mmcblk0rpmb:=False;
  end;

  if pos('LXPXT010057',s)=1 then
  begin
    Result:=true;
//    mmcblk0rpmb:=false;
  end;

  if mmcblk0rpmb then
  begin
    if not mmcblk0rpmb_CheckBoardMatch() then
    begin
      Result:=False;
      exit;
    end;
  end;

Result:=True;

end;

function GetSys_UUID:string;
var
  strlst:TStringList;
  i:integer;
  s:string;
const
  s1='UUID:';
begin
  //dmidecode -s system-serial-number
  Result:='';
  s:='';
  if not runCommand('dmidecode -t 1',s) then
  exit;

  strlst:=Tstringlist.Create;
  strlst.Text:=s;

  for i := 0 to strlst.Count-1 do
  begin
    s:=trim(strlst.Strings[i]);
    if pos(s1,s)=1 then
    begin
      Result:=copy(s,length(s1)+1,maxint);
      system.Break;
    end;
  end;
  sysutils.FreeAndNil(strlst);
  Result:=trim(Result);
end;

function GetSys_SN:string;
var
  strlst:TStringList;
  i:integer;
  s:string;
const
  s1='Serial Number:';
begin
  //dmidecode -s system-serial-number
  Result:='';
  s:='';
  if not runCommand('dmidecode -t 1',s) then
  exit;

  strlst:=Tstringlist.Create;
  strlst.Text:=s;

  for i := 0 to strlst.Count-1 do
  begin
    s:=trim(strlst.Strings[i]);
    if pos(s1,s)=1 then
    begin
      Result:=copy(s,length(s1)+1,maxint);
      system.Break;
    end;
  end;
  sysutils.FreeAndNil(strlst);
  Result:=trim(Result);

end;

function GetSysBrd_SN:string;
var
  strlst:TStringList;
  i:integer;
  s:string;
const
  s1='Serial Number:';
begin
  //dmidecode -s system-serial-number
  Result:='';
  s:='';
  if not runCommand('dmidecode -t 2',s) then
  exit;

  strlst:=Tstringlist.Create;
  strlst.Text:=s;

  for i := 0 to strlst.Count-1 do
  begin
    s:=trim(strlst.Strings[i]);
    if pos(s1,s)=1 then
    begin
      Result:=copy(s,length(s1)+1,maxint);
      system.Break;
    end;
  end;
  sysutils.FreeAndNil(strlst);
  Result:=trim(Result);
end;

function GetSysBrd_SN_D:DWORD;
var
  str:string;
  t:DWORD;
  z:boolean;
begin
  Result:=0;
//  str:=GetSysBrd_SN;
  str:=SysBrdSN;
  z:=False;
  if (pos('FB',Str)=1) then
  begin
    delete(str,1,3);
    z:=true;
  end;
  if (pos('VMware-',Str)=1) then
  begin
    delete(str,1,7);
    z:=true;
  end;
  if (pos('LXPXT',Str)=1) then
  begin
    delete(str,1,5);
    z:=true;
  end;
  if not z then
  exit;

  if TryStrToDWord(str,t) then
  Result:=T;

end;

function SysinfoWhere: string;
begin
if SDRSN='' then
SDRSN:=GetSDRSN(True);
  Result:=' (SDRSN='+sysutils.QuotedStr(SDRSN)+' COLLATE NOCASE) '
end;

function GetSDRSN(onlySDRSN:boolean):String;
var
  strlst:TStringList;
  s,s1,s2:string;
  i:integer;
  p1,p2:integer;
  crc1:word;

  xorkey:array[0..2-1] of byte absolute crc1;
  xor2:array[0..2-1] of byte;
  xor2_word:word absolute xor2;

  //crc_xor-sn

  l1,l2:integer;
  zz:array[0..32-1] of byte;
  b:boolean;
const
  snkey='Serial:';
begin
  Result:='';
  s:='';
  b:=false;
  try
    b:=RunCommand('bladeRF-cli -p',s)
  except
    b:=false;
  end;

  if not b then
  begin
    exit;
  end;
  strlst:=TStringList.Create;
  strlst.Delimiter:=#10;
  strlst.Text:=s;
  for i := 0 to strlst.Count-1 do
  begin
    s:=strlst.Strings[i];
    s:=trim(s);
    p1:=pos(snkey,s);
    if p1=0 then
    system.Continue;

    delete(s,1,p1+length(snkey));
    s:=trim(s);
    if s<>'' then
    begin
      Result:=s;
      system.Break;
    end;

  end;
  sysutils.FreeAndNil(strlst);

  if onlySDRSN then
  exit;

  s:=Result;
  if s='' then
  exit;

  l2:=length(s);

  //xor1 (CRC16 all+'_SDR')
  //xor2 随机
  // 4char xor
  // 4char xor
  // crc

  crc1:=CalcCRC16(s+'_SDR');
  sleep(13);
  system.Randomize;
  sleep(2);
  xor2[0]:=max(system.Random(250),12);

  sleep(5);
  system.Randomize;
  i:=system.Random(maxint) mod 180;
  i:=max(23,i);
  xor2[1]:=i;

  s2:=copy(s,l2-8,8);

  for i := 1 to 8 do
  begin
     s2[i]:=char(ord(s2[i]) xor xorkey[0]);
     s2[i]:=char(ord(s2[i]) xor xorkey[1]);
     s2[i]:=char(ord(s2[i]) xor xor2[0]);
     s2[i]:=char(ord(s2[i]) xor xor2[1]);
  end;
  Result:=inttohex(crc1,4)+inttohex(xor2_word,2)+'-';

  for i := 1 to 4 do
  begin
    Result:=Result+inttohex(ord(s2[i]),2);
  end;
  Result:=Result+'-';
  for i := 5 to 8 do
  begin
    Result:=Result+inttohex(ord(s2[i]),2);
  end;

end;


function GetMacHWForReg(R:PRegHW=nil):string;
var
  hwc:ansistring;
  brd:ansistring;
  R2:TRegHW;
  i:integer;
  buf:PByteArray;
  strlst:TStringList;
begin
  Result:='';
  strlst:=nil;

  fillchar(R2,sizeof(R2),0);
  if R<>nil then
  R2:=R^
  else
  FillRegHW(R2);

  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  strlst.Add(inttohex(R2.xor_1,2)+inttohex(R2.Xor_2,2)+inttohex(R2.V1,2)+inttohex(R2.product,2));

  strlst.Add(inttohex(R2.SDR,4)+inttohex(R2.MBSN,4));
  strlst.Add(inttohex(R2.LastCount,4)+inttohex(R2.AllCount,4));

  strlst.Add(inttohex(R2.PayCount,4)+inttohex(R2.CRC,2)+inttohex(R2.Xor_4,2));

  Result:=Strlst.DelimitedText;
  sysutils.FreeAndNil(strlst);
end;

function Str2RegHW(MacHWStr:string;var R:TRegHW):Boolean;
var
  strlst:TStringList;
  str:String;
  dw:TDWRec;
  buf:PByteArray;
  c:byte;
  i:integer;
begin
  //0000DAD1-D11EDBDB-DBDBDBDB-DBDB5D00

  Result:=False;
  fillchar(R,sizeof(R),0);

  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  strlst.DelimitedText:=MacHWStr;
  if strlst.Count<>4 then
  begin
    sysutils.FreeAndNil(strlst);
    exit;
  end;

  if not TryStrToDWord('0x'+strlst.Strings[0],dw.dw) then
  dw.int:=0;

  R.xor_1:=dw.Bytes[3];
  R.Xor_2:=dw.Bytes[2];
  R.V1:=dw.Bytes[1];
  R.product:=dw.Bytes[0];

  if not TryStrToDWord('0x'+strlst.Strings[1],dw.dw) then
  dw.int:=0;

  R.SDR:=dw.Words[1];
  R.MBSN:=dw.Words[0];

  if not TryStrToDWord('0x'+strlst.Strings[2],dw.dw) then
  dw.int:=0;
  R.LastCount:=dw.Words[1];
  R.AllCount:=dw.Words[0];

  if not TryStrToDWord('0x'+strlst.Strings[3],dw.dw) then
  dw.int:=0;
  R.PayCount:=dw.Words[1];
  r.CRC:=dw.Bytes[1];
  r.Xor_4:=dw.Bytes[0];
  buf:=@R;

  for i := 0 to sizeof(R)-2 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_4;
  end;

  c:=CalcCRC8(@R,sizeof(R)-2);
  if C<>R.CRC then
  exit;

  for i := 2 to sizeof(R)-3 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_2;
    buf^[i]:=buf^[i] xor R.Xor_1;
  end;

  Result:=True;

end;

function Str2RegCode(RegCodeStr:string;out R:TRegCode):Boolean;
var
  strlst:TStringList;
  str:String;
  dw:TDWRec;
  buf:PByteArray;
  c:byte;
  i:integer;
begin
  Result:=False;
  FillChar(R,sizeof(R),0);

  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  strlst.DelimitedText:=RegCodeStr;
  if strlst.Count<>3 then
  begin
    sysutils.FreeAndNil(strlst);
    exit;
  end;

  if not TryStrToDWord('0x'+strlst.Strings[0],dw.dw) then
  dw.int:=0;

  R.xor_1:=dw.Bytes[3];
  R.Xor_2:=dw.Bytes[2];
  R.V1:=dw.Bytes[1];
  R.product:=dw.Bytes[0];

  if not TryStrToDWord('0x'+strlst.Strings[1],dw.dw) then
  dw.int:=0;

  R.SDR:=dw.Words[1];
  R.MBSN:=dw.Words[0];

  if not TryStrToDWord('0x'+strlst.Strings[2],dw.dw) then
  dw.int:=0;

  sysutils.FreeAndNil(strlst);

  R.Count:=dw.Words[1];
  R.CRC:=dw.Bytes[1];
  R.Xor_4:=dw.Bytes[0];
  buf:=@R;
  for i := 0 to sizeof(R)-2 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_4;
  end;
  c:=CalcCRC8(@R,sizeof(R)-2);
  if R.CRC<>C then
  exit;
  //
  for i := 2 to sizeof(R)-3 do
  begin
    buf^[i]:=buf^[i] xor R.xor_2;
    buf^[i]:=buf^[i] xor R.xor_1;
  end;

  Result:=True;
end;

//
//SetxFxx-IMEI-RegCRC_CRC_xx
//
//SIME 设定,CIME,清除一下imei,如果串号是0000000...表示清空所有,  AIME ADD
//
function NewBindIMEICode(idx: integer; IMEI: String; Method: string; R: TRegHW): string;
var
  CRC1,CRC2:WORD;
  c:int64;
  i:integer;
  d:integer;
begin
Result:='';
if Method='' then
Method:='SIME';
  for i := 1 to length(imei) do
  begin
    if not (imei[i] in ['0'..'9']) then
    exit;
  end;
  if not sysutils.TryStrToInt64(imei,c) then
  exit;

  system.Randomize;
  d:=round(system.Random*100000000) mod 234;

  Result:=Method+inttostr(idx)+'F';
  Result:=Result+inttohex(d,2)+'-';

  Result:=Result+IMEI+'-';
  CRC1:=CRC16_Unit.CalcCRC16(@R,sizeof(R),0);
  Result:=Result+inttohex(CRC1,4);
  CRC2:=CRC16_Unit.CalcCRC16(sysutils.LowerCase(Result+CRCSalt));
  Result:=Result+inttohex(CRC2,4);
end;

function BindIMEI(BindIMEICode:AnsiString;R:TRegHW;OnlyCheck:Boolean=False):String;
var
  idx:integer;
  s,s2:AnsiString;
  crc2,crr1:integer;
  strlst:TStringList;
  T:int64;
  i,j:integer;
  cmd:string;
  imei:string;
begin
  idx:=0;
  imei:='';
  Result:='';
  strlst:=nil;
  BindIMEICode:=trim(BindIMEICode);
  BindIMEICode:=sysutils.UpperCase(BindIMEICode);

  if length(BindIMEICode)<10 then
  exit;

  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  strlst.DelimitedText:=BindIMEICode;
  while True do
  begin
    if strlst.Count<>3 then
    begin
      system.Break;
    end;

    //cmd
    s:=strlst.Strings[0];
    cmd:=copy(s,1,4);
    delete(s,1,4);
    if sysutils.SameText(cmd,'SIME') or sysutils.SameText(cmd,'CIME') or sysutils.SameText(cmd,'AIME') then
    begin
      cmd:=sysutils.UpperCase(cmd);
    end
    else
    begin
      system.Break;
    end;

    //index
    if not (s[1] in ['0'..'9','A'..'F']) then
    system.Break;

    if not sysutils.TryStrToInt(s[1],idx) then
    begin
      system.Break;
    end;

    s:=trim(strlst.Strings[1]);
    if length(s)<>15 then
    system.Break;
    if not sysutils.TryStrToInt64(s,T) then
    system.Break;

    //all CRC
    s:=trim(strlst.Strings[2]);
    if length(s)<>8 then
    begin
      system.Break;
    end;
    s2:='0x'+copy(s,5,4);
    if not sysutils.TryStrToInt(s2,j) then
    begin
      system.Break;
    end;

    s:=BindIMEICode;
    setlength(s,length(s)-4);
    i:=CRC16_Unit.CalcCRC16(sysutils.LowerCase(s+CRCSalt));

    if i<>j then
    begin
      system.Break;
    end;

    //CRC R

    i:=CRC16_Unit.CalcCRC16(@R,sizeof(R));

    s:=trim(strlst.Strings[2]);
    setlength(s,4);
    s:='0x'+s;

    if not sysutils.TryStrToInt(s,j) then
    system.Break;

    if i<>j then
    system.Break;

    imei:=trim(strlst.Strings[1]);
    Result:=imei;
    if OnlyCheck then
    system.Break;

    if sysutils.SameText(cmd,'AIME') then
    begin
      if SelfIMEIList.IndexOf(imei)=-1 then
      begin
        SelfIMEIList.Add(imei);
      end;
      dmunit.DataModule1.SetSysValue('UserIMEI',SelfIMEIList.DelimitedText);
      system.Break;
    end;

    if sysutils.SameText(cmd,'SIME') then
    begin
      if idx>=SelfIMEIList.Count then
      begin
        if SelfIMEIList.IndexOf(imei)=-1 then
        begin
          SelfIMEIList.Add(imei);
        end;
      end
      else
      begin
        SelfIMEIList.Strings[idx]:=imei;
      end;

      dmunit.DataModule1.SetSysValue('UserIMEI',SelfIMEIList.DelimitedText);
      system.Break;
    end;

    if sysutils.SameText(cmd,'CIME') then
    begin
      if Result='000000000000000' then
      begin
        SelfIMEIList.Clear;
      end
      else
      begin
        if (idx<SelfIMEIList.Count) and (idx>=0) then
        begin
          SelfIMEIList.Delete(idx);
        end;
      end;

      dmunit.DataModule1.SetSysValue('UserIMEI',SelfIMEIList.DelimitedText);
      system.Break;
    end;

  end;
  if strlst<>nil then
  sysutils.FreeAndNil(strlst);

  Result:=imei;

end;

//DecC_次数  用于扣次数
function NewDecCountCode(Count:integer):string;
begin
  Result:='DecC-'+inttostr(count);
end;

function NewRegCode(Count:integer;RegHW:PRegHW=nil):string;
var
  Mac:TRegHW;
  R:TRegCode;
  buf:PByteArray;
  i:integer;
begin
  Result:='';
  if RegHW=nil then
  begin
    FillRegHW(Mac);
  end
  else
  begin
    Mac:=RegHW^;
  end;

  fillchar(R,sizeof(R),0);
  sleep(10);
  system.Randomize;
  R.Xor_1:=max(system.Random(240),13);
  sleep(5);
  system.Randomize;
  sleep(11);
  system.Randomize;
  i:=system.Random(maxint);
  i:=i mod $3A;


  R.Xor_2:=max(i,21);
//  R.Xor_2:=RegCode_Res;

  R.Xor_2:= CRC8_Unit.CalcCRC8(@Mac,sizeof(Mac));

  R.V1:=Product_BTS_SMS_Modem_Ver;
  R.product:=Product_BTS_SMS_Modem;

  R.SDR:=Mac.SDR;
  R.MBSN:=Mac.MBSN;

  R.Count:=Count;

  R.CRC:=CalcCRC16(@R,sizeof(R)-2);

  system.Randomize;
  sleep(9);
  sleep(8);
  i:=max(system.Random(250),12);
  i:=i mod $5D;
  R.Xor_4:=i;

  buf:=@R;

  for i := 2 to sizeof(R)-3 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_1;
    buf^[i]:=buf^[i] xor R.Xor_2;
  end;

  R.CRC:=CalcCRC8(@R,sizeof(R)-2);

  for i := 0 to sizeof(R)-2 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_4;
  end;

  Result:=inttohex(R.Xor_1,2)+inttohex(R.Xor_2,2)+inttohex(R.V1,2)+inttohex(R.product,2)+'-';
  Result:=Result+inttohex(R.SDR,4)+inttohex(R.MBSN,4)+'-';
  Result:=Result+inttohex(R.Count,4)+inttohex(R.CRC,2)+inttohex(R.Xor_4,2);

end;

function DoRegCheck(RegStr: string; MacStr: string): boolean;
var
  R:TRegCode;
  M:TRegHW;
  hwc:string;
  w:WORD;
  c1,c2,c3:integer;
begin
  Result:=False;
  fillchar(R,sizeof(R),0);
  fillchar(M,sizeof(M),0);
  if not Str2RegCode(RegStr,R) then
  exit;
  if not Str2RegHW(MacStr,M) then
  exit;
  hwc:=GetSDRSN(True);
  W:=CalcCRC16(hwc+'R');
  if w<>R.SDR then
  exit;
  if R.Xor_2<>CalcCRC8(@M,Sizeof(M)) then
  exit;

  Result:=True;
end;

function DoReg(RegStr:string;MacStr:string):integer;
var
  R:TRegCode;
  hwc:string;
  w:WORD;
  c1,c2,c3:int64;
  emmc:Tmmcblk0rpmb;
begin
  Result:=-1;
  if not DoRegCheck(RegStr,MacStr) then
  exit;

  if not Str2RegCode(RegStr,R) then
  exit;

  hwc:=GetSDRSN(True);
  W:=CalcCRC16(hwc+'R');
  if w<>R.SDR then
  exit;

  if R.V1<>Product_BTS_SMS_Modem_Ver then
  exit;

  if R.product<>Product_BTS_SMS_Modem then
  exit;

  c1:=GetHWCount;
  c2:=GetHWAllCount;
  c3:=GetPayCount;

  c1:=c1+Max(R.Count,0);
  c2:=c2+Max(R.Count,0);
  c3:=c3+1;
  dmunit.DataModule1.SetSysValue('HWCount',inttostr(c1),True);
  dmunit.DataModule1.SetSysValue('HWAllCount',inttostr(c2),True);
  dmunit.DataModule1.SetSysValue('PayCount',inttostr(c3),True);


  if mmcblk0rpmb then
  begin
    mmcblk0rpmb_Read(emmc);

    emmc.Data.Count.Data:=inttostr(c1);
    emmc.Data.AllCount.Data:=inttostr(c2);
    emmc.Data.PayCount.Data:=inttostr(c3);
    if not mmcblk0rpmb_Write(emmc) then
    begin
      Result:=-100;
      exit;
    end;
  end;

  Result:=R.Count;

end;

function FillRegHW(var R:TRegHW):Boolean;
var
  hwc:ansistring;
  brd:ansistring;
//  R:TRegID;
  i:integer;
  buf:PByteArray;
begin
  Result:=False;
//  if SDRSN='' then
//  exit;

  fillchar(R,sizeof(R),0);
  sleep(10);
  system.Randomize;
  R.xor_1:=max(system.Random(250),13);
  sleep(11);
  system.Randomize;
  i:=system.Random(maxint);
  i:=i mod 150;

  R.Xor_2:=max(i,24);
//  R.Xor_2:=RegCode_Res;

  R.V1:=Product_BTS_SMS_Modem_Ver;
  R.Product:=Product_BTS_SMS_Modem;

  hwc:=SDRSN;
  R.SDR:=CalcCRC16(hwc+'R');
//  brd:=GetSysBrdSN;
//  R.CPU:=CalcCRC16_R(brd+'B',3);

  R.MBSN:=GetSysBrd_SN_D;

  R.LastCount:=GetHWCount;
  R.AllCount:=GetHWAllCount;
  R.PayCount:=GetPayCount;

  R.CRC:=CalcCRC16(@R,sizeof(R)-1);

  system.Randomize;
  sleep(9);
  sleep(8);
  R.Xor_4:=max(system.Random(150),23);


  buf:=@R;

  for i := 2 to sizeof(R)-3 do
  begin
    buf^[i]:=buf^[i] xor R.xor_1;
    buf^[i]:=buf^[i] xor R.xor_2;
  end;

  R.CRC:=CalcCRC8(@R,sizeof(R)-2);

  for i := 0 to sizeof(R)-2 do
  begin
    buf^[i]:=buf^[i] xor R.Xor_4;
  end;

end;

function GetMacID():String;
var
  strlst:TStringList;
  s:AnsiString;
  d:DWORD;
  M:TMacID;
  c:integer;
  l:integer;
  buf:PByteArray;
  buf2:PintegerArray;
  i:integer;
begin
  Result:='';
  //abcd-abcd-abcd
  //macsdr,sdr-mac-crc
  //85583E37-B1E4E1E3-E5B7E4B5
//  if SDRSN='' then
//  exit;

  fillchar(M,sizeof(M),0);
  m.SysBrdSN:=GetSysBrd_SN_D;
  m.SysSDRSN:=CalcCRC16(SDRSN+'R');
  M.SysUUIDSN:=CalcCRC16(GetSys_UUID+'U');
  M.res:=0;
  system.Randomize;
  sleep(10);
  c:=system.Random(maxint);
  M.XorKey1:=c div 137;
  M.XorKey1:=max($21,M.XorKey1);

  system.Randomize;
  sleep(10);
  c:=system.Random(maxint-768);
  M.XorKey2:=c mod 231;

  m.CRC:=CalcCRC8(@M,sizeof(M)-4);
  buf:=@M;
  L:=sizeof(M)-4;
  for i := 0 to L-1 do
  begin
    buf^[i]:=buf^[i] xor M.XorKey1;
    buf^[i]:=buf^[i] xor M.XorKey2;
  end;

  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  buf2:=@M;
  strlst.Add(inttoHex(buf2^[0],8));
  strlst.Add(inttoHex(buf2^[1],8));
  strlst.Add(inttoHex(buf2^[2],8));
  Result:=strlst.DelimitedText;
  sysutils.FreeAndNil(strlst);
end;

function Str2MacID(str:String;out M:TMacID):Boolean;
var
  strlst:TStringList;
  l,i:integer;
  buf:PByteArray;
  buf2:PDWORDArray;
begin
  Result:=False;
  fillchar(M,sizeof(m),0);
  strlst:=TStringList.Create;
  strlst.Delimiter:='-';
  strlst.DelimitedText:=str;
  if strlst.Count<>3 then
  begin
    sysutils.FreeAndNil(strlst);
    exit;
  end;
  buf2:=@M;
try
  if not TryStrToDWord('0x'+strlst.Strings[0],buf2^[0]) then
  exit;
  if not TryStrToDWord('0x'+strlst.Strings[1],buf2^[1]) then
  exit;
  if not TryStrToDWord('0x'+strlst.Strings[2],buf2^[2]) then
  exit;

  buf:=@M;
  l:=sizeof(M)-4;
  for i := 0 to L-1 do
  begin
    buf^[i]:=buf^[i] xor M.XorKey2;
    buf^[i]:=buf^[i] xor M.XorKey1;
  end;
  if m.CRC<>CalcCRC8(@M,sizeof(M)-4) then
  exit;


  Result:=True;
finally
  if strlst<>nil then
  sysutils.FreeAndNil(strlst);
end;


end;

function BindIMEI(BindIMEICode:AnsiString;MacStr:AnsiString;OnlyCheck:Boolean=False):String;
var
  HW:TRegHW;
begin
  Result:='';
  if not Str2RegHW(MacStr,HW) then
  exit;

  Result:=BindIMEI(BindIMEICode,HW,OnlyCheck);

end;

function GetMainDisk_Feature: string;
var
  s,s2:string;
  strlst:TStringList;
  i,j:integer;
  a,b:string;
begin
  Result:='';
  s:='/dev/sda';
  if not sysutils.FileExists(s) then
  begin
    s:='';
    exit;
  end;

  s:='hdparm -i '+s;
  s2:='';
  try
    RunCommand(s,s2);
  except
    exit;
  end;
  strlst:=TStringList.Create;
  strlst.DelimitedText:=s2;
  while strlst.Count>10 do
  begin
    strlst.Delete(strlst.Count-1);
  end;
  a:='M='+strlst.Values['Model'];
  b:='SN='+strlst.Values['SerialNo'];
  Result:=A+','+B;

end;


type
  TCPUID = array[1..4] of Longint;   //获取CPUID用
  TVendor = array [0..11] of char;   //获取CPUID用

function GetCPUID: TCPUID; assembler; register;
asm
  PUSH EBX {Save affected register}
  PUSH EDI
  MOV EDI,EAX {@Resukt}
  MOV EAX,1
  DW $A20F {CPUID Command}
  STOSD {CPUID[1]}
  MOV EAX,EBX
  STOSD {CPUID[2]}
  MOV EAX,ECX
  STOSD {CPUID[3]}
  MOV EAX,EDX
  STOSD {CPUID[4]}
  POP EDI {Restore registers}
  POP EBX
end;

Function GetCPUVendor: TVendor; assembler; register;
asm
  PUSH EBX {Save affected register}
  PUSH EDI
  MOV EDI,EAX {@Result (TVendor)}
  MOV EAX,0
  DW $A20F {CPUID Command}
  MOV EAX,EBX
  XCHG EBX,ECX {save ECX result}
  MOV ECX,4
  @1:
  STOSB
  SHR EAX,8
  LOOP @1
  MOV EAX,EDX
  MOV ECX,4
  @2:
  STOSB
  SHR EAX,8
  LOOP @2
  MOV EAX,EBX
  MOV ECX,4
  @3:
  STOSB
  SHR EAX,8
  LOOP @3
  POP EDI {Restore registers}
  POP EBX
end;

function GetCPUID_Str:string;
var
  CPUID: TCPUID;
  I: Integer;
  c:TVendor;
begin
  for I := Low(CPUID) to High(CPUID) do
  begin
    CPUID[I] := -1;
  end;

  CPUID := GetCPUID;
  Result := IntToHex(CPUID[1], 8) + IntToHex(CPUID[3], 8) + IntToHex(CPUID[4], 8);
end;

end.

