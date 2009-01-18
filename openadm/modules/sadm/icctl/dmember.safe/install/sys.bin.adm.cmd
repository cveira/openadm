if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\bin\adm
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:\bin\adm" -ot file -actn ace -ace "n:%COMPUTERNAME%\res-ts-binadm;p:change" -ace "n:%COMPUTERNAME%\res-ts-binadm-da;p:read_ex;m:deny" -ace "n:%COMPUTERNAME%\res-ts-binadm-rx;p:read_ex" %ACL_LOCAL_AUDIT_SYSTEM%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\bin\adm
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:\bin\adm" -ot file -actn ace -ace "n:%COMPUTERNAME%\res-ts-binadm;p:change" -ace "n:%COMPUTERNAME%\res-ts-binadm-da;p:read_ex;m:deny" -ace "n:%COMPUTERNAME%\res-ts-binadm-rx;p:read_ex" %ACL_LOCAL_AUDIT_SYSTEM%

  %sys.ColorNormal%
)