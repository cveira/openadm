if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.script.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.script.ini) do (
    if exist "%systemroot%\system32\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      :: %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      :: %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysscript-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysscript-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysscript-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysscript-da;p:read_ex;m:deny"

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
  @echo  # [test-mode] processing sys.osroot.script.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.script.ini) do (
    if exist "%systemroot%\system32\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      :: @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      :: @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysscript-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysscript-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysscript-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysscript-da;p:read_ex;m:deny"

      @echo.
      %sys.ColorNormal%
    )
  )
)