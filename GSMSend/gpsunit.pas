unit GpsUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils,syncobjs,dateutils,process,vsComPort,vsComPortbase;

const
  GPSDeviceName:array[0..5-1] of string=
    (
      '/dev/ttyACM0',
      '/dev/ttyACM1',
      '/dev/ttyACM2',
      '/dev/ttyACM3',
      '/dev/ttyACM4'
    );

type
  { TGPSDevice }
  TOnGPSData=procedure(sender:TObject;GPSData:String) of object;

  TGPSDevice= class(TvsComPort)
  private
    CS:TCriticalSection;
    FAutoFixLocalTime: Boolean;
    FCurGPSTime: TDateTime;
    FCurGPSX: String;
    FCurGPSY: String;
    FCurGPSZ: string;
    FGPSStar: integer;
    FLastGPS: TDateTime;
    strlst:TStringList;
    FLastFixTime:TDateTime;    //最后什么时候修复时间的
    FOnGPSData:TOnGPSData;

    function GetCurGPSTime: TDateTime;
    function GetCurGPSX: String;
    function GetCurGPSY: String;
    function GetCurGPSZ: string;
    function GetGPSStar: integer;
    function GetLastGPS: TDateTime;
    procedure DoRxData(Sender: TObject);

    procedure SetCurGPSTime(AValue: TDateTime);
    procedure SetCurGPSX(AValue: String);
    procedure SetCurGPSY(AValue: String);
    procedure SetCurGPSZ(AValue: string);
    procedure SetGPSStar(AValue: integer);
    procedure SetLastGPS(AValue: TDateTime);
  protected
    property OnRxData;
    procedure DoFixLocalTime;

    procedure ProcGPS_GPRMC;
    procedure ProcGPS_GPTXT;
    procedure ProcGPS_GPVTG;
    procedure ProcGPS_GPGGA;
    procedure ProcGPS_GPGLL;

    function ConverGPSPos(s: String): String;   //转换度分坐标(dddmm.mmmmm)到数字坐标

  public
    function Open: Boolean;

    property CurGPSX:String read GetCurGPSX write SetCurGPSX;
    property CurGPSY:String read GetCurGPSY write SetCurGPSY;
    property CurGPSZ:string read GetCurGPSZ write SetCurGPSZ;
    property CurGPSTime:TDateTime read GetCurGPSTime write SetCurGPSTime;
    property LastGPS:TDateTime read GetLastGPS write SetLastGPS;
    property GPSStar:integer read GetGPSStar write SetGPSStar;
    property OnGPSData:TOnGPSData read FOnGPSData write FOnGPSData;
    property AutoFixLocalTime:Boolean read FAutoFixLocalTime write FAutoFixLocalTime;
    function GetData:String;

    constructor Create;
    destructor Destroy; override;
  published
  end;

var
  GPSDevice:TGPSDevice=nil;

  function CheckGPSDevice():integer;


implementation

{ TGPSDevice }

function CheckGPSDevice():integer;
var
  i:integer;
begin
  Result:=-1;
  for i := 0 to length(GPSDeviceName) do
  begin
    if sysutils.FileExists(GPSDeviceName[i]) then
    begin
      Result:=i;
      exit;
    end;
  end;

end;

function TGPSDevice.GetCurGPSX: String;
begin
  CS.Enter;
  Result:=self.FCurGPSX;
  CS.Leave;
end;

procedure TGPSDevice.ProcGPS_GPRMC();
var
  s,s0,s1,s2,s3:string;
  posOk:Boolean;
  TimeOK:Boolean;
  t:TDateTime;
  d:TDateTime;
