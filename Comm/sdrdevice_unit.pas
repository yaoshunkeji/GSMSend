unit SDRDevice_Unit;

{$mode delphi}{$H+}

{.$DEFINE _WindowsOnly_}

{$define Test}

interface

uses
  Classes, SysUtils, math, dateutils, zlib,syncobjs,strutils,forms
  {$IFNDEF _WindowsOnly_}
  ,process
  ,CommFunUnit,hw_fununit,BaseUnix
  {$ENDIF}
  ,FileFormat_Unit ;

const
  __BaseFreqOff__=70000000;   //偏移50M，避免·被人猜出    默认值
  __DefWaveSample__=16000;    //生成小声音文件时，使用采样率

//实际给出wave时，使用(Freq-BaseFreqOff)*5+5000G




var
  IQDataMaxSize:int64=256*MB;
  {
  为保证数据简单化，  先写完或分备完基础数据，后面全部是IQ数据
  1.写入文件头(占位),写入系统信息头,写入系统信息(压缩),写入IQ数据头(占位)
  2.根据IQ头中定义的Slat，处理后。写入数据，
    如果需要 压缩，每个包，一个IQ头


  IQ头永远在最后，IQ后面不再有其它数据， 省的解码麻烦,写数据麻烦

  结果文件时，对所有数据头进行加盐
    }

type
  { TSDR }

  {$IFDEF _WindowsOnly_}
  TSDR = class(TObject)
  {$ELSE}
  TThread2=class;
  TSDR = class(TThread)
  {$ENDIF}
  private
    FAGC1: integer;
    FDeviceIndex: integer;
    FDeviceType: TDeviceType;
    FDirectSample: Boolean;
    FFreq: int64;
    FOPMode: integer;
    FSamRate: DWORD;
    BufList:TThreadList;
    FEvent:TEvent;
    FSwapIQ: Boolean;
    FWaitWriteDoneEvent:TEvent;
    FCurIQFileName:string;
    FCurAMFileName:string;

    FProgressCur,FProgressMax:int64;
    FProgressMode:integer;

    FOnProgress: TProgressEvent;
    {$IFNDEF _WindowsOnly_}
    function BufItemCount: integer;
    {$ENDIF}
    function CheckFileHead(var FileHead: TFileHead; Stream: TStream): Boolean;
    procedure ClearBufList;
    procedure Compress_Zlib(Data: Pointer; Len: DWORD);
    function GetTempFileName: string;

    procedure IQData_DeSlat(buf: PByteArray; len: integer);
    procedure IQData_EnSlat(buf: PByteArray; len: integer);

    procedure EnSlat(buf: PByteArray; len: integer;Slat:PByteArray;SlatLen:integer;SlatIdx:Pinteger=nil);
    procedure DeSlat(buf: PByteArray; len: integer;Slat:PByteArray;SlatLen:integer;SlatIdx:Pinteger=nil);
    procedure NullData;

    function PopBufItem: TIQData;
    procedure ProcHead_EndPack(var dph: TDataPackHead; S: TStream; StartPos: int64; Len: int64);overload;    //根据数据，处理包头，
    procedure ProcHead_EndPack(var dph: TDataPackHead);overload;
    procedure SetDeviceIndex(AValue: integer);
    procedure SetSamRate(AValue: DWORD);
    procedure SetFreq(AValue: int64);
  protected
    FileHead:TFileHead;
    PackFile:TFileStream;
    RawFile:TFileStream;
    StrData:TStringList;
    TmpMem1:TMemoryStream;
    TmpMem2:TMemoryStream;
    TmpFile:string;

    IQSlatIndex_En:integer;
    IQSlatIndex_De:integer;
    IQDph:TDataPackHead;
    IQMap:array of TComplexSingle;
    IQMapSize:integer;
    {$IFNDEF _WindowsOnly_}
    StopFlag:TLockValue;
    {$ENDIF}
    function GetSampleBit: Byte;virtual;
    procedure DoProgress();
    {$IFNDEF _WindowsOnly_}


    function GetDeviceType: TDeviceType;virtual;

    procedure SetDeviceType(DeviceType: TDeviceType);virtual;
    function DoOpenDevice:Boolean;virtual;
    function DoCloseDevice:Boolean;virtual;

    function DoStartIQ:Boolean;virtual;
    function DoStopIQ:Boolean;virtual;
    function DoSetSampleRate:Boolean;virtual;

    function DoSetFreq(Freq:Int64): Boolean;virtual;
    procedure SetOPMode(AValue: integer);virtual;

    procedure DoOpenFile(AndWriteIQHead:Boolean=True);virtual;
    function DoEndFile(ByThreadCall:Boolean): Boolean;virtual;

    function RecvIQData(buf: pByte; len: dword): boolean;
    function GetDiskSpace(Dir:string='/tmp/'):int64;virtual;
    procedure SetAGC1(AValue: integer);virtual;

    procedure DoWork;

    procedure Execute;override;

    procedure WriteLog_No0(ID: integer; Str: String='');overload;
    procedure WriteLog(str: string);overload;
    procedure WriteLog(T: int64);overload;
    {$ENDIF}
    procedure Progress(Cur,Max:int64;UseThreadSyncProc:Boolean=True;Mode:integer=0);
    procedure InitIQMap();virtual;
    procedure Swap_Byte(buff: Pointer; BufSize: integer);
    procedure Swap_Word(buff: Pointer; BufSize:integer);
  public
    {$IFNDEF _WindowsOnly_}

    property DeviceIndex:integer read FDeviceIndex write SetDeviceIndex default 0;
    property DeviceType:TDeviceType read GetDeviceType;
    property Freq:int64 read FFreq write SetFreq;
    property DirectSample:Boolean read FDirectSample write FDirectSample;

    property OnProgress:TProgressEvent read FOnProgress write FOnProgress;
    property OPMode:integer read FOPMode write SetOPMode;
    property AGC1:integer read FAGC1 write SetAGC1;
    property SwapIQ:Boolean read FSwapIQ write FSwapIQ;

    function GetDeviceCount():integer;virtual;
    function StartIQ:Boolean;virtual;

    function InternalStopIQ(ByThreadCall:Boolean):Boolean;
    function StopIQ:Boolean;virtual;
    function ReadDeviceEEPROM(buf:PByte;len:DWORD;StartAddr:integer=0):integer;virtual;overload;    //返回大小, StartAddr=-1 表示从真正的flash开始0位置
    function ReadDeviceEEPROM(fn:string;All:Boolean=false):Boolean;virtual;overload;
    function OpenDevice:boolean;
    function CloseDevice:boolean;
    function CompressFile(fn: String; destfn: String):boolean;
    {$ENDIF}
    property SamRate:DWORD read FSamRate write SetSamRate;
    property CurFileName:string read FCurIQFileName;
    property CurAMFileName:string read FCurAMFileName;
    property SampleBit:Byte read GetSampleBit default 8;


    function CheckCurData(out info:TIQDataInfo):boolean;
    procedure Sample2Complex(buf: Pointer; BufSize: DWORD; Complex: PComplexSingle_Array);virtual;
    procedure Sample2Single(buf: Pointer; BufSize: DWORD; Complex: PSingleArray);virtual;
    procedure Sample2Single_Byte(buf: Pointer; BufSize: DWORD; Dest: PSingleArray);virtual;
    function DeFile(fn: string; destfn: string; DecodeMode: TDecodeMode;InfoList:TStrings): Boolean;
    function DeFile_IQ(fn: string; destfn: string; DecodeMode: TDecodeMode; SampleRate: integer;SampleBit: integer): Boolean;
    function AMFile2AuWave(fn,dest:string):Boolean;
    constructor Create();
    destructor Destroy; override;

    class function GetBaseFreqOff(OpMode:integer=1):int64;virtual;
  end;

  {$IFNDEF _WindowsOnly_}
  { TThread2 }

  TThread2 = class(TThread)
  private
    FEvent:TEvent;
  protected
    obj:Pointer;
    procedure Execute;override;
    procedure DoWork;virtual;
  public
    property Event:TEvent read FEvent write FEvent;
    constructor Create(aObj:Pointer);virtual;
    destructor Destroy; override;
  end;

  {$ENDIF}
var
  WanIP:TStringList=nil;
  LocalIP:TStringList=nil;
  IQSaveDir:String='';

var
  BaseFreqOff:integer=__BaseFreqOff__;   //偏移50M，避免·被人猜出    默认值
  DefWaveSample:integer=__DefWaveSample__;    //生成小声音文件时，使用采样率

implementation

{ TSDR }

