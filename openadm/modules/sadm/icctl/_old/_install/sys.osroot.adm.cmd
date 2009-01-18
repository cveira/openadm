if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.adm.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\install\sys.osroot.adm.ini) do (
    if exist "%systemroot%\system32\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:res-ts-sysadm-rx;p:read_ex" -ace "n:res-ts-sysadm-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

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
  @echo  # [test-mode] processing sys.osroot.adm.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\install\sys.osroot.adm.ini) do (
    if exist "%systemroot%\system32\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
      @echo %fs.BinDir%\setacl -on "%systemroot%\system32\%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:res-ts-sysadm-rx;p:read_ex" -ace "n:res-ts-sysadm-da;p:read_ex;m:deny" -actn clear -clr "dacl,sacl"

      @echo.
      %sys.ColorNormal%
    )
  )
)