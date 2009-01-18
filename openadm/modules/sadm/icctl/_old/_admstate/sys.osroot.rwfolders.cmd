if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing sys.osroot.rwfolders.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\admstate\sys.osroot.rwfolders.ini) do (
    if exist "%systemroot%\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

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
  @echo  # [test-mode] processing sys.osroot.rwfolders.ini
  @echo.

  for /f "eol=# tokens=*" %%i in (%fs.ModulesDir%\admstate\sys.osroot.rwfolders.ini) do (
    if exist "%systemroot%\%%i" (
      @echo    + %%i
      @echo.

      %sys.ColorDark%

      @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace -ace "n:%sid.system%;s:y;p:full"

      @echo.
      %sys.ColorNormal%
    )
  )
)