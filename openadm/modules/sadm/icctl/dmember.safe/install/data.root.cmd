set data.root.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\data.root.exclusions.ini) do (
  set data.root.exclusions=!data.root.exclusions! -fltr "%%~i"
)

set data.root.exclusions=%data.root.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo  # processing e:\
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %data.root.exclusions%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo  # [test-mode] processing e:\
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %data.root.exclusions%

  %sys.ColorNormal%
)