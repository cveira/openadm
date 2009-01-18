if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\services\mrelay
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:\services\sarelay" -ot file -actn ace -ace "n:%ds.domain%\¡sys-svc-mail;p:read_ex"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\services\sarelay
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:\services\mrelay" -ot file -actn ace -ace "n:%ds.domain%\¡sys-svc-mail;p:read_ex"

  %sys.ColorNormal%
)