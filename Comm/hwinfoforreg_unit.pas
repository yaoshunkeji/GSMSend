unit HwInfoForReg_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils,process;


function GetSys_UUID:string;
function GetSys_SN:string;
function GetSysBrd_SN:string;
function GetCPUID_Str:string;
function GetMainDisk_Feature(Model:boolean=true;SerialNo:boolean=true;Name:boolean=true):String;
//网卡，从commfununit中



implementation

function GetMainDisk_Feature(Model:boolean=true;SerialNo:boolean=true;Name:boolean=true):String;
var
  s,s2:string;
  strlst:TStringList;
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
  a:='';
  b:='';
  if Name then
  a:='M='+strlst.Values['Model']
  else
  a:=strlst.Values['Model'];

  if Name then
  b:='SN='+strlst.Values['SerialNo']
  else
  b:=strlst.Values['SerialNo'];
  if Model and SerialNo then
  begin
    Result:=A+','+B;
  end
  else
  begin
    if Model then
    Result:=A;
    if SerialNo then
    Result:=B;
  end;

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
  str:=GetSysBrd_SN;
  z:=False;
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

end.

