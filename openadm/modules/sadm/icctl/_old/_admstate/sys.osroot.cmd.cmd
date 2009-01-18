if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\system32\cmd.exe
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\system32\cmd.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

  if %errorlevel% NEQ %EL_SETACL_OK% (
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

  @echo %fs.BinDir%\setacl -on "%systemroot%\system32\cmd.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"
)