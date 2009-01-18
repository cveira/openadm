if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\archive
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\archive" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\archive" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-fs-archive;p:change" -ace "n:%COMPUTERNAME%\res-fs-archive-da;p:read_ex;m:deny" -ace "n:%COMPUTERNAME%\res-fs-archive-rx;p:read_ex" -ace "n:%COMPUTERNAME%\role-job-archive;p:change" -actn clear -clr "dacl,sacl"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\archive
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\archive" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "e:\archive" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% %ACL_LOCAL_AUDIT_SYSTEM% -ace "n:%COMPUTERNAME%\res-fs-archive;p:change" -ace "n:%COMPUTERNAME%\res-fs-archive-da;p:read_ex;m:deny" -ace "n:%COMPUTERNAME%\res-fs-archive-rx;p:read_ex" -ace "n:%COMPUTERNAME%\role-job-archive;p:change" -actn clear -clr "dacl,sacl"

  %sys.ColorNormal%
)