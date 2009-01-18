      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # [test-mode] resetting security on target resource(s)
      @echo.

      if /i %VALUE_RESTYPE:~0,1% NEQ %VALUE_RESTYPE_SYSPRIV% (
        if /i %VALUE_RESPARENT% NEQ %VALUE_RESPARENT_NONE% (
          set fs.RootDir="%CD%"
          set target.TypeIsFs=%STATUS_OFF%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%  set fs.RootDir=%fs.FsRootDir%  && set target.TypeIsFs=%STATUS_OK%
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% set fs.RootDir=%fs.WebRootDir% && set target.TypeIsFs=%STATUS_OK%
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% set fs.RootDir=%fs.FtpRootDir% && set target.TypeIsFs=%STATUS_OK%
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS%  set fs.RootDir=%fs.TsRootDir%  && set target.TypeIsFs=%STATUS_OK%
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% set fs.RootDir=%fs.VcsRootDir% && set target.TypeIsFs=%STATUS_OK%

          @echo # parent resource:      "%VALUE_RESPARENT%"
          @echo # target resource:      "%VALUE_RESLABEL%"
          @echo.

          set user.CurrentDir="%CD%"
          cd /d %fs.RootDir%  >  nul

          if /i %target.TypeIsFs% EQU %STATUS_OK% (
            if /i %VALUE_RESPARENT:~0,2% EQU %VALUE_RESPARENT_ISDRIVE% (
              %sys.ColorDark%

              @echo   %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"

              %sys.ColorNormal%
            ) else (
              for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
                @echo   + "%%~i"

                %sys.ColorDark%

                @echo     %fs.BinDir%\setacl -on "%%i" -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"

                @echo.
                %sys.ColorNormal%
              )
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot reg -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"

            %sys.ColorNormal%
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% (
            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%VALUE_RESLABEL%" -ot prn -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"

            %sys.ColorNormal%
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% (
            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%VALUE_RESLABEL%" -ot srv -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"

            %sys.ColorNormal%
          )

          cd /d %user.CurrentDir%  >  nul
        )
      ) else (
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
          set service.IsRegistered=%STATUS_OFF%

          if /i %VALUE_RESLABEL:~0,2% EQU db (
            set service.IsRegistered=%STATUS_ON%

            set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\db
            set service.CurrentResLabel=%VALUE_RESLABEL:db=%
          )

          if /i %VALUE_RESLABEL:~0,3% EQU web (
            set service.IsRegistered=%STATUS_ON%

            set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\web
            set service.CurrentResLabel=%VALUE_RESLABEL:web=%
          )

          if /i %VALUE_RESLABEL:~0,3% EQU ftp (
            set service.IsRegistered=%STATUS_ON%

            set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\ftp
            set service.CurrentResLabel=%VALUE_RESLABEL:ftp=%
          )

          if /i %VALUE_RESLABEL:~0,3% EQU vcs (
            set service.IsRegistered=%STATUS_ON%

            set fs.CurrentBackupRootDir=%fs.BackupRootDir%\day\vcs
            set service.CurrentResLabel=%VALUE_RESLABEL:vcs=%
          )

          if %service.IsRegistered% EQU %STATUS_OFF% (
            @echo # parent resource:      "%fs.ServicesRootDir%"
            @echo # target resource:      "%VALUE_RESLABEL%"
            @echo.

            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%fs.ServicesRootDir%\%VALUE_RESLABEL%" -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"                >  nul

            %sys.ColorNormal%
          ) else (
            @echo # parent resource:      "%fs.CurrentBackupRootDir%"
            @echo # target resource:      "%service.CurrentResLabel%"
            @echo.

            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%fs.CurrentBackupRootDir%\%service.CurrentResLabel%" -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"  >  nul

            %sys.ColorNormal%
            @echo.

            @echo # parent resource:      "%fs.ServicesRootDir%"
            @echo # target resource:      "%service.CurrentResLabel%"
            @echo.

            %sys.ColorDark%

            @echo   %fs.BinDir%\setacl -on "%fs.ServicesRootDir%\%service.CurrentResLabel%" -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"       >  nul

            %sys.ColorNormal%
          )
        ) else (
          @echo # parent resource:      "%VALUE_RESPARENT%"
          @echo # target resource:      "%VALUE_RESLABEL%"
          @echo.

          %sys.ColorDark%

          @echo   %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -ot file -actn clear -clr "dacl,sacl" -actn setprot -op "dacl:np;sacl:np" -rec cont_obj -actn rstchldrn -rst "dacl,sacl"             >  nul

          %sys.ColorNormal%

          @echo.
        )
      )