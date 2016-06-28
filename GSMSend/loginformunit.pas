unit LoginFormUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel, StdCtrls,IniFiles;

type

  { TLoginForm }

  TLoginForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    blCanClose:Boolean;
  public
    { public declarations }
  end;

var
  LoginForm: TLoginForm;
  loginok:Boolean=False;

  function LoginDlg:boolean;

implementation

{$R *.lfm}


uses
  chanPassWordForm_Unit;

{ TLoginForm }

function LoginDlg:boolean;
var
  LoginForm:TLoginForm;
  ini:Tinifile;
begin
  Result:=False;
  LoginForm:=TLoginForm.Create(nil);
//  if LoginForm.ShowModal<>mrok then
//  exit;

  LoginForm.ShowModal;

  Result:=LoginOK;

end;

procedure TLoginForm.HelpButtonClick(Sender: TObject);
begin
  TchanPassWordForm.Create(self).ShowModal;
  Label1.Visible:=false;
end;

procedure TLoginForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=blCanClose;
end;

procedure TLoginForm.CancelButtonClick(Sender: TObject);
begin
  blCanClose:=True;
end;

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  blCanClose:=false;
end;

procedure TLoginForm.OKButtonClick(Sender: TObject);
var
  ini:Tinifile;
  s:String;
begin
  self.ModalResult:=mrnone;
  ini:=tinifile.Create(sysutils.ExtractFilePath(system.ParamStr(0))+'config.ini');
  s:=trim(ini.ReadString('config','softsafe',''));
  s:=DecPasswordStr(s);
  sysutils.FreeAndNil(ini);
  if LabeledEdit2.Text<>s then
  begin
    Label1.Visible:=true;
    blCanClose:=false;
    exit;
  end;
  loginok:=true;
  blCanClose:=True;
  self.ModalResult:=mrok;
  self.Close;

end;

end.

