@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: alert [grouped log files]
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
@rem   Analyzes output files from <alert-id> operations in order to
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
@rem   <fs.SysOpDir>\alert.cmd <alert-id>
@rem                           <-l:{log-file|last|search}>
@rem                           <-id:group-label>
@rem                           <-trap:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:    <fs.SystemDrive>\openadm\modules\alert
@rem   fs.SysOpDir:      <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:       <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:        <fs.SystemDrive>\openadm\bin\system
@rem   fs.TmpDir:        <fs.SystemDrive>\openadm\tmp
@rem   fs.AlertLogsDir:  <fs.DataDrive>\logs\openadm\alert
@rem   fs.SourceLogsDir: <fs.DataDrive>\logs\openadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <-id:alert-id>    - operation/action identifier.
@rem   <-l:log-file>     - when specified, it will process that log file.
@rem   <-l:last>         - when specified, it will process that last <fs.SourceLogsDir> log file.
@rem   <-l:search>       - when specified, it will list any relevant log files in <fs.SourceLogsDir>.
@rem   <-id:group-label> - log group identifier.
@rem   <-trap:{yes|no}>  - send mail trap.
@rem
@rem Important notes:
@rem   <alert> only processes existing log files in <fs.SourceLogsDir>.
@rem
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : <alert-id>.patterns.ini
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
  set fs.SourceLogsDir=%fs.DataDrive%\logs\openadm

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

  set SET_ID=%1
  set SET_TARGET=%2
  set SET_LABELID=%3
  set SET_MAILTRAP=%4
  set SET_LOGFILE=%5
  set SET_SSNSEQ=%6

  set VALUE_ID=%SET_ID%
  set VALUE_TARGET=%SET_TARGET:-l:=%
  set VALUE_LABELID=%SET_LABELID:-id:=%
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
  set TYPE_DELIMITER=.

  set user.ExitCode=%EL_STATUS_OK%

  if /i "%SET_ID%"             EQU ""       goto HELP
  if /i "%SET_TARGET:~0,2%"    NEQ "-l"     goto HELP
  if /i "%SET_LABELID:~0,3%"   NEQ "-id"    goto HELP
  if /i "%SET_MAILTRAP:~0,5%"  NEQ "-trap"  goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_MAILTRAP% EQU %STATUS_YES% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_MAILTRAP% EQU %STATUS_NO%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.AlertLogsDir% md %fs.AlertLogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.AlertLogsDir%\%VALUE_ID%-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=%VALUE_ID%-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  for /f "tokens=1,* delims=%TYPE_DELIMITER%" %%i in ("%VALUE_ID%") do (
    set fs.LogFileTypeName=%%i
    set fs.LogFileRootName=%%j
  )

  set fs.SourceLogsDir=%fs.SourceLogsDir%\%fs.LogFileTypeName%


  set fs.PatternsSource=%fs.InstallDir%\grouped.master.patterns.ini
  if exist %fs.InstallDir%\%VALUE_ID%-%VALUE_LABELID%.patterns.ini  set fs.PatternsSource=%fs.InstallDir%\%VALUE_ID%-%VALUE_LABELID%.patterns.ini


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\customer.id.ini               set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\sys.alerts.ini                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.PatternsSource%                        set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\customer.id.ini
    @echo #   %fs.ConfDir%\sys.alerts.ini
    @echo #   %fs.PatternsSource%
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

