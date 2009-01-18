@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: ssnmirror
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
@rem   net.exe         - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   mirror.cmd      - openadm [folder module]
@rem   alert.cmd       - openadm [ssnmirror alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm session -cmd:mirror
@rem                                {none|<session-id>}
@rem                                <-id:{<group-label>|list|xlist}>
@rem                                <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:  <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.BinDir:      <fs.SystemDrive>\openadm\bin\system
@rem   fs.SysOpDir:    <fs.SystemDrive>\openadm\actions\operations
@rem   fs.CmdbDir:     <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.ConfDir:     <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:      <fs.SystemDrive>\openadm\tmp
@rem   fs.LogsDir:     <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <none>            - target object ignored. Used with -id:{list|xlist}.
@rem   <session-id>      - session label.
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sadm session -cmd:mirror none -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : ssnmirror.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\sadm
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

  set SET_SESSIONID=%1
  set SET_LABELID=%2
  set SET_ALERTMODE=%3
  set SET_LOGFILE=%4

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set SET_SESSIONID_NONE=none
  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_NET_OK=0
  set EL_NET_ERROR=1
  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i %SET_SESSIONID:"=% NEQ %SET_SESSIONID_NONE% (
    if /i "%SET_SESSIONID:"=%"    EQU ""     goto HELP
    if /i "%SET_LABELID:~0,3%"    NEQ "-id"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"   goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"                   set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"                    set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    if /i "%VALUE_LABELID%" NEQ "%VALUE_LABELID_LIST%" set VALUE_LABELID=%VALUE_LABELID_XLIST%
    set VALUE_ALERTMODE=%STATUS_NO%
  )

  if /i %VALUE_CMD% EQU %VALUE_CMD_LIST% (
    set SET_SESSIONID=%SET_SESSIONID_NONE%
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\ssnmirror-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=ssnmirror-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.SysOpDir%\mirror.cmd                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\net.exe            set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.SysOpDir%\mirror.cmd
    @echo #   %systemroot%\system32\net.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\ssnmirror.%VALUE_LABELID%.ini           set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\ssnmirror.%VALUE_LABELID%.ini
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU session.begin set event.BeginId=%%j
    if /i %%i EQU session.end   set event.EndId=%%j
    if /i %%i EQU session.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN
  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    set event.message="ssnmirror: [%VALUE_LABELID%] mirroring OpenADM CMDB session from local system. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:ssn.mirror [%SET_SESSIONID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:  %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # command:      %SET_SESSIONID%
    @echo # group label:  %VALUE_LABELID%
    @echo # alert mode:   %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
    @echo.

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\ssnmirror.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\ssnmirror.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\ssnmirror.*.ini


      goto EXIT
    )


    %sys.ColorDark%

    if exist %fs.CmdbDir%\%SET_SESSIONID% (
      for /f "eol=# tokens=1,2,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\ssnmirror.%VALUE_LABELID%.ini) do (
        net use \\%%i\sys-openadm$ /u:%%j %%k  >  nul

        if %errorlevel% NEQ %EL_NET_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unable to connect to target server.
          @echo #
          @echo #   server:   %%i
          @echo #   user:     %%j
          @rem @echo #   password: %%k
          @echo.

          %sys.ColorNormal%

          set event.message="ssnmirror: [%VALUE_LABELID%] unable to connect to target server. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:ssn.mirror [%SET_SESSIONID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
        ) else (
          call %fs.SysOpDir%\mirror.cmd folder %fs.CmdbDir%\%SET_SESSIONID% \\%%i\sys-openadm$\cmdb\incoming\%SET_SESSIONID% -id:ssnmirror.%SET_SESSIONID% -rs:1 -a:yes

          if %errorlevel% NEQ %EL_STATUS_OK% (
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

            set event.message="ssnmirror: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
            %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:ssn.mirror [%SET_SESSIONID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
          )
        )

        net use \\%%i\sys-openadm$ /d /y  >  nul
      )
    ) else (
      %sys.ColorRed%
      @echo # WARNING: session doesn't exist.
      %sys.ColorNormal%

      set event.message="ssnclose: session doesn't exist. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "ssnclose:%SET_SESSIONID% [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sadm session -cmd:mirror
      @echo                [{none^|[session-id]}]
      @echo                [-id:{group-label^|list^|xlist}]
      @echo                [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sadm session -cmd:mirror none -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="ssnmirror: [%VALUE_LABELID%] OpenADM CMDB session from local system mirrored. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:ssn.mirror [%SET_SESSIONID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd ssnmirror -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes


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