begin

  posok:=False;
  timeok:=false;
  t:=0;
  d:=0;
  s0:='';
  s1:='';
  s2:='';
  s3:='';

  {
  //UTC时间、定位状态（A－可用，V－可能有错误）、纬度值、经度值、对地速度、日期等
  Recommended Minimum Specific GPS/TRANSIT Data（RMC）推薦定位資訊



  $GPRMC,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>*hh


    <1> UTC时间，hhmmss（时分秒）格式
    <2> 定位状态，A=有效定位，V=无效定位
    <3> 纬度ddmm.mmmm（度分）格式（前面的0也将被传输）
    <4> 纬度半球N（北半球）或S（南半球）
    <5> 经度dddmm.mmmm（度分）格式（前面的0也将被传输）
    <6> 经度半球E（东经）或W（西经）
    <7> 地面速率（000.0~999.9节，前面的0也将被传输）
    <8> 地面航向（000.0~359.9度，以真北为参考基准，前面的0也将被传输）
    <9> UTC日期，ddmmyy（日月年）格式
    <10> 磁偏角（000.0~180.0度，前面的0也将被传输）
    <11> 磁偏角方向，E（东）或W（西）
    <12> 模式指示（仅NMEA0183 3.00版本输出，A=自主定位，D=差分，E=估算，N=资料无效）
    }

  if strlst.Count<13 then
  exit;
//    if (strlst.Strings[12]='D') or (strlst.Strings[12]='A') then
  if (strlst.Strings[12]='A') then
  begin
    posok:=True;
    timeok:=true;
  end;
  if strlst.Strings[2]='A' then
  begin
    posok:=True;
    timeok:=true;
  end;
  s1:=strlst.Strings[3];
  s2:=strlst.Strings[5];
  if (length(s1)>4) and (length(s2)>4) then
  begin
    self.CurGPSX:=ConverGPSPos(s1)+strlst.Strings[4];
    self.CurGPSY:=ConverGPSPos(s2)+strlst.Strings[6];
    self.LastGPS:=now;
    posok:=true;
  end
  else
  begin
    posok:=False;
    timeok:=False;
  end;
  s0:=strlst.Strings[9];
  s:=strlst.Strings[1];
  if length(s0)<>6 then
  timeok:=false;
  if length(s)<6 then
  timeok:=false;

  if timeok then
  begin
    s1:=copy(s0,1,2);
    s2:=copy(s0,3,2);
    s3:=copy(s0,5,2);
    if not sysutils.TryStrToDateTime('20'+s3+'-'+s2+'-'+s1,d) then
    begin
      timeok:=false;
    end;
    s1:=copy(s,1,2);
    s2:=copy(s,3,2);
    s3:=copy(s,5,2);
    if not sysutils.TryStrToTime(s1+':'+s2+':'+s3,t) then
    begin
      timeok:=false;
    end;

    if timeok then
    begin
      self.CurGPSTime:=d+t+8*dateutils.OneHour;
      self.DoFixLocalTime;
    end;
  end;

end;

procedure TGPSDevice.ProcGPS_GPTXT();
begin
  {
    $GPTXT,01,01,02,u-blox ag - www.u-blox.com*50
    $GPTXT,01,01,02,HW  UBX-G70xx   00070000 *77
    $GPTXT,01,01,02,ROM CORE 1.00 (59842) Jun 27 2012 17:43:52*59
    $GPTXT,01,01,02,PROTVER 14.00*1E
    $GPTXT,01,01,02,ANTSUPERV=AC SD PDoS SR*20
    $GPTXT,01,01,02,ANTSTATUS=OK*3B
    $GPTXT,01,01,02,LLC FFFFFFFF-FFFFFFFD-FFFFFFFF-FFFFFFFF-FFFFFFF9*53
  }
end;

procedure TGPSDevice.ProcGPS_GPVTG();
begin
  {
   //对地速度等
   2.5、 Track Made Good and Ground Speed（VTG）地面速度资讯
   $GPVTG,<1>,T,<2>,M,<3>,N,<4>,K,<5>*hh
   <1> 以真北为参考基准的地面航向（000~359度，前面的0也将被传输）
   <2> 以磁北为参考基准的地面航向（000~359度，前面的0也将被传输）
   <3> 地面速率（000.0~999.9节，前面的0也将被传输）
   <4> 地面速率（0000.0~1851.8公里/小时，前面的0也将被传输）
   <5> 模式指示（仅NMEA0183 3.00版本输出，A=自主定位，D=差分，E=估算，N=资料无效）
 }




end;

function TGPSDevice.ConverGPSPos(s:String):String;
var
  f:double;
begin
  f := StrToFloatDef(s,0) / 100;
  f:=Int(f) + (Frac(f) * 5) / 3;
  s:=sysutils.FormatFloat('0.0000000000',f);
  Result:=s;
