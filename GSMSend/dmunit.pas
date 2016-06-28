unit dmunit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, db, BufDataset, Sqlite3DS, sqldb, sqlite3conn, FileUtil, Variants,syncobjs
  ,Sqlite3Wrapper, CustomSqliteDS, memds,sqlite3dyn

  ,fununit;

type

  { TDataModule1 }
  TDataModule1 = class(TDataModule)
    BufDataset1: TBufDataset;
    ds_lv1: TDataSource;
    ds_lv2: TDataSource;
    ds_AutoSend_histimei: TDataSource;
    ds_devinfo: TDataSource;
    ds_history: TDataSource;
    ds_sys_imei: TDataSource;
    ds_user_imei: TDataSource;
    md_lv1__: TMemDataset;
    md_lv2__: TMemDataset;
    qry_AutoSend_histimeiFindTime: TDateTimeField;
    qry_AutoSend_histimeiID: TLongintField;
    qry_AutoSend_histimeiIMEI: TMemoField;
    qry_AutoSend_histimeiIMSI: TMemoField;
    qry_AutoSend_histimeiLastTime: TDateTimeField;
    qry_AutoSend_histimeiModel: TMemoField;
    qry_AutoSend_histimeiModem: TLongintField;
    qry_AutoSend_histimeiSelect1: TBooleanField;
    qry_AutoSend_histimeiTMSI: TMemoField;
    qry_devinfoFindTime: TDateTimeField;
    qry_devinfoID: TLongintField;
    qry_devinfoIMEI: TMemoField;
    qry_devinfoIMSI: TMemoField;
    qry_devinfoLastRegTime: TDateTimeField;
    qry_devinfoLastTime: TDateTimeField;
    qry_devinfoModel: TMemoField;
    qry_devinfoModem: TLongintField;
    qry_devinfoTMSI: TMemoField;
    qry_historyEncode: TMemoField;
    qry_historyfromTel: TMemoField;
    qry_historyfrom_imei: TMemoField;
    qry_historyfrom_imsi: TMemoField;
    qry_historyID: TLongintField;
    qry_historyMEMO: TMemoField;
    qry_historyMode: TLongintField;
    qry_historytime: TStringField;
    qry_historyToTel: TMemoField;
    qry_historyto_imei: TMemoField;
    qry_historyto_imsi: TMemoField;
    qry_sysimeiinfoc: TLargeintField;
    qry_sysimeiinfocorp: TMemoField;
    qry_sys_imeic: TLongintField;
    qry_sys_imeicorp: TMemoField;
    qry_userdbID: TAutoIncField;
    qry_userdbmodel: TMemoField;
    qry_userdbModem: TLongintField;
    qry_userdbtac: TMemoField;
    qry_sys_imei: TSqlite3Dataset;
    qry_user_imei: TSqlite3Dataset;
    qry_user_imeiID: TLongintField;
    qry_user_imeimodel: TMemoField;
    qry_user_imeiModem: TLongintField;
    qry_user_imeitac: TMemoField;
    qry_history: TSqlite3Dataset;
    SQLite3Connection1: TSQLite3Connection;
    qry_devinfo: TSqlite3Dataset;
    qry_AutoSend_histimei: TSqlite3Dataset;
    SQLQueryarfcn: TLongintField;
    SQLQueryband: TMemoField;
    SQLQuerydownlink: TLargeintField;
    SQLQueryID: TAutoIncField;
    SQLQueryuplink: TLargeintField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure qry_AutoSend_histimeiFindTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_AutoSend_histimeiIMEIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_AutoSend_histimeiIMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_AutoSend_histimeiLastTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_AutoSend_histimeiModelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_AutoSend_histimeiTMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoFindTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoIMEIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoIMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoLastRegTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoLastTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoModelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_devinfoTMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historyEncodeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historyfromTelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historyfrom_imeiGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historyMEMOGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historytimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_historyto_imeiGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_sys_imeicorpGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_user_imeimodelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure qry_user_imeitacGetText(Sender: TField; var aText: string; DisplayText: Boolean);
  private

    function CreateAndLockQuery(UserDB: Boolean; Commit: Boolean=False): TSqlite3Dataset;

    { private declarations }
  public
    CS_SysDB:TCriticalSection;
    CS_UsrDB:TCriticalSection;

    procedure LockCS(UserDB:Boolean);
    procedure UnLockCS(UserDB:Boolean);

    function ConectDB: boolean;
    function ExecSQL(SQL: String; userdb: boolean): Boolean;overload;
    function ExecSQL(SQL: TStringList; userdb: boolean): Boolean;overload;
    function GetImeiInfo(aimei:string;aimsi:string):TDeviceInfo;
    function GetValueDB(SQL: String; field: string; userdb: boolean): AnsiString;

    function GetSysValue(const Key: AnsiString): AnsiString;
    procedure SetSysValue(const Key: AnsiString; const Value: AnsiString;AllowNewRow: Boolean=False;Flag:integer=1);
    procedure SaveDevinfo(di: TDeviceInfo;blReg:Boolean=False);
    procedure SaveUserLog(const strlst:TStringList;Flag:integer=0);
    procedure DeConectDB;
    procedure ApplyUpdates(D:TDataSet);
    function GetNewDataset(UserDB:Boolean;SQL:string):TSqlite3Dataset;
  end;

