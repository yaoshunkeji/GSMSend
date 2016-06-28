unit mainform_unit;

{$mode delphi}{$H+}


{$define m_tmp}

//http://baike.baidu.com/view/4332047.htm

interface

uses
  Classes, SysUtils, FileUtil, UTF8Process, DateTimePicker, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls,process, StdCtrls, DBGrids, Buttons, LResources, LCLType, PairSplitter, DbCtrls, Spin, ColorBox, Menus, EditBtn,
  CheckLst, Grids,syncobjs ,inifiles,dateutils,math,strutils,db, memds,sqlite3
  ,fununit,RegUnit,ServerComm_Unit,dmunit,CommFunUnit,StrGrid_Unit, SqliteUtils,base64;

type

  { TMainForm }

  TMainForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    DateTimePicker1: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBGrid_userdb: TDBGrid;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit22: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox12: TGroupBox;
    GroupBox13: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label5: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit10: TLabeledEdit;
    LabeledEdit11: TLabeledEdit;
    LabeledEdit12: TLabeledEdit;
    LabeledEdit13: TLabeledEdit;
    LabeledEdit14: TLabeledEdit;
    LabeledEdit15: TLabeledEdit;
    LabeledEdit16: TLabeledEdit;
    LabeledEdit17: TLabeledEdit;
    LabeledEdit18: TLabeledEdit;
    LabeledEdit19: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit20: TLabeledEdit;
    LabeledEdit21: TLabeledEdit;
    LabeledEdit22: TLabeledEdit;
    LabeledEdit23: TLabeledEdit;
    LabeledEdit24: TLabeledEdit;
    LabeledEdit25: TLabeledEdit;
    LabeledEdit26: TLabeledEdit;
    LabeledEdit27: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    LabeledEdit8: TLabeledEdit;
    LabeledEdit9: TLabeledEdit;
    ListView3: TListView;
    Memo1: TMemo;
    Memo10: TMemo;
    Memo11: TMemo;
    Memo12: TMemo;
    Memo13: TMemo;
    Memo14: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Memo7: TMemo;
    Memo8: TMemo;
    Memo9: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog_SQL: TOpenDialog;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    PageControl3: TPageControl;
    PageControl4: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    PopupMenu1: TPopupMenu;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    SaveDialog1: TSaveDialog;
    SaveDialog_SQL: TSaveDialog;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    SpinEdit9: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar2: TStatusBar;
    DBGrid_lv1: TStringGrid;
    DBGrid_lv2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet15: TTabSheet;
    TabSheet16: TTabSheet;
    TabSheet17: TTabSheet;
    TabSheet18: TTabSheet;
    TabSheet19: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    Timer_SEND: TTimer;
    Timer_ResetBTS: TTimer;
    chkOnlyModem: TToggleBox;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolBar4: TToolBar;
    ToolBar5: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure CheckBox20Click(Sender: TObject);
    procedure CheckBox22Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure chkOnlyModemChange(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DBGrid3CellClick(Column: TColumn);
    procedure DBGrid_lv1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure Edit3KeyPress(Sender: TObject; var Key: char);
    procedure Edit4Change(Sender: TObject);
    procedure Edit4Exit(Sender: TObject);
    procedure Edit4KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit6KeyPress(Sender: TObject; var Key: char);
    procedure Edit9KeyPress(Sender: TObject; var Key: char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupBox13Click(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
    procedure Memo2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuItem4Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl3Change(Sender: TObject);
    procedure PageControl4Change(Sender: TObject);
    procedure SpinEdit6Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer_ResetBTSTimer(Sender: TObject);
    procedure Timer_SENDTimer(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
    DeviceList:TThreadList;
    ShowCountry:Boolean;
    SMSblockList:TStringList;
    TelblockList:TStringList;

    MsgLock:TCriticalSection;
    ResetBTSTime:TDateTime;
    PlanSendTime:TDateTime;
    RepoStr_1_idx:integer;
    RepoStr_2_idx:integer;
    RepoStr_3_idx:integer;
    UserSendDev:TThreadList;
    UserSendSMS:TStringList;
    blAllowAllReg:Boolean;
    blNoKeyFilter:Boolean;
    blNoTelFilter:Boolean;

    SendDataHisory:TStringList;

    procedure Add_UserSendDev(di: TDeviceInfo);
    function CheckBlockSMS(sms: String; DestIMEI: string):String;
    function CheckBlockTel(Tel: String; DestIMEI: string):String;
    procedure ClearDataForBTSAbort_Start;
    procedure ClearQry(qry: TDataSet);
    procedure DelFromListView(di: TDeviceInfo; dbGrd:TStringGrid);
    procedure ExceptionEvent(Sender: TObject; E: Exception);
    procedure ExecutePlan(Force: Boolean=false);
    procedure Fill_ListView(di:TDeviceInfo;Grd:TStringGrid;Row:integer);
    function GetSelectDeviceInfoByDBGrid(DbGrd: TDBGRID): TDeviceInfo;
    function LargeInt2DeviceInfo(LargeInt: int64): TDeviceInfo;
//    function Same_DeviceInfo(LargeInt: int64; Dev: TDeviceInfo): Boolean;overload;
//    function Same_DeviceInfo(HexStr:String; Dev: TDeviceInfo): Boolean;overload;
    function FixTelStr(Str: string): string;
    function GetCharLen(all: Boolean): integer;
    function GetCharMode: integer;

    function GetDiByIdent(str: String;all:boolean=false): TDeviceInfo;
    function is_UserSendDev(di: TDeviceInfo): Boolean;
    procedure ListAllDevice(dbGrd:TStringGrid;onlyReg:Boolean;OnlyModem:Boolean=False);
    function OnRecvMsg_OnLog_Filter(s: string): boolean;
    procedure OnRecvMsg_OnLog_Replace(var s: string);

    procedure OnRecvMsg_RecvSms(var msg: TMSGData; strlst: TStringList);
    procedure OnRecvMsg_OnLog(var msg: TMSGData; strlst: TStringList);
    procedure OnRecvMsg_RecvSms_CMD(var msg: TMSGData; strlst: TStringList);
    function PosDeviceInfo(di: TDeviceInfo; qry: TDataSet;OnlyGet:Boolean=True): Boolean;
    procedure ReadConfig;
    procedure ReListDevice(di: TDeviceInfo);   //找到一个设备，增加或刷新
    procedure ReportToSelfIMEI(sender: string; sms: string);
    procedure SaveConfig(all:boolean=False);
    function FindDevice(IMEI: string; IMSI: String;TMSI:string):TDeviceInfo;
    procedure SaveSMS(fromTel,ToTel,to_imsi,to_imei,from_imei,from_imsi,sms:string;Encode:string;mode:integer);
    function SendSms(Sender:string;sms:String;di:TDeviceInfo;AutoSMS:Boolean=True):integer;   //0ok ,1 false, -1 error
    procedure SendSMS_SelfIMEI(Sender: String; di: TDeviceInfo; sms: String);   //转发到手机上

    procedure UpdataDevinfoDB(imei, model: string; modem: Boolean);
    procedure WriteLog(str: string);

  public


    function GetRePoStr(id:integer):String;

    function NewDevice(IMEI:string;IMSI:String;TMSI:string):TDeviceInfo;
    procedure UpdateUserSet(IMEI:String;Model:string;UserModem:Boolean);

    function FindTMSI(imei,imsi:string;OnlyOnline:Boolean):TDeviceInfo;
    procedure OnRecvMsg_OnRegister(var msg:TMSGData;strlst:TStringList);
    procedure OnRecvMsg(var msg:TMSGData;strlst:TStringList);

  end;

var
  MainForm: TMainForm;

  ReBootOrShutMode:Boolean=False;
  CreateOK:Boolean;

implementation

{$R *.lfm}

uses
  TestForm_unit,UserImeiSetForm_Unit,TCPServerUnit,pdu_unit,YateCFG_Unit,FindModemForm_Unit
  ,DataFile_Unit,AsyncUpdateThread_Unit,Process_Unit,FindDeviceForm_Unit,SetWiFiForm_Unit;

var
  YateProc:TProcess=nil;

{ TMainForm }

function GetImeiStr(di:TDeviceInfo;var s:String):string;
begin
  s:='';
  Result:='';
  if di<>nil then
  begin
    Result:=GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User);
    exit;
    Result:=di.IMEI;
    if di.modem_user or di.modem_DB then
    begin
      s:='短信猫';
      if length(Result)>=8 then
      begin
        Result[3]:='*';
        Result[4]:='*';
        Result[5]:='*';
        Result[7]:='*';
        Result[8]:='*';
      end;
    end;
  end;
  Result:=s;
end;

function TMainForm.PosDeviceInfo(di: TDeviceInfo; qry: TDataSet; OnlyGet: Boolean): Boolean;
var
  oldr:integer;
  d:DWORD;
begin
  Result:=False;
  if not qry.Active then
  exit;
  oldr:=qry.RecNo;
  qry.DisableControls;
  qry.First;
  while not qry.EOF do
  begin
    d:=qry.FieldByName('DeviceInfo').AsLargeInt;
    if d=0 then
    begin
      qry.Next;
      system.Continue;
    end;

    if TDeviceInfo(d)=di then
    begin
      Result:=True;
      system.Break;
    end;

    qry.Next;
  end;
  if OnlyGet or (not Result) then
  qry.RecNo:=oldR;

  qry.EnableControls;


end;

procedure TMainForm.ClearQry(qry:TDataSet);
begin
  qry.Close;
  qry.Active:=true;
  qry.First;
  while not qry.EOF do
  begin
    qry.Delete;
  end;


end;

procedure TMainForm.ListAllDevice(dbGrd:TStringGrid;onlyReg:Boolean;OnlyModem:Boolean=False);
var
  i:integer;
  lst:TList;
  di:TDeviceInfo;
  old:TDeviceInfo;
  R:integer;
begin
  di:=nil;
  old:=nil;

 lst:=self.DeviceList.LockList;

 if dbGrd.Row>0 then
 begin
   old:=dbgrd._GetValue_Pointer(dbgrd.Row,'DeviceInfo');
 end;
 dbgrd.BeginUpdate;
 dbgrd._Clear;

 for i := 0 to lst.Count-1 do
 begin
   di:=TDeviceInfo(lst.Items[i]);
   if onlyReg then
   begin
     if not di.isReg then
     system.Continue;
   end;
   if OnlyModem then
   begin
     if not (di.modem_DB or di.modem_User) then
     system.Continue;
   end;
   dbgrd.RowCount:=dbgrd.RowCount+1;
   R:=dbgrd.RowCount-1;
//   if R=0 then
//   beep;
   dbgrd.Rows[R].Clear;
   dbgrd._SetValue(R,'ID',inttostr(R));
   Fill_ListView(di,dbgrd,R);
 end;
 if old<>nil then
 begin
  dbGrd._Locate('DeviceInfo',old,True);
 end;
 dbgrd.EndUpdate();
 self.DeviceList.UnlockList;


end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
var
  i:integer;
  lst:TList;
  di:TDeviceInfo;

begin
  lst:=self.DeviceList.LockList;
  for i := lst.count-1 downto 0 do
  begin
    //已经入网的不清除
    di:=TDeviceInfo(lst.items[i]);

    if (Sender=ToolButton1) or (sender =MenuItem1) then
    begin
      if not di.isReg then
      begin
        lst.Delete(i);
        di.Free;
      end;
    end;
    if (sender=MenuItem2) then
    begin
      lst.Delete(i);
      di.Free;
    end;
  end;
//  lst.Clear;
  self.ListAllDevice(self.DBGrid_lv1,false);
  self.ListAllDevice(self.DBGrid_lv2,True);
  Memo14.Lines.Clear;
  self.Devicelist.unlocklist;

end;

function TMainForm.LargeInt2DeviceInfo(LargeInt:int64):TDeviceInfo;
var
  d:DWORD;
begin
 Result:=nil;
 if LargeInt=0 then
 exit;
 d:=LargeInt;

 Result:=TDeviceInfo(LargeInt);
end;

function TMainForm.GetSelectDeviceInfoByDBGrid(DbGrd:TDBGRID):TDeviceInfo;
begin
 Result:=nil;
 if not DBGrd.DataSource.DataSet.Active then
 exit;
 if dbGrd.DataSource.DataSet.RecNo=-1 then
 exit;
 Result:=LargeInt2DeviceInfo(dbgrd.DataSource.DataSet.FieldByName('DeviceInfo').AsLargeInt);

end;

procedure TMainForm.ToolButton2Click(Sender: TObject);
var
  di:TDeviceInfo;
begin
  //if dmunit.DataModule1.md_lv1.RecNo=-1 then
  //begin
  //  writeln('md_lv1.RecNo=-1');
  //  exit;
  //end;
  //di:=GetSelectDeviceInfoByDBGrid(self.DBGrid_lv1);

  di:=self.DBGrid_lv1._GetValue_Pointer(DBGrid_lv1.Row,'DeviceInfo');

  if di=nil then
  exit;

  di.AllowReg:=true;
  di.Kick:=False;
  self.ReListDevice(di);
  //考虑是否通知服务器。马上同意,假设客户端在等待，但通常的只有几秒，意义不大

end;

procedure TMainForm.ToolButton3Click(Sender: TObject);
var
  di:TDeviceInfo;
begin
  di:=self.DBGrid_lv1._GetValue_Pointer(DBGrid_lv1.Row,'DeviceInfo');
  if di=nil then
  exit;

  di.AllowReg:=False;
  di.Kick:=True;
  Send_Tick(di.IMEI,di.IMSI,di.TMSI);
  ReListDevice(di);
end;

procedure TMainForm.ToolButton4Click(Sender: TObject);
var
  lst:TList;
  b:Boolean;
  di:TDeviceInfo;

  frm:TUserImeiSetForm;
  strlst:TStringList;
begin

  di:=self.DBGrid_lv1._GetValue_Pointer(DBGrid_lv1.Row,'DeviceInfo');
  b:=True;
  strlst:=nil;

  lst:=DeviceList.LockList;
  if lst.IndexOf(di)=-1 then
  b:=False;
  DeviceList.UnlockList;
  if not b then
  exit;

  if di.IMEI='' then
  exit;

  frm:=TUserImeiSetForm.Create(self);
  frm.CheckBox1.Checked:=di.modem_DB or di.modem_user;
  frm.Edit1.Text:=ImeiTail(di.IMEI);
  frm.Edit2.Text:=di.Model;

  if frm.ShowModal=mrok then
  begin
    di.modem_user:=frm.CheckBox1.Checked;
    strlst:=TStringList.Create;
    strlst.Add('INSERT OR REPLACE INTO imei_user(tac,model,Modem) VALUES(');
    strlst.Add(sysutils.QuotedStr(frm.Edit1.Text)+','+sysutils.QuotedStr(frm.Edit2.Text));
    if frm.CheckBox1.Checked then
    strlst.Add(',1)')
    else
    strlst.Add(',0)');
    dmunit.DataModule1.ExecSQL(strlst.Text,true);
    BitBtn8Click(nil);
  end
  else
  begin

  end;
  sysutils.FreeAndNil(frm);


end;

procedure TMainForm.ToolButton5Click(Sender: TObject);
var
  frm:TFindModemForm;
  strlst,strlst2:TStringList;
  i:integer;
  s:string;
  itm:TListItem;
  qry:TDataSet;

  function likeStr(field:String;val:string):string;
  begin
    Result:='('+field+' like '+sysutils.QuotedStr('%'+val+'%')+')';
  end;

  function likeStr2(field1,field2:string;val:string):string;
  begin
    Result:='('+likeStr(field1,val)+') or ('+ likeStr(field2,val)+')';
  end;
begin
  frm:=TFindModemForm.Create(self);
  if frm.ShowModal=mrok then
  begin
    dmunit.DataModule1.qry_AutoSend_histimei.Close;

    frm.LabeledEdit4.Text:=trim(frm.LabeledEdit4.Text);
    frm.LabeledEdit8.Text:=trim(frm.LabeledEdit8.Text);
    frm.LabeledEdit9.Text:=trim(frm.LabeledEdit9.Text);

    strlst:=TStringList.Create;
    strlst2:=TStringList.Create;
    if frm.LabeledEdit4.Text<>'' then
    begin
      strlst.Add(likeStr('IMEI',frm.LabeledEdit4.Text));
    end;
    if LabeledEdit8.Text<>'' then
    begin
      strlst.Add(likeStr('IMSI',frm.LabeledEdit8.Text));
    end;
    if LabeledEdit9.Text<>'' then
    begin
      strlst.Add(likeStr('Model',frm.LabeledEdit9.Text));
    end;
    if frm.CheckBox9.Checked then
    begin
      strlst.Add('(Modem=1)');
    end;
    if frm.RadioButton7.Checked then
    begin
//      s:=sysutils.FormatDateTime('yyyy-MM-dd',now-7);
//      strlst.Add('(LastTime>='+sysutils.QuotedStr(s) +')');
            s:=sysutils.FloatToStr(now-7);
            strlst.Add('(LastTime>='+s +')');
    end;
    if frm.RadioButton8.Checked then
    begin
//      s:=sysutils.FormatDateTime('yyyy-MM-dd',now-31);
//      strlst.Add('(LastTime>='+sysutils.QuotedStr(s) +')');
      s:=sysutils.FloatToStr(now-31);
      strlst.Add('(LastTime>='+s +')');
    end;

    for i := 0 to strlst.Count-1 do
    begin
      if strlst2.Count=0 then
      strlst2.Add(strlst.Strings[i])
      else
      strlst2.Add(' and '+ strlst.Strings[i]);
    end;

    strlst.Clear;

    strlst.Add('select * from devinfo ');
    if strlst2.Count>0 then
    strlst.Add(' where '+strlst2.Text);

    strlst.Add(' order by LastTime Desc');

//    strlst.SaveToFile('/tmp/a.txt');

    dmunit.DataModule1.LockCS(true);
    dmunit.DataModule1.qry_AutoSend_histimei.DisableControls;
    try
      dmunit.DataModule1.qry_AutoSend_histimei.Close;
      dmunit.DataModule1.qry_AutoSend_histimei.SQL:=strlst.Text;
      dmunit.DataModule1.qry_AutoSend_histimei.Open;
      qry:=dmunit.DataModule1.qry_AutoSend_histimei;

      ListView3.BeginUpdate;
      ListView3.Items.Clear;
      while not qry.EOF do
      begin
        itm:=ListView3.Items.Add;
        itm.SubItems.Add(sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',qry.FieldByName('LastTime').AsDateTime));
        if qry.FieldByName('Modem').AsBoolean then
        itm.SubItems.Add('是')
        else
        itm.SubItems.Add('');

        itm.SubItems.Add(qry.FieldByName('Model').AsString);
        s:=GetModemImeiShowStr(qry.FieldByName('IMEI').AsString,qry.FieldByName('Modem').AsBoolean,False);
        itm.SubItems.Add(s);
        itm.SubItems.Add(qry.FieldByName('IMSI').AsString);


        itm.SubItems.Add(sysutils.FormatDateTime('yy-MM-dd HH:nn:ss',qry.FieldByName('FindTime').AsDateTime));
        itm.SubItems.Add(qry.FieldByName('TMSI').AsString);

        qry.Next;

      end;

      ListView3.EndUpdate;

    finally
      dmunit.DataModule1.UnLockCS(true);
      dmunit.DataModule1.qry_AutoSend_histimei.EnableControls;
    end;

end;
  if strlst<>nil then
  sysutils.FreeAndNil(strlst);
  sysutils.FreeAndNil(frm);

end;

procedure TMainForm.ToolButton6Click(Sender: TObject);
begin
  Memo7.Lines.BeginUpdate;
  Memo7.Lines.Clear;
  Memo7.Lines.EndUpdate;
end;

procedure TMainForm.ToolButton7Click(Sender: TObject);
var
  i:integer;
  sel:integer;
begin
  sel:=ListView3.ItemIndex;

  ListView3.BeginUpdate;

  for i := 0 to ListView3.Items.Count-1 do
  begin
    ListView3.Items.Item[i].Checked:=True;
  end;
  ListView3.ItemIndex:=sel;
  ListView3.Repaint;
  ListView3.EndUpdate;

end;

procedure TMainForm.ToolButton8Click(Sender: TObject);
var
  i,sel:integer;
begin
  sel:=ListView3.ItemIndex;

  ListView3.BeginUpdate;

  for i := 0 to ListView3.Items.Count-1 do
  begin
    ListView3.Items.Item[i].Checked:=not ListView3.Items.Item[i].Checked;
  end;
  ListView3.ItemIndex:=sel;
  ListView3.Repaint;
  ListView3.EndUpdate;
end;

procedure TMainForm.ToolButton9Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  Memo7.Lines.SaveToFile(SaveDialog1.FileName);
end;
{
function TMainForm.Same_DeviceInfo(LargeInt:int64;Dev:TDeviceInfo):Boolean;
var
  buf:TDeviceInfo;
begin
  Result:=False;
  if LargeInt=0 then
  exit;

  buf:=TDeviceInfo(LargeInt);
  if buf=dev then
  Result:=True;

end;

function TMainForm.Same_DeviceInfo(HexStr: String; Dev: TDeviceInfo): Boolean;
begin
  Result:=False;
  if HexStr='' then
  exit;
  if sysutils.StrToInt64(HexStr)=DWORD(Dev) then
  Result:=True;
end;
}
procedure TMainForm.Fill_ListView(di:TDeviceInfo;Grd:TStringGrid;Row:integer);
var
  s:String;
begin
//  itm:=listview1.Items.Add;
  if di=nil then
  exit;
//  if Row=0 then
//  beep;

//  if not Same_DeviceInfo(Grd._GetValue(row,'DeviceInfo'),di) then
  if Grd._GetValue_Pointer(row,'DeviceInfo')<>di then
  Grd._SetValue(Row,'DeviceInfo',di);

  Grd._SetValue(row,'Model',di.Model);
  Grd._SetValue(row,'IMEI',GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User));

  Grd._SetValue(row,'IMSI',di.IMSI);
  Grd._SetValue(row,'LastTime',Time2Str(now-di.LastTime));
  Grd._SetValue(row,'Count',inttostr(di.Count));
  Grd._SetValue(row,'Tel',inttostr(di.CallList.Count));

  if Grd=self.DBGrid_lv1 then
  begin

    s:='';
    if di.isReg then
    s:='是';

    if di.Kick then
    begin
      if s='' then
      s:='禁'
      else
      s:=s+'/禁';
    end;
    if di.AllowReg then
    begin
      if s='' then
      s:='允'
      else
      s:=s+'/允';
    end;
    Grd._SetValue(row,'Reg',s);
  end;
  if Grd=self.DBGrid_lv2 then
  begin
    Grd._SetValue(row,'TMSI',di.TMSI);
  end;

end;

function TMainForm.FindDevice(IMEI: string; IMSI: String;TMSI:string):TDeviceInfo;
var
  lst:TList;
  b:Boolean;
  di:TDeviceInfo;
  itm:TListItem;
  s:string;
  i:integer;
begin
  Result:=nil;
  di:=nil;
  if (imei='(null)') then
  imei:='';
  if (imsi='(null)') then
  imsi:='';
  if (tmsi='(null)') then
  tmsi:='';

  if (imei='') and (imsi='') and (tmsi='') then
  exit;

  lst:=self.DeviceList.LockList;
  for i := 0 to lst.Count-1 do
  begin
    di:=TDeviceInfo(lst.Items[i]);
    try
    if imei<>'' then
    begin
      if copy(di.IMEI,1,14)=copy(IMEI,1,14) then
      begin
        Result:=di;
        system.Break;
      end;
    end;
    except
    end;
    try
    if imsi<>'' then
    begin
      if imsi=di.IMSI then
      begin
        Result:=di;
        system.Break;
      end;
    end;
    except
    end;
    try
    if tmsi<>'' then
    begin
      if tmsi=di.TMSI then
      begin
        Result:=di;
        system.Break;
      end;
    end;

    except
    end;
  end;
  self.DeviceList.UnlockList;
  if Result<>nil then
  begin
    if imei<>'' then
    Result.IMEI:=imei;
    if imsi<>'' then
    Result.IMSI:=imsi;
    if TMSI<>'' then
    Result.TMSI:=tmsi;
  end;

end;

function TMainForm.NewDevice(IMEI: string; IMSI: String;TMSI:string):TDeviceInfo;
var
  lst:TList;
  old:Boolean;
  di:TDeviceInfo;
  itm:TListItem;
  s:string;
  i:integer;

begin
  Result:=nil;
  di:=nil;
  lst:=nil;
  old:=False;
  imei:=trim(imei);
  imsi:=trim(imsi);
  TMSI:=trim(TMSI);
  i:=0;

  if (imei='(null)') then
  imei:='';
  if (imsi='(null)') then
  imsi:='';
  if (tmsi='(null)') then
  tmsi:='';

  if (imei='') and (imsi='') and (tmsi='') then
  exit;

  di:=FindDevice(imei,imsi,tmsi);
  Result:=di;

   if di=nil then
   begin
     old:=False;

     if (imei='') and (imsi='') then
     exit;
     di:=dmunit.DataModule1.GetImeiInfo(imei,imsi);
     if di=nil then
     exit;
     if tmsi<>'' then
     di.TMSI:=tmsi;

     di.LastTime:=now;
//     if di.modem_user or di.modem_DB then
//     di.AllowReg:=CheckBox3.Checked;
     di.isReg:=False;
     lst:=self.DeviceList.LockList;
     if lst.IndexOf(di)=-1 then
     lst.Add(di);
     self.DeviceList.UnlockList;
     Result:=di;
   end
   else
   begin
     old:=true;
     if imei<>'' then
     di.IMEI:=imei;
     if imsi<>'' then
     di.IMSI:=imsi;
     if TMSI<>'' then
     di.TMSI:=tmsi;
   end;


end;

procedure TMainForm.ReListDevice(di:TDeviceInfo);
var
  zz:Boolean;
  R:integer;
  i:integer;
  c:integer;
  skip:Boolean;
begin
  if di=nil then
  exit;

  self.DBGrid_lv1.BeginUpdate;
  self.DBGrid_lv2.BeginUpdate;

  zz:=false;
  skip:=false;

  R:=self.DBGrid_lv1._Locate('DeviceInfo',di,False);
  if R=-1 then
  begin
    self.DBGrid_lv1.RowCount:=self.DBGrid_lv1.RowCount+1;
    R:=self.DBGrid_lv1.RowCount-1;
    self.DBGrid_lv1._SetValue(R,'ID',R);
  end
  else
  begin
//    R:=R+1;
  end;

  Fill_ListView(di,self.DBGrid_lv1,R);

  if not di.isReg then
  skip:=true;

  if self.chkOnlyModem.Checked then
  begin
    if not (di.modem_User or di.modem_DB) then
    skip:=true;
  end;

  if not skip then
  begin
    R:=self.DBGrid_lv2._Locate('DeviceInfo',di,False);
    if R=-1 then
    begin
      self.DBGrid_lv2.RowCount:=self.DBGrid_lv2.RowCount+1;
      R:=self.DBGrid_lv2.RowCount-1;
      self.DBGrid_lv2._SetValue(R,'ID',R);
    end;
    Fill_ListView(di,self.DBGrid_lv2,R);
  end
  else
  begin
    R:=self.DBGrid_lv2._Locate('DeviceInfo',di,False);
    if R<>-1 then
    begin
      if R=self.DBGrid_lv2.Row then
      begin
        if self.DBGrid_lv2.Row>(R-1) then
        self.DBGrid_lv2.Row:=R-1;
      end;
      self.DBGrid_lv2.DeleteRow(R);
      c:=self.DBGrid_lv2._ColByName('ID');
      for i := 1 to self.DBGrid_lv2.RowCount-1 do
      begin
        if c<>-1 then
        self.DBGrid_lv2.Cells[c,i]:=inttostr(i);

      end;

    end;

  end;
  self.DBGrid_lv2.EndUpdate();
  self.DBGrid_lv1.EndUpdate();

end;

procedure TMainForm.DelFromListView(di:TDeviceInfo;dbGrd:TStringGrid);
var
  i:integer;
  r:integer;
begin
  if di=nil then
  exit;
  dbGrd.BeginUpdate;
  dbGrd._DelRow('DeviceInfo',di);
  dbGrd.EndUpdate();
end;

procedure FillBaseInfo(di:TDeviceInfo;strlst:TStringList;tel:Boolean=true);
var
  i:integer;
  s:string;
  function Val(name:String):String;
  begin
    Result:=strlst.Values[name];
    Result:=trim(Result);
  end;

begin
  if di=nil then
  exit;
  if strlst=nil then
  exit;
  for i := strlst.Count-1 downto 0 do
  begin
    s:=strlst.ValueFromIndex[i];
    if s='(null)' then
    strlst.Delete(i);
  end;
  if tel then
  begin
    if Val('tel')<>'' then
    di.Tel:=Val('tel');
  end;

    if Val('TMSI')<>'' then
    di.TMSI:=Val('TMSI');

    if Val('IMSI')<>'' then
    di.IMSI:=Val('IMSI');
    if Val('IMEI')<>'' then
    di.IMEI:=Val('IMEI');

end;

function TMainForm.FindTMSI(imei,imsi:string;OnlyOnline:Boolean):TDeviceInfo;
var
  i:integer;
  lst:TList;
  di:TDeviceInfo;
begin
  Result:=nil;
  imei:=trim(imei);
  imsi:=trim(imsi);

  if (imei='(null)') then
  imei:='';
  if (imsi='(null)') then
  imsi:='';

  if (imei='') and (imsi='') then
  exit;

  lst:=self.DeviceList.LockList;
  for i := 0 to lst.Count-1 do
  begin
    di:=TDeviceInfo(lst.Items[i]);
    if OnlyOnline then
    begin
      if not di.isReg then
      system.Continue;
    end;


    if (imei<>'') then
    begin
      if SameText_N(di.IMEI,imei,14,True) then
      begin
        if di.TMSI<>'' then
        begin
          Result:=di;
          system.Break;
        end;
      end;
    end;

    if imsi<>'' then
    begin
      if di.IMSI=IMSI then
      begin
        if di.TMSI<>'' then
        begin
          result:=di;
          system.Break;
        end;
      end;
    end;

  end;
  self.DeviceList.UnlockList;


end;

function GetTimeDiffStr(t1,t2:TDateTime;eng:boolean=False):string;
var
  m,s,t:integer;
begin
  Result:='';
  t:=round((t1-t2)/dateutils.OneSecond);
  t:=abs(t);
  s:=trunc(abs(t1-t2)/dateutils.OneSecond);
  m:=trunc(abs(t1-t2)/dateutils.OneMinute);


  if abs(t)<60 then
  begin
    if eng then
    Result:=inttostr(t)+'s'
    else
    Result:=inttostr(t)+'秒前';
    exit;
  end;

  if abs(t)<3600 then
  begin
    if eng then
    Result:=inttostr(m)+'min'
    else
    Result:=inttostr(m)+'分前';
    exit;
  end;
  if eng then
  Result:=sysutils.FormatDateTime('HH:nn',abs(t1-t2))
  else
  Result:=sysutils.FormatDateTime('H时n分',abs(t1-t2));

end;

procedure TMainForm.OnRecvMsg_OnRegister(var msg:TMSGData;strlst:TStringList);
var
  s:String;
  di,di2:TDeviceInfo;
  s2:string;
  strlst2:TStringList;
  i:integer;
  w:WideString;
  aimei,atmsi,aimsi,TMSI2:string;
  tel:string;
  lst:TList;
  c:integer;
  Sended:TList;
begin
  aimei:=strlst.Values['IMEI'];
  atmsi:=strlst.Values['TMSI'];
  aimsi:=strlst.Values['IMSI'];
  tel:=strlst.Values['Tel'];
  if (aimei='(null)') then
  aimei:='';
  if (aimsi='(null)') then
  aimsi:='';
  if (atmsi='(null)') then
  atmsi:='';

  di:=self.NewDevice(aimei,aimsi,atmsi);
  if di=nil then
  exit;

  if ATmsi='' then
  exit;

  di.TMSI:=ATmsi;

  aimei:=di.IMEI;
  aimsi:=di.IMSI;
  atmsi:=di.TMSI;

  di.AddHistoryLog('入网成功');

  Sended:=TList.Create;
  if di<>nil then
  begin
    di.isReg:=true;
    di.RegTime:=now;
    if Tel<>'' then
    di.Tel:=Tel;

    FillBaseInfo(di,strlst);
    di.LastTime:=now;
    ReListDevice(di);

    if CheckBox8.Checked and (not self.blAllowAllReg) then
    begin
      if not di.Kick then
      begin
        s:='Reg,Idx:'+inttostr(self.DBGrid_lv2.RowCount);
        if di.modem_DB or di.modem_User then
        begin
//          s:=s+',猫'
        end
        else
        if di.AllowReg then
        begin
          s:=s+',Manual'
        end;
        s:=s+sysutils.Format(',TMSI:%s,IMEI:%s,IMSI:%s,Model:%s',[atmsi,GetModemImeiShowStr(aimei,di.modem_DB or di.modem_User,True),aimsi,di.Model]);

        for i := 0 to fununit.SelfIMEIList.Count-1 do
        begin
          s2:=trim(FunUnit.SelfIMEIList.Strings[i]);
          if s2='' then
          system.Continue;
          di2:=FindTMSI(s2,'',true);
          if di2<>nil then
          begin
           // SendSms('000',s,di);
            if di2<>di then
            begin
              //Send_Msg(di2.IMEI,di2.IMSI,di2.TMSI,'0000','0000',s,8,10000,'');
              self.SendSms('000',s,di2,True);
              Sended.Add(di2);
            end;
          end;
        end;

      end;    //not send to TMEI1,IMEI2

      if (aimei<>'') and (di.TMSI<>'') and isFreeIMEI(aimei) then
      begin
        c:=1;
        lst:=self.DeviceList.LockList;
        for i := 0 to lst.Count-1 do
        begin
          di2:=TDeviceInfo(lst.Items[i]);
          if Sended.IndexOf(di2)<>-1 then
          system.Continue;

          Sended.Add(di2);

          if not di2.isReg then
          system.Continue;
          if di2.Kick then
          system.Continue;

          if di2=di then
          system.Continue;

          s:=inttostr(c)+'/'+inttostr(lst.Count)+'. ';
          inc(c);
          s:=s+GetTimeDiffStr(now,di2.RegTime);
          s:=s+'已入';
          if di.modem_DB or di.modem_User then
          begin
            s:=s+',猫'
          end
          else
          if di.AllowReg then
          begin
            s:=s+',手动'
          end;
          aimsi:=di2.IMSI;
          atmsi:=di2.TMSI;
          aimei:=di2.IMEI;
          s:=s+sysutils.Format(',IMEI:%s,IMSI:%s,TMSI%s,Model:%s',[GetModemImeiShowStr(aimei,di.modem_User or di.modem_DB,False),aimsi,atmsi,di.Model]);
          Send_Msg(di.IMEI,di.IMSI,di.TMSI,'0000','0000',s,8,10000,'');

        end;
        self.DeviceList.UnlockList;

      end;    //imei1/2 online,send old device

    end;      //if send imei1/2 checkbox

  end;
  if di<>nil then
  dmunit.DataModule1.SaveDevinfo(di,true);
  if Sended<>nil then
  sysutils.FreeAndNil(Sended);

  if RadioButton11.Checked and CheckBox10.Checked then
  begin

  end;

end;

function TMainForm.FixTelStr(Str:string):string;
var
  i:integer;
begin
  str:=trim(str);
  if str='' then
  str:='0';
  for i := 1 to length(str) do
  begin
    if i=1 then
    begin
      if not (str[1] in ['0'..'9','+']) then
      begin
        Result:='0';
        exit;
      end;
    end
    else
    begin
      if not (str[i] in ['0'..'9']) then
      begin
        Result:='0';
        exit;
      end;
    end;
  end;
Result:=str;

end;

function TMainForm.GetDiByIdent(str:String;all:boolean=false):TDeviceInfo;
var
  i:integer;
  lst:TList;
  idx:integer;
  s2:string;
  di:TDeviceInfo;
  tmsi,imsi,imei:string;
begin
  Result:=nil;
  tmsi:='';
  imsi:='';
  imei:='';
  str:=sysutils.UpperCase(str);
  lst:=self.DeviceList.LockList;
  if (pos('TMSI',str)=1) or (pos('IMSI',str)=1) or (pos('IMEI',str)=1) then
  begin
    if (pos('TMSI',str)=1) then
    tmsi:=copy(str,4,maxint);
    if (pos('IMSI',str)=1) then
    imsi:=copy(str,4,maxint);
    if (pos('IMEI',str)=1) then
    imei:=copy(str,4,maxint);

    for i := 0 to lst.Count-1 do
    begin
      di:=TDeviceInfo(lst.Items[i]);
      if tmsi<>'' then
      begin
        if sysutils.SameText(di.TMSI,tmsi) then
        begin
          result:=di;
          system.Break;
        end;
      end;

      if imsi<>'' then
      begin
        if sysutils.SameText(di.IMSI,imsi) then
        begin
          result:=di;
          system.Break;
        end;
      end;

      if imei<>'' then
      begin
        if copy(di.IMEI,1,14)=copy(imei,1,14) then
        begin
          result:=di;
          system.Break;
        end;
      end;

    end;
  end
  else
  begin
    idx:=-1;
    if not sysutils.TryStrToInt(str,idx) then
    begin
      idx:=-1;
    end;
    if all then
    begin
      if (idx>0) and (idx<=lst.Count) then
      begin
        di:=lst.Items[idx-1];
      end;
    end
    else
    begin
      if (idx>0) and (idx<=self.DBGrid_lv2.RowCount) then
      begin
        di:=self.DBGrid_lv2._GetValue_Pointer(Idx,'DeviceInfo');
      end;
    end;
    if di<>nil then
    begin
      if lst.IndexOf(di)<>-1 then
      result:=di;
    end;
  end;
  self.DeviceList.UnlockList;

end;

function GetDeviceInfoForSMS(di:TDeviceInfo;lst:TList;idx:integer;AppIdxStr:string;eng:Boolean=True):String;
var
  s:String;
begin
  Result:='';
  if AppIdxStr<>'' then
  begin
    if eng then
    s:=format('All:%d/%d,Online:%s, Model:%s, ',[idx+1,lst.Count,AppIdxStr,di.Model])
    else
    s:=format('全部%d/%d,在线%s,型号:%s,',[idx+1,lst.Count,AppIdxStr,di.Model])
  end
  else
  begin
    if eng then
    s:=format('%d/%d, Model:%s, ',[idx,lst.Count,di.Model])
    else
    s:=format('%d/%d,型号:%s,',[idx,lst.Count,di.Model]);
  end;
  if eng then
  s:=s+GetTimeDiffStr(now,di.RegTime,true)+' '
  else
  s:=s+GetTimeDiffStr(now,di.RegTime,false)+'前已入';

  if di.modem_DB or di.modem_User then
  begin
    if eng then
    s:=s+',Modem'
    else
    s:=s+',猫'

  end
  else
  if di.AllowReg then
  begin
    if eng then
    s:=s+',Manual'
    else
    s:=s+',手动';
  end;
  s:=s+sysutils.Format(',TMSI:%s,IMEI:%s,IMSI:%s',[di.TMSI,GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User,true),di.IMSI]);
  Result:=s;
end;

procedure TMainForm.ReportToSelfIMEI(sender:string;sms:string);
var
  i:integer;
  di:TDeviceInfo;
  s:String;
begin
  sender:=trim(sender);
  for i := 0 to SelfIMEIList.Count-1 do
  begin
    s:=trim(SelfIMEIList.Strings[i]);
    if s='' then
    system.Continue;

    di:=self.GetDiByIdent('IMSI'+s);
    if di=nil then
    system.Continue;

    if not di.isReg then
    system.Continue;

    self.SendSms(sender,sms,di,true);

  end;
end;

procedure TMainForm.ExecutePlan(Force:Boolean);
var
  s:string;
  lst:TList;
  i:integer;
  di,di2:TDeviceInfo;
  space:TDateTime;
  sms:string;
  d:integer;
begin
  i:=0;
  if Memo11.Lines.Count=0 then
  exit;

  Space:=SpinEdit3.Value*dateutils.OneMinute;

  lst:=self.DeviceList.LockList;
  for i := 0 to lst.Count-1 do
  begin
    di:=TDeviceInfo(lst.Items[i]);
    if ((now-di.LastSend)>=Space) or Force then
    begin
      if GetHWCount<=0 then
      system.Break;
      if RadioButton13.Checked then
      begin
        di.TextIndex:=di.TextIndex+1;
        if memo1.Lines.Count>=di.TextIndex then
        begin
          di.TextIndex:=0;
        end;
        if memo1.Lines.Count>=di.TextIndex then
        begin
          system.Continue;
        end;

        sms:=Memo11.Lines.Strings[di.TextIndex]
      end
      else
      begin
        system.Randomize;
        d:=round((system.Random*1000000));
        d:=(d mod Memo11.Lines.Count);
        sms:=Memo11.Lines.Strings[d];
      end;

        D:=self.SendSms(LabeledEdit26.Text,sms,di,true);
      if (D=0) then
      begin
        DecHwCount();
        if self.CheckBox11.Checked then
        begin
          sms:=self.GetRePoStr(1);
          ReportToSelfIMEI(trim(edit19.Text),sms);
        end;
      end;
      if d=-1 then
      begin
        DecHwCount();
        DecHwCount();
      end;
    end;
  end;
  self.DeviceList.UnlockList;


end;

procedure TMainForm.OnRecvMsg_RecvSms_CMD(var msg:TMSGData;strlst:TStringList);
var
  s:String;
  i,j,p,c:integer;
  di,di2:TDeviceInfo;
  str,s2,s3,AllText,OrgText:string;
  w:WideString;
  aimei,atmsi,aimsi:string;
  tel,toTel:String;
  lst:TList;
  Dest,DestTel:string;
  strlst2:TStringList;
  R:integer;
  b:boolean;
begin
  strlst2:=nil;
  R:=0;
  di:=nil;
  di2:=nil;

  di:=nil;
//  s3:='';
  LabeledEdit15.Text:=FixTelStr(LabeledEdit15.Text);
  toTel:=FixTelStr(LabeledEdit15.Text);

  aimei:=strlst.Values['IMEI'];
  atmsi:=strlst.Values['TMSI'];
  aimsi:=strlst.Values['IMSI'];
  tel:=trim(strlst.Values['Tel']);   //srctel
  if (aimei='(null)') then
  aimei:='';
  if (aimsi='(null)') then
  aimsi:='';
  if (atmsi='(null)') then
  atmsi:='';

  di:=FindDevice(aimei,aimsi,atmsi);
  if di=nil then
  exit;

  if not fununit.isFreeIMEI(di.IMEI) then
  begin
    exit;
  end;
  if not sysutils.SameText(sysutils.Trim(LabeledEdit27.Text),tel) then
  exit;

  AllText:=strlst.Values['TEXT'];
  if trim(AllText)='' then
  exit;
  OrgText:=AllText;
  AllText:=trim(AllText);
  if strlst.Count=0 then
  exit;
  i:=0;
  s3:=AllText;
  strlst2:=TStringList.Create;
  try
  strlst2.DelimitedText:=AllText;
  str:=trim(strlst2.Strings[0]);

  if AllText=trim(LabeledEdit10.Text) then
  begin
    self.SendSms(LabeledEdit15.Text,inttostr(fununit.GetHWCount)+'次',di);
    exit;
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit12.Text)) then       //closeBTS
  begin
    if CheckBox2.Checked then
    self.SendSms(toTel,GetRePoStr(3),di);
    sleep(2000);
    BitBtn2Click(nil);
    exit;
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit11.Text)) then     //resetbts
  begin
    if CheckBox2.Checked then
    self.SendSms(toTel,GetRePoStr(3),di);
    sleep(2000);
    BitBtn2Click(nil);
    BitBtn1Click(nil);
    exit;
  end;

  if sysutils.SameText(trim(LabeledEdit13.Text),AllText) then   //reboot
  begin
    if CheckBox2.Checked then
    self.SendSms(toTel,GetRePoStr(3),di);
    sleep(500);
    Reboot;
    exit;
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit14.Text)) then   //shutdown
  begin
    if CheckBox2.Checked then
    self.SendSms(toTel,GetRePoStr(3),di);
    sleep(500);
    shutdown;
    exit;
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit18.Text)) then     //list online device
  begin
    c:=0;
    lst:=self.DeviceList.LockList;
    for  i:= 0 to lst.Count-1 do
    begin
      di2:=TDeviceInfo(lst.Items[i]);
      if di2.isReg then
      inc(c);
    end;
    j:=0;
    for i:= 0 to lst.Count-1 do
    begin
      di2:=TDeviceInfo(lst.Items[i]);
      s3:='';
      if di2.isReg then
      begin
        s3:=inttostr(j+1)+'/'+inttostr(c);
        inc(j);
      end
      else
      begin
        system.Continue;
        s3:='';
      end;

      s3:=GetDeviceInfoForSMS(di2,lst,i,s3,True);
      self.SendSms(toTel,s3,di);

    end;
    self.DeviceList.UnlockList;
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit19.Text)) then     //list all device
  begin
    c:=0;
    lst:=self.DeviceList.LockList;
    for  i:= 0 to lst.Count-1 do
    begin
      di2:=TDeviceInfo(lst.Items[i]);
      if di2.isReg then
      inc(c);
    end;
    for i:= 0 to lst.Count-1 do
    begin
      di2:=TDeviceInfo(lst.Items[i]);
      s3:='';
      if di2.isReg then
      begin
        s3:=inttostr(j)+'/'+inttostr(c);
        inc(j);
      end
      else
      begin
        s3:='';
      end;

      s3:=GetDeviceInfoForSMS(di2,lst,i,s3);
      self.SendSms(toTel,s3,di);

    end;
    self.DeviceList.UnlockList;

  end;
  if sysutils.SameText(AllText,trim(LabeledEdit21.Text)) then
  begin
    CheckBox10.Checked:=true;
    CheckBox10Click(nil);
  end;
  if sysutils.SameText(AllText,trim(LabeledEdit22.Text)) then
  begin
    CheckBox10.Checked:=False;
    CheckBox10Click(nil);
  end;

  if sysutils.SameText(AllText,trim(LabeledEdit23.Text)) then
  begin
    ExecutePlan();
  end;

  if sysutils.SameText(str,trim(LabeledEdit20.Text)) then     //allowDevice
  begin
    if strlst2.Count<2 then
    exit;
    lst:=self.DeviceList.LockList;
    s3:=strlst2.Strings[1];
    s3:=trim(s3);
    di2:=GetDiByIdent(s3,true);
    if di2=nil then
    begin
      self.SendSms(toTel,'',di,true);
    end
    else
    begin
      di2.AllowReg:=True;
      di2.Kick:=False;
      if CheckBox2.Checked then
      self.SendSms(toTel,GetRePoStr(3),di);
    end;
    self.ReListDevice(di2);
    self.DeviceList.UnlockList;

  end;

  if sysutils.SameText(str,trim(LabeledEdit24.Text)) then     //tick
  begin
    if strlst2.Count<2 then
    exit;

    lst:=self.DeviceList.LockList;
    s3:=trim(strlst2.Strings[1]);
    di2:=GetDiByIdent(s3);
    if di2=nil then
    begin
      self.SendSms(toTel,'',di,true);
    end
    else
    begin
      di2.AllowReg:=False;
      di2.Kick:=true;
      if CheckBox2.Checked then
      self.SendSms(toTel,GetRePoStr(3),di);
    end;
    self.ReListDevice(di2);
    self.DeviceList.UnlockList;
  end;

  if sysutils.SameText(str,trim(LabeledEdit16.Text)) or sysutils.SameText(str,trim(LabeledEdit17.Text)) then    //转发
  begin
    s3:=OrgText;
    i:=0;
    while i<3 do
    begin
      p:=pos(',',s3);
      if p<>0 then
      begin
        delete(s3,1,p);
      end
      else
      begin
        p:=pos('，',s3);
        if p>0 then
        p:=p+1;
        delete(s3,1,p);
      end;

      inc(i);
    end;
    DestTel:=trim(strlst2.Strings[1]);
    Dest:=trim(strlst2.Strings[2]);
    if dest='***' then
    begin
      lst:=self.DeviceList.LockList;
      for i := 0 to lst.Count-1 do
      begin
        di2:=TDeviceInfo(lst.Items[i]);
        if not di2.isReg then
        system.Continue;
