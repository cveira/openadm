if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\system32\cmd.exe
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\system32\cmd.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-syscmd-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-syscmd-da;p:read_ex;m:deny"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\system32\cmd.exe
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\system32\cmd.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-syscmd-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-syscmd-da;p:read_ex;m:deny"

  %sys.ColorNormal%
)