//http://wiki.freepascal.org/Platform_defines
//http://www.freepascal.org/docs-html/prog/progap7.html
//http://www.freepascal.org/docs-html/prog/prog.html

{$IFDEF CPU86} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPU386} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPUI386} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPUX86_64} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPUAMD64} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPUIA64} {$DEFINE FB_X86} {$ENDIF}
{$IFDEF CPUARM} {$UNDEF FB_X86} {$ENDIF}

