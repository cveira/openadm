set fs.ProfilesDir=
for /f "delims=\ tokens=1,2,*" %%i in ("%UserProfile%") do set fs.ProfilesDir=%%i\%%j

set sys.root.profilesroot.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.root.profilesroot.exclusions.ini) do (
  set sys.root.profilesroot.exclusions=!sys.root.profilesroot.exclusions! -fltr "%%~i"
)

set sys.root.profilesroot.exclusions=%sys.root.profilesroot.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %fs.ProfilesDir%
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%fs.ProfilesDir%" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.root.profilesroot.exclusions%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %fs.ProfilesDir%
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%fs.ProfilesDir%" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.root.profilesroot.exclusions%

  %sys.ColorNormal%
)