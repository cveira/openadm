    set TargetResource.TypeIsFS=%STATUS_OFF%

    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%    set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%     set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%     set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%      set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB%     set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP%     set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS%      set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DB%      set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS%     set TargetResource.TypeIsFS=%STATUS_ON%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_UR%      set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DR%      set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_RAS%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VPN%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FW%      set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_MAIL%    set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_CHAT%    set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VMM%     set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DCOM%    set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_APPROLE% set TargetResource.TypeIsFS=%STATUS_OFF%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ELOG%    set TargetResource.TypeIsFS=%STATUS_OFF%

    set user.CurrentDir="%CD%"

    if %TargetResource.TypeIsFS% EQU %STATUS_ON% (
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # resource instances on: %fs.ServicesRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.ServicesRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do @echo   %%i

        %sys.ColorNormal%

        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # resource instances on: %fs.BackupRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.BackupRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do @echo   %%i

        %sys.ColorNormal%

        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # resource instances on: %fs.ArchiveRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.ArchiveRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do @echo   %%i

        %sys.ColorNormal%
      ) else (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # resource instances on: %fs.CurrentRootDir%
        @echo.

        %sys.ColorDark%

        for /d /r . %%i in (%VALUE_RESLABEL%) do @echo   %%i

        %sys.ColorNormal%
      )


      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # ACL layout of resource instances on: %fs.ServicesRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.ServicesRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do (
          %fs.BinDir%\setacl -on %%i -ot file -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%

          if !errorlevel! EQU %EL_SETACL_OK% (
            @echo     + operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + operation status: FAIL
          )
        )

        %sys.ColorNormal%

        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # ACL layout of resource instances on: %fs.BackupRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.BackupRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do (
          %fs.BinDir%\setacl -on %%i -ot file -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%

          if !errorlevel! EQU %EL_SETACL_OK% (
            @echo     + operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + operation status: FAIL
          )
        )

        %sys.ColorNormal%

        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # ACL layout of resource instances on: %fs.ArchiveRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.ArchiveRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do (
          %fs.BinDir%\setacl -on %%i -ot file -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%

          if !errorlevel! EQU %EL_SETACL_OK% (
            @echo     + operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + operation status: FAIL
          )
        )

        %sys.ColorNormal%
      ) else (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # ACL layout of resource instances on: %fs.CurrentRootDir%
        @echo.

        %sys.ColorDark%

        cd /d %fs.CurrentRootDir% > nul

        for /d /r . %%i in (%VALUE_RESLABEL%) do (
          %fs.BinDir%\setacl -on %%i -ot file -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%

          if !errorlevel! EQU %EL_SETACL_OK% (
            @echo     + operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + operation status: FAIL
          )
        )

        %sys.ColorNormal%
      )
    ) else (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # ACL layout of resource: %VALUE_RESLABEL%
      @echo.

      %sys.ColorDark%

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% %fs.BinDir%\setacl -on %VALUE_RESLABEL% -ot reg -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% %fs.BinDir%\setacl -on %VALUE_RESLABEL% -ot srv -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% %fs.BinDir%\setacl -on %VALUE_RESLABEL% -ot prn -actn list -lst "f:tab;w:d,s,o,g;i:y;s:b" -rec cont | %fs.BinDir%\findstr /i %SET_RESLABEL%

      if !errorlevel! EQU %EL_SETACL_OK% (
        @echo     + operation status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + operation status: FAIL
      )

      %sys.ColorNormal%
    )