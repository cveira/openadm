if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\regedit.exe
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  :: %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysregedit-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysregedit-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

  %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysregedit-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysregedit-da;p:read_ex;m:deny"


  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\regedit.exe
  @echo.

  %sys.ColorDark%

  :: @echo %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  :: @echo %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysregedit-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysregedit-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

  @echo %fs.BinDir%\setacl -on "%systemroot%\regedit.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysregedit-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysregedit-da;p:read_ex;m:deny"

  %sys.ColorNormal%
)