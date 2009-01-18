if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:change;" -ace "n:%sid.service%;s:y;p:change;" -ace "n:%sid.NetworkService%;s:y;p:change;" -ace "n:aspnet;p:change;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing sys.osroot.dotnet11.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\install\sys.osroot.dotnet11.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:res-ts-sysdotnet-rx;p:read_ex" -ace "n:res-ts-sysdotnet-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      if %errorlevel% NEQ %EL_SETACL_OK% (
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
  @echo  # [test-mode] processing %systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\temporary asp.net files" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:change;" -ace "n:%sid.service%;s:y;p:change;" -ace "n:%sid.NetworkService%;s:y;p:change;" -ace "n:aspnet;p:change;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing sys.osroot.dotnet11.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\install\sys.osroot.dotnet11.ini) do (
    if exist "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      @echo %fs.BinDir%\setacl -on "%systemroot%\microsoft.net\framework\v1.1.4322\%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:res-ts-sysdotnet-rx;p:read_ex" -ace "n:res-ts-sysdotnet-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      @echo.
      %sys.ColorNormal%
    )
  )
)