if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "c:" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

  %fs.BinDir%\subinacl /file "c:" /revoke=system /revoke=builtin\administrators

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\
  @echo.

  :: @echo %fs.BinDir%\setacl -on "c:" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

  @echo %fs.BinDir%\subinacl /file "c:" /revoke=system /revoke=builtin\administrators
)