if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\services\jre
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:\services\jre" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysjre-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysjre-da;p:read_ex;m:deny"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\services\jre
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:\services\jre" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysjre-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysjre-da;p:read_ex;m:deny"

  %sys.ColorNormal%
)