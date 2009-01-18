if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
  @echo.
  @echo  # processing %systemroot%\*.exe
  @echo.

  for %%i in (%systemroot%\*.exe) do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\setacl -on "%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
    %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -actn clear -clr "dacl,sacl"

    if %errorlevel% NEQ %EL_SETACL_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
      @echo    + operation status: FAIL
    ) else (
      @echo    + operation status: OK
    )

    @echo.
    %sys.ColorNormal%
  )
) else (
  @echo.
  @echo  # [test-mode] processing %systemroot%\*.exe
  @echo.

  for %%i in (%systemroot%\*.exe) do (
    @echo    + %%i
    @echo.

    %sys.ColorDark%

    @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"
    @echo %fs.BinDir%\setacl -on "%%i" -ot file -actn ace %ACL_SYSTEM_PROFILE% %ACL_AUDIT_SYSTEM% -ace "n:%sid.AuthUsers%;s:y;p:read_ex" -actn clear -clr "dacl,sacl"

    @echo.
    %sys.ColorNormal%
  )
)