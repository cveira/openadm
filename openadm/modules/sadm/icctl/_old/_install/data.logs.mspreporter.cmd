if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\logs\net\preporter
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\net\preporter" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\logs\net\preporter
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\net\preporter" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  %sys.ColorNormal%
)