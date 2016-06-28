unit userimeisetForm_unit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,Forms, Controls, Graphics, Dialogs, ExtDlgs, DbCtrls,
  StdCtrls, ButtonPanel,LCLType;

type
  { TUserImeiSetForm }
  TUserImeiSetForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  UserImeiSetForm: TUserImeiSetForm;

implementation

{$R *.lfm}

uses
  pdu_unit;

{ TUserImeiSetForm }

procedure TUserImeiSetForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=cahide;
end;

procedure TUserImeiSetForm.Edit1Change(Sender: TObject);
var
  s:ansiString;
  b:boolean;
  i:integer;
  s2:ansiString;
begin
  s:=edit1.Text;
  b:=False;
//  Label5.ed
  if (length(s)=8) then
  b:=True;

  if length(s)=15 then
  begin
    b:=true;
    s2:=ImeiTail(s);
    self.Label5.Visible:=s2[15]<>s[15];
    if self.Label5.Visible then
    b:=false;
  end
  else
  begin
    self.Label5.Visible:=False;
  end;

  for i := 1 to length(s) do
  begin
    if not (s[i] in ['0'..'9']) then
    begin
      b:=False;
      system.Break;
    end;
  end;
  Label3.Caption:=inttostr(length(s));

  ButtonPanel1.OKButton.Enabled:=b;
  Label3.Visible:=b and (length(s)<>1);

end;

end.

