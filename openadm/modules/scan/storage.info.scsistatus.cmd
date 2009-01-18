@echo.
%sys.ColorBright%
@echo # SCSI controller status: ////////////////////////////////////////////////
%sys.ColorNormal%
@echo.

%sys.ColorDark%

wmic /locale:ms_409 scsicontroller list status

if {!errorlevel!} NEQ {%EL_WMIC_OK%} (
  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

  %sys.ColorRed%

  @echo.
  @echo # ERROR: unexpected operation error.
  @echo.

  %sys.ColorNormal%

  set event.message="scan storage: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
  %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
)

%sys.ColorNormal%