//        self.SendSms(DestTel,s3,di2);
        if GetHWCount>0 then
        begin
          R:=self.SendSms(DestTel,s3,di2);
          if R=0 then
          DecHwCount;
          if R=-1 then
          begin
//            DecHwCount;
//            DecHwCount;
          end;
        end
        else
        begin
          self.SendSms(toTel,'次数=0',di);
          system.Break;
        end;
      end;
      if lst.Count>0 then
      begin
        if CheckBox2.Checked then
        self.SendSms(toTel,GetRePoStr(3),di);
      end
      else
      begin
        self.SendSms(toTel,' ',di);
      end;
      self.DeviceList.UnlockList;

    end
    else
    begin
      di2:=GetDiByIdent(dest);
      if (di2=nil) or (strlst.Count<3) then
      begin
        self.SendSms(toTel,' ',di);
      end
      else
      begin
        if GetHWCount=0 then
        begin
          self.SendSms(toTel,'次数=0',di);
          exit;
        end;
        self.SendSms(DestTel,s3,di2,false);

        if not isFreeIMEI(di2.IMEI) then
        begin
          fununit.DecHwCount;
        end;

        if CheckBox2.Checked then
        self.SendSms(toTel,GetRePoStr(3),di);
      end;
    end;
  end;

  finally
  end;


