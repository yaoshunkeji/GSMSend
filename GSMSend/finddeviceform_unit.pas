unit FindDeviceForm_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ButtonPanel;

type

  { TFindDeviceForm }

  TFindDeviceForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    Model: TLabeledEdit;
    IMEI: TLabeledEdit;
    IMSI: TLabeledEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FindDeviceForm: TFindDeviceForm;

implementation

{$R *.lfm}

{ TFindDeviceForm }

procedure TFindDeviceForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TFindDeviceForm.FormCreate(Sender: TObject);
begin
  self.Model.Caption:='';
  self.IMSI.Caption:='';
  self.IMEI.Caption:='';
end;

end.

