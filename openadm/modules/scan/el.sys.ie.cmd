@echo.
@echo # relevant internet explorer events:
%sys.ColorBright%
@echo # ------------------------------------------------------------------------
%sys.ColorNormal%
@echo.

set EvtQuery.where=^(EventType = %EvtType.Error% OR EventType = %EvtType.Warning%^) AND TimeGenerated ^> %EvtQuery.time%
set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %std_evt_log_ie% WHERE !EvtQuery.where! ORDER BY SourceName"

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

%fs.BinDir%\logparser %LogParser.SessionParameters% !EvtQuery.sql!

%sys.ColorDark%

if {!errorlevel!} NEQ {%EL_LOGPARSER_OK%} @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

%sys.ColorNormal%