end;

procedure TMainForm.OnRecvMsg_RecvSms(var msg:TMSGData;strlst:TStringList);
var
  s:String;
  di:TDeviceInfo;
  s2:string;
  i:integer;
  w:WideString;
  aimei,atmsi,aimsi:string;
  aimei2,atmsi2,aimsi2:string;
  tel:string;
  strlst2:TStringList;
  c:integer;
  e:string;
begin
  s2:='';
  s2:='';
  e:='';

  strlst2:=TStringList.Create;
  di:=nil;
  aimei:=strlst.Values['IMEI'];
  atmsi:=strlst.Values['TMSI'];
  aimsi:=strlst.Values['IMSI'];
  tel:=strlst.Values['Tel'];
  if (aimei='(null)') then
  aimei:='';
  if (aimsi='(null)') then
  aimsi:='';
  if (atmsi='(null)') then
  atmsi:='';

  aimei2:='';
  atmsi2:='';
  aimsi2:='';

  di:=self.NewDevice(aimei,aimsi,atmsi);
  if di<>nil then
  begin
    di.LastTime:=now;
    di.isReg:=true;
    if aTMSI<>'' then
    di.TMSI:=aTMSI;

    if aimsi<>'' then
    di.IMSI:=aimsi;

    FillBaseInfo(di,strlst,False);
    self.ReListDevice(di);
  end;
  try
  OnRecvMsg_RecvSms_CMD(msg,strlst);
  except
  end;

  if di=nil then
  begin
    s:='';
    if aimsi<>'' then
    s:='IMSI: '+aimsi;
    if aimei<>'' then
    begin
      if s<>'' then
      s:=s+',';
      s:=s+'IMEI: '+GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User,False);
    end;
    if aTMSI<>'' then
    begin
      if s<>'' then
      s:=s+',';
      s:=s+'TMSI: '+aTMSI;
    end;
  end
  else
  begin
     s:='型号: '+di.Model+', '+'IMEI: '+GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_user,False)+', IMSI: '+di.IMSI;
  end;

  strlst2.Add(sysutils.FormatDateTime('====yyyy-MM-dd hh:NN:ss=======================',now));
  strlst2.Add('源    :'+s);
  if s2='' then
  strlst2.Add('目标 : '+strlst.Values['Tel']+',编码: '+strlst.Values['EncodeStr'])
  else
  strlst2.Add(s2+'=>目标: '+strlst.Values['Tel']+',编码: '+strlst.Values['EncodeStr']);

  w:=strlst.Values['TEXT'];
  strlst2.Add('内容('+inttostr(length(w))+'): '+w);
  strlst2.Add('');

  s2:='外发短信=>'+strlst.Values['Tel']+',编码: '+strlst.Values['EncodeStr'];
  s2:=s2+',内容('+inttostr(length(w))+'): '+w;
  if di<>nil then
  di.AddHistoryLog(s2);

  self.Memo3.Lines.BeginUpdate;
  for i := 0 to strlst2.Count-1 do
  begin
    if self.Memo3.Lines.Count>i then
    self.Memo3.Lines.Insert(i,strlst2.Strings[i])
    else
    self.Memo3.Lines.Add(strlst2.Strings[i]);
  end;
  self.Memo3.Lines.EndUpdate;

  if self.CheckBox6.Checked then
  msg.res:=1;

  //aimei2:='';
  //atmsi2:='';
  //aimsi2:='';

  self.SaveSMS('',strlst.Values['Tel'],'','',aIMEI,aIMSI,strlst.Values['Text'],strlst.Values['EncodeStr'],1);
  sysutils.FreeAndNil(strlst2);

  if (di<>nil) and CheckBox12.Checked then
  begin
   if is_UserSendDev(di) then
   begin
     SendSMS_SelfIMEI(trim(strlst.Values['Tel']),di,strlst.Values['Text']);
   end;
  end;

end;

procedure TMainForm.ClearDataForBTSAbort_Start;
var
  lst:TList;
  i:integer;
  di:TDeviceInfo;
begin
  di:=nil;
  lst:=nil;
  lst:=self.DeviceList.LockList;
  for i := 0 to lst.Count-1 do
  begin
    di:=TDeviceInfo(lst.Items[i]);
    di.isReg:=False;
  end;
  self.DeviceList.UnlockList;
  self.ListAllDevice(self.DBGrid_lv1,False);
  self.ListAllDevice(self.DBGrid_lv2,True);

end;

procedure TMainForm.OnRecvMsg_OnLog_Replace(var s:string);
var
  p1,p2:integer;
begin

   if pos('Yate (',s)>0  then
   begin
     p1:=pos(' is starting',s);
     if p1>0 then
     begin
       delete(s,1,p1+3);
       exit;
     end;
   end;

   if pos(' ./transceiver-',s)>0 then
   begin
     s:=strutils.AnsiReplaceStr(s,' ./transceiver-usrp1',' transceiver-u');
     s:=strutils.AnsiReplaceStr(s,' ./transceiver-bladerf',' transceiver-b');
     s:=strutils.AnsiReplaceStr(s,' ./transceiver-rad1',' transceiver-r');
     s:=strutils.AnsiReplaceStr(s,' ./transceiver-c118',' transceiver-c');
     s:=strutils.AnsiReplaceStr(s,' ./transceiver-118',' transceiver-1');
   end;
   if pos('TRX->USRP interface',s)>0 then
   begin
     s:=strutils.AnsiReplaceStr(s,'TRX->USRP interface','TRX->interface');
     exit;
   end;

   if pos('USRPDevice.cpp:',s)>0 then
   begin
     s:=strutils.AnsiReplaceStr(s,'USRPDevice.cpp:','device.cpp');
     exit;
   end;
   if pos('OpenBTS.cpp:',s)>0 then
   begin
     s:=strutils.AnsiReplaceStr(s,'OpenBTS.cpp:','bts.cpp:');
     exit;
   end;
   if pos('.cpp:',s)>0 then
   begin
     if pos('TRXManager.cpp:',s)>0 then
     begin
       s:=strutils.AnsiReplaceStr(s,'TRXManager.cpp:','manager.cpp:');
       exit;
     end;
     if pos('GSMConfig.cpp:',s)>0 then
     begin
       s:=strutils.AnsiReplaceStr(s,'GSMConfig.cpp:','config.cpp:');
       exit;
     end;
     if pos('SigConnection.cpp:',s)>0 then
     begin
       s:=strutils.AnsiReplaceStr(s,'SigConnection.cpp:','connection.cpp:');
       exit;
     end;
   end;
end;

function TMainForm.OnRecvMsg_OnLog_Filter(s:string):boolean;
var
  p1,p2:integer;
begin
  Result:=true;

   p1:=pos('RadioResource.cpp',s);
   p2:=pos('AccessGrantResponder: LUR congestion',s);
   if (p1>0) and (p2>0) and (p2>p1) then
   begin
     exit;
   end;

   //----------------
   p1:=pos(') TMSI=',s);
   p2:=pos('MT call to (',s);

   if (p1>0) and (p2>0) and (p1>p2) then
   begin
     exit;
   end;
   if pos('<ybts:ALL> Started paging TMSI',s)>0  then
   begin
     exit;
   end;
   if pos('<ybts:ALL> Stopped paging TMSI',s)>0  then
   begin
     exit;
   end;
   if pos('<ybts-mm:ALL> Added UE (0x',s)>0  then
   begin
     exit;
   end;
   if pos('<ybts:ALL> UE destroyed [0x',s)>0  then
   begin
     exit;
   end;
   if pos('<ybts-mm:ALL> Removed UE (0x',s)>0  then
   begin
     exit;
   end;
   if pos('<ybts:ALL> MT SMS ''ybts/sms/',s)>0  then
   begin
     exit;
   end;
   p1:=pos('<ybts:ALL> SMS CP-ACK conn=',s);
   p2:=pos('callRef=0 tiFlag=true',s);
   if (p1>0) and (p2>0) and (p1>p2) then
   begin
     exit;
   end;
   if pos('<ybts:INFO> MT SMS ''ybts/sms/',s)>0 then
   begin
     exit;
   end;

   p1:=pos('PagingResponse TMSI=',s);
   p2:=pos('for unknown UE',s);
   if (p1>0) and (p2>0) and (p1>p2) then
   begin
     exit;
   end;

   if pos('Releasing connection (0x',s)>0  then
   begin
     exit;
   end;
   if pos('Added connection (0x',s)>0  then
   begin
     exit;
   end;
   if pos('Removing released connection ',s)>0  then
   begin
     exit;
   end;
   if pos('OpenBTS ',s)>0  then
   begin
     exit;
   end;
   if pos('Copyright ',s)>0  then
   begin
     exit;
   end;
   if pos('Yate-BTS ',s)>0  then
   begin
     exit;
   end;

   if pos('MBTS connected to YBTS',s)>0  then
   begin
     exit;
   end;
   if pos('libusb, LGPL 2.1',s)>0  then
   begin
     exit;
   end;
   if pos('Incorporated L/GPL',s)>0  then
   begin
     exit;
   end;

   if pos('Parsed ''nib'' script: /',s)>0 then
   exit;

   if pos('"OpenBTS" is a registered',s)>0 then
   exit;

   if pos('yate',s)>0 then
   begin
     if pos('Failed to open config file ',s)>0 then
     begin
       if pos('tmsidata.conf',s)>0 then
       exit;
     end;
     if pos('Starting peer ',s)>0 then
       exit;
     if pos('Failed to load entity caps from',s)>0 then
       exit;
     if pos('Parsed ''eliza'' script:',s)>0 then
     exit;

   end;

   Result:=false;

end;

procedure TMainForm.OnRecvMsg_OnLog(var msg: TMSGData; strlst: TStringList);
var
  s,s2,s3,s4:string;
  i,p:integer;
  d:TDateTime;
  a:Boolean;
  T:int64;
  b:Boolean;
  di:TDeviceInfo;
  p1,p2,L1,L2:integer;
  procedure Delzz(var s:String);
  begin
    p1:=pos(' <',s);
    p2:=pos('> ',s);
    if (p1=0) or (p2=0) or (p1>=p2) then
    exit;
    delete(s,p1+1,p2-p1+1);
  end;
  procedure Delzz2(var s:String);
  begin
    //[0x99f3938]
    p1:=pos('[0x',s);
    p2:=pos(']',s);
    if (p1=0) or (p2=0) or (p1>=p2) then
    exit;
    delete(s,p1,p2-p1+1);
  end;
  procedure RemTimeStr(var s:String);
  var
    p:integer;
    s2:string;
    t:TDateTime;
  begin
     //04:58:46.004110 UE destroyed
    if length(s)<10 then
    exit;
    p:=pos(' ',s);
    if p=0 then
    exit;
    if p<10 then
    exit;

    if s[3]<>':' then
    exit;

    if s[6]<>':' then
    exit;
    if s[9]<>'.' then
    exit;
    s2:=copy(s,1,8);
    if not sysutils.TryStrToTime(s2,t) then
    exit;
    delete(s,1,p-1);
    s:=sysutils.FormatDateTime('HH:nn:ss ',t)+s;

  end;

  function AddCNStr(s:String):boolean;
  var
    i:integer;
  begin
      Result:=True;
      //Yate (27299) is starting Sun Sep 13 06:22:56 2015
      i:=pos('Yate (',s);
      if i>0 then
      begin
        p:=pos(' is starting',s);
        if p>i then
        begin
          memo7.Lines.Add('    ====== 基站后台程序启动 ======');
        end;
      end;

      a:=false;
      if pos('setRxFreq: set RX:',s)>0 then
      begin
        if pos('failed',s)>0 then
        begin
          a:=true;
        end;
      end;
      if not a then
      begin
        if pos('driveControl: RX failed to tune',s)>0 then
        begin
          a:=true;
        end;
      end;
      if a then
      begin
        memo7.Lines.Add('    ====== 接收频率设置失败,请确认模块是否支持这个频率 ======');
        memo7.Lines.Add('    ====== 900硬件，只支持9xxMhz,1800版只支持18xxMhz频段内的频点,请调整频点或联系卖家，升级850/900/1800/1900四频硬件 ======');
        memo7.Lines.Add('    ====== 850/900/1800/1900四频基站，能保证全球通用 ======');
      end;

      b:=false;

      if pos('usb_control_msg failed: error sending control message: No such device',s)>0 then
      begin
        b:=true;
      end;
      if pos('Transceiver quit with status 6',s)>0 then
      begin
        b:=true;
      end;
      if pos('usrp: failed to find usrp[0]',s)>0 then
      begin
        b:=true;
      end;
      if b then
      begin
        memo7.Lines.Add('    ====== 无线电收发器启动失败，可能线松了，可能是无线硬件类型选择错误 ======');
      end;

      if pos('reason=''postdialdelay''',s)>0 then
      begin
        memo7.Lines.Add('    ====== 短信发送延时,稍后重试! ======');
      end;

      if pos('Transceiver quit with status 6. Exiting',s)>0 then
      begin
        memo7.Lines.Add('    ====== 无线电收发器退出，设备没插好？！ ======');
      end;

      b:=False;
      if sysutils.SameText('fusb::_reap: No such device',s) then
      begin
        b:=true;
      end;
      if (pos('fusb',s)>0) and (pos('Protocol error',s)>0) then
      begin
        b:=true;
      end;

      if (pos('_reap: usb->status = -',s)>0) then
      begin
        b:=true;
      end;

      if b then
      begin
        memo7.Lines.Add(s);
        memo7.Lines.Add('    ====== 无线电收发器丢失，拨了，线松了？！ ======');
        BitBtn2Click(nil);
        memo7.Lines.Add('    ====== 防止太多错误日志，已经强行终止后台程序，请检查后再启动 ======');
        self.Timer_ResetBTS.Enabled:=false;
        Memo7.Lines.EndUpdate;
        Result:=False;
        exit;
      end;

      if pos('clockHandler: TRX clock interface timed out, assuming TRX is dead',s)>0 then
      begin
        AddCNStr('无法启动无线电收发器，请检查模块是否正常..');
   //     Result:=true;
        exit;
      end;

      if pos('<RManager:WARN> Accept error: Too many open files',s)>0 then
      begin
        if not BitBtn1.Enabled then
        begin
          memo7.Lines.Add('    ====== 后台错误，准备重启后台。。。 ======');
          BitBtn2Click(nil);
          sleep(1000);
          BitBtn1Click(nil);
        end
        else
        begin
          BitBtn2Click(nil);
          memo7.Lines.Add('    ====== 后台错误，已经强行终止。。。 ======');
        end;

      end;

      if pos('Unloading module YBTS',s)>0 then
      begin
       ClearDataForBTSAbort_Start;
       memo7.Lines.Add('    ====== 后台终止，清理数据完成 ======');
      end;

      i:=pos(' State changed Running -> RadioUp',s);
      if i>0 then
      begin
       memo7.Lines.Add('    ====== 无线收发器已经正式工作 ======');
       ClearDataForBTSAbort_Start;
      end;
      i:=pos('Starting transceiver',s);
      if i>0 then
      begin
       memo7.Lines.Add('    ====== 启动无线电收发器 ======');
       ClearDataForBTSAbort_Start;
      end;
  end;

