@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: aclrestore (ACL Restore)
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
@rem   Restore the Security Descriptor into the target directory.
@rem
@rem Dependencies:
@rem   setacl.exe      - setacl.sf.net (v2.0.2)
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [aclrestore alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm acl -cmd:restore
@rem                            <-id:{none|<group-label>}>
@rem                            <-mode:{exec|query}>
@rem                            <{none|<target-dir>}>
@rem                            <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:   <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.SysOpDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:      <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:       <fs.SystemDrive>\openadm\tmp
@rem   fs.BinDir:       <fs.SystemDrive>\openadm\bin\system
@rem   fs.BackupDir:    <fs.DataDrive>\pub\fs\support\settings\aclbackup
@rem   fs.LogsDir:      <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:none]         - when in query mode, sets no file-filter, letting the view of every available backup files.
@rem   [-id:group-label]  - label name used as filter to select the file to restore from.
@rem   [-mode:exec]       - performs a restore operation.
@rem   [-mode:query]      - lists currently available backup files filtering by <group-label>.
@rem   [-id:none]         - target object ignored. Used with -cmd:list.
@rem   <target-dir>       - target dir full path with no trailing back slash.
@rem   [-a:{yes|no}]      - alert mode: it triggers a post-execution log analysis.
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.ConfDir> : el.iddb.ini
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\sadm
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.BackupDir=%fs.DataDrive%\pub\fs\support\settings\aclbackup
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
  set SET_MODE=%2
  set SET_TARGETDIR=%3
  set SET_ALERTMODE=%4
  set SET_LOGFILE=%5

  set VALUE_MODE=%SET_MODE:-mode:=%
  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_TARGETDIR=%SET_TARGETDIR:"=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_MODE_EXEC=exec
  set VALUE_MODE_SEARCH=search
  set VALUE_MODE_QUERY=query
  set VALUE_LABELID_NONE=none
  set VALUE_TARGETDIR_NONE=none

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set user.ExitCode=%EL_STATUS_OK%

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;


  if /i "%SET_LABELID:~0,3%"    NEQ "-id"    goto HELP
  if /i "%SET_MODE:~0,5%"       NEQ "-mode"  goto HELP
  if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"     goto HELP

  set input.ValueIsOk=%STATUS_OFF%

  if /i "%VALUE_MODE%" EQU "%VALUE_MODE_EXEC%"   set input.ValueIsOk=%STATUS_ON%
  if /i "%VALUE_MODE%" EQU "%VALUE_MODE_QUERY%"  set input.ValueIsOk=%STATUS_ON%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"  set input.ValueIsOk=%STATUS_ON%
  if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"   set input.ValueIsOk=%STATUS_ON%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


  if /i {%VALUE_LABELID%} EQU {%VALUE_LABELID_NONE%} set VALUE_MODE=%VALUE_MODE_QUERY%
  if /i {%VALUE_MODE%}    EQU {%VALUE_MODE_QUERY%}   set VALUE_TARGETDIR=%VALUE_TARGETDIR_NONE%


  set fs.TargetDir=%VALUE_TARGETDIR%
  if /i {%VALUE_TARGETDIR%} NEQ {%VALUE_TARGETDIR_NONE%} (
    if /i "!fs.TargetDir:~-1!" EQU "\" set fs.TargetDir=!fs.TargetDir:~0,-1!
    if not exist "!fs.TargetDir!" goto HELP
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\aclrestore-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=aclrestore-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.BinDir%\mtee.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\colorx.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\datex.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\alert.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\setacl.exe                   set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\setacl.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU acl.begin set event.BeginId=%%j
    if /i %%i EQU acl.end   set event.EndId=%%j
    if /i %%i EQU acl.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    set event.message="aclrestore: requested command [%VALUE_MODE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:acl.restore [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:      %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:      %VALUE_LABELID%
    @echo # mode:             %VALUE_MODE%
    @echo # target directory: %VALUE_TARGETDIR%
    @echo # alert mode:       %VALUE_ALERTMODE%
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


    if /i %VALUE_MODE% EQU %VALUE_MODE_EXEC% (
      @echo # restoring ACLs
      @echo.

      %sys.ColorDark%

      set fs.BackupFile=%fs.BackupDir%\aclbackup-%VALUE_LABELID%

      %fs.BinDir%\setacl -on %VALUE_TARGETDIR% -ot file -actn restore -bckp %fs.BackupFile%.bak

      if {!errorlevel!} NEQ {%EL_STATUS_OK%} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%
        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo.

        %sys.ColorNormal%

        set event.message="aclrestore: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:acl.restore [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      %sys.ColorNormal%
    ) else (
      @echo # current stored ACL backups with label: %VALUE_LABELID%
      @echo.

      %sys.ColorDark%

      if /i "%VALUE_LABELID%" EQU "%VALUE_LABELID_NONE%" (
        set fs.file.BackupNameFilter=%fs.BackupDir%\aclbackup-*
      ) else (
        set fs.file.BackupNameFilter=%fs.BackupDir%\aclbackup-%VALUE_LABELID%*
      )

      for /f %%i in ('dir /b %fs.file.BackupNameFilter%') do (
        for /f "tokens=1,2,3* delims=-" %%j in (%%~ni) do (
          @echo   %%k-%%l
        )
      )

      %sys.ColorNormal%
    )

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sadm acl -cmd:restore
      @echo            [-id:none^|[group-label]]
      @echo            [-mode:{exec^|query}]
      @echo            [none^|[target-dir]]
      @echo            [-a:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ========================================================================
    %sys.ColorNormal%

    set event.message="aclrestore: executed command [%VALUE_MODE%]"
    %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:acl.restore [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd aclrestore -l:%SET_LOGFILE% -trap:yes

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