end;

procedure TGPSDevice.ProcGPS_GPGGA();
var
  s:String;
  s0,s1,s2,s3:string;
  cmd:String;
  posOk:Boolean;
  TimeOK:Boolean;
  t:TDateTime;
  d:TDateTime;
  i:integer;

  tmpStr: string;
  tmpFloat: Double;


begin
{
    $GPGGA,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,M,<10>,M,<11>,<12>*hh

    <1> UTC时间，hhmmss（时分秒）格式
    <2> 纬度ddmm.mmmm（度分）格式（前面的0也将被传输）
    <3> 纬度半球N（北半球）或S（南半球）
    <4> 经度dddmm.mmmm（度分）格式（前面的0也将被传输）
    <5> 经度半球E（东经）或W（西经）
    <6> GPS状态：0=未定位，1=非差分定位，2=差分定位，6=正在估算
      GPS状态， 0初始化， 1单点定位， 2码差分， 3无效PPS， 4固定解， 5浮点解， 6正在估算 7，人工输入固定值， 8模拟模式， 9WAAS查分
    <7> 正在使用解算位置的卫星数量（00~12）（前面的0也将被传输）
    <8> HDOP水准精度因数（0.5~99.9）
    <9> 海拔高度（-9999.9~99999.9）
    <10> 地球椭球面相对大地水准面的高度
    <11> 差分时间（从最近一次接收到差分信号开始的秒数，如果不是差分定位将为空）
    <12> 差分站ID号0000~1023（前面的0也将被传输，如果不是差分定位将为空）
}

  if strlst.Count<13 then
  exit;

  if (strlst.Strings[6]='0') or (strlst.Strings[6]='6') then     //没有定位
  begin
    self.GPSStar:=-1;
    exit;
  end;
  s:=strlst.Strings[7];
  if not sysutils.TryStrToInt(s,i) then
  begin
    self.GPSStar:=-1;
    exit;
  end;

  if not (i in [0..12]) then
  begin
    self.GPSStar:=-1;
    exit;
  end;

  self.CS.Enter;
  try
  self.GPSStar:=i;

  if i>=3 then
  begin
    self.LastGPS:=now;

    s1:=strlst.Strings[2];  //+strlst.Strings[3];
    s2:=strlst.Strings[4];  //+strlst.Strings[5];

    self.CurGPSX:=ConverGPSPos(s1)+strlst.Strings[3];
    self.CurGPSY:=ConverGPSPos(s2)+strlst.Strings[5];
//    self.CurGPSZ:=strlst.Strings[9];
    s1:=strlst.Strings[9];

  end;
  except
  end;
  if i<=3 then
  begin
    self.CurGPSZ:='';
  end;
  if i>=4 then
  begin
    self.CurGPSZ:=strlst.Strings[9];
  end;






end;

procedure TGPSDevice.ProcGPS_GPGLL;
begin
  //TC时间、纬度值、经度值、定位状态（无效、单点定位、差分）、校验和
  {
  字段1：纬度ddmm.mmmm，度分格式（前导位数不足则补0）
  字段2：纬度N（北纬）或S（南纬）
  字段3：经度dddmm.mmmm，度分格式（前导位数不足则补0）
  字段4：经度E（东经）或W（西经）
  字段5：UTC时间，hhmmss.sss格式
  字段6：状态，A=定位，V=未定位
  字段7：校验值
  }




end;


procedure TGPSDevice.DoRxData(Sender: TObject);
var
  s:String;
  s0,s1,s2,s3:string;
  cmd:String;
  posOk:Boolean;
  TimeOK:Boolean;
  t:TDateTime;
  d:TDateTime;
begin
  s:=self.ReadData;
  if s='' then
  exit;

  if system.Assigned(self.FOnGPSData) then
  begin
    self.FOnGPSData(self,s);
  end;
  strlst.Clear;
  strlst.DelimitedText:=s;
  if strlst.Count=0 then
  exit;

  cmd:=strlst.Strings[0];

  if not sysutils.SameText(copy(cmd,1,3),'$GP') then
  exit;



  if sysutils.SameText(cmd,'$GPTXT') then
  begin
    ProcGPS_GPTXT();
    exit;
  end;



 {
  //对地速度等
  2.5、 Track Made Good and Ground Speed（VTG）地面速度资讯
}
  if sysutils.SameText(cmd,'$GPVTG') then
  begin
    ProcGPS_GPVTG;
    exit;
  end;

