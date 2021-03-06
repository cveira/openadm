if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\$*$.
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\attrib -h "%systemroot%\$*$." /d /s

  %sys.ColorNormal%
  @echo.

  for /d %%i in ("%systemroot%\$*$.") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    :: %fs.BinDir%\setacl -on "%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
    :: %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -actn clear -clr "dacl,sacl" -actn rstchldrn -rst "dacl,sacl"

    %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysadm-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysadm-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    @echo.
    %sys.ColorNormal%
  )

  %sys.ColorDark%

  %fs.BinDir%\attrib +h "%systemroot%\$*$." /d /s

  %sys.ColorNormal%
  @echo.
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\$*$.
  @echo.

  %sys.ColorDark%

  for /d %%i in ("%systemroot%\$*$.") do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    :: @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
    :: @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -actn clear -clr "dacl,sacl" -actn rstchldrn -rst "dacl,sacl"

    @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_DOMAIN_SYSTEM_PROFILE% %ACL_DOMAIN_AUDIT_SYSTEM% -ace "n:%ds.domain%\res-ts-sysadm-rx;p:read_ex" -ace "n:%ds.domain%\res-ts-sysadm-da;p:read_ex;m:deny" -actn rstchldrn -rst "dacl,sacl"

    @echo.
    %sys.ColorNormal%
  )
)