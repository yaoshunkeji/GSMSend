unit UTF8toUCS2_Unit;

{$mode objfpc}{$H+}

interface
{
  http://biancheng.dnbcw.info/c/411829.html
  http://www.cnblogs.com/findumars/p/4591082.html
}
uses
  Classes, SysUtils;

function UTF8toUCS2Code(utf8_Byte:PByte;ucs2_Word:Pointer):integer;

function UCS2PDU(UCS2:pointer;len:integer):AnsiString;

implementation

function UCS2PDU(UCS2:pointer;len:integer):AnsiString;
var
  i:integer;
  buf:PByteArray;
begin
//  l:=len div 2;
  i:=0;
  Result:='';
  buf:=UCS2;
  while i<len do
  begin
    Result:=Result+sysutils.IntToHex(buf^[i+1],2);
    Result:=Result+sysutils.IntToHex(buf^[i+0],2);
    inc(i,2);
  end;


end;

function UTF8toUCS2Code(utf8_Byte:PByte;ucs2_Word:Pointer):integer;
var
  temp1, temp2:WORD;
  out1:PWORD;
  in1:PByte;
  in2:PByteArray;

  i:integer;
begin
  i:=0;
  Result:=0;
  if (utf8_Byte=nil) or (ucs2_Word=nil) then
  exit;

  out1 := ucs2_Word;
  in1  := utf8_Byte;

  while in1^ <>0 do
  begin
    in2:=PByteArray(in1);
    if ((in1^ and $80)=0) then
    begin
          // 1 byte UTF-8 Charater
      out1^:=in1^;
      inc(in1);
    end
    else
    if (( in1^ and $E0)=$C0) and ((in2^[1] and $C0)=$80) then
    begin
      // 2 bytes UTF-8 Charater
      temp1 :=in1^ and $1F;
      inc(in1);
      temp1:=temp1 shl 6;
      temp2:=in1^ and $3F;
      temp1:=temp1 or temp2;
      inc(in1);
      out1^:=temp1;
    end
    else
    if ((in1^ and $F0)=$E0) and ((in2^[1] and $C0)=$80) and ((in2^[2] and $C0)=$80) then
    begin
      // 3bytes UTF-8 Charater.*/
      temp1 := (in1^ and $0f);
      inc(in1);
      temp1 :=temp1 shl 12;
      temp2 := (in1^ and $3F);
      inc(in1);
      temp2 := temp2 shl 6;
      temp1 := temp1 or temp2 or (in1^ and $3F);
      inc(in1);
      out1^ := temp1;
    end
    else
    begin
    // unrecognize byte.
      result:=0;
      exit;
    end;
    inc(out1);
    Result:=Result+1;
  end;

end;




end.

