if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing d:\temp
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "d:\temp" -ot file -actn ace -ace "n:%sid.administrators%;s:y;p:full" -ace "n:%sid.system%;s:y;p:full" -ace "n:%sid.CreatorOwner%;s:y;p:full;i:sc,so,io" -ace "n:%sid.PowerUsers%;s:y;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing d:\temp
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "d:\temp" -ot file -actn ace -ace "n:%sid.administrators%;s:y;p:full" -ace "n:%sid.system%;s:y;p:full" -ace "n:%sid.CreatorOwner%;s:y;p:full;i:sc,so,io" -ace "n:%sid.PowerUsers%;s:y;p:change"

  %sys.ColorNormal%
)