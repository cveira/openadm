setlocal enabledelayedexpansion

  @echo # bulk loading users on local resource
  @echo.

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + loading group member: %%i
        @echo.

        %sys.ColorDark%

        net localgroup %SecurityGroup.RootName% %%i /add

        if !errorlevel! EQU %EL_NET_OK% (
          @echo     + group members load status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members load status: FAIL
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :LocalLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + loading group member: %%i
        @echo.

        %sys.ColorDark%

        net group %SecurityGroup.RootName% %%i /add /domain

        if !errorlevel! EQU %EL_NET_OK% (
          @echo     + group members load status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members load status: FAIL
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :NTLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + loading group member: %%i
        @echo.

        %sys.ColorDark%

        %fs.BinDir%\lg \\%ds.server%\%SecurityGroup.RootName% %%i -add

        if !errorlevel! EQU %EL_LG_OK% (
          @echo     + group members load status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members load status: FAIL
        )
      )

      @echo.
      %sys.ColorNormal%
    ) else (
      call :ADLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )

  if exist %fs.TmpDir%\%SET_LOGFILE:.log=.exit% (
    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpected operation error.
    @echo.

    %sys.ColorNormal%

    set event.message="sadm res.load.%VALUE_RESTYPE%: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:res.load.%VALUE_RESTYPE% [%SET_SSNSEQ%]" /d !event.message! > nul
  )

endlocal

goto :ExitLoadGroups



:ADLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\lg \\%ds.server%\%SecurityGroup.RootName% %%i -add

      if !errorlevel! EQU %EL_LG_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :ADLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:NTLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      net group %SecurityGroup.RootName% %%i /add /domain

      if !errorlevel! EQU %EL_NET_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :NTLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:LocalLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      net localgroup %SecurityGroup.RootName% %%i /add

      if !errorlevel! EQU %EL_NET_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :LocalLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:ExitLoadGroups