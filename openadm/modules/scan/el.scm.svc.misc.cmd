setlocal enabledelayedexpansion

  for /f "eol=# tokens=* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.scm.svc.misc.ini) do set EvtRecord.MiscPatterns=!EvtRecord.MiscPatterns!;%%i
  set EvtRecord.MiscPatterns=^(%EvtRecord.MiscPatterns:~1%^)


  @echo.
  @echo # business: miscelaneous business services
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventType = %EvtType.Error% AND SourceName IN !EvtRecord.ScmPatterns! AND TimeGenerated ^> %EvtQuery.time% AND TO_LOWERCASE^(EXTRACT_TOKEN^(Strings,0,'|'^)^) IN !EvtRecord.MiscPatterns!
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


  @echo.

  set EvtQuery.where=SourceName IN !EvtRecord.ScmPatterns! AND TimeGenerated ^> %EvtQuery.time% AND TO_LOWERCASE^(EXTRACT_TOKEN^(Strings,0,'|'^)^) IN !EvtRecord.MiscPatterns! AND TO_LOWERCASE^(EXTRACT_TOKEN^(Strings,1,'|'^)^) IN !EvtRecord.ServiceIsStoppedPatterns!
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