var
  DataModule1: TDataModule1=nil;

function LoadARFCNList(BandName:string;lst:TStrings;arfcn:integer=-1):integer;
function TryStr2Int(str:string;default:integer=-1):integer;

type
  TBandInfo=record
    ID:integer;
    Band:string[32];
    ARFCN:integer;
    DownLink:integer;
    UpLink:integer;
    Info:string[128];
  end;
  TBandList=array of TBandInfo;

var
  BandList:TBandList;

implementation

{$R *.lfm}

uses
  CRC16_Unit,pdu_unit,CommFunUnit;

{ TDataModule1 }


//把真的userdb放到深目录中，在自己目录下随机一个userdb.db，欺骗一下

function TryStr2Int(str:string;default:integer=-1):integer;
begin
  str:=sysutils.trim(str);
  if not sysutils.TryStrToInt(str,result) then
  Result:=default;
end;

function LoadARFCNList(BandName:string;lst:TStrings;arfcn:integer=-1):integer;
var
  qry:TSqlite3Dataset;
  idx:integer;
begin
  Result:=0;

  qry:=dmunit.DataModule1.CreateAndLockQuery(False,False);
  //
//  qry.SQL:='select *,''频点: '' || arfcn || '' 下行: '' || (downlink/1000000.0) || ''MHz 上行: '' || (uplink/1000000.0) || ''Mhz'' as ''info''   from BandList where (Band='+sysutils.QuotedStr(BandName)+') order by arfcn';
  qry.SQL:='select *,''频点: '' || arfcn || '' 下行: '' || (downlink/1000000.0) || ''MHz 上行: '' || (uplink/1000000.0) || ''Mhz'' as ''info''   from BandList where (Band='+sysutils.QuotedStr(BandName)+') order by arfcn';
//  qry.SQL.SaveToFile('/tmp/a.txt');

  qry.Open;
  lst.Clear;
  lst.BeginUpdate;;
  qry.First;
  idx:=-1;
  while not qry.EOF do
  begin
    lst.AddObject(qry.FieldByName('info').AsString,Tobject(qry.FieldByName('arfcn').AsInteger));
    if arfcn<>-1 then
    begin
      if qry.FieldByName('arfcn').AsInteger=arfcn then
      begin
        idx:=qry.RecNo-1;
      end;
    end;
    qry.Next;
  end;
  sysutils.FreeAndNil(qry);
  dmunit.DataModule1.UnLockCS(False);

  lst.EndUpdate;
  if arfcn<>-1 then
  begin
    Result:=idx;
  end;

end;

function TDataModule1.ConectDB:boolean;
var
  i:integer;
  s:String;
begin
  Result:=False;
  RandomUserDB;
    //     '/usr/lib/libxml10-dev.so';
    if not sysutils.FileExists(GetSysDBFile) then
    halt;
    if not sysutils.FileExists(GetUserDBFile) then
    exit;

    s:=GetSysDBFile();
    self.CS_SysDB.Enter;
    try
      self.qry_sys_imei.FileName:=GetSysDBFile;
      self.qry_sys_imei.Open;
    except
    end;
    self.CS_SysDB.Leave;

    self.CS_UsrDB.Enter;
    try
      self.qry_user_imei.FileName:=GetUserDBFile;
      self.qry_user_imei.Open;
    except
    end;
    self.CS_UsrDB.Leave;

    self.CS_UsrDB.Enter;
    try
      self.qry_history.FileName:=GetUserDBFile;
