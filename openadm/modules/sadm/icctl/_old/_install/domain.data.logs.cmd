if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\logs
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\logs" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:sys-job-local;p:change" -ace "n:res-fs-logs;p:change" -ace "n:res-fs-logs-da;p:read_ex;m:deny" -ace "n:res-fs-logs-rx;p:read_ex" -actn clear -clr "dacl,sacl"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @rem @echo.
  @rem @echo  # processing e:\logs\desktop.ini
  @rem @echo.
  @rem
  @rem %sys.ColorDark%
  @rem
  @rem %fs.BinDir%\setacl -on "e:\logs\desktop.ini" -ot file -actn setprot -op "sacl:p_c"
  @rem %fs.BinDir%\setacl -on "e:\logs\desktop.ini" -ot file -actn ace %ACL_AUDIT_SYSTEM% -actn clear -clr "sacl"
  @rem
  @rem if %errorlevel% NEQ %EL_SETACL_OK% (
  @rem   @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
  @rem   @echo    + operation status: FAIL
  @rem ) else (
  @rem   @echo    + operation status: OK
  @rem )
  @rem
  @rem %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\coredump
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\coredump" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\msfw
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\msfw" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\logs\sysmon
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\logs\sysmon" -ot file -actn ace -ace "n:%sid.NetworkService%;s:y;p:change"

  if %errorlevel% NEQ %EL_SETACL_OK% (
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
  @echo %fs.BinDir%\setacl -on "e:\logs" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:sys-job-local;p:change" -ace "n:res-fs-logs;p:change" -ace "n:res-fs-logs-da;p:read_ex;m:deny" -ace "n:res-fs-logs-rx;p:read_ex" -actn clear -clr "dacl,sacl"

  %sys.ColorNormal%


  @rem @echo.
  @rem @echo  # [test-mode] processing e:\logs\desktop.ini
  @rem @echo.
  @rem
  @rem %sys.ColorDark%
  @rem
  @rem @echo %fs.BinDir%\setacl -on "e:\logs\desktop.ini" -ot file -actn setprot -op "sacl:p_c"
  @rem @echo %fs.BinDir%\setacl -on "e:\logs\desktop.ini" -ot file -actn ace %ACL_AUDIT_SYSTEM% -actn clear -clr "sacl"
  @rem
  @rem %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\coredump
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\coredump" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\msfw
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\msfw" -ot file -actn ace -ace "n:%sid.system%;s:y;p:change"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\logs\sysmon
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\logs\sysmon" -ot file -actn ace -ace "n:%sid.NetworkService%;s:y;p:change"

  %sys.ColorNormal%
)