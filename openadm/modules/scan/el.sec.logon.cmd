setlocal enabledelayedexpansion

  for /f "eol=# tokens=* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.sec.logon.ini)          do set EvtRecord.LogonIds=!EvtRecord.LogonIds!;%%i
  set EvtRecord.LogonIds=^(%EvtRecord.LogonIds:~1%^)

  for /f "eol=# tokens=* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.sec.user.openadm.ini)   do set EvtRecord.SystemUserPatterns=!EvtRecord.SystemUserPatterns!;%%i
  set EvtRecord.SystemUserPatterns=^(%EvtRecord.SystemUserPatterns:~1%^)

  for /f "eol=# tokens=* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.sec.user.blacklist.ini) do set EvtRecord.BlackListedUserPatterns=!EvtRecord.BlackListedUserPatterns!;%%i
  set EvtRecord.BlackListedUserPatterns=^(%EvtRecord.BlackListedUserPatterns:~1%^)


  @echo.
  @echo # global regular account log on statistics:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  @echo # total by user:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time% AND TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,1^)^) = '¡'
  set EvtQuery.sql="SELECT SID, DIV^(COUNT^(*^),2^) FROM %EvtLog.sec% WHERE !EvtQuery.where! GROUP BY SID"

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


  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time% AND TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,3^)^) NOT IN !EvtRecord.SystemUserPatterns!
  set EvtQuery.sql="SELECT SID, DIV^(COUNT^(*^),2^) FROM %EvtLog.sec% WHERE !EvtQuery.where! GROUP BY SID"

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
  @echo # total by user and logon type:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time% AND EXTRACT_TOKEN^(Strings,3,'|'^) IN %EvtRecord.UserLogonType% AND ^(TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,3^)^) NOT IN !EvtRecord.SystemUserPatterns! OR TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,1^)^) = '¡')
  set EvtQuery.sql="SELECT SID, CASE TO_INT^(EXTRACT_TOKEN^(Strings,3,'|'^)^) WHEN 2 THEN 'interactive' WHEN 3 THEN 'network' WHEN 4 THEN 'batch' WHEN 5 THEN 'service' WHEN 6 THEN 'proxy' WHEN 7 THEN 'unlock workstation' WHEN 8 THEN 'network logon using a clear text password' WHEN 9 THEN 'impersonated logon' END AS LogonType, DIV^(COUNT^(*^),2^) FROM %EvtLog.sec% WHERE !EvtQuery.where! GROUP BY SID, LogonType"

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
  @echo # global platform-dependant account log on statistics:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  @echo # total by user:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time% AND TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,3^)^) IN !EvtRecord.SystemUserPatterns!
  set EvtQuery.sql="SELECT SID, DIV^(COUNT^(*^),2^) FROM %EvtLog.sec% WHERE !EvtQuery.where! GROUP BY SID"

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
  @echo # total by user and logon type:
  %sys.ColorBright%
  @echo # ------------------------------------------------------------------------
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time% AND EXTRACT_TOKEN^(Strings,3,'|'^) IN %EvtRecord.UserLogonType%
  set EvtQuery.sql="SELECT SID, CASE TO_INT^(EXTRACT_TOKEN^(Strings,3,'|'^)^) WHEN 2 THEN 'interactive' WHEN 3 THEN 'network' WHEN 4 THEN 'batch' WHEN 5 THEN 'service' WHEN 6 THEN 'proxy' WHEN 7 THEN 'unlock workstation' WHEN 8 THEN 'network logon using a clear text password' WHEN 9 THEN 'impersonated logon' END AS LogonType, DIV^(COUNT^(*^),2^) FROM %EvtLog.sec% WHERE !EvtQuery.where! GROUP BY SID, LogonType"

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
  @echo # relevant account log on events:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventType = %EvtType.Error% AND EventID IN !EvtRecord.LogonIds! AND TimeGenerated ^> %EvtQuery.time%
  set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %EvtLog.sec% WHERE !EvtQuery.where! ORDER BY SID"

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
  @echo # accounts that should never log on:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=EventID IN !EvtRecord.LogonIds! AND TO_LOWERCASE^(EXTRACT_TOKEN^(SID,1,'\\'^)^) IN !EvtRecord.BlackListedUserPatterns! AND TimeGenerated ^> %EvtQuery.time%
  set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %EvtLog.sec% WHERE !EvtQuery.where! ORDER BY SID"

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
  @echo # accounts that should never work on certain time frames:
  %sys.ColorBright%
  @echo # ========================================================================
  %sys.ColorNormal%
  @echo.

  set EvtQuery.where=TO_LOWERCASE^(SUBSTR^(EXTRACT_TOKEN^(SID,1,'\\'^),0,3^)^) NOT IN !EvtRecord.SystemUserPatterns! AND TimeGenerated ^> %EvtQuery.time% AND ^((TO_STRING^(TimeGenerated, 'hh:mm:ss'^) ^>= '%EvtTime.Hour00%' AND ^(TO_STRING^(TimeGenerated, 'hh:mm:ss'^) ^< '%EvtTime.LabourStart%'^) OR ^((TO_STRING^(TimeGenerated, 'hh:mm:ss'^) ^> '%EvtTime.LabourEnd%' AND ^(TO_STRING^(TimeGenerated, 'hh:mm:ss'^) ^<= '%EvtTime.Hour24%'))
  set EvtQuery.sql="SELECT %EvtRecord.Fields% FROM %EvtLog.sec% WHERE !EvtQuery.where! ORDER BY SID"

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