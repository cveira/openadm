if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing e:\recycler
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\setacl -on "e:\recycler" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  %fs.BinDir%\setacl -on "e:\recycler" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.CreatorOwner%;s:y;p:full;i:sc,so,io" -ace "n:%sid.users%;s:y;p:read_ex;" -ace "n:%sid.users%;s:y;p:add_subdir;i:sc" -ace "n:%sid.users%;s:y;p:add_file;i:sc" -ace "n:%sid.system%;s:y;p:full;" -ace "n:%sid.administrators%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn -rst "dacl,sacl"

  if %errorlevel% NEQ %EL_SETACL_OK% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
    @echo    + operation status: FAIL
  ) else (
    @echo    + operation status: OK
  )

  %sys.ColorNormal%
) else (
  @echo.
  @echo  # [test-mode] processing e:\recycler
  @echo.

  %sys.ColorDark%

  @echo %fs.BinDir%\setacl -on "e:\recycler" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
  @echo %fs.BinDir%\setacl -on "e:\recycler" -ot file -actn ace %ACL_SYSTEM_PROFILE% -ace "n:%sid.CreatorOwner%;s:y;p:full;i:sc,so,io" -ace "n:%sid.users%;s:y;p:read_ex;" -ace "n:%sid.users%;s:y;p:add_subdir;i:sc" -ace "n:%sid.users%;s:y;p:add_file;i:sc" -ace "n:%sid.system%;s:y;p:full;" -ace "n:%sid.administrators%;s:y;p:full;" -actn clear -clr "dacl,sacl" -actn rstchldrn -rst "dacl,sacl"

  %sys.ColorNormal%
)