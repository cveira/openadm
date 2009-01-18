setlocal enabledelayedexpansion

  @echo # bulk unloading users on local resource
  @echo.

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + unloading group member: %%i
        @echo.

        %sys.ColorDark%

        net localgroup %SecurityGroup.RootName% %%i /delete

        if !errorlevel! EQU %EL_NET_OK% (
          @echo     + group members unload status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members unload status: FAIL
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :LocalUnLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + unloading group member: %%i
        @echo.

        %sys.ColorDark%

        net group %SecurityGroup.RootName% %%i /delete /domain

        if !errorlevel! EQU %EL_NET_OK% (
          @echo     + group members unload status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members unload status: FAIL
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :NTUnLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
    if /i %VALUE_SOURCE:~0,2% EQU %VALUE_SOURCE_FILE% (
      for /f "eol=#" %%i in (.\resunload.%VALUE_SOURCE:~2%.ini) do (
        @echo   + unloading group member: %%i
        @echo.

        %sys.ColorDark%

        %fs.BinDir%\lg \\%ds.server%\%SecurityGroup.RootName% %%i -remove

        if !errorlevel! EQU %EL_LG_OK% (
          @echo     + group members unload status: OK
        ) else (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
          @echo     + group members unload status: FAIL
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :ADUnLoadFromList "%VALUE_SOURCE:l:=%"
    )
  )


  if %user.ExitCode% NEQ %EL_STATUS_OK% (
    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpected operation error.
    @echo.

    %sys.ColorNormal%

    set event.message="sadm res.unload.%VALUE_RESTYPE%: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:res.unload.%VALUE_RESTYPE% [%SET_SSNSEQ%]" /d !event.message! > nul
  )

endlocal

goto :ExitLoadGroups



:ADUnLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\lg \\%ds.server%\%SecurityGroup.RootName% %%i -remove

      if !errorlevel! EQU %EL_LG_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :ADUnLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:NTUnLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      net group %SecurityGroup.RootName% %%i /delete /domain

      if !errorlevel! EQU %EL_NET_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :NTUnLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:LocalUnLoadFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + loading group member: %%i
      @echo.

      %sys.ColorDark%

      net localgroup %SecurityGroup.RootName% %%i /delete

      if !errorlevel! EQU %EL_NET_OK% (
        @echo     + group members load status: OK
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        @echo     + group members load status: FAIL
      )

      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :LocalUnLoadFromList "%%j"
      goto :EOF
    )

  endlocal



:ExitLoadGroups