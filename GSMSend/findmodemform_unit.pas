unit FindModemForm_Unit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ButtonPanel;

type

  { TFindModemForm }

  TFindModemForm = class(TForm)
    Button6: TButton;
    ButtonPanel1: TButtonPanel;
    CheckBox9: TCheckBox;
    Label32: TLabel;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit8: TLabeledEdit;
    LabeledEdit9: TLabeledEdit;
    Panel1: TPanel;
    Panel5: TPanel;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FindModemForm: TFindModemForm;

implementation

{$R *.lfm}

{ TFindModemForm }

procedure TFindModemForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
CloseAction:=cahide;
end;

end.

