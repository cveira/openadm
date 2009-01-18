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

    :: %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

    %fs.BinDir%\subinacl /file "%%i" /grant=system=f /grant=builtin\administrators=f

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
    :: @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"
    
    @echo %fs.BinDir%\subinacl /file "%%i" /grant=system=f /grant=builtin\administrators=f
  )
)