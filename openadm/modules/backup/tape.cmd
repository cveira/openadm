@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: backup tape
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
@rem   Back up files to tape and performs operations to keep the log
@rem   files in a safe place and mood.
@rem
@rem Dependencies:
@rem   ntbackup.exe    - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [backup.tape alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\backup tape {none|sysstate|<selection-filename>}
@rem                             <-id:{<group-label>|list|xlist}>
@rem                             <-mode:{full|inc}>
@rem                             <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:      <fs.SystemDrive>\openadm\modules\backup
@rem   fs.ConfDir:         <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:          <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:        <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:          <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:         <fs.DataDrive>\logs\openadm\backup
@rem
@rem   fs.NtBackupLogDir: [defined in tape.<group-label>.ini]
@rem ------------------------------------------------------------------------------------
@rem Important notes:
@rem   <none>                - target object ignored. Used with -id:{list|xlist}.
@rem   <sysstate>            - selects system state as backup source
@rem   <selection-filename>  - full-path to the ntbackup selection file.
@rem   [-id:group-label]     - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]            - enumerates configuration files currently available for this operation.
@rem   [-mode:full]          - performs a full backup
@rem   [-mode:inc]           - performs an incremental backup
@rem   [-a:{yes|no}]         - alert  mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   backup tape none -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : tape.<group-label>.ini
@rem     - <fs.InstallDir> : tape.<group-label>.settings.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   This script assumes that NO OTHER NT Backup operations are done
@rem   during its execution.
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\backup
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\backup

  set dd=%date:~0,2%
  set mm=%date:~3,2%
  set yy=%date:~8,2%
  set yyyy=%date:~6,4%

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


  set SET_SOURCE=%1
  set SET_LABELID=%2
  set SET_OPERATIONMODE=%3
  set SET_ALERTMODE=%4
  set SET_LOGFILE=%5
  set SET_SSNSEQ=%6

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%
  set VALUE_OPERATIONMODE=%SET_OPERATIONMODE:-mode:=%

  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist
  set VALUE_OPERATIONMODE_FULL=full
  set VALUE_OPERATIONMODE_INC=inc
  set VALUE_OPERATIONMODE_NA=N/A
  set VALUE_SOURCE_NONE=none
  set VALUE_SOURCE_SYSSTATE=sysstate

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_NTBACKUP_OK=0
  set EL_NTBACKUP_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i %SET_SOURCE:"=% NEQ %VALUE_SOURCE_NONE% (
    if /i "%SET_SOURCE%"              EQU ""       goto HELP
    if /i "%SET_OPERATIONMODE:~0,5%"  NEQ "-mode"  goto HELP
    if /i "%SET_LABELID:~0,3%"        NEQ "-id"    goto HELP
    if /i "%SET_ALERTMODE:~0,2%"      NEQ "-a"     goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_OPERATIONMODE%" EQU "%VALUE_OPERATIONMODE_FULL%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_OPERATIONMODE%" EQU "%VALUE_OPERATIONMODE_INC%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set VALUE_OPERATIONMODE=%VALUE_OPERATIONMODE_NA%
    if /i "%VALUE_LABELID%" NEQ "%VALUE_LABELID_LIST%" set VALUE_LABELID=%VALUE_LABELID_XLIST%
    set VALUE_ALERTMODE=%STATUS_NO%
  )

  if /i %context.SkipExec% EQU %STATUS_ON% (
    set SET_SOURCE=%VALUE_SOURCE_NONE%
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\backup.tape-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=backup.tape-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.BinDir%\ntbackup.exe                 set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\ntbackup.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\tape.%VALUE_LABELID%.ini           set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\tape.%VALUE_LABELID%.settings.ini  set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\tape.%VALUE_LABELID%.ini
      @echo #   %fs.InstallDir%\tape.%VALUE_LABELID%.settings.ini
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
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\tape.%VALUE_LABELID%.ini) do (
        if /i "%%i" EQU "fs.NtBackupLogDir" set fs.NtBackupLogDir=%%~j
        if /i "%%i" EQU "device.id"         set device.id=%%j
      )

      set fs.NtBackupLogDir=!fs.NtBackupLogDir:"=!
      if /i "!fs.NtBackupLogDir:~-1!" EQU "\" set fs.NtBackupLogDir=!fs.NtBackupLogDir:~0,-1!
      if not exist "!fs.NtBackupLogDir!" goto HELP

      if /i %VALUE_BACKUPMODE% EQU %VALUE_OPERATIONMODE_INC% (
        for /f "usebackq delims==" %%i in (`rsm view /tphysical_media /cg%device.id% /guiddisplay /b`)          do set device.tape.id=%%i
        for /f "usebackq delims==" %%i in (`rsm view /tpartition /cg%device.tape.id% /guiddisplay /b`)          do set device.partition.id=%%i
        for /f "usebackq delims==" %%i in (`rsm view /tlogical_media /cg%device.partition.id% /guiddisplay /b`) do set device.lmedia.id=%%i

        set p1=!device.lmedia.id:~0,8!
        set p2=!device.lmedia.id:~8,4!
        set p3=!device.lmedia.id:~12,4!
        set p4=!device.lmedia.id:~16,4!
        set p5=!device.lmedia.id:~20,12!

        set device.lmedia.guid=!p1!-!p2!-!p3!-!p4!-!p5!
      )

      set ntbackup.SessionParameters=
      for /f "eol=# tokens=*" %%i in (%fs.InstallDir%\tape.%VALUE_LABELID%.settings.ini) do (
        set ntbackup.SessionParameters=!ntbackup.SessionParameters! %%i
      )

      if /i %VALUE_OPERATIONMODE% EQU %VALUE_OPERATIONMODE_FULL% set ntbackup.SessionMode=/m normal
      if /i %VALUE_OPERATIONMODE% EQU %VALUE_OPERATIONMODE_INC%  set ntbackup.SessionMode=/m incremental

      if /i %SET_SOURCE%          EQU %VALUE_SOURCE_SYSSTATE% (
        set ntbackup.SessionSource=%VALUE_SOURCE_SYSSTATE%
      ) else (
        set ntbackup.SessionSource="@%fs.InstallDir%\%SET_SOURCE%.bks"
        if not exist %fs.InstallDir%\%SET_SOURCE%.bks goto HELP
      )

      set ntbackup.SessionLabel=backup.tape-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%
    )


    set event.message="backup tape: [%VALUE_LABELID%] starting backup. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "backup:tape [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:        %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      %sys.ColorBright%
      @echo # source:             !ntbackup.SessionSource!
      @echo # media logical GUID: !device.lmedia.guid!
      @echo # group label:        %VALUE_LABELID%
      @echo # operation mode:     %VALUE_OPERATIONMODE%
      @echo # alert mode:         %VALUE_ALERTMODE%
      @echo # ------------------------------------------------------------------------
      @echo # session parameters: !ntbackup.SessionParameters!
      @echo # session mode:       !ntbackup.SessionMode:/m =!
      @echo # session label:      !ntbackup.SessionLabel!
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
    )

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\tape.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\tape.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\tape.*.ini


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


    @echo # current status of ntbackup log directory:
    @echo.

    set user.CurrentDir="%CD%"
    cd /d "!fs.NtBackupLogDir!"  >  nul

    %sys.ColorDark%

    dir  *.* /a /o:gen /q /l /c /4

    %sys.ColorNormal%

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorRed%
    @echo # errors detected when cleaning ntbackup log directory:
    @echo.

    %sys.ColorDark%

    del /f /q *.*  2>&1

    %sys.ColorNormal%

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # final status of ntbackup log directory:
    @echo.

    %sys.ColorDark%

    dir  *.* /a /o:gen /q /l /c /4

    %sys.ColorNormal%

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # ntbackup operation:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_BACKUPMODE% EQU %VALUE_BACKUPMODE_FULL% (
      %fs.BinDir%\ntbackup backup !ntbackup.SessionSource! !ntbackup.SessionParameters! !ntbackup.SessionMode! /j "!ntbackup.SessionLabel!" /d "!ntbackup.SessionLabel!" /p "4mm DDS" /um
    ) else (
      %fs.BinDir%\ntbackup backup !ntbackup.SessionSource! !ntbackup.SessionParameters! !ntbackup.SessionMode! /j "!ntbackup.SessionLabel!" /d "!ntbackup.SessionLabel!" /g "!device.lmedia.guid!" /a /um
    )

    if %errorlevel% NEQ %EL_NTBACKUP_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   session.source:      !ntbackup.SessionSource!
      @echo #   media logical GUID:  !device.lmedia.guid!
      @echo #   session.label:       !ntbackup.SessionLabel!
      @echo #   session.mode:        %ntbackup.SessionMode:/m =%
      @echo #   session.parameters:  !ntbackup.SessionParameters!
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    cd /d "!fs.NtBackupLogDir!"  >  nul
    for %%i in ("!fs.NtBackupLogDir!"\*.log) do set ntbackup.SessionLog="%%~i"

    if NOT exist %ntbackup.SessionLog% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to find %ntbackup.SessionLog%.
      @echo #
      @echo #   session.source:      !ntbackup.SessionSource!
      @echo #   media logical GUID:  !device.lmedia.guid!
      @echo #   session.label:       !ntbackup.SessionLabel!
      @echo #   session.mode:        %ntbackup.SessionMode:/m =%
      @echo #   session.parameters:  !ntbackup.SessionParameters!
      @echo #   session.log:         %ntbackup.SessionLog%
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: [%VALUE_LABELID%] unable to find %ntbackup.SessionLog%. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      type %ntbackup.SessionLog%
      del /f /q %ntbackup.SessionLog%  2>&1
    )

    %sys.ColorNormal%

    cd /d %user.CurrentDir%  >  nul


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   backup tape [{none^|sysstate^|[selection-filename]}]
      @echo               [-id:{[group-label]^|list^|xlist}]
      @echo               [-mode:{full^|inc}]
      @echo               [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     backup tape none -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="backup tape: [%VALUE_LABELID%] backup finished. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "backup:tape [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd backup.tape -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes

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