begin
  s:='';


  Memo7.Lines.BeginUpdate;


  for i := 0 to strlst.Count-1 do
  begin
    s:=strlst.Strings[i];
    p:=pos('IMEI',s);
    if p>0 then
    begin
      s:=copy(s,1,p-1)+'    --------IMEI--------';
      s:=strutils.StringsReplace(s,['<ybts-signalling:','<ybts/'],['<signalling','</'],[]);
    end;

    if length(s)>10 then
    begin
     s2:=copy(s,1,10);
     if sysutils.TryStrToDate(s2,d) then
     begin
      if abs(d-now)<10 then
      begin
       delete(s,1,11);
      end;
     end;
    end;

    //      //17 <nib:TEST> onRoute TMSI007b0001 -> 111111111
    p1:=pos('onRoute TMSI',s);
    p2:=pos('->',s);
   if (p2>p1) and (p2>0) and (p1>0) then
   begin
     s2:=s;
     L1:=length('onRoute TMSI');
     L2:=p2-p1-L1;
     s3:=trim(copy(s2,p1+L1,L2-1));
     s4:=copy(s2,p2+2,maxint);
     s4:=trim(s4);
     if (s3<>'') and (s4<>'') then
     begin
       di:=self.FindDevice('','',s3);
       if di<>nil then
       begin
         di.AddCall(s4);
         self.ReListDevice(di);
       end;
     end;

   end;

   if not CheckBox19.Checked then
   system.Continue;

   if pos('handoverPending: handover clear failed',s)>0 then
   begin
     system.Continue;
   end;
   if pos('clearHandover: NOHANDOVER failed with status ',s)>0 then
   begin
     system.Continue;
   end;
   p1:=pos('Opened bladeRF serial=',s);
   if p1>0 then
   begin
     setlength(s,p1-1);
     s:=s+'Opened RF Board OK';
   end;

   p1:=pos('*** Error in ',s);
   if p1=1 then
   begin
     memo7.Lines.Add('    ====== 后台出错，紧急重启后台!! ======');
     BitBtn2Click(nil);
     BitBtn1Click(nil);
     system.Break;
   end;
   p1:=pos('Segmentation fault',s);
   if p1=1 then
   begin
     if not BitBtn1.Enabled then
     begin
       memo7.Lines.Add('    ====== 后台出错，紧急重启后台!! ======');
       BitBtn2Click(nil);
       BitBtn1Click(nil);
       system.Break;
     end;
   end;

   if self.OnRecvMsg_OnLog_Filter(s) then
   system.Continue;
   OnRecvMsg_OnLog_Replace(s);

   delzz(s);
   Delzz2(s);

   RemTimeStr(s);
   if pos('Started',s)>0 then
   begin
     s2:=trim(copy(s,11,maxint));
     if s2='Started' then
     begin
       system.Continue;
     end;
   end;


   if not AddCNStr(s) then
   system.Break;
   {
   s:=strutils.StringsReplace(s,[' <mbts:MILD> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <mbts:WARN> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <mbts:NOTE> '],[' '],[]);

   s:=strutils.StringsReplace(s,[' <nib:INFO> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <javascript:INFO> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <ybts:NOTE> '],[' '],[]);

   s:=strutils.StringsReplace(s,[' <cpuload:NOTE> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <ALL> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <INFO> '],[' '],[]);

   s:=strutils.StringsReplace(s,[' <transceiver:NOTE> '],[' '],[]);

   s:=strutils.StringsReplace(s,[' <ybts-signalling:ALL> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <ybts-mm:ALL> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <ybts:ALL> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <nib:TEST> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <sip:ALL> '],[' '],[]);
   s:=strutils.StringsReplace(s,[' <jingle:ALL> '],[' '],[]);

   }

   memo7.Lines.Add(s);
  end;
  //


   while memo7.Lines.Count>5000 do
   begin
     memo7.Lines.Delete(0);
   end;


  if CheckBox13.Checked then
  begin
//   self.Memo7.SelStart:=length(self.Memo7.Lines.Text);
//    memo7.Perform(EM_SCROLLCARET,0,0);
//    EchoMemo.ScrollBy(0, EchoMemo.Lines.Count);
    memo7.VertScrollBar.Position:=memo7.VertScrollBar.Range;
  end;

  Memo7.Lines.EndUpdate;
end;

procedure TMainForm.SendSMS_SelfIMEI(Sender:String;di:TDeviceInfo;sms:String);
var
  c:integer;
  lst:TList;
  di2:TDeviceInfo;
  i:integer;
begin
  sender:=trim(sender);
  if sender='' then
  sender:='0';
  Sender:=Sender+'00'+Sender;

  if isFreeIMEI(di.IMEI) then
  begin
   exit;
  end;

  lst:=self.DeviceList.LockList;
  for i := 0 to lst.Count-1 do
  begin
    di2:=lst.Items[i];
    if not di2.isReg then
    begin
      system.Continue;
    end;
    if isFreeIMEI(di2.IMEI) then
    self.SendSms(Sender,sms,di2,True);
  end;
  self.DeviceList.UnlockList;

end;

procedure TMainForm.OnRecvMsg(var msg:TMSGData;strlst:TStringList);
var
  s:String;
  di,di2:TDeviceInfo;
  s2,s3:string;
  strlst2:TStringList;
  i:integer;
  w:WideString;
  aimei,atmsi,aimsi,TMSI2:string;
  tel:string;
  lst:TList;
  c:integer;
  e:string;
  T:int64;
begin
  msg.DataSize:=0;
  s:='';
  s2:='';
  s3:='';
  di:=nil;
  strlst2:=nil;

  if msg.MsgType=ord(mt_log) then
  begin
    self.MsgLock.Enter;
    try
//      T:=sysutils.GetTickCount;
      OnRecvMsg_OnLog(msg,strlst);
//      T:=sysutils.GetTickCount-T;
//      writeln(T);
    except
    end;
    self.MsgLock.Leave;
    exit;
  end;

//  WriteLn(strlst.Text);

  try
  strlst2:=TStringList.Create;

  aimei:=strlst.Values['IMEI'];
  atmsi:=strlst.Values['TMSI'];
  aimsi:=strlst.Values['IMSI'];
  tel:=strlst.Values['Tel'];
  if (aimei='(null)') then
  aimei:='';
  if (aimsi='(null)') then
  aimsi:='';
  if (atmsi='(null)') then
  atmsi:='';

  if atmsi<>'' then
  begin
   if atmsi[1]<>'0' then
   atmsi:='';
  end;

  self.MsgLock.Enter;
  try

  case TMSGType(msg.MsgType) of
    mt_none   :
        begin

        end;
    mt_log  :
        begin
          OnRecvMsg_OnLog(msg,strlst);
        end;
    mt_Register:
        begin
          OnRecvMsg_OnRegister(msg,strlst);

        end;
    mt_UnRegister:
        begin
          di:=self.NewDevice(aimei,aimsi,atmsi);
          if di<>nil then
          begin
            di.isReg:=False;
            di.LastTime:=now;
            di.AddHistoryLog('离网');
            ReListDevice(di);
          end;

        end;
    mt_ConnRequest:
        begin
          if blAllowAllReg then
          begin
           msg.Res:=1;
          end;

          di:=self.NewDevice(aimei,aimsi,atmsi);
          if di=nil then
          exit;
          if di.isReg then
          begin
            msg.res:=1;
          end;
          if (di.modem_DB or di.modem_User) then
          begin
            if CheckBox3.Checked then
            msg.res:=1;
          end;
          if di.AllowReg then
          begin
            msg.res:=1;
          end;
          if isFreeIMEI(di.IMEI) then
          begin
            msg.Res:=1;
          end;
          if CheckBox20.Checked then
          begin
            msg.Res:=1;
          end;

          if di.Kick then
          begin
            msg.res:=0;
          end;
          if Tel<>'' then
          di.Tel:=Tel;
          inc(di.Count);

          FillBaseInfo(di,strlst);

          di.LastTime:=now;
          if msg.Res=1 then
          di.AddHistoryLog('入网申请: 同意')
          else
          di.AddHistoryLog('入网申请: 拒绝');

          ReListDevice(di);
        end;
    mt_TickConn:    //BTS端接收
        begin
           //none code
        end;
    mt_SendSms:    //BTS端发送确认
        begin
          //send    ,nodecode
          s2:=strlst.Values['DestTmsi'];
          if pos('TMSI',sysutils.UpperCase(s2))=1 then
          begin
            delete(s2,1,4);
            di:=self.FindDevice(aimei,aimsi,s2);
//            if di<>nil then
//            di.LastTime:=now;
          end;

          s2:=trim(strlst.Values['smskey']);
          if (s2<>'') and (self.SendDataHisory.IndexOfName(s2)<>-1) then
          begin
            s:=s+strlst.Values['SrcTel']+' => '+strlst.Values['DestTmsi'];
            if di<>nil then
            s:=s+',型号:'+di.Model+',IMEI:'+di.IMEI+',IMSI:'+di.IMSI;

            s3:='下发短信,号码:'+strlst.Values['SrcTel'];
            strlst2.Add(s);

            if strlst.Values['OK']='1' then
            begin
              strlst2.Add('短信已送达,内容概要 : '+self.SendDataHisory.Values[s2]);
              s3:=s3+'=> 短信已送达';
              if di<>nil then
              di.LastTime:=now;
            end
            else
            begin
              s2:=strlst.Values['Reason'];
              s:='发送失败 : ';
              if sysutils.SameText(s2,'exiting') then
              s:=s+'重复';

              if sysutils.SameText(s2,'cancelled') then
              s:=s+'放弃';
              if sysutils.SameText(s2,'timeout') then
              s:=s+'超时';
              if sysutils.SameText(s2,'offline') then
              s:=s+'离线';

              if sysutils.SameText(s2,'failure') then
              s:=s+'失败';
              if sysutils.SameText(s2,'postdialdelay') then
              s:=s+'延后发送';

              s3:=s3+'=>'+s;

              strlst2.Add(s+',内容概要 : '+self.SendDataHisory.Values[s2]);
            end;
            s3:=s3+' 内容概要: '+self.SendDataHisory.Values[s2];
            if di<>nil then
            di.AddHistoryLog(s3);

          end;
          self.Memo3.Lines.BeginUpdate;
          for i := 0 to strlst2.Count-1 do
          begin
            if self.Memo3.Lines.Count>i then
            self.Memo3.Lines.Insert(i,strlst2.Strings[i])
            else
            self.Memo3.Lines.Add(strlst2.Strings[i]);
          end;
          self.Memo3.Lines.EndUpdate;


        end;
    mt_RecvSms:
        begin
          if strlst.Count=0 then
          exit;
          OnRecvMsg_RecvSms(msg,strlst);
        end;
    mt_ConnLost:
        begin
          di:=self.NewDevice(aimei,aimsi,atmsi);
          if di<>nil then
          begin
          if aTMSI<>'' then
            di.TMSI:=aTMSI;
            if tel<>'' then
            di.Tel:=tel;
            di.isReg:=False;
//            di.LastTime:=now;
            ReListDevice(di);
            FillBaseInfo(di,strlst);
//            di.AddHistoryLog('连接丢失');
            DelFromListView(di,self.DBGrid_lv2);
          end;
        end;
    mt_ConnRelease:
        begin
          di:=self.FindDevice(aimei,aimsi,atmsi);
          if di<>nil then
          begin
            if aTMSI<>'' then
            di.TMSI:=aTMSI;

  //          di.isReg:=False;
            FillBaseInfo(di,strlst);
            di.LastTime:=now;
            ReListDevice(di);
          end;
//          self.FindListItem()
        end;
    mt_Call:
        begin
          di:=self.FindDevice(aimei,aimsi,atmsi);
          if di<>nil then
          begin
            if aTMSI<>'' then
            di.TMSI:=aTMSI;

            di.isReg:=True;
            FillBaseInfo(di,strlst);
            di.LastTime:=now;
            ReListDevice(di);
          end;
          di.AddCall(strlst.Values['Tel']);
          di.AddHistoryLog('电话=>'+strlst.Values['Tel']);
        end;
    mt_RadioReady:
        begin

        end;
    mt_ProgEnd:
        begin

        end;
    mt_progStart:
        begin

        end;
    mt_sig:
        begin

        end;
    mt_Conn_Allow:
        begin

        end;
    mt_Conn_deny:
        begin

        end;
  end;
  except
  end;
  finally
    if strlst2<>nil then
    sysutils.FreeAndNil(strlst2)
  end;
  if di<>nil then
  begin
    if (TMsgType(msg.MsgType) in [mt_ConnRequest,mt_TickConn,mt_SendSms,mt_Register,mt_UnRegister,mt_ConnLost,mt_ConnRelease,mt_sig]) then
    begin
      dmunit.DataModule1.SaveDevinfo(di);
    end;
  end;

  self.MsgLock.Leave;

end;

function ToIntToStr(Str:String;len:integer;def:integer):string;
var
  t:integer;
  fmt:string;
begin
  Result:='';
  t:=def;
  if not sysutils.TryStrToInt(Str,t) then
  t:=def;

  if len=0 then
  begin
    fmt:='%d'
  end
  else
  begin
    fmt:='%.'+inttostr(len)+'d';
  end;
  Result:=sysutils.Format(fmt,[t]);
end;

procedure TMainForm.SaveConfig(all:boolean=False);
var
  ini:Tinifile;
  i,j,k:integer;
  strlst:TStringList;
  fn:string;
  s,s2,s3,s4:String;
  CFG:TYateCFG;
  b:Boolean;
  R:Boolean;
  dirty:Boolean;
  T:integer;
begin

  fn:='/usr/local/etc/yate/ybts.conf';
  if ComboBox3.Text='' then
  ComboBox3.Text:='CMCC';
  CFG:=nil;
  ini:=nil;
  strlst:=nil;
  dirty:=false;

  if sysutils.FileExists(fn) then
  begin
//  ini:=Tinifile.Create(fn);
//  ini.EscapeLineFeeds:=False;
  CFG:=TYateCFG.Create(fn);
  if ShowCountry then
  CFG.WriteString('gsm_advanced','ShowCountry','yes')
  else
  CFG.WriteString('gsm_advanced','ShowCountry','no');

  Edit15.Text:=trim(Edit15.Text);
  Edit16.Text:=trim(Edit16.Text);
  Edit17.Text:=trim(Edit17.Text);
  Edit18.Text:=trim(Edit18.Text);

  CFG.WriteString('gsm','Identity.LAC',ToIntToStr_NullRandom(Edit15.Text,0,100,60000));

  CFG.WriteString('gsm','Identity.CI',ToIntToStr_NullRandom(Edit16.Text,0,1,60000));
  CFG.WriteString('gsm','Identity.BSIC.BCC',Edit17.Text);
  CFG.WriteString('gsm','Identity.BSIC.NCC',Edit18.Text);


  case ComboBox1.ItemIndex of
    0: CFG.WriteString('gsm','Radio.Band','850');
    1: CFG.WriteString('gsm','Radio.Band','900');
    2: CFG.WriteString('gsm','Radio.Band','1800');
    3: CFG.WriteString('gsm','Radio.Band','1900');
  end;
  CFG.WriteString('gsm','Radio.C0',Edit4.Text);
  CFG.WriteString('gsm','Identity.MCC',ToIntToStr(Edit1.Text,3,001));
  CFG.WriteString('gsm','Identity.MNC',ToIntToStr(Edit2.Text,2,01));
  CFG.WriteString('gsm','Identity.ShortName',ComboBox3.Text);

  case ComboBox4.ItemIndex of
    0: CFG.WriteString('transceiver','Path','./transceiver-usrp1');
    1: CFG.WriteString('transceiver','Path','./transceiver-bladerf');
  else
    CFG.WriteString('transceiver','Path','./transceiver-usrp1');
  end;

  if (SpinEdit4.Value=0) then
  CFG.WriteString('gsm','SI3RO','0')
  else
  CFG.WriteString('gsm','SI3RO','1');

  CFG.WriteInt64('gsm','SI3RO.CRO',SpinEdit4.Value);
  CFG.WriteString('gsm','SI3RO.TEMPORARY_OFFSET',CFG.ReadString('gsm','SI3RO.TEMPORARY_OFFSET','0'));
  CFG.WriteString('gsm','SI3RO.PENALTY_TIME',CFG.ReadString('gsm','SI3RO.PENALTY_TIME','5'));
  CFG.WriteInt64('gsm','SI3RO.CBQ',0);
  CFG.WriteInt64('gsm','SI3RO.CBA',0);

//  CFG.WriteString('gprs','Enable','no');

  CFG.WriteInt64('gsm_advanced','CellSelection.MS-TXPWR-MAX-CCH',SpinEdit5.Value);
  CFG.WriteInt64('gsm_advanced','CellSelection.RXLEV-ACCESS-MIN',SpinEdit8.Value);
  CFG.WriteInt64('gsm_advanced','CellSelection.CELL-RESELECT-HYSTERESIS',SpinEdit9.Value);

  CFG.WriteInt64('transceiver','MinimumRxRSSI',SpinEdit6.Value);
  CFG.WriteInt64('gsm_advanced','Radio.RxGain',SpinEdit7.Value);

  if CheckBox21.Checked then
  CFG.WriteString('gprs','Enable','no')
  else
  CFG.WriteString('gprs','Enable','yes');

  sysutils.FreeAndNil(CFG);
  end;

  fn:='/usr/local/etc/yate/subscribers.conf';
  if sysutils.FileExists(fn) then
  begin
    CFG:=TYateCFG.Create(fn);
    CFG.WriteString('general','regexp','.*');
    s:=trim(LabeledEdit5.Text);
    if s<>'' then
    begin
      if s[1]='+' then
      delete(s,1,1);
    end;
    CFG.WriteString('general','country_code',s);
//    CFG.WriteString('general','smsc',labeledEdit6.Text);

    sysutils.FreeAndNil(CFG);
  end;

  ini:=tinifile.Create(sysutils.ExtractFilePath(system.ParamStr(0))+'config.ini');
  ini.WriteBool('config','AllowModemDirectReg',CheckBox3.Checked);
  Edit3.Text:=trim(Edit3.Text);
  ini.WriteString('config','Sender',Edit3.Text);
  LabeledEdit6.Text:=trim(LabeledEdit6.Text);
  ini.WriteString('config','nib_smsc_number',LabeledEdit6.Text);
  ini.WriteBool('config','FixGSMSmsTimeToLocalTime',CheckBox16.Checked);

    if all then
    begin
//      ini.WriteString('config','APName',Edit8.Text);
//      ini.WriteString('config','APPass',Edit7.Text);
      ini.WriteString('config','VNCPass',Edit9.Text);
      ini.WriteInteger('config','SendTimeOut',SpinEdit1.Value);
    end;

    ini.WriteBool('config','FilterSMSReportOK',CheckBox6.Checked);
    ini.WriteBool('config','AutoResetBTS',CheckBox7.Checked);
    ini.WriteInteger('config','AutoResetBTS_Min',SpinEdit2.Value);
    ini.WriteBool('config','FindModemSendOKSMS',CheckBox8.Checked);

    if CheckBox14.Checked then
    ini.WriteInteger('config','BTSDebugLevel',10)
    else
    ini.WriteInteger('config','BTSDebugLevel',2);

    ini.WriteBool('config','ShowLog',CheckBox19.Checked);


    ini.WriteBool('config','BTSLog_AutoScrollToEnd',CheckBox13.Checked);
    ini.WriteBool('gsm','close_gprs',CheckBox21.Checked);
    ini.WriteBool('gsm','ShowCountry',ShowCountry);
    ini.WriteString('gsm','Identity.LAC',Edit15.Text);
    ini.WriteString('gsm','Identity.CI',Edit16.Text);
    ini.WriteString('gsm','Identity.BSIC.BCC',Edit17.Text);
    ini.WriteString('gsm','Identity.BSIC.NCC',Edit18.Text);

    case ComboBox1.ItemIndex of
      0: ini.WriteInteger('gsm','Radio.Band',850);
      1: ini.WriteInteger('gsm','Radio.Band',900);
      2: ini.WriteInteger('gsm','Radio.Band',1800);
      3: ini.WriteInteger('gsm','Radio.Band',1900);
    end;
    ini.WriteString('gsm','Radio.C0',Edit4.Text);
    ini.WriteString('gsm','Identity.MCC',ToIntToStr(Edit1.Text,3,001));
    ini.WriteString('gsm','Identity.MNC',ToIntToStr(Edit2.Text,2,01));
    ini.WriteString('gsm','Identity.ShortName',ComboBox3.Text);

    ini.WriteInteger('gsm','SI3RO.CRO',SpinEdit4.Value);
    ini.WriteInteger('gsm','CellSelection.MS-TXPWR-MAX-CCH',SpinEdit5.Value);
    ini.WriteInteger('gsm','MinimumRxRSSI',SpinEdit6.Value);
    ini.WriteInteger('gsm','Radio.RxGain',SpinEdit7.Value);

    ini.WriteInteger('gsm','CellSelection.RXLEV-ACCESS-MIN',SpinEdit8.Value);
    ini.WriteInteger('gsm','CellSelection.CELL-RESELECT-HYSTERESIS',SpinEdit9.Value);

    ini.WriteString('gsm','country_code',LabeledEdit5.Text);
    ini.WriteString('gsm','smsc',labeledEdit6.Text);

    ini.WriteBool('config','AllowModemDirectReg',CheckBox3.Checked);
    ini.ReadString('config','Sender',Edit3.Text);

//    ini.WriteString('config','APName',Edit8.Text);
//    ini.WriteString('config','APPass',Edit7.Text);
    ini.WriteString('config','VNCPass',Edit9.Text);
    ini.WriteBool('config','FilterSMSReportOK',CheckBox6.Checked);
    ini.WriteBool('config','AutoResetBTS',CheckBox7.Checked);
    ini.WriteInteger('config','AutoResetBTS_Min',SpinEdit2.Value);
    ini.WriteBool('config','FindModemSendOKSMS',CheckBox8.Checked);

    ini.WriteInteger('config','RFHW',ComboBox4.ItemIndex);

    ini.WriteBool('Config','AllDirectReg',CheckBox20.Checked);

//    CheckBox10.Checked:=False;

    ini.WriteString('AutoSend','Sender',LabeledEdit26.Text);
    ini.WriteBool('AutoSend','TimeSend',RadioButton10.Checked);

    ini.WriteBool('AutoSend','RandomSmsItem',RadioButton13.Checked);

    ini.WriteBool('AutoSend','RepoSms',CheckBox11.Checked);
    ini.WriteString('AutoSend','RepoTel',Edit19.Text);
    ini.WriteString('AutoSend','RepoSMS',LabeledEdit25.Text);


    ini.EraseSection('AutoSend_SMSItem');
    for i := 0 to self.Memo11.Lines.Count-1 do
    begin
      ini.WriteString('AutoSend_SMSItem','SMSItem_'+inttostr(i+1),self.Memo11.Lines.Strings[i]);
    end;
    ini.WriteString('MPControl','ControlTel',LabeledEdit27.Text);
    ini.WriteString('MPControl','GetCount',LabeledEdit10.Text);
    ini.WriteString('MPControl','CloseBTS',LabeledEdit12.Text);
    ini.WriteString('MPControl','ReSetBTS',LabeledEdit11.Text);
    ini.WriteString('MPControl','CloseSYS',LabeledEdit14.Text);
    ini.WriteString('MPControl','ReSetSYS',LabeledEdit13.Text);
    ini.WriteString('MPControl','Send_CN',LabeledEdit16.Text);
    ini.WriteString('MPControl','Send_EN',LabeledEdit17.Text);
    ini.WriteString('MPControl','Allow',LabeledEdit20.Text);
    ini.WriteString('MPControl','Deny',LabeledEdit24.Text);
    ini.WriteString('MPControl','ListOnline',LabeledEdit18.Text);
    ini.WriteString('MPControl','ListAll',LabeledEdit19.Text);
    ini.WriteBool('MPControl','Repo',CheckBox2.Checked);
    LabeledEdit15.Text:=trim(LabeledEdit15.Text);
    if LabeledEdit15.Text='' then
    LabeledEdit15.Text:='0';
    ini.WriteString('MPControl','RepoSender',LabeledEdit15.Text);

    ini.WriteBool('MPControl','ConvertToMP',CheckBox12.Checked);
    ini.WriteString('MPControl','RepoText',Edit22.Text);

    ini.WriteString('MPControl','OpenAuto',LabeledEdit21.Text);
    ini.WriteString('MPControl','CloseAuto',LabeledEdit22.Text);
    ini.WriteString('MPControl','ManualAuto',LabeledEdit23.Text);

    sysutils.FreeAndNil(ini);