{
  //  UTC时间、纬度值、经度值、定位状态（无效、单点定位、差分）、
  //  观测的GPS卫星个数、HDOP值、GPS椭球高、天线架设高度、差分数据龄期、
  //  差分基准站编号、校验和

  Global Positioning System Fix Data（GGA）GPS定位資訊
  }
  if sysutils.SameText(cmd,'$GPGGA') then
  begin
    self.ProcGPS_GPGGA;
    exit;
  end;
  //TC时间、纬度值、经度值、定位状态（无效、单点定位、差分）、校验和
  if sysutils.SameText(cmd,'$GPGLL') then
  begin
    self.ProcGPS_GPGLL;
    exit;
  end;

  {
  GPS Satellites in View（GSV）可見衛星資訊
  $GPGSV, <1>,<2>,<3>,<4>,<5>,<6>,<7>,?<4>,<5>,<6>,<7>,<8>



  <1> GSV語句的總數
  <2> 本句GSV的編號
  <3> 可見衛星的總數，00 至 12。
  <4> 衛星編號， 01 至 32。
  <5>衛星仰角， 00 至 90 度。
  <6>衛星方位角， 000 至 359 度。實際值。
  <7>訊號雜訊比（C/No）， 00 至 99 dB；無表未接收到訊號。
  <8>Checksum.(檢查位).
  }

  if sysutils.SameText(cmd,'$GPGSV') then
  begin

    exit;
  end;
  {
    定位模式（M－手动，强制二维或三维定位；A－自动，自动二维或三维定位）、定位中使用的卫星ID号、PDOP值、HDOP值、VDOP值

    $GPGSA,<1>,<2>,<3>,<4>,,,,,<12>,<13>,<14>, <15>,<16>,<17>,<18>

    <1>模式 ：M = 手動， A = 自動。
    <2>定位型式 1 = 未定位， 2 = 二維定位， 3 = 三維定位。
    <3>到<14>PRN 數字：01 至 32 表天空使用中的衛星編號，最多可接收12顆衛星資訊



          (上面藍色處，總共有12個)。
    <15> PDOP位置精度因數（0.5~99.9）
    <16> HDOP水準精度因數（0.5~99.9）
    <17> VDOP垂直精度因數（0.5~99.9）
    <18> Checksum.(檢查位)
  }
  if sysutils.SameText(cmd,'$GPGSA') then
  begin

    exit;
  end;

  //信标台的信号强度、信噪比、信标频率、串列传输速率、通道号
  if sysutils.SameText(cmd,'$GPMSS') then
  begin

    exit;
  end;

  //UTC时间、定位状态（A－可用，V－可能有错误）、纬度值、经度值、对地速度、日期等
  //Recommended Minimum Specific GPS/TRANSIT Data（RMC）推荐定位资讯
  if sysutils.SameText(cmd,'$GPRMC') then   //
  begin
    self.ProcGPS_GPRMC();


    exit;
  end;
  {
  //UTC时间、年、月、日、当地时区、时区的分钟值等
  $GPZDA,<1>,<2>, <3> , <4> , <5> , <6> *CC

  <1> UTC时间，hhmmss（时分秒）格式
  <2> 日
  <3> 月
  <4> 年
  <5> 本地时区小时便宜量
  <6>本地时区分钟便宜量
  }
  if sysutils.SameText(cmd,'$GPZDA') then
  begin

    exit;
  end;

end;

function TGPSDevice.GetCurGPSTime: TDateTime;
begin
  CS.Enter;
  Result:=self.FCurGPSTime;
  CS.Leave;
end;

function TGPSDevice.GetCurGPSY: String;
begin
  CS.Enter;
  Result:=self.FCurGPSY;
  CS.Leave;
end;

function TGPSDevice.GetCurGPSZ: string;
begin
  CS.Enter;
  Result:=self.FCurGPSZ;
  CS.Leave;
