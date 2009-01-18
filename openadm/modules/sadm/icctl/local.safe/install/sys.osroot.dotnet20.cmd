if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.dotnet20.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysdotnet-da;p:read_ex;m:deny"

      if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo    + operation status: FAIL
      ) else (
        @echo    + operation status: OK
      )

      @echo.
      %sys.ColorNormal%
    )
  )
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE%

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.dotnet20.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysdotnet-da;p:read_ex;m:deny"

      @echo.
      %sys.ColorNormal%
    )
  )
)