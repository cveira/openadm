@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: docreate
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
@rem   eventcreate.exe - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   install.cmd     - openadm [app2svc install module]
@rem   rescreate.cmd   - openadm [rescrete module]
@rem   alert.cmd       - openadm [rescreate alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm do -cmd:create
@rem                           <-id:{<group-label>|list|xlist}>
@rem                           <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:   <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.BinDir:       <fs.SystemDrive>\openadm\bin\system
@rem   fs.SysOpDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ActionsDir:   <fs.SystemDrive>\openadm\actions
@rem   fs.ConfDir:      <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:       <fs.SystemDrive>\openadm\tmp
@rem   fs.CmdbDir:      <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.ModulesDir:   <fs.SystemDrive>\openadm\modules
@rem   fs.LogsDir:      <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sadm do -cmd:create -id:{list|xlist}
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
  set fs.ActionsDir=%fs.SystemDrive%\openadm\actions
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
  for %%i in (%fs.LogsDir%\docreate-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=docreate-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.SysOpDir%\install.cmd                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\rescreate.cmd            set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.InstallDir%\rescreate.cmd
    @echo #   %fs.BinDir%\sc.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\docreate.%VALUE_LABELID%.ini           set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\docreate.%VALUE_LABELID%.ini
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )
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

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      set DelegatedOperation.User=""
      set DelegatedOperation.Password=""

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\docreate.%VALUE_LABELID%.ini) do (
        if /i "%%i" EQU "DelegatedOperation.FullPathCommand" set DelegatedOperation.FullPathCommand=%%j
        if /i "%%i" EQU "DelegatedOperation.AppStartUpDir"   set DelegatedOperation.AppStartUpDir=%%j
        if /i "%%i" EQU "DelegatedOperation.User"            set DelegatedOperation.User=%%j
        if /i "%%i" EQU "DelegatedOperation.Password"        set DelegatedOperation.Password=%%j
      )
    )


    set event.message="docreate: creating delegated operation end-point on local system. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:do.create [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

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

      for %%i in (%fs.InstallDir%\docreate.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\docreate.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\docreate.*.ini


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


    @echo # creating delegated operation configuration files:
    @echo.

    %sys.ColorDark%

    @echo   + %fs.InstallDir%\doexec.ini

    @echo %VALUE_LABELID%;!DelegatedOperation.FullPathCommand!>> %fs.InstallDir%\doexec.ini


    @echo   + %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini

    @echo #property;value>  %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini
    @echo.>> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini
    @echo SourceFolder;%fs.ActionsDir%\install\app2svc\do>> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini
    @echo TargetFolder;%fs.ActionsDir%\do>> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.ini


    @echo   + %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg

    @echo Windows Registry Editor Version 5.00>  %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    @echo.>> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    @echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\do.%VALUE_LABELID%\Parameters]>> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    @echo "AppDirectory"="!DelegatedOperation.AppStartUpDir!">> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    @echo "Application"="%systemroot:\=\\%\\system32\\cmd.exe">> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg
    @echo "AppParameters"="/c %fs.InstallDir:\=\\%\\doexec.cmd %VALUE_LABELID% -a:yes">> %fs.ModulesDir%\install\app2svc.do.%VALUE_LABELID%.reg

    @echo   + %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini

    @echo #property;value>  %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    @echo.>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    @echo ID;do.%VALUE_LABELID%>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    @echo DisplayName;do.%VALUE_LABELID%>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    @echo BinPath;C:\openadm\bin\system\srvany.exe>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    @echo Dependencies;Tcpip>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini

    if /i "!DelegatedOperation.User!" EQU "" (
      @echo #User;LocalSystem>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
      @echo #Password;>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    ) else (
      @echo User;!DelegatedOperation.User!>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
      @echo Password;!DelegatedOperation.Password!>> %fs.ModulesDir%\install\services.do.%VALUE_LABELID%.ini
    )

    @echo   + %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini

    @echo #service.name>  %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini
    @echo.>> %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini
    @echo do.%VALUE_LABELID%>> %fs.ModulesDir%\sctl\services.do.%VALUE_LABELID%.ini

    %sys.ColorNormal%


    @echo.
    @echo # creating delegated operation end-point service:
    @echo.

    call %fs.SysOpDir%\install.cmd app2svc -id:do.%VALUE_LABELID% -mode:exec -a:no

    if %errorlevel% NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   service: %%i
      @echo.

      %sys.ColorNormal%

      set event.message="docreate: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:do.create [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    @echo.
    @echo # creating delegated operation end-point security:
    @echo.

    call %fs.InstallDir%\rescreate.cmd do.%VALUE_LABELID% -p:none -type:scm -acl:bit -scope:local -mode:exec -a:yes

    if %errorlevel% NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   service: %%i
      @echo.

      %sys.ColorNormal%

      set event.message="docreate: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:do.create [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    ver | %fs.BinDir%\findstr /i "XP" > nul
    if %errorlevel% NEQ %EL_STATUS_OK% call :AllowRemoteSCM

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sadm do -cmd:create
      @echo           [-id:{[group-label]^|list^|xlist}]
      @echo           [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sadm do -cmd:create -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="docreate: delegated operation end-point on local system created. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:do.create [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd docreate -l:%SET_LOGFILE% -trap:yes

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

goto :ExitDoCreate



:AllowRemoteSCM

    @echo.
    @echo # adjusting SCM ACL:
    @echo.

    @echo   + current SCM ACL:
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\sc sdshow SCMANAGER

    %sys.ColorNormal%

    @echo.
    @echo   + new SCM ACL:
    @echo.

    %sys.ColorDark%

    @echo     D:(A;;CCLCRPRC;;;AU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)S:(AU;FA;KA;;;WD)(AU;OIIOFA;GA;;;WD)
    @echo.

    %sys.ColorNormal%

    %fs.BinDir%\sc sdset SCMANAGER D:(A;;CCLCRPRC;;;AU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)S:(AU;FA;KA;;;WD)(AU;OIIOFA;GA;;;WD) > nul

    if {%errorlevel%} NEQ {%EL_STATUS_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   service: %%i
      @echo.

      %sys.ColorNormal%

      set event.message="docreate: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:do.create [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


  goto :EOF



:ExitDoCreate