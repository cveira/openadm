setlocal enabledelayedexpansion

  for /f "eol=# tokens=* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.sec.reboot.ini) do set EvtRecord.RebootPatterns=!EvtRecord.RebootPatterns!;%%i
  set EvtRecord.RebootPatterns=^(%EvtRecord.RebootPatterns:~1%^)


  @echo.
  @echo # system reboot:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=SourceName IN !EvtRecord.RebootPatterns! AND TimeGenerated ^> %EvtQuery.time%
  set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %EvtLog.sys% WHERE !EvtQuery.where! ORDER BY SID"

  if /i {%VALUE_DEBUGMODE%} EQU {%STATUS_YES%} (
    %sys.ColorBright%

    @echo.
    @echo ////////////////////////////////////////////////////////////////////////
    @echo LogParser.SessionParameters: %LogParser.SessionParameters%
    @echo EvtQuery.where:              !EvtQuery.where!
    @echo EvtQuery.sql:                !EvtQuery.sql!
    @echo ////////////////////////////////////////////////////////////////////////
    @echo.

    %sys.ColorNormal%
  )

  %sys.ColorDark%

  %fs.BinDir%\logparser %LogParser.SessionParameters% !EvtQuery.sql!

  if {!errorlevel!} NEQ {%EL_LOGPARSER_OK%} @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

  %sys.ColorNormal%

endlocal