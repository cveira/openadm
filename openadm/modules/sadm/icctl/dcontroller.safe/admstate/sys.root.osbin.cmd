if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\program files
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "c:\program files" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

  %fs.BinDir%\subinacl /file "c:\program files" /grant=system=f /grant=builtin\administrators=f

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\program files
  @echo.

  :: @echo %fs.BinDir%\setacl -on "c:\program files" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

  @echo %fs.BinDir%\subinacl /file "c:\program files" /grant=system=f /grant=builtin\administrators=f
)