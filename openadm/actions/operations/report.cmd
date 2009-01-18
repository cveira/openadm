@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: report
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
@rem   Routes the user to the proper report sub-command and/or launches a given sub-command.
@rem
@rem Dependencies:
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   *.cmd           - openadm [report modules]
@rem
@rem Usage:
@rem   <fs.InstallDir>\report <sub-command>
@rem
@rem Disk locations:
@rem   fs.InstallDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:        <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:         <fs.SystemDrive>\openadm\bin\system
@rem   fs.ModulesDir:     <fs.SystemDrive>\openadm\modules\report
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <sub-command>   - stands for an active module name.
@rem
@rem Important notes:
@rem   It uses a text file located on <fs.InstallDir>:
@rem     - report.ini
@rem ------------------------------------------------------------------------------------

setlocal

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ModulesDir=%fs.SystemDrive%\openadm\modules\report

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


  set SET_CMD=%1

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%STATUS_OFF%


  if not exist %fs.InstallDir%\report.ini (
    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\report.ini
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto EXIT
  )


  if /i "%SET_CMD%" EQU "" goto HELP


  :MAIN
    set command.IsNotFound=%STATUS_ON%

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\report.ini) do (
      if /i %SET_CMD% EQU %%i (
        set command.IsNotFound=%STATUS_OFF%
      )
    )

    if %command.IsNotFound% EQU %STATUS_ON% (
      goto HELP
    ) else (
      call %fs.ModulesDir%\%*
    )

    set user.ExitCode=%errorlevel%


    goto EXIT


  :HELP

    @echo.
    @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
    @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
    @echo   under GPL 2.0 license terms and conditions.
    @echo.
    @echo   report [sub-command]
    @echo.

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\report.ini) do (
      @echo     # [ %%i ] - %%j
    )

    @echo.


  :EXIT

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul

    exit /b %user.ExitCode%

endlocal