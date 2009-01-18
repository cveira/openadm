@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sctl processes
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
@rem   Kills any black-listed processes
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   blat.exe        - www.blat.net (v2.5.0)
@rem   sort.exe        - win2k3 server
@rem   sed.exe         - GNU Win32 - http://getgnuwin32.sourceforge.net/ (v4.1.5)
@rem   wmic.exe        - win2k3 server
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [sctl.processes alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\sctl processes {none|<"l:prc1,prc2,[...]">|<"f:group-label">}
@rem                                <-cmd:{query|kill|setpriority|warn|list|xlist}>
@rem                                <-a:{yes|no}>
@rem                                <-w:99>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\sctl
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\sctl
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <none>             - target object ignored. Used with -cmd:list.
@rem   <"f:prc1,prc2">    - target objects: CSV list
@rem   <"f:group-label">  - target objects stored in a configuration file processes.<group-label>.ini
@rem   [-cmd:query]       - queries the state of a set of selected processes.
@rem   [-cmd:kill]        - kills a set of selected processes.
@rem   [-cmd:setpriority] - sets the system scheduler priority for a set of selected processes
@rem   [-cmd:warn]        - raises a warning when a set of selected processes is detected.
@rem   [-cmd:list]        - enumerates configuration files currently available for this operation.
@rem   [-cmd:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]      - alert mode: it triggers a post-scan log analysis.
@rem   [-w:99]            - time to wait between one operation and the following one.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sctl processes none -cmd:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : processes.excluded.ini
@rem     - <fs.InstallDir> : processes.filters.notfound.ini
@rem     - <fs.InstallDir> : processes.filters.warn.ini
@rem     - <fs.InstallDir> : processes.filters.kill.ini
@rem     - <fs.InstallDir> : processes.<group-label>.ini
@rem     - <%CD%>          : processes.<group-label>.ini
@rem     - <fs.ConfDir>    : customer.id.ini
@rem     - <fs.ConfDir>    : sys.alerts.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   <processes.excluded.ini> holds an excluded process name per line.
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\sctl
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\sctl

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
  set SET_CMD=%2
  set SET_ALERTMODE=%3
  set SET_TIMETOWAIT=%4
  set SET_LOGFILE=%5
  set SET_SSNSEQ=%6

  set VALUE_TARGET=%SET_TARGET:"=%
  set VALUE_CMD=%SET_CMD:-cmd:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%
  set VALUE_TIMETOWAIT=%SET_TIMETOWAIT:-w:=%

  set VALUE_TARGET_FILE=f:
  set VALUE_TARGET_LIST=l:
  set VALUE_TARGET_NONE=none
  set VALUE_CMD_QUERY=query
  set VALUE_CMD_KILL=kill
  set VALUE_CMD_SETPRIORITY=setpriority
  set VALUE_CMD_WARN=warn
  set VALUE_CMD_LIST=list
  set VALUE_CMD_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_WMIC_OK=0
  set EL_WMIC_ERROR=1
  set EL_FINDSTR_FOUND=0
  set EL_FINDSTR_NOTFOUND=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_TARGET:"=%" NEQ "%VALUE_TARGET_NONE%" (
    if /i "%SET_TARGET:"=%"       EQU ""      goto HELP
    if /i "%SET_CMD:~0,4%"        NEQ "-cmd"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"    goto HELP
    if /i "%SET_TIMETOWAIT:~0,2%" NEQ "-w"    goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_QUERY%"        set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_KILL%"         set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_SETPRIORITY%"  set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_WARN%"         set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LIST%"         set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_XLIST%"        set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    if /i "%VALUE_CMD%" NEQ "%VALUE_CMD_LIST%" set VALUE_CMD=%VALUE_CMD_XLIST%
    set VALUE_ALERTMODE=%STATUS_NO%
    set VALUE_TIMETOWAIT=0
  )

  if /i %VALUE_CMD% EQU %VALUE_CMD_LIST% (
    set VALUE_TARGET=%VALUE_TARGET_NONE%
    set VALUE_ALERTMODE=%STATUS_NO%
    set VALUE_TIMETOWAIT=0
  )

  if /i %VALUE_CMD% EQU %VALUE_CMD_XLIST% (
    set VALUE_TARGET=%VALUE_TARGET_NONE%
    set VALUE_ALERTMODE=%STATUS_NO%
    set VALUE_TIMETOWAIT=0
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileRootName=processes
  if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE% set fs.LogFileRootName=processes-%VALUE_TARGET:~2%

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\%fs.LogFileRootName%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=%fs.LogFileRootName%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\customer.id.ini                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\sys.alerts.ini                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\el.iddb.ini                        set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\processes.excluded.ini          set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\processes.filters.kill.ini      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\processes.filters.warn.ini      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\processes.filters.notfound.ini  set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\customer.id.ini
    @echo #   %fs.ConfDir%\sys.alerts.ini
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.InstallDir%\processes.excluded.ini
    @echo #   %fs.InstallDir%\processes.filters.kill.ini
    @echo #   %fs.InstallDir%\processes.filters.warn.ini
    @echo #   %fs.InstallDir%\processes.filters.notfound.ini
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.BinDir%\eventcreate.exe              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\list.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\mtee.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\colorx.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\datex.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\alert.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\wbem\wmic.exe      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sed.exe                      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sort.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\blat.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sleep.exe                    set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: external dependency check failed.
    @echo #
    @echo #   %fs.BinDir%\eventcreate.exe
    @echo #   %fs.BinDir%\list.exe
    @echo #   %fs.BinDir%\mtee.exe
    @echo #   %fs.BinDir%\colorx.exe
    @echo #   %fs.BinDir%\datex.exe
    @echo #   %fs.SysOpDir%\alert.cmd
    @echo #   %systemroot%\system32\wbem\wmic.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #   %fs.BinDir%\sed.exe
    @echo #   %fs.BinDir%\sort.exe
    @echo #   %fs.BinDir%\blat.exe
    @echo #   %fs.BinDir%\sleep.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  set input.ValuesFromFile=%STATUS_OFF%

  if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE% (
    set input.ValueIsOk=%STATUS_OFF%

    if exist "%CD%\processes.%VALUE_TARGET:~2%.ini"               set input.ValueIsOk=%STATUS_ON%
    if exist "%fs.InstallDir%\processes.%VALUE_TARGET:~2%.ini"    set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   first file location:  "%CD%\processes.%VALUE_TARGET:~2%.ini"
      @echo #   second file location: "%fs.InstallDir%\processes.%VALUE_TARGET:~2%.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )

    set fs.IniDir=%fs.InstallDir%
    set fs.IniFile="%fs.InstallDir%\processes.%VALUE_TARGET:~2%.ini"

    if exist "%CD%\processes.%VALUE_TARGET:~2%.ini" (
      set fs.IniDir=%CD%
      set fs.IniFile="%CD%\processes.%VALUE_TARGET:~2%.ini"
    )

    set input.ValuesFromFile=%STATUS_ON%
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

    set query.TimeOffset=0
    set query.MaxChecks=1
    set query.SafeFilter=%STATUS_NO%
    set query.Filter=%STATUS_NO%
    set policy.Priority=8
    set policy.MaxInstances=%STATUS_NO%
    set policy.MaxEvents=%STATUS_NO%

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\processes.%VALUE_TARGET:~2%.ini) do (
        if /i "%%i" EQU "query.TimeOffset"    set query.TimeOffset=%%j
        if /i "%%i" EQU "query.MaxChecks"     set query.MaxChecks=%%j
        if /i "%%i" EQU "query.SafeFilter"    set query.SafeFilter=%%j
        if /i "%%i" EQU "query.Filter"        set query.Filter=%%j
        if /i "%%i" EQU "policy.Priority"     set policy.Priority=%%j
        if /i "%%i" EQU "policy.MaxInstances" set policy.MaxInstances=%%j
        if /i "%%i" EQU "policy.MaxEvents"    set policy.MaxEvents=%%j
      )
    )


    for /f %%i in (%fs.ConfDir%\customer.id.ini) do set customer.id=%%i

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
    set mail.subject="sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]: warning search patterns detected"
    if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set mail.subject="sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]: [%VALUE_TARGET:~2%] warning search patterns detected"


    set event.message="sctl processes: performing %VALUE_CMD% operation over selected processes. [%fs.LogsDir%\%SET_LOGFILE%]"
    if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] performing %VALUE_CMD% operation over selected processes. [%fs.LogsDir%\%SET_LOGFILE%]"

    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:         %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:         %VALUE_TARGET%
    @echo # command:             %VALUE_CMD%
    @echo # alert mode:          %VALUE_ALERTMODE%
    @echo # time to wait:        %VALUE_TIMETOWAIT%
    @echo # ------------------------------------------------------------------------
    @echo # number of checks:    !query.MaxChecks!
    @echo # time offset:         !query.TimeOffset!
    @echo # safe filtering:      !query.SafeFilter!
    @echo # selection criteria:  !query.Filter!
    @echo # priority:            !policy.Priority!
    @echo # number of instances: !policy.MaxInstances!
    @echo # number of events:    !policy.MaxEvents!
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_CMD% EQU %VALUE_CMD_LIST% (
      @echo # current defined settings in [%CD%]:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\processes.*.ini") do (
        @echo   + %%i
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # current defined settings in [%fs.InstallDir%]:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\processes.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_CMD% EQU %VALUE_CMD_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\processes.*.ini") do (
        @echo   + %%i
      )

      for %%i in (%fs.InstallDir%\processes.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list "%CD%\processes.*.ini"
      %fs.BinDir%\list "%fs.InstallDir%\processes.*.ini"


      goto EXIT
    )


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


    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      set query.ExcludeFilter=
      set query.NameFilter=
      set query.CommandLineFilter=

      if /i "%query.SafeFilter%" EQU "%STATUS_YES%" (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\processes.excluded.ini) do (
          if /i "%%~i" EQU "name"        set query.NameFilter=!query.NameFilter! or Name='%%~j'
          if /i "%%~i" EQU "commandline" set query.CommandLineFilter=!query.CommandLineFilter! or CommandLine like '%%%%~j%%'
        )

        if /i {!query.NameFilter!}        NEQ {} set query.NameFilter=!query.NameFilter:~4!
        if /i {!query.CommandLineFilter!} NEQ {} set query.CommandLineFilter=!query.CommandLineFilter:~4!

        set query.ExcludeFilter=^(not ^(!query.NameFilter!^) and not ^(!query.CommandLineFilter!^)^)

        if /i {!query.NameFilter!}        EQU {} set query.ExcludeFilter=not ^(!query.CommandLineFilter!^)
        if /i {!query.CommandLineFilter!} EQU {} set query.ExcludeFilter=not ^(!query.NameFilter!^)
      )

      if /i {!query.ExcludeFilter!} NEQ {} set query.Filter=^(!query.Filter!^) and ^(!query.ExcludeFilter!^)

      if /i {!query.Filter!} EQU {} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unable to build query filter.
        @echo #
        @echo #   number of checks:    !query.MaxChecks!
        @echo #   time offset:         !query.TimeOffset!
        @echo #   safe filtering:      !query.SafeFilter!
        @echo #   selection criteria:  !query.Filter!
        @echo #   priority:            !policy.Priority!
        @echo #   number of instances: !policy.MaxInstances!
        @echo #   number of events:    !policy.MaxEvents!
        @echo.

        %sys.ColorNormal%

        set event.message="sctl processes: unable to build query filter. [%fs.LogsDir%\%SET_LOGFILE%]"
        if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unable to build query filter. [%fs.LogsDir%\%SET_LOGFILE%]"

        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )


    if /i %VALUE_CMD% EQU %VALUE_CMD_QUERY% (
      @echo # current state of selected processes [%VALUE_TARGET%]:
      @echo.

      %sys.ColorDark%

      if /i %input.ValuesFromFile% EQU %STATUS_ON% (
        wmic /locale:ms_409 process where "!query.Filter!" list brief /every:!query.TimeOffset! /repeat:!query.MaxChecks!
      ) else (
        for /l %%s in (1,1,!query.MaxChecks!) do (
          call :QueryFromList "%VALUE_TARGET:~2%"

          %fs.BinDir%\sleep !query.TimeOffset!
        )
      )

      %sys.ColorNormal%

      goto EXIT
    )


    @echo # current state of selected processes [%VALUE_TARGET%]:
    @echo.

    %sys.ColorDark%

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      wmic /locale:ms_409 process where "!query.Filter!" list brief
    ) else (
      call :QueryFromList "%VALUE_TARGET:~2%"
    )

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # running [%VALUE_CMD%] command on selected processes:
    @echo.

    %sys.ColorDark%

    set policy.IsSingleCriteria=%STATUS_ON%
    if /i "!policy.MaxInstances!" EQU "%STATUS_NO%"  set policy.IsSingleCriteria=%STATUS_OFF%
    if /i "!policy.MaxEvents!"    EQU "%STATUS_NO%"  set policy.IsSingleCriteria=%STATUS_OFF%

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      if /i %VALUE_CMD% EQU %VALUE_CMD_KILL%  (
        if /i "!policy.MaxInstances!" NEQ "%STATUS_NO%" (
          for /l %%s in (1,1,!query.MaxChecks!) do (
            wmic /locale:ms_409 process where "!query.Filter!" get ProcessId  >  %fs.TmpDir%\%SET_LOGFILE:.log=.tmp1%

            if !errorlevel! NEQ %EL_WMIC_OK% (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

              %sys.ColorRed%

              @echo.
              @echo # ERROR: unexpected operation error.
              @echo #
              @echo #   number of checks:    !query.MaxChecks!
              @echo #   time offset:         !query.TimeOffset!
              @echo #   safe filtering:      !query.SafeFilter!
              @echo #   selection criteria:  !query.Filter!
              @echo #   priority:            !policy.Priority!
              @echo #   number of instances: !policy.MaxInstances!
              @echo #   number of events:    !policy.MaxEvents!
              @echo.

              %sys.ColorNormal%

              set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
              if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

              %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
            )

            type %fs.TmpDir%\%SET_LOGFILE:.log=.tmp1% | %fs.BinDir%\findstr /i /g:%fs.InstallDir%\processes.filters.notfound.ini  >   nul

            if !errorlevel! NEQ %EL_FINDSTR_FOUND% (
              type %fs.TmpDir%\%SET_LOGFILE:.log=.tmp1% | %fs.BinDir%\findstr /v /g:%fs.InstallDir%\processes.filters.kill.ini    >>  %fs.TmpDir%\%SET_LOGFILE:.log=.tmp2%
              type %fs.TmpDir%\%SET_LOGFILE:.log=.tmp2% | %fs.BinDir%\sort                                                        >>  %fs.TmpDir%\%SET_LOGFILE:.log=.tmp3%
              type %fs.TmpDir%\%SET_LOGFILE:.log=.tmp3% | %fs.BinDir%\sed     -e "s/ \+$//"                                       >>  %fs.TmpDir%\%SET_LOGFILE%

              set process.InstanceCount=0
              set process.SelectedInstances=

              for /f "tokens=*" %%i in (%fs.TmpDir%\%SET_LOGFILE%) do (
                if !process.InstanceCount! GEQ !policy.MaxInstances! set process.SelectedInstances=!process.SelectedInstances! or ProcessId=%%i

                set /a process.InstanceCount+=1
              )


              if {!process.SelectedInstances!} NEQ {} (
                set process.SelectedInstances=!process.SelectedInstances:~4!

                @echo   + killing the exceeding instances: [!process.InstanceCount!/!policy.MaxInstances!]
                @echo.

                wmic process where "!process.SelectedInstances!" delete

                if !errorlevel! NEQ %EL_WMIC_OK% (
                  @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

                  %sys.ColorRed%

                  @echo.
                  @echo # ERROR: unexpected operation error.
                  @echo #
                  @echo #   number of checks:    !query.MaxChecks!
                  @echo #   time offset:         !query.TimeOffset!
                  @echo #   safe filtering:      !query.SafeFilter!
                  @echo #   selection criteria:  !query.Filter!
                  @echo #   priority:            !policy.Priority!
                  @echo #   number of instances: !policy.MaxInstances!
                  @echo #   number of events:    !policy.MaxEvents!
                  @echo.

                  %sys.ColorNormal%

                  set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
                  if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

                  %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
                )
              ) else (
                @echo   + current instances meet current policy: [!process.InstanceCount!/!policy.MaxInstances!]
                @echo.

                wmic /locale:ms_409 process where "!query.Filter!" list brief
              )

              del /q /f %fs.TmpDir%\%SET_LOGFILE:.log=%.tmp?             >  nul
              del /q /f %fs.TmpDir%\%SET_LOGFILE%                        >  nul
            ) else (
              @echo   + no instances where selected for policy verification.
              @echo.
            )

            %fs.BinDir%\sleep !query.TimeOffset!
          )
        )


        if /i "!policy.MaxEvents!" NEQ "%STATUS_NO%" (
          set process.EventCount=0

          for /l %%s in (1,1,!query.MaxChecks!) do (
            wmic /locale:ms_409 process where "!query.Filter!" list brief  >  %fs.TmpDir%\%SET_LOGFILE%

            type %fs.TmpDir%\%SET_LOGFILE% | %fs.BinDir%\findstr /i /g:%fs.InstallDir%\processes.filters.notfound.ini   >   nul

            if !errorlevel! NEQ %EL_FINDSTR_FOUND% (
              if !process.EventCount! GEQ !policy.MaxEvents! (
                @echo   + killing the selected instances: [!process.EventCount!/!policy.MaxEvents!]
                @echo.

                wmic /locale:ms_409 process where "!query.Filter!" delete
              ) else (
                @echo   + current instances meet current policy: [!process.EventCount!/!policy.MaxEvents!]
                @echo.

                wmic /locale:ms_409 process where "!query.Filter!" list brief
              )

              del /q /f %fs.TmpDir%\%SET_LOGFILE%                        >  nul
            ) else (
              @echo   + no instances where selected for policy verification.
              @echo.
            )

            set /a process.EventCount+=1

            %fs.BinDir%\sleep !query.TimeOffset!
          )
        )
      )


      if /i "!policy.IsSingleCriteria!" EQU "%STATUS_ON%"            wmic /locale:ms_409 process where "!query.Filter!" delete /every:!query.TimeOffset! /repeat:!query.MaxChecks!
      if /i %VALUE_CMD%                 EQU %VALUE_CMD_SETPRIORITY%  wmic /locale:ms_409 process where "!query.Filter!" call SetPriority !policy.Priority!

      if %errorlevel% NEQ %EL_WMIC_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   number of checks:    !query.MaxChecks!
        @echo #   time offset:         !query.TimeOffset!
        @echo #   safe filtering:      !query.SafeFilter!
        @echo #   selection criteria:  !query.Filter!
        @echo #   priority:            !policy.Priority!
        @echo #   number of instances: !policy.MaxInstances!
        @echo #   number of events:    !policy.MaxEvents!
        @echo.

        %sys.ColorNormal%

        set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      if /i %VALUE_CMD% EQU %VALUE_CMD_WARN% (
        for /l %%s in (1,1,!query.MaxChecks!) do (
          wmic /locale:ms_409 process where "!query.Filter!" list brief
          wmic /locale:ms_409 process where "!query.Filter!" list brief  >  %fs.TmpDir%\%SET_LOGFILE%

          if !errorlevel! NEQ %EL_WMIC_OK% (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

            %sys.ColorRed%

            @echo.
            @echo # ERROR: unexpected operation error.
            @echo #
            @echo #   number of checks:    !query.MaxChecks!
            @echo #   time offset:         !query.TimeOffset!
            @echo #   safe filtering:      !query.SafeFilter!
            @echo #   selection criteria:  !query.Filter!
            @echo #   priority:            !policy.Priority!
            @echo #   number of instances: !policy.MaxInstances!
            @echo #   number of events:    !policy.MaxEvents!
            @echo.

            %sys.ColorNormal%

            set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
            if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

            %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
          )

          %fs.BinDir%\findstr /i /g:%fs.InstallDir%\processes.filters.warn.ini %fs.TmpDir%\%SET_LOGFILE%  >  nul

          if !errorlevel! NEQ %EL_FINDSTR_FOUND% (
            @echo.                                                                            >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo # ------------------------------------------------------------------------  >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo # sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]: operational parameters.        >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #                                                                           >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   number of checks:    !query.MaxChecks!                                  >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   time offset:         !query.TimeOffset!                                 >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   safe filtering:      !query.SafeFilter!                                 >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   selection criteria:  !query.Filter!                                     >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   priority:            !policy.Priority!                                  >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   number of instances: !policy.MaxInstances!                              >>  %fs.TmpDir%\%SET_LOGFILE%
            @echo #   number of events:    !policy.MaxEvents!                                 >>  %fs.TmpDir%\%SET_LOGFILE%

            @echo.
            %sys.ColorBright%
            @echo # ------------------------------------------------------------------------
            %sys.ColorNormal%
            @echo # sending e-mail warning ...
            @echo.

            call :SendWarning
          )

          %fs.BinDir%\sleep !query.TimeOffset!
        )

        del /q /f %fs.TmpDir%\%SET_LOGFILE%  >  nul
      )

      @echo.
      %sys.ColorNormal%
    ) else (
      for /l %%s in (1,1,!query.MaxChecks!) do (
        call :RunCommandFromList "%VALUE_TARGET:~2%"

        %fs.BinDir%\sleep !query.TimeOffset!
      )

      if exist %fs.TmpDir%\%SET_LOGFILE% del /q /f %fs.TmpDir%\%SET_LOGFILE%  >  nul
    )

    %fs.BinDir%\sleep %VALUE_TIMETOWAIT%

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # final state of selected processes [%VALUE_TARGET%]:
    @echo.

    %sys.ColorDark%

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      wmic /locale:ms_409 process where "!query.Filter!" list brief
    ) else (
      call :QueryFromList "%VALUE_TARGET:~2%"
    )

    %sys.ColorNormal%


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sctl processes [{none^|["l:prc1,prc2,[...]"]^|["f:group-label"]}]
      @echo                  [-cmd:{query^|kill^|setpriority^|warn^|list^|xlist}]
      @echo                  [-a:{yes^|no}]
      @echo                  [-w:99]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sctl processes none -cmd:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="sctl processes: %VALUE_CMD% operation over selected processes completed. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] %VALUE_CMD% operation over selected processes completed. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd sctl.processes -l:%SET_LOGFILE% -trap:yes

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

