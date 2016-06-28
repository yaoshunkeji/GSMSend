unit GetIPInfoUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils,math,iconvenc,process,
  sockets,UnixType,baseunix,netdb;


{
const char ip138_QueryIP_Start[256]="您的IP是：[";
const char ip138_QueryIP_End[256]="]";
const char ip138_QueryIP_Info_Start[256]="来自：";
const char ip138_QueryIP_Info_End[256]="</center>";
const char ifconfig_me_start[256]="<strong id=\"ip_address\">";
const char ifconfig_me_end[256]="</strong>";

const char www_net_cn_start[256]= "您的本地上网IP是：";
const char www_net_cn_end1[256]=", ";
const char www_net_cn_end2[256]="</h2>";

//先大范围确定
//const char ip138_QueryInfo_Start[256]="<td align=\"center\"><h1>您查询的IP:";
//const char ip138_QueryInfo_End[256]="<br/><br/></td>";
//然后小范围
const char ip138_QueryInfo_Start1[256]="<ul class=\"ul1\"><li>";
const char ip138_QueryInfo_End1[256]="</li></ul></td>";
const char ip138_QueryInfo_DelHead[256]="本站主数据：";
const char ip138_QueryInfo_DelEnd[256]="参考数据";

const char dns_aizhan_com_IP_start[128]= {"您的IP地址是";
const char dns_aizhan_com_IP_end[128]= {"</font>";

const char dns_aizhan_com_Addr_start[128]= {"所在地区为：";
const char dns_aizhan_com_Addr_end[128]= {"</font>";

}

function getwanip_www_ip138_com(out ip:AnsiString;out addr:AnsiString):boolean;
function getwanip_dns_aizhan_com(out ip:AnsiString;out addr:AnsiString):boolean;
function getwanip_www_net_cn(out ip:AnsiString;out addr:AnsiString):boolean;
function GetLocalIP(strlst:TStrings=nil): string;

procedure TEST;

var
  IPINFO_getwanip_www_ip138_com:string;
  IPINFO_getwanip_dns_aizhan_com:string;


implementation

uses
  BaseNetUnit;


const

  ip138_QueryIP_Start       = '您的IP地址是：[';
  ip138_QueryIP_End         = ']';
  ip138_QueryIP_Info_Start  = '来自：';
  ip138_QueryIP_Info_End    = '<br/><br/></td>';
  ip138_QueryIP_DelHtml=False;

  //当前IP <font color="#008000">115.192.189.141</font> 所在地区为： <font color="#FF0000">浙江省杭州市</font>，共有  <font color="#FF0000" id="yhide">0</font> 个域名解析到该IP。
  dns_aizhan_com_IP_start= '当前IP';
  dns_aizhan_com_IP_end= '</font>';


  dns_aizhan_com_Addr_start='所在地区为：';
  dns_aizhan_com_Addr_end= '</font>';
  dns_aizhan_com_DelHtml=true;


  www_net_cn_Start       = '您的本地上网IP是：';
  www_net_cn_End         = ',';
//  www_net_cn_Info_Start  = '来自：';
//  www_net_cn_Info_End    = '<br/><br/></td>';
  www_net_cn_DelHtml=true;



function Do_getwanip(URL:string;out ip:string;out addr:string; const IPStart:string;const IPEnd:string; const AddrStart:string;const AddrEnd:string;bltrim:boolean=true;blhtml2txt:Boolean=true):boolean;
var
  m:TMemoryStream;
  s:string;
  p1,p2:integer;
  l:integer;
  strlst:TStringList;
  s1,s2:string;
//  en:string;
  h:THTTP_HEAD_INFO;
const
  MaxStrLen=1024*1024*8;
begin
  Result:=False;
  ip:='';
  Addr:='';

  m:=TMemoryStream.Create;
  Strlst:=TStringList.Create;
  if HttpGet(url,m,Strlst)<>200 then
  begin
    sysutils.freeAndNil(m);
    sysutils.freeandNil(Strlst);
    exit;
  end;
  l:=min(m.size,MaxStrLen);
  setlength(s,L);
//  m.SaveToFile('/tmp/a.html');
  Move(m.Memory^,s[1],L);
  sysutils.freeAndNil(m);
//  Strlst.SaveToFile('/tmp/b.txt');
  RespondLst2HttpHeadInfo(strlst,h);
  if not sysutils.SameText(h.CharSet,'utf-8') then
  s:=gb2312toutf8(s);

  if (IPStart<>'') and (IPEnd<>'') then
  begin
    ip:=CutSubStr(s,IPStart,IPEnd);
  end;
  if (AddrStart<>'') and (AddrEnd<>'') then
  begin
    addr:=CutSubStr(s,AddrStart,AddrEnd);
  end;
  if blhtml2txt then
  begin
    ip:=del_html_simple(ip);
    addr:=del_html_simple(addr);
  end;
  if bltrim then
  begin
    ip:=trim(ip);
    addr:=trim(addr);
  end;

  Result:=(Addr<>'') and (ip<>'');
  if (AddrStart='') and (AddrEnd='') then
  begin
    Result:=ip<>'';
  end;


end;

function getwanip_www_ip138_com(out ip:AnsiString;out addr:AnsiString):boolean;
begin
  ip:='';
  addr:='';
  Result:=Do_getwanip('http://www.ip138.com/ips1388.asp',ip,addr,ip138_QueryIP_Start,ip138_QueryIP_End,ip138_QueryIP_Info_Start,ip138_QueryIP_Info_End,true,ip138_QueryIP_DelHtml);
  if Result  then
  IPINFO_getwanip_www_ip138_com:=IP+'='+addr;
end;

function getwanip_dns_aizhan_com(out ip:AnsiString;out addr:AnsiString):boolean;
begin
  ip:='';
  addr:='';
  Result:=Do_getwanip('http://dns.aizhan.com/',ip,addr,dns_aizhan_com_IP_start,dns_aizhan_com_IP_end,dns_aizhan_com_Addr_start,dns_aizhan_com_Addr_end,true,dns_aizhan_com_DelHtml);
  if Result then
  IPINFO_getwanip_dns_aizhan_com:=IP+'='+addr;;
end;


function getwanip_www_net_cn(out ip:AnsiString;out addr:AnsiString):boolean;
begin
  Result:=Do_getwanip('http://www.net.cn/static/customercare/yourip.asp',ip,addr,www_net_cn_Start,www_net_cn_End,'','',true,www_net_cn_DelHtml);
end;


function GetLocalIP(strlst:TStrings=nil): string;
var
  ifa,oifa:pifaddrs;
  saddr:Psockaddr;
  addr:in_addr;
  s:string;
  e:Boolean;

begin
Result:='';
ifa:=nil;

if (getifaddrs(@ifa) < 0) then
exit;
oifa := ifa;

while ifa<>nil do
begin
  e:=false;
  if (ifa.ifa_addr = nil) then
  e:=true;
  if not e then
  begin
    if (ifa.ifa_addr.sa_family <> AF_INET) or (strpas(ifa.ifa_name)='lo') then
    begin
      e:=true;
    end;
  end;

  if not e then
  begin
    saddr := ifa.ifa_addr;
    addr:=saddr^.sin_addr;

    s := sysutils.Format('%d.%d.%d.%d',[Addr.s_bytes[1],Addr.s_bytes[2],Addr.s_bytes[3],Addr.s_bytes[4]]);
    if strlst<>nil then
    begin
      strlst.Add(strpas(ifa^.ifa_name)+'='+s);
//      writeln(strpas(ifa^.ifa_name)+'='+s);
    end;
//    writeln(strpas(ifa^.ifa_name)+'='+s);

  end;
  ifa := ifa^.ifa_next;

end;

freeifaddrs(oifa);

end;

procedure TEST;
var
  a,b:string;
  strlst:TStringList;
begin
  a:='';
  b:='';
  if getwanip_www_ip138_com(a,b) then
  begin
    writeln('getwanip_www_ip138_com:' +a+'  '+b);
  end
  else
  begin
    writeln('getwanip_www_ip138_com() = failed');
  end;

  if getwanip_dns_aizhan_com(a,b) then
  begin
    writeln('getwanip_dns_aizhan_com:' +a+'  '+b);
  end
  else
  begin
    writeln('getwanip_dns_aizhan_com() = failed');
  end;
  if getwanip_www_net_cn(a,b) then
  begin
    writeln('getwanip_www_net_cn:' +a+'  ');
  end
  else
  begin
    writeln('getwanip_www_net_cn() = failed');
  end;

  strlst:=TStringList.Create;
  GetLocalIP(strlst);
  begin
    writeln('GetLocalIP:');
    writeln(strlst.Text);
  end;


end;

end.

