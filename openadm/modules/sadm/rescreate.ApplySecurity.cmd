  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo # securing resources [%VALUE_RESTYPE%-%input.LabelName%]
  @echo.

  if /i %VALUE_RESTYPE:~0,1% NEQ %VALUE_RESTYPE_SYSPRIV% (
    if /i %VALUE_RESPARENT% NEQ %VALUE_RESPARENT_NONE% (
      setlocal enabledelayedexpansion
        set fs.RootDir="%CD%"

        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%  set fs.RootDir=%fs.FsRootDir%
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% set fs.RootDir=%fs.WebRootDir%
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% set fs.RootDir=%fs.FtpRootDir%
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS%  set fs.RootDir=%fs.TsRootDir%
        if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% set fs.RootDir=%fs.VcsRootDir%

        @echo # parent resource:      "%VALUE_RESPARENT%"
        @echo # target resource:      "%VALUE_RESLABEL%"
        @echo.

        set user.CurrentDir="%CD%"
        cd /d !fs.RootDir!  >  nul

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULT% (
          if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
            %sys.ColorDark%

            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )

            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_DEFAULT_PROFILE_FS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )

            @echo.
            %sys.ColorNormal%
          ) else (
            for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
              @echo   + "%%~i"

              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%%~i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_DEFAULT_PROFILE_FS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            )
          )
        )

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULTINHERIT% (
          if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_DEFAULT_PROFILE_FS%

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )
          ) else (
            if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot reg -actn ace %ACL_USER_DEFAULT_PROFILE_REG%

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            ) else (
              for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
                @echo   + "%%~i"

                %sys.ColorDark%

                %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_DEFAULT_PROFILE_FS%

                if %errorlevel% EQU %EL_SETACL_OK% (
                  @echo     + acl operation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + acl operation status: FAIL
                )

                @echo.
                %sys.ColorNormal%
              )
            )
          )
        )

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULL% (
          if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
            %sys.ColorDark%

            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )

            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_FULL_PROFILE_FS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )

            @echo.
            %sys.ColorNormal%
          ) else (
            for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
              @echo   + "%%~i"

              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%%~i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_FULL_PROFILE_FS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            )
          )
        )

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULLINHERIT% (
          if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
            %sys.ColorDark%

            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_FULL_PROFILE_FS%

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )

            @echo.
            %sys.ColorNormal%
          ) else (
            for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
              @echo   + "%%~i"

              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_FULL_PROFILE_FS%

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            )
          )
        )

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% (
            if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_VCS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            ) else (
              for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
                @echo   + "%%~i"

                %sys.ColorDark%

                %fs.BinDir%\setacl -on "%%~i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

                if %errorlevel% EQU %EL_SETACL_OK% (
                  @echo     + acl operation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + acl operation status: FAIL
                )

                %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_VCS% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"

                if %errorlevel% EQU %EL_SETACL_OK% (
                  @echo     + acl operation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + acl operation status: FAIL
                )

                @echo.
                %sys.ColorNormal%
              )
            )
          ) else (
            if /i %VALUE_RESPARENT:~1,1% EQU %VALUE_RESPARENT_ISDRIVE% (
              %sys.ColorDark%

              %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )


              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
                %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_ROLE% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
              )

              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
                %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_SVC% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
              )

              if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
                %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_JOB% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
              )


              if %errorlevel% EQU %EL_SETACL_OK% (
                @echo     + acl operation status: OK
              ) else (
                @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                @echo     + acl operation status: FAIL
              )

              @echo.
              %sys.ColorNormal%
            ) else (
              for /d /r . %%i in (*"%VALUE_RESLABEL%") do (
                @echo   + "%%~i"

                %sys.ColorDark%

                %fs.BinDir%\setacl -on "%%~i" -ot file -actn setprot -op "dacl:p_c;sacl:p_c"

                if %errorlevel% EQU %EL_SETACL_OK% (
                  @echo     + acl operation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + acl operation status: FAIL
                )


                if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
                  %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_ROLE% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
                )

                if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
                  %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_SVC% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
                )

                if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
                  %fs.BinDir%\setacl -on "%%~i" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_JOB% %ACL_SYSTEM_PROFILE_FS% -actn clear -clr "dacl,sacl"
                )


                if %errorlevel% EQU %EL_SETACL_OK% (
                  @echo     + acl operation status: OK
                ) else (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
                  @echo     + acl operation status: FAIL
                )

                @echo.
                %sys.ColorNormal%
              )
            )
          )
        )

        if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_BIT% (
          %sys.ColorDark%

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% (
            %fs.BinDir%\setacl -on "%VALUE_RESLABEL%" -ot prn -actn ace %ACL_USER_BIT_PROFILE_PRN%

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% (
            %fs.BinDir%\setacl -on "%VALUE_RESLABEL%" -ot srv -actn ace %ACL_USER_BIT_PROFILE_SCM%

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )
          )

          if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
            %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot reg -actn ace %ACL_USER_BIT_PROFILE_REG%

            if %errorlevel% EQU %EL_SETACL_OK% (
              @echo     + acl operation status: OK
            ) else (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
              @echo     + acl operation status: FAIL
            )
          )

          @echo.
          %sys.ColorNormal%
        )

        cd /d !user.CurrentDir!  >  nul
      endlocal
    )
  ) else (
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
      setlocal enabledelayedexpansion
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

        if !service.IsRegistered! EQU %STATUS_OFF% (
          @echo # parent resource:      "%fs.ServicesRootDir%"
          @echo # target resource:      "%VALUE_RESLABEL%"
          @echo.

          @echo   + %fs.ServicesRootDir%\%VALUE_RESLABEL%

          %sys.ColorDark%

          %fs.BinDir%\setacl -on "%fs.ServicesRootDir%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_SVC_SYSPRIV%

          if %errorlevel% EQU %EL_SETACL_OK% (
            @echo     + acl operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + acl operation status: FAIL
          )

          @echo.
          %sys.ColorNormal%
        ) else (
          @echo # parent resource:      "!fs.CurrentBackupRootDir!"
          @echo # target resource:      "%service.CurrentResLabel%"
          @echo.

          @echo   + !fs.CurrentBackupRootDir!\%service.CurrentResLabel%

          %sys.ColorDark%

          %fs.BinDir%\setacl -on "!fs.CurrentBackupRootDir!\%service.CurrentResLabel%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_SVC_SYSPRIV%

          if %errorlevel% EQU %EL_SETACL_OK% (
            @echo     + acl operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + acl operation status: FAIL
          )

          @echo.
          %sys.ColorNormal%

          @echo # parent resource:      "%fs.ServicesRootDir%"
          @echo # target resource:      "%service.CurrentResLabel%"
          @echo.

          @echo   + %fs.ServicesRootDir%\%VALUE_RESLABEL:db=%

          %sys.ColorDark%

          %fs.BinDir%\setacl -on "%fs.ServicesRootDir%\%service.CurrentResLabel%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_SVC_SYSPRIV%

          if %errorlevel% EQU %EL_SETACL_OK% (
            @echo     + acl operation status: OK
          ) else (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
            @echo     + acl operation status: FAIL
          )

          @echo.
          %sys.ColorNormal%
        )
      endlocal
    ) else (
      @echo # parent resource:      "%VALUE_RESPARENT%"
      @echo # target resource:      "%VALUE_RESLABEL%"
      @echo.

      @echo   + "%VALUE_RESPARENT%\%VALUE_RESLABEL%"

      %sys.ColorDark%

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
        %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_ROLE_SYSPRIV%
      ) else (
        %fs.BinDir%\setacl -on "%VALUE_RESPARENT%\%VALUE_RESLABEL%" -ot file -actn ace %ACL_USER_SINGLE_PROFILE_JOB_SYSPRIV%
      )

      if %errorlevel% EQU %EL_SETACL_OK% (
        @echo     + acl operation status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + acl operation status: FAIL
      )

      @echo.
      %sys.ColorNormal%
    )
  )