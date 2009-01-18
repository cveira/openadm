if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\tasks
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "%systemroot%\tasks" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "%systemroot%\tasks" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.CreatorOwner%;s:y;p:profile;i:sc,so,io" -ace "n:%sid.AuthUsers%;s:y;p:read_ex,add_file;i:np" -ace "n:%sid.system%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\tasks
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "%systemroot%\tasks" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "%systemroot%\tasks" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.CreatorOwner%;s:y;p:profile;i:sc,so,io" -ace "n:%sid.AuthUsers%;s:y;p:read_ex,add_file;i:np" -ace "n:%sid.system%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn  -rst "dacl,sacl"

  %sys.ColorNormal%
)