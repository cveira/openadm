if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\services\clamwin
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:\services\clamwin" -ot file -actn ace -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%COMPUTERNAME%\¡role-svc-av;p:read_ex" -ace "n:%COMPUTERNAME%\¡role-job-security;p:read_ex"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\services\clamwin
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:\services\clamwin" -ot file -actn ace -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%COMPUTERNAME%\¡role-svc-av;p:read_ex" -ace "n:%COMPUTERNAME%\¡role-job-security;p:read_ex"

  %sys.ColorNormal%
)