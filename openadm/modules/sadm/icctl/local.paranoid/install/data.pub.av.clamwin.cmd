if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub\av\clamwin
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\av\clamwin" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%COMPUTERNAME%\�role-svc-av;p:change" -ace "n:%COMPUTERNAME%\�role-job-security;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\pub\av\clamwin
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\av\clamwin" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -ace "n:%COMPUTERNAME%\�role-svc-av;p:change" -ace "n:%COMPUTERNAME%\�role-job-security;p:change"

  %sys.ColorNormal%
)