if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\$*$.
  @echo.

  %sys.ColorDark%

  attrib -h "%systemroot%\$*$." /d /s

  %sys.ColorNormal%
  @echo.

  for /d %%i in ("%systemroot%\$*$.") do (
    %sys.ColorDark%

    :: %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

    %fs.BinDir%\subinacl /file "%%i" /revoke=system /revoke=builtin\administrators

    if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    %sys.ColorNormal%
  )

  %sys.ColorDark%

  attrib +h "%systemroot%\$*$." /d /s

  %sys.ColorNormal%
  @echo.
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\$*$.
  @echo.

  %sys.ColorDark%

  attrib "%systemroot%\$*$." /d /s

  %sys.ColorNormal%
  @echo.

  for /d %%i in ("%systemroot%\$*$.") do (
    :: @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"
    
    @echo %fs.BinDir%\subinacl /file "%%i" /revoke=system /revoke=builtin\administrators
  )
)