{
加密方案


HARDID:
SLAT4		-	CRC2,Prod_VER1,DataHwLen	-	Data	-	CPUCRC2,DiskCRC2

1.主机上一个key.dat文件。
2.rtlsdr中，写入一个hardid
  删掉rtl的信息，但这几个信号不用于判断，eeprom最后64byte用于保存hardid数据



Vendor ID:		0x0ccd
Product ID:		0x00a9
Manufacturer:
Product:
Serial number:		00000001
Serial number enabled:	yes
IR endpoint enabled:	yes
Remote wakeup enabled:	no




root@raspberrypi /tmp # time zip -1 -k 1 2015-11-21_160959.dat
  adding: 2015-11-.DAT (deflated 75%)

real	0m37.489s
user	0m35.280s
sys	0m1.400s
root@raspberrypi /tmp # time zip -5 -k 1 2015-11-21_160959.dat
updating: 2015-11-.DAT^C


zip error: Interrupted (aborting)

real	0m0.849s
user	0m0.830s
sys	0m0.020s
root@raspberrypi /tmp # time zip -5 -k 5 2015-11-21_160959.dat
  adding: 2015-11-.DAT (deflated 84%)

real	1m16.519s
user	1m14.160s
sys	0m0.990s
root@raspberrypi /tmp # time zip -4 -k 4 2015-11-21_160959.dat
  adding: 2015-11-.DAT (deflated 82%)

real	0m52.970s
user	0m51.800s
sys	0m1.150s


}

uses
  CRC16_Unit,CRC8_Unit,CRC32_unit
  {$IFNDEF _WindowsOnly_}
  ,GetIPInfoUnit,rtlsdr_sdk_unit,hackrf_Unit ,SafeData_unit
  {$ENDIF}
  ;

{$IFDEF _WindowsOnly_}
function uncompress(dest: pbytef; destLen: puLongf; source: pbytef; sourceLen: uLong):integer;
var
  L:integer;
begin
  Result:=-1;
  try
    L:=destlen^;
    DecompressToUserBuf(source,sourceLen,dest,L);
    Result:=0;
  except
  end;
end;
{$ENDIF}



class function TSDR.GetBaseFreqOff(OpMode:integer):int64;
begin
  Result:=__BaseFreqOff__;
  case OPMode of
    0: Result:=70*10000000;
    1: Result:=10000000;
  end;
end;
{$IFNDEF _WindowsOnly_}
function GetHardInfo(strlst:TStringList):Boolean;
var
  d:TDiskInfo;
begin
  Result:=false;
  strlst.Clear;
//  {$IFDEF ARM}
  strlst.Add('CPU_ID='+GetCPUID_Str);
  strlst.Add('Disk_ID='+GetDiskID_Str);
//  strlst


end;


procedure FillStr(Str:ansiString;Buff:PByte;Len:DWORD);
var
  l:integer;
begin
  fillchar(Buff^,Len,0);
  l:=length(str);
  l:=min(l,Len);
  Move(Str[1],buff^,l);
end;

procedure FillDataPackHead(F:TStream;var dph:TDataPackHead;DataType:TDataType);
begin
  fillchar(dph,sizeof(dph),0);
  FillStr(DataPackHead_Flag,@dph.HeadFlag[0],length(dph.HeadFlag));

  dph.DataType:=integer(DataType);
  dph.DataStartPos:=F.Size+sizeof(dph);
  system.Randomize;
  dph.DataSlat:=GetDataSalt(length(dph.DataSlat));

end;

{ TThread2 }

procedure TThread2.DoWork;
begin



end;

procedure TThread2.Execute;
begin
  while(not self.Terminated) do
  begin
    if self.Event.WaitFor(INFINITE)<>wrSignaled then
      system.Continue;
    if self.Terminated then
      system.Break;

    self.DoWork;
  end;

end;

constructor TThread2.Create(aObj:Pointer);
begin
  inherited Create(True);
  self.FreeOnTerminate:=false;
  self.obj:=aObj;
  self.FEvent:=TEvent.Create(nil,false,false,'Event_'+self.ClassName+'_'+inttostr(DWORD(self)));
  self.Resume;
end;

destructor TThread2.Destroy;
begin
  inherited Destroy;
end;

procedure TSDR.SetDeviceIndex(AValue: integer);
begin
  if FDeviceIndex=AValue then
    Exit;
  FDeviceIndex:=AValue;
end;

procedure TSDR.SetOPMode(AValue: integer);
begin
  FOPMode:=AValue;


end;

function TSDR.GetDeviceType: TDeviceType;
begin
  Result:=dt_None;
end;

procedure TSDR.Compress_Zlib(Data:Pointer;Len:DWORD);
var
  l:DWORD;
begin
  self.TmpMem2.Clear;
  self.TmpMem2.Size:=Len+4096;
  L:=Len;
  zlib.compress2(self.TmpMem2.Memory,@L,Data,Len,Z_BEST_SPEED);
  self.TmpMem2.Size:=L;
end;

procedure TSDR.ProcHead_EndPack(var dph:TDataPackHead);
var
  b:pbyte;
  b2:Pointer;
  P:int64;
begin
  b:=Pbyte(@dph);
  inc(b,4);
  b2:=b;

  P:=dph.DataStartPos-sizeof(dph);
  self.EnSlat(b2,sizeof(dph)-4,@self.FileHead.head2.dph_Slat[0],length(self.FileHead.head2.dph_Slat));
  dph.CRC16:=CRC16_Unit.CalcCRC16(b,sizeof(dph)-4);
  self.PackFile.Position:=p;
  self.PackFile.Write(dph,sizeof(dph));
end;

procedure TSDR.SetAGC1(AValue: integer);
begin
  if FAGC1=AValue then Exit;
  FAGC1:=AValue;
end;

procedure TSDR.ProcHead_EndPack(var dph:TDataPackHead;S:TStream;StartPos:int64;Len:int64);
const
  BufCap=16384;
var
  oldP,P:int64;
  buf:array[0..BufCap-1] of Byte;
  buflen:integer;
  L:int64;
  C:WORD;
  b:pbyte;
  b2:Pointer;
  idx:integer;
begin
  oldP:=s.Position;
  dph.DataSize:=Len;
  L:=Len;
  C:=StartPos;
  s.Position:=0;
  while L>0 do
  begin
    buflen:=Min(BufCap,L);
    buflen:=S.Read(buf[0],buflen);
    if buflen=0 then
      system.Break;
    L:=L-BufLen;

    C:=CRC16_Unit.CalcCRC16(@buf[0],buflen,C)
  end;
  s.Position:=OldP;
  dph.DataCRC:=C;
  ProcHead_EndPack(dph);
end;

procedure TSDR.DoOpenFile(AndWriteIQHead:Boolean=True);
var
  s,s2:ansiString;
  d:TDiskInfo;
  i:integer;
  dph:TDataPackHead;
  dd:DWORD;
  a,b:int64;
begin
  if IQSaveDir='' then
    IQSaveDir:=GetCurDeskPath+'/data/';
  if not sysutils.DirectoryExists(IQSaveDir) then
    begin
      sysutils.ForceDirectories(IQSaveDir);
      try
        s:='chmod a+rx -R "'+IQSaveDir+'"';
        s2:='';
        RunCommand(s,s2);
      except
      end;
    end;
  self.FCurIQFileName:=IQSaveDir+'/'+sysutils.FormatDateTime('yyyy-MM-dd_HHnnss',now)+'.dat';
  {$ifdef test}
    self.FCurIQFileName:='/tmp/test.dat';
    self.RawFile:=TFileStream.Create('/tmp/test_IQ.dat',fmCreate);
  {$endif}

  s:='';

  self.IQSlatIndex_En:=0;
  self.IQSlatIndex_De:=0;

  FillChar(IQDph,sizeof(IQDph),0);

  FillChar(self.FileHead,sizeof(self.FileHead),0);
  FileHead.Head1.FileVer[0]:=FileVer1;
  FileHead.Head1.FileVer[1]:=FileVer2;
  FillStr(Flag1,@FileHead.Head1.Flag1[0],length(FileHead.Head1.Flag1));
  FillStr(Flag2,@FileHead.Head1.Flag2[0],length(FileHead.Head1.Flag2));

  FileHead.Head1.Head2Size:=sizeof(FileHead.head2);
  GetDataSalt(FileHead.Head1.Head2Slat[0],length(FileHead.Head1.Head2Slat),false);

  FileHead.Head2.SoftVer:=DateTime_DateTime2(GetLastCompileTime);
  FileHead.Head2.FileDate:=DateTime_DateTime2(Now);
  FileHead.Head2.DeviceType:=integer(self.FDeviceType);
  FileHead.Head2.Freq:=self.Freq;
  FileHead.Head2.SampleRate:=self.SamRate;
  FileHead.Head2.SampleBit:=self.SampleBit;
  GetDataSalt(FileHead.Head2.dph_Slat[0],length(FileHead.Head2.dph_Slat));

  StrData.Clear;
  StrData.Add('CPU_Serial='+hw_fununit.GetCPUID_Str);
