if exist "%systemroot%\servicepackfiles" (
  if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
    @echo.
    @echo  # processing %systemroot%\servicepackfiles
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%systemroot%\servicepackfiles" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysadm-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysadm-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    %sys.ColorNormal%
  ) else (
    @echo.
    @echo  # [test-mode] processing %systemroot%\servicepackfiles
    @echo.

    %sys.ColorDark%

    @echo %fs.BinDir%\setacl -on "%systemroot%\servicepackfiles" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-ts-sysadm-rx;p:read_ex" -ace "n:%COMPUTERNAME%\res-ts-sysadm-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    %sys.ColorNormal%
  )
)