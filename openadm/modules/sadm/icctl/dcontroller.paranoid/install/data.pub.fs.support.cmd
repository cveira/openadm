if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\pub\fs\support
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\fs\support" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\pub\fs\support" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM%

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\pub\fs\support\doc
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\fs\support\doc" -ot file -actn ace -ace "n:%ds.domain%\res-fs-doc;p:change" -ace "n:%ds.domain%\res-fs-doc-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-doc-rx;p:read_ex" -ace "n:%ds.domain%\¡sys-job-system;p:change" -ace "n:%ds.domain%\¡sys-job-security;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%


  @echo.
  @echo  # processing e:\pub\fs\support\export
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\pub\fs\support\export" -ot file -actn ace -ace "n:%ds.domain%\res-fs-export;p:change" -ace "n:%ds.domain%\res-fs-export-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-export-rx;p:read_ex" -ace "n:%ds.domain%\sys-job-replication;p:change"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\pub\fs\support
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\fs\support" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "e:\pub\fs\support" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM%

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\pub\fs\support\doc
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\fs\support\doc" -ot file -actn ace -ace "n:%ds.domain%\res-fs-doc;p:change" -ace "n:%ds.domain%\res-fs-doc-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-doc-rx;p:read_ex" -ace "n:%ds.domain%\¡sys-job-system;p:change" -ace "n:%ds.domain%\¡sys-job-security;p:change"

  %sys.ColorNormal%


  @echo.
  @echo  # [test-mode] processing e:\pub\fs\support\export
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\pub\fs\support\export" -ot file -actn ace -ace "n:%ds.domain%\res-fs-export;p:change" -ace "n:%ds.domain%\res-fs-export-da;p:read_ex;m:deny" -ace "n:%ds.domain%\res-fs-export-rx;p:read_ex" -ace "n:%ds.domain%\sys-job-replication;p:change"

  %sys.ColorNormal%
)