if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub\mail
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\mail" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change" -ace "n:%ds.domain%\¡sys-svc-mail;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\pub\mail
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\mail" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change" -ace "n:%ds.domain%\¡sys-svc-mail;p:change"

  %sys.ColorNormal%
)