set sys.osroot.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.system32.exclusions.ini) do (
  set sys.osroot.system32.exclusions=!sys.osroot.system32.exclusions! -fltr "%%~i"
)

set sys.osroot.system32.exclusions=%sys.osroot.system32.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\system32
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\system32" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.osroot.system32.exclusions%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\system32
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\system32" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.osroot.system32.exclusions%

  %sys.ColorNormal%
)