@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: archive urfolder
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
@rem   Sequentially launches <archive folder> operations against certain directories of a
@rem   given resource that match the search criteria stablished on an external text
@rem   file.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [urfolder alert module]
@rem   archive.cmd     - openadm [folder module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\archive urfolder {none|<target-dir>}
@rem                                  <-id:{<group-label>|list|xlist}>
@rem                                  <-w:99>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\archive
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\archive
@rem
@rem   target-dir:     <target-dir>
@rem   archive-dir:    e:\archive\urfolder
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <none>            - target object ignored. Used with -id:{list|xlist}.
@rem   <target-dir>      - existing full-path directory name.
@rem   <-id:group-label> - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-w:99]           - time to wait between the start and the query operation.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   archive urfolder none -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : urfolder.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\archive
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\archive

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
  set SET_LABELID=%2
  set SET_TIMETOWAIT=%3
  set SET_LOGFILE=%4
  set SET_SSNSEQ=%5

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_TIMETOWAIT=%SET_TIMETOWAIT:-w:=%

  set VALUE_TARGET_NONE=none
  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_ARCHIVEFSDIR_OK=0
  set EL_ARCHIVEFSDIR_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i "%SET_TARGET:"=%" NEQ "%VALUE_TARGET_NONE%" (
    if /i "%SET_TARGET%"           EQU ""     goto HELP
    if /i "%SET_LABELID:~0,3%"     NEQ "-id"  goto HELP
    if /i "%SET_TIMETOWAIT:~0,2%"  NEQ "-w"   goto HELP


    set fs.TargetDir=%SET_TARGET:"=%
    if /i "!fs.TargetDir:~-1!" EQU "\" set fs.TargetDir=!fs.TargetDir:~0,-1!
    if not exist "!fs.TargetDir!" goto HELP
  ) else (
    if /i "%VALUE_LABELID%" NEQ "%VALUE_LABELID_LIST%" set VALUE_LABELID=%VALUE_LABELID_XLIST%
    set VALUE_TIMETOWAIT=0
  )

  if /i %context.SkipExec% EQU %STATUS_ON% (
    set VALUE_TARGET=%VALUE_TARGET_NONE%
    set VALUE_TIMETOWAIT=0
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\urfolder-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=urfolder-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.SysOpDir%\archive.cmd                set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.SysOpDir%\archive.cmd
    @echo #   %fs.BinDir%\sleep.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\urfolder.%VALUE_LABELID%.ini set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\urfolder.%VALUE_LABELID%.ini
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
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\urfolder.%VALUE_LABELID%.ini) do (
        if /i %%i EQU fs.DestinationDir   set fs.DestinationDir=%%~j
        if /i %%i EQU folderSearchPattern set folderSearchPattern=%%j
      )

      set fs.DestinationDir=%fs.DestinationDir:"=%
      if /i "!fs.DestinationDir:~-1!" EQU "\" set fs.DestinationDir=!fs.DestinationDir:~0,-1!
      if not exist "!fs.DestinationDir!" goto HELP
    )


    set event.message="archive urfolder: [%VALUE_LABELID%] processing resource %SET_TARGET%. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "archive:urfolder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:           %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      %sys.ColorBright%
      @echo # target dir:            "!fs.TargetDir!"
      @echo # group label:           %VALUE_LABELID%
      @echo # time to wait:          %VALUE_TIMETOWAIT%
      @echo # ------------------------------------------------------------------------
      @echo # destination dir:       "!fs.DestinationDir!"
      @echo # folder search pattern: "%folderSearchPattern%"
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
    )

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\urfolder.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\urfolder.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\urfolder.*.ini


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


    @echo # requested archive operations:
    @echo.

    %sys.ColorDark%

    set user.CurrentDir="%CD%"
    cd /d !fs.TargetDir!    >  nul

    for /d /r . %%i in (%folderSearchPattern%) do (
      @echo   + %fs.SysOpDir%\archive.cmd folder "%%~i" "!fs.DestinationDir!" -id:%VALUE_LABELID%.%%~ni -mode:tree -vol:none -a:yes
      call %fs.SysOpDir%\archive.cmd folder "%%~i" "!fs.DestinationDir!" -id:%VALUE_LABELID%.%%~ni -mode:tree -vol:none -a:yes

      if %errorlevel% NEQ %EL_ARCHIVEFSDIR_OK% (
        @echo %errorlevel% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   target resource:      "%%~i"
        @echo #   destination resource: "!fs.DestinationDir!"
        @echo #   resource label:       %VALUE_LABELID%.%%~ni
        @echo.

        %sys.ColorNormal%

        set event.message="archive urfolder: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "archive:urfolder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      %fs.BinDir%\sleep %VALUE_TIMETOWAIT%
    )

    cd /d %user.CurrentDir%  >  nul

    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   archive urfolder [{none^|[target-dir]}]
      @echo                    [-id:{[group-label]^|list^|xlist}]
      @echo                    [-w:99]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     archive urfolder none -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="archive urfolder: [%VALUE_LABELID%] resource %SET_TARGET% processed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "archive:urfolder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd archive.urfolder -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:no

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