//  BitBtn5Click(nil);
  //  DBGrid_userdb.DataSource.DataSet.Open;

  LabeledEdit6.Text:=trim(LabeledEdit6.Text);
  if LabeledEdit6.Text='' then
  LabeledEdit6.Text:='12345';

  dirty:=False;
  fn:='/usr/local/share/yate/scripts/nib.js';
  if sysutils.FileExists(fn) then
  begin
    strlst:=TStringList.Create;
    strlst.LoadFromFile(fn);
    for i := 0 to strlst.Count-1 do
    begin
      s:=sysutils.LowerCase(trim(strlst.Strings[i]));
      if pos('nib_smsc_number',s)=1 then
      begin
        strlst.Strings[i]:='nib_smsc_number='+sysutils.AnsiQuotedStr(LabeledEdit6.Text,'"')+';';
        dirty:=True;
        system.Break;
      end;
    end;
    s2:=sysutils.LowerCase('function sendGreetingMessage');
    for i := 0 to strlst.Count-1 do
    begin
      s:=sysutils.LowerCase(trim(strlst.Strings[i]));
      if pos(s2,s)=1 then
      begin
        if (i+2)<strlst.Count then
        begin
          s:=trim(strlst.Strings[i+1]);
          if s='{' then
          begin
            s:=trim(strlst.Strings[i+2]);
            if not sysutils.SameText('return;',s) then
            begin
              strlst.Insert(i+2,'return;');
              dirty:=true;
            end;

          end;
        end;
        system.Break;
      end;
    end;
    s2:=sysutils.LowerCase('return onElizaSMS(msg, imsi, dest, msisdn);');
    b:=false;
    R:=False;
    for i := 0 to strlst.Count-5 do
    begin
      if b then
      system.Break;
      s:=sysutils.LowerCase(trim(strlst.Strings[i]));
      if pos(s2,s)=0 then
      system.Continue;


       b:=true;
      for j := 1 to 5-1 do
      begin
        if j+i>=strlst.Count then
        system.Break;
        s:=strlst.Strings[i+j];

        s3:=trim(sysutils.LowerCase(s));
        if CheckBox6.Checked then   //return=true  yes
        begin
          if s3='return true;' then
          begin
            R:=true;
            dirty:=true;
            system.Break;
          end;
          k:=length(s3);
          if k>0 then
          begin
            system.Break;
          end;
        end
        else    //no
        begin
          if s3='return true;' then
          begin
             strlst.Strings[i+j]:='';
             dirty:=True;
             R:=True;
             system.Break;
          end;
//          if s3<>'' then
//          system.Break;
        end;

      end;               //for i
      if not r then
      begin
        if checkBox6.Checked then
        begin
          if strlst.Count>j then
          begin
            dirty:=True;
            strlst.Insert(i+1,'');
            strlst.Insert(i+2,'       return true;');
            strlst.Insert(i+3,'');
            r:=true;
          end
          else
          begin
            writeln('script "return true" pos error');
          end;
        end
        else
        begin
            writeln('script "return true" pos error');
        end;

      end;
      break;

    end;
    s2:=LowerCase('Engine.debug(Engine.DebugInfo,"onRoute');
    b:=false;
    for i := 0 to strlst.Count-1 do
    begin
      if b then
      system.Break;
      s:=sysutils.LowerCase(trim(strlst.Strings[i]));
      if pos(s2,s)=0 then
      system.Continue;

      s:=strlst.Strings[i];

      s:=strutils.StringsReplace(s,['Engine.DebugInfo'],['Engine.DebugFail'],[rfIgnoreCase]);
      strlst.Strings[i]:=s;

      b:=true;
      system.Break;

    end;

//    if dirty then
    strlst.SaveToFile(fn);
    sysutils.FreeAndNil(strlst);
  end;

  fn:='';

end;

procedure TMainForm.ReadConfig;
var
  ini:Tinifile;
  i:integer;
  strlst:TStringList;
  fn:string;
  s:String;
  s2:String;
begin
  strlst:=TStringList.Create;
  ini:=tinifile.Create(sysutils.ExtractFilePath(system.ParamStr(0))+'config.ini');

  ShowCountry:=ini.ReadBool('gsm','ShowCountry',True);
//  Edit15.Text:=inttostr(ini.ReadInteger('gsm','Identity.LAC',1000));
  Edit15.Text:=ini.ReadString('gsm','Identity.LAC','1000');
  Edit16.Text:=inttostr(ini.ReadInteger('gsm','Identity.CI',10));
  Edit17.Text:=inttostr(ini.ReadInteger('gsm','Identity.BSIC.BCC',2));
  Edit18.Text:=inttostr(ini.ReadInteger('gsm','Identity.BSIC.NCC',0));
  LabeledEdit5.Text:=ini.ReadString('gsm','country_code','+86');
  CheckBox21.Checked:=ini.ReadBool('gsm','close_gprs',True);


  ComboBox1.ItemIndex:=1;
  i:=ini.ReadInteger('gsm','Radio.Band',900);
  case i of
    850: ComboBox1.ItemIndex:=0;
    900: ComboBox1.ItemIndex:=1;
    1800: ComboBox1.ItemIndex:=2;
    1900: ComboBox1.ItemIndex:=3;
    else
      ComboBox1.ItemIndex:=1;
  end;
  ComboBox1Change(nil);
  Edit4.Text:=inttostr(ini.ReadInteger('gsm','Radio.C0',0));
  Edit4Exit(nil);

  Edit1.Text:=ini.ReadString('gsm','Identity.MCC','460');
  Edit2.Text:=ini.ReadString('gsm','Identity.MNC','00');
  ComboBox3.Text:=ini.ReadString('gsm','Identity.ShortName','CMCC');

  SpinEdit4.Value:=ini.ReadInteger('gsm','SI3RO.CRO',SpinEdit4.Value);
//  CFG.WriteString('gsm','SI3RO.TEMPORARY_OFFSET',CFG.ReadString('gsm','SI3RO.TEMPORARY_OFFSET','0'));
//  CFG.WriteString('gsm','SI3RO.PENALTY_TIME',CFG.ReadString('gsm','SI3RO.PENALTY_TIME','5'));

  SpinEdit5.Value:=ini.ReadInteger('gsm','CellSelection.MS-TXPWR-MAX-CCH',SpinEdit5.Value);
  SpinEdit6.Value:=ini.ReadInteger('gsm','MinimumRxRSSI',SpinEdit6.Value);
  SpinEdit7.Value:=ini.ReadInteger('gsm','Radio.RxGain',SpinEdit7.Value);
  SpinEdit8.Value:=ini.ReadInteger('gsm','CellSelection.RXLEV-ACCESS-MIN',SpinEdit8.Value);
  SpinEdit9.Value:=ini.ReadInteger('gsm','CellSelection.CELL-RESELECT-HYSTERESIS',SpinEdit9.Value);

  LabeledEdit5.Text:=ini.ReadString('gsm','country_code',LabeledEdit5.Text);
  labeledEdit6.Text:=trim(ini.ReadString('gsm','smsc','+8613501000500'));
  if labeledEdit6.Text='' then
  labeledEdit6.Text:='+8613501000500';

  CheckBox3.Checked:=ini.ReadBool('config','AllowModemDirectReg',True);
  Edit3.Text:=ini.ReadString('config','Sender','13512345678');

  CheckBox16.Checked:=ini.ReadBool('config','FixGSMSmsTimeToLocalTime',CheckBox16.Checked);
  FixSmscTimeToLocalTime:=CheckBox16.Checked;

//  Edit8.Text:=ini.ReadString('config','APName','ChinaNet');
//  Edit7.Text:=ini.ReadString('config','APPass','87654321');
  Edit9.Text:=ini.ReadString('config','VNCPass','654321');
  CheckBox6.Checked:=ini.ReadBool('config','FilterSMSReportOK',CheckBox6.Checked);
  CheckBox7.Checked:=ini.ReadBool('config','AutoResetBTS',CheckBox7.Checked);
  SpinEdit2.Value:=ini.ReadInteger('config','AutoResetBTS_Min',SpinEdit2.Value);
  CheckBox8.Checked:=ini.ReadBool('config','FindModemSendOKSMS',CheckBox8.Checked);

  CheckBox14.Checked:=ini.ReadInteger('config','BTSDebugLevel',2)>2;
  CheckBox13.Checked:=ini.ReadBool('config','BTSLog_AutoScrollToEnd',CheckBox13.Checked);

  CheckBox20.Checked:=ini.ReadBool('Config','AllDirectReg',CheckBox20.Checked);

  CheckBox19.Checked:=ini.ReadBool('config','ShowLog',CheckBox19.Checked);

  CheckBox10.Checked:=False;
  LabeledEdit26.Text:=ini.ReadString('AutoSend','Sender',LabeledEdit26.Text);
  if ini.ReadBool('AutoSend','TimeSend',RadioButton10.Checked) then
  begin
    RadioButton10.Checked:=True;
    RadioButton11.Checked:=False;
  end
  else
  begin
    RadioButton11.Checked:=True;
    RadioButton10.Checked:=False;
  end;
  if ini.ReadBool('AutoSend','RandomSmsItem',RadioButton13.Checked) then
  begin
    RadioButton13.Checked:=true;
    RadioButton14.Checked:=False;
  end
  else
  begin
    RadioButton13.Checked:=False;
    RadioButton14.Checked:=True;
  end;
  CheckBox11.Checked:=ini.ReadBool('AutoSend','RepoSms',CheckBox11.Checked);
  Edit19.Text:=ini.ReadString('AutoSend','RepoTel',Edit19.Text);
  LabeledEdit25.Text:=ini.ReadString('AutoSend','RepoSMS',LabeledEdit25.Text);

  strlst.Clear;
  ini.ReadSection('AutoSend_SMSItem',strlst);
  self.Memo11.Lines.Clear;
  for i := 0 to self.Memo11.Lines.Count-1 do
  begin
    s:=ini.ReadString('AutoSend_SMSItem',strlst.Strings[i],self.Memo11.Lines.Strings[i]);
    self.Memo11.Lines.Add(s);
  end;
  LabeledEdit27.Text:=trim(ini.ReadString('MPControl','ControlTel',LabeledEdit27.Text));
  LabeledEdit10.Text:=trim(ini.ReadString('MPControl','GetCount',LabeledEdit10.Text));
  LabeledEdit12.Text:=trim(ini.ReadString('MPControl','CloseBTS',LabeledEdit12.Text));
  LabeledEdit11.Text:=trim(ini.ReadString('MPControl','ReSetBTS',LabeledEdit11.Text));
  LabeledEdit14.Text:=trim(ini.ReadString('MPControl','CloseSYS',LabeledEdit14.Text));
  LabeledEdit13.Text:=trim(ini.ReadString('MPControl','ReSetSYS',LabeledEdit13.Text));
  LabeledEdit16.Text:=trim(ini.ReadString('MPControl','Send_CN',LabeledEdit16.Text));
  LabeledEdit17.Text:=trim(ini.ReadString('MPControl','Send_EN',LabeledEdit17.Text));
  LabeledEdit20.Text:=trim(ini.ReadString('MPControl','Allow',LabeledEdit20.Text));
  LabeledEdit24.Text:=trim(ini.ReadString('MPControl','Deny',LabeledEdit24.Text));
  LabeledEdit18.Text:=trim(ini.ReadString('MPControl','ListOnline',LabeledEdit18.Text));
  LabeledEdit19.Text:=trim(ini.ReadString('MPControl','ListAll',LabeledEdit19.Text));
  CheckBox2.Checked:=ini.ReadBool('MPControl','Repo',CheckBox2.Checked);
  LabeledEdit15.Text:=trim(ini.ReadString('MPControl','RepoSender',LabeledEdit15.Text));
  LabeledEdit15.Text:=trim(LabeledEdit15.Text);
  if LabeledEdit15.Text='' then
  LabeledEdit15.Text:='13512345678';

  CheckBox12.Checked:=ini.ReadBool('MPControl','ConvertToMP',CheckBox12.Checked);
  Edit22.Text:=ini.ReadString('MPControl','RepoText',Edit22.Text);

  LabeledEdit21.Text:=trim(ini.ReadString('MPControl','OpenAuto',LabeledEdit21.Text));
  LabeledEdit22.Text:=trim(ini.ReadString('MPControl','CloseAuto',LabeledEdit22.Text));
  LabeledEdit23.Text:=trim(ini.ReadString('MPControl','ManualAuto',LabeledEdit23.Text));


  if not ini.ValueExists('config','APName') then
  begin
//    BitBtn4Click(nil);
  end;
  setwifiform_unit.CheckAndSetDefaultConfig();
  if not ini.ValueExists('config','VNCPass') then
  begin
    Button4Click(nil);
  end;

  ComboBox4.ItemIndex:=ini.ReadInteger('config','RFHW',ComboBox4.ItemIndex);

  SpinEdit1.Value:=ini.ReadInteger('config','SendTimeOut',SpinEdit1.Value);

  BitBtn5Click(nil);

//  BitBtn4Click(nil);
  Button4Click(nil);
  if strlst<>nil then
  sysutils.FreeAndNil(strlst);

end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  ini:Tinifile;
  i:integer;
  strlst:TStringList;
  fn:string;
  s:String;
  p:TPoint;
  c:TGridColumn;
begin
  blAllowAllReg:=False;

  SetWiFiForm_Unit.APName:='TP-LINK';

  SpinEdit6.MaxValue:=-63;
  SendDataHisory:=TStringList.Create;
  DeviceList:=TThreadList.Create;
  DeviceList.DefName:='DeviceList';
  UserSendDev:=TThReadList.Create;
  UserSendDev.DefName:='UserSendDev';
  MsgLock:=TCriticalSection.Create;
  MsgLock.DefName:='MsgLock';

  DBGrid_lv1._SetDataGrid;
  DBGrid_lv1.RowCount:=1;
  DBGrid_lv1.FixedRows:=1;
  DBGrid_lv1._AddCol('ID','ID',32);
  DBGrid_lv1._AddCol('Model','型号',110);
  DBGrid_lv1._AddCol('Count','次数',30,taCenter);
  DBGrid_lv1._AddCol('Reg','入网',30,taCenter);
  c:=DBGrid_lv1._AddCol('Tel','电话',30,taCenter);
//  c.Font.Bold:=true;
//  C.f
  DBGrid_lv1._AddCol('IMEI','IMEI',126);
  DBGrid_lv1._AddCol('IMSI','IMSI',126);
  DBGrid_lv1._AddCol('LastTime','最后活动',65);
  DBGrid_lv1._AddCol('DeviceInfo','DeviceInfo').Visible:=False;

  DBGrid_lv2._SetDataGrid;
  DBGrid_lv2._AddCol('ID','ID',32);
  DBGrid_lv2._AddCol('Model','型号',110);
  DBGrid_lv2._AddCol('Count','次',20,taCenter);
  DBGrid_lv2._AddCol('Tel','电话',32,taCenter);
  DBGrid_lv2._AddCol('IMEI','IMEI',126);
  DBGrid_lv2._AddCol('IMSI','IMSI',126);
  DBGrid_lv2._AddCol('LastTime','最后活动',65);
  DBGrid_lv2._AddCol('TMSI','TMSI',80);
  DBGrid_lv2._AddCol('DeviceInfo','DeviceInfo').Visible:=False;

//  self.DBGrid_lv1.SelectedColor:=clFuchsia;
//  self.DBGrid_lv2.SelectedColor:=clFuchsia;


  Memo7.Lines.Clear;
  Memo14.Lines.Clear;
  Memo14.WordWrap:=False;
  Memo4.WordWrap:=False;
  Memo2.WordWrap:=False;
  Memo3.WordWrap:=False;

  memo7.Lines.LineBreak:=#13#10;

//  self.ListView1.OnClick


  self.ResetBTSTime:=0;
  DateTimePicker1.DateTime:=now;
  DateTimePicker1.Date:=Date;
  DateTimePicker1.Time:=Time;
  Memo11.Lines.Clear;

  Label31.Caption:='';

  SMSblockList:=TStringList.Create;
  SMSblockList.Delimiter:=',';

  strlst:=TStringlist.Create;
  //block sms list
  strlst.Clear;
  strlst.AddStrings(Memo12.Lines);
  for i := strlst.Count-1 downto 0 do
  begin
    s:=trim(strlst.Strings[i]);
    if s='' then
    begin
      strlst.Delete(i);
      system.Continue;
    end;
    if (s[1] in ['#',';','!','/','%','-']) then
    strlst.Delete(i);
  end;

  SMSblockList.DelimitedText:=strlst.Text;
  for i := SMSblockList.Count-1 downto 0 do
  begin
    s:=trim(SMSblockList.Strings[i]);
    s:=sysutils.LowerCase(s);

    if (s='') then
    begin
      SMSblockList.Delete(i);
      system.Continue;
    end;
    SMSblockList.Strings[i]:=s;
  end;
//  SMSblockList.SaveToFile('/tmp/a.txt');

   //tel block list
  TelblockList:=TStringList.Create;
  strlst.Clear;
  strlst.AddStrings(Memo13.Lines);
  for i := strlst.Count-1 downto 0 do
  begin
    s:=trim(strlst.Strings[i]);
    if s='' then
    begin
      strlst.Delete(i);
      system.Continue;
    end;
    if not (s[1] in ['0'..'9','+',',']) then
    strlst.Delete(i);
  end;

  self.TelblockList.DelimitedText:=strlst.Text;
  for i := TelblockList.Count-1 downto 0 do
  begin
    s:=trim(TelblockList.Strings[i]);
    s:=sysutils.LowerCase(s);

    if (s='') then
    begin
      TelblockList.Delete(i);
      system.Continue;
    end;
    if s[1]='0' then
    begin
      delete(s,1,1);
    end;
    if s='' then
    begin
      TelblockList.Delete(i);
      system.Continue;
    end;

  end;

//  TelblockList.SaveToFile('/tmp/b.txt');

  LabeledEdit4.Text:='';
  LabeledEdit8.Text:='';
  LabeledEdit9.Text:='';

  Createok:=False;
  Edit10.Text:='';
  Edit11.Text:='';
  Edit12.Text:='';
//  Edit13.Text:='';
  Edit14.Text:='';
  Memo8.Lines.Clear;
  Edit5.ReadOnly:=true;   //macid

//  Edit3.Text:='';
  Memo2.Lines.Clear;
  Memo3.Lines.Clear;

//  listview1.Items.Clear;
//  listview2.Items.Clear;

  Edit10.Text:='';
  Edit11.Text:='';
  Edit12.Text:='';
//  Edit13.Text:='';
  Edit14.Text:='';
