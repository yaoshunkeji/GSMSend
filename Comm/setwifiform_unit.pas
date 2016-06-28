unit SetWiFiForm_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel, StdCtrls, Buttons,inifiles,LCLType
  ,process;

type

  { TSetWiFiForm }

  TSetWiFiForm = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
  private

  public
    procedure SetDefaultConfig(Force:Boolean=False;Active:Boolean=False);
  end;

var
  SetWiFiForm: TSetWiFiForm;

  APName:String='FindGPS';

procedure CheckAndSetDefaultConfig();

implementation

{$R *.lfm}

uses
  commfununit;

{ TSetWiFiForm }

procedure CheckAndSetDefaultConfig();
begin
  SetWiFiForm:=TSetWiFiForm.Create(nil);
  SetWiFiForm.SetDefaultConfig(false,true);
  sysutils.FreeAndNil(SetWiFiForm);
end;

procedure TSetWiFiForm.SetDefaultConfig(Force:Boolean=False;Active:Boolean=False);
var
  ssid,pass:String;
  mode:string;
  wep:boolean;
  ac:boolean;
  mac:string;
begin
  ssid:='';
  pass:='';
  mode:='';
  mac:='';
  wep:=true;

  if WiFi_Get_Config(mac,ssid,pass,mode,wep,ac,true) then
  begin
    if not force then
    exit;
  end;

  BitBtn1Click(nil);
  if Active then
  CheckBox2.Checked:=true;
  OKButtonClick(nil);


end;

procedure TSetWiFiForm.BitBtn1Click(Sender: TObject);
var
  aMacAddr:string;
begin
  aMacAddr:=GetWifiMac('',true,true,true);
  ComboBox1.Text:=APName+'_'+aMacAddr;
  Edit1.Text:='12345';

  CheckBox1.Enabled:=false;
  CheckBox1.Checked:=true;
  RadioButton1.Checked:=true;
  RadioButton2.Checked:=false;
  ComboBox1Change(nil);
//  application.MessageBox('aa','aa');
  exit;
  if Sender<>nil then
  showmessage('请点[确认]保存,重启系统生效!');
end;

procedure TSetWiFiForm.Button1Click(Sender: TObject);
begin
  ComboBox1.Items.Clear;
  screen.Cursor:=crSQLWait;
  Wifi_Get_APNameList(ComboBox1.Items);
  screen.Cursor:=crdefault;
end;

procedure TSetWiFiForm.ComboBox1Change(Sender: TObject);
var
  b:boolean;
  l:integer;
begin
  b:=(trim(ComboBox1.Text)<>'');
  b:=b and (trim(Edit1.Caption)<>'');
  l:=length(trim(Edit1.Caption));
  if CheckBox1.Checked then
  begin
    b:=b and (l in [5,13]);
  end
  else
  begin
    b:=b and (l>=8);
  end;
  ButtonPanel1.OKButton.Enabled:=b;
end;

procedure TSetWiFiForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=cafree;
end;

procedure TSetWiFiForm.FormCreate(Sender: TObject);
var
  ssid,pass:String;
  mode:string;
  wep:boolean;
  mac:string;
  ac:boolean;
begin
  mac:='';
  pass:='';
  wep:=false;
  ac:=false;

  if WiFi_Get_Config(mac,ssid,pass,mode,wep,ac,true) then
  begin
    self.ComboBox1.Text:=ssid;
    self.Edit1.Text:=pass;
    if sysutils.SameText('adhoc',mode) or sysutils.SameText('ap',mode) then
    RadioButton1.Checked:=true
    else
    RadioButton2.Checked:=true;

    CheckBox1.Checked:=wep;
    if wep then
    CheckBox1.Enabled:=false;
    exit;
  end;
  BitBtn1Click(nil);
end;

procedure TSetWiFiForm.OKButtonClick(Sender: TObject);
var
  s:String;
  s1,s2:String;
  b:boolean;
begin
  ComboBox1Change(nil);
  if not self.ButtonPanel1.OKButton.Enabled then
  begin
    self.ModalResult:=mrNone;
    exit;
  end;

    if RadioButton1.Checked then
    s1:=RadioButton1.Caption
    else
    s1:=RadioButton2.Caption;

    if Sender<>nil then
    begin

      s:=sysutils.Format('是否要设置成 %s 「%s」,密码: 「%s」 ',[s1,trim(ComboBox1.Text),trim(edit1.Text)]);

      s:=s+CRLF+'如果设错，或忘记密码，只能连接显示器键盘操作来恢复!';

      if application.MessageBox(PChar(s),'警告',MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)<>ID_YES then
      exit;
      s:=sysutils.Format('再次确认,你将要设置成 %s 「%s」,密码: 「%s」 ，是否真的继续？',[s1,trim(ComboBox1.Text),trim(edit1.Text)]);

      if application.MessageBox(PChar(s),'警告',MB_YESNO+MB_ICONQUESTION)<>ID_YES then
      begin
        self.ModalResult:=mrNone;
        exit;
      end;
    end;

    b:=false;
    if RadioButton1.Checked then
    b:=WiFi_Set_APMode('',trim(ComboBox1.Text),trim(Edit1.Text))
    else
    b:=WiFi_Set_Conn('',trim(ComboBox1.Text),trim(Edit1.Text),CheckBox1.Checked);

    if not b then
    begin
      if Sender<>nil then
      application.MessageBox('设置失败','警告',MB_OK+MB_ICONERROR);
      self.ModalResult:=mrNone;
      exit;
    end;
    b:=false;
    if CheckBox2.Checked then
    begin
      try
        b:=true;
        process.RunCommand('nmcli conn reload',s2);
        except
        b:=false;
      end;
    end;

    if Sender<>nil then
    begin
      if b then
      s:='修改成功,稍后生效，你的设置是 %s,「%s」,密码为「%s」'
      else
      s:='修改成功,重启生效，你的设置是 %s,「%s」,密码为「%s」';
      s:=sysutils.Format(s,[s1,trim(ComboBox1.Text),trim(edit1.Text)]);

      application.MessageBox(PChar(s),'警告',MB_OK+MB_ICONWARNING);
    end;

    if Sender<>nil then
    self.Close;

end;

procedure TSetWiFiForm.RadioButton1Change(Sender: TObject);
begin
  if RadioButton1.Checked then
  begin
    CheckBox1.Checked:=true;
    CheckBox1.Enabled:=false;
  end
  else
  begin
    CheckBox1.Checked:=false;
    CheckBox1.Enabled:=true;
  end;
end;

end.

