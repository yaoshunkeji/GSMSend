unit runbtsform_unit;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtDlgs, ButtonPanel, ExtCtrls, StdCtrls;

type

  { TRunBTSForm }

  TRunBTSForm = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  RunBTSForm: TRunBTSForm;

implementation

{$R *.lfm}

{ TRunBTSForm }

procedure TRunBTSForm.FormCreate(Sender: TObject);
begin

end;

end.

