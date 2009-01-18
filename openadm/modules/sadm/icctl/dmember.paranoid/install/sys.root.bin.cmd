if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing c:\bin
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "c:\bin" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "c:\bin" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -actn clear -clr "dacl,sacl"

  if {!errorlevel!} NEQ {%EL_SETACL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing c:\bin
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "c:\bin" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "c:\bin" -ot file -actn ace %ACL_LOCAL_SYSTEM_PROFILE% -ace "n:%sid.AuthUsers%;s:y;p:list_folder;i:np" -actn clear -clr "dacl,sacl"

  %sys.ColorNormal%
)