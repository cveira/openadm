@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: scan storage
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
@rem   Verifies File Systems data structures.
@rem
@rem Dependencies:
@rem   eventcreate.exe                     - win2k3 server
@rem   chkdsk.exe                          - win2k3 server
@rem   fsutil.exe                          - win2k3 server
@rem   diskpart.exe                        - win2k3 server
@rem   wmic.exe                            - win2k3 server
@rem   sleep.exe                           - win2k3 reskit
@rem   mtee.exe                            - http://www.commandline.co.uk (v2.0)
@rem   datex.exe                           - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe                          - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   sctl.cmd                            - openadm [scm module]
@rem   alert.cmd                           - openadm [scan.storage alert module]
@rem   <fs.InstallDir>\storage.*.[cmd|ini] - openadm [scan storage extension modules]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\scan storage <-profile:{quick|deep|safe|info}>
@rem                              <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\scan
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\scan
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-profile:quick] - quick operation mode.
@rem   [-profile:deep]  - deep operation mode.
@rem   [-profile:safe]  - stop certain services during deep scan operation.
@rem   [-profile:info]  - collect file system information.
@rem   [-a:{yes|no}]    - alert mode: it triggers a post-scan log analysis.
@rem
@rem Important notes:
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : storage.ini
@rem     - <fs.ConfDir>    : sys.diskvolumes.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\scan
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\scan

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


  set SET_PROFILE=%1
  set SET_ALERTMODE=%2
  set SET_LOGFILE=%3
  set SET_SSNSEQ=%4

  set VALUE_PROFILE=%SET_PROFILE:-profile:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_PROFILE_QUICK=quick
  set VALUE_PROFILE_DEEP=deep
  set VALUE_PROFILE_SAFE=safe
  set VALUE_PROFILE_INFO=info

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_CHKDSK_OK=0
  set EL_CHKDSK_ERROR=3
  set EL_FSUTIL_OK=0
  set EL_FSUTIL_ERROR=1
  set EL_DISKPART_OK=0
  set EL_DISKPART_ERROR=1
  set EL_WMIC_OK=0
  set EL_WMIC_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_PROFILE%"      EQU ""       goto HELP
  if /i %SET_PROFILE:~0,8%   NEQ -profile goto HELP
  if /i %SET_ALERTMODE:~0,2% NEQ -a       goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_QUICK% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_DEEP%  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_SAFE%  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_PROFILE% EQU %VALUE_PROFILE_INFO%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES%        set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%         set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\storage-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=storage-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini               set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\el.local.ini              set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\storage.ini            set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\el.local.ini
    @echo #   %fs.InstallDir%\storage.ini
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
  if not exist %fs.SysOpDir%\sctl.cmd                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\chkdsk.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\fsutil.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\diskpart.exe                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sleep.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\wbem\wmic.exe      set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.SysOpDir%\sctl.cmd
    @echo #   %fs.BinDir%\chkdsk.exe
    @echo #   %fs.BinDir%\fsutil.exe
    @echo #   %fs.BinDir%\diskpart.exe
    @echo #   %fs.BinDir%\sleep.exe
    @echo #   %systemroot%\system32\wbem\wmic.exe
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

    set event.message="scan storage: scanning system. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by: %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # profile:     %VALUE_PROFILE%
    @echo # alert mode:  %VALUE_ALERTMODE%
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


    @echo # scanning storage subsystems ...


    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\storage.ini) do (
      if /i %%i EQU %VALUE_PROFILE_QUICK% (
        if %VALUE_PROFILE% EQU %VALUE_PROFILE_QUICK% call %fs.InstallDir%\%%j.cmd
      )

      if /i %%i EQU %VALUE_PROFILE_DEEP% (
        if %VALUE_PROFILE% EQU %VALUE_PROFILE_DEEP%  call %fs.InstallDir%\%%j.cmd
      )

      if /i %%i EQU %VALUE_PROFILE_SAFE% (
        if %VALUE_PROFILE% EQU %VALUE_PROFILE_SAFE%  call %fs.InstallDir%\%%j.cmd
      )

      if /i %%i EQU %VALUE_PROFILE_INFO% (
        if %VALUE_PROFILE% EQU %VALUE_PROFILE_INFO%  call %fs.InstallDir%\%%j.cmd
      )
    )

    if exist %fs.TmpDir%\%SET_LOGFILE:.log=.exit% (
      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   selected profile: %VALUE_PROFILE%
      @echo.

      %sys.ColorNormal%

      set event.message="scan storage: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "scan:storage [%VALUE_PROFILE%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   scan storage [-profile:{quick^|deep^|safe^|info}]
      @echo                [-a:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="scan storage: system scanned. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "scan.storage [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd scan.storage -l:%SET_LOGFILE% -trap:yes

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