if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub\fs
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\fs" -ot file -actn ace -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:sc,np"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\pub\fs
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\fs" -ot file -actn ace -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:sc,np"

  %sys.ColorNormal%
)