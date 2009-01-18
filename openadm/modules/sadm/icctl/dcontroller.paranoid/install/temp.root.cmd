set temp.root.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\temp.root.exclusions.ini) do (
  set temp.root.exclusions=!temp.root.exclusions! -fltr "%%~i"
)

set temp.root.exclusions=%temp.root.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo  # processing d:\
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "d:" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.system%;s:y;p:full;i:np" -actn clear -clr "dacl,sacl" %temp.root.exclusions%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo  # [test-mode] processing d:\
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "d:" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% -ace "n:%sid.system%;s:y;p:full;i:np" -actn clear -clr "dacl,sacl" %temp.root.exclusions%

  %sys.ColorNormal%
)