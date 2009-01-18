set sys.osroot.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.osroot.exclusions.ini) do (
  set sys.osroot.exclusions=!sys.osroot.exclusions! -fltr "%%~i"
)

set sys.osroot.exclusions=%sys.osroot.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %sys.osroot.exclusions%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %sys.osroot.exclusions%

  %sys.ColorNormal%
)