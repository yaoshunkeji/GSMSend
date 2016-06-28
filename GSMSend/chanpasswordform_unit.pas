unit chanPassWordForm_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel, StdCtrls
  ,IniFiles;

type

  { TchanPassWordForm }

  TchanPassWordForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    blCanClose:Boolean;
  public
    { public declarations }
  end;

var
  chanPassWordForm: TchanPassWordForm;

function DecPasswordStr(Str:string):string;
function EncPasswordStr(Str:string):string;

implementation

{$R *.lfm}

uses
  base64;

{ TchanPassWordForm }

function DecPasswordStr(Str:string):string;
var
  s:String;
begin
  s:='';
  s:=trim(str);
  if (s='') or ((s[1]<>'V') and (s[1]<>'v')) then
  begin
    Result:='987654321';
    exit;
  end;
  delete(s,1,1);
  Result:=base64.DecodeStringBase64(s);
end;

function EncPasswordStr(Str:string):string;
var
  s:String;
begin
  Result:='V'+base64.EncodeStringBase64(str);
end;


procedure TchanPassWordForm.OKButtonClick(Sender: TObject);
var
  ini:Tinifile;
  s:String;
begin
  ini:=tinifile.Create(sysutils.ExtractFilePath(system.ParamStr(0))+'config.ini');
  s:=trim(ini.ReadString('config','softsafe',''));
  s:=DecPasswordStr(s);

  if s<>LabeledEdit1.Text then
  begin
    showmessage('原密码输入错误');
    sysutils.FreeAndNil(ini);
    blCanClose:=False;
    exit;
  end;
  s:=EncPasswordStr(LabeledEdit2.Text);
  ini.WriteString('config','softsafe',s);
  ini.Free;
  showmessage('你现在的密码是:['+LabeledEdit1.Text+'],区分大小写');
  blCanClose:=true;

end;

procedure TchanPassWordForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=blCanClose;
end;

procedure TchanPassWordForm.CancelButtonClick(Sender: TObject);
begin
  blCanClose:=true;
end;

procedure TchanPassWordForm.FormCreate(Sender: TObject);
begin
  blCanClose:=false;
end;

end.

