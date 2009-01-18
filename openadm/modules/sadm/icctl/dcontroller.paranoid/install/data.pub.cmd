if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\pub" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -ace "n:%ds.domain%\sys-job-replication;p:change" -ace "n:%ds.domain%\sys-job-archive;p:change" -actn clear -clr "dacl,sacl"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\pub
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "e:\pub" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -ace "n:%ds.domain%\sys-job-replication;p:change" -ace "n:%ds.domain%\sys-job-archive;p:change" -actn clear -clr "dacl,sacl"

  %sys.ColorNormal%
)