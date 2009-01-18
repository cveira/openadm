@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: dodelete
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
@rem   Creates Delegated Operation end-point on local system.
@rem
@rem Dependencies:
@rem   sc.exe          - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   install.cmd     - openadm [app2svc install module]
@rem   resdelete.cmd   - openadm [resdelete module]
@rem   alert.cmd       - openadm [rescreate alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm do -cmd:delete
@rem                           <-id:{<group-label>|list|xlist}>
@rem                           <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:   <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.BinDir:       <fs.SystemDrive>\openadm\bin\system
@rem   fs.SysOpDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ModulesDir:   <fs.SystemDrive>\openadm\modules
@rem   fs.ConfDir:      <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:       <fs.SystemDrive>\openadm\tmp
@rem   fs.CmdbDir:      <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.LogsDir:      <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sadm do -cmd:delete -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses a text file located on:
@rem     - <fs.InstallDir> : doexec.ini
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
  set fs.ModulesDir=%fs.SystemDrive%\openadm\modules
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\sadm

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


  set SET_LABELID=%1
  set SET_ALERTMODE=%2
  set SET_LOGFILE=%3

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    if /i "%SET_LABELID%"         EQU ""     goto HELP
    if /i "%SET_LABELID:~0,3%"    NEQ "-id"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"   goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"    set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"     set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\dodelete-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=dodelete-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\doexec.ini       set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.InstallDir%\doexec.ini
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
  if not exist %fs.SysOpDir%\install.cmd                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\resdelete.cmd            set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sc.exe                       set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.SysOpDir%\install.cmd
    @echo #   %fs.InstallDir%\resdelete.cmd
    @echo #   %fs.BinDir%\sc.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU do.begin set event.BeginId=%%j
    if /i %%i EQU do.end   set event.EndId=%%j
    if /i %%i EQU do.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    set event.message="dodelete: creating delegated operation end-point on local system. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:do.delete [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:               %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # delegated operation label: %VALUE_LABELID%
    @echo # alert mode:                %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.ModulesDir%\install\app2svc.do.*.ini) do (
        @echo   + %%i
      )

      @echo.

      for %%i in (%fs.ModulesDir%\install\services.do.*.ini) do (
        @echo   + %%i
      )

      for %%i in (%fs.ModulesDir%\sctl\services.do.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.ModulesDir%\install\app2svc.do.*.ini) do (
        @echo   + %%i
      )

      @echo.

      for %%i in (%fs.ModulesDir%\install\services.do.*.ini) do (
        @echo   + %%i
      )

      for %%i in (%fs.ModulesDir%\sctl\services.do.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\*.do.*.ini


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


    @echo # removing delegated operation configuration files:
    @echo.

    %sys.ColorDark%

    @echo   + %fs.InstallDir%\doexec.ini

    %fs.BinDir%\findstr /i /v /c:%VALUE_LABELID% %fs.InstallDir%\doexec.ini  >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
    type %fs.TmpDir%\%SET_LOGFILE:.log=.ini%                                 >   %fs.InstallDir%\doexec.ini
    del  /f /q %fs.TmpDir%\%SET_LOGFILE:.log=.ini%                           >   nul

    @echo   + %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini
    if exist %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini  del /f /q %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini  >  nul

    @echo   + %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    if exist %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg  del /f /q %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg  >  nul

    @echo   + %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    if exist %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini del /f /q %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini >  nul

    @echo   + %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini
    if exist %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini del /f /q %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini       >  nul


    %sys.ColorNormal%


    @echo.
    @echo # removing delegated operation end-point service:
    @echo.

    @echo   + current state of end-point service:
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\sc query do.%VALUE_LABELID%

    %sys.ColorNormal%

    @echo.
    @echo   + removing end-point service:
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\sc delete do.%VALUE_LABELID%

    if %errorlevel% NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   service: do.%VALUE_LABELID%
      @echo.

      %sys.ColorNormal%

      set event.message="dodelete: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:do.delete [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    %sys.ColorNormal%


    @echo.
    @echo # removing delegated operation end-point security objects:
    @echo.

    call %fs.InstallDir%\resdelete.cmd do.%VALUE_LABELID% -p:none -type:scm -scope:local -mode:exec -a:yes

    if %errorlevel% NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   resource label: do.%VALUE_LABELID%
      @echo.

      %sys.ColorNormal%

      set event.message="dodelete: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:do.delete [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sadm do -cmd:delete
      @echo           [-id:{[group-label]^|list^|xlist}]
      @echo           [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sadm do -cmd:delete -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="dodelete: delegated operation end-point on local system created. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:do.delete [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd dodelete -l:%SET_LOGFILE% -trap:yes

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