@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sctl tapes
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
@rem   It issues a management command to RSM in order to perform certain device
@rem   or media operations.
@rem
@rem Dependencies:
@rem   rsm.exe         - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [sctl.tapes alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\sctl tapes {none|<"f:group-label">}
@rem                            <-cmd:{eject|list|xlist}>
@rem                            <-a:{yes|no}>
@rem                            <-w:99>
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
@rem   <"f:group-label"> - target objects stored in a configuration file sysmon.<group-label>.ini
@rem   [-cmd:eject]      - ejects media from a tape device.
@rem   [-cmd:list]       - enumerates configuration files currently available for this operation.
@rem   [-cmd:xlist]      - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem   [-w:99]           - time to wait between one operation and the following one.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   sctl tapes none -cmd:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : tapes.<group-label>.ini
@rem     - <%CD%>          : tapes.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   The first time you set up this script you must feed it with the GUID
@rem   of the Tape Library using the RSM command (rsm view /tlibrary /guiddisplay)
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
  set VALUE_TARGET_NONE=none
  set VALUE_CMD_EJECT=eject
  set VALUE_CMD_LIST=list
  set VALUE_CMD_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_RSM_OK=0
  set EL_RSM_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_TARGET:"=%" NEQ "%VALUE_TARGET_NONE%" (
    if /i "%SET_TARGET:"=%"        EQU ""      goto HELP
    if /i "%SET_CMD:~0,4%"         NEQ "-cmd"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"   NEQ "-a"    goto HELP
    if /i "%SET_TIMETOWAIT:~0,2%"  NEQ "-w"    goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_EJECT%"  set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LIST%"   set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_CMD%" EQU "%VALUE_CMD_XLIST%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

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

  set fs.LogFileRootName=tapes
  if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE% set fs.LogFileRootName=tapes-%VALUE_TARGET:~2%

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
  if not exist %fs.BinDir%\rsm.exe                      set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.BinDir%\rsm.exe
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

    if exist "%CD%\tapes.%VALUE_TARGET:~2%.ini"               set input.ValueIsOk=%STATUS_ON%
    if exist "%fs.InstallDir%\tapes.%VALUE_TARGET:~2%.ini"    set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   first file location:  "%CD%\tapes.%VALUE_TARGET:~2%.ini"
      @echo #   second file location: "%fs.InstallDir%\tapes.%VALUE_TARGET:~2%.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )

    set fs.IniDir=%fs.InstallDir%
    set fs.IniFile="%fs.InstallDir%\tapes.%VALUE_TARGET:~2%.ini"

    if exist "%CD%\tapes.%VALUE_TARGET:~2%.ini" (
      set fs.IniDir=%CD%
      set fs.IniFile="%CD%\tapes.%VALUE_TARGET:~2%.ini"
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

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\tapes.%VALUE_TARGET:~2%.ini) do (
        if /i "%%i" EQU "device.Id"        set device.Id=%%j
      )
    )


    set event.message="sctl tapes: performing %SET_CMD% command operation over selected device. [%fs.LogsDir%\%SET_LOGFILE%]"
    if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl tapes: [%VALUE_TARGET:~2%] performing %SET_CMD% command operation over selected device. [%fs.LogsDir%\%SET_LOGFILE%]"

    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sctl:tapes.%VALUE_TARGET:~2% [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:  %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:  %VALUE_TARGET%
    @echo # command:      %VALUE_CMD%
    @echo # alert mode:   %VALUE_ALERTMODE%
    @echo # time to wait: %VALUE_TIMETOWAIT%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_CMD% EQU %VALUE_CMD_LIST% (
      @echo # current defined settings in [%CD%]:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\tapes.*.ini") do (
        @echo   + %%i
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # current defined settings in [%fs.InstallDir%]:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\tapes.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_CMD% EQU %VALUE_CMD_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\tapes.*.ini") do (
        @echo   + %%i
      )

      for %%i in (%fs.InstallDir%\tapes.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list "%CD%\tapes.*.ini"
      %fs.BinDir%\list "%fs.InstallDir%\tapes.*.ini"


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


    @echo # current state of selected device on group %VALUE_TARGET%:
    @echo.

    %sys.ColorDark%

    for /f "usebackq delims==" %%i in (`rsm view /tphysical_media /cg!device.Id! /guiddisplay /b`)         do set device.TapeId=%%i
    for /f "usebackq delims==" %%i in (`rsm view /tpartition /cg%device.TapeId% /guiddisplay /b`)          do set device.PartitionId=%%i
    for /f "usebackq delims==" %%i in (`rsm view /tlogical_media /cg%device.PartitionId% /guiddisplay /b`) do set device.LMediaId=%%i


    @rsm view /tphysical_media /cg!device.Id! /guiddisplay /b  >  nul

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + physical media state: OK
    ) else (
      @echo   + physical media state: FAIL

      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: physical media state failure.
      @echo #
      @echo #   device.Id: !device.Id!
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: physical media state failure. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="backup tape: [%VALUE_TARGET:~2%] physical media state failure. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%SET_SSNSEQ%]" /d !event.message! > nul

      goto EXIT
    )


    @rsm view /tpartition /cg%device.TapeId% /guiddisplay /b  >  nul

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + physical media partition state: OK
    ) else (
      @echo   + physical media partition state: FAIL

      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: physical media partition state failure.
      @echo #
      @echo #   device.TapeId: !device.TapeId!
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: physical media partition state failure. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="backup tape: [%VALUE_TARGET:~2%] physical media partition state failure. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%SET_SSNSEQ%]" /d !event.message! > nul

      goto EXIT
    )


    @rsm view /tlogical_media /cg%device.PartitionId% /guiddisplay /b  >  nul

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + logical media state: OK
    ) else (
      @echo   + logical media state: FAIL

      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: logical media state failure.
      @echo #
      @echo #   device.PartitionId: !device.PartitionId!
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: logical media state failure. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="backup tape: [%VALUE_TARGET:~2%] logical media state failure. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%SET_SSNSEQ%]" /d !event.message! > nul

      goto EXIT
    )

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # running [%VALUE_CMD%] command of selected device on group %VALUE_TARGET%:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_CMD% EQU %VALUE_CMD_EJECT% (
      for /f "usebackq delims==" %%i in (`rsm view /tphysical_media /cg!device.Id! /guiddisplay /b`) do rsm eject /pg%%i /astart /b
    )

    if !errorlevel! NEQ %EL_RSM_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   device.Id: !device.Id!
      @echo.

      %sys.ColorNormal%

      set event.message="backup tape: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="backup tape: [%VALUE_TARGET:~2%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:tape [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    %sys.ColorNormal%

    %fs.BinDir%\sleep %VALUE_TIMETOWAIT%


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # final state of selected device on group %VALUE_TARGET%:
    @echo.

    %sys.ColorDark%

    for /f "usebackq delims==" %%i in (`rsm view /tphysical_media /cg!device.Id! /guiddisplay /b`)          do set device.TapeId=%%i
    for /f "usebackq delims==" %%i in (`rsm view /tpartition /cg%device.TapeId% /guiddisplay /b`)          do set device.PartitionId=%%i
    for /f "usebackq delims==" %%i in (`rsm view /tlogical_media /cg%device.PartitionId% /guiddisplay /b`) do set device.LMediaId=%%i

    @rsm view /tphysical_media /cg!device.Id! /guiddisplay /b

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + physical media state: OK
    ) else (
      @echo   + physical media state: FAIL
    )

    @rsm view /tpartition /cg%device.TapeId% /guiddisplay /b

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + physical media partition state: OK
    ) else (
      @echo   + physical media partition state: FAIL
    )

    @rsm view /tlogical_media /cg%device.PartitionId% /guiddisplay /b

    if !errorlevel! EQU %EL_STATUS_OK% (
      @echo   + logical media state: OK
    ) else (
      @echo   + logical media state: FAIL
    )

    %sys.ColorNormal%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sctl tapes [{none^|["f:group-label"]}]
      @echo              [-cmd:{eject^|list^|xlist}]
      @echo              [-a:{yes^|no}]
      @echo              [-w:99]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     sctl tapes none -cmd:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%


      set event.message="sctl tapes: %SET_CMD% command operation over selected device completed. [%fs.LogsDir%\%SET_LOGFILE%]"
      if /i %VALUE_TARGET:~0,2% EQU %VALUE_TARGET_FILE%  set event.message="sctl tapes: [%VALUE_TARGET:~2%] %SET_CMD% command operation over selected device completed. [%fs.LogsDir%\%SET_LOGFILE%]"

      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sctl:tapes.%VALUE_TARGET:~2% [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd sctl.tapes -l:%SET_LOGFILE% -trap:yes

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