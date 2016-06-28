program SmsSend;

{$mode delphi}{$H+}

uses
  cthreads,
  cmem,
  Interfaces, // this includes the LCL widgetset
  sysutils,
  Forms,
  dialogs,
  bs_controls, pl_excontrols, lz_memds,

  mainform_unit, DmUnit, runbtsform_unit, fununit, CRC8_Unit,
  CRC16_Unit,  TCPServerUnit, userimeisetForm_unit,
  RegUnit, FindmodemForm_Unit, DataFile_Unit, PushData_Unit , SoftProtect_Unit,
  CommFunUnit,ServerComm_Unit, FindDeviceForm_Unit, gsm_sms_util, LoginFormUnit, chanPassWordForm_Unit;

{$R *.res}
var
  s:string;

begin
  Application.Title:='短信猫作弊';

  if not fununit.isRoot then
  begin
    WriteLn('Need Root!');
    WriteLn('必须在root下运行，需要调用硬件!!');
    showmessage('必须在root下运行，需要调用硬件!!');
    exit;
  end;

  if not initDSP(True) then
  begin
    showmessage('不兼容/无线电板没有插上/加密狗无效/系统文件损坏, 请检查硬件 ');
//    shutdown;
    exit;
  end;

  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);

  if ProcParam then
  begin
    exit;
  end;



  {
  s:=GetMacHWForReg;
  Str2RegHW(s,H);
  s:=NewRegCode(1234,@h);
  Str2RegCode(S,R);
  if H.SDR=0 then
  }
  if not LoginDlg then
  exit;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