//      self.qry_user_imei.Open;
    except
    end;
    self.CS_UsrDB.Leave;

    self.CS_UsrDB.Enter;
    try
      self.qry_devinfo.FileName:=GetUserDBFile;
//      self.qry_user_imei.Open;
    except
    end;
    self.CS_UsrDB.Leave;

    self.CS_UsrDB.Enter;
    try
      qry_AutoSend_histimei.FileName:=GetUserDBFile;
    except
    end;
    self.CS_UsrDB.Leave;

  Result:=true;

  if not self.qry_user_imei.Active then
  Result:=false;
  if not self.qry_sys_imei.Active then
  Result:=false;

end;


const
  Flag_0=0;   //明文，不处理
  Flag_1=1;   //int;
  Flag_2=2;   //blod;


  //有问题，内存操作后，出问题
procedure TDataModule1.SetSysValue(const Key:AnsiString;const Value:AnsiString;AllowNewRow:Boolean;Flag:integer=1);
var
  qry:TSqlite3Dataset;
  DataType:DWORD;
  Code:DWORD;
  s:ansiString;
  CRC:DWORD;
  CRC_A:DWORD;

  v2:ansiString;

begin

  v2:='';
  s:='';
  DataType:=GetSysDBType(key);
  Code:=GetSysDBCode(key);

  qry:=TSqlite3Dataset.Create(self);
  qry.FileName:=GetSysDBFile;
  qry.SaveOnClose:=true;
  qry.SaveOnRefetch:=true;
  self.CS_SysDB.Enter;
  try

    qry.SQLList.Clear;

    qry.SQLList.Add('select * from sysinfo where');
    qry.SQLList.Add('(Type='+DWORD2Str(DataType,True,True)+')');
    qry.SQLList.Add(' and (Code='+DWORD2Str(Code,True,True)+')');

//    qry.SQLList.SaveToFile('/tmp/a.txt');
    qry.SQL:=qry.SQLList.Text;

    qry.Open;

    s:=Value;

    //DWORD=加密前的CRC+加密后的CRC
    CRC_A:=CRC16_Unit.CalcCRC16(s+GetCRCSalt(DataType));
    CRC_A:=CRC_A shl 16;
    if Flag<>0 then
    begin
//      v2:=Value;
      setlength(v2,length(value));
      move(value[1],v2[1],length(v2));
      XorEncode(@v2[1],length(v2),code);
      s:=Str2Hex(v2);
    end;
    CRC:=CRC16_Unit.CalcCRC16(s+GetCRCSalt(DataType));
    CRC:=CRC or CRC_A;

    if qry.RecordCount=0 then
    begin
      if AllowNewRow then
      begin
//        qry.Insert;
//        qry.FieldByName('Flag').AsInteger:=Flag;
//        qry.FieldByName('Code').AsInteger:=Code;
//        qry.FieldByName('Type').AsInteger:=DataType;
        qry.Active:=False;
        qry.SQLList.Clear;
        qry.SQLList.Add('Insert INTO SysInfo ([Flag],[Code],[Type],[Check],[Data]) Values (');
        qry.SQLList.Add(inttostr(Flag)+','+DWORD2Str(Code,True,True)+','+DWORD2Str(DataType,True,True)+','+DWORD2Str(CRC,True,True)+',');
        qry.SQLList.Add(sysutils.QuotedStr(s));
        qry.SQLList.Add(')');
//        qry.SQLList.SaveToFile('/tmp/sql.txt');
        qry.ExecSQLList;
      end
      else
      begin
        sysutils.FreeAndNil(qry);
        exit;
      end;
    end
    else
    begin
      //qry.Edit;
      //qry.FieldByName('Data').AsString:=s;
      //qry.FieldByName('Check').AsInteger:=CRC;
      //qry.Post;
      qry.Active:=False;
      qry.SQLList.Clear;
      qry.SQLList.Add('update SysInfo set ');
      qry.SQLList.Add('[Flag]='+inttostr(Flag)+',');
      qry.SQLList.Add('[Code]='+DWORD2Str(Code,True,True)+',');
      qry.SQLList.Add('[Type]='+DWORD2Str(DataType,True,True)+',');
      qry.SQLList.Add('[Check]='+DWORD2Str(CRC,True,True)+',');
      qry.SQLList.Add('[Data]='+sysutils.QuotedStr(s));
      qry.SQLList.Add(' where ');

      qry.SQLList.Add('(Type='+DWORD2Str(DataType,True,True)+')');
      qry.SQLList.Add(' and (Code='+DWORD2Str(Code,True,True)+')');

