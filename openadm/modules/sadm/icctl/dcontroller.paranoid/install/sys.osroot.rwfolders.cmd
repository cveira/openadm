if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.rwfolders.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.rwfolders.ini) do (
    if exist "%systemroot%\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\setacl -on "%systemroot%\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      %fs.BinDir%\setacl -on "%systemroot%\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

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
  @echo  # [test-mode] processing sys.osroot.rwfolders.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.rwfolders.ini) do (
    if exist "%systemroot%\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      @echo %fs.BinDir%\setacl -on "%systemroot%\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      @echo %fs.BinDir%\setacl -on "%systemroot%\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%sid.system%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

      @echo.
      %sys.ColorNormal%
    )
  )
)