//  StrData.Add('Disk_SN=',)
  StrData.Add('MacAddr_eth0='+MacAddr_eth0);
  StrData.Add('MacAddr_wlan0='+MacAddr_wlan0);

  StrData.AddStrings(WanIP);
  for i := 0 to LocalIP.Count-1  do
  begin
    StrData.AddStrings('LocalIP_'+LocalIP.Strings[i]);
  end;
  StrData.AddStrings('getwanip_www_ip138_com='+IPINFO_getwanip_www_ip138_com);
  StrData.AddStrings('getwanip_dns_aizhan_com='+IPINFO_getwanip_dns_aizhan_com);

  StrData.Add('CPUInfo='+CPUInfo);
  //StrData.Add('Mem')
  d:=GetDisk_Auto();
  s:=sysutils.ExtractFileName(d.KNAME);

  StrData.Add('Disk_'+s+'_SN='+d.SERIAL);
  StrData.Add('Disk_'+s+'_Model='+d.MODEL);
  StrData.Add('Disk_'+s+'_Size='+SmartSize_1000(d.SIZE));
  StrData.Add('Disk_'+s+'_Size_Byte='+inttostr(d.SIZE));
  StrData.Add('Disk_'+s+'_Type='+d.Type_);
  StrData.Add('Disk_'+s+'_VENDOR='+d.VENDOR);
  StrData.Add('Disk_'+s+'_FwRev='+d.FwRev);
  StrData.Add('Disk_'+s+'_SIZE='+inttostr(d.SIZE));


  StrData.Add('EXEInfo_FileSize='+inttostr(GetFileSize(system.ParamStr(0))));
  StrData.Add('EXEInfo_FileName='+system.ParamStr(0));
  dd:=0;
  CRC32_unit.GetCRC32File(system.ParamStr(0),DD);
  StrData.Add('EXEInfo_FileCRC32=$'+sysutils.IntToHex(dD,8));
  dD:=CRC16_Unit.CalcCRC16_File(system.ParamStr(0));
  StrData.Add('EXEInfo_FileCRC16=$'+sysutils.IntToHex(dD,4));
  StrData.Add('EXEInfo_FileLastCompileTime="'+GetLastCompileTimeStr+'"');

  StrData.Add('SysInfo_DeskPath='+GetCurDeskPath);

  if GetUPTime(a,b) then
  begin
    StrData.Add('SysInfo_Uptime_A='+DataTime_DayTimeStr(a));
    StrData.Add('SysInfo_Uptime_B='+DataTime_DayTimeStr(b));
  end
  else
  begin
    StrData.Add('SysInfo_Uptime_A=-1');
    StrData.Add('SysInfo_Uptime_B=-1');
  end;
  StrData.Add('');
  StrData.Add('');
  StrData.Add('hackrfSN='+hackrfSN);
  if hackrfSN_Lic then
  StrData.Add('hackrfSN_Lic=1')
  else
  StrData.Add('hackrfSN_Lic=0');
  StrData.Add('');
  StrData.Add('rtlsdrSN='+rtlsdrSN);
  if rtlsdrSN_Lic then
  StrData.Add('rtlsdrSN_Lic=1')
  else
  StrData.Add('rtlsdrSN_Lic=0');
  StrData.Add('');

  StrData.Add('HWSN='+SafeData_unit.GetHWSN);
  StrData.Add('');
  StrData.Add('');
  StrData.Add('-----CMD----wpa_cli status---------------------------------------------------');
//  StrData.AddText()
  GetCmdResult('wpa_cli status',StrData,false);
  StrData.Add('-----CMD----ifconfig---------------------------------------------------------');
//  StrData.AddText()
  GetCmdResult('ifconfig',StrData,false);
  StrData.Add('-----CMD----cat /etc/wpa_supplicant/wpa_supplicant.conf----------------------');
  GetCmdResult('cat /etc/wpa_supplicant/wpa_supplicant.conf',StrData,false);
  StrData.Add('');
  StrData.Add('');

  s:=strdata.Text;
//  strdata.SaveToFile('/tmp/a.txt');

  self.PackFile:=TFileStream.Create(self.FCurIQFileName,fmcreate);
  self.PackFile.Position:=0;
  self.PackFile.Write(FileHead,sizeof(FileHead));    //暂时写入占位，文件结束时，重写位置

  FillChar(dph,sizeof(dph),0);
  FillDataPackHead(self.PackFile,dph,dt_Info);
  dph.RealSize:=length(s);
  self.Compress_Zlib(@s[1],length(s));
  dph.Compress:=ord(cm_zlip);
  self.PackFile.Position:=self.PackFile.Size;
  self.PackFile.Write(dph,sizeof(dph));
  self.EnSlat(self.TmpMem2.Memory,self.TmpMem2.size,@dph.DataSlat[0],length(dph.DataSlat));
  self.ProcHead_EndPack(dph,self.TmpMem2,0,self.TmpMem2.size);

  self.PackFile.Position:=self.PackFile.Size;
  self.PackFile.Write(self.TmpMem2.Memory^,self.TmpMem2.size);
  if AndWriteIQHead then
  begin
    self.PackFile.Position:=self.PackFile.Size;
    FillDataPackHead(self.PackFile,IQDph,dt_IQData);    //暂时写入占位，包结束时，重写位置
    self.PackFile.Write(IQDph,sizeof(IQDph));
  end;
  self.PackFile.Position:=self.PackFile.Size;
end;

function TSDR.GetTempFileName:string;
begin
  Result:='/tmp/'+sysutils.FormatFloat('yyyy-mm-dd_HHnnss.zzz.dat',now);
end;

function TSDR.RecvIQData(buf: pByte; len: dword): boolean;
var
  D:TIQData;
begin
  Result:=False;
  if Len=0 then
    exit;
  if self.StopFlag.Boolean then
  exit;

  d:=TIQData.Create;
  d.Data:=GetMem(len);
  D.Size:=len;
  move(buf^,d.Data^,len);
  self.BufList.Add(D);
  self.FEvent.SetEvent;
  Result:=true;
end;

function TSDR.GetDiskSpace(Dir: string): int64;
var
  s:Stat;
  c:integer;
begin
  Result:=-1;
  //fillchar(s,sizeof(s),0);
  //if statfs(dir,s)<>0 ten
  //exit;
  c:=AddDisk(dir);
  Result:=DiskFree(c);
end;

function TSDR.BufItemCount:integer;
begin
  Result:=self.BufList.LockList.Count;
  self.BufList.UnlockList;
end;

function TSDR.PopBufItem:TIQData;
var
  lst:TList;
begin
  Result:=nil;
  lst:=self.BufList.LockList;
  if lst.Count>0 then
  begin
    Result:=lst.Items[0];
    lst.Delete(0);
  end;
  self.BufList.UnlockList;

end;

procedure TSDR.WriteLog_No0(ID:integer;Str:String='');
begin
  if id=0 then
  exit;
  if Str='' then
  begin
    WriteLog(inttostr(ID));
  end
  else
  begin
    WriteLog(Str+' ,ID='+inttostr(ID));
  end;

end;

procedure TSDR.WriteLog(str:string);
begin
  writeln(str);
end;

procedure TSDR.WriteLog(T:int64);
begin
  writeln(inttostr(T));
end;

procedure TSDR.DoWork;
var
  L:integer;
  D:TIQData;
  E:Boolean;
begin
  D:=self.PopBufItem;
  E:=false;
//  writeln('a');
  if d=nil then
  begin
    if self.StopFlag.Boolean then
    begin
      self.FWaitWriteDoneEvent.SetEvent;
      exit;
    end;
    exit;
  end;
//  writeln('b');
  {$IFDEF Test}
    self.RawFile.Write(d.Data^,D.Size);
  {$ENDIF}
//  writeln('c');
  self.IQData_EnSlat(d.Data,D.Size);
  self.IQDph.DataCRC:=CRC16_Unit.CalcCRC16(D.Data,D.Size,self.IQDph.DataCRC);
//  writeln('d');
  L:=self.PackFile.Write(D.Data^,D.Size);
  if L<>D.Size then
  begin
    E:=True;
    self.Progress(FileHead.head2.DataSize,0,True,Progress_Mode_WriteDiskErr);

    self.DoStopIQ;
    self.ClearBufList;
  end;
//  writeln('e');
  FileHead.head2.DataSize:=FileHead.head2.DataSize+L;
  IQDph.DataSize:=IQDph.DataSize+L;
  FreeMem(D.Data);
  sysutils.FreeAndNil(D);
//  writeln('f');
  self.Progress(FileHead.head2.DataSize,self.BufItemCount,True,Progress_Mode_Rec_Size);
//  writeln('g');

//  sleep(500);
  if self.IQDph.DataSize>=IQDataMaxSize then
  begin
    E:=True;
    self.Progress(Progress_EndFlag_Cur,Progress_EndFlag_Max,True,Progress_Mode_RecSizeLimit);
    InternalStopIQ(true);
    self.ClearBufList;
  end;
end;

function TSDR.OpenDevice: boolean;
begin
  Result:=False;
  Result:=self.DoOpenDevice;
end;

function TSDR.CloseDevice: boolean;
begin
  Result:=self.DoCloseDevice;