//      qry.SQLList.SaveToFile('/tmp/sql.txt');
      qry.ExecSQLList;

    end;

  except
  end;

  if qry<>nil then
  sysutils.FreeAndNil(qry);

  self.CS_SysDB.Leave;
end;

procedure TDataModule1.SaveDevinfo(di: TDeviceInfo;blReg:Boolean=False);
var
  qry:TSqlite3Dataset;
  s,s2:ansiString;
  strlst:TStringList;
  strlst2:TStringList;
  Where:TStringList;
  aIMEI,AIMSI,ATMSI,NewTemp:string;
  i,c:integer;

  procedure Add(name,val:string;strlst:TStringList);
  begin
    if val='' then
    exit;
    strlst.Add('('+Name+'='+sysutils.QuotedStr(Val)+')');
  end;

begin
  strlst:=nil;
  strlst2:=nil;
  Where:=nil;
  qry:=nil;
  aimei:='';
  aimsi:='';
  atmsi:='';

  if di=nil then
  exit;

  if (di.IMEI='') and (di.IMSI='') then
  exit;

  if not sysutils.FileExists(GetUserDBFile) then
  exit;

  strlst:=TStringList.Create;
  strlst2:=TStringList.Create;
  Where:=TStringList.Create;
  qry:=TSqlite3Dataset.Create(nil);
  qry.TableName:='devinfo';
  qry.PrimaryKey:='ID';
  qry.FileName:=GetUserDBFile;
  qry.SaveOnClose:=true;
//  qry.SaveOnRefetch:=true;
  if di.IMEI<>'' then
  aimei:=trim(ImeiTail(di.IMEI));

  aimsi:=trim(di.IMSI);

  Add('IMEI',di.IMEI,strlst2);
  Add('IMSI',di.IMSI,strlst2);

  c:=0;
  for i := 0 to strlst2.Count-1 do
  begin
    s:=trim(strlst2.Strings[i]);
    if s='' then
    system.Continue;

    if c=0 then
    where.Add(s)
    else
    where.Add(' and '+s);

    inc(c);
  end;
  strlst.Clear;
  strlst.Add('select * from devinfo where ('+where.Text+')');
  qry.SQL:=strlst.Text;
//  strlst.SaveToFile('/tmp/a.txt');

  self.CS_UsrDB.Enter;
  try
    while True do
    begin
      qry.Open;
      if qry.RecordCount>0 then
      system.Break;

      if aimei<>'' then
      begin
        qry.Close;
        qry.SQL:='select * from devinfo where (IMEI='+sysutils.QuotedStr(aimei)+')';
        qry.Open;
        if qry.RecordCount>0 then
        system.Break;
      end;

      if aimsi<>'' then
      begin
        qry.Close;
        qry.SQL:='select * from devinfo where (IMSI='+sysutils.QuotedStr(aimsi)+')';
        qry.Open;
        if qry.RecordCount>0 then
        system.Continue;
      end;
      system.Break;

    end;

    if qry.RecordCount=0 then
    begin
      qry.Append;
      qry.FieldByName('FindTime').AsDateTime:=now;
    end
    else
    begin
      qry.Edit;
      if qry.FieldByName('FindTime').IsNull then
      qry.FieldByName('FindTime').AsDateTime:=now;

    end;
    if aimei<>'' then
    qry.FieldByName('IMEI').AsString:=aimei;
    if aimsi<>'' then
    qry.FieldByName('IMSI').AsString:=aimsi;

    qry.FieldByName('Model').AsString:=di.Model;
    if di.modem_DB or di.modem_User then
    qry.FieldByName('Modem').AsInteger:=1
    else
    qry.FieldByName('Modem').AsInteger:=0;

    if blReg then
    begin
      qry.FieldByName('LastRegTime=').AsDateTime:=now;
    end;

    if di.TMSI<>'' then
    qry.FieldByName('TMSI').AsString:=di.TMSI;

    qry.FieldByName('LastTime').AsDateTime:=now;
    qry.Post;

    qry.ApplyUpdates;
    sysutils.FreeAndNil(qry);
    sysutils.FreeAndNil(strlst);
    sysutils.FreeAndNil(strlst2);
    sysutils.FreeAndNil(where);

  finally
    self.CS_UsrDB.Leave;
  end;



