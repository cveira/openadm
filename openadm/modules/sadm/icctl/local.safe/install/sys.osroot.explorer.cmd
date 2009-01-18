if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\explorer.exe
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysshell-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysshell-da;p:read_ex;m:deny"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\explorer.exe
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysshell-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysshell-da;p:read_ex;m:deny"

  %sys.ColorNormal%
)