//  application.OnException:=ExceptionEvent;

  Edit6.Text:='';


  if not dmunit.DataModule1.ConectDB then
  exit;

  if not isMySysBoard then
  begin
    showmessage('不兼容/无线电板没有插上/加密狗无效/系统文件损坏, 请检查硬件 ');
    halt;
    exit;
  end;

  if not CheckSysData then
  begin
    showmessage('初始化失败，可能原因:'#10'1.数据库损坏,2.无线模块死机，3.系统损坏，'#10'请尝试关机，拨掉无线模块电源，等几分种，再开机。如还不行，联系卖家售后!');

    if application.MessageBox('是否重启系统？',nil, MB_YESNO) = ID_YES then
    begin
      ReBoot;
    end;
//    exit;
    halt;

  end;

  try
  ReadConfig;
  except
  end;

  BitBtn5Click(nil);
  try
  CheckBox4Click(nil);
  except
  end;

  {$ifndef m_tmp}
  LabeledEdit1.Text:=GetMacID;
  LabeledEdit3.Text:=GetSoftVer;
  LabeledEdit2.Text:=GetBuyDate;
  {$else}
  LabeledEdit1.Text:='';
  LabeledEdit3.Text:='';
  LabeledEdit2.Text:='';
  GroupBox7.Visible:=false;
  GroupBox8.Visible:=false;
  GroupBox6.Visible:=false;
  TabSheet16.TabVisible:=false;
  {$endif}

  Label12.Caption:=inttostr(GetHWCount);
  self.PageControl1.ActivePageIndex:=0;
  self.PageControl2.ActivePageIndex:=0;
  PageControl3.ActivePageIndex:=0;
//  ComboBox1Change(nil);
  CreateOK:=True;
  BitBtn8Click(nil);
  Memo2Change(nil);
  TCPServer:=TTCPServer.Create;
  if not TCPServer.StartServer then
  begin
    s:=ServerAddr_APP+':'+inttostr(ServerPort_APP)+LineEnding+TCPServer.error;
    showmessage('TCPServer 启动失败'+LineEnding+s+LineEnding+'尝试等2分种，再开');
  end;
  TCPServer_ConsoleRedirect:=TTCPServer_ConsoleRedirect.Create;
  if not TCPServer_ConsoleRedirect.StartServer then
  begin
    s:=ServerAddr_APP_Log+':'+inttostr(ServerPort_APP_Log)+LineEnding+TCPServer.error;
    showmessage('TCPServerLog 启动失败'+LineEnding+s+LineEnding+'尝试等2分种，再开');
  end;

  Label30.Caption:=SelfIMEIList.DelimitedText;

  Label12.Caption:=inttostr(GetHWCount);
  if Param_WinPos<>'' then
  begin
    p:=GetA_B(Param_WinPos);
    if (p.X=0) and (P.Y=0) then
    begin
      self.Left:=0;
      self.Top:=0;
    end;
    if (p.X=-1) and (P.Y=-1) then
    begin
      self.Left:=(screen.DesktopWidth-self.Width) div 2;
      self.Top:=(screen.DesktopHeight-self.Height) div 2;
    end;
    if (p.X=-2) and (P.Y=-2) then
    begin
      self.Left:=0;
      self.Top:=0;
      self.Width:=screen.DesktopWidth;
      self.Height:=screen.DesktopHeight;
    end;
    if (p.X>=0) or (P.Y>=0) then
    begin
      self.Left:=p.x;
      self.Top:=p.Y;
    end;
  end;

  if Param_WinSize<>'' then
  begin
    p:=GetA_B(Param_WinSize);
    if (p.X>=0) and (P.Y>=0) then
    begin
      self.Width:=p.x;
      self.Height:=p.Y;
    end;
  end;

  StartAsyncUpdateThread();
  CheckBox22.Checked:=CheckAutoRun(system.ParamStr(0),application.Title)>0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
//  dmunit.DataModule1.DeConectDB;
  self.DBGrid_userdb.DataSource.DataSet.Active:=false;
  self.DBGrid1.DataSource.DataSet.Active:=false;

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if not CreateOK then
  begin
    self.PageControl1.Enabled:=false;
    self.PageControl1.Visible:=False;
    self.Caption:='E';
    self.Caption:=self.Caption+'R';
    self.Caption:=self.Caption+'R';
    self.Caption:=self.Caption+'O';
    self.Caption:=self.Caption+'R';
  end;

  if blAutoStart=1 then
  begin
    BitBtn1Click(nil);
    blAutoStart:=-1;
  end;
end;

procedure TMainForm.GroupBox13Click(Sender: TObject);
begin
  if not self.Memo2.Focused then
  begin
    if (Sender=self.RadioButton2) or (Sender=self.RadioButton2) or (Sender=self.RadioButton3) then
    begin
    self.CheckBox1.Checked:=false;
    end;

  end;

  Memo2Change(nil);
end;

procedure TMainForm.ExceptionEvent(Sender: TObject; E: Exception);
begin

end;

function TMainForm.GetCharMode:integer;
var
  w:WideString;
  s:ansistring;
  e:boolean;
begin
  Result:=1;
  e:=false;
  w:=Memo2.Lines.Text;
  s:=Memo2.Lines.Text;
  if length(s)=length(w) then
  e:=true;


  if not e then
  begin
    RadioButton3.Checked:=true;
    RadioButton1.Checked:=False;
    RadioButton2.Checked:=False;

    RadioButton1.Enabled:=False;
    RadioButton2.Enabled:=False;
  end
  else
  begin
    RadioButton1.Enabled:=True;
    RadioButton2.Enabled:=True;
    if CheckBox1.Checked then
    begin
      RadioButton1.Checked:=True;
      RadioButton3.Checked:=false;
      RadioButton2.Checked:=False;
    end;
  end;
  if RadioButton1.Checked then
  Result:=0;
  if RadioButton2.Checked then
  Result:=4;
  if RadioButton3.Checked then
  Result:=8;

end;

function TMainForm.GetCharLen(all:Boolean):integer;
begin
Result:=70;
if all then
begin
  case self.GetCharMode of
    0:Result:=160;
    4:Result:=140;
    8:Result:=70;
  end;
end
else
begin
  case self.GetCharMode of
    0:Result:=length(Memo2.Lines.Text);
    4:Result:=length(Memo2.Lines.Text);
    8:Result:=length(WideString(Memo2.Lines.Text));
  end;
end;

end;

procedure TMainForm.Memo2Change(Sender: TObject);
var
  s:ansistring;
  a,b:integer;
begin
  s:=memo2.Lines.Text;
//  Label23.Caption:=inttostr(length(s));
  if length(s)=length(WideString(s)) then
  begin
    CheckBox1.Enabled:=True;
    RadioButton1.Enabled:=True;
    RadioButton2.Enabled:=True;
    RadioButton3.Enabled:=True;
  end
  else
  begin
    CheckBox1.Enabled:=True;
    RadioButton1.Enabled:=True;
    RadioButton2.Enabled:=True;
    RadioButton3.Enabled:=True;
  end;
  a:=self.GetCharLen(False);
  b:=self.GetCharLen(True);

  Label46.Caption:=inttostr(a)+'/'+inttostr(b);
  self.Button2.Enabled:=a<=b;

end;

procedure TMainForm.Memo2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key=13) and (shift=[ssCtrl]) then
  begin
    key:=0;
    Button2Click(nil);
  end;
end;

procedure TMainForm.MenuItem4Click(Sender: TObject);
begin
  self.MsgLock.Enter;
    self.DBGrid_lv1.BeginUpdate;
    self.DBGrid_lv1._Clear;
    self.ListAllDevice(self.DBGrid_lv1,False);
    self.DBGrid_lv1.EndUpdate();
  self.MsgLock.Leave;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin
DateTimePicker1.DateTime:=now;
DateTimePicker1.Date:=Date;
DateTimePicker1.Time:=Time;
if PageControl1.ActivePage=TabSheet6 then
begin
  try
  Label12.Caption:=inttostr(GetHWCount);
  except
  end;
  try
  BitBtn5Click(nil);
  except
  end;
end;
if PageControl1.ActivePage=TabSheet11 then
begin
  memo7.SelStart:=length(memo7.Text);
  try
  Label12.Caption:=inttostr(GetHWCount);
  except
  end;
end;

end;

procedure TMainForm.PageControl3Change(Sender: TObject);
begin
  if PageControl3.ActivePage=TabSheet16 then
  begin
    try
    Label12.Caption:=inttostr(GetHWCount);
    except
    end;
  end;
end;

procedure TMainForm.PageControl4Change(Sender: TObject);
begin

  DBGrid_lv1Selection(nil,-1,dbgrid_lv1.Row);
end;

procedure TMainForm.SpinEdit6Change(Sender: TObject);
begin
  SpinEdit6.Value:=Min(SpinEdit6.Value,SpinEdit6.MaxValue);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
//  Label40.Enabled:=false;
//  Label25.Enabled:=false;
    Label40.Visible:=false;
    Label25.Visible:=false;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
var
  t:TDateTime;
begin
  t:=now;
  Label28.Caption:=sysutils.FormatDateTime('yyyy-MM-dd',T)+' '+sysutils.FormatDateTime('HH:nn:ss',T);


end;

procedure TMainForm.Timer3Timer(Sender: TObject);
var
  lst:TList;
  i:integer;
  di2:TDeviceInfo;
  procedure UpdateList(StrGrd:TStringGrid);
  var
    i:integer;
  begin
    for i := 1 to StrGrd.RowCount-1 do
    begin
      di2:=StrGrd._GetValue_Pointer(i,'DeviceInfo');
      if di2=nil then
      system.Continue;
      if lst.IndexOf(di2)=-1 then
      system.Continue;

      StrGrd._SetValue(i,'LastTime',Time2Str(now-di2.LastTime));
    end;
  end;

begin
  self.MsgLock.Enter;
  lst:=self.DeviceList.LockList;
  try
    UpdateList(self.DBGrid_lv1);
    UpdateList(self.DBGrid_lv2);
  finally
    self.DeviceList.UnlockList;
    self.MsgLock.Leave;
  end;



end;

procedure TMainForm.Timer_ResetBTSTimer(Sender: TObject);
var
  t1:TDateTime;
  T2:TDateTime;
begin
T1:=self.ResetBTSTime+SpinEdit2.Value*dateutils.OneMinute;
  if CheckBox7.Checked then
  begin
    t2:=T1-Now;
    T2:=Max(0,T2);
    if T2>=1 then
    Label31.Caption:='基站重启倒计时   '+inttostr(system.trunc(T2))+' 天 '+sysutils.FormatDateTime('HH:nn:ss',T2)+'    '
    else
    Label31.Caption:='基站重启倒计时   '+sysutils.FormatDateTime('HH:nn:ss',T2)+'    '
  end
  else
  begin
    Label31.Caption:='';
    self.Timer_ResetBTS.Enabled:=false;
  end;

  if Now>T1 then
  begin
//    Label31.Caption:='';
//    self.Timer_ResetBTS.Enabled:=false;
    if not CheckBox7.Checked then
    begin
      Label31.Caption:='';
      Label31.Visible:=False;
      exit;
    end;
    if not BitBtn1.Enabled then
    begin
      BitBtn2Click(nil);
      sleep(10000);
      BitBtn1Click(nil);
      self.ResetBTSTime:=now;
    end;
  end;
end;

procedure TMainForm.Timer_SENDTimer(Sender: TObject);
begin
  //
  self.ExecutePlan(false);

end;

procedure TMainForm.ToolButton10Click(Sender: TObject);
var
  frm:TFindDeviceForm;
  var
    imei,model,imsi:string;
    b:boolean;
begin
  b:=false;
  frm:=TFindDeviceForm.Create(self);
  if frm.ShowModal=mrok then
  begin
    b:=true;
    imei:=trim(frm.IMEI.Caption);
    imsi:=trim(frm.IMSI.Caption);
    model:=trim(frm.Model.Caption);
  end;
  sysutils.FreeAndNil(frm);
  if not b then
  exit;
  if (imsi='') and (imei='') and (model='') then
  exit;

  if imei<>'' then
  begin
    DBGrid_lv1._Locate('IMEI',IMEI);
    exit;
  end;

  if IMSI<>'' then
  begin
    DBGrid_lv1._Locate('IMSI',IMSI);
    exit;
  end;

  if model<>'' then
  begin
    DBGrid_lv1._Locate('Model',model);
    exit;
  end;


end;

procedure TMainForm.Button4Click(Sender: TObject);
  var
  s1,s2:string;
  a,b:String;
begin
  b:='';
  if Sender<>nil then
  begin
    if application.MessageBox('是否真的要修改VNC连接密码？如果输错或忘记密码，无法恢复!!','警告',MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)<>ID_YES then
    exit;

    s1:='你将要设置VNC连接密码为「%s」 ，是否真的继续？';
    s2:=sysutils.Format(s1,[Edit9.Text]);

    if application.MessageBox(PChar(s2),'警告',MB_YESNO+MB_ICONQUESTION)<>ID_YES then
    exit;


    s1:='修改成功,下次开机生效，你的VNC连接密码为「%s」,请牢记!!';
    s2:=sysutils.Format(s1,[Edit9.Text]);

  end;

   //todo:    修改VNC密码
   a:=edit9.Text;

   a:='gsettings set org.gnome.Vino vnc-password "'+EncodeStringBase64(a)+'"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino authentication-methods "[''none'']"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino enabled "true"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino notify-on-connect "false"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino prompt-enabled "false"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino use-upnp "false"';
   RunCommand(a,b);
   a:='gsettings set org.gnome.Vino view-only "false"';
   RunCommand(a,b);
//   a:='gsettings set org.gnome.Vino icon-visibility "never"';

//   a:='gsettings set org.gnome.Vino require-encryption "false"';


   Vncpasswd(edit9.Text);

   self.SaveConfig(True);

  if sender<>nil then
  begin
    if application.MessageBox(PChar(s2),'警告',MB_OK+MB_ICONINFORMATION)<>ID_YES then
    exit;
  end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
var
  s:AnsiString;
  v:String;
begin
//date -s "2015-08-29 08:42:17"
//Button5

//if MessageDlg('短信中有基站时间截，为防止短信猫检测时间，请设置正确的时间'+LineEnding+'是否继续设置你指定的值？', mtConfirmation, [mbOK, mbCancel],0) <> mrOk then
//exit;

s:=sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',DateTimePicker1.DateTime);
s:='date -s "'+s+'"';
process.RunCommand(s,v);

end;

procedure TMainForm.Button6Click(Sender: TObject);
var
  strlst,strlst2:TStringList;
  i:integer;
  s:string;
  qry:TDataSet;
  a,b:integer;
  function likeStr(field:String;val:string):string;
  begin
    Result:='('+field+' like '+sysutils.QuotedStr('%'+val+'%')+')';
  end;

  function likeStr2(field1,field2:string;val:string):string;
  begin
    Result:='('+likeStr(field1,val)+') or ('+ likeStr(field2,val)+')';
  end;
begin
  //
  try
  LabeledEdit4.Text:=trim(LabeledEdit4.Text);
  LabeledEdit8.Text:=trim(LabeledEdit8.Text);
  LabeledEdit9.Text:=trim(LabeledEdit9.Text);

  strlst:=TStringList.Create;
  strlst2:=TStringList.Create;
  if LabeledEdit4.Text<>'' then
  begin
    strlst.Add(likeStr('IMEI',LabeledEdit4.Text));
  end;
  if LabeledEdit8.Text<>'' then
  begin
    strlst.Add(likeStr('IMSI',LabeledEdit8.Text));
  end;
  if LabeledEdit9.Text<>'' then
  begin
    strlst.Add(likeStr('Model',LabeledEdit9.Text));
  end;
  if CheckBox9.Checked then
  begin
    strlst.Add('(Modem=1)');
  end;
  if RadioButton7.Checked then
  begin
//    s:=sysutils.FormatDateTime('yyyy-MM-dd',now-7);
//    strlst.Add('(LastTime>='+sysutils.QuotedStr(s) +')');
    s:=sysutils.FloatToStr(now-7);
    strlst.Add('(LastTime>='+s +')');
  end;
  if RadioButton8.Checked then
  begin
    //s:=sysutils.FormatDateTime('yyyy-MM-dd',now-31);
//    strlst.Add('(LastTime>='+sysutils.QuotedStr(s) +')');
    s:=sysutils.FloatToStr(now-31);
    strlst.Add('(LastTime>='+s +')');
  end;

  if CheckBox17.Checked then
  begin
    strlst.Add('((TMSI<>'''') AND (TMSI IS NOT NULL))');
  end;

  if CheckBox18.Checked then
  begin
    strlst.Add('((Model='''') or (Model is NULL))');
  end;

  for i := 0 to strlst.Count-1 do
  begin
    if strlst2.Count=0 then
    strlst2.Add(strlst.Strings[i])
    else
    strlst2.Add(' and '+ strlst.Strings[i]);
  end;

  strlst.Clear;

  strlst.Add('select * from devinfo ');
  if strlst2.Count>0 then
  strlst.Add(' where '+strlst2.Text);

  strlst.Add(' order by LastTime Desc');
  except
    exit;
  end;


  dmunit.DataModule1.LockCS(true);
  dmunit.DataModule1.qry_devinfo.DisableControls;
  try
    dmunit.DataModule1.qry_devinfo.Close;
    dmunit.DataModule1.qry_devinfo.SQL:=strlst.Text;
    dmunit.DataModule1.qry_devinfo.Open;
//    s:=inttostr(dmunit.DataModule1.qry_devinfo.RecordCount);
//    self.Caption:=s;
  finally
    dmunit.DataModule1.UnLockCS(true);
    dmunit.DataModule1.qry_devinfo.EnableControls;
  end;
  sysutils.FreeAndNil(strlst);
  sysutils.FreeAndNil(strlst2);

qry:=self.DBGrid4.DataSource.DataSet;
StatusBar2.Panels.Items[1].Text:=inttostr(qry.RecordCount);
qry.DisableControls;
qry.First;
a:=0;
b:=0;
while not qry.EOF do
begin
if qry.FieldByName('Modem').AsBoolean then
inc(a);

if (qry.FieldByName('Model').IsNull) or (qry.FieldByName('Model').AsString='') then
inc(b);

qry.Next;
end;
qry.First;
qry.EnableControls;
self.StatusBar2.Panels.Items[3].Text:=inttostr(a);
self.StatusBar2.Panels.Items[5].Text:=inttostr(b);


end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
  xrandr_ReActiveDisplay('1920x1080');
end;

procedure TMainForm.Button8Click(Sender: TObject);
var
  qry:TDataSet;
  R:integer;
  strlst:TStringList;
  s:String;
begin
  if not SaveDialog_SQL.Execute then
  exit;

  ProgressBar2.Position:=0;
  ProgressBar2.Visible:=true;

  strlst:=TStringList.Create;
  strlst.Clear;
  strlst.Add('');

qry:=dmunit.DataModule1.GetNewDataset(False,'select * from imei');
qry.First;

ProgressBar2.Max:=qry.RecordCount;
ProgressBar2.Position:=0;
while not qry.EOF do
begin
  s:='INSERT INTO "imei" (Modem,tac,fac,corp,model,inter_model) VALUES( ';

  if qry.FieldByName('Modem').AsBoolean then
  s:=s+'1'
  else
  s:=s+'0';

  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('tac').AsString)+' ';
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('fac').AsString);
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('corp').AsString);

  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('model').AsString);
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('inter_model').AsString);
  s:=s+' );';

  ProgressBar2.Position:=qry.RecNo;
  if qry.RecNo mod 5=0 then
  ProgressBar2.Repaint;

  strlst.Add(s);

  qry.Next;

end;
sysutils.FreeAndNil(qry);

ProgressBar2.Visible:=false;
DataFile_Unit.StrLst2DataFile(strlst,self.SaveDialog_SQL.FileName,'SYSDB.IMEI');

sysutils.FreeAndNil(strlst);


end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
  xrandr_ReActiveDisplay('1280x720');
end;

procedure TMainForm.CheckBox10Click(Sender: TObject);
begin
  Timer_SEND.Enabled:=CheckBox10.Checked;
  self.ExecutePlan

end;

procedure TMainForm.CheckBox16Click(Sender: TObject);
begin
  FixSmscTimeToLocalTime:=CheckBox16.Checked;
end;

procedure TMainForm.CheckBox20Click(Sender: TObject);
begin
  self.blAllowAllReg:=self.CheckBox20.Checked;
end;

procedure TMainForm.CheckBox22Click(Sender: TObject);
begin
  if not self.Showing then
    exit;
    SetAutoRun(system.ParamStr(0),application.Title,self.CheckBox22.Checked);
end;

procedure TMainForm.CheckBox3Click(Sender: TObject);
var
  i:integer;
  lst:TList;
  di:TDeviceInfo;
begin
lst:=self.DeviceList.LockList;
for i := 0 to lst.count-1 do
begin
  di:=TDeviceInfo(lst.Items[i]);
//  if di.modem_DB or di.modem_user then
//  TDeviceInfo(lst.Items[i]).AllowReg:=CheckBox3.Checked;

end;
self.DeviceList.UnlockList;

end;

procedure TMainForm.CheckBox4Click(Sender: TObject);
var
  s:String;
  loc:string;
begin
  loc:='';
  dmunit.DataModule1.LockCS(False);
  self.DBGrid1.BeginUpdate;
  dmunit.DataModule1.qry_sys_imei.DisableControls;
  try
  if dmunit.DataModule1.qry_sys_imei.Active then
  begin
    if dmunit.DataModule1.qry_sys_imei.RecNo<>-1 then
    loc:=dmunit.DataModule1.qry_sys_imei.FieldByName('corp').AsString;
    dmunit.DataModule1.qry_sys_imei.Active:=False;
  end;

  dmunit.DataModule1.qry_sys_imei.SQLList.Clear;
  dmunit.DataModule1.qry_sys_imei.SQLList.Add('select corp,count(*) as c from imei ');
  s:='select count(*) as c from imei ';

  if CheckBox4.Checked then
  begin
    dmunit.DataModule1.qry_sys_imei.SQLList.Add(' where Modem=1 ');
    s:=s+' where Modem=1 ';
  end;
  dmunit.DataModule1.qry_sys_imei.SQLList.Add(' group by corp order by c desc,corp');
//  dmunit.DataModule1.qry_sysimeiinfo.SQL.SaveToFile('/tmp/sql.txt');
  dmunit.DataModule1.qry_sys_imei.SQL:=dmunit.DataModule1.qry_sys_imei.SQLList.Text;
  dmunit.DataModule1.qry_sys_imei.Open;
  Label52.Caption:=dmunit.DataModule1.GetValueDB(s,'c',false);

  //if loc<>'' then
//  dmunit.DataModule1.qry_sys_imei.Locate('corp',loc,[]);
  except
  end;

  dmunit.DataModule1.qry_sys_imei.EnableControls;
  self.DBGrid1.EndUpdate();
  dmunit.DataModule1.UnLockCS(False);
end;

procedure TMainForm.chkOnlyModemChange(Sender: TObject);
begin
  BitBtn16Click(nil);
end;

procedure TMainForm.WriteLog(str:string);
begin
  self.Memo7.Lines.Add(str);
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
var
  ini:Tinifile;
  s:String;
  i:integer;
  cmdline:string;
  fn:string;
begin
  if ComboBox3.Text='' then
  begin
    if Sender<>nil then
    showmessage('请设置网络名，中国移动是"CMCC",其它国家地区，请把手机设成英文(水货手机更好)，手动查找网络时，通常的会显示网络名');
    exit;
  end;
  if Sender<>nil then
  begin
    s:=trim(LabeledEdit6.Text);
    if s<>'' then
    begin
      if s[1]='+' then
      delete(s,1,1);

      for i := 1 to length(s) do
      begin
        if not (s[i] in ['0'..'9']) then
        begin
          showmessage('短信中心，号码格式错误');
          exit;
        end;
      end;
    end;
  end;

  BitBtn2Click(nil);
  s:='';
  RunCommand('chmod a+sx /usr/local/bin/yate',s);
  fn:=sysutils.ExtractFilePath(system.ParamStr(0))+'ConsoleRedirect';
  if sysutils.FileExists(fn) then
  begin
    s:='chmod a+sx "'+fn+'"';
    RunCommand(s ,s);
  end;
  s:='/usr/local/etc/yate/tmsidata.conf';
  if sysutils.FileExists(s) then
  begin
    sysutils.DeleteFile(s);
  end;


  self.SaveConfig();

  if CheckBox14.Checked then
  cmdline:='yate -vvvvvvvvvvvvvvv'
  else
  cmdline:='yate -vv';
//  WriteLog('===========启动基站===========');
  s:='';
//  RunCommand(cmdline,s);
  if sysutils.FileExists(fn) then
  begin
    cmdline:=fn+' /Exec "'+cmdline+'" /Dest:127.0.0.1:7788';
  end;



  s:='';

  s:='';

  YateProc:=TProcess.Create(nil);