end;

procedure TDataModule1.SaveUserLog(const strlst:TStringList;Flag:integer=0);
var
  qry:TSqlite3Dataset;
  i:integer;
  s:AnsiString;
  t:AnsiString;
begin
  if strlst.Count=0 then
  exit;
  qry:=self.CreateAndLockQuery(True,True);
  qry.TableName:='UserLog';
  qry.PrimaryKey:='ID';
  qry.SQL:='open * from Userlog where ID=-1';
  qry.Open;
  for i := 0 to strlst.Count-1 do
  begin
    s:=trim(strlst.Strings[i]);
    if s='' then
    system.Continue;
    t:=sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss.zzz',now);
    qry.Append;
    qry.FieldByName('Time').AsString:=t;

    s:=XorEncode2HexStr(s,t);
    qry.FieldByName('CRC').AsInteger:=CRC16_Unit.CalcCRC16(T+s);
    qry.FieldByName('Log').AsString:=s;
    qry.FieldByName('Flag').AsInteger:=Flag;
    qry.Post;
  end;

  qry.ApplyUpdates;
  sysutils.FreeAndNil(qry);
  self.UnLockCS(true);

end;

function TDataModule1.GetSysValue(const Key:AnsiString):AnsiString;
var
  qry:TSqlite3Dataset;
  DataType:DWORD;
  Code:DWORD;
  s,s2:ansiString;
  CRC_db:DWORD;    //db
  CRC_DB_R:DWORD;  //->
  CRC_DB_L:DWORD;  //<-
  CRC:DWORD;  //calc_crc16

  Q:String;

begin
  Result:='';
  s:='';
  s2:='';
  Q:='';

  if not sysutils.FileExists(GetSysDBFile) then
  exit;

  DataType:=GetSysDBType(key);
  Code:=GetSysDBCode(key);

  qry:=self.CreateAndLockQuery(False,False);
  try

    qry.SQLList.Clear;
    qry.SQLList.Add('select * from sysinfo where');
    qry.SQLList.Add('([Type]='+DWORD2Str(DataType,True,True)+')');
    qry.SQLList.Add(' and ([Code]='+DWORD2Str(Code,True,True)+')');
    qry.SQL:=qry.SQLList.text;
//    qry.SQLList.SaveToFile('/tmp/a.txt');
    qry.SQLList.Clear;
    qry.Open;
    if qry.RecordCount>0 then
    begin
      s:=qry.FieldByName('Data').AsString;
      CRC:=CRC16_Unit.CalcCRC16(s+GetCRCSalt(DataType));

      s2:=Qry.FieldByName('Check').ASString;

      CRC_DB:=Str2DWORD(s2,true);

      CRC_DB_L:=CRC_DB shr 16;    //       加密前的CRC

      CRC_DB_R:=crc_DB and $0000FFFF;


      if CRC_DB_R=CRC then
      begin
        case qry.FieldByName('Flag').AsLongint of
          0:
            begin
//              if (CRC_DB_L=CRC) then
              Result:=s;
            end;
          1:
            begin
              s:=trim(s);
              if isHexStr(s) then
              begin
                s:=Hex2Str(s);
                XorDeCode(@s[1],length(s),Code);
                Result:=s;
              end;
            end;
        end;
        CRC:=CRC16_Unit.CalcCRC16(Result+GetCRCSalt(DataType));
        if CRC<>CRC_DB_L then
        begin
          Result:='';
        end;
      end;
    end
    else
    begin
      Result:='';
    end;

  except
  end;
  if qry<>nil then
  sysutils.FreeAndNil(qry);

  self.UnLockCS(False);


end;

function TDataModule1.GetValueDB(SQL:String;field:string;userdb:boolean):AnsiString;
var
  qry:TSqlite3Dataset;
begin
  Result:='';
  qry:=self.CreateAndLockQuery(UserDB,False);
    try
    qry.SQL:=SQL;
    qry.SQL:=SQL;