goto :ExitProgram



:QueryFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      %sys.ColorDark%

      wmic /locale:ms_409 process where "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')" list brief

      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :QueryFromList "%%~j"
      goto :EOF
    )

  endlocal



:RunCommandFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + processing process pattern: %%i
      @echo.

      %sys.ColorDark%

      if /i %VALUE_CMD% EQU %VALUE_CMD_KILL%         wmic /locale:ms_409 process where "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')" delete
      if /i %VALUE_CMD% EQU %VALUE_CMD_SETPRIORITY%  wmic /locale:ms_409 process where "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')" call SetPriority !policy.Priority!

      if !errorlevel! NEQ %EL_WMIC_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   number of checks:    !query.MaxChecks!
        @echo #   time offset:         !query.TimeOffset!
        @echo #   safe filtering:      !query.SafeFilter!
        @echo #   selection criteria:  "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')"
        @echo #   priority:            !policy.Priority!
        @echo #   number of instances: !policy.MaxInstances!
        @echo #   number of events:    !policy.MaxEvents!
        @echo.

        %sys.ColorNormal%

        set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )


      if /i %VALUE_CMD% EQU %VALUE_CMD_WARN% (
        wmic /locale:ms_409 process where "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')" list brief
        wmic /locale:ms_409 process where "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')" list brief  >  %fs.TmpDir%\%SET_LOGFILE%

        if !errorlevel! NEQ %EL_WMIC_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   number of checks:    !query.MaxChecks!
          @echo #   time offset:         !query.TimeOffset!
          @echo #   safe filtering:      !query.SafeFilter!
          @echo #   selection criteria:  "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')"
          @echo #   priority:            !policy.Priority!
          @echo #   number of instances: !policy.MaxInstances!
          @echo #   number of events:    !policy.MaxEvents!
          @echo.

          %sys.ColorNormal%

          set event.message="sctl processes: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
        )

        %fs.BinDir%\findstr /i /g:%fs.InstallDir%\processes.filters.warn.ini %fs.TmpDir%\%SET_LOGFILE%  >  nul

        if !errorlevel! NEQ %EL_FINDSTR_FOUND% (
          @echo.                                                                                                                          >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo # ------------------------------------------------------------------------                                                >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo # sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]: operational parameters.                                                      >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #                                                                                                                         >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   number of checks:    !query.MaxChecks!                                                                                >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   time offset:         !query.TimeOffset!                                                                               >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   safe filtering:      !query.SafeFilter!                                                                               >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   selection criteria:  "CommandLine like '%%%%~i%%' and not (Name='wmic.exe' or CommandLine like '%%processes.cmd%%')"  >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   priority:            !policy.Priority!                                                                                >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   number of instances: !policy.MaxInstances!                                                                            >>  %fs.TmpDir%\%SET_LOGFILE%
          @echo #   number of events:    !policy.MaxEvents!                                                                               >>  %fs.TmpDir%\%SET_LOGFILE%

          @echo.
          %sys.ColorBright%
          @echo # ------------------------------------------------------------------------
          %sys.ColorNormal%
          @echo # sending e-mail warning ...
          @echo.

          call :SendWarning
        )

        %fs.BinDir%\sleep !query.TimeOffset!
      )


      @echo.
      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :RunCommandFromList "%%j"
      goto :EOF
    )

  endlocal



:SendWarning

  setlocal
    set mail.body=%fs.TmpDir%\%SET_LOGFILE%

    if /i %sys.AlertByNetSend% EQU %STATUS_YES% net send %sys.AlertServerName% %mail.subject%

    if /i %sys.AlertByMail% EQU %STATUS.YES% (
      if %mail.ProfileIsActive% EQU %STATUS.YES% (
        %fs.BinDir%\blat %mail.body% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %fs.TmpDir%\%SET_LOGFILE% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.TmpDir%\%SET_LOGFILE% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.TmpDir%\%SET_LOGFILE% -server %mail.server% -port %mail.ServerPort% -log %fs.AlertLogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )
    )


    if %errorlevel% EQU %STATUS_OK% (
      @echo.
      @echo # mail warning has been sent:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.TmpDir%\%SET_LOGFILE%
      @echo.

      set event.message="sctl processes: mail warning has been sent."
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] mail warning has been sent."

      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to send mail warning:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.TmpDir%\%SET_LOGFILE%
      @echo.

      %sys.ColorNormal%

      set event.message="sctl processes: unable to send mail warning."
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl processes: [%VALUE_TARGET:~2%] unable to send mail warning."

      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:processes.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    )
  endlocal

  goto :EOF



:ExitProgram