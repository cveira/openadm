if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\explorer.exe
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

  %fs.BinDir%\subinacl /file "%systemroot%\explorer.exe" /revoke=system /revoke=builtin\administrators

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

  :: @echo %fs.BinDir%\setacl -on "%systemroot%\explorer.exe" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

  @echo %fs.BinDir%\subinacl /file "%systemroot%\explorer.exe" /revoke=system /revoke=builtin\administrators
)