//    qry.SQL.SaveToFile('/tmp/a.sql');
    qry.Open;
    if qry.Fields.FindField(field)<>nil then
    begin
      Result:=qry.FieldByName(field).AsString;
    end;
  except
  end;
  if qry<>nil then
  sysutils.FreeAndNil(qry);

  self.UnLockCS(UserDB);


end;

procedure TDataModule1.LockCS(UserDB:Boolean);
begin
  if UserDb then
  self.CS_UsrDB.Enter
  else
  self.CS_UsrDB.Enter;
end;

procedure TDataModule1.UnLockCS(UserDB:Boolean);
begin
  if UserDb then
  self.CS_UsrDB.Leave
  else
  self.CS_UsrDB.Leave;
end;

function TDataModule1.ExecSQL(SQL:String;userdb:boolean):Boolean;
var
  qry:TSqlite3Dataset;
begin
  Result:=False;
  qry:=self.CreateAndLockQuery(userDB,True);
  try
    qry.SQL:=SQL;
    qry.ExecSQL;
    Result:=True;
  except
  end;
  if qry<>nil then
  sysutils.FreeAndNil(qry);

  self.UnLockCS(UserDB);

end;

function TDataModule1.ExecSQL(SQL: TStringList; userdb: boolean): Boolean;
var
  qry:TSqlite3Dataset;
begin
  Result:=False;
  qry:=self.CreateAndLockQuery(userDB,True);
  try
    qry.SQLList.Clear;
    qry.ExecSQL(sql);
    Result:=True;
  except
  end;
  if qry<>nil then
  sysutils.FreeAndNil(qry);

  self.UnLockCS(UserDB);
 end;

function TDataModule1.CreateAndLockQuery(UserDB:Boolean;Commit:Boolean=False): TSqlite3Dataset;
begin
  Result:=TSqlite3Dataset.Create(self);

  if userdb then
  begin
    Result.FileName:=GetUserDBFile;
  end
  else
  begin
    Result.FileName:=GetSysDBFile;
  end;
  if Commit then
  begin
    Result.SaveOnRefetch:=true;
    Result.SaveOnClose:=true;
  end;
  self.LockCS(UserDB);

end;

function TDataModule1.GetImeiInfo(aimei: string;aimsi:string): TDeviceInfo;
var
  qry:TSqlite3Dataset;
  imei:string;
  s:String;
  c:integer;
begin
  Result:=nil;
  aimei:=trim(aimei);
  aimsi:=trim(aimsi);

  if aimei='(null)' then
  exit;
  if aimsi='(null)' then
  exit;

  if aimei='' then
  exit;
  if length(aimei)<8 then
  exit;

  qry:=nil;

  Result:=TDeviceInfo.Create;;
  Result.IMEI:=aIMEI;
  Result.IMSI:=aimsi;
  Result.AllowReg:=False;

  imei:=copy(aimei,1,8);

  qry:=self.CreateAndLockQuery(False,False);
  try
    qry.SQL:='select * from imei where (tac='+sysutils.QuotedStr(imei) +')';
    qry.Open;
    if qry.RecordCount>0  then
    begin
      Result.modem_DB:=qry.FieldByName('Modem').AsBoolean;
      Result.Model:=qry.FieldByName('corp').AsString+' '+qry.FieldByName('model').AsString;
    end;
    sysutils.FreeAndNil(qry);

  finally
    self.UnLockCS(false);
  end;

  try
    qry:=self.CreateAndLockQuery(true,false);
    qry.SQL:='select * from imei_user where (tac='+sysutils.QuotedStr(imei) +')';
    qry.Open;
    if qry.RecordCount>0  then
    begin
      Result.modem_user:=qry.FieldByName('Modem').AsBoolean;
      Result.Model:=qry.FieldByName('model').AsString;
    end;
    sysutils.FreeAndNil(qry);

  finally
    self.UnLockCS(True);
  end;

  try
  qry:=self.CreateAndLockQuery(True,False);
  s:=sysutils.QuotedStr(copy(aimei,1,14));
  qry.SQL:='select * from imei_user where (substr(tac,1,14)='+s +')';
//  qry.SQLList.Add(qry.SQL);
//  qry.SQLList.SaveToFile('/tmp/aa.txt');
  qry.Open;
  if qry.RecordCount>0  then
  begin
    Result.modem_user:=qry.FieldByName('Modem').AsBoolean;
    Result.Model:=qry.FieldByName('model').AsString;
  end;

