set sys.root.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\install\sys.root.exclusions.ini) do (
  set sys.root.exclusions=!sys.root.exclusions! -fltr "%%~i"
)

set sys.root.exclusions=%sys.root.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo  # processing c:\
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -ace "n:%sid.system%;s:y;p:full;i:np" -actn clear -clr "dacl,sacl" %sys.root.exclusions%

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo  # [test-mode] processing c:\
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -ace "n:%sid.system%;s:y;p:full;i:np" -actn clear -clr "dacl,sacl" %sys.root.exclusions%

  %sys.ColorNormal%
)