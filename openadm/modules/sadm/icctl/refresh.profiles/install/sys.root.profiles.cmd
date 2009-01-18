set fs.ProfilesDir=
for /f "delims=\ tokens=1,2,*" %%i in ("%UserProfile%") do set fs.ProfilesDir=%%i\%%j

set sys.root.profiles.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\sys.root.profiles.exclusions.ini) do (
  set sys.root.profiles.exclusions=!sys.root.profiles.exclusions! -fltr "%%~i"
)

set sys.root.profiles.exclusions=%sys.root.profiles.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %fs.ProfilesDir%\*.*
  @echo.

  for /d %%i in ("%fs.ProfilesDir%\*.*") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.root.profiles.exclusions%

    if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    @echo.
    %sys.ColorNormal%
  )
) else (
  @echo.
  @echo  # [test-mode] processing %fs.ProfilesDir%\*.*
  @echo.

  for /d %%i in ("%fs.ProfilesDir%\*.*") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    @echo %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %sys.root.profiles.exclusions%

    @echo.
    %sys.ColorNormal%
  )
)