//  Result.AllowReg:=Result.modem_DB or result.modem_user;
  s:=copy(aimei,1,14);
  Result.Self:=SelfIMEIList.IndexOf(s)<>-1;
  sysutils.FreeAndNil(qry);
finally
  self.UnLockCS(True);
end;


end;

procedure TDataModule1.DeConectDB;
begin
  self.LockCS(True);
    self.qry_user_imei.Close;
    self.qry_devinfo.Close;
    self.qry_history.Close;
  self.UnLockCS(True);

  self.LockCS(False);
    self.qry_sys_imei.Close;
  self.UnLockCS(False);
end;

procedure TDataModule1.ApplyUpdates(D: TDataSet);
begin
  if (d is TSqlite3Dataset) or d.InheritsFrom(TSqlite3Dataset) then
  TSqlite3Dataset(d).ApplyUpdates;

end;

function TDataModule1.GetNewDataset(UserDB: Boolean;SQL:string): TSqlite3Dataset;
begin
  Result:=TSqlite3Dataset.Create(nil);
  if UserDB then
  Result.FileName:=GetUserDBFile
  else
  Result.FileName:=GetSysDBFile;

self.LockCS(UserDB);
try
  Result.SQL:=SQL;
  Result.Open;
finally
  self.UnLockCS(UserDB);
end;

end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
self.DeConectDB;
sysutils.FreeAndNil(self.CS_SysDB);
sysutils.FreeAndNil(self.CS_SysDB);
end;

procedure TDataModule1.qry_AutoSend_histimeiFindTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
  aText:=''
  else
  aText:=sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_AutoSend_histimeiIMEIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
   if sender.IsNull then
   aText:=''
   else
   aText:=Sender.AsString;

   if qry_AutoSend_histimei.FieldByName('Modem').AsInteger=1 then
   begin
     aText:=GetModemImeiShowStr(aText,True);
   end;
end;

procedure TDataModule1.qry_AutoSend_histimeiIMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=sender.AsString;
end;

procedure TDataModule1.qry_AutoSend_histimeiLastTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
   if Sender.IsNull then
   aText:=''
   else
   aText:=sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_AutoSend_histimeiModelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=sender.AsString;
end;

procedure TDataModule1.qry_AutoSend_histimeiTMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=sender.AsString;
end;

procedure TDataModule1.qry_devinfoFindTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
  aText:=''
  else
  aText:=sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_devinfoIMEIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin

   if sender.IsNull then
   aText:=''
   else
   aText:=Sender.AsString;

   if qry_devinfo.FieldByName('Modem').AsInteger=1 then
   begin
     aText:=GetModemImeiShowStr(aText,True);
   end;
end;

procedure TDataModule1.qry_devinfoIMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_devinfoLastRegTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin

   if Sender.IsNull then
   aText:=''
   else
   aText:=sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_devinfoLastTimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
   if Sender.IsNull then
   aText:=''
   else
   aText:=sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_devinfoModelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_devinfoTMSIGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_historyEncodeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_historyfromTelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_historyfrom_imeiGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  atext:=trim(sender.AsString);
  if atext<>'' then
  atext:='**'+copy(aText,7,maxint);
end;

procedure TDataModule1.qry_historyMEMOGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  atext:=sender.AsString;
end;

procedure TDataModule1.qry_historytimeGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  if sender.IsNull then
  aText:=''
  else
  aText:=sysutils.FormatDateTime('yy-MM-dd hh:nn:ss',Sender.AsDateTime);
end;

procedure TDataModule1.qry_historyto_imeiGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  atext:=trim(sender.AsString);
  if atext<>'' then
  atext:='**'+copy(aText,7,maxint);
end;

procedure TDataModule1.qry_sys_imeicorpGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
    aText:=Sender.AsString;
end;

procedure TDataModule1.qry_user_imeimodelGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.qry_user_imeitacGetText(Sender: TField; var aText: string; DisplayText: Boolean);
begin
  aText:=Sender.AsString;
end;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  sqlite3dyn.InitialiseSQLite;
  CS_SysDB:=TCriticalSection.Create;
  CS_UsrDB:=TCriticalSection.Create;
//  self.md_lv1.Open;
//  self.md_lv2.Open;
end;

end.

