unit KeyGenForm_Unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, ComboEx, Buttons
  ,Clipbrd;

type

  { TKeyGen_Form }

  TKeyGen_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  KeyGen_Form: TKeyGen_Form;

implementation

{$R *.lfm}

uses
  RegUnit,FunUnit,CRC8_Unit,pdu_unit,CommFunUnit;

{ TKeyGen_Form }




procedure TKeyGen_Form.Edit1Change(Sender: TObject);
var
  R:TRegHW;
  s:string;
begin
  self.Memo1.Clear;
  Edit2.Text:='';
  Button1.Enabled:=Str2RegHW(edit1.Text,R);
  Label9.Enabled:=Button1.Enabled;
  if not Button1.Enabled then
  exit;

  self.Memo1.Lines.Clear;
  self.Memo1.Lines.Add(' 软件版本:  '+inttostr(R.V1));
  s:=sysutils.Format(' 硬件ID1 :  %-8d   硬件ID2:   %-8d',[R.SDR,R.MBSN]);
  self.Memo1.Lines.Add(s);

  self.Memo1.Lines.Add(' 累计次数: '+inttostr(R.AllCount));
  self.Memo1.Lines.Add(' 剩余次数: '+inttostr(R.LastCount));
  self.Memo1.Lines.Add(' 充值次数: '+inttostr(R.PayCount));

  if not button1.Enabled then
  begin
    self.Memo1.Lines.Add('');
    self.Memo1.Lines.Add('   ！！！！！硬件码错误！！！！！');

  end;

end;

procedure TKeyGen_Form.Edit3Change(Sender: TObject);
var
  M:TMacID;
begin
  Label7.Caption:='';
  Label8.Enabled:=Str2MacID(edit3.Text,M);
  if Label8.Enabled then
  begin
    Label7.Caption:=sysutils.Format(' 硬件ID1 :  %-8d   硬件ID2:   %-8d  硬件ID3:   %-8d',[M.SysSDRSN,M.SysBrdSN,M.SysUUIDSN]);
  end;
end;

procedure TKeyGen_Form.Edit4Change(Sender: TObject);
var
  s:String;
  b:Boolean;
begin
  s:=trim(edit4.Text);
  b:=false;
  if length(s)=15 then
  begin
    if ImeiTail(s)=edit4.Text then
    begin
      b:=true;
    end
    else
    begin
      b:=False;
    end;
  end;

  Button4.Enabled:=b;

end;

procedure TKeyGen_Form.Button1Click(Sender: TObject);
var
  R:TRegHW;
begin
if not Str2RegHW(edit1.Text,R) then
  exit;

  Edit2.Text:=NewRegCode(SpinEdit1.Value,@R);

end;

procedure TKeyGen_Form.Button2Click(Sender: TObject);
var
  lst:TStringList;
begin
if not self.OpenDialog1.Execute then
exit;

lst:=TStringList.Create;
lst.LoadFromFile(self.OpenDialog1.FileName);
EncodeStrLst(lst);
if self.SaveDialog1.Execute then
begin
  lst.SaveToFile(self.SaveDialog1.FileName);
end;
sysutils.FreeAndNil(lst);
end;

procedure TKeyGen_Form.Button3Click(Sender: TObject);
var
  lst:TStringList;
begin
if not self.OpenDialog1.Execute then
exit;

lst:=TStringList.Create;
lst.LoadFromFile(self.OpenDialog1.FileName);
if not DecodeStrLst(lst) then
begin
  showmessage('ERROR');
  sysutils.FreeAndNil(lst);
  exit;
end;

if self.SaveDialog1.Execute then
begin
  lst.SaveToFile(self.SaveDialog1.FileName);
end;
sysutils.FreeAndNil(lst);

end;

procedure TKeyGen_Form.Button4Click(Sender: TObject);
var
  R:TRegHW;
  s:String;
begin

  Edit4.Text:=ImeiTail(trim(Edit4.Text));

  if not Str2RegHW(Edit1.Text,R) then
    exit;
  Edit4.Text:=trim(Edit4.Text);

  s:='SIME';
  if RadioButton1.Checked then
  S:='AIME';
  if RadioButton3.Checked then
  S:='SIME';
  if RadioButton2.Checked then
  S:='CIME';

  Edit5.Text:=NewBindIMEICode(SpinEdit2.Value,Edit4.Text,s,R);




end;

procedure TKeyGen_Form.Button5Click(Sender: TObject);
begin
  //
  edit6.Text:=NewDecCountCode(SpinEdit3.Value);


end;

procedure TKeyGen_Form.FormCreate(Sender: TObject);
begin
  self.Edit1.Text:='';
  self.Edit2.Text:='';
  self.Edit3.Text:='';
  self.Label7.Caption:='';
  self.Memo1.Lines.Clear;
  Label11.Visible:=False;

end;

procedure TKeyGen_Form.SpeedButton1Click(Sender: TObject);
begin
  Edit1.Text:=Clipbrd.Clipboard.AsText;
end;

procedure TKeyGen_Form.SpeedButton2Click(Sender: TObject);
begin
  Clipbrd.Clipboard.AsText:=trim(Edit1.Text);
end;

procedure TKeyGen_Form.SpinEdit3Change(Sender: TObject);
begin
  button5.Enabled:=spinedit3.Value>0;
end;

end.