end;

function TGPSDevice.Open:Boolean;
begin
  if CheckGPSDevice<>-1 then
  self.Device:=GPSDeviceName[CheckGPSDevice]
  else
  self.Device:='';

  self.Active:=true;


end;

function TGPSDevice.GetData: String;
begin
  Result:='';
  self.CS.Enter;
  Result:=sysutils.Format('GPS_X=%s,GPS_Y=%s,GPS_Z=%s',[self.CurGPSX,self.CurGPSY,self.CurGPSZ]);
  Result:=Result+sysutils.Format(',GPS_Star=%d,GPS_Date=%s,GPS_Time=%s',[self.GPSStar,sysutils.FormatDateTime('yyyy-MM-dd',self.CurGPSTime),sysutils.FormatDateTime('HH:nn:ss',self.CurGPSTime)]);
  self.CS.Leave;
end;

function TGPSDevice.GetLastGPS: TDateTime;
begin
  CS.Enter;
  Result:=self.FLastGPS;
  CS.Leave;
end;

function TGPSDevice.GetGPSStar: integer;
begin
  CS.Enter;
  Result:=self.FGPSStar;
  CS.Leave;
end;

procedure TGPSDevice.SetCurGPSTime(AValue: TDateTime);
begin
  CS.Enter;
  if FCurGPSTime<>AValue then
  FCurGPSTime:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.SetCurGPSX(AValue: String);
begin
  CS.Enter;
  if FCurGPSX<>AValue then
  FCurGPSX:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.SetCurGPSY(AValue: String);
begin
  CS.Enter;
  if FCurGPSY<>AValue then
  FCurGPSY:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.SetCurGPSZ(AValue: string);
begin
  CS.Enter;
  if FCurGPSZ<>AValue then
  FCurGPSZ:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.SetGPSStar(AValue: integer);
begin
  CS.Enter;
  if FGPSStar<>AValue then
  FGPSStar:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.SetLastGPS(AValue: TDateTime);
begin
  CS.Enter;
  if FLastGPS<>AValue then
  FLastGPS:=AValue;
  CS.Leave;
end;

procedure TGPSDevice.DoFixLocalTime;
var
  T,T2:TDateTime;
  s,s2:String;
begin
  if self.FCurGPSTime=0 then
  exit;

  if not self.FAutoFixLocalTime then
  exit;

  T:=now;
  T2:=self.FLastFixTime-T;
  if abs(T2)<=dateutils.OneSecond*5 then
  begin
    exit;
  end;
  T2:=T-self.FCurGPSTime;

  if abs(T2)>=(dateutils.OneSecond*15) then
  begin
    try
    s:='/bin/date -s "'+sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',self.FCurGPSTime)+'"';
    process.RunCommand(s,s2);
    except
    end;
  end;
end;

constructor TGPSDevice.Create;
begin
  inherited Create(nil);
  CS:=TCriticalSection.Create;
  self.RcvLineCRLF:=true;
  strlst:=TStringList.Create;
  strlst.Delimiter:=',';
  self.OnRxData:=self.DoRxData;
  if CheckGPSDevice<>-1 then
  self.Device:=GPSDeviceName[CheckGPSDevice];
  self.BaudRate:=br__9600;
  self.StopBits:=sbOne;
  self.Parity:=pNone;
  self.FlowControl:=fcNone;
  self.DataBits:=db8bits;
  FAutoFixLocalTime:=True;

end;

destructor TGPSDevice.Destroy;
begin
  sysutils.FreeAndNil(CS);
  sysutils.freeandnil(strlst);
  inherited Destroy;

end;

initialization
  GPSDevice:=TGPSDevice.Create;
  sysutils.FormatSettings.LongTimeFormat:='HH:nn:ss';
  sysutils.FormatSettings.DateSeparator:='-';
  sysutils.FormatSettings.TimeSeparator:=':';
  sysutils.FormatSettings.ShortTimeFormat:='HH:nn:ss';
  sysutils.FormatSettings.LongDateFormat:='yyyy-MM-dd';
  sysutils.FormatSettings.ShortDateFormat:='yyyy-MM-dd';


finalization


end.

