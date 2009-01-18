      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # [test-mode] creating target resources [%VALUE_RESTYPE%-%input.LabelName%]
      @echo.

      if /i %VALUE_RESTYPE:~0,1% NEQ %VALUE_RESTYPE_SYSPRIV% (
        if /i %VALUE_RESPARENT% NEQ %VALUE_RESPARENT_NONE% (
          if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
            @echo # parent resource:      "%VALUE_RESPARENT%"
            @echo # new resource:         "%VALUE_RESLABEL%"
            @echo.

            %sys.ColorDark%

            @echo   + "%VALUE_RESPARENT%\%VALUE_RESLABEL%"

            %sys.ColorNormal%
          ) else (
            setlocal enabledelayedexpansion
              set fs.RootDir="%CD%"

              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%  set fs.RootDir=%fs.FsRootDir%
              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% set fs.RootDir=%fs.WebRootDir%
              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% set fs.RootDir=%fs.FtpRootDir%
              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS%  set fs.RootDir=%fs.TsRootDir%
              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% set fs.RootDir=%fs.VcsRootDir%

              @echo # root directory:       !fs.RootDir!
              @echo # parent resource:      "%VALUE_RESPARENT%"
              @echo # new resource:         "%VALUE_RESLABEL%"
              @echo.

              set user.CurrentDir="%CD%"
              cd /d !fs.RootDir!  >  nul

              %sys.ColorDark%

              for /d /r . %%i in (*"%VALUE_RESPARENT%") do (
                @echo   + "%%~i\%VALUE_RESLABEL%"
              )

              %sys.ColorNormal%

              cd /d !user.CurrentDir!   >  nul
            endlocal
          )
        )
      ) else (
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
          setlocal enabledelayedexpansion
            set service.IsRegistered=%STATUS_OFF%

            if /i %VALUE_RESLABEL:~0,2% NEQ db (
              set service.IsRegistered=%STATUS_ON%

              set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\db
              set service.CurrentResLabel=%VALUE_RESLABEL:db=%
            )

            if /i %VALUE_RESLABEL:~0,3% NEQ web (
              set service.IsRegistered=%STATUS_ON%

              set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\web
              set service.CurrentResLabel=%VALUE_RESLABEL:web=%
            )

            if /i %VALUE_RESLABEL:~0,3% NEQ ftp (
              set service.IsRegistered=%STATUS_ON%

              set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\ftp
              set service.CurrentResLabel=%VALUE_RESLABEL:ftp=%
            )

            if /i %VALUE_RESLABEL:~0,3% NEQ vcs (
              set service.IsRegistered=%STATUS_ON%

              set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\vcs
              set service.CurrentResLabel=%VALUE_RESLABEL:vcs=%
            )

            if !service.IsRegistered! EQU %STATUS_OFF% (
              @echo # parent resource:      "%fs.ServicesRootDir%"
              @echo # new resource:         "%VALUE_RESLABEL%"
              @echo.

              %sys.ColorDark%

              @echo   + "%fs.ServicesRootDir%\%VALUE_RESLABEL%"

              %sys.ColorNormal%
            ) else (
              @echo # parent resource:      "!fs.CurrentBackupRootDir!"
              @echo # new resource:         "%service.CurrentResLabel%"
              @echo.

              %sys.ColorDark%

              @echo   + "!fs.CurrentBackupRootDir!\%service.CurrentResLabel%"

              %sys.ColorNormal%

              @echo.
              @echo # parent resource:      "%fs.ServicesRootDir%"
              @echo # new resource:         "%service.CurrentResLabel%"
              @echo.

              %sys.ColorDark%

              @echo   + "%fs.ServicesRootDir%\%service.CurrentResLabel%"

              %sys.ColorNormal%
            )
          endlocal
        ) else (
          @echo # parent resource:      "%VALUE_RESPARENT%"
          @echo # new resource:         "%VALUE_RESLABEL%"
          @echo.

          %sys.ColorDark%

          @echo   + "%VALUE_RESPARENT%\%VALUE_RESLABEL%"

          %sys.ColorNormal%
        )
      )