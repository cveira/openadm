if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.script.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.script.ini) do (
    if exist "%systemroot%\system32\%%i" (
      %sys.ColorDark%

      :: %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

      %fs.BinDir%\subinacl /file "%systemroot%\system32\%%i" /grant=system=f /grant=builtin\administrators=f

      if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo    + operation status: FAIL
      ) else (
        @echo    + operation status: OK
      )

      %sys.ColorNormal%
    )
  )
) else (
  @echo.
  @echo  # [test-mode] processing sys.osroot.script.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.script.ini) do (
    if exist "%systemroot%\system32\%%i" (
      :: @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

      @echo %fs.BinDir%\subinacl /file "%systemroot%\system32\%%i" /grant=system=f /grant=builtin\administrators=f
    )
  )
)