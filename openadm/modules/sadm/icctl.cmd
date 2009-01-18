@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: icctl
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
@rem   Performs Intrussion Contention Control.
@rem
@rem Dependencies:
@rem   setacl.exe      - setacl.sf.net (v2.0.2)
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [icctl alert module]
@rem   *.cmd           - openadm [c:\openadm\modules\icctl]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm ic <-cmd:{install|set.admin|set.op|refresh.profiles|query}>
@rem                           <-mode:{exec|test}>
@rem                           <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:     <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.SysOpDir:       <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:        <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:         <fs.SystemDrive>\openadm\bin\system
@rem   fs.CmdbDir:        <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.ModulesDir:     <fs.SystemDrive>\openadm\modules\icctl
@rem   fs.LogsDir:        <fs.DataDrive>\logs\openadm\sadm
@rem   fs.TmpDir:         <fs.SystemDrive>\openadm\tmp
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-cmd:install]          - install security on the system side.
@rem   [-cmd:set.admin]        - takes the system into the AdminMode.
@rem   [-cmd:set.op]           - takes the system into the OperationalMode.
@rem   [-cmd:refresh.profiles] - updates OpenADM ACLs on recently created user profiles.
@rem   [-cmd:query]            - queries the actual mode of the system.
@rem   [-mode:exec]            - it sets execution mode: changes will be done on the system.
@rem   [-mode:test]            - it sets test mode: no changes will be done on the system.
@rem   [-a:{yes|no}]           - alert mode: it triggers a post-execution log analysis.
@rem
@rem Important notes:
@rem   It uses a text file located on:
@rem     - <fs.InstallDir> : icctl.<profile-id>.install.ini
@rem     - <fs.InstallDir> : icctl.<profile-id>.admstate.ini
@rem     - <fs.InstallDir> : icctl.<profile-id>.opstate.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem     - <fs.ConfDir>    : icctl.ini
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\sadm
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ModulesDir=%fs.SystemDrive%\openadm\modules\sadm
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
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


  set SET_CMD=%1
  set SET_OPMODE=%2
  set SET_ALERTMODE=%3
  set SET_LOGFILE=%4
  set SET_SSNSEQ=%5

  set VALUE_CMD=%SET_CMD:-cmd:=%
  set VALUE_OPMODE=%SET_OPMODE:-mode:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_CMD_INSTALL=install
  set VALUE_CMD_SETADMIN=set.admin
  set VALUE_CMD_SETOP=set.op
  set VALUE_CMD_REFRESHPROFILES=refresh.profiles
  set VALUE_CMD_QUERY=query
  set VALUE_OPMODE_EXEC=exec
  set VALUE_OPMODE_TEST=test

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_SETACL_OK=0
  set EL_SETACL_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%
  set ds.SettingsFile=%fs.ConfDir%\domain.ini


  if /i "%SET_CMD%"           EQU ""     goto HELP
  if /i %SET_CMD:~0,4%        NEQ -cmd   goto HELP
  if /i %SET_OPMODE:~0,5%     NEQ -mode  goto HELP
  if /i %SET_ALERTMODE:~0,2%  NEQ -a     goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_CMD% EQU %VALUE_CMD_INSTALL%          set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_CMD% EQU %VALUE_CMD_SETADMIN%         set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_CMD% EQU %VALUE_CMD_SETOP%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_CMD% EQU %VALUE_CMD_REFRESHPROFILES%  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_CMD% EQU %VALUE_CMD_QUERY%            set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_OPMODE% EQU %VALUE_OPMODE_EXEC%  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_OPMODE% EQU %VALUE_OPMODE_TEST%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES%      set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%       set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\icctl-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=icctl-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\icctl.ini           set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\icctl.ini
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
    if /i %%i EQU ic.begin          set event.BeginId=%%j
    if /i %%i EQU ic.end            set event.EndId=%%j
    if /i %%i EQU ic.begin.TestMode set event.TestModeBeginId=%%j
    if /i %%i EQU ic.end.TestMode   set event.TestModeEndId=%%j
    if /i %%i EQU ic.event          set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%ds.SettingsFile%) do (
      if /i %%i EQU domain       set ds.domain=%%j
      if /i %%i EQU server       set ds.server=%%j
      if /i %%i EQU user         set ds.user=%%j
      if /i %%i EQU password     set ds.passwd=%%j
    )


    for /f "eol=# tokens=*" %%i in (%fs.ConfDir%\icctl.ini) do set icctl.profile=%%i


    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.ModulesDir%\icctl\%icctl.profile%\opstate.ini           set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.ModulesDir%\icctl\%icctl.profile%\admstate.ini          set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.ModulesDir%\icctl\%icctl.profile%\install.ini           set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.ModulesDir%\icctl\%icctl.profile%\opstate.ini
      @echo #   %fs.ModulesDir%\icctl\%icctl.profile%\admstate.ini
      @echo #   %fs.ModulesDir%\icctl\%icctl.profile%\install.ini
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )

    set fs.ModulesDir.install=%fs.ModulesDir%\icctl\%icctl.profile%\install
    set fs.ModulesDir.admstate=%fs.ModulesDir%\icctl\%icctl.profile%\admstate
    set fs.ModulesDir.opstate=%fs.ModulesDir%\icctl\%icctl.profile%\opstate


    set sid.EveryOne=S-1-1-0
    set sid.AuthUsers=S-1-5-11
    set sid.DialupUsers=S-1-5-1
    set sid.NetworkUsers=S-1-5-2
    set sid.BatchUsers=S-1-5-3
    set sid.InteractiveUsers=S-1-5-4
    set sid.ServiceUsers=S-1-5-6
    set sid.AnonymousUsers=S-1-5-7
    set sid.CreatorOwner=S-1-3-0
    set sid.system=S-1-5-18
    set sid.service=S-1-5-19
    set sid.NetworkService=S-1-5-20
    set sid.administrators=S-1-5-32-544
    set sid.users=S-1-5-32-545
    set sid.PowerUsers=S-1-5-32-547
    set sid.AccountOperators=S-1-5-32-548
    set sid.ServerOperators=S-1-5-32-549
    set sid.PrinterOperators=S-1-5-32-550
    set sid.BackupOperators=S-1-5-32-551
    set sid.replicators=S-1-5-32-552

    set ACL_LOCAL_SYSTEM_PROFILE=-ace "n:%COMPUTERNAME%\¡res-fs-system;p:change" -ace "n:%COMPUTERNAME%\¡res-fs-system-da;p:read_ex;m:deny" -ace "n:%COMPUTERNAME%\¡res-fs-system-rx;p:read_ex" -ace "n:%COMPUTERNAME%\¡res-fs-system-lo;p:list_folder" -ace "n:%COMPUTERNAME%\¡res-fs-system-wo;p:write" -ace "n:%COMPUTERNAME%\¡res-fs-system-rwx;p:read_ex,write" -ace "n:%COMPUTERNAME%\¡role-adm-system;p:full"
    set ACL_LOCAL_AUDIT_SYSTEM=-ace "n:%sid.system%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.service%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.NetworkService%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.administrators%;s:y;p:full;m:aud_fail;w:sacl"
    set ACL_DOMAIN_SYSTEM_PROFILE=-ace "n:%ds.domain%\¡res-fs-system;p:change" -ace "n:%ds.domain%\¡res-fs-system-da;p:read_ex;m:deny" -ace "n:%ds.domain%\¡res-fs-system-rx;p:read_ex" -ace "n:%ds.domain%\¡res-fs-system-lo;p:list_folder" -ace "n:%ds.domain%\¡res-fs-system-wo;p:write" -ace "n:%ds.domain%\¡res-fs-system-rwx;p:read_ex,write" -ace "n:%ds.domain%\¡role-adm-system;p:full"
    set ACL_DOMAIN_AUDIT_SYSTEM=-ace "n:%sid.system%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.service%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.NetworkService%;s:y;p:full;m:aud_fail;w:sacl" -ace "n:%sid.administrators%;s:y;p:full;m:aud_fail;w:sacl"

    set user.CurrentDir="%CD%"


    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      set event.message="sadm:ic [%icctl.profile%]: requested command [%VALUE_CMD%]"
    ) else (
      set event.message="sadm:ic [%icctl.profile%]: [test-mode] requested command [%VALUE_CMD%]"
    )

    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      %fs.BinDir%\eventcreate /id %event.TestModeBeginId% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:       %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # profile id:        %icctl.profile%
    @echo # requested command: %VALUE_CMD%
    @echo # operational mode:  %VALUE_OPMODE%
    @echo # alert mode:        %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
    @echo.
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


    if /i %VALUE_CMD% EQU %VALUE_CMD_INSTALL% (
      for /f "eol=#" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\install.ini) do call %fs.ModulesDir.install%\%%i.cmd
    )

    if /i %VALUE_CMD% EQU %VALUE_CMD_SETADMIN% (
      if not exist %fs.TmpDir%\sysstate.AdminMode (
        for /f "eol=#" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\admstate.ini) do call %fs.ModulesDir.admstate%\%%i.cmd

        if exist %fs.TmpDir%\sysstate.OpMode del %fs.TmpDir%\sysstate.OpMode     >  nul

        @echo %* > %fs.TmpDir%\sysstate.AdminMode
      ) else (
        @echo.
        @echo # INFO: the system is already in Administration Mode.
        @echo.

        set event.message="sadm:ic [%icctl.profile%]: the system is already in Administration Mode. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    if /i %VALUE_CMD% EQU %VALUE_CMD_SETOP% (
      if not exist %fs.TmpDir%\sysstate.OpMode (
        for /f "eol=#" %%i in (%fs.ModulesDir%\icctl\%icctl.profile%\opstate.ini) do call %fs.ModulesDir.opstate%\%%i.cmd

        if exist %fs.TmpDir%\sysstate.OpMode del %fs.TmpDir%\sysstate.AdminMode  >  nul

        @echo %* > %fs.TmpDir%\sysstate.OpMode
      ) else (
        @echo.
        @echo # INFO: the system is already in Operational Mode.
        @echo.

        set event.message="sadm:ic [%icctl.profile%]: the system is already in Operational Mode. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
      )
    )

    if /i %VALUE_CMD% EQU %VALUE_CMD_REFRESHPROFILES% (
      for /f "eol=#" %%i in (%fs.ModulesDir%\icctl\refresh.profiles\install.ini) do call %fs.ModulesDir%\icctl\refresh.profiles\install\%%i.cmd
    )

    if exist %fs.TmpDir%\%SET_LOGFILE:.log=.exit% (
      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo.

      %sys.ColorNormal%

      set event.message="sadm:ic [%icctl.profile%]: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    if /i %VALUE_CMD% EQU %VALUE_CMD_QUERY% (
      for /f %%i in ('dir /s /b %fs.TmpDir%\sysstate.*') do (
        if /i %%~xi EQU AdminMode @echo # system state is: Administration Mode
        if /i %%~xi EQU OpMode    @echo # system state is: Operational Mode
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
      @echo   sadm ic [-cmd:{install^|set.admin^|set.op^|refresh.profiles^|query}]
      @echo           [-mode:{exec^|test}]
      @echo           [-a:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%


    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      set event.message="sadm:ic [%icctl.profile%]: executed command [%VALUE_CMD%]"
    ) else (
      set event.message="sadm:ic [%icctl.profile%]: [test-mode] executed command [%VALUE_CMD%]"
    )

    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      %fs.BinDir%\eventcreate /id %event.TestModeEndId% /l application /t information /so "sadm:ic.%VALUE_CMD% [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd icctl -l:%SET_LOGFILE% -trap:yes

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