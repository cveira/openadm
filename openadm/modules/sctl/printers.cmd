@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sctl printers
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
@rem   Pauses, Resumes or Purges a given target printer(s).
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   prnqctl.vbs     - win2k3 server
@rem   prnjobs.vbs     - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   sed.exe         - GNU Win32 - http://getgnuwin32.sourceforge.net/ (v4.1.5)
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [sctl.printers alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\sctl printers {none|all|<"l:prn1,prn2,[...]">|<"f:group-label">}
@rem                               <-cmd:{pause|resume|purge|query|list|xlist}>
@rem                               <-a:{yes|no}>
@rem                               <-w:99>
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
@rem   <none>            - target object ignored. Used with -cmd:list.
@rem   <all>             - targets every object.
@rem   <"f:prn1,prn2">   - target objects: CSV list
@rem   <"f:group-label"> - target objects stored in a configuration file printers.<group-label>.ini
@rem   [-cmd:pause]      - pauses a given printers.
@rem   [-cmd:resume]     - resumes a given printers.
@rem   [-cmd:purge]      - purges all the jobs enqueued on a given printers.
@rem   [-cmd:query]      - queries the state of a given printers.
@rem   [-cmd:list]       - enumerates configuration files currently available for this operation.
@rem   [-cmd:xlist]      - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem   [-w:99]           - time to wait between one operation and the following one.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sctl printers none -cmd:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : printers.<group-label>.ini
@rem     - <%CD%>          : printers.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
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


  set SET_TARGET="%~1"
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
  set VALUE_TARGET_ALL=all
  set VALUE_CMD_RESUME=resume
  set VALUE_CMD_PAUSE=pause
  set VALUE_CMD_PURGE=purge
  set VALUE_CMD_QUERY=query
  set VALUE_CMD_LIST=list
  set VALUE_CMD_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_PRNQCTL_OK=0
  set EL_PRNQCTL_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_TARGET:"=%" NEQ "%VALUE_TARGET_NONE%" (
    if /i "%SET_TARGET:"=%"        EQU ""      goto HELP
    if /i "%SET_CMD:~0,4%"         NEQ "-cmd"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"   NEQ "-a"    goto HELP
    if /i "%SET_TIMETOWAIT:~0,2%"  NEQ "-w"    goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_RESUME%"                      set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_PAUSE%"                       set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_PURGE%"                       set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_QUERY%"                       set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LIST%"                        set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_XLIST%"                       set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"                      set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"                       set input.ValueIsOk=%STATUS_ON%

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

  set fs.LogFileRootName=printers
  if /i %VALUE_TARGET%      EQU %VALUE_TARGET_ALL%  set fs.LogFileRootName=printers-%VALUE_TARGET%
  if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE% set fs.LogFileRootName=printers-%VALUE_TARGET:~2%

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\%fs.LogFileRootName%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=%fs.LogFileRootName%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
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
  if not exist %fs.InstallDir%\prnqctl.vbs              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\prnjobs.vbs              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sed.exe                      set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.InstallDir%\prnqctl.vbs
    @echo #   %fs.InstallDir%\prnjobs.vbs
    @echo #   %fs.BinDir%\findstr.exe
    @echo #   %fs.BinDir%\sed.exe
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

    if exist "%CD%\printers.%VALUE_TARGET:~2%.ini"              set input.ValueIsOk=%STATUS_ON%
    if exist "%fs.InstallDir%\printers.%VALUE_TARGET:~2%.ini"   set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input file does not exist.
      @echo #
      @echo #   first file location:  "%CD%\printers.%VALUE_TARGET:~2%.ini"
      @echo #   second file location: "%fs.InstallDir%\printers.%VALUE_TARGET:~2%.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )

    set fs.IniDir=%fs.InstallDir%
    set fs.IniFile="%fs.InstallDir%\printers.%VALUE_TARGET:~2%.ini"

    if exist "%CD%\printers.%VALUE_TARGET:~2%.ini" (
      set fs.IniDir=%CD%
      set fs.IniFile="%CD%\printers.%VALUE_TARGET:~2%.ini"
    )

    set input.ValuesFromFile=%STATUS_ON%
  )


  if /i "%VALUE_TARGET%" EQU "%VALUE_TARGET_ALL%" (
    if /i "%context.IsCallBack%" NEQ "%STATUS_ON%" (
      wmic printer get Name                                                           >>  %fs.TmpDir%\%fs.LogFile:.log=.tmp1%
      type %fs.TmpDir%\%fs.LogFile:.log=.tmp1% | %fs.BinDir%\findstr /i /v /c:"Name"  >>  %fs.TmpDir%\%fs.LogFile:.log=.tmp2%
      type %fs.TmpDir%\%fs.LogFile:.log=.tmp2% | %fs.BinDir%\sed -e "s/ \+$//"        >>  %fs.TmpDir%\%fs.LogFile:.log=.ini%

      del /q /f %fs.TmpDir%\%fs.LogFile:.log=%.tmp?                                   >   nul

      set fs.IniFile=%fs.TmpDir%\%fs.LogFile:.log=.ini%
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

    set event.message="sctl printers: performing %VALUE_CMD% operation over the target printer(s). [%fs.LogsDir%\%SET_LOGFILE%]"
    if /i %VALUE_TARGET%      EQU %VALUE_TARGET_ALL%   set event.message="sctl printers: [%VALUE_TARGET%] performing %VALUE_CMD% operation over the target printer(s). [%fs.LogsDir%\%SET_LOGFILE%]"
    if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl printers: [%VALUE_TARGET:~2%] performing %VALUE_CMD% operation over the target printer(s). [%fs.LogsDir%\%SET_LOGFILE%]"

    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sctl:printers.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:  %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # target:       %VALUE_TARGET%
    @echo # command:      %VALUE_CMD%
    @echo # alert mode:   %VALUE_ALERTMODE%
    @echo # time to wait: %VALUE_TIMETOWAIT%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_CMD% EQU %VALUE_CMD_LIST% (
      @echo # current defined settings in [%CD%]:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\printers.*.ini") do (
        @echo   + %%i
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # current defined settings in [%fs.InstallDir%]:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\printers.*.ini) do (
        @echo   + %%i
      )


      goto EXIT
    )


    if /i %VALUE_CMD% EQU %VALUE_CMD_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\printers.*.ini") do (
        @echo   + %%i
      )

      for %%i in (%fs.InstallDir%\printers.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list "%CD%\printers.*.ini"
      %fs.BinDir%\list "%fs.InstallDir%\printers.*.ini"


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


    if /i %VALUE_CMD% EQU %VALUE_CMD_QUERY% (
      @echo # current enqueued print jobs [%VALUE_TARGET%]:
      @echo.

      if /i %input.ValuesFromFile% EQU %STATUS_ON% (
        for /f "eol=# tokens=*" %%i in (!fs.IniFile!) do (
          @echo   + printer: %%i
          @echo.

          %sys.ColorDark%

          %fs.InstallDir%\prnjobs.vbs -p "%%~i" -l

          @echo.
          %sys.ColorNormal%
        )
      ) else (
        call :QueryFromList "%VALUE_TARGET:~2%"
      )

      goto EXIT
    )


    @echo # current enqueued print jobs [%VALUE_TARGET%]:
    @echo.

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      for /f "eol=# tokens=*" %%i in (!fs.IniFile!) do (
        @echo   + printer: %%i
        @echo.

        %sys.ColorDark%

        %fs.InstallDir%\prnjobs.vbs -p "%%~i" -l

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :QueryFromList "%VALUE_TARGET:~2%"
    )


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # running [%VALUE_CMD%] command over target printer(s) defined in [%VALUE_TARGET%]:
    @echo.

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      for /f "eol=# tokens=*" %%i in (!fs.IniFile!) do (
        @echo   + processing printer: %%i
        @echo.

        %sys.ColorDark%

        if /i %VALUE_CMD% EQU %VALUE_CMD_PAUSE%  %fs.InstallDir%\prnqctl.vbs -p "%%~i" -z
        if /i %VALUE_CMD% EQU %VALUE_CMD_RESUME% %fs.InstallDir%\prnqctl.vbs -p "%%~i" -m
        if /i %VALUE_CMD% EQU %VALUE_CMD_PURGE%  %fs.InstallDir%\prnqctl.vbs -p "%%~i" -x

        if %errorlevel% NEQ %EL_PRNQCTL_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   printer name: %%i
          @echo.

          %sys.ColorNormal%

          set event.message="sctl printers: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          if /i %VALUE_TARGET%      EQU %VALUE_TARGET_ALL%   set event.message="sctl printers: [%VALUE_TARGET%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl printers: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:printers.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :RunCommandFromList "%VALUE_TARGET:~2%"
    )

    %fs.BinDir%\sleep %VALUE_TIMETOWAIT%

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # final enqueued print jobs [%VALUE_TARGET%]:
    @echo.

    if /i %input.ValuesFromFile% EQU %STATUS_ON% (
      for /f "eol=# tokens=*" %%i in (!fs.IniFile!) do (
        @echo   + printer: %%i
        @echo.

        %sys.ColorDark%

        %fs.InstallDir%\prnjobs.vbs -p "%%~i" -l

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      call :QueryFromList "%VALUE_TARGET:~2%"
    )


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sctl printers [{none^|all^|["l:prn1,prn2,[...]"]^|["f:group-label"]}]
      @echo                 [-cmd:{pause^|resume^|purge^|query^|list^|xlist}]
      @echo                 [-a:{yes^|no}]
      @echo                 [-w:99]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sctl printers none -cmd:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="sctl printers: %VALUE_CMD% operation over the target printer(s) completed. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET%      EQU %VALUE_TARGET_ALL%   set event.message="sctl printers: [%VALUE_TARGET%] %VALUE_CMD% operation over the target printer(s) completed. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl printers: [%VALUE_TARGET:~2%] %VALUE_CMD% operation over the target printer(s) completed. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sctl:printers.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd sctl.printers -l:%SET_LOGFILE% -trap:yes

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul


    if exist %fs.TmpDir%\%SET_LOGFILE:.log=.ini% del /q /f %fs.TmpDir%\%SET_LOGFILE:.log=.ini%  >  nul


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

      %fs.InstallDir%\prnjobs.vbs -p "%%~i" -l

      %sys.ColorNormal%

      if /i "%%j" NEQ "" call :QueryFromList "%%j"
      goto :EOF
    )

  endlocal



:RunCommandFromList

  setlocal enabledelayedexpansion

    for /f "delims=%LIST_DELIMITER% tokens=1,*" %%i in (%1) do (
      @echo   + processing printer: %%i
      @echo.

      %sys.ColorDark%

      if /i %VALUE_CMD% EQU %VALUE_CMD_PAUSE%  %fs.InstallDir%\prnqctl.vbs -p "%%~i" -z
      if /i %VALUE_CMD% EQU %VALUE_CMD_RESUME% %fs.InstallDir%\prnqctl.vbs -p "%%~i" -m
      if /i %VALUE_CMD% EQU %VALUE_CMD_PURGE%  %fs.InstallDir%\prnqctl.vbs -p "%%~i" -x

      if %errorlevel% NEQ %EL_PRNQCTL_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   printer name: %%i
        @echo.

        %sys.ColorNormal%

        set event.message="sctl printers: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        if /i %VALUE_TARGET%      EQU %VALUE_TARGET_ALL%   set event.message="sctl printers: [%VALUE_TARGET%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl printers: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sctl:printers.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      @echo.
      %sys.ColorNormal%


      if /i "%%j" NEQ "" call :RunCommandFromList "%%j"
      goto :EOF
    )

  endlocal



:ExitProgram