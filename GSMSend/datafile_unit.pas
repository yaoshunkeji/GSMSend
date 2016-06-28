unit DataFile_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils,zlib,math;

const
  DataFileHeadFlag='DataFile';

type
  TDataFile=packed record   //128
    HeadFlag:array[0..16-1] of ansiChar;
    ver:integer;
    FileSize:DWORD;
    DataSize_Org:DWORD;
    DataSize_Compress:DWORD;
    Compress:integer;
    DataType:array[0..16-1] of AnsiChar;
    DataCount:integer;
    DataCRC:DWORD;
    DataPos:DWORD;

    Salt:array[0..12-1] of byte;
    SaltLen:integer;
    Res:array[0..48-1] of byte;
  end;


function StrLst2DataFile(strlst:TStringList;FileName:String;DataType:AnsiString):Boolean;
function DataFile2StrLst(FileName:String;strlst:TStringList;var DataType:String):Boolean;

implementation

uses
  CRC32_Unit;

function StrLst2DataFile(strlst:TStringList;FileName:String;DataType:AnsiString):Boolean;
var
  h:TDataFile;
  Mem:TMemoryStream;
  mem2:TMemoryStream;
  i:integer;
  s:String;
  d:dword;
const
  CRLF=#13#10;
begin
Result:=False;
mem:=TMemoryStream.Create;
for i := 0 to strlst.Count-1 do
begin
  s:=strlst.Strings[i];
  mem.Write(s[1],length(s));
  mem.Write(CRLF[1],length(CRLF));
end;

if length(DataType)>=length(h.DataType) then
setlength(DataType,length(h.DataType)-1);

fillchar(h,sizeof(h),0);
h.HeadFlag:=DataFileHeadFlag;
h.DataType:=DataType;
h.DataSize_Org:=mem.Size;
h.DataSize_Compress:=mem.Size;
h.DataCount:=strlst.Count;
h.DataPos:=sizeof(h);
h.SaltLen:=0;

mem2:=TMemoryStream.Create;
mem2.Size:=max(mem.Size*2,1024*128);
d:=mem2.Size;
i:=zlib.compress(mem2.Memory,@d,mem.Memory,mem.Size);
if i<>Z_OK then
begin
  sysutils.FreeAndNil(mem2);
  sysutils.FreeAndNil(mem);
  exit;
end;
h.DataSize_compress:=d;
h.DataCRC:=UpdateCRC32(mem2.Memory,d);
h.Compress:=1;
h.FileSize:=sizeof(h)+d;
mem.Clear;
mem.Write(h,sizeof(h));
mem.Write(mem2.Memory^,d);

mem.SaveToFile(filename);
sysutils.FreeAndNil(mem);
sysutils.FreeAndNil(mem2);
Result:=true;
//h.FileSize

end;

function DataFile2StrLst(FileName:String;strlst:TStringList;var DataType:String):Boolean;
var
  h:TDataFile;
  Mem:TMemoryStream;
  mem2:TMemoryStream;
  i:integer;
  s:String;
  d:dword;
  p:PByte;
  L,L2:DWORD;
const
  CRLF=#13#10;
begin
  Result:=False;
  fillchar(h,sizeof(h),0);
  mem:=nil;
  mem2:=nil;
  strlst.Clear;
  if not sysutils.FileExists(FileName) then
  exit;

  mem:=TMemoryStream.Create;
  mem.LoadFromFile(filename);
  mem.Read(h,sizeof(h));
  if (h.DataPos>mem.Size) or (H.SaltLen>length(h.Salt)) or (H.FileSize<mem.Size) then
  begin
    sysutils.FreeAndNil(mem);
    exit;
  end;
  L:=h.DataSize_Compress;
  L:=min(L,mem.Size-mem.Position);
  p:=mem.Memory;
  inc(p,h.DataPos);
  d:=UpdateCRC32(p,L);
  if d<>h.DataCRC then
  begin
    sysutils.FreeAndNil(mem);
    exit;
  end;
  if h.Compress=1 then
  begin
    L2:=0;
    mem2:=TMemoryStream.Create;
    mem2.Size:=h.DataSize_Org+4096;
    l2:=mem2.Size;
    i:=zlib.uncompress(mem2.Memory,@L2,pointer(p),L);
    if i<>Z_OK then
    begin
      sysutils.FreeAndNil(mem);
      sysutils.FreeAndNil(mem2);
      exit;
    end;
    mem2.Size:=l2;
    sysutils.FreeAndNil(mem);
    mem:=mem2;
  end;

  strlst.LoadFromStream(mem);

  sysutils.FreeAndNil(mem);
  DataType:=trim(h.DataType);
  Result:=true;

end;


end.

