@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sys.echo
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
@rem   Notifies that the system is alive to the Management Server.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   net.exe         - win2k3 server
@rem   blat.exe        - www.blat.net (v2.5.0)
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   update.cmd      - openadm [update.sys.info module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\sys.echo
@rem
@rem Disk locations:
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\operations
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem ------------------------------------------------------------------------------------
@rem Important notes:
@rem   It uses several text files located on <fs.ConfDir>:
@rem     - el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\operations
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp

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


  set context.IsCallBack=0
  if %1 EQU MAIN (
    set context.IsCallBack=1
    shift
  )

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set user.ExitCode=%EL_STATUS_OK%

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\sys.echo-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=sys.echo-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU sys.echo set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN
  call %~dpnx0 MAIN %* %fs.LogFile% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    for /f %%i in (%fs.ConfDir%\customer.id.ini) do set customer.id=%%i
    for    %%i in (%fs.TmpDir%\sys.info.log)     do set fs.file.SysInfo=%%i

    set mail.ServerUser=
    set mail.ServerPassword=

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\sys.alerts.ini) do (
      if /i %%i EQU sys.AlertByMail        set sys.AlertByMail=%%j
      if /i %%i EQU sys.AlertByNetSend     set sys.AlertByNetSend=%%j
      if /i %%i EQU sys.AlertServerName    set sys.AlertServerName=%%j

      if /i %%i EQU mail.ProfileIsActive   set mail.ProfileIsActive=%%j
      if /i %%i EQU mail.ProfileName       set mail.ProfileName=%%j
      if /i %%i EQU mail.log               set mail.log=%%j
      if /i %%i EQU mail.server            set mail.server=%%j
      if /i %%i EQU mail.ServerPort        set mail.ServerPort=%%j
      if /i %%i EQU mail.ServerUser        set mail.ServerUser=%%j
      if /i %%i EQU mail.ServerPassword    set mail.ServerPassword=%%j
      if /i %%i EQU mail.SourceDomain      set mail.SourceDomain=%%j
      if /i %%i EQU mail.DestinationDomain set mail.DestinationDomain=%%j
    )

    set mail.from=%COMPUTERNAME%.%customer.id%@%mail.SourceDomain%
    set mail.to=alerts.%customer.id%@%mail.DestinationDomain%
    set mail.subject="sys.echo: system alive"


    set event.message="sys.echo: updating system information summary. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "sys.echo [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by: %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo.

    call %fs.InstallDir%\update.cmd sys.info
    call :SEND_ALERT


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ========================================================================
    %sys.ColorNormal%

    set event.message="sys.echo: system information summary updated. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "sys.echo [%SET_SSNSEQ%]" /d !event.message! > nul

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


:SEND_ALERT

  setlocal
    set mail.body=%fs.file.SysInfo%

    if /i %sys.AlertByNetSend% EQU %STATUS_YES% net send %sys.AlertServerName% %mail.subject%

    if /i %sys.AlertByMail% EQU %STATUS.YES% (
      if %mail.ProfileIsActive% EQU %STATUS.YES% (
        %fs.BinDir%\blat %mail.body% -p %mail.ProfileName% -to %mail.to% -s "%mail.subject:"=%" -attacht %fs.file.SysInfo% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
      ) else (
        if "%mail.ServerUser%" EQU "" (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.file.SysInfo% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat %mail.body% -to %mail.to% -f %mail.from% -s "%mail.subject:"=%" -attacht %fs.file.SysInfo% -server %mail.server% -port %mail.ServerPort% -log %fs.LogsDir%\%mail.log% -timestamp -priority 1 -noh2 -u %mail.ServerUser% -pw %mail.ServerPassword%
        )
      )
    )

    call :SEND_ALERT_ISOK %errorlevel%
  endlocal

  goto :EOF


:SEND_ALERT_ISOK

  setlocal
    set SET_ERRORCODE=%1

    if %SET_ERRORCODE% EQU %STATUS_OK% (
      @echo.
      @echo # mail trap has been sent:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.file.SysInfo%
      @echo.

      set event.message="sys.echo: mail trap has been sent. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "sys.echo [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to send mail trap:
      @echo #
      @echo #   sender:        %mail.from%
      @echo #   recipient:     %mail.to%
      @echo #   subject:       %mail.subject%
      @echo #   attached file: %fs.file.SysInfo%
      @echo.

      %sys.ColorNormal%

      set event.message="sys.echo: unable to send mail trap. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sys.echo [%SET_SSNSEQ%]" /d !event.message! > nul
    )
  endlocal

  goto :EOF