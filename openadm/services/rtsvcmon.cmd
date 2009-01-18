@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: rtsvcmon
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
@rem   Real Time Service Monitor.
@rem
@rem Dependencies:
@rem   wmic.exe        - win2k3 server
@rem   sc.exe          - win2k3 server
@rem   schtasks.exe    - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   sleep.exe       - win2k3 reskit
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [services.rtsvcmon alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\rtsvcmon
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\services
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\services
@rem ------------------------------------------------------------------------------------
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem     - <fs.InstallDir> : rtsvcmon.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\services
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\services

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

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\rtsvcmon-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=rtsvcmon-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.InstallDir%\rtsvcmon.ini     set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.InstallDir%\rtsvcmon.ini
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
  if not exist %fs.BinDir%\sc.exe                       set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\schtasks.exe                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.BinDir%\sc.exe
    @echo #   %fs.BinDir%\schtasks.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #   %fs.BinDir%\sleep.exe
    @echo #   %systemroot%\system32\wbem\wmic.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU service.begin set event.BeginId=%%j
    if /i %%i EQU service.end   set event.EndId=%%j
    if /i %%i EQU service.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN
  call %~dpnx0 MAIN %* %fs.LogFile% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\rtsvcmon.ini) do (
      if /i %%i EQU openadm.RefreshPolicy   set openadm.RefreshPolicy=%%j
      if /i %%i EQU openadm.TimeToWait      set openadm.TimeToWait=%%j
      if /i %%i EQU openadm.StrJobIsRunning set openadm.StrJobIsRunning=%%j
    )

    set event.message="rtsvcmon: starting real-time service monitor. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "service:rtsvcmon [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:    %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # refresh policy: %openadm.RefreshPolicy%
    @echo # time to wait:   %openadm.TimeToWait%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    set event.BeginMessage="rtsvcmon: polling services. [%fs.LogsDir%\%SET_LOGFILE%]"
    set event.EndMessage="rtsvcmon: services polled. [%fs.LogsDir%\%SET_LOGFILE%]"

    :SECUREIT

      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "service:rtsvcmon" /d %event.BeginMessage% > nul

      for /f "eol=# tokens=1,*" %%i in (%fs.InstallDir%\rtsvcmon.ini) do (
        if /i %%i EQU service.Name (
          for /f "usebackq" %%j in (`wmic service where "Name = '%%~i' and State = 'Stopped'" get Name`) do (
            if /i %%j NEQ Name (
              %fs.BinDir%\sc start "%%~j"
              %fs.BinDir%\sleep %openadm.TimeToWait%
              %fs.BinDir%\sc query "%%~j"

              set event.message="rtsvcmon: service unavailable [%%~j]. [%fs.LogsDir%\%SET_LOGFILE%]"
              %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "service:rtsvcmon [%SET_SSNSEQ%]" /d !event.message!  >  nul

              call %fs.SysOpDir%\alert.cmd services.rtsvcmon -l:%fs.LogFile% -svc:"%%~j" -trap:yes
            )
          )
        )

        if /i %%i EQU service.Process (
          set process.count=0

          for /f "usebackq" %%j in (`wmic process where "CommandLine like '%%%~j%' or ExecutablePath like '%%%~j%'" get ProcessId`) do (
            if /i %%i NEQ ProcessId (
              set /a process.count+=1
            )
          )

          if % process.count% EQU 0 (
            call %fs.SysOpDir%\alert.cmd services.rtsvcmon -l:%fs.LogFile% -svc:"%%~j" -trap:yes
          )
        )



        if /i %%i EQU service.Job (
          set process.count=0

          for /f "usebackq tokens=1-4 delims=%LIST_DELIMITER%" %%a in (`%fs.BinDir%\schtasks /query /nh /fo csv`) do (
            if /i "%%~a" EQU "%%~j" (
              if /i "%%~d" NEQ "%openadm.StrJobIsRunning%" (
                %fs.BinDir%\schtasks /run /tn "%%~a"
                %fs.BinDir%\sleep %openadm.TimeToWait%
                %fs.BinDir%\schtasks /query | findstr /i %%~a

                call %fs.SysOpDir%\alert.cmd services.rtsvcmon -l:%fs.LogFile% -svc:"%%~j" -trap:yes
              )
            )
          )
        )

      )

      %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "service:rtsvcmon" /d %event.EndMessage% > nul

      %fs.BinDir%\sleep %openadm.RefreshPolicy%

    goto SECUREIT

    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ========================================================================
    %sys.ColorNormal%

    set event.message="rtsvcmon: real-time service monitor stopped. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "service:rtsvcmon [%SET_SSNSEQ%]" /d !event.message! > nul

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul

    goto MAIN-EXIT


  :MAIN-EXIT
  :END

endlocal