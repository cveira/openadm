setlocal enabledelayedexpansion

  set EvtRecord.OpenADMIds=

  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i {%%i} EQU {aclbackup.begin}           set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {aclbackup.end}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {aclrestore.begin}          set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {aclrestore.end}            set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {rescreate.begin}           set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {rescreate.end}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resdelete.begin}           set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resdelete.end}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resload.begin}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resload.end}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resunload.begin}           set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resunload.end}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {icctl.begin}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {icctl.end}                 set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {rescreate.begin.TestMode}  set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {rescreate.end.TestMode}    set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resdelete.begin.TestMode}  set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resdelete.end.TestMode}    set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resload.begin.TestMode}    set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resload.end.TestMode}      set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resunload.begin.TestMode}  set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resunload.end.TestMode}    set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {icctl.begin.TestMode}      set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {icctl.end.TestMode}        set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resview.begin}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {resview.end}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {install.begin}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {install.end}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {service.begin}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {service.end}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {doexec.begin}              set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {doexec.end}                set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {session.begin}             set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {session.end}               set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j

    if /i {%%i} EQU {begin}                     set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {end}                       set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {begin.TestMode}            set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
    if /i {%%i} EQU {end.TestMode}              set EvtRecord.OpenADMIds=!EvtRecord.OpenADMIds!;%%j
  )

  set EvtRecord.OpenADMIds=^(%EvtRecord.OpenADMIds:~1%^)


  @echo.
  @echo # relevant application events:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  %sys.ColorDark%

  set EvtQuery.where=^(EventType = %EvtType.Error% OR EventType = %EvtType.Warning%^) AND TimeGenerated ^> %EvtQuery.time%
  set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %EvtLog.app% WHERE !EvtQuery.where! ORDER BY SourceName"

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
  @echo # unfinished OpenADM processes:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  %sys.ColorDark%

  set EvtQuery.where=^(EventType = %EvtType.Info% AND TimeGenerated ^> %EvtQuery.time%^) AND EventID IN !EvtRecord.OpenADMIds!

  for /d %%i in (%fs.InstallDir%\..\*.*) do (
    set EvtQuery.sql="SELECT COUNT^(EventID^) as EventCount, CASE MOD^(COUNT^(EventID^),2^) WHEN 0 THEN 'finished' ELSE 'unfinished' END AS HasFinished, SourceName FROM application WHERE ^(EventType = %EvtType.Info% AND TimeGenerated ^> %EvtQuery.time%^) AND ^(EventID IN !EvtRecord.OpenADMIds! AND SourceName LIKE '%%~ni%%'^) GROUP BY SourceName HAVING HasFinished='unfinished' ORDER BY SourceName"

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

    @echo   + processing [%%~ni] events:
    @echo.

    %fs.BinDir%\logparser %LogParser.SessionParameters% !EvtQuery.sql!

    if {!errorlevel!} NEQ {%EL_LOGPARSER_OK%} @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    @echo.
  )

  %sys.ColorNormal%

endlocal