end;


function TSDR.DoEndFile(ByThreadCall:Boolean):Boolean;
var
  dph:TDataPackHead;
  t:integer;
  ok:boolean;
const
  step=50;
begin
  Result:=False;
  if self.PackFile=nil then
  exit;

  StopFlag.Enter;
  StopFlag.Boolean:=true;
  self.FEvent.SetEvent;
  StopFlag.Leave;

  t:=0;
  ok:=false;
  if not ByThreadCall then
  begin
    while t<120000 do
    begin
      if self.FWaitWriteDoneEvent.WaitFor(step)=wrSignaled then
      begin
        ok:=true;
        system.Break;
      end;
      application.ProcessMessages;
      self.FEvent.SetEvent;
      sleep(10);
      inc(t,step);
    end;
  end;

  if not ok then
  begin
    exit;
  end;

  ProcHead_EndPack(self.IQDph);
  FillDataPackHead(self.PackFile,dph,dt_FileEnd);
  ProcHead_EndPack(dph);
  self.EnSlat(@self.FileHead.Head2,self.FileHead.Head1.Head2Size,@self.FileHead.Head1.Head2Slat[0],length(self.FileHead.Head1.Head2Slat));
  self.FileHead.Head1.Head2CRC:=CRC16_Unit.CalcCRC16(@self.FileHead.Head2,self.FileHead.Head1.Head2Size);

  self.PackFile.Position:=0;
  self.PackFile.Write(self.FileHead,sizeof(self.FileHead));

  self.Progress(Progress_EndFlag_Cur,Progress_EndFlag_Max,ByThreadCall,Progress_Mode_Rec);

  sysutils.FreeAndNil(self.PackFile);

  {$IFDEF Test}
    sysutils.FreeAndNil(self.RawFile);
  {$ENDIF}
  Result:=true;
end;


function TSDR.InternalStopIQ(ByThreadCall:Boolean): Boolean;
begin
  self.FWaitWriteDoneEvent.ResetEvent;
  self.DoStopIQ;
  sleep(500);
  self.DoEndFile(ByThreadCall);
  Result:=True;
end;

function TSDR.StopIQ: Boolean;
begin
  Result:=InternalStopIQ(False);
end;

function TSDR.ReadDeviceEEPROM(buf: PByte; len: DWORD;StartAddr:integer): integer;
begin
  Result:=-1;

end;

function TSDR.ReadDeviceEEPROM(fn: string; All: Boolean): Boolean;
var
  mem:TMemoryStream;
  len:integer;
  s:integer;
begin
  if All then
  s:=-1
  else
  s:=0;
  len:=self.ReadDeviceEEPROM(nil,0,s);
  if len<0 then
  exit;

  mem:=TMemoryStream.Create;
  mem.Size:=len;
  len:=self.ReadDeviceEEPROM(mem.Memory,mem.Size,s);
  if len<0 then
  begin
    sysutils.FreeAndNil(mem);
    exit;
  end;
  mem.SaveToFile(fn);
  Result:=true;

end;

procedure TSDR.ClearBufList;
var
  i:integer;
  lst:TList;
begin
  lst:=self.BufList.LockList;
  for i := 0 to lst.Count-1  do
  begin
    TObject(lst.Items[i]).Free;
  end;
  lst.Clear;
  self.BufList.UnlockList;

end;

procedure TSDR.NullData;
begin
  self.StopFlag.Boolean:=false;
  self.FWaitWriteDoneEvent.ResetEvent;
  self.FEvent.ResetEvent;
  self.ClearBufList;
  Fillchar(self.FileHead,sizeof(self.FileHead),0);
  FillChar(IQDph,sizeof(IQDph),0);

  PackFile:=nil;
  StrData.Clear;
  TmpMem1.Clear;
  TmpMem2.Clear;

  IQSlatIndex_En:=0;
  IQSlatIndex_De:=0;

end;

{$ENDIF}

procedure TSDR.DoProgress;
begin
  if system.Assigned(self.FOnProgress) then
  FOnProgress(self,self.FProgressCur,FProgressMax,self.FProgressMode);
end;

procedure TSDR.Progress(Cur, Max: int64; UseThreadSyncProc: Boolean=True;Mode:integer=0);
begin
  self.FProgressCur:=Cur;
  self.FProgressMax:=Max;
  self.FProgressMode:=Mode;
  {$IFNDEF _WindowsOnly_}
  if UseThreadSyncProc then
  begin
    self.Synchronize(self.DoProgress);
  end
  else
  {$ENDIF}
  begin
    self.DoProgress
  end;

end;

function TSDR.GetSampleBit: Byte;
begin
  Result:=8;
end;

procedure TSDR.IQData_DeSlat(buf:PByteArray;len:integer);
begin
  self.DeSlat(buf,len,@IQDph.DataSlat[0],length(IQDph.DataSlat),@IQSlatIndex_De);
end;

procedure TSDR.IQData_EnSlat(buf: PByteArray; len: integer);
begin
  self.EnSlat(buf,len,@IQDph.DataSlat[0],length(IQDph.DataSlat),@IQSlatIndex_En);
end;

procedure TSDR.EnSlat(buf: PByteArray; len: integer; Slat: PByteArray; SlatLen: integer; SlatIdx:Pinteger=nil);
var
  i:integer;
  idx:integer;
begin
  idx:=0;
  if SlatIdx<>nil then
  idx:=SlatIdx^;

  if idx>=SlatLen then
  idx:=0;

  for i := 0 to len-1 do
  begin
    buf^[i]:=buf^[i] xor Slat^[idx];
    Inc(idx);
    if idx>=SlatLen then
    idx:=0;
  end;
  if SlatIdx<>nil then
  SlatIdx^:=idx;

end;

procedure TSDR.DeSlat(buf: PByteArray; len: integer; Slat: PByteArray; SlatLen: integer; SlatIdx:Pinteger=nil);
var
  i:integer;
  idx:integer;
begin
  idx:=0;
  if SlatIdx<>nil then
  idx:=SlatIdx^;

  if idx>=SlatLen then
  idx:=0;

  for i := 0 to len-1 do
  begin
    buf^[i]:=buf^[i] xor Slat^[idx];
    Inc(idx);
    if idx>=SlatLen then
    idx:=0;
  end;
  if SlatIdx<>nil then
  SlatIdx^:=idx;

end;

function TSDR.CheckCurData(out info: TIQDataInfo): boolean;
var
  A:TFileStream;
  B:TFileStream;
  L:integer;
  i:integer;
  All_L:DWORD;
  dest:String;
  strlst:TStringList;
  function GetInt64(s:String):int64;
  begin
    Result:=-1;
    s:=trim(s);
    if not sysutils.TryStrToInt64(s,Result) then
    Result:=-1;
  end;
  function GetDouble(s:String):Double;
  begin
    Result:=-1;
    s:=trim(s);
    if s='' then
    exit;
    if rightstr(s,1)='%' then
    setlength(s,length(s)-1);
    if not sysutils.TryStrToFloat(s,Result) then
    Result:=-1;
  end;
  function GetTime(s:String):TDateTime;
  begin
    Result:=0;
    s:=trim(s);
    if s='' then
    exit;
    if not sysutils.TryStrToTime(s,Result) then
    Result:=0;
  end;
var
  buf:array[0..1024*256-1] of byte;
  buf_AM:array[0..1024*128-1] of DWORD;
  ALL:int64;
  All_Max:int64;
  T:DWORD;
begin
  Result:=False;
  //暂处理8位，不去折腾16的

  fillchar(info,sizeof(info),0);
  if not sysutils.FileExists(self.FCurIQFileName) then
  exit;
  if GetFileSize(self.FCurIQFileName)<1024 then    //文件太小。也不对
  exit;
  Progress(Progress_StartFlag_Cur,Progress_StartFlag_Max,false);
  All:=0;
  All_Max:=0;
  strlst:=TStringList.Create;

    //FCurAMFileName
  self.IQSlatIndex_De:=0;
  All_L:=0;
  dest:=self.GetTempFileName;
  //self.FCurAMFileName:=dest;
  //A:=TFileStream.Create(self.FCurIQFileName,fmOpenRead or fmShareDenyWrite);
  //B:=TFileStream.Create(self.CurAMFileName,fmCreate);
  //while True do
  //begin
  //  l:=A.Read(buf[0],sizeof(buf));
  //  if l=0 then
  //  system.Break;
  //
  //  Progress(A.Position,A.Size);
  //  self.IQData_DeSlat(@buf[0],l);
  //  for i := 0  to (L div 2) do
  //  begin
  //    T:=(buf[i*2]*buf[i*2]+buf[i*2+1]+buf[i*2+1]);
  //    buf_AM[i]:=T;
  //    All:=All+T;
  //    All_Max:=Max(All_Max,T);
  //  end;
  //  All_L:=All_L+L;
  //  B.Write(buf_AM[0],L*2);
  //
  //end;
