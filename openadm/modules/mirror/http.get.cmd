@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: mirror http.get
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
@rem   Performs a local mirror of a remote web resource through HTTP/HTTPS.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   wget.exe        - http://xoomer.virgilio.it/hherold/ (v1.10.2)
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [mirror.http.get alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\mirror http.get {none|<server[:port]>}
@rem                                 {none|<destination-dir>}
@rem                                 <-id:{<group-label>|list|xlist}>
@rem                                 <-p:{yes|no}>
@rem                                 <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:     <fs.SystemDrive>\openadm\modules\mirror
@rem   fs.ConfDir:        <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:         <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:       <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:         <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:        <fs.DataDrive>\logs\openadm\mirror
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <none>             - target object ignored. Used with -id:{list|xlist}.
@rem   <server[:port]>    - FQDN DNS name of the HTTPS server publishing the web resource.
@rem   <destination-dir>  - full path to the local directory where the mirror is going to be
@rem                        placed.
@rem   [-id:group-label]  - label ID to select a different set of connection and
@rem                        category settings different from the main ones.
@rem   [-id:list]         - enumerates configuration files currently available for this operation.
@rem   [-p:{yes|no}]      - proxy mode: de/activates transmission over HTTP proxy.
@rem   [-a:{yes|no}]      - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   mirror http.get none none -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : http.get.[group-label].ini
@rem     - <fs.InstallDir> : http.get.[group-label].source.ini
@rem     - <fs.InstallDir> : http.get.[group-label].connection.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   The connection files store connection credentials to the web resource. They
@rem   must be considered as any other sensitive information file. That is why the
@rem   <fs.InstallDir> directory has secure ACLs by default.
@rem
@rem   Web site credentials are passed through the command-line in clear text.
@rem   This allows any local or remote user with the proper tools to look at the
@rem   command-line parameters of the process and grab that credentials.
@rem   Unfortunately, given current functionality implemented on wget, there is
@rem   no way to overcome this scenario.
@rem
@rem   The connection files must avoid passwords containing any of the special
@rem   characters declared on CMD: [ @ % ^ ! | <> & () : ; ' ` " [] {} = + ~ * ? \ ]
@rem
@rem   mirror http.get creates a <web.SessionLog> directory inside <destination-dir>.
@rem
@rem   It also needs write acces on <destination-dir>:
@rem
@rem   mirror http.get downloads every file on the remote web resource. It was designed
@rem   to be used in conjuntion with the  directory browsing feature present on
@rem   the web server. To perform a clean download, mirror http.get clears up any HTML
@rem   page downloaded as part of the directory browsing pages. It does not delete
@rem   any image file like file type icons rendered by some web servers. So, if
@rem   you want a clean download configure your web server to render graphicless
@rem   HTML pages as part of the directory browsing feature.
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

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\mirror
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\mirror

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


  set SET_SERVERSOURCE=%1
  set SET_DESTINATION=%2
  set SET_LABELID=%3
  set SET_PROXYMODE=%4
  set SET_ALERTMODE=%5
  set SET_LOGFILE=%6
  set SET_SSNSEQ=%7

  set VALUE_SERVERSOURCE=%SET_SERVERSOURCE:https://:=%
  set VALUE_SERVERSOURCE=%SET_SERVERSOURCE:http://:=%
  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_PROXYMODE=%SET_PROXYMODE:-p:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_SERVERSOURCE_NONE=none
  set VALUE_DESTINATION_NONE=none
  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_WGET_OK=0
  set EL_WGET_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i {%VALUE_SERVERSOURCE:"=%} NEQ {%VALUE_TARGET_NONE%} (
    if /i "%VALUE_SERVERSOURCE%"   EQU ""     goto HELP
    if /i "%SET_DESTINATION%"      EQU ""     goto HELP
    if /i "%SET_LABELID:~0,3%"     NEQ "-id"  goto HELP
    if /i "%SET_PROXYMODE:~0,2%"   NEQ "-p"   goto HELP
    if /i "%SET_ALERTMODE:~0,2%"   NEQ "-a"   goto HELP


    set fs.DestinationDir=%SET_DESTINATION:"=%
    if /i "!fs.DestinationDir:~-1!" EQU "\" set fs.DestinationDir=!fs.DestinationDir:~0,-1!
    if not exist "!fs.DestinationDir!" goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_PROXYMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_PROXYMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set SET_DESTINATION=%VALUE_DESTINATION_NONE%
    if /i "%VALUE_LABELID%" NEQ "%VALUE_LABELID_LIST%" set VALUE_LABELID=%VALUE_LABELID_XLIST%
    set VALUE_PROXYMODE=%STATUS_NO%
    set VALUE_ALERTMODE=%STATUS_NO%

    set fs.DestinationDir=%SET_DESTINATION:"=%
  )

  if /i %context.SkipExec% EQU %STATUS_ON% (
    set VALUE_SERVERSOURCE=%VALUE_SERVERSOURCE_NONE%
    set SET_DESTINATION=%VALUE_DESTINATION_NONE%
    set VALUE_PROXYMODE=%STATUS_NO%
    set VALUE_ALERTMODE=%STATUS_NO%

    set fs.DestinationDir=%SET_DESTINATION:"=%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\http.get-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=http.get-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.BinDir%\wget.exe                     set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\wget.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\http.get.%VALUE_LABELID%.ini             set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\http.get.%VALUE_LABELID%.connection.ini  set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\http.get.%VALUE_LABELID%.source.ini      set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\http.get.%VALUE_LABELID%.ini
      @echo #   %fs.InstallDir%\http.get.%VALUE_LABELID%.connection.ini
      @echo #   %fs.InstallDir%\http.get.%VALUE_LABELID%.source.ini
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )
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

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      set web.SessionSSL=--sslprotocol=3
      set web.SessionSourceFile=%fs.InstallDir%\http.get.%VALUE_LABELID%.source.ini
      set web.SessionConnectionFile=%fs.InstallDir%\http.get.%VALUE_LABELID%.connection.ini
      set web.SessionDestinationDir=!fs.DestinationDir!
      set web.SessionServerUser=
      set web.SessionServerPassword=
      set web.SessionProxyUser=
      set web.SessionProxyPassword=

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!web.SessionConnectionFile!) do (
        if /i "%%i" EQU "server.user" set web.SessionServerUser=%%j
        if /i "%%i" EQU "server.pwd"  set web.SessionServerPassword=%%j
        if /i "%%i" EQU "proxy.user"  set web.SessionProxyUser=%%j
        if /i "%%i" EQU "proxy.pwd"   set web.SessionProxyPassword=%%j
      )

      if not exist "!web.SessionDestinationDir!\logs" md "!web.SessionDestinationDir!\logs"  >  nul
      set web.SessionLog="!web.SessionDestinationDir!\logs\%SET_LOGFILE%"

      set web.SessionParameters=

      for /f "eol=# tokens=*" %%i in (%fs.InstallDir%\http.get.%VALUE_LABELID%.ini) do (
        set web.SessionParameters=!web.SessionParameters! %%i
        if /i %%i EQU !web.SessionSSL! set web.SessionIsSSL=%STATUS_YES%
      )

      set web.SessionPrintableParameters=-a !web.SessionLog! !web.SessionParameters!
      set web.SessionParameters=-a !web.SessionLog! !web.SessionParameters!

      if !web.SessionServerUser! NEQ anonymous     set web.SessionParameters=!web.SessionParameters! --http-user=!web.SessionServerUser! --http-password=!web.SessionServerPassword!
      if %VALUE_PROXYMODE%       EQU %STATUS_YES%  set web.SessionParameters=!web.SessionParameters! --proxy --proxy-user=!web.SessionProxyUser! --proxy-password=!web.SessionProxyPassword!

      if !web.SessionIsSSL! EQU %STATUS_YES% (
        set web.SessionProtocol=https
      ) else (
        set web.SessionProtocol=http
      )
    )


    set event.message="mirror http.get: [%VALUE_LABELID%] updating "!web.SessionDestinationDir!". [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "mirror:http.get [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:     %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # source server:   %VALUE_SERVERSOURCE%
    @echo # destination dir: "!fs.DestinationDir!"
    @echo # group label:     %VALUE_LABELID%
    @echo # proxy mode:      %VALUE_PROXYMODE%
    @echo # alert mode:      %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\http.get.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\http.get.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\http.get.*.ini


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


    @echo # updating "!web.SessionDestinationDir!" ...
    @echo.

    set user.CurrentDir="%CD%"
    cd /d "!web.SessionDestinationDir!"              >  nul

    for /f "eol=# tokens=*" %%i in (!web.SessionSourceFile!) do (
      @echo   + web resource: %%i
      @echo.

      %sys.ColorDark%

      %fs.BinDir%\wget !web.SessionParameters! !web.SessionProtocol!://%VALUE_SERVERSOURCE%/%%i

      if {!errorlevel!} NEQ {%EL_WGET_OK%} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   target web resource:    %%i
        @echo #   web session parameters: !web.SessionPrintableParameters!
        @echo #   proxy mode:             %VALUE_PROXYMODE%
        @echo #   SSL mode:               !web.SessionIsSSL!
        @echo #   web resource:           !web.SessionProtocol!://%VALUE_SERVERSOURCE%/%%i
        @echo.

        %sys.ColorNormal%

        set event.message="mirror http.get: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "mirror:http.get [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      @echo.
      %sys.ColorNormal%
    )

    if exist "!web.SessionLog!" (
      @echo.
      @echo # ------------------------------------------------------------------------
      @echo # session log:
      @echo.

      %sys.ColorDark%

      type "!web.SessionLog!"
      @echo.

      %sys.ColorNormal%
    )

    del /f /s /q !web.SessionDestinationDir!\*.htm?  2>&1
    cd /d %user.CurrentDir%                           >  nul

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   mirror http.get [{none^|[server[:port]}]
      @echo                   [{none^|[destination-dir]}]
      @echo                   [-id:{[group-label]^|list^|xlist}]
      @echo                   [-p:{yes^|no}]
      @echo                   [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     mirror http.get none none -id:{list^|xlist}
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

      set event.message="mirror http.get: [%VALUE_LABELID%] "!web.SessionDestinationDir!" updated. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "mirror:http.get [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd mirror.http.get -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes

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