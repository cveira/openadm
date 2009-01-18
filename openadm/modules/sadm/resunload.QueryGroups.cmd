  @echo # [test-mode] bulk unloading objects on selected resource
  @echo.

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
    @echo #  looking up target resource: %SecurityGroup.RootName%
    @echo.

    %sys.ColorDark%

    wmic group where "name like '%SecurityGroup.RootName%%'" list brief

    %sys.ColorNormal%

    @echo.
    @echo #  looking up member objects:
    @echo.

    %sys.ColorDark%

    wmic group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption

    %sys.ColorNormal%

    @echo.
    @echo #  source objects:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE%.ini) do (
        @echo   + %%i
      )
    ) else (
      for /f "eol=# delims=%LIST_DELIMITER%" %%i in (%VALUE_SOURCE:l:=%) do (
        @echo   + %%i
      )
    )

    @echo.
    %sys.ColorNormal%
  )


  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
    @echo #  looking up target resource: %SecurityGroup.RootName%
    @echo.

    %sys.ColorDark%

    if /i "%COMPUTERNAME%" EQU "%ds.server%" (
      wmic group where "name like '%SecurityGroup.RootName%%'" list brief
    ) else (
      wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%SecurityGroup.RootName%%'" list brief
    )

    %sys.ColorNormal%

    @echo.
    @echo #  looking up member objects:
    @echo.

    %sys.ColorDark%

    if /i "%COMPUTERNAME%" EQU "%ds.server%" (
      wmic group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption
    ) else (
      wmic /node:"%ds.server%" /user:"%ds.user%" /password:"%ds.passwd%" /implevel:impersonate group where "name like '%SecurityGroup.RootName%%'" assoc:list | %fs.BinDir%\findstr /i Caption
    )

    %sys.ColorNormal%

    @echo.
    @echo #  source objects:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE%.ini) do (
        @echo   + %%i
      )
    ) else (
      for /f "eol=# delims=%LIST_DELIMITER%" %%i in (%VALUE_SOURCE:l:=%) do (
        @echo   + %%i
      )
    )

    @echo.
    %sys.ColorNormal%
  )


  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
    @echo #  looking up target resource: %SecurityGroup.RootName%
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\dsquery group domainroot -name %SecurityGroup.RootName%* -desc %SecurityGroup.RootName%* -s %ds.server% -u %ds.user% -p %ds.passwd%

    %sys.ColorNormal%

    @echo.
    @echo #  looking up member objects:
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\dsget group "CN=%SecurityGroup.RootName%,%ds.path%" -members -expand -s %ds.server% -u %ds.user% -p %ds.passwd%

    %sys.ColorNormal%

    @echo.
    @echo #  source objects:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE%.ini) do (
        @echo   + %%i
      )
    ) else (
      for /f "eol=# delims=%LIST_DELIMITER%" %%i in (%VALUE_SOURCE:l:=%) do (
        @echo   + %%i
      )
    )

    @echo.
    %sys.ColorNormal%
  )