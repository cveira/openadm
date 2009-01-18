if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\opstate\sys.osroot.dotnet20.ini) do (
    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"

    if %errorlevel% NEQ %EL_SETACL_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    %sys.ColorNormal%
  )
) else (
  @echo.
  @echo  # [test-mode] processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\opstate\sys.osroot.dotnet20.ini) do (
    @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full;m:revoke"
  )
)