@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: xrun
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
@rem   Enlists all the existing sessions declared on the local system.
@rem
@rem Dependencies:
@rem   psexec.exe      - www.sysinternals.com (v1.92)
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [xrun alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\xrun <-id:{<group-label>|list|xlist}>
@rem                        <-mode:{test|normal|async}>
@rem                        <-w:99>
@rem                        "<command> <sub-command> <parameter1>|'<parameter2>'|[...]>"
@rem
@rem Disk locations:
@rem   fs.InstallDir:  <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:      <fs.SystemDrive>\openadm\bin\system
@rem   fs.SysOpDir:    <fs.SystemDrive>\openadm\actions\operations
@rem   fs.CmdbDir:     <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.ConfDir:     <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:      <fs.SystemDrive>\openadm\tmp
@rem   fs.LogsDir:     <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label]                                            - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]                                                   - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]                                                  - shows contents of configuration files currently available for this operation.
@rem   [-mode:test]                                                 - simulated execution: OpenADM shows which commands will be executed against each target computer.
@rem   [-mode:normal]                                               - regular syncronous execution: OpenADM does wait for each command to finish on each target computer.
@rem   [-mode:async]                                                - asyncronous execution: OpenADM does not wait for each command to finish on each target computer.
@rem   [-w:99]                                                      - time to wait between one operation and the following one.
@rem   "<command> <sub-command> <parameter1>|'<parameter2>'|[...]>" - OpenADM command to be executed remotely on machine names defined in xrun.<group-label>.ini.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   xrun -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : xrun.ini
@rem     - <fs.InstallDir> : xrun.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem
@rem   WARNING: Password information is transmitted in clear text. Be sure to use any
@rem   secure transport protocol to manage that risk.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\sadm

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

  set SET_LABELID=%1
  set SET_MODE=%2
  set SET_TIMETOWAIT=%3
  set SET_CMD=%4
  set SET_LOGFILE=%5

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_MODE=%SET_MODE:-mode=%
  set VALUE_TIMETOWAIT=%SET_TIMETOWAIT:-w:=%
  set VALUE_CMD=%SET_CMD:~1,-1%
  set VALUE_CMD=%VALUE_CMD:'="%

  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist
  set VALUE_MODE_TEST=test
  set VALUE_MODE_NORMAL=normal
  set VALUE_MODE_ASYNC=async
  set VALUE_MODE_NONE=none
  set VALUE_CMD_NONE=none

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_PSEXEC_OK=0
  set EL_PSEXEC_ERROR=1
  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i {%context.SkipExec%} EQU {%STATUS_OFF%} (
    if /i "%SET_LABELID:~0,3%"     NEQ "-id"    goto HELP
    if /i "%SET_MODE:~0,5%"        NEQ "-mode"  goto HELP
    if /i "%SET_TIMETOWAIT:~0,2%"  NEQ "-w"     goto HELP
    if /i "%SET_CMD%"              EQU ""       goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_MODE%" EQU "%VALUE_MODE_TEST%"   set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_MODE%" EQU "%VALUE_MODE_NORMAL%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_MODE%" EQU "%VALUE_MODE_ASYNC%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    if /i "%VALUE_LABELID%" NEQ "%VALUE_LABELID_LIST%" set VALUE_LABELID=%VALUE_LABELID_XLIST%
    set VALUE_MODE=%VALUE_MODE_NONE%
    set VALUE_TIMETOWAIT=0
    set VALUE_CMD=%VALUE_CMD_NONE%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\xrun-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=xrun-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.BinDir%\sleep.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\psexec.exe                   set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\sleep.exe
    @echo #   %fs.BinDir%\psexec.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\xrun.ini                  set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\xrun.%VALUE_LABELID%.ini  set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\xrun.ini
      @echo #   %fs.InstallDir%\xrun.%VALUE_LABELID%.ini
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU xrun.begin set event.BeginId=%%j
    if /i %%i EQU xrun.end   set event.EndId=%%j
    if /i %%i EQU xrun.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN
  call %~dpnx0 MAIN %* %fs.LogFile% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.


    if /i %context.SkipExec% EQU %STATUS_OFF% (
      set psexec.SessionParameters=
      for /f "eol=# tokens=*" %%i in (%fs.InstallDir%\xrun.ini) do set psexec.SessionParameters=!psexec.SessionParameters! %%i
	)


    set event.message="xrun: [%VALUE_LABELID%] executing OpenADM activities remotely. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "xrun:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:  %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:  %VALUE_LABELID%
    @echo # mode:         %VALUE_LABELID%
    @echo # time to wait: %VALUE_TIMETOWAIT%
    @echo # command:      %VALUE_CMD%
    @echo # ------------------------------------------------------------------------
    @echo.

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\xrun.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\xrun.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\xrun.*.ini


      goto EXIT
    )


    %sys.ColorDark%

    if /i {%VALUE_MODE%} EQU {%VALUE_MODE_TEST%} (
    	for /f "eol=# tokens=1,2,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\xrun.%VALUE_LABELID%.ini) do (
        @echo   + %fs.BinDir%\psexec /accepteula \\%%i -u %%j -p %%k -w %fs.TmpDir% !psexec.SessionParameters! %VALUE_CMD%
    	)
    )


    if /i {%VALUE_MODE%} EQU {%VALUE_MODE_NORMAL%} (
    	for /f "eol=# tokens=1,2,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\xrun.%VALUE_LABELID%.ini) do (
    	  @echo   + target server [%%i] as user [%%j]
    	  @echo.

    	  %fs.BinDir%\psexec /accepteula \\%%i -u %%j -p %%k -w %fs.TmpDir% !psexec.SessionParameters! %VALUE_CMD%

    	  if {!errorlevel!} NEQ {%EL_STATUS_OK%} (
      		@echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      		%sys.ColorRed%

      		@echo.
      		@echo # ERROR: unexpected operation error.
      		@echo #
      		@echo #   server:   %%i
      		@echo #   user:     %%j
      		@rem @echo #   password: %%k
      		@echo.

      		%sys.ColorNormal%

      		set event.message="xrun: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      		%fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "xrun:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message!  >  nul
    	  )

        %fs.BinDir%\sleep %VALUE_TIMETOWAIT%
    	)
    )


    if /i {%VALUE_MODE%} EQU {%VALUE_MODE_ASYNC%} (
    	for /f "eol=# tokens=1,2,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\xrun.%VALUE_LABELID%.ini) do (
    	  @echo   + target server [%%i] as user [%%j]
    	  @echo.

    	  start %fs.BinDir%\psexec /accepteula \\%%i -u %%j -p %%k -w %fs.TmpDir% !psexec.SessionParameters! %VALUE_CMD%

        %fs.BinDir%\sleep %VALUE_TIMETOWAIT%
    	)
    )


    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   xrun [-id:{[group-label]^|list^|xlist}]
      @echo        [-mode:{test^|normal^|async}]
      @echo        [-w:99]
      @echo        "[command] [sub-command] [parameter1]^|'[parameter2]'^|[...]]"
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     xrun -id:{list^|xlist}
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   WARNING: Password information is transmitted in clear text. Be
      @echo   sure to use any secure transport protocol to manage that risk.
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="xrun: [%VALUE_LABELID%] OpenADM activities remotely executed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "xrun:%VALUE_LABELID% [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd xrun -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes


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