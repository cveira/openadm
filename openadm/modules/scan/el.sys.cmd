@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: scan el.sys
@rem ------------------------------------------------------------------------------------
@rem OpenADM 3.5.1.0b2-20090118-0.
@rem Copyright (C) 2006  Carlos Veira Lorenzo.
@rem
@rem This program is free software; you can redistribute it and/or
@rem modify it under the terms of the GNU General Public License
@rem as published by the Free Software Foundation; either version 2
@rem of the License.
@rem
@rem This program is distributed in the hope that it will be useful,
@rem but WITHOUT ANY WARRANTY; without even the implied warranty of
@rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
@rem GNU General Public License for more details.
@rem
@rem You should have received a copy of the GNU General Public License
@rem along with this program; if not, write to the Free Software
@rem Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
@rem ------------------------------------------------------------------------------------
@rem Reference Sites:
@rem   http://www.thinkinbig.org/
@rem   http://www.xlnetworks.net/
@rem ------------------------------------------------------------------------------------
@rem Description:
@rem   Analizes current and live Event Log entries in order to detect system and
@rem   application errors or anomalies on the system.
@rem
@rem Dependencies:
@rem   logparser.exe                      - microsoft.com (v2.2.10)
@rem   eventcreate.exe                    - win2k3 server
@rem   mtee.exe                           - http://www.commandline.co.uk (v2.0)
@rem   datex.exe                          - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe                         - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd                          - openadm [scan.el.sys alert module]
@rem   <fs.InstallDir>\el.sys.*.[cmd|ini] - openadm [scan el.sys extension modules]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\scan el.sys <-profile:{dc|mhost|app|sys|ds|dns|frs|ps|ie|dfsr|fwe|hwe}>
@rem                             <-range:{today|yesterday|lastweek}>
@rem                             <-a:{yes|no}>
@rem                             <-d:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\scan
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\scan
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-profile:dc]       - performs the whole system checks for a DC.
@rem   [-profile:mhost]    - performs the whole system checks for a Member Host.
@rem   [-profile:app]      - performs the information filtering on the Application Event Log.
@rem   [-profile:sys]      - performs the information filtering on the System Event Log.
@rem   [-profile:ds]       - performs the information filtering on the Directory Service Event Log.
@rem   [-profile:dns]      - performs the information filtering on the DNS Server Event Log.
@rem   [-profile:frs]      - performs the information filtering on the File Replication Service Event Log.
@rem   [-profile:ps]       - performs the information filtering on the PowerShell Event Log.
@rem   [-profile:ie]       - performs the information filtering on the Internet Explorer Event Log.
@rem   [-profile:dfsr]     - performs the information filtering on the DFS Replication Event Log.
@rem   [-profile:fwe]      - performs the information filtering on the Forwarded Events Event Log.
@rem   [-profile:hwe]      - performs the information filtering on the Hardware Events Event Log.
@rem   [-range:today]      - restrict the analysis to the current day only.
@rem   [-range:yesterday]  - restrict the analysis to events generated for the last two days.
@rem   [-range:lastweek]   - restrict the analysis to events generated for the last week.
@rem   [-a:{yes|no}]       - alert mode: it triggers a post-scan log analysis.
@rem   [-d:{yes|no}]       - debug mode: enables/disables verbose output.
@rem
@rem Important notes:
@rem   Monitoring tokens are updated up to win2k3 and winxp sp2.
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : el.sys.ini
@rem     - <fs.ConfDir>    : el.local.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem Sample rules:
@rem   %fs.BinDir%\logparser -q:on -iw:off -stats:off -resolveSIDs:on -formatMsg:on -o:nat !EvtQuery.sql!
@rem
@rem Sample queries:
@rem   SELECT     RecordNumber, TimeGenerated, EventID,
@rem              EXTRACT_TOKEN^(EventTypeName, 0, ' '^),
@rem              SourceName, SID, Strings
@rem   FROM       [application|security|system|gfi]
@rem   WHERE      EventType = '[%EvtType.Info%|%EvtType.Warning%|%EvtType.Error%]' [AND|OR]
@rem              EventID IN (id1; id2; ...; idn)               [AND|OR]
@rem              TimeGenerated > '%yyyy%-%mm%%dd% 00:00:00'
@rem   ORDER BY   [SourceName|EventTypeName|SID]
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\scan
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\scan

  set dd=%date:~0,2%
  set mm=%date:~3,2%
  set yy=%date:~8,2%
  set yyyy=%date:~6,4%

  set sys.ColorBright=%fs.BinDir%\colorx -c 0E
  set sys.ColorNormal=%fs.BinDir%\colorx -c 0F
  set sys.ColorDark=%fs.BinDir%\colorx -c 08
  set sys.ColorRed=%fs.BinDir%\colorx -c 0C

  for /f %%i in ('%fs.BinDir%\colorx') do set sys.ColorOriginal=%%i
  %sys.ColorNormal%

  set sys.CPLatin1=%fs.BinDir%\chcp 1252

  for /f "delims=: tokens=1,2" %%i in ('%fs.BinDir%\chcp') do set sys.CPOriginal=%%j
  set sys.CPOriginal=%sys.CPOriginal:~1%
  %sys.CPLatin1%  >  nul


  if /i {%1} EQU {} goto HELP

  set context.IsCallBack=0
  if %1 EQU MAIN (
    set context.IsCallBack=1
    shift
  )


  set SET_PROFILE=%1
  set SET_TIMERANGE=%2
  set SET_ALERTMODE=%3
  set SET_DEBUGMODE=%4
  set SET_LOGFILE=%5
  set SET_SSNSEQ=%6

  set VALUE_PROFILE=%SET_PROFILE:-profile:=%
  set VALUE_TIMERANGE=%SET_TIMERANGE:-range:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%
  set VALUE_DEBUGMODE=%SET_DEBUGMODE:-d:=%

  set VALUE_PROFILE_DC=dc
  set VALUE_PROFILE_MHOST=mhost
  set VALUE_PROFILE_APP=app
  set VALUE_PROFILE_SYS=sys
  set VALUE_PROFILE_DS=ds
  set VALUE_PROFILE_DNS=dns
  set VALUE_PROFILE_FRS=frs
  set VALUE_PROFILE_PS=ps
  set VALUE_PROFILE_IE=ie
  set VALUE_PROFILE_DFSR=dfsr
  set VALUE_PROFILE_FWE=fwe
  set VALUE_PROFILE_HWE=hwe

  set VALUE_TIMERANGE_CURRENTDAY=today
  set VALUE_TIMERANGE_YESTERDAY=yesterday
  set VALUE_TIMERANGE_LASTWEEK=lastweek

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_LOGPARSER_OK=0
  set EL_LOGPARSER_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_PROFILE%"      EQU ""       goto HELP
  if /i %SET_PROFILE:~0,8%   NEQ -profile goto HELP
  if /i %SET_TIMERANGE:~0,6% NEQ -range   goto HELP
  if /i %SET_ALERTMODE:~0,2% NEQ -a       goto HELP
  if /i %SET_DEBUGMODE:~0,2% NEQ -d       goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DC%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_MHOST%          set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_APP%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_SYS%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DS%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DNS%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_FRS%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_PS%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_IE%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DFSR%           set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_FWE%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_HWE%            set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_CURRENTDAY% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_YESTERDAY%  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_LASTWEEK%   set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%                  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_DEBUGMODE% EQU %STATUS_YES%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_DEBUGMODE% EQU %STATUS_NO%                  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\el.sys-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=el.sys-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini               set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\el.local.ini              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\el.sys.ini             set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\el.local.ini
    @echo #   %fs.InstallDir%\el.sys.ini
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.BinDir%\eventcreate.exe              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\mtee.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\colorx.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\datex.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\alert.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\logparser.exe                set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: external dependency check failed.
    @echo #
    @echo #   %fs.BinDir%\eventcreate.exe
    @echo #   %fs.BinDir%\mtee.exe
    @echo #   %fs.BinDir%\colorx.exe
    @echo #   %fs.BinDir%\datex.exe
    @echo #   %fs.SysOpDir%\alert.cmd
    @echo #   %fs.BinDir%\logparser.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU begin set event.BeginId=%%j
    if /i %%i EQU end   set event.EndId=%%j
    if /i %%i EQU event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    set LogParser.SessionParameters=-q:on -iw:off -stats:off -resolveSIDs:on -formatMsg:on -headers:on -direction:bw -o:nat

    set EvtRecord.Fields=RecordNumber, TimeGenerated, EventID, EXTRACT_TOKEN^(EventTypeName, 0, ' '^) AS EventTypeName, SourceName, SID, Strings
    set EvtType.Info=0
    set EvtType.Warning=2
    set EvtType.Error=1

    set EvtTime.Hour00=00:00:00
    set EvtTime.Hour24=23:59:59

    set EvtDate.Today=%yyyy%-%mm%-%dd%
    set EvtDate.Yesterday=TO_TIMESTAMP^(SUB^(TO_INT^(SYSTEM_TIMESTAMP^(^)^), 86400^)^)
    set EvtDate.LastWeek=TO_TIMESTAMP^(SUB^(TO_INT^(SYSTEM_TIMESTAMP^(^)^), 604800^)^)

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.local.ini) do (
      if /i %%i EQU el.app       set EvtLog.app=%%~j
      if /i %%i EQU el.sys       set EvtLog.sys=%%~j
      if /i %%i EQU el.sec       set EvtLog.sec=%%~j
      if /i %%i EQU el.sim       set EvtLog.sim='%%~j'
      if /i %%i EQU el.dns       set EvtLog.dns='%%~j'
      if /i %%i EQU el.ds        set EvtLog.ds='%%~j'
      if /i %%i EQU el.frs       set EvtLog.frs='%%~j'
      if /i %%i EQU el.ps        set EvtLog.ps=%%~j
      if /i %%i EQU el.ie        set EvtLog.ie='%%~j'
      if /i %%i EQU el.dfsr      set EvtLog.dfsr='%%~j'
      if /i %%i EQU el.fwe       set EvtLog.fwe='%%~j'
      if /i %%i EQU el.hwe       set EvtLog.hwe='%%~j'
      if /i %%i EQU labour.start set EvtTime.LabourStart=%%j
      if /i %%i EQU labour.end   set EvtTime.LabourEnd=%%j
    )


    set event.message="scan el.sys: scanning system. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "scan:el.sys [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by: %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo profile:       %VALUE_PROFILE%
    @echo time range:    %VALUE_TIMERANGE%
    @echo alert mode:    %VALUE_ALERTMODE%
    @echo debug mode:    %VALUE_DEBUGMODE%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    set cmdb.SessionIsOpened=%STATUS_OFF%
    set cmdb.SessionIndex=0

    if exist %fs.CmdbDir%\*.open (
      set cmdb.SessionIsOpened=%STATUS_ON%

      for /d %%i in (%fs.CmdbDir%\*.open) do (
        set /a cmdb.SessionIndex+=1
        set cmdb.SessionPath=%fs.CmdbDir%\%%~nxi
        set cmdb.SessionName=%%~ni
      )

      if {!cmdb.SessionIndex!} GTR {1} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR - there is more than one open transactional session.
        @echo #
        @echo # aborting program.

        %sys.ColorNormal%

        goto HELP
      )
    )

    if {!cmdb.SessionIsOpened!} EQU {%STATUS_ON%} (
      @echo # recording requested action in currently opened session:
      @echo.
      @echo   + requested action: %cmdb.RequestedAction%
      @echo   + action container: %cmdb.SessionPath%\%cmdb.ScriptName%
      @echo.

      @echo %cmdb.RequestedAction% >> %cmdb.SessionPath%\%cmdb.ScriptName%

      goto EXIT
    )


    @echo # searching alert patterns ...
    @echo.

    set context.CheckApp=%STATUS_OFF%
    set context.CheckSys=%STATUS_OFF%
    set context.CheckDs=%STATUS_OFF%
    set context.CheckDns=%STATUS_OFF%
    set context.CheckFrs=%STATUS_OFF%
    set context.CheckPs=%STATUS_OFF%
    set context.CheckIe=%STATUS_OFF%
    set context.CheckDfsr=%STATUS_OFF%
    set context.CheckFwe=%STATUS_OFF%
    set context.CheckHwe=%STATUS_OFF%

    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DC% (
      set context.CheckApp=%STATUS_ON%
      set context.CheckSys=%STATUS_ON%
      set context.CheckDs=%STATUS_ON%
      set context.CheckDns=%STATUS_ON%
      set context.CheckFrs=%STATUS_ON%
    )

    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_MHOST% (
      set context.CheckApp=%STATUS_ON%
      set context.CheckSys=%STATUS_ON%
    )

    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_APP%  set context.CheckApp=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_SYS%  set context.CheckSys=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DS%   set context.CheckDs=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DNS%  set context.CheckDns=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_FRS%  set context.CheckFrs=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_PS%   set context.CheckPs=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_IE%   set context.CheckIe=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DFSR% set context.CheckDfsr=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_FWE%  set context.CheckFwe=%STATUS_ON%
    if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_HWE%  set context.CheckHwe=%STATUS_ON%


    if %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_CURRENTDAY% set EvtQuery.time='%EvtDate.Today% %EvtTime.Hour00%'
    if %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_YESTERDAY%  set EvtQuery.time=%EvtDate.Yesterday%
    if %VALUE_TIMERANGE% EQU %VALUE_TIMERANGE_LASTWEEK%   set EvtQuery.time=%EvtDate.LastWeek%

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\el.sys.ini) do (
      if /i {%%i} EQU {%VALUE_PROFILE_APP%} (
        if {%context.CheckApp%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_SYS%} (
        if {%context.CheckSys%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_DS%} (
        if {%context.CheckDs%} EQU {%STATUS_ON%}   call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_DNS%} (
        if {%context.CheckDns%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_FRS%} (
        if {%context.CheckFrs%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_PS%} (
        if {%context.CheckPs%} EQU {%STATUS_ON%}   call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_IE%} (
        if {%context.CheckIe%} EQU {%STATUS_ON%}   call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_DFSR%} (
        if {%context.CheckDfsr%} EQU {%STATUS_ON%} call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_FWE%} (
        if {%context.CheckFwe%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )

      if /i {%%i} EQU {%VALUE_PROFILE_HWE%} (
        if {%context.CheckHwe%} EQU {%STATUS_ON%}  call %fs.InstallDir%\%%j.cmd
      )
    )

    %sys.ColorNormal%

    if exist %fs.TmpDir%\%SET_LOGFILE:.log=.exit% (
      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   selected profile: %VALUE_PROFILE%
      @echo.

      %sys.ColorNormal%

      set event.message="scan el.sys: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "scan:el.sys [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   scan el.sys [-profile:{dc^|mhost^|app^|sys^|ds^|dns^|frs^|ps^|ie^|
      @echo                          dfsr^|fwe^|hwe}]
      @echo               [-range:{today^|yesterday^|lastweek}]
      @echo               [-a:{yes^|no}]
      @echo               [-d:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="scan el.sys: system scanned. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "scan:el.sys [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd scan.el.sys -l:%SET_LOGFILE% -trap:yes

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul

    goto MAIN-EXIT


  :MAIN-EXIT

    exit /b


  :END

    if "%fs.LogFile%" NEQ "" (
      if exist %fs.TmpDir%\%fs.LogFile:.log=.exit% (
        for /f %%i in (%fs.TmpDir%\%fs.LogFile:.log=.exit%) do (
          set /a user.ExitCode+=%%i
        )

        del /q /f %fs.TmpDir%\%fs.LogFile:.log=.exit% > nul

        exit /b !user.ExitCode!
      ) else (
        exit /b 0
      )
    )

endlocal