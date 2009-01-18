    @echo # retrieving objects from selected resource
    @echo.

    %sys.ColorDark%

    @echo #  looking up target resource: %SecurityGroup.RootName%
    @echo.

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
      %sys.ColorDark%

      wmic group where "name like '%SecurityGroup.RootName%%'" list brief

      if !errorlevel! EQU %EL_STATUS_OK% (
        @echo     + operation status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + operation status: FAIL
      )

      %sys.ColorNormal%

      if /i %VALUE_VIEWMODE% EQU %VALUE_VIEWMODE_FULL% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo #  looking up member objects:
        @echo.

        %sys.ColorDark%

        wmic group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption

        if !errorlevel! EQU %EL_STATUS_OK% (
          @echo     + operation status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + operation status: FAIL
        )

        %sys.ColorNormal%
      )
    )


    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
      %sys.ColorDark%

      if /i "%COMPUTERNAME%" EQU "%ds.server%" (
        wmic group where "name like '%SecurityGroup.RootName%%'" list brief
      ) else (
        wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%SecurityGroup.RootName%%'" list brief
      )

      if !errorlevel! EQU %EL_STATUS_OK% (
        @echo     + operation status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + operation status: FAIL
      )

      %sys.ColorNormal%

      if /i %VALUE_VIEWMODE% EQU %VALUE_VIEWMODE_FULL% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo #  looking up member objects:
        @echo.

        %sys.ColorDark%

        if /i "%COMPUTERNAME%" EQU "%ds.server%" (
          wmic group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption
        ) else (
          wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption
        )

        if !errorlevel! EQU %EL_STATUS_OK% (
          @echo     + operation status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + operation status: FAIL
        )

        %sys.ColorNormal%
      )
    )


    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
      %sys.ColorDark%

      %fs.BinDir%\dsquery group domainroot -name %SecurityGroup.RootName%* -desc %SecurityGroup.RootName%* -s %ds.server% -u %ds.user% -p %ds.passwd%

      if !errorlevel! EQU %EL_STATUS_OK% (
        @echo     + operation status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + operation status: FAIL
      )

      %sys.ColorNormal%

      if /i %VALUE_VIEWMODE% EQU %VALUE_VIEWMODE_FULL% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo #  looking up member objects:
        @echo.

        %sys.ColorDark%

        %fs.BinDir%\dsget group "CN=%SecurityGroup.RootName%,%ds.path%" -members -expand -s %ds.server% -u %ds.user% -p %ds.passwd%

        if !errorlevel! EQU %EL_STATUS_OK% (
          @echo     + operation status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + operation status: FAIL
        )

        %sys.ColorNormal%
      )
    )