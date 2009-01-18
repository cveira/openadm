if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.dotnet20.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" (
      %sys.ColorDark%

      :: %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

      %fs.BinDir%\subinacl /file "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" /revoke=system /revoke=builtin\administrators

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
  @echo  # [test-mode] processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.dotnet20.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" (
      :: @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

      @echo  %fs.BinDir%\subinacl /file "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" /revoke=system /revoke=builtin\administrators
    )
  )
)