//  YateProc.CommandLine:='yate -d -t -l /tmp/ya.txt';
  YateProc.Options:=YateProc.Options+[poNoConsole];
  YateProc.CommandLine:=cmdline;

  YateProc.Environment.Add('LANG=en');
  YateProc.Environment.Add('LANGUAGE=en');
  WriteLog('===========启动基站===========');
  YateProc.Execute;



//  SpinEdit2.Enabled:=False;
  Panel7.Enabled:=False;
  Label21.Enabled:=false;
//  CheckBox7.Enabled:=True;
  if CheckBox7.Checked then
  begin
    Label31.Visible:=True;
  end;

  CheckBox6.Enabled:=false;

  BitBtn2.enabled:=True;
  BitBtn1.enabled:=False;
  Label17.Enabled:=False;
  SpinEdit5.Enabled:=False;
  SpinEdit4.Enabled:=False;
  Label23.Enabled:=false;
  Label35.Enabled:=false;
  SpinEdit7.Enabled:=false;
  SpinEdit6.Enabled:=false;
  Label34.Enabled:=false;
  LabeledEdit6.Enabled:=False;
  LabeledEdit7.Enabled:=False;

  SpinEdit8.Enabled:=false;
  Label49.Enabled:=false;
  SpinEdit9.Enabled:=false;
  Label50.Enabled:=false;


  blBtsRun:=True;
  ResetBTSTime:=now;
  if sender<>nil then
  begin
    if CheckBox7.Checked then
    Timer_ResetBTS.Enabled:=True;
  end;

end;

procedure TMainForm.BitBtn10Click(Sender: TObject);
begin
  Memo3.Lines.Clear;
end;

procedure TMainForm.UpdateUserSet(IMEI:String;Model:string;UserModem:Boolean);
var
  lst:TList;
  i,l1,l2:integer;
  di:TDeviceInfo;
  s:string;
begin
l1:=length(imei);
if l1>14 then
begin
  l1:=14;
  setlength(imei,14);
end;

lst:=self.DeviceList.LockList;
for i := 0 to lst.Count-1 do
begin
  di:=TDeviceInfo(lst.Items[i]);
  s:=copy(di.IMEI,l1);
  if s<>imei then
  system.Continue;

  di.modem_User:=UserModem;
  if model<>'' then
  di.Model:=Model;
end;
self.DeviceList.UnlockList;


end;


procedure TMainForm.BitBtn11Click(Sender: TObject);
var
  d:TDataSet;
  frm:TUserImeiSetForm;
begin
  d:=self.DBGrid_userdb.DataSource.DataSet;

  if d.Active=false then
  d.Open;

  d.Append;
  d.FieldByName('Modem').AsBoolean:=False;
  frm:=TUserImeiSetForm.Create(self);
  if frm.ShowModal=mrok then
  begin
    d.FieldByName('Tac').Value:=frm.Edit1.Text;
    d.FieldByName('model').Value:=frm.Edit2.Text;
    if frm.CheckBox1.Checked then
    d.FieldByName('Modem').Value:=1
    else
     d.FieldByName('Modem').Value:=0;

    d.Post;
    dmunit.DataModule1.LockCS(True);
    dmunit.DataModule1.ApplyUpdates(d);
    dmunit.DataModule1.UnLockCS(False);
    UpdateUserSet(frm.Edit1.Text,frm.Edit2.Text,frm.CheckBox1.Checked);
    UpdataDevinfoDB(frm.Edit1.Text,frm.Edit2.Text,frm.CheckBox1.Checked);
  end
  else
  begin
    d.Cancel;
  end;
  sysutils.FreeAndNil(frm);

end;

procedure TMainForm.BitBtn12Click(Sender: TObject);
var
  d:TDataSet;
  frm:TUserImeiSetForm;
begin
  Dmunit.DataModule1.CS_UsrDB.Enter;
  try
  d:=self.DBGrid_userdb.DataSource.DataSet;
  if d.Active=false then
  d.Open;

  if d.RecNo=-1 then
  exit;

  d.Edit;
  frm:=TUserImeiSetForm.Create(self);
  frm.Edit1.Text:=d.FieldByName('Tac').AsString;
  frm.Edit2.Text:=d.FieldByName('model').AsString;
  frm.CheckBox1.Checked:=d.FieldByName('Modem').AsInteger=1;
  if frm.ShowModal=mrok then
  begin
    d.FieldByName('Tac').Value:=frm.Edit1.Text;
    d.FieldByName('model').Value:=frm.Edit2.Text;
    if frm.CheckBox1.Checked then
    d.FieldByName('Modem').Value:=1
    else
    d.FieldByName('Modem').Value:=0;
    d.Post;

    dmunit.DataModule1.LockCS(True);
    dmunit.DataModule1.ApplyUpdates(d);
    dmunit.DataModule1.UnLockCS(True);
    UpdateUserSet(frm.Edit1.Text,frm.Edit2.Text,frm.CheckBox1.Checked);

    UpdataDevinfoDB(frm.Edit1.Text,frm.Edit2.Text,frm.CheckBox1.Checked);
  end
  else
  d.Cancel;

  finally
    Dmunit.DataModule1.CS_UsrDB.Leave;
  end;
  if frm<>nil then
  sysutils.FreeAndNil(frm);

end;

procedure TMainForm.BitBtn13Click(Sender: TObject);
var
  s:string;
  d:TDataSet;
begin
d:=self.DBGrid_userdb.DataSource.DataSet;
if not d.Active then
exit;
if d.RecNo=-1 then
exit;

s:=format('是否删除IMEI: %s, 名称: %s 的项？',[d.FieldByName('tac').AsString,d.FieldByName('model').AsString]);

  if application.MessageBox(PChar(s),nil,MB_YESNO+MB_ICONQUESTION)<>ID_YES then
  exit;
  s:=d.FieldByName('tac').AsString;

  UpdateUserSet(s,'',False);

//  dmunit.DataModule1.ExecSQL('delete from imei_user where tac='+sysutils.QuotedStr(s),true);

  d.Delete;

  dmunit.DataModule1.LockCS(True);
  dmunit.DataModule1.ApplyUpdates(d);
  dmunit.DataModule1.UnLockCS(True);
end;

procedure TMainForm.BitBtn14Click(Sender: TObject);
var
  s:string;
  d:TDataSet;
begin
  d:=self.DBGrid_userdb.DataSource.DataSet;
  if not d.Active then
  exit;
  if d.RecNo=-1 then
  exit;

  if application.MessageBox('是否清空串号定义表？',nil,MB_YESNO+MB_ICONWARNING+MB_DEFBUTTON2)<>ID_YES then
  exit;
  dmunit.DataModule1.LockCS(True);
  d.Active:=false;
  Dmunit.DataModule1.ExecSQL('delete from imei_user',true);
  d.Open;
  dmunit.DataModule1.LockCS(False);
end;

procedure TMainForm.BitBtn15Click(Sender: TObject);
begin
if application.MessageBox('是否清空入网列表，清空后，可通过刷新恢复',nil,MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)<>ID_YES then
exit;

self.MsgLock.Enter;
  self.DBGrid_lv2._Clear;
self.MsgLock.Leave;

end;

procedure TMainForm.BitBtn16Click(Sender: TObject);
begin
  self.ListAllDevice(self.DBGrid_lv2,true,chkOnlyModem.Checked);
end;

procedure TMainForm.UpdataDevinfoDB(imei,model:string;modem:Boolean);
var
  strlst:TStringList;
begin
  strlst:=TStringList.Create;

  strlst.Add('update devinfo set ');
  if modem then
  strlst.Add('Modem=1')
  else
  strlst.Add('Modem=0');

  strlst.Add(',Model='+sysutils.QuotedStr(model));

  strlst.Add(' where ');

  if length(imei)=8 then
  strlst.Add('substr(IMEI,1,8)='+sysutils.QuotedStr(imei))
  else
  strlst.Add('IMEI='+sysutils.QuotedStr(imei));

  strlst.Add(';');

  dmunit.DataModule1.ExecSQL(strlst.Text,true);
  sysutils.FreeAndNil(strlst);

end;

procedure TMainForm.BitBtn17Click(Sender: TObject);
var
  qry:TDataSet;
  R:integer;
  m:boolean;
  s:string;
  tac:string;
  imei:String;
  corp:string;
begin
  qry:=DBGrid_userdb.DataSource.DataSet;
  R:=qry.RecNo;
  qry.First;
  self.ProgressBar1.Visible:=true;
  self.ProgressBar1.Max:=qry.RecordCount;
  while not qry.EOF do
  begin
    m:=qry.FieldByName('Modem').AsBoolean;
    s:=qry.FieldByName('model').AsString;
    Tac:=qry.FieldByName('Tac').AsString;
    self.ProgressBar1.Position:=qry.RecNo;
    if (qry.RecNo mod 10=0) then
    self.ProgressBar1.Repaint;

    UpdataDevinfoDB(tac,s,m);

    qry.Next;
  end;
    if R>0 then
    qry.RecNo:=R;
    self.ProgressBar1.Position:=0;

    qry:=nil;

  qry:=dmunit.DataModule1.GetNewDataset(False,'select * from imei');
  qry.First;
  self.ProgressBar1.Visible:=true;
  self.ProgressBar1.Max:=qry.RecordCount;
  while not qry.EOF do
  begin
    m:=qry.FieldByName('Modem').AsBoolean;
    corp:=qry.FieldByName('corp').AsString;
    s:=corp+' '+qry.FieldByName('model').AsString;
    Tac:=qry.FieldByName('Tac').AsString;

    self.ProgressBar1.Position:=qry.RecNo;
    if (qry.RecNo mod 10=0) then
    self.ProgressBar1.Repaint;

    UpdataDevinfoDB(tac,s,m);

    qry.Next;

  end;
 self.ProgressBar1.Position:=0;
 self.ProgressBar1.Visible:=False;
 sysutils.FreeAndNil(qry);

end;

procedure TMainForm.BitBtn18Click(Sender: TObject);
var
  frm:TFindDeviceForm;
  var
    imei,model,imsi:string;
    b:boolean;
begin
  b:=false;
  frm:=TFindDeviceForm.Create(self);
  if frm.ShowModal=mrok then
  begin
    b:=true;
    imei:=trim(frm.IMEI.Caption);
    imsi:=trim(frm.IMSI.Caption);
    model:=trim(frm.Model.Caption);
  end;
  sysutils.FreeAndNil(frm);
  if not b then
  exit;
  if (imsi='') and (imei='') and (model='') then
  exit;

  if imei<>'' then
  begin
    DBGrid_lv2._Locate('IMEI',IMEI);
    exit;
  end;

  if IMSI<>'' then
  begin
    DBGrid_lv2._Locate('IMSI',IMSI);
    exit;
  end;

  if model<>'' then
  begin
    DBGrid_lv2._Locate('Model',model);
    exit;
  end;

end;

procedure TMainForm.BitBtn2Click(Sender: TObject);
var
  b,b2:boolean;
  s:string;
  lst:TList;
  i:integer;
  di:TDeviceInfo;
begin
  b:=false;
  try
  b2:=KillExec('ConsoleRedirect');
  b2:=KillExec('transceiver-bladerf');
  b2:=KillExec('transceiver-usrp1');
  b2:=KillExec('transceiver-uhd');
  b2:=KillExec('mbts');
  b:=KillExec('yate');

  if (self.BitBtn2.Enabled) or (Sender<>nil) then
  WriteLog('===========停止基站===========');

  ClearDataForBTSAbort_Start;
  //lst:=self.DeviceList.LockList;
  //for i := 0 to lst.Count-1 do
  //begin
  //  di:=TDeviceInfo(lst.Items[i]);
  //  di.isReg:=False;
  //end;
  //self.DeviceList.UnlockList;
  //self.ListAllDevice(self.DBGrid_lv1,False);
  //self.ListAllDevice(self.DBGrid_lv2,True);

  except
    b:=false;
  end;
  if sender<>nil then
  begin
    self.Timer_ResetBTS.Enabled:=False;
    self.Label31.Visible:=False;
  end;

  SpinEdit2.Enabled:=True;
  Panel7.Enabled:=True;
  Label21.Enabled:=True;
  CheckBox7.Enabled:=True;
  CheckBox6.Enabled:=True;
  Label17.Enabled:=True;
  SpinEdit5.Enabled:=True;
  SpinEdit4.Enabled:=True;
  Label23.Enabled:=True;
  Label35.Enabled:=True;
  SpinEdit7.Enabled:=True;
  SpinEdit6.Enabled:=True;
  Label34.Enabled:=True;
  LabeledEdit6.Enabled:=True;
  LabeledEdit7.Enabled:=True;

  blbtsRun:=False;
  BitBtn1.enabled:=True;
  BitBtn2.enabled:=False;

  SpinEdit8.Enabled:=true;
  Label49.Enabled:=true;
  SpinEdit9.Enabled:=true;
  Label50.Enabled:=true;

end;

procedure TMainForm.BitBtn3Click(Sender: TObject);
var
  c,i:integer;
  s:string;
  strlst:TStringList;
  b:Boolean;
begin
  Edit6.Text:=trim(Edit6.Text);
  s:=Edit6.Text;
  b:=false;

    if sysutils.SameText(s,'ShowHelp') then
    begin
        s:='======指令帮助======'#13#10;
        s:=s+'1.输入充值码，充值'#13#10;
        s:=s+'2.绑定/清除串号 命令，绑定/清除测试手机'#13#10;
        s:=s+'3.NoTelFilter[=0/1] 打开/临时关闭电话号码过滤'#13#10;
        s:=s+'4.NoKeyFilter[=0/1] 打开/临时关键词过滤'#13#10;
        s:=s+'5.DECC-xxx  直接扣除多少次，xxx用数字代替';

      ShowMessage(s);
      exit;
    end;

    b:=false;
    if sysutils.SameText(s,'NoTelFilter') then
    begin
      self.blNoTelFilter:=not self.blNoTelFilter;
      b:=true;
    end;
    if sysutils.SameText(s,'NoTelFilter=1') then
    begin
      self.blNoTelFilter:=true;
      b:=true;
    end;
    if sysutils.SameText(s,'NoTelFilter=0') then
    begin
      self.blNoTelFilter:=false;
      b:=true;
    end;

    if b then
    begin
//      self.CheckBox20.Checked:=self.blAllowAllReg;
      if self.blNoTelFilter then
        s:='当前已经临时关闭电话号码过滤，供测试，不要糊搞瞎搞！！'
        else
        s:='当前已经打开电话号码过滤';
        s:=s+#13#10;
        s:=s+'"NoTelFilter=1" 允许,"NoTelFilter=0" 关闭, '#13#10'单独"NoTelFilter"，乒乓键, 无引号，不区分大小写';

      ShowMessage(s);
      exit;
    end;

    b:=false;
    if sysutils.SameText(s,'NoKeyFilter') then
    begin
      self.blNoKeyFilter:=not self.blNoKeyFilter;
      b:=true;
    end;
    if sysutils.SameText(s,'NoKeyFilter=1') then
    begin
      self.blNoKeyFilter:=true;
      b:=true;
    end;
    if sysutils.SameText(s,'NoKeyFilter=0') then
    begin
      self.blNoKeyFilter:=false;
      b:=true;
    end;

    if b then
    begin
      //self.CheckBox20.Checked:=self.blAllowAllReg;
      if self.blNoKeyFilter then
        s:='当前已经临时关闭关键词过滤，供测试，不要糊搞瞎搞！！'
        else
        s:='当前已经打开关键词过滤';
        s:=s+#13#10;
        s:=s+'"NoKeyFilter=1" 允许,"NoKeyFilter=0" 关闭, '#13#10'单独"NoKeyFilter"，乒乓键, 无引号，不区分大小写';

      ShowMessage(s);
      exit;
    end;

  b:=false;
  if sysutils.SameText(s,'AllowAllReg') then
  begin
    self.blAllowAllReg:=not self.blAllowAllReg;
    b:=true;
  end;
  if sysutils.SameText(s,'AllowAllReg=1') then
  begin
    self.blAllowAllReg:=true;
    b:=true;
  end;
  if sysutils.SameText(s,'AllowAllReg=0') then
  begin
    self.blAllowAllReg:=false;
    b:=true;
  end;

  if b then
  begin
    self.CheckBox20.Checked:=self.blAllowAllReg;
    if self.blAllowAllReg then
      begin
        s:='当前已经临时允许所有手机都可入网，供测试，不要糊搞瞎搞！！';
        if CheckBox20.Visible<> true then
        CheckBox20.Visible:=true;
      end
      else
      begin
        s:='当前已关闭所有手机直接入网';
      end;
      s:=s+#13#10;
      s:=s+'"AllowAllReg=1" 允许,"AllowAllReg=0" 关闭, '#13#10'单独"AllowAllReg"，乒乓键, 无引号，不区分大小写';

    ShowMessage(s);
    exit;
  end;

  b:=false;
  if pos('DECC-',sysutils.UpperCase(s))=1 then
  begin
    delete(s,1,5);
    for i := 1 to length(s) do
    begin
      if not (s[i] in ['0'..'9']) then
      begin
        b:=true;
        system.Break;
      end;
    end;
    if not sysutils.TryStrToInt(s,c) then
    begin
       b:=true;
    end;
    if c<=0 then
    begin
      b:=true;
    end;
    if b then
    begin
      showmessage('减次数时,格式错误');
      exit;
    end;
    c:=abs(c);
    s:='是否减掉'+inttostr(c)+'次?减完/减错,只能充值才能增加次数';
    if application.MessageBox(pchar(s),nil,MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)<>ID_YES then
    exit;

    fununit.DecHwCount(c);
    Label12.Caption:=inttostr(GetHWCount);
    showmessage('减完,请检查次数');
    exit;

  end;
  s:=SYSutils.UpperCase(trim(edit6.Text));
  s:=copy(s,2,3);
  if sysutils.SameText('IME',s) then
  begin
    s:=trim(edit6.Text);
    s:=regunit.BindIMEI(s,Edit5.Text);
    if s='000000000000000' then
    begin
      showmessage('已清空绑定串号!');
      Label30.Caption:=SelfIMEIList.DelimitedText;
      exit;
    end;
    if s='' then
    begin
      showmessage('串号操作,错误!');
      exit;
    end;
    Label30.Caption:=SelfIMEIList.DelimitedText;
    showmessage('串号 '+s+' 操作成功!');
    exit;
  end;

  c:=DoReg(Edit6.Text,Edit5.Text);
  if c<=0 then
  begin
    if c=-100 then
    begin
      application.MessageBox('充值失败，建议重开程序，重新注册流程',nil,MB_OK+MB_ICONWARNING);
      exit;
    end;
    application.MessageBox('输入的充值码无效，请确认是否输错！',nil,MB_OK+MB_ICONWARNING);
    exit;
  end
  else
  begin
    BitBtn5Click(nil);
    s:=format('已成功充值 %d 次',[c]);
    application.MessageBox(pchar(s),nil,MB_OK+MB_ICONWARNING);
    Label12.Caption:=inttostr(GethwCount);
    Edit6.Text:='';
  end;

end;

procedure TMainForm.BitBtn4Click(Sender: TObject);
begin
  SetWiFiForm_Unit.TSetWiFiForm.Create(self).ShowModal;
end;

procedure TMainForm.BitBtn5Click(Sender: TObject);
var
  LastCount:integer;
  R:TRegHW;
