if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files
  @echo.

  %sys.ColorDark%

  :: %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  :: %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:change;" -ace "n:%sid.service%;s:y;p:change;" -ace "n:%sid.NetworkService%;s:y;p:change;" -ace "n:%ds.domain%\aspnet;p:change;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE%

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

      :: %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      :: %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysdotnet-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysdotnet-da;p:read_ex;m:deny"

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

  :: @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  :: @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:change;" -ace "n:%sid.service%;s:y;p:change;" -ace "n:%sid.NetworkService%;s:y;p:change;" -ace "n:%ds.domain%\aspnet;p:change;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\temporary asp.net files" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE%

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing sys.osroot.dotnet20.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.dotnet20.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      :: @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      :: @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysdotnet-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v2.0.50727\%%i" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysdotnet-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysdotnet-da;p:read_ex;m:deny"

      @echo.
      %sys.ColorNormal%
    )
  )
)