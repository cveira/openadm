set data.pub.fs.users.exclusions=

for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\conf\data.pub.fs.users.exclusions.ini) do (
  set data.pub.fs.users.exclusions=!data.pub.fs.users.exclusions! -fltr "%%~i"
)

set data.pub.fs.users.exclusions=%data.pub.fs.users.exclusions:-fltr ""=%


if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub\fs\users\*.*
  @echo.

  for /d %%i in ("e:\pub\fs\users\*.*") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %data.pub.fs.users.exclusions%
    
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
  @echo  # [test-mode] processing e:\pub\fs\users\*.*
  @echo.

  for /d %%i in ("%fs.ProfilesDir%\*.*") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    @echo %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %data.pub.fs.users.exclusions%

    @echo.
    %sys.ColorNormal%
  )
)