@echo.
%sys.ColorBright%
@echo # file system info: //////////////////////////////////////////////////////
%sys.ColorNormal%
@echo.

for /f "eol=#" %%i in (%fs.ConfDir%\sys.diskvolumes.ini) do (
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo   + processing volume: %%i
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\fsutil fsinfo ntfsinfo %%i

  if {!errorlevel!} NEQ {%EL_FSUTIL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpected operation error.
    @echo #
    @echo #   volume: %%i
    @echo.

    %sys.ColorNormal%

    set event.message="scan storage: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
  )

  @echo.
  %sys.ColorNormal%
)


@echo.
%sys.ColorBright%
@echo # file system statistics: ////////////////////////////////////////////////
%sys.ColorNormal%
@echo.

%sys.ColorDark%

for /f "eol=#" %%i in (%fs.ConfDir%\sys.diskvolumes.ini) do (
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo   + processing volume: %%i
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\fsutil fsinfo statistics %%i

  if {!errorlevel!} NEQ {%EL_FSUTIL_OK%} (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpected operation error.
    @echo #
    @echo #   volume: %%i
    @echo.

    %sys.ColorNormal%

    set event.message="scan storage: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
  )

  @echo.
  %sys.ColorNormal%
)