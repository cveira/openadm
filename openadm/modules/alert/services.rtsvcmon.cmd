@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: alert services.rtsvcmon
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
@rem   Analyzes output files from services.rtsvcmon in order to
@rem   detect errors or anomalies.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   net.exe         - win2k3 server
@rem   blat.exe        - www.blat.net (v2.5.0)
@rem   update.cmd      - openadm [sys.info module]
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem
@rem Usage:
@rem   <fs.SysOpDir>\alert.cmd services.rtsvcmon <-l:{log-file|last|search}>
@rem                                             <-svc:service-name>
@rem                                             <-trap:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:    <fs.SystemDrive>\openadm\modules\alert
@rem   fs.SysOpDir:      <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:       <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:        <fs.SystemDrive>\openadm\bin\system
@rem   fs.TmpDir:        <fs.SystemDrive>\openadm\tmp
@rem   fs.AlertLogsDir:  <fs.DataDrive>\logs\openadm\alert
@rem   fs.SourceLogsDir: <fs.DataDrive>\logs\openadm\mirror
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <-l:log-file>       - when specified, it will process that log file.
@rem   <-l:last>           - when specified, it will process that last <fs.SourceLogsDir> log file.
@rem   <-l:search>         - when specified, it will list any relevant log files in <fs.SourceLogsDir>.
@rem   <-svc:service-name> - service name.
@rem   <-trap:{yes|no}>    - send mail trap.
@rem
@rem Important notes:
@rem   <alert services.rtsvcmon> only processes existing log files in <fs.SourceLogsDir>.
@rem
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : services.rtsvcmon.patterns.ini
@rem     - <fs.TmpDir>     : sys.info-yymmdd.log
@rem     - <fs.ConfDir>    : customer.id.ini
@rem     - <fs.ConfDir>    : sys.alerts.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\alert
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.AlertLogsDir=%fs.DataDrive%\logs\openadm\alert
  set fs.SourceLogsDir=%fs.DataDrive%\logs\openadm\mirror

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

  set SET_TARGET=%1
  set SET_SERVICENAME=%2
  set SET_MAILTRAP=%3

  set VALUE_TARGET=%SET_TARGET:-l:=%
  set VALUE_SERVICENAME=%SET_SERVICENAME:-svc:=%
  set VALUE_SERVICENAME=%SET_SERVICENAME:":=%
  set VALUE_MAILTRAP=%SET_MAILTRAP:-trap:=%

  set VALUE_TARGET_LAST=last
  set VALUE_TARGET_SEARCH=search

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_FINDSTR_FOUND=0
  set EL_FINDSTR_NOTFOUND=1

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_TARGET%"         EQU ""    goto HELP
  if /i %SET_TARGET:~0,2%      NEQ -l    goto HELP
  if /i %SET_SERVICENAME:~0,4% NEQ -svc  goto HELP
  if /i %SET_MAILTRAP:~0,5%    NEQ -trap goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_MAILTRAP% EQU %STATUS_YES% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_MAILTRAP% EQU %STATUS_NO%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.AlertLogsDir% md %fs.AlertLogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.AlertLogsDir%\services.rtsvcmon-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=services.rtsvcmon-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\customer.id.ini                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\sys.alerts.ini                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\services.rtsvcmon.patterns.ini  set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\customer.id.ini
    @echo #   %fs.ConfDir%\sys.alerts.ini
    @echo #   %fs.ConfDir%\services.rtsvcmon.patterns.ini
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
  if not exist %fs.SysOpDir%\update.cmd                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\blat.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\net.exe            set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.SysOpDir%\update.cmd
    @echo #   %fs.BinDir%\blat.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #   %systemroot%\system32\net.exe
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

    set alert.RunLogAnalysis=%STATUS_OFF%
    if /i %VALUE_TARGET% EQU %VALUE_TARGET_LAST%    set alert.RunLogAnalysis=%STATUS_ON%
    if /i %VALUE_TARGET% EQU %VALUE_TARGET_SEARCH%  set alert.RunLogAnalysis=%STATUS_ON%


    for /f %%i in (%fs.ConfDir%\customer.id.ini) do set customer.id=%%i
    for    %%i in (%fs.TmpDir%\sys.info.log)     do set fs.file.SysInfo=%%i

    set mail.ServerUser=
    set mail.ServerPassword=

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\sys.alerts.ini) do (
      if /i %%i EQU sys.AlertByMail         set sys.AlertByMail=%%j
      if /i %%i EQU sys.AlertByNetSend      set sys.AlertByNetSend=%%j
      if /i %%i EQU sys.AlertServerName     set sys.AlertServerName=%%j

      if /i %%i EQU mail.ProfileIsActive    set mail.ProfileIsActive=%%j
      if /i %%i EQU mail.ProfileName        set mail.ProfileName=%%j
      if /i %%i EQU mail.log                set mail.log=%%j
      if /i %%i EQU mail.server             set mail.server=%%j
      if /i %%i EQU mail.ServerPort         set mail.ServerPort=%%j
      if /i %%i EQU mail.ServerUser         set mail.ServerUser=%%j
      if /i %%i EQU mail.ServerPassword     set mail.ServerPassword=%%j
      if /i %%i EQU mail.SourceDomain       set mail.SourceDomain=%%j
      if /i %%i EQU mail.DestinationDomain  set mail.DestinationDomain=%%j
      if /i %%i EQU mail.DestinationMailBox set mail.DestinationMailBox=%%j
    )

    set mail.from=%COMPUTERNAME%.%customer.id%@%mail.SourceDomain%
    set mail.to=%mail.DestinationMailBox%@%mail.DestinationDomain%


    if %alert.RunLogAnalysis% EQU %STATUS_ON% (
      set mail.subject="alert services.rtsvcmon: patterns detected"
      set event.BeginMessage="alert services.rtsvcmon: [%VALUE_SERVICENAME%] analyzing services.rtsvcmon results. [%fs.AlertLogsDir%\%fs.LogFile%]"
      set event.EndMessage="alert services.rtsvcmon: [%VALUE_SERVICENAME%] services.rtsvcmon results analized. [%fs.AlertLogsDir%\%fs.LogFile%]"
    ) else (
      set MailTrap.send=%STATUS_ON%

      set mail.subject="alert services.rtsvcmon: service not available [%VALUE_SERVICENAME%]"
      set event.BeginMessage="alert services.rtsvcmon: [%VALUE_SERVICENAME%] service not available. [%fs.AlertLogsDir%\%fs.LogFile%]"
      set event.EndMessage="alert services.rtsvcmon: [%VALUE_SERVICENAME%] service not available. [%fs.AlertLogsDir%\%fs.LogFile%]"
    )


    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "alert:services.rtsvcmon" /d %event.BeginMessage%  > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by: %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # target:      %VALUE_TARGET%
    @echo # group label: %VALUE_SERVICENAME%
    @echo # trap mode:   %VALUE_MAILTRAP%
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


    @echo.

    if /i %VALUE_TARGET% EQU %VALUE_TARGET_LAST% (
      for %%i in (%fs.SourceLogsDir%\services.rtsvcmon-*.log) do (
        set fs.file.TargetLog=%%i
      )
    ) else (
      set fs.file.TargetLog=%VALUE_TARGET%
    )

    if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
      if NOT exist %fs.SourceLogsDir%\%fs.file.TargetLog% (
        %sys.ColorRed%
        @echo # ERROR: no log files to process
        %sys.ColorNormal%

        set event.message="alert services.rtsvcmon: no log files to process. [%fs.AlertLogsDir%\%fs.LogFile%]"
        %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t warning /so "alert:services.rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul

        goto EXIT
      )
    )


    if %alert.RunLogAnalysis% EQU %STATUS_ON% (
      set TargetLog.PatternsFound=%STATUS_OFF%

      if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
        @echo # processing: %fs.SourceLogsDir%\%fs.file.TargetLog%
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%

        set MailTrap.send=%STATUS_OFF%

        @echo # searching patterns ...
        @echo.

        %fs.BinDir%\findstr /i /n /g:%fs.InstallDir%\services.rtsvcmon.patterns.ini %fs.SourceLogsDir%\%fs.file.TargetLog%  >  %fs.TmpDir%\%fs.file.TargetLog%
        if %errorlevel% EQU %EL_FINDSTR_FOUND% set TargetLog.PatternsFound=%STATUS_ON%
      ) else (
        @echo # processing: %fs.SourceLogsDir%
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%

        set MailTrap.send=%STATUS_OFF%

        @echo # searching patterns ...
        @echo.

        %fs.BinDir%\findstr /i /m /s /g:%fs.InstallDir%\services.rtsvcmon.patterns.ini %fs.SourceLogsDir%\services.rtsvcmon-*.log  >  %fs.TmpDir%\%fs.file.TargetLog%
        if %errorlevel% EQU %EL_FINDSTR_FOUND% set TargetLog.PatternsFound=%STATUS_ON%
      )


      type %fs.TmpDir%\%fs.file.TargetLog%


      if %TargetLog.PatternsFound% EQU %STATUS_ON% (
        set MailTrap.send=%STATUS_ON%

        @echo.
        @echo   + search completed: patterns found.

        if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
          set event.message="alert services.rtsvcmon: [%VALUE_SERVICENAME%] patterns detected on %fs.SourceLogsDir%\%fs.file.TargetLog%. [%fs.AlertLogsDir%\%fs.LogFile%]"
        ) else (
          set event.message="alert services.rtsvcmon: [%VALUE_SERVICENAME%] patterns detected on %fs.SourceLogsDir%\services.rtsvcmon-*.log. [%fs.AlertLogsDir%\%fs.LogFile%]"
        )

        %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "alert:services.rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul
      ) else (
        @echo.
        @echo   + search completed: no patterns found.

        if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
          set event.message="alert services.rtsvcmon: [%VALUE_SERVICENAME%] no patterns found on %fs.SourceLogsDir%\%fs.file.TargetLog%. [%fs.AlertLogsDir%\%fs.LogFile%]"
        ) else (
          set event.message="alert services.rtsvcmon: [%VALUE_SERVICENAME%] no patterns found on %fs.SourceLogsDir%\services.rtsvcmon-*.log. [%fs.AlertLogsDir%\%fs.LogFile%]"
        )

        %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "alert:services.rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul
      )
    )


    if /i %VALUE_MAILTRAP% EQU %STATUS_YES% (
      if %MailTrap.send% EQU %STATUS_ON% (
        @echo.
        %sys.ColorBright%
        @echo # ------------------------------------------------------------------------
        %sys.ColorNormal%
        @echo # sending e-mail alert ...
        @echo.

        call %fs.SysOpDir%\update.cmd sys.info

        call :SEND_ALERT
      )
    )


    if %alert.RunLogAnalysis% EQU %STATUS_ON% (
      del /q /f %fs.TmpDir%\%fs.file.TargetLog%  >  nul
    )


    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   alert services.rtsvcmon [-l:{log-file^|last^|search}]
      @echo                           [-svc:service-name]
      @echo                           [-trap:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "alert:services.rtsvcmon" /d %event.EndMessage%  >  nul


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


:SEND_ALERT

  setlocal
    if %alert.RunLogAnalysis% EQU %STATUS_ON% (
      set mail.body=%fs.TmpDir%\%fs.file.TargetLog%
      set mail.AttachedFiles=%fs.SourceLogsDir%\%fs.file.TargetLog%,%fs.file.SysInfo%
    ) else (
      set mail.body=%fs.file.SysInfo%
      set mail.AttachedFiles=%fs.file.SysInfo%
    )

    if /i %sys.AlertByNetSend% EQU %STATUS_YES% net send %sys.AlertServerName% %mail.subject%

    if /i %sys.AlertByMail% EQU %STATUS.YES% (
      if %mail.ProfileIsActive% EQU %STATUS.YES% (
        %fs.BinDir%\blat %mail.body% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %mail.AttachedFiles% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %mail.AttachedFiles% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %mail.AttachedFiles% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )
    )

    call :SEND_ALERT_ISOK %errorlevel%
  endlocal

  goto :EOF


:SEND_ALERT_ISOK

  setlocal
    set SET_ERRORCODE=%1

    if %SET_ERRORCODE% EQU %STATUS_OK% (
      @echo.
      @echo # mail trap has been sent:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %mail.AttachedFiles%
      @echo.

      set event.message="alert services.rtsvcmon: mail trap has been sent. [%fs.AlertLogsDir%\%fs.LogFile%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "alert:services.rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul
    ) else (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to send mail trap:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %mail.AttachedFiles%
      @echo.

      %sys.ColorNormal%

      set event.message="alert services.rtsvcmon: unable to send mail trap. [%fs.AlertLogsDir%\%fs.LogFile%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "alert:services.rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul
    )
  endlocal

  goto :EOF