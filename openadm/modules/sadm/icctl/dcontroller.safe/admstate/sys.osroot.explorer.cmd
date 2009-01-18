if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\explorer.exe
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

  %fs.BinDir%\subinacl /file "%systemroot%\explorer.exe" /grant=system=f /grant=builtin\administrators=f

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

  :: @echo %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

  @echo %fs.BinDir%\subinacl /file "%systemroot%\explorer.exe" /grant=system=f /grant=builtin\administrators=f
)