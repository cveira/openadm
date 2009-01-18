if exist "%systemroot%\system32\windowspowershell" (
  if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
    @echo.
    @echo  # processing %systemroot%\system32\windowspowershell
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%systemroot%\system32\windowspowershell" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysscript-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysscript-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    %sys.ColorNormal%
  ) else (
    @echo.
    @echo  # [test-mode] processing %systemroot%\system32\windowspowershell
    @echo.

    %sys.ColorDark%

    @echo %fs.BinDir%\setacl -on "%systemroot%\system32\windowspowershell" -ot file -actn ace %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysscript-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysscript-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    %sys.ColorNormal%
  )
)