//  sysutils.FreeAndNil(A);
  if not self.DeFile(self.CurFileName,dest,dm_AM_Int32,strlst) then
  begin
    sysutils.FreeAndNil(strlst);
    exit;
  end;
  deleteFile(dest);
  info.CurFileName:=self.CurFileName;
  info.DataSize:=GetFileSize(info.CurFileName);
  info.CurFileName:=info.CurFileName;

  info.AllData_Avg:=GetInt64(strlst.Values['AllData_Avg']);
  info.AllData_Max:=GetInt64(strlst.Values['AllData_Max']);
  info.AllData_SNR:=GetDouble(strlst.Values['AllData_SNR']);


  info.SampleRate:=GetInt64(strlst.Values['SampleRate']);
  info.SampleBit:=GetInt64(strlst.Values['SampleBit']);
  info.IQDataSize:=GetInt64(strlst.Values['IQDataSize']);
  info.TimeLen:=GetTime(strlst.Values['TimeLen']);



//  info.DataSize:=B.Size;
////  sysutils.FreeAndNil(B);
//  DeleteFile(self.CurAMFileName);
//  Info.CurFileName:=self.FCurIQFileName;
////  strlst.Values['']
//  Info.All_Avg:=All/All_L;
//  info.All_Max:=All_Max;
////  info.All_SNR:=
  Result:=True;


end;

function TSDR.CheckFileHead(var FileHead:TFileHead;Stream:TStream):Boolean;
begin
  Result:=False;
  if not sysutils.SameText(FileHead.head1.Flag1,Flag1) then
  exit;

  if not sysutils.SameText(FileHead.head1.Flag2,Flag2) then
  exit;

  if (FileHead.head1.FileVer[0]<>FileVer1) and (FileHead.head1.FileVer[0]<>FileVer2) then
  exit;
  if FileHead.head1.Head2Size>sizeof(FileHead.head2) then   //!
  exit;
  //if FileHead.head2.IQStartPos>=Stream.Size then
  //exit;
  //if (FileHead.head2.DataSize+FileHead.head2.DataStartPos)>Stream.Size then
  //exit;
  if not (TDeviceType(FileHead.head2.DeviceType) in [dt_HackRFOne,dt_rtl2832u,dt_rtl2832u_DirSam]) then
  exit;

  if (FileHead.head2.Freq<=0) or (FileHead.head2.Freq>6000000000) then
  exit;

  if (FileHead.head2.SampleRate<=10000) or (FileHead.head2.SampleRate>20000000) then
  exit;

  if (TDeviceType(FileHead.head2.DeviceType) in [dt_rtl2832u,dt_rtl2832u_DirSam]) then
  begin
    if (FileHead.head2.Freq>1750000000) then
    exit;
    if (FileHead.head2.SampleRate>3200000) then
    exit;
  end;
  Result:=True;
end;

function TSDR.DeFile_IQ(fn: string; destfn: string; DecodeMode: TDecodeMode;SampleRate:integer;SampleBit:integer): Boolean;
const
  BufCap=512*1024;
var
  F:TFileStream;
  idx:integer;
  OK:Boolean;
  L:DWORD;
  L2:int64;
  Dest:TFileStream;
  wh:TWaveHead_File;
  buf:array[0..BufCap-1] of byte;
  buf_flt:array of Single;
  buf_Int:array of integer;
  buf_wrd:array of Word;
  a,b:integer;
  b1,b2:Byte;
  buf16:PWordarray;
  buf32:PIntegerArray;
  BufLen:integer;
  BufRdy,bufrdy2:integer;
  E:Boolean;
  WaveDataLen:DWORD;

  C:WORD;
  i:integer;
begin
  Result:=false;

  if not sysutils.FileExists(fn) then
  exit;

  Dest:=nil;
  F:=nil;

  OK:=False;
  F:=TFileStream.Create(fn,fmOpenRead or fmShareDenyWrite);
  WaveDataLen:=0;

  if DecodeMode in [dm_SDRSharp_Float,dm_AM_Float32,dm_AM_Float32_ABS,dm_FM_Float32] then
  setlength(buf_flt,BufCap);
  if DecodeMode in [dm_AM_Int16] then
  setlength(buf_wrd,BufCap);
  if DecodeMode in [dm_AM_Int32] then
  setlength(buf_int,BufCap);

  L2:=f.Size;
  while L2>0 do
  begin
    C:=0;
    BufLen:=min(BufCap,L2);
    BufRdy:=F.Read(buf[0],BufLen);
    if BufRdy<>BufLen then
    begin
      E:=True;
      system.Break;
    end;
    L2:=L2-BufRdy;

    if Dest=nil then
    begin
      Dest:=TFileStream.Create(destfn,fmcreate);
      fillchar(wh,sizeof(wh),0);
      wh.cData:='data';
      wh.WaveHead.cHead:='RIFF';
      wh.WaveHead.cWaveTag:='WAVEfmt ';
      wh.WaveHead.nHeaderLength:=16;
      wh.WaveHead.wFormatTag:=1;

      wh.WaveHead.nChannels:=0;
      wh.WaveHead.nSamplesPerSec:=SampleRate;
      wh.WaveHead.wBitsPerSample:=SampleBit;
      wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample div 8;
      wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
    end;

    case DecodeMode of
     dm_SDRSharp_RawBit:
       begin
         if wh.WaveHead.nChannels=0 then
         begin
           wh.WaveHead.nChannels:=2;
           wh.WaveHead.nSamplesPerSec:=SampleRate;
           wh.WaveHead.wBitsPerSample:=SampleBit;
           wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
           wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
           Dest.Write(wh,sizeof(wh));
         end;
         //if Dest.Write(buf[0],bufrdy)<>bufrdy then
         //begin
         //  e:=True;
         //  system.Break;
         //end;
         bufrdy2:=bufrdy div 2;
         for i := 0  to bufrdy2-1  do
         begin
           b1:=buf[i*2];
           b2:=buf[i*2+1];
           buf[i*2]:=b2;
           buf[i*2+1]:=b1;
         end;
         if Dest.Write(buf[0],bufrdy)<>bufrdy then
         begin
           e:=True;
           system.Break;
         end;
         WaveDataLen:=WaveDataLen+BufRDY;
      end;
     dm_AM_Int32,dm_AM_Int32_ABS:
       begin
         if wh.WaveHead.nChannels=0 then
         begin
           wh.WaveHead.nChannels:=1;
           wh.WaveHead.nSamplesPerSec:=SampleRate;
           wh.WaveHead.wBitsPerSample:=32;
           wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
           wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
           Dest.Write(wh,sizeof(wh));
         end;
         bufrdy:=bufrdy div 2;
         for i := 0 to bufrdy-1  do
         begin
           a:=buf[i*2];
           b:=buf[i*2+1];
           if DecodeMode=dm_AM_Int32_ABS then
           begin
             a:=abs(a);
             b:=abs(b);
           end;

           buf_wrd[i]:=a*a+b*b;
         end;
         if Dest.Write(buf_wrd[0],bufrdy*2)<>bufrdy*2 then
         begin
           e:=True;
           system.Break;
         end;
         WaveDataLen:=WaveDataLen+BufRDY*2;
       end;
      end;
    end;

  if DecodeMode in [dm_SDRSharp_RawBit,dm_SDRSharp_Float,dm_AM_Float32,dm_AM_Float32_ABS,dm_FM_Float32,dm_AM_Int32,dm_AM_Int16] then
  begin
    wh.nDataLen:=WaveDataLen;
    if dest<>nil then
    begin
      Dest.Position:=0;
      dest.Write(wh,sizeof(wh));
    end;
    Result:=true;
  end;
 if dest<>nil then
 begin
   sysutils.FreeAndNil(dest);
 end;

end;

function TSDR.AMFile2AuWave(fn, dest: string): Boolean;
const
  BufCap=512*1024;
var
  F1,F2:TFileStream;
  W1,W2:TWaveHead_File;
  OK:Boolean;
  buf:array[0..BufCap-1] of byte;
  BufLen:integer;
  L:integer;

  buf2:array of SmallInt;
  buf2Cap:integer;
  buf2Len:integer;
  Step:integer;


