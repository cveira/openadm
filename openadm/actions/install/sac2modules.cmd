@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sac2modules
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
@rem   Looks for binary files required by OpenADM and places them in <fs.ModulesDir>
@rem
@rem Dependencies:
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem
@rem Usage:
@rem   <fs.SysOpDir>\sac2modules <-id:{<group-label>}> <-mode:{exec|test}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\actions\install
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.ModulesDir: <fs.SystemDrive>\openadm\modules
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\install
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-mode:exec]      - it sets execution mode: changes will be done on the system.
@rem   [-mode:test]      - it sets test mode: no changes will be done on the system.
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : sac2modules.<group-label>.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\actions\install
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ModulesDir=%fs.SystemDrive%\openadm\modules
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\install

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
  set SET_LOGFILE=%3

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_MODE=%SET_MODE:-mode:=%

  set VALUE_MODE_EXEC=exec
  set VALUE_MODE_TEST=test

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_LABELID%"          EQU ""       goto HELP
  if /i "%SET_LABELID:~0,3%"     NEQ "-id"    goto HELP
  if /i "%SET_MODE:~0,5%"        NEQ "-mode"  goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_MODE% EQU %VALUE_MODE_EXEC%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_MODE% EQU %VALUE_MODE_TEST%                   set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\sac2modules-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=sac2modules-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.InstallDir%\sac2modules.%VALUE_LABELID%.ini  set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.InstallDir%\sac2modules.%VALUE_LABELID%.ini
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN
  call %~dpnx0 MAIN %* %fs.LogFile% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:    %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:    %VALUE_LABELID%
    @echo # execution mode: %VALUE_MODE%
    @echo # ------------------------------------------------------------------------
    @echo.

    set context.UserDir=%CD%
    cd /d %fs.SystemDrive%\  >  nul

    if /i {%VALUE_MODE%} EQU {%VALUE_MODE_EXEC%} (
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\sac2modules.%VALUE_LABELID%.ini) do (
        %sys.ColorDark%

        @echo   + %%i

        for /f "tokens=*" %%k in ('dir /s /b %%i') do (
          if exist "%%~dpnxk" (
            copy /v /y "%%~dpnxk" %%j  >  nul

            if {!errorlevel!} NEQ {%EL_STATUS_OK%} (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

              %sys.ColorRed%

              @echo.
              @echo # ERROR: unexpected operation error.
              @echo.

              %sys.ColorNormal%
            )
          ) else (
            %sys.ColorRed%

            @echo     + file not found: "%%~dpnxk"

            %sys.ColorNormal%
          )
        )

        @echo.
        %sys.ColorNormal%
      )
    ) else (
      %sys.ColorDark%

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\sac2modules.%VALUE_LABELID%.ini) do (
        @echo   + %%i

        for /f "tokens=*" %%k in ('dir /s /b %%i') do (
          if exist "%%~dpnxk" (
            @echo     + "%%~dpnxk" - %%j
          ) else (
            %sys.ColorRed%

            @echo     + file not found: "%%~dpnxk" - %%j

            %sys.ColorNormal%
          )
        )

        @echo.
      )

      %sys.ColorNormal%
    )

    cd /d %context.UserDir%

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sac2modules [-id:{[group-label]}]
      @echo               [-mode:{exec^|test}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

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