begin
//  MacID:=
  if sender<>nil then
  begin
    if application.MessageBox('是否要手工刷新机器码？'#10'如果对应充值码还没有充值，请不要刷新或关机！！！','警告',MB_YESNO+MB_DEFBUTTON2+MB_ICONWARNING)<>ID_YES then
    exit;
    if application.MessageBox('如果刷新后，未充值的充值码失效，自己负责！！！'#10'是否要继续？','警告',MB_YESNO+MB_DEFBUTTON2+MB_ICONQUESTION)<>ID_YES then
    exit;
  end;
//
  Edit5.Text:=GetMacHWForReg();
//  Str2RegHW(edit5.Text,R);
//  Edit6.Text:=NewRegCode(10000,@R);

end;

procedure TMainForm.BitBtn6Click(Sender: TObject);
var
  strlst,strlst2:TStringList;
  i:integer;
  s:string;
  function likeStr(field:String;val:string):string;
  begin
    Result:='('+field+' like '+sysutils.QuotedStr('%'+val+'%')+')';
  end;

  function likeStr2(field1,field2:string;val:string):string;
  begin
    Result:='('+likeStr(field1,val)+') or ('+ likeStr(field2,val)+')';
  end;
begin
  //
  Edit10.Text:=trim(Edit10.Text);
  Edit11.Text:=trim(Edit11.Text);
  Edit12.Text:=trim(Edit12.Text);
  Edit14.Text:=trim(Edit14.Text);

  strlst:=TStringList.Create;
  strlst2:=TStringList.Create;
  if edit10.Text<>'' then
  begin
    strlst.Add(likeStr2('fromTel','ToTel',edit10.Text));
  end;
  if edit11.Text<>'' then
  begin
    strlst.Add(likeStr2('from_imsi','to_imsi',edit11.Text));
  end;
  if edit12.Text<>'' then
  begin
    strlst.Add(likeStr2('from_imsi','to_imei',edit12.Text));
  end;
  if edit14.Text<>'' then
  begin
    strlst.Add(likeStr('Text',edit14.Text));
  end;
  if RadioButton5.Checked then
  begin
    s:=sysutils.FormatDateTime('yyyy-MM-dd',now-7);
    strlst.Add('(Time>='+sysutils.QuotedStr(s) +')');
  end;
  if RadioButton5.Checked then
  begin
    s:=sysutils.FormatDateTime('yyyy-MM-dd',now-31);
    strlst.Add('(Time>='+sysutils.QuotedStr(s) +')');
  end;

  for i := 0 to strlst.Count-1 do
  begin
    if strlst2.Count=0 then
    strlst2.Add(strlst.Strings[i])
    else
    strlst2.Add(' and '+ strlst.Strings[i]);
  end;

  strlst.Clear;
//  strlst.Add('select '*' || substr(to_imei,7) as  to_imei2,'*' || substr(from_imei,7) as  from_imei2, *  from history');

  strlst.Add('select * from history ');
  if strlst2.Count>0 then
  strlst.Add(' where '+strlst2.Text);

  strlst.Add(' order by Time Desc');

//  strlst.SaveToFile('/tmp/a.txt');

  dmunit.DataModule1.LockCS(true);
  dmunit.DataModule1.qry_history.DisableControls;
  try
    dmunit.DataModule1.qry_history.Close;
    dmunit.DataModule1.qry_history.SQL:=strlst.Text;
    dmunit.DataModule1.qry_history.Open;
//    s:=inttostr(dmunit.DataModule1.qry_history.RecordCount);
//    self.Caption:=s;
  finally
    dmunit.DataModule1.UnLockCS(true);
    dmunit.DataModule1.qry_history.EnableControls;
  end;

end;

procedure TMainForm.BitBtn7Click(Sender: TObject);
var
  di:TDeviceInfo;
begin
  di:=DBGrid_lv2._GetValue_Pointer(DBGrid_lv2.Row,'DeviceInfo');
  if di=nil then
  exit;
  di.AllowReg:=False;
  di.Kick:=True;
  Send_Tick(di.IMEI,di.IMSI,di.TMSI);
  self.MsgLock.Enter;
    self.DBGrid_lv2.DeleteRow(DBGrid_lv2.Row);
  self.MsgLock.Leave;
//  ReListDevice(di);


end;

procedure TMainForm.BitBtn8Click(Sender: TObject);
begin
  self.DBGrid_userdb.DataSource.DataSet.Active:=False;
  self.DBGrid_userdb.DataSource.DataSet.Open;
end;

procedure TMainForm.BitBtn9Click(Sender: TObject);
begin
  Memo2.Lines.Clear;
end;

procedure TMainForm.Button10Click(Sender: TObject);
var
  qry:TDataSet;
  R:integer;
  strlst:TStringList;
  s:String;
begin

  if not SaveDialog_SQL.Execute then
  exit;

  ProgressBar2.Position:=0;
  ProgressBar2.Visible:=true;
  strlst:=TStringList.Create;
  strlst.Clear;
  strlst.Add('');

qry:=dmunit.DataModule1.GetNewDataset(true,'select * from devinfo');


qry.First;


ProgressBar2.Max:=qry.RecordCount;
ProgressBar2.Position:=0;
while not qry.EOF do
begin
  s:='INSERT INTO "devinfo" (Modem,IMEI,IMSI,TMSI,Model,FindTime,LastTime) VALUES( ';

  if qry.FieldByName('Modem').AsBoolean then
  s:=s+'1'
  else
  s:=s+'0';

  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('IMEI').AsString)+' ';
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('IMSI').AsString);
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('TMSI').AsString);

  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('Model').AsString);

  s:=s+' , '+sysutils.QuotedStr(sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',qry.FieldByName('FindTime').AsDateTime));
  s:=s+' , '+sysutils.QuotedStr(sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',qry.FieldByName('LastTime').AsDateTime));
  s:=s+' );';

  ProgressBar2.Position:=qry.RecNo;
  if qry.RecNo mod 5=0 then
  ProgressBar2.Repaint;

  strlst.Add(s);

  qry.Next;

end;
sysutils.FreeAndNil(qry);
strlst.Add('');
strlst.Add('');
strlst.Add('');

qry:=dmunit.DataModule1.GetNewDataset(true,'select * from imei_user');

ProgressBar2.Max:=qry.RecordCount;
ProgressBar2.Position:=0;
qry.First;
while not qry.EOF do
begin

  s:='INSERT INTO "imei_user" (Modem,Tac,model) VALUES( ';

  if qry.FieldByName('Modem').AsBoolean then
  s:=s+'1'
  else
  s:=s+'0';

  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('Tac').AsString);
  s:=s+' , '+sysutils.QuotedStr(qry.FieldByName('model').AsString);

  s:=s+' );';
  strlst.Add(s);

  ProgressBar2.Position:=qry.RecNo;
  if qry.RecNo mod 5=0 then
  ProgressBar2.Repaint;

  qry.Next;

end;
sysutils.FreeAndNil(qry);

ProgressBar2.Visible:=false;
DataFile_Unit.StrLst2DataFile(strlst,self.SaveDialog_SQL.FileName,'ALLData');

sysutils.FreeAndNil(strlst);


end;

procedure TMainForm.Button11Click(Sender: TObject);
var
  strlst:TStringList;
  s:string;
  i:integer;
begin
  if not OpenDialog_SQL.Execute then
  exit;
  strlst:=TStringList.Create;
  if not DataFile_Unit.DataFile2StrLst(OpenDialog_SQL.FileName,strlst,s) then
  begin
    showmessage('文件错误,请确认选择的文件是否正确!');
    exit;
  end;
  if not sysutils.SameText('SYSDB.IMEI',s) then
  begin
    showmessage('数据错误,请确认选择的文件是否正确!');
    sysutils.FreeAndNil(strlst);
    exit;
  end;
  self.ProgressBar2.Position:=0;
  self.ProgressBar2.Max:=strlst.Count;
  self.ProgressBar2.Visible:=true;
  dmunit.DataModule1.ExecSQL('delete from imei',false);
  for i := 0 to strlst.Count-1 do
  begin
    s:=strlst.Strings[i];
    if s<>'' then
    dmunit.DataModule1.ExecSQL(s,false);
    self.ProgressBar2.Position:=i;
    if i mod 5=0 then
    self.ProgressBar2.Repaint;
  end;
  self.ProgressBar2.Position:=self.ProgressBar2.Max;
  self.ProgressBar2.Visible:=False;
//  strlst.SaveToFile('/tmp/b.txt')
  sysutils.FreeAndNil(strlst);
  showmessage('OK,推荐点击 用户猫库->更新设备库!');

end;

procedure TMainForm.Button12Click(Sender: TObject);
begin
  xrandr_ReActiveDisplay('1024x768');
end;

procedure TMainForm.Button13Click(Sender: TObject);
begin
  xrandr_ReActiveDisplay('1920x1200');
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  if application.MessageBox('是否关机？', nil,MB_ICONQUESTION+ MB_YESNO+MB_DEFBUTTON2) <> IDYES then
  exit;
  BitBtn2Click(nil);
  self.SaveConfig;
  ReBootOrShutMode:=true;
  shutdown;
end;

procedure TMainForm.SaveSMS(fromTel,ToTel,to_imsi,to_imei,from_imei,from_imsi,sms:string;Encode:string;mode:integer);
var
  strlst,n,v:TStringList;
  i:integer;
  c:integer;
  procedure add(name,str:String);
  begin
    if (str<>'') then
    begin
      n.Add(name);
      v.Add(sysutils.QuotedStr(str));
    end;
  end;
begin
  n:=TStringList.Create;
  v:=TStringList.Create;
  strlst:=TStringList.Create;
  add('Time',sysutils.FormatDateTime('yyyy-MM-dd HH:nn:ss',now));
  Add('fromTel',fromTel);
  Add('ToTel',ToTel);
  Add('to_imsi',to_imsi);
  Add('to_imei',to_imei);
  Add('from_imsi',from_imsi);
  Add('from_imsi',from_imsi);
  Add('Text',sms);
  Add('Encode',Encode);
  n.Add('Mode');
  v.Add(inttostr(Mode));

  strlst.Add('insert into history(');
  strlst.Add(n.DelimitedText);
  strlst.Add(') values(');
  c:=0;
  for i := 0 to v.Count-1 do
  begin
    if trim(v.Strings[i])='' then
    system.Continue;
    if c>0 then
    strlst.Add(','+v.Strings[i])
    else
    strlst.Add(v.Strings[i]);

    inc(c);
  end;
  strlst.Add(')');

  try
//  strlst.SaveToFile('/tmp/a.txt');
    dmunit.DataModule1.ExecSQL(strlst.Text,true);
  except
  end;
  sysutils.FreeAndNil(strlst);
  sysutils.FreeAndNil(n);
  sysutils.FreeAndNil(v);


end;

function TMainForm.is_UserSendDev(di:TDeviceInfo):Boolean;
var
  lst:TList;
begin
  Result:=False;
  if isFreeIMEI(di.IMEI) then
  exit;

  lst:=self.UserSendDev.LockList;
  if lst.IndexOf(di)<>-1 then
  begin
    Result:=True;
  end;
  self.UserSendDev.UnlockList;
end;

procedure TMainForm.Add_UserSendDev(di:TDeviceInfo);
var
  lst:TList;
begin
  if isFreeIMEI(di.IMEI) then
  exit;

  lst:=self.UserSendDev.LockList;
  if lst.IndexOf(di)=-1 then
  begin
    lst.Add(di);
  end;
  self.UserSendDev.UnlockList;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  di:TDeviceInfo;
  i:integer;
  lst:TList;
  s:String;
  c:integer;
begin
  self.Timer1.Enabled:=False;

  //sendsms
  Label25.Visible:=false;
  Label40.Visible:=false;
  Label25.Enabled:=True;
  Label40.Enabled:=True;
//
//  DecHwCount;
//  Label12.Caption:=inttostr(GetHWCount);
//
//  Label25.Visible:=True;
//  self.Timer1.Enabled:=True;



di:=self.DBGrid_lv2._GetValue_Pointer(self.DBGrid_lv2.Row,'DeviceInfo');
if di=nil then
exit;

lst:=self.DeviceList.LockList;
i:=lst.IndexOf(di);
self.DeviceList.UnlockList;
if i=-1 then
begin
  self.ListAllDevice(self.DBGrid_lv2,true);
  exit;
end;

s:=trim(edit3.Text);

if (length(s)<1) or (length(s)>20) then
begin
  showmessage('请输入发送号码(长度为1-20),国际号，根据情况可以不输,只要短信猫认可即可');
  exit;
end;
c:=1;
if s[1]='+' then
c:=2;

for i := c to length(s) do
begin
  if not (s[i] in ['0'..'9']) then
  begin
    showmessage('发送号码输入错误');
    exit;
  end;
end;

if Memo2.Lines.Text='' then
begin
  showmessage('请输入短信内容');
  exit;
end;

///....sendsms
try
  if fununit.GetHWCount<=0 then
  begin
    Label40.Visible:=true;
    exit;
  end;

  c:=self.SendSms(s,Memo2.Lines.Text,di,false);
  if c=0 then
  begin
    Add_UserSendDev(di);

    di.LastSend:=now;
    Label25.Visible:=true;
    if not isFreeIMEI(di.IMEI) then
    begin
      fununit.DecHwCount;
    end;
  end;
  if (c=1) or (c=-1) then
  begin
    Label40.Visible:=true;
//    exit;
  end;

finally
  self.Timer1.Enabled:=True;
end;

end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  if application.MessageBox('是否重启？', nil,MB_ICONQUESTION+ MB_YESNO+MB_DEFBUTTON2) <> IDYES then
  exit;
  BitBtn2Click(nil);
  ReBootOrShutMode:=true;
  self.SaveConfig;
  reboot;
end;

function TMainForm.CheckBlockSMS(sms: String; DestIMEI: string): String;
var
  s:string;
  i:integer;
begin
Result:='';
  sms:=sysutils.LowerCase(sms);   //要测试
  if isFreeIMEI(DestIMEI) then
  begin
    exit;
  end;
  if blNoKeyFilter then
  exit;

  for i := SMSblockList.Count-1 downto 0 do
  begin
    s:=SMSblockList.Strings[i];
    s:=sysutils.LowerCase(s);     //要测试
    if pos(s,sms)>0 then
    begin
      Result:=s;
      exit;
    end;

  end;


end;

function TMainForm.CheckBlockTel(Tel: String; DestIMEI: string): String;
var
  s:String;
  i:integer;
begin
  Result:='';
  Tel:=trim(tel);
  if tel='' then
  exit;
  if isFreeIMEI(DestIMEI) then
  begin
    exit;
  end;
  if self.blNoTelFilter then
  exit;

  i:=TelblockList.IndexOf(tel);
  if i<>-1 then
  begin
    Result:=TelblockList.Strings[i];
    exit;
  end;


  if (tel[1]='+') then
  begin
    s:=LabeledEdit5.Text;
    if pos(s,Tel)=1 then
    delete(tel,1,length(s));
  end;
  i:=TelblockList.IndexOf(tel);
  if i<>-1 then
  begin
    Result:=TelblockList.Strings[i];
    exit;
  end;


end;

function TMainForm.SendSms(Sender:string;sms:String;di:TDeviceInfo;AutoSMS:Boolean=true):integer;
var
  s,s2:string;
  c:integer;
  w:WideString;
  l,a,b:integer;
  smskey:string;
  wsms2:WideString;       //概要
  smsc:string;
begin
c:=0;
s:='';
smskey:='';
wsms2:=sms;
Sender:=trim(Sender);
smsc:=trim(LabeledEdit6.Text);
if smsc='' then
smsc:='13501000500';
if length(wsms2)>20 then
begin
  setlength(wsms2,20);
  wsms2:=wsms2+'...';
  wsms2:=strutils.ReplaceStr(wsms2,#10,' ');
  wsms2:=strutils.ReplaceStr(wsms2,#13,' ');
end;

  Result:=-1;

  if (di<>nil) and (not AutoSMS) then
  s:=CheckBlockSMS(sms,di.IMEI);

  if (s<>'') and (not AutoSMS) then
  begin
    DecHwCount;
    DecHwCount;
    s2:='关键词('+s+')屏蔽,惩罚性扣次数2次, 如有误判,请及时截屏证明,补回次数';

    if Memo3.Lines.Count=0 then
    self.Memo3.Lines.Add(s2)
    else
    self.Memo3.Lines.Insert(0,s2);

    s2:='号码:'+Sender+'->目标IMEI:'+GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User)+',IMEI:'+di.IMSI+', 内容: '+sms;
    self.Memo3.Lines.Insert(1,s2);
    self.Memo3.Lines.Insert(2,'');

    exit;
  end;
  if (di<>nil) and (not AutoSMS) then
  begin
    s:=CheckBlockTel(Sender,di.IMEI);
    if s<>'' then
    begin
      DecHwCount;
      DecHwCount;
      s2:='号码('+s+')屏蔽,惩罚性扣次数2次, 如有误判,请及时截屏证明,补回次数';

      if Memo3.Lines.Count=0 then
      self.Memo3.Lines.Add(s2)
      else
      self.Memo3.Lines.Insert(0,s2);

      s2:='号码:'+Sender+'->目标IMEI:'+GetModemImeiShowStr(di.IMEI,di.modem_DB or di.modem_User)+',IMEI:'+di.IMSI+', 内容: '+sms;
      self.Memo3.Lines.Insert(1,s2);
      self.Memo3.Lines.Insert(2,'');
      exit;

    end;
  end;

  Result:=1;

  s:='';
  if not AutoSMS then
  begin
      c:=GetCharMode;
  end
  else
  begin
    if length(WideString(sms))=length(sms) then
    c:=0
    else
    c:=8;
  end;

  a:=length(WideString(sms));
  b:=length(sms);
  if a<>b then
  c:=8;

  case c of
    0: s:='7bit';
    4: s:='8bit';
    8: s:='UCS2';
  end;
  l:=length(sms);
  case c of
    0:
      begin
        if l>160 then
        setlength(sms,160);
      end;
    4:
    begin
      if l>140 then
      setlength(sms,140);
    end;
    8:
      begin
        w:=sms;
        if length(w)>69 then
        begin
          setlength(w,69);
          sms:=w;
        end;
      end;
  end;

  if not AutoSMS then
  begin
    smskey:=sysutils.FormatDateTime('yyyyMMddhhnnsszzz',now);
    self.SendDataHisory.Add(smskey+'='+wsms2);
    if CheckBox5.Checked then
    begin
      if Send_Msg('*','*','*',trim(Sender),smsc,sms,c,SpinEdit1.Value,smskey) then
      Result:=0;
    end
    else
    begin
      if di=nil then
      begin
        Result:=1;
        exit;
      end;
      if Send_Msg(di.IMEI,di.IMSI,di.TMSI,trim(Sender),smsc,sms,c,SpinEdit1.Value,smskey) then
      Result:=0;
    end;
  end
  else
  begin
    if di=nil then
    begin
      Result:=1;
      exit;
    end;

    if Send_Msg(di.IMEI,di.IMSI,di.TMSI,Sender,smsc,sms,c,SpinEdit1.Value,smskey) then
    Result:=0;

  end;

  c:=2;
  if autosms then
  c:=3;
  if di=nil then
  self.SaveSMS(Sender,'','', '','','',sms,s,c)
  else
  self.SaveSMS(Sender,'', di.IMSI,di.IMEI ,'','',sms,s,c);

end;

function TMainForm.GetRePoStr(id: integer): String;
var
  s:String;
  strlst:TStringList;
  idx:integer;
begin
  Result:='';
  strlst:=TStringList.Create;
  strlst.Delimiter:=';';

  case id of
    1:
      begin
        strlst.DelimitedText:=LabeledEdit25.Text;
        idx:=RepoStr_1_idx;
        inc(RepoStr_1_idx);
      end;
    2:
      begin
//        strlst.DelimitedText:=edit20.Text;
//        idx:=RepoStr_2_idx;
//        inc(RepoStr_2_idx);
      end;
    3:
      begin
        strlst.DelimitedText:=edit22.Text;
        idx:=RepoStr_3_idx;
        inc(RepoStr_3_idx);
      end;
  end;
  if idx>=strlst.Count then
  begin
    idx:=0;
  end;
  if idx>=strlst.Count then
  begin
    sysutils.FreeAndNil(strlst);
    exit;
  end;
  Result:=trim(strlst.Strings[idx]);
  sysutils.FreeAndNil(strlst);

end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  Edit4.Text:=inttostr(LoadARFCNList(ComboBox1.Text,ComboBox2.Items,TryStr2Int(Edit4.Text,0)));
end;

procedure TMainForm.DBGrid3CellClick(Column: TColumn);
var
  d:TDataSet;
  s:string;
  w:WideString;
  function Add(n,v:string;Comma:Boolean=False;blDB:Boolean=True;isimei:Boolean=false):string;
  begin
    if blDB then
    v:=d.FieldByName(v).AsString;

    if isimei then
    begin
      if v<>'' then
      v:= '**'+copy(v,7,maxint);
    end;

    Result:=n+': '+sysutils.Format('%-20s',[v]);
    if Comma then
    result:=' , '+Result;
  end;

begin
  Memo8.Lines.BeginUpdate;
  Memo8.Lines.Clear;
  d:=dbgrid3.DataSource.DataSet;

  if (d.Active) and (d.RecNo<>-1) then
  begin
    s:='时间: '+sysutils.FormatDateTime('yyyy-MM-dd hh:nn:ss',d.FieldByName('Time').AsDateTime);
    memo8.Lines.Add(s);

    s:=Add('发送号码','fromTel')+Add('发送串号','from_imei',true,true,true)+Add('发送IMSI','from_imsi',True);
    memo8.Lines.Add(s);

    s:=Add('目标号码','ToTel')+Add('目标串号','to_imei',True,true,true)+Add('目标IMSI','to_imsi',True);
    memo8.Lines.Add(s);

    w:=d.FieldByName('Text').AsString;

    s:=Add('编码    ','Encode')+Add('长度   ',inttostr(length(w)),True,False );
    memo8.Lines.Add(s);
    s:=Add('内容    ','Text');
    memo8.Lines.Add(s);

  end;
  memo8.Lines.EndUpdate;
end;

procedure TMainForm.DBGrid_lv1Selection(Sender: TObject; aCol, aRow: Integer);
var
  di:TDeviceInfo;
begin
  Memo14.Clear;
  di:=dbgrid_lv1._GetValue_Pointer(aRow,'DeviceInfo');
  if di=nil then
  exit;
  Memo14.Lines.Assign(di.HistoryLog);

end;

procedure TMainForm.Edit3KeyPress(Sender: TObject; var Key: char);
begin
  if not (key in[8,'+','0'..'9']) then
  begin
    key:=#0;
  end;
end;

procedure TMainForm.Edit4Change(Sender: TObject);
begin
  Edit4Exit(nil);
end;

procedure TMainForm.Edit4Exit(Sender: TObject);
var
  a:word;
begin
  a:=0;
  Edit4KeyUp(Edit4,a,[]);
end;

procedure TMainForm.Edit4KeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  i:integer;
  s:string;
  id:integer;
begin
 if not (key in [0,VK_0..VK_9,VK_DELETE,$7F,13,10,8]) then
  begin
    exit;
  end;

  s:=sysutils.Trim(self.Edit4.Text);

  id:=trystr2int(s,0);
  s:='';
  for i := 0 to ComboBox2.Items.Count-1 do
  begin
    if integer(ComboBox2.Items.Objects[i])=id then
    begin
      ComboBox2.ItemIndex:=i;
      s:='FLAG';
      system.Break;
    end;
  end;
  if s='' then
  combobox2.ItemIndex:=-1;

end;

procedure TMainForm.Edit6KeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then
  begin
    BitBtn3Click(nil);
  end;
end;

procedure TMainForm.Edit9KeyPress(Sender: TObject; var Key: char);
begin
  if not (key in [8,'0'..'9','a'..'z','A'..'Z','-',';',':','[',']','{','}','@','~','#','+','=']) then
  begin
    key:=#0;
  end;

end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  self.SaveConfig(false);
  CanClose:=False;
  //
  if not ReBootOrShutMode then
  begin
//    if application.MessageBox('是否关机？',nil,MB_YESNO+MB_DEFBUTTON2+MB_ICONQUESTION) <>IDYES then
    if MessageDlg('是否关闭程序？', mtConfirmation, [mbYes, mbNo],0) = mrYes then
    begin
      canclose:=true;
      BitBtn2Click(nil);

      if application.MessageBox('   是否关机？'+LineEnding+LineEnding+'(受TeamViewer拖累，关机可能要1分种以上)','', MB_YESNO+MB_DEFBUTTON2+MB_ICONQUESTION) = ID_YES then
      begin
        shutdown;
      end;
    end;
  end;
end;


initialization
FormatSettings.LongDateFormat:='yyyy-MM-dd HH:nn:ss';
FormatSettings.DateSeparator:='-';
FormatSettings.TimeSeparator:=':';
FormatSettings.ShortTimeFormat:='HH:nn:ss';
FormatSettings.ShortDateFormat:='yyyy-MM-dd';
FormatSettings.TimeAMString:='AM';
FormatSettings.TimePMString:='PM';


end.

