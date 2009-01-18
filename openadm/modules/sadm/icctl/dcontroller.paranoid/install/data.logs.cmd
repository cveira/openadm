if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\logs
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\logs" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\sys-job-local;p:change" -ace "n:%ds.domain%\res-fs-logs;p:change" -ace "n:%ds.domain%\res-fs-logs-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-logs-rx;p:read_ex" -actn clear -clr "dacl,sacl"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\os\coredump
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\os\coredump" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\net\msfw
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\net\msfw" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\os\sysmon
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\os\sysmon" -ot file -actn ace -ace "n:%sid.NetworkService%;s:y;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\logs
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "e:\logs" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\sys-job-local;p:change" -ace "n:%ds.domain%\res-fs-logs;p:change" -ace "n:%ds.domain%\res-fs-logs-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-logs-rx;p:read_ex" -actn clear -clr "dacl,sacl"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\os\coredump
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\os\coredump" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\net\msfw
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\net\msfw" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\os\sysmon
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\os\sysmon" -ot file -actn ace -ace "n:%sid.NetworkService%;s:y;p:change"

  %sys.ColorNormal%
)