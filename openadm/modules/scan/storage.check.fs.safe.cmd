for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\storage.check.fs.safe.ini) do (
  if /i %%i EQU sctl.group set sctl.group=%%j
  if /i %%i EQU sctl.wait  set sctl.wait=%%j
)


@echo.
%sys.ColorBright%
@echo # stopping services: /////////////////////////////////////////////////////
%sys.ColorNormal%
@echo.

@call %fs.BinDir%\sctl services "f:!sctl.group!" -cmd:stop -a:yes -w:!sctl.wait!

@echo.
%sys.ColorBright%
@echo # ------------------------------------------------------------------------
%sys.ColorNormal%


@echo.
%sys.ColorBright%
@echo # file system verification: //////////////////////////////////////////////
%sys.ColorNormal%
@echo.

for /f "eol=#" %%i in (%fs.ConfDir%\sys.diskvolumes.ini) do (
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo   + checking volume: %%i
  @echo.

  %sys.ColorDark%

  %fs.BinDir%\chkdsk %%i /v

  if {!errorlevel!} EQU {%EL_CHKDSK_ERROR%} (
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
  ) else (
    if {!errorlevel!} GTR {%EL_CHKDSK_OK%} (
      %sys.ColorBright%

      @echo.
      @echo # WARNING: file system clean up has been performed on volume [%%i].
      @echo.

      %sys.ColorNormal%

      set event.message="scan storage: file system clean up has been performed on volume [%%i]. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )
  )

  @echo.
  %sys.ColorNormal%
)


@echo.
%sys.ColorBright%
@echo # starting services: /////////////////////////////////////////////////////
%sys.ColorNormal%
@echo.

@call %fs.BinDir%\sctl  services "f:!sctl.group!" -cmd:start -a:yes -w:!sctl.wait!