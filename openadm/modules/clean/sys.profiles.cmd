@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: clean sys.profiles
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
@rem   Cleans dirty files from user profiles.
@rem
@rem Dependencies:
@rem   cprofile.exe    - win2k3 server
@rem   delprof.exe     - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   clean.cmd       - openadm [fs.selection module]
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [clean.sys.profiles alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\clean sys.profiles <-id:{<group-label>|list|xlist}>
@rem                                    <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\clean
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\clean
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label]  - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]         - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]        - shows contents of configuration files currently available for this operation.
@rem   [-a:{yes|no}]      - alert  mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   clean sys.profiles -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : sys.profiles.<group-label>.ini
@rem     - <fs.InstallDir> : sys.profiles.<group-label>.targets.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: default directory list sorting may affect how this piece of
@rem   code is working! Test before running on a production system.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\clean
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\clean

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
  set SET_ALERTMODE=%2
  set SET_LOGFILE=%3
  set SET_SSNSEQ=%4

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_CMD_OK=0
  set EL_CMD_ERROR=1
  set EL_CLEANFSDIR_OK=0
  set EL_CLEANFSDIR_ERROR=1
  set EL_DELPROF_OK=0
  set EL_DELPROF_ERROR=1
  set EL_CPROFILE_OK=0
  set EL_CPROFILE_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    if /i "%SET_LABELID%"         EQU ""     goto HELP
    if /i "%SET_LABELID:~0,3%"    NEQ "-id"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"   goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\sys.profiles-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=sys.profiles-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.BinDir%\cprofile.exe                 set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\delprof.exe                  set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\cprofile.exe
    @echo #   %fs.BinDir%\delprof.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\sys.profiles.%VALUE_LABELID%.ini           set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\sys.profiles.%VALUE_LABELID%.targets.ini   set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\sys.profiles.%VALUE_LABELID%.ini
      @echo #   %fs.InstallDir%\sys.profiles.%VALUE_LABELID%.targets.ini
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
      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\sys.profiles.%VALUE_LABELID%.ini) do (
        if /i "%%i" EQU "sys.TimeToWait"          set sys.TimeToWait=%%j
        if /i "%%i" EQU "policy.MaxAgeDays"       set policy.MaxAgeDays=%%j
        if /i "%%i" EQU "policy.main"             set policy.main=%%j
        if /i "%%i" EQU "policy.cache"            set policy.cache=%%j
        if /i "%%i" EQU "policy.SpecificTargets"  set policy.SpecificTargets=%%j
        if /i "%%i" EQU "policy.desktop"          set policy.desktop=%%j
        if /i "%%i" EQU "policy.desktop.allusers" set policy.desktop.allusers=%%j
        if /i "%%i" EQU "policy.outlook"          set policy.outlook=%%j
        if /i "%%i" EQU "policy.roam"             set policy.roam=%%j
        if /i "%%i" EQU "policy.old"              set policy.old=%%j
        if /i "%%i" EQU "policy.compact"          set policy.compact=%%j
      )

      set fs.ProfilesDir=
      for /f "delims=\ tokens=1,2,*" %%i in ("%UserProfile%") do set fs.ProfilesDir=%%i\%%j
      if not exist "!fs.ProfilesDir!" goto HELP
    )


    set event.message="clean sys.profiles: starting profile clean up. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:                        %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      %sys.ColorBright%
      @echo # profile store:                      "!fs.ProfilesDir!"
      @echo # time to wait:                       !sys.TimeToWait!
      @echo # ------------------------------------------------------------------------
      @echo # profile storage policies:
      @echo #   main clean-up policy:             !policy.main!
      @echo #   clean cache folders:              !policy.cache!
      @echo #   clean specific target folders:    !policy.SpecificTargets!
      @echo #   clean desktop folders:            !policy.desktop!
      @echo #   clean 'all users' desktop folder: !policy.desktop.allusers!
      @echo #   clean outlook xST files:          !policy.outlook!
      @echo #   clean roaming profiles:           !policy.roam!
      @echo #   clean old prolies:                !policy.old!
      @echo #   compacting profiles:              !policy.compact!
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
    )

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\sys.profiles.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\sys.profiles.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\sys.profiles.*.ini


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


    @echo.

    set user.CurrentDir="%CD%"

    if /i !policy.main! EQU %STATUS_YES% (
      @echo # main profile clean-up policy:
      @echo.

      %sys.ColorDark%

      cd /d "!fs.ProfilesDir!"  >  nul

      @echo   + %fs.SysOpDir%\clean.cmd fs.selection "!fs.ProfilesDir!" -id:profiles -mode:exec -w:!sys.TimeToWait!
      call %fs.SysOpDir%\clean.cmd fs.selection "!fs.ProfilesDir!" -id:profiles -mode:exec -w:!sys.TimeToWait!

      if %errorlevel% NEQ %EL_CLEANFSDIR_OK% (
        @echo %errorlevel% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo #
        @echo #   target resource: "!fs.ProfilesDir!"
        @echo #   resource label:  profiles
        @echo.

        %sys.ColorNormal%

        set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )

      %sys.ColorNormal%
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.cache! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # cache storage policy:
      @echo.

      %sys.ColorDark%

      cd /d "!fs.ProfilesDir!"  >  nul

      for /d /r . %%i in (*cache) do (
        if /i %%~ni EQU cache (
          @echo   + %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.cache -m:tree -a:yes
          call %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.cache -m:tree -a:yes

          if %errorlevel% NEQ %EL_CLEANFSDIR_OK% (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

            %sys.ColorRed%

            @echo.
            @echo # ERROR: unexpected operation error.
            @echo #
            @echo #   target resource: "%%i"
            @echo #   resource label:  profiles.cache
            @echo.

            %sys.ColorNormal%

            set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
            %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
          )
        )

        %fs.BinDir%\sleep !sys.TimeToWait!
      )

      %sys.ColorNormal%
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.SpecificTargets! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # specific targets storage policy:
      @echo.

      %sys.ColorDark%

      cd /d "!fs.ProfilesDir!"  >  nul

      for /f "eol=# tokens=1,*" %%i in (%fs.InstallDir%\sys.profiles.%VALUE_LABELID%.targets.ini) do (
        @echo   + %fs.SysOpDir%\clean.cmd folder "%%~j" -id:profiles.%%i -m:tree -a:yes
        call %fs.SysOpDir%\clean.cmd folder "%%~j" -id:profiles.%%i -m:tree -a:yes

        if %errorlevel% NEQ %EL_CLEANFSDIR_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   target resource: "%%~j"
          @echo #   resource label:  profiles.%%i
          @echo.

          %sys.ColorNormal%

          set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
        )

        %fs.BinDir%\sleep !sys.TimeToWait!
      )

      %sys.ColorNormal%
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.desktop! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # desktop storage policy:
      @echo.

      %sys.ColorDark%

      cd /d "!fs.ProfilesDir!"  >  nul

      if !policy.desktop.allusers! EQU %STATUS_YES% (
        for /d /r . %%i in (*desktop) do (
          @echo   + %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.desktop -m:tree -a:yes
          call %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.desktop -m:tree -a:yes

          if %errorlevel% NEQ %EL_CLEANFSDIR_OK% (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

            %sys.ColorRed%

            @echo.
            @echo # ERROR: unexpected operation error.
            @echo #
            @echo #   target resource: "%%i"
            @echo #   resource label:  profiles.desktop
            @echo.

            %sys.ColorNormal%

            set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
            %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
          )

          %fs.BinDir%\sleep !sys.TimeToWait!
        )
      ) else (
        for /d /r . %%i in (*desktop) do (
          if /i "%%~27,9i" NEQ "All Users" (
            @echo   + %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.desktop -m:tree -a:yes
            call %fs.SysOpDir%\clean.cmd folder "%%i" -id:profiles.desktop -m:tree -a:yes

            if %errorlevel% NEQ %EL_CLEANFSDIR_OK% (
              @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

              %sys.ColorRed%

              @echo.
              @echo # ERROR: unexpected operation error.
              @echo #
              @echo #   target resource: "%%i"
              @echo #   resource label:  profiles.desktop
              @echo.

              %sys.ColorNormal%

              set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
              %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
            )

            %fs.BinDir%\sleep !sys.TimeToWait!
          )
        )
      )

      %sys.ColorNormal%
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.outlook! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # outlook storage policy:
      @echo.

      %sys.ColorDark%

      cd /d "!fs.ProfilesDir!"  >  nul

      for /d /r . %%i in (*outlook) do (
        @echo   + %%i

        del /f /q "%%i\*.pst"

        if %errorlevel% NEQ %EL_CMD_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   target resource: "%%i\*.pst"
          @echo.

          %sys.ColorNormal%

          set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
        )

        del /f /q "%%i\*.ost"

        if %errorlevel% NEQ %EL_CMD_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   target resource: "%%i\*.ost"
          @echo.

          %sys.ColorNormal%

          set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
        )

        %fs.BinDir%\sleep !sys.TimeToWait!
      )

      %sys.ColorNormal%
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.roam! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # roaming profile storage policy:
      @echo.

      cd /d "!fs.ProfilesDir!"  >  nul

      %fs.BinDir%\delprof /q /i /r

      if %errorlevel% NEQ %EL_DELPROF_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo.

        %sys.ColorNormal%

        set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.old! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # old profiles storage policy:
      @echo.

      cd /d "!fs.ProfilesDir!"  >  nul

      %fs.BinDir%\delprof /q /i /d:%policy.MaxAgeDays%

      if %errorlevel% NEQ %EL_DELPROF_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo.

        %sys.ColorNormal%

        set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    %fs.BinDir%\sleep !sys.TimeToWait!

    if /i !policy.compact! EQU %STATUS_YES% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # compact profiles storage policy:
      @echo.

      cd /d "!fs.ProfilesDir!"  >  nul

      %fs.BinDir%\cprofile /l /v

      if %errorlevel% NEQ %EL_CPROFILE_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected operation error.
        @echo.

        %sys.ColorNormal%

        set event.message="clean sys.profiles: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    cd /d %user.CurrentDir%  >  nul

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   clean sys.profiles [-id:{[group-label]^|list^|xlist}]
      @echo                      [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     clean sys.profiles -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="clean sys.profiles: profile clean up finished. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "clean:sys.profiles [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd clean.sys.profiles -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes

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