@echo // %fs.AlertLogsDir%\%fs.LogFile%

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.AlertLogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

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
    set mail.subject="alert [%VALUE_ID%:%VALUE_LABELID%]: patterns detected"


    set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: analyzing %VALUE_ID% results. [%fs.AlertLogsDir%\%fs.LogFile%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by: %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # alert id:    %VALUE_ID%
    @echo # target:      %VALUE_TARGET%
    @echo # group label: %VALUE_LABELID%
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
      for %%i in (%fs.SourceLogsDir%\%fs.LogFileRootName%-%VALUE_LABELID%-*.log) do (
        set fs.file.TargetLog=%%~nxi
      )
    ) else (
      set fs.file.TargetLog=%VALUE_TARGET%
    )

    if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
      if NOT exist %fs.SourceLogsDir%\%fs.file.TargetLog% (
        %sys.ColorRed%
        @echo # ERROR: no log files to process
        %sys.ColorNormal%

        set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: no log files to process. [%fs.AlertLogsDir%\%fs.LogFile%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul

        goto EXIT
      )
    )

    set TargetLog.PatternsFound=%STATUS_OFF%

    if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
      @echo # processing: %fs.SourceLogsDir%\%fs.file.TargetLog%
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%

      set MailTrap.send=%STATUS_OFF%

      @echo # searching patterns ...
      @echo.

      %fs.BinDir%\findstr /i /n /g:%fs.PatternsSource% %fs.SourceLogsDir%\%fs.file.TargetLog%  >  %fs.TmpDir%\alert.%SET_LOGFILE%
      if {!errorlevel!} EQU {%EL_FINDSTR_FOUND%} set TargetLog.PatternsFound=%STATUS_ON%
    ) else (
      @echo # processing: %fs.SourceLogsDir%
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%

      set MailTrap.send=%STATUS_OFF%

      @echo # searching patterns ...
      @echo.

      %fs.BinDir%\findstr /i /m /s /g:%fs.PatternsSource% %fs.SourceLogsDir%\%fs.LogFileRootName%-%VALUE_LABELID%-*.log  >  %fs.TmpDir%\alert.%SET_LOGFILE%
      if {!errorlevel!} EQU {%EL_FINDSTR_FOUND%} set TargetLog.PatternsFound=%STATUS_ON%
    )

    %sys.ColorDark%

    type %fs.TmpDir%\alert.%SET_LOGFILE%

    %sys.ColorNormal%


    if %TargetLog.PatternsFound% EQU %STATUS_ON% (
      set MailTrap.send=%STATUS_ON%

      @echo.
      @echo   + search completed: patterns found.

      if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
        set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: patterns detected on %fs.SourceLogsDir%\%fs.file.TargetLog%. [%fs.AlertLogsDir%\%fs.LogFile%]"
      ) else (
        set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: patterns detected on %fs.SourceLogsDir%\%fs.LogFileRootName%-%VALUE_LABELID%-*.log. [%fs.AlertLogsDir%\%fs.LogFile%]"
      )

      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul
    ) else (
      @echo.
      @echo   + search completed: no patterns found.

      if /i %VALUE_TARGET% NEQ %VALUE_TARGET_SEARCH% (
        set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: no patterns found on %fs.SourceLogsDir%\%fs.file.TargetLog%. [%fs.AlertLogsDir%\%fs.LogFile%]"
      ) else (
        set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: no patterns found on %fs.SourceLogsDir%\%fs.LogFileRootName%-%VALUE_LABELID%-*.log. [%fs.AlertLogsDir%\%fs.LogFile%]"
      )

      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul
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

        call :SendAlert
      )
    )

    del /q /f %fs.TmpDir%\alert.%SET_LOGFILE%  >  nul

    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   alert [alert-id]
      @echo         [-l:{log-file^|last^|search}]
      @echo         [-id:group-label]
      @echo         [-trap:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: %VALUE_ID% results analyzed. [%fs.AlertLogsDir%\%fs.LogFile%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul


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


:SendAlert

  setlocal

    set mail.body=%fs.TmpDir%\alert.%SET_LOGFILE%

    if /i %sys.AlertByNetSend% EQU %STATUS_YES% net send %sys.AlertServerName% %mail.subject%

    if /i %sys.AlertByMail% EQU %STATUS.YES% (
      if %mail.ProfileIsActive% EQU %STATUS.YES% (
        %fs.BinDir%\blat %mail.body% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %fs.SourceLogsDir%\%fs.file.TargetLog%,%fs.file.SysInfo% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.SourceLogsDir%\%fs.file.TargetLog%,%fs.file.SysInfo% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.SourceLogsDir%\%fs.file.TargetLog%,%fs.file.SysInfo% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )
    )

    if {!errorlevel!} EQU {%STATUS_OK%} (
      @echo.
      @echo # mail trap has been sent:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.SourceLogsDir%\%fs.file.TargetLog%
      @echo #                  %fs.file.SysInfo%
      @echo.

      set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: mail trap has been sent. [%fs.AlertLogsDir%\%fs.LogFile%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to send mail trap:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.SourceLogsDir%\%fs.file.TargetLog%
      @echo #                  %fs.file.SysInfo%
      @echo.

      %sys.ColorNormal%

      set event.message="alert [%VALUE_ID%:%VALUE_LABELID%]: unable to send mail trap. [%fs.AlertLogsDir%\%fs.LogFile%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "alert:%VALUE_ID%:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message! > nul
    )

  endlocal

  goto :EOF