begin
 {
  Result:=false;
  if not sysutils.FileExists(fn) then
  exit;

  OK:=False;
  F1:=TFileStream.Create(fn,fmOpenRead or fmShareDenyWrite);
  while True do
  begin
    if F1.Read(W1,sizeof(W1))<>sizeof(W1) then
    begin
      system.Break;
    end;
    if not sysutils.SameText(W1.cData,'data') then
    system.Break;
    if not w1.WaveHead.wFormatTag in [1,3] then
    exit;
    if not sysutils.SameText(W1.cData,'RIFF') then
    system.Break;
    if not sysutils.SameText(W1.WaveHead.cWaveTag,'WAVEfmt ') then
    system.Break;
    if not w1.WaveHead.nChannels in [1,2] then
    exit;
    if not w1.WaveHead.nBlockAlign in [2,4,8] then
    exit;
    if not w1.WaveHead.wBitsPerSample in [8,16,32] then
    exit;

    ok:=true;
    System.Break;
  end;
  if not OK then
  begin
    sysutils.FreeAndNil(F1);
    exit;
  end;

  if W1.WaveHead.wFormatTag=3 then
  begin
    Buf2Cap:=BufCap div 2;
    SetLength(buf2,BufCap);
  end;
  if W1.WaveHead.wFormatTag=1 then
  begin
    case W1.WaveHead.wBitsPerSample of
      8:
        begin
          Buf2Cap:=BufCap*2;
          SetLength(buf2,BufCap);
        end;
      16:
        begin
          Buf2Cap:=BufCap;
          SetLength(buf2,BufCap);
        end;
      32:
        begin
          Buf2Cap:=BufCap div 2;
          SetLength(buf2,BufCap);
        end;
    end;
  end;
  FillChar(W2,sizeof(w2),0);
  W2.cData:='data';
  W2.WaveHead.cHead:='RIFF';
  W2.WaveHead.cWaveTag:='WAVEfmt ';
  W2.WaveHead.nHeaderLength:=16;
  W2.WaveHead.wFormatTag:=1;

  W2.WaveHead.nChannels:=W1.WaveHead.nChannels;
  W2.WaveHead.nSamplesPerSec:=DefWaveSample;
  W2.WaveHead.wBitsPerSample:=32;
  W2.WaveHead.nAvgBytesPerSec:=W2.WaveHead.nSamplesPerSec*W2.WaveHead.wBitsPerSample div 8;
  W2.WaveHead.nBlockAlign:=W@.WaveHead.nAvgBytesPerSec div W2.WaveHead.nSamplesPerSec;

  Step:=Round(W1.WaveHead.nSamplesPerSec/DefWaveSample);

  self.Progress(Progress_StartFlag_Cur,Progress_StartFlag_Max,false);
  while F1.Position<F1.Size do
  begin
    L:=F1.Size-F1.Position+1;
    L:=min(L,BufCap);
    L:=F1.Read(buf[0],L);
    self.Progress(F1.Position,F1.Size,false);
    if W1.WaveHead.wFormatTag=3 then
    begin
      BufLen:=L div 2;
      for i := 0 to   do
      begin
        DefWaveSample

      end;

      system.Continue;
    end;
    if W1.WaveHead.wFormatTag=3 then
    begin

    end;


  end;
  self.Progress(Progress_EndFlag_Cur,Progress_EndFlag_Max,false);



}

end;

procedure TSDR.Swap_Word(buff:Pointer;BufSize:integer);
var
  i:integer;
  a,b:byte;
  buf:PWordarray;
begin
  i:=0;
  BufSize:=(BufSize div 4)*2;
  BufSize:=BufSize-1;
  while (i<BufSize) do
  begin
    a:=buf^[i];
    buf^[i]:=buf^[i+1];
    buf^[i+1]:=a;
    inc(i,2);
  end;

end;

procedure TSDR.Swap_Byte(buff:Pointer;BufSize:integer);
var
  i:integer;
  a,b:byte;
  buf:pByteArray;
begin
  i:=0;
  BufSize:=(BufSize div 2)*2;
  BufSize:=BufSize-1;
  buf:=buff;
  while (i<BufSize) do
  begin
    a:=buf^[i];
    buf^[i]:=buf^[i+1];
    buf^[i+1]:=a;
    inc(i,2);
  end;

end;

function TSDR.DeFile(fn: string; destfn: string; DecodeMode: TDecodeMode;InfoList:TStrings): Boolean;
const
  BufCap=512*1024;
var
  F:TFileStream;
//  FileHead:TFileHead;
  idx:integer;
  OK:Boolean;
  dph:TDataPackHead;
  L:DWORD;
  L2:int64;
  Dest:TFileStream;
  wh:TWaveHead_File;
  buf:array[0..BufCap-1] of byte;
  buf_flt:array of Single;
  buf_Int:array of integer;
  buf_wrd:array of Word;
  a,b:integer;
  buf16:PWordarray;
  buf32:PIntegerArray;
  BufLen:integer;
  BufRdy:integer;
  E:Boolean;
  WaveDataLen:DWORD;
  IQData:Boolean;
  C:WORD;
  i:integer;
  AllData_Sum:int64;
  SamCount:int64;
  Sam_Max:integer;
  AllData_Max:int64;
  AllData_Avr:int64;
  IQDataSize:int64;
  T:integer;
const
  flt_127:Single=1/127;
  flt_32767:Single=1/32767;
  flt_2147483647:Single=1/2147483647;
  function ReadDataHeadPack:Boolean;
  var
    b:PByte;
    b2:Pointer;
  begin
    Result:=False;
    if F.Read(dph,sizeof(dph))<>sizeof(dph) then
    exit;
    b:=PByte(@dph);
    inc(b,4);

    if CRC16_Unit.CalcCRC16(b,sizeof(dph)-4,0)<>dph.CRC16 then
    exit;
    idx:=0;
    b2:=b;
    self.DeSlat(b2,sizeof(dph)-4,@FileHead.head2.dph_Slat[0],length(FileHead.head2.dph_Slat));

    Result:=True;
  end;

begin
  Result:=False;
  InfoList.Clear;
  Dest:=nil;
  F:=nil;
  Fillchar(dph,sizeof(dph),0);
  AllData_Sum:=0;
  SamCount:=0;
  Sam_Max:=0;
  AllData_Max:=0;
  AllData_Avr:=0;
  IQDataSize:=0;

  if sysutils.FileExists(destfn) then
  sysutils.DeleteFile(destfn);

  if not sysutils.FileExists(fn) then
  exit;

  OK:=False;
  F:=TFileStream.Create(fn,fmOpenRead or fmShareDenyWrite);
  WaveDataLen:=0;
  IQData:=False;
  while True do
  begin
    F.Position:=0;
    if F.Read(FileHead.Head1,sizeof(FileHead.Head1))<>sizeof(FileHead.Head1) then
    system.Break;
    if not sysutils.SameText(FileHead.head1.Flag1,Flag1) then
    system.Break;
    if not sysutils.SameText(FileHead.head1.Flag2,Flag2) then
    system.Break;

    if (FileHead.Head1.Head2Size>F.Size) or (FileHead.Head1.Head2Size>256*1024) then
    system.Break;

    if F.Read(FileHead.Head2,FileHead.Head1.Head2Size)<>FileHead.Head1.Head2Size then
    system.Break;
    if CRC16_Unit.CalcCRC16(@FileHead.Head2,FileHead.Head1.Head2Size)<>FileHead.Head1.Head2CRC then   //如果文件头大于当前头，需要先读入buff，再弄
    system.Break;

    self.DeSlat(@FileHead.Head2,FileHead.Head1.Head2Size,@FileHead.Head1.Head2Slat[0],length(FileHead.Head1.Head2Slat));
    if not CheckFileHead(FileHead,F) then
    system.Break;

    if not (FileHead.Head2.SampleBit in [8,16]) then
    begin
      system.Break;
    end;

    Ok:=True;
    system.Break;
  end;
  if not OK then
  begin
    sysutils.FreeAndNil(F);
    exit;
  end;

  Sam_Max:=(1 shl FileHead.Head2.SampleBit) div 2;

  if DecodeMode in [dm_SDRSharp_Float,dm_AM_Float32,dm_AM_Float32_ABS,dm_FM_Float32] then
  setlength(buf_flt,BufCap);

  if DecodeMode in [dm_AM_Int16] then
  setlength(buf_wrd,BufCap);
  if DecodeMode in [dm_AM_Int32] then
  setlength(buf_int,BufCap);
  if InfoList<>nil then
  begin
    InfoList.Add('SampleBit='+inttostr(FileHead.Head2.SampleBit));
    InfoList.Add('SampleRate='+inttostr(FileHead.Head2.SampleRate));
  end;

  OK:=False;
  F.Position:=sizeof(FileHead.Head1)+FileHead.Head1.Head2Size;
  self.Progress(Progress_StartFlag_Cur,Progress_StartFlag_Max,false);
  while F.Position<F.Size do
  begin
    self.Progress(Progress_StartFlag_Cur,Progress_StartFlag_Max,false);
    if not ReadDataHeadPack then
    system.Break;

    if dph.DataType=ord(dt_Error) then
    system.Break;
    if dph.DataType=ord(dt_FileEnd) then
    begin
      ok:=True;
      system.Break;
    end;
    if dph.DataType=ord(dt_Info) then
    begin
      if InfoList=nil then
      system.Continue;

      self.TmpMem1.Clear;
      self.TmpMem1.Size:=dph.DataSize;
      if F.Read(self.TmpMem1.Memory^,self.TmpMem1.size)<>self.TmpMem1.size then
      system.Break;

      if dph.DataCRC<>CRC16_Unit.CalcCRC16(self.TmpMem1.Memory,self.TmpMem1.Size) then
      system.Break;
      self.DeSlat(self.TmpMem1.Memory,self.TmpMem1.size,@dph.DataSlat[0],length(dph.DataSlat));
      if not (TCompressMode(dph.Compress) in [cm_zlip,cm_none]) then
      system.Break;

      if dph.Compress=ord(cm_zlip) then
      begin
        self.TmpMem2.Size:=dph.RealSize;
        L:=self.TmpMem2.Size+1024;    //这里没有用到L
        T:=uncompress(self.TmpMem2.Memory,@L,self.TmpMem1.Memory,self.TmpMem1.Size);
        if T<>Z_OK then
        system.Break;
        InfoList.LoadFromStream(self.TmpMem2)
      end;
      if dph.Compress=ord(cm_none) then
      begin
        InfoList.LoadFromStream(self.TmpMem1);
      end;
