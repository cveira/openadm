@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: baseline acl.services
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
@rem   Baselines Service Control Manager ACLs.
@rem
@rem Dependencies:
@rem   dump.cmd        - openadm [acl.services module]
@rem   logparser.exe   - microsoft.com (v2.2.10)
@rem   eventcreate.exe - win2k3 server
@rem   diff.exe        - GNU Win32 - http://getgnuwin32.sourceforge.net/ (v2.8.7)
@rem   blat.exe        - www.blat.net (v2.5.0)
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [baseline alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\baseline acl.services <-a:{yes|no}>
@rem                                       <-sr:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\baseline
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\baseline
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.CmdbDir:    <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.DumpDir:    <fs.DataDrive>\pub\fs\support\settings
@rem   fs.ReportDir:  [defined in acl.services.ini]
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-a:{yes|no}]   - alert mode: it triggers a post-scan log analysis.
@rem   [-sr:{yes|no}]  - send report: it triggers a post-scan log analysis.
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : acl.services.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem     - <fs.ConfDir>    : sys.alerts.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\baseline
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\baseline
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.DumpDir=%fs.DataDrive%\pub\fs\support\settings

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


  set SET_ALERTMODE=%1
  set SET_SENDREPORTMODE=%2
  set SET_LOGFILE=%3
  set SET_SSNSEQ=%4

  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%
  set VALUE_SENDREPORTMODE=%SET_SENDREPORTMODE:-sr:=%

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_DUMP_OK=0
  set EL_DUMP_ERROR=1
  set EL_DIFF_IDENTICAL=0
  set EL_DIFF_DIFFERENT=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_ALERTMODE%"          EQU ""  goto HELP
  if /i %SET_ALERTMODE:~0,2%       NEQ -a  goto HELP
  if /i %SET_SENDREPORTMODE:~0,3%  NEQ -sr goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES%      set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%       set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_SENDREPORTMODE% EQU %STATUS_YES% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SENDREPORTMODE% EQU %STATUS_NO%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\acl.services-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=acl.services-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\sys.alerts.ini      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\acl.services.ini set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\sys.alerts.ini
    @echo #   %fs.InstallDir%\acl.services.ini
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
  if not exist %fs.BinDir%\diff.exe                       set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\blat.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\logparser.exe                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\dump.cmd                   set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\diff.exe
    @echo #   %fs.BinDir%\blat.exe
    @echo #   %fs.BinDir%\logparser.exe
    @echo #   %fs.SysOpDir%\dump.cmd
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

    for /f %%i in (%fs.ConfDir%\customer.id.ini) do set customer.id=%%i

    set mail.ServerUser=
    set mail.ServerPassword=

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\sys.alerts.ini) do (
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
    set mail.subject=


    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\acl.services.ini) do (
      if /i %%i EQU fs.ReportDir set fs.ReportDir=%%j
    )

    set fs.ReportDir=%fs.ReportDir:"=%
    if /i %fs.ReportDir:~-1% EQU \ set fs.ReportDir=%fs.ReportDir:~0,-1%
    if not exist "%fs.ReportDir%" goto HELP

    if not exist %fs.ReportDir%\%yy%%mm% md %fs.ReportDir%\%yy%%mm%  >  nul
    set fs.ReportDir=%fs.ReportDir%\%yy%%mm%


    set baseline.OutputIsDifferent=%STATUS_OFF%
    for /f "delims=- tokens=1,2" %%i in ("%SET_SSNSEQ%") do set baseline.SeqId=%%j

    set baseline.OutputFileRootName=baseline.acl.services
    set baseline.OutputFile=%baseline.OutputFileRootName%
    set baseline.OutputTmpFile=%baseline.OutputFileRootName%-%yy%%mm%%dd%-%baseline.SeqId%.tmp
    set baseline.OutputDiffFile=diff-%baseline.OutputFileRootName%-%yy%%mm%%dd%-%baseline.SeqId%.log

    set event.message="baseline acl.services: baselining SCM security. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:      %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # alert mode:       %VALUE_ALERTMODE%
    @echo # send report mode: %VALUE_SENDREPORTMODE%
    @echo # report directory: %fs.ReportDir%
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


    @echo # taking current state snapshot:
    @echo.

    %sys.ColorDark%

    set dump.FailCode=%EL_DUMP_OK%
    call %fs.SysOpDir%\dump acl.services %fs.DumpDir% -id:all -a:no

    if {!errorlevel!} NEQ {%EL_DUMP_OK%} (
      set dump.FailCode=%EL_DUMP_ERROR%
    ) else (
      @echo.

      for /f "usebackq tokens=1,*" %%i in (`%fs.BinDir%\logparser -i:fs -q:on -iw:off -stats:off -headers:off -o:nat "SELECT TOP 1 Name, LastWriteTime FROM %fs.DumpDir%\acl.services-all-%yy%%mm%%dd%-*.* ORDER BY LastWriteTime DESC"`) do (
        @echo   + including file: %fs.DumpDir%\%%~nxi
        @type %fs.DumpDir%\%%~nxi  >>  %fs.CmdbDir%\%baseline.OutputTmpFile%
      )
    )

    @echo.
    %sys.ColorNormal%

    if {!dump.FailCode!} NEQ {%EL_DUMP_OK%} (
      goto ERROR
    ) else (
      @echo # looking for a baseline:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.CmdbDir%\%baseline.OutputFileRootName%-*.log) do set baseline.OutputFile=%%~nxi

      if NOT exist %fs.CmdbDir%\!baseline.OutputFile! (
        set baseline.OutputFile=%baseline.OutputFileRootName%-%yy%%mm%%dd%-%baseline.SeqId%.log
        copy /v /y %fs.CmdbDir%\%baseline.OutputTmpFile% %fs.CmdbDir%\!baseline.OutputFile!  >  nul

        @echo   + baseline created: %fs.CmdbDir%\!baseline.OutputFile!.
      ) else (
        @echo   + found an existing baseline: %fs.CmdbDir%\!baseline.OutputFile!.
      )

      %sys.ColorNormal%
    )

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # baselining process:
    @echo #   baseline file:      !baseline.OutputFile!
    @echo #   temp baseline file: %baseline.OutputTmpFile%
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\diff --minimal --suppress-common-lines -Bay %fs.CmdbDir%\%baseline.OutputTmpFile% %fs.CmdbDir%\!baseline.OutputFile!  >  %fs.CmdbDir%\%baseline.OutputDiffFile%

    if {!errorlevel!} NEQ {%EL_DIFF_IDENTICAL%} (
      set baseline.OutputIsDifferent=%STATUS_ON%

      set event.message="baseline acl.services: differences detected. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul

      %sys.ColorNormal%

      @echo # differences detected.
      @echo.

      %sys.ColorDark%

      type %fs.CmdbDir%\%baseline.OutputDiffFile%

      @echo.
      @echo   + sending mail notification about the differences found:
      @echo.

      set mail.subject=%event.message%

      if %mail.ProfileIsActive% EQU %STATUS_YES% (
        %fs.BinDir%\blat %fs.CmdbDir%\%baseline.OutputDiffFile% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %fs.CmdbDir%\!baseline.OutputFile!,%fs.CmdbDir%\%baseline.OutputTmpFile%,%fs.CmdbDir%\%baseline.OutputDiffFile% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %fs.CmdbDir%\%baseline.OutputDiffFile% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.CmdbDir%\!baseline.OutputFile!,%fs.CmdbDir%\%baseline.OutputTmpFile%,%fs.CmdbDir%\%baseline.OutputDiffFile% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %fs.CmdbDir%\%baseline.OutputDiffFile% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.CmdbDir%\!baseline.OutputFile!,%fs.CmdbDir%\%baseline.OutputTmpFile%,%fs.CmdbDir%\%baseline.OutputDiffFile% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )

      if {!errorlevel!} EQU %EL_STATUS_OK% (
        %sys.ColorNormal%

        @echo.
        @echo # differences have been notified:
        @echo #
        @echo #   sender:        %mail.from%
        @echo #   recipient:     %mail.to%
        @echo #   subject:       %mail.subject%
        @echo #   body:          %fs.CmdbDir%\%baseline.OutputDiffFile%
        @echo #   attached file: %fs.CmdbDir%\!baseline.OutputFile!
        @echo #   attached file: %fs.CmdbDir%\%baseline.OutputTmpFile%
        @echo #   attached file: %fs.CmdbDir%\%baseline.OutputDiffFile%
        @echo.

        %sys.ColorDark%

        set event.message="baseline acl.services: differences have been notified. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unable to send mail notification about the differences found:
        @echo #
        @echo #   sender:        %mail.from%
        @echo #   recipient:     %mail.to%
        @echo #   subject:       %mail.subject%
        @echo #   body:          %fs.CmdbDir%\%baseline.OutputDiffFile%
        @echo #   attached file: %fs.CmdbDir%\!baseline.OutputFile!
        @echo #   attached file: %fs.CmdbDir%\%baseline.OutputTmpFile%
        @echo #   attached file: %fs.CmdbDir%\%baseline.OutputDiffFile%
        @echo.

        %sys.ColorDark%

        set event.message="baseline acl.services: unable to send mail notification about the differences found. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      del /q /f %fs.CmdbDir%\%baseline.OutputDiffFile%   >  nul

      %sys.ColorNormal%
      @echo # setting up a new baseline.
      %sys.ColorDark%

      del /q /f %fs.CmdbDir%\!baseline.OutputFile!       >  nul
      move /y "%fs.CmdbDir%\%baseline.OutputTmpFile%" "%fs.CmdbDir%\%baseline.OutputTmpFile:.tmp=.log%"  >  nul

      @echo.
      @echo   + new baseline file is: %fs.CmdbDir%\%baseline.OutputTmpFile:.tmp=.log%
    ) else (
      set event.message="baseline acl.services: no differences detected. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul

      %sys.ColorNormal%

      @echo # no differences detected.
      @echo.

      %sys.ColorDark%

      type %fs.CmdbDir%\%baseline.OutputDiffFile%
      del /q /f %fs.CmdbDir%\%baseline.OutputDiffFile%  >  nul
      del /q /f %fs.CmdbDir%\%baseline.OutputTmpFile%   >  nul
    )

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # current Service Control Manager ACLs:
    @echo.

    %sys.ColorDark%

    call %fs.SysOpDir%\dump acl.services %fs.DumpDir% -id:all -a:no
    if {!errorlevel!} NEQ {%EL_DUMP_OK%} goto ERROR

    %sys.ColorNormal%

    goto EXIT


    :ERROR

      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      set event.message="baseline acl.services: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul

      %sys.ColorRed%
      @echo # ERROR: unexpected operation error.
      %sys.ColorNormal%

      goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   baseline acl.services [-a:{yes^|no}]
      @echo                         [-sr:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="baseline acl.services: SCM security baselined. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul

    copy /v /y %fs.LogsDir%\%SET_LOGFILE% %fs.ReportDir%  >  nul

    if /i %VALUE_SENDREPORTMODE% EQU %STATUS_YES% (
      set mail.subject=[baseline acl.services] report

      if %mail.ProfileIsActive% EQU %STATUS_YES% (
        %fs.BinDir%\blat %fs.LogsDir%\%fs.LogFile% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %fs.LogsDir%\%fs.LogFile% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %fs.LogsDir%\%fs.LogFile% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.LogsDir%\%fs.LogFile% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %fs.LogsDir%\%fs.LogFile% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.LogsDir%\%fs.LogFile% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )

      if {!errorlevel!} EQU %EL_STATUS_OK% (
        @echo.
        @echo # e-mail report has been sent:
        @echo #
        @echo #   sender:        %mail.from%
        @echo #   recipient:     %mail.to%
        @echo #   subject:       %mail.subject%
        @echo #   body:          %fs.LogsDir%\%fs.LogFile%
        @echo #   attached file: %fs.LogsDir%\%fs.LogFile%
        @echo.

        set event.message="baseline acl.services: e-mail report has been sent. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul
      ) else (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unable to send e-mail report:
        @echo #
        @echo #   sender:        %mail.from%
        @echo #   recipient:     %mail.to%
        @echo #   subject:       %mail.subject%
        @echo #   body:          %fs.LogsDir%\%fs.LogFile%
        @echo #   attached file: %fs.LogsDir%\%fs.LogFile%
        @echo.

        %sys.ColorNormal%

        set event.message="baseline acl.services: unable to send e-mail report. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "baseline:acl.services [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd baseline.acl.services -l:%SET_LOGFILE% -trap:yes

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