//      InfoList.SaveToFile('/tmp/aa.txt');
      system.Continue;
    end;
    if dph.DataType=ord(dt_IQData) then
    begin
      IQDataSize:=IQDataSize+dph.DataSize;
      if Dest=nil then
      begin
        Dest:=TFileStream.Create(destfn,fmcreate);
        fillchar(wh,sizeof(wh),0);
        wh.cData:='data';
        wh.WaveHead.cHead:='RIFF';
        wh.WaveHead.cWaveTag:='WAVEfmt ';
        wh.WaveHead.nHeaderLength:=16;
        wh.WaveHead.wFormatTag:=1;

        wh.WaveHead.nChannels:=0;
        wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
        wh.WaveHead.wBitsPerSample:=self.SampleBit;
        wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample div 8;
        wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
      end;
        L2:=dph.DataSize;
        idx:=0;
        E:=False;
        C:=0;
        while L2>0 do
        begin
          IQData:=True;
          BufLen:=min(BufCap,L2);
          BufRdy:=F.Read(buf[0],BufLen);
          if BufRdy<>BufLen then
          begin
            //SaveBuffFile(@buf[0],bufrdy,'/tmp/aaa');
            E:=True;
            system.Break;
          end;
          L2:=L2-BufRdy;
          C:=CRC16_Unit.CalcCRC16(@buf[0],bufrdy,C);
          self.DeSlat(@buf[0],BufRdy,@dph.DataSlat[0],length(dph.DataSlat),@idx);
          case DecodeMode of
            dm_IQData:
              begin
                if Dest.Write(buf[0],bufrdy)<>bufrdy then
                begin
                  e:=True;
                  system.Break;
                end;
              end;
            dm_SDRSharp_RawBit:
              begin
                if wh.WaveHead.nChannels=0 then
                begin
                  wh.WaveHead.nChannels:=2;
                  wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
                  wh.WaveHead.wBitsPerSample:=self.SampleBit;
                  wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                  wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                  Dest.Write(wh,sizeof(wh));
                end;
//                Swap_Byte(@buf[0],bufrdy);
                if Dest.Write(buf[0],bufrdy)<>bufrdy then
                begin
                  e:=True;
                  system.Break;
                end;
                WaveDataLen:=WaveDataLen+BufRDY;
              end;
            dm_SDRSharp_Float:
              begin
                if wh.WaveHead.nChannels=0 then
                begin
                  wh.WaveHead.wFormatTag:=3;
                  wh.WaveHead.nChannels:=2;
                  wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
                  wh.WaveHead.wBitsPerSample:=32;
                  wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                  wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                  Dest.Write(wh,sizeof(wh));
                end;
                case FileHead.Head2.SampleBit of
                  8:
                      begin
//                        Swap_Byte(@buf[0],bufrdy);
                        for i := 0 to bufrdy-1 do
                        begin
                          buf_flt[i]:=(buf[i]-128)*flt_127;
                        end;
                        Dest.Write(buf_flt[0],BufRDY*4);

                        WaveDataLen:=WaveDataLen+BufRDY*4;
                      end;
                  16:
                      begin
                        buf16:=@buf[0];
                        Swap_Word(@buf[0],bufrdy);

                        bufrdy:=bufrdy div 2;
                        for i := 0 to bufrdy-1 do
                        begin
                          buf_flt[i]:=(buf16^[i]-32768)*flt_32767;
                        end;
                        Dest.Write(buf_flt[0],BufRDY*4);
                        WaveDataLen:=WaveDataLen+BufRDY*4;
                      end;
                  //32:
                  //    begin
                  //      for i := 0 to bufrdy-1 do
                  //      begin
                  //        buf_flt[i]:=(buf[i]-2147483648)*flt_2147483647;
                  //      end;
                  //      Dest.Write(buf_flt[0],BufRDY*4);
                  //      WaveDataLen:=WaveDataLen+BufRDY*4;
                  //    end;
                end;

              end;
            dm_AM_Int16:
              begin
                if wh.WaveHead.nChannels=0 then
                begin
                  wh.WaveHead.nChannels:=1;
                  wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
                  wh.WaveHead.wBitsPerSample:=16;
                  wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                  wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                  Dest.Write(wh,sizeof(wh));
                end;

                case FileHead.Head2.SampleBit of
                  8:
                      begin
                        bufrdy:=bufrdy div 2;
                        for i := 0 to bufrdy-1 do
                        begin
                          a:=(buf[i*2]-127);
                          b:=(buf[i*2+1]-127);
                          buf_wrd[i]:=a*a+b+b;
                          inc(SamCount,buf_wrd[i]);
                          AllData_Max:=Max(AllData_Max,buf_wrd[i]);
                        end;
                        inc(AllData_Sum,bufrdy);
                        Dest.Write(buf_wrd[0],BufRDY*2);

                        WaveDataLen:=WaveDataLen+BufRDY*2;
                      end;
                  16:
                      begin
                        bufrdy:=bufrdy;
                        for i := 0 to bufrdy-1 do
                        begin
                          a:=(buf[i*2]-32768) div 256;
                          b:=(buf[i*2+1]-32768) div 256;
                          buf_wrd[i]:=a*a+b*b;
                          inc(AllData_Sum,buf_wrd[i]);
                          AllData_Max:=Max(AllData_Max,buf_wrd[i]);
                        end;
                        inc(SamCount,bufrdy);

                        Dest.Write(buf_wrd[0],BufRDY*2);

                        WaveDataLen:=WaveDataLen+BufRDY*2;
                      end;
                  //32:
                  //    begin
                  //      for i := 0 to bufrdy-1 do
                  //      begin
                  //        buf_flt[i]:=(buf[0]-2147483648)*flt_2147483647;
                  //      end;
                  //      Dest.Write(buf_flt[0],BufRDY*4);
                  //      WaveDataLen:=WaveDataLen+BufRDY*4;
                  //    end;
                end;

              end;
            dm_AM_Int32,dm_AM_Int32_ABS:
              begin
                if wh.WaveHead.nChannels=0 then
                begin
                  wh.WaveHead.nChannels:=1;
                  wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
                  wh.WaveHead.wBitsPerSample:=32;
                  wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                  wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                  Dest.Write(wh,sizeof(wh));
                end;

                case FileHead.Head2.SampleBit of
                  8:
                      begin
                        bufrdy:=bufrdy div 2;
                        for i := 0 to bufrdy-1 do
                        begin
                          a:=(buf[i*2]-127);
                          b:=(buf[i*2+1]-127);
                          //a:=(buf[i*2]);
                          //b:=(buf[i*2+1]);
                          if DecodeMode=dm_AM_Int32_ABS then
                          begin
                            a:=abs(a);
                            b:=abs(b);
                          end;

                          buf_Int[i]:=(a*a)+(b*b);
                          inc(AllData_Sum,buf_Int[i]);
                          AllData_Max:=Max(AllData_Max,buf_Int[i]);
                        end;
                        inc(SamCount,bufrdy);
                        Dest.Write(buf_Int[0],BufRDY*4);

                        WaveDataLen:=WaveDataLen+BufRDY*4;
                      end;
                  16:
                      begin
                        bufrdy:=bufrdy div 4;
                        buf16:=@buf[0];
                      for i := 0 to bufrdy-1 do
                      begin
                        a:=(buf[i*2]-128);
                        b:=(buf[i*2+1]-128);
                        buf_Int[i]:=a*a+b*b;
                        inc(SamCount,buf_wrd[i]);
                        AllData_Max:=Max(AllData_Max,buf_Int[i]);
                      end;
                      inc(AllData_Sum,bufrdy);
                      Dest.Write(buf_Int[0],BufRDY*4);

                      WaveDataLen:=WaveDataLen+BufRDY*4;
                      end;
                  //32:
                  //    begin
                  //      for i := 0 to bufrdy-1 do
                  //      begin
                  //        buf_flt[i]:=(buf[0]-2147483648)*flt_2147483647;
                  //      end;
                  //      Dest.Write(buf_flt[0],BufRDY*4);
                  //      WaveDataLen:=WaveDataLen+BufRDY*4;
                  //    end;
                end;

              end;
            dm_AM_Float32,dm_AM_Float32_ABS:
              begin
                if wh.WaveHead.nChannels=0 then
                 begin
                   wh.WaveHead.nChannels:=1;
                   wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;
                   wh.WaveHead.wBitsPerSample:=32;
                   wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                   wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                   Dest.Write(wh,sizeof(wh));
                 end;

                //..
              end;
            dm_FM_Float32:
              begin
                if wh.WaveHead.nChannels=0 then
                 begin
                   wh.WaveHead.nChannels:=1;
                   wh.WaveHead.nSamplesPerSec:=Filehead.head2.SampleRate;   //div 2?
                   wh.WaveHead.wBitsPerSample:=32;
                   wh.WaveHead.nAvgBytesPerSec:=wh.WaveHead.nSamplesPerSec*wh.WaveHead.wBitsPerSample*wh.WaveHead.nChannels div 8;
                   wh.WaveHead.nBlockAlign:=wh.WaveHead.nAvgBytesPerSec div wh.WaveHead.nSamplesPerSec;
                   Dest.Write(wh,sizeof(wh));
                 end;


              end;
          end;
        end;
        if E then
        system.Break;
    end;
    if C<>dph.CRC16 then
    begin
      //e:=True;
      //system.Break;
    end;

  end;
  sysutils.FreeAndNil(F);
  if not ok then
  begin
    if Dest<>nil then
    sysutils.FreeAndNil(Dest);
    exit;
  end;
  if not IQData then
  begin
    if Dest<>nil then
    sysutils.FreeAndNil(Dest);

    exit;
  end;
  if DecodeMode in [dm_AM_Int16,dm_AM_Float32,dm_AM_Int32] then
  begin
    if InfoList<>nil then
    begin
      InfoList.Add('AllData_Sum='+inttostr(AllData_Sum));
      InfoList.Add('AllData_Max='+inttostr(AllData_Max));
      InfoList.Add('SamCount='+inttostr(SamCount));
      if SamCount<>0 then
      begin
        AllData_Avr:=round(AllData_Sum/SamCount);
        InfoList.Add('AllData_Avg='+sysutils.FormatFloat('0.000%',(AllData_Sum/AllData_Avr*100)));
        if AllData_Avr<>0 then
        begin
          InfoList.Add('AllData_SNR='+sysutils.FormatFloat('0.000%',(AllData_Max/AllData_Avr*100)))
//          InfoList.Add('AllData_SNR_Max='+sysutils.FormatFloat('0.000%',(AllData_Max/AllData_Avr*100)));
        end
        else
        begin
          InfoList.Add('AllData_SNR=N/A');
        end;
      end
      else
      begin
        InfoList.Add('AllData_Avr=N/A');
      end;
    end;
  end;

  if DecodeMode in [dm_SDRSharp_RawBit,dm_SDRSharp_Float,dm_AM_Int16,dm_AM_Float32,dm_AM_Int32] then
  begin
    wh.nDataLen:=WaveDataLen;
    Dest.Position:=0;
    dest.Write(wh,sizeof(wh));
    Result:=true;
  end;
  if InfoList<>nil then
  begin
    InfoList.Add('IQDataSize='+inttostr(IQDataSize));
    case Filehead.Head2.SampleBit of
      8:
        InfoList.Add('TimeLen='+sysutils.FormatDateTime('HH:nn:ss.zzz',(IQDataSize/2/FileHead.Head2.SampleRate)*dateutils.OneSecond));
      16:
        InfoList.Add('TimeLen='+sysutils.FormatDateTime('HH:nn:ss.zzz',(IQDataSize/4/FileHead.Head2.SampleRate)*dateutils.OneSecond));
    end;
  end;

  if Dest<>nil then
  sysutils.FreeAndNil(Dest);
end;

procedure TSDR.SetFreq(AValue: int64);
begin
  if FFreq=AValue then
    Exit;
  FFreq:=AValue;
end;

{$IFNDEF _WindowsOnly_}
procedure TSDR.Execute;
begin
  while not self.Terminated do
  begin
//    writeln('1');
    if self.FEvent.WaitFor(INFINITE)<>wrSignaled then
      system.Continue;
//    writeln('2');
    if self.Terminated then
      system.Break;
//    writeln('3');
    DoWork;
//  writeln('4');
  end;
//  writeln('5');
end;

procedure TSDR.SetDeviceType(DeviceType: TDeviceType);
begin
  self.FDeviceType:=DeviceType;
end;

function TSDR.DoOpenDevice: Boolean;
begin
  Result:=False;
end;

function TSDR.DoCloseDevice: Boolean;
begin
  Result:=False;
  Result:=self.DoCloseDevice;
end;

function TSDR.DoStartIQ: Boolean;
begin
  Result:=False;
end;

function TSDR.DoStopIQ: Boolean;
begin
  Result:=False;

end;

function TSDR.DoSetSampleRate: Boolean;
begin
  Result:=False;

end;

function TSDR.DoSetFreq(Freq:Int64): Boolean;
begin
  Result:=false;
end;

function TSDR.GetDeviceCount: integer;
begin
  Result:=0;

end;

function TSDR.StartIQ: Boolean;
var
  s:ansistring;
  z:int64;
  l:integer;
begin
  Result:=False;
  NullData;

  self.DoOpenFile(True);

  self.DoSetFreq(self.Freq);
  self.DoSetSampleRate;

  Result:=self.DoStartIQ;

end;


function TSDR.CompressFile(fn:String;destfn:String):boolean;
var
  s:String;
  s2:string;
begin
  Result:=false;
  s:='rar a -ep -k -m1 "'+destfn+'" "'+fn+'"';
  try
    RunCommand(s,s2);
    Result:=true;
  except
  end;
end;
{$ENDIF}

procedure TSDR.SetSamRate(AValue: DWORD);
begin
  if FSamRate=AValue then
    Exit;
  FSamRate:=AValue;
end;

procedure TSDR.InitIQMap();
var
  i:integer;
begin
  setlength(self.IQMap,$FFFF);
  for i := 0 to $FFFF  do
  begin
    IQMap[i].Imag:=(i and $FF)*1/128;
    IQMap[i].Real:=(i shr 8)*1/128;
  end;
  IQMapSize:=$FFFF;

end;

procedure TSDR.Sample2Complex(buf:Pointer;BufSize:DWORD;Complex:PComplexSingle_Array);
var
  b:PSingleArray;
begin
  b:=PSingleArray(@Complex^[0]);
  Sample2Single(buf,bufsize,b);
end;

procedure TSDR.Sample2Single_Byte(buf: Pointer; BufSize: DWORD; Dest: PSingleArray);
var
  buff:PByteArray;
  T:integer;
  i:integer;
begin
  BufSize:=(BufSize div 2)*2;
  fillchar(Dest^,sizeof(Single)*BufSize,0);
  buff:=buf;
  i:=0;
  while i<BufSize do
  begin
    T:=buff^[i];
    Dest^[i]:=self.IQMap[T].Real;
    Dest^[i+1]:=self.IQMap[T].Imag;
    inc(i,2);
  end;

end;

procedure TSDR.Sample2Single(buf: Pointer; BufSize: DWORD; Complex: PSingleArray);
begin
  case self.SampleBit of
    8: Sample2Single_Byte(buf,bufsize,Complex);
    16: ;
  end;
end;


constructor TSDR.Create();
begin
  {$IFDEF _WindowsOnly_}
  inherited Create();
  {$ELSE}
  inherited Create(True);


  self.FreeOnTerminate:=false;
  {$ENDIF}
  self.FEvent:=TEvent.Create(nil,false,false,'Event_'+self.ClassName+'_'+inttostr(DWORD(self)));
  self.FWaitWriteDoneEvent:=TEvent.Create(nil,True,false,'WaitWriteDoneEvent_'+self.ClassName+'_'+inttostr(DWORD(self)));
  FDeviceIndex:=0;
  self.FDeviceType:=dt_None;
  self.IQSlatIndex_En:=0;
  self.IQSlatIndex_De:=0;
  StrData:=TStringList.Create;
  tmpmem1:=TMemoryStream.Create;
  tmpmem2:=TMemoryStream.Create;
  BufList:=TThreadList.Create;

  {$IFDEF test}
  self.FCurIQFileName:='/tmp/test.dat';
  {$endif}

  {$IFNDEF _WindowsOnly_}
  StopFlag:=TLockValue.Create;

  self.Freq:=96800000;

  self.Resume;
  {$ENDIF}
end;



destructor TSDR.Destroy;
begin
  inherited Destroy;
end;

initialization
  WanIP:=TStringList.Create;
  LocalIP:=TStringList.Create;
  {$IFNDEF _WindowsOnly_}
  IQSaveDir:=GetCurDeskPath+'/data/';
  IQSaveDir:=Delete_Surplus_DirSep(IQSaveDir);
  {$ENDIF}

end.


