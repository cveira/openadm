@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: install groups
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
@rem   Creates OpenADM System Operations Framework groups on the local system.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   net.exe         - win2k3 server
@rem   dsadd.exe       - win2k3 server
@rem   lg.exe          - http://www.joeware.net/freetools/ (v1.02.00)
@rem   wmic.exe        - win2k3 server
@rem   findstr.exe     - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [install.groups alert module]
@rem   rescreate.cmd   - openadm [adm action]
@rem   resload.cmd     - openadm [adm action]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\install groups <-id:{<group-label>|list|xlist}>
@rem                                <-mode:{exec|query}>
@rem                                <-scope:{local|ntdomain|addomain}>
@rem                                <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\install
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.AdmDir:     <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\install
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-mode:exec]      - perform install operations.
@rem   [-mode:query]     - perform status query operations.
@rem   [-scope:local]    - target objects and security belong to local system and security objects too.
@rem   [-scope:ntdomain] - target objects and security belong to local system but security objects belong to local NT4 domain.
@rem   [-scope:addomain] - target objects and security belong to local system but security objects belong to local AD domain.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   install groups -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.InstallDir> : groups.<group-label>.ini
@rem     - <fs.InstallDir> : groups.<group-label>.members.ini
@rem     - <%CD%>          : groups.<group-label>.ini
@rem     - <%CD%>          : groups.<group-label>.members.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem     - <fs.ConfDir>    : domain.ini
@rem     - <fs.TmpDir>     : groups-<group-label>-yymmdd-x.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\install
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.AdmDir=%fs.SystemDrive%\openadm\modules\sadm
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
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
  set SET_SCOPE=%3
  set SET_ALERTMODE=%4
  set SET_LOGFILE=%5
  set SET_SSNSEQ=%6

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_MODE=%SET_MODE:-mode:=%
  set VALUE_SCOPE=%SET_SCOPE:-scope:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist
  set VALUE_MODE_EXEC=exec
  set VALUE_MODE_QUERY=query
  set VALUE_MODE_NA=N/A
  set VALUE_SCOPE_LOCAL=local
  set VALUE_SCOPE_NTDOMAIN=ntdomain
  set VALUE_SCOPE_ADDOMAIN=addomain
  set VALUE_SCOPE_NA=N/A

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_NET_OK=0
  set EL_NET_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%
  set ds.SettingsFile=%fs.ConfDir%\domain.ini


  set context.SkipExec=%STATUS_OFF%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST%  set context.SkipExec=%STATUS_ON%
  if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% set context.SkipExec=%STATUS_ON%


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    if /i "%SET_LABELID%"         EQU ""        goto HELP
    if /i "%SET_LABELID:~0,3%"    NEQ "-id"     goto HELP
    if /i "%SET_MODE:~0,5%"       NEQ "-mode"   goto HELP
    if /i "%SET_SCOPE:~0,6%"      NEQ "-scope"  goto HELP
    if /i "%SET_ALERTMODE:~0,2%"  NEQ "-a"      goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_MODE%" EQU "%VALUE_MODE_EXEC%"      set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_MODE%" EQU "%VALUE_MODE_QUERY%"     set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_SCOPE%" EQU "%VALUE_SCOPE_LOCAL%"    set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_SCOPE%" EQU "%VALUE_SCOPE_NTDOMAIN%" set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_SCOPE%" EQU "%VALUE_SCOPE_ADDOMAIN%" set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP


    set input.ValueIsOk=%STATUS_OFF%

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"       set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"        set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set VALUE_MODE=%VALUE_MODE_NA%
    set VALUE_SCOPE=%VALUE_SCOPE_NA%
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\groups-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=groups-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


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
  if not exist %fs.AdmDir%\rescreate.cmd                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.AdmDir%\resload.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\dsadd.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\lg.exe                       set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\findstr.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\net.exe            set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\wbem\wmic.exe      set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.AdmDir%\rescreate.cmd
    @echo #   %fs.AdmDir%\resload.cmd
    @echo #   %fs.BinDir%\dsadd.exe
    @echo #   %fs.BinDir%\lg.exe
    @echo #   %fs.BinDir%\findstr.exe
    @echo #   %systemroot%\system32\net.exe
    @echo #   %systemroot%\system32\wbem\wmic.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_OFF%

    if exist "%CD%\groups.%VALUE_LABELID%.ini"                       set input.ValueIsOk=%STATUS_ON%
    if exist "%fs.InstallDir%\groups.%VALUE_LABELID%.ini"            set input.ValueIsOk=%STATUS_ON%

    if /i "!input.ValueIsOk!" EQU "%STATUS_OFF%" (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input file does not exist.
      @echo #
      @echo #   first file location:  "%CD%\groups.%VALUE_LABELID%.ini"
      @echo #   second file location: "%fs.InstallDir%\groups.%VALUE_LABELID%.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )


    set fs.IniDir=%fs.InstallDir%
    set fs.IniFile="%fs.InstallDir%\groups.%VALUE_LABELID%.ini"

    if exist "%CD%\groups.%VALUE_LABELID%.ini" (
      set fs.IniDir=%CD%
      set fs.IniFile="%CD%\groups.%VALUE_LABELID%.ini"
    )


    if not exist "!fs.IniDir!\groups.%VALUE_LABELID%.members.ini" (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input file does not exist.
      @echo #
      @echo #   file location:  "!fs.IniDir!\groups.%VALUE_LABELID%.members.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    ) else (
      set fs.MembersFile="!fs.IniDir!\groups.%VALUE_LABELID%.members.ini"
    )
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU install.begin set event.BeginId=%%j
    if /i %%i EQU install.end   set event.EndId=%%j
    if /i %%i EQU install.event set event.id=%%j
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    @echo.

    if /i %VALUE_SCOPE% NEQ %VALUE_SCOPE_LOCAL% (
      set ds.CurrentDomain=""

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%ds.SettingsFile%) do (
          if /i "%%i" EQU "domain"       set ds.domain=%%j
          if /i "%%i" EQU "server"       set ds.server=%%j
          if /i "%%i" EQU "user"         set ds.user=%%j
          if /i "%%i" EQU "password"     set ds.passwd=%%j
          if /i "%%i" EQU "ldap.ResPath" set ds.ResourceObjectsPath=%%j
          if /i "%%i" EQU "ldap.AdmPath" set ds.AdmObjectsPath=%%j
          if /i "%%i" EQU "ldap.OrgPath" set ds.OrgObjectsPath=%%j
          if /i "%%i" EQU "ldap.SvcPath" set ds.ServiceObjectsPath=%%j
          if /i "%%i" EQU "ldap.JobPath" set ds.JobObjectsPath=%%j
        )

        set ds.CurrentDomain=!ds.domain!\
      ) else (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%ds.SettingsFile%) do (
          if /i "%%i" EQU "domain"       set ds.domain=%%j
          if /i "%%i" EQU "server"       set ds.server=%%j
          if /i "%%i" EQU "user"         set ds.user=%%j
          if /i "%%i" EQU "password"     set ds.passwd=%%j
        )

        set ds.CurrentDomain=!ds.domain!\
      )
    )

    set event.message="install groups: [%VALUE_LABELID%] installing OpenADM System Operations Framework groups. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:  %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # group label:  %VALUE_LABELID%
    @echo # mode:         %VALUE_MODE%
    @echo # scope:        %VALUE_SCOPE%
    @echo # alert mode:   %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current defined settings in [%CD%]:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\groups.*.ini") do (
        @echo   + %%i
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # current defined settings in [%fs.InstallDir%]:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\groups.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\groups.*.ini") do (
        @echo   + %%i
      )

      for %%i in (%fs.InstallDir%\groups.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list "%CD%\groups.*.ini"
      %fs.BinDir%\list "%fs.InstallDir%\groups.*.ini"


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


    @echo # current state of target security groups:
    @echo.

    set user.SetDomainSession=%STATUS_OFF%
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% set user.SetDomainSession=%STATUS_ON%
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% set user.SetDomainSession=%STATUS_ON%

    if /i %user.SetDomainSession% EQU %STATUS_ON% (
      if /i "%COMPUTERNAME%" NEQ "%ds.server%" (
        @echo   + connecting to domain [!ds.domain!] as user [!ds.domain!\!ds.user!]
        @echo.

        net use \\%ds.server%\c$ /u:!ds.domain!\!ds.user! !ds.passwd! >  nul

        if %errorlevel% NEQ %EL_NET_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo.

          %sys.ColorNormal%

          set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul

          goto EXIT
        )
      )
    )


    for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\groups.%VALUE_LABELID%.ini) do (
      if /i %%i EQU raw (
        @echo   + groups labeled as: "%%~j"
        @echo.

        %sys.ColorDark%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
          %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
          %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"                                                      >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
        ) else (
          if /i "%COMPUTERNAME%" EQU "%ds.server%" (
            %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
            %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"                                                    >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
          ) else (
            %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
            %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"                                      >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
          )
        )

        %sys.ColorNormal%
      ) else (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
          @echo   + groups labeled as: %%a
          @echo.

          %sys.ColorDark%

          if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
            %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
            %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"                  >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
          ) else (
            if /i "%COMPUTERNAME%" EQU "%ds.server%" (
              %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
              %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"                >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
            ) else (
              %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
              %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"  >>  %fs.TmpDir%\%SET_LOGFILE:.log=.ini%
            )
          )

          %sys.ColorNormal%
        )
      )

      @echo.
    )


    @echo.
    @echo # current members of target security groups:
    @echo.

    for /f "eol=# tokens=*" %%j in (%fs.TmpDir%\%SET_LOGFILE:.log=.ini%) do (
      @echo   + members of: "%%~j"
      @echo.

      %sys.ColorDark%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        %fs.BinDir%\lg "%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
      ) else (
        if /i "%COMPUTERNAME%" EQU "%ds.server%" (
          %fs.BinDir%\lg "%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
        ) else (
          %fs.BinDir%\lg "\\%ds.server%\%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
        )
      )

      %sys.ColorNormal%
    )


    if /i %VALUE_MODE% EQU %VALUE_MODE_EXEC% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # creating target security groups:
      @echo.

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\groups.%VALUE_LABELID%.ini) do (
        if /i %%i EQU raw (
          @echo   + group definition: %%i-[%%~j]
          @echo.

          %sys.ColorDark%

          if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    net localgroup "%%~j" /comment:"%%~j" /add
          if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% net group      "%%~j" /comment:"%%~j" /add
          if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% %fs.BinDir%\dsadd group "CN=%%~j,!ds.ResourceObjectsPath!" -samid "%%~j" -desc "%%~j" -secgrp yes -scope l -s %ds.server% -u !ds.user! -p !ds.passwd!

          if !errorlevel! NEQ %EL_STATUS_OK% (
            @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

            %sys.ColorRed%

            @echo.
            @echo # ERROR: unexpected operation error.
            @echo #
            @echo #   group type:  %%i
            @echo #   group name:  "%%~j"
            @echo.

            %sys.ColorNormal%

            set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
            %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
          )

          @echo.
          %sys.ColorNormal%
        ) else (
          for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
            @echo   + group definition: %%i-%%a-%%b
            @echo.

            if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    call %fs.AdmDir%\rescreate.cmd %%a -p:none -type:%%i -acl:%%b -scope:lgroups-only  -mode:exec -a:no
            if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% call %fs.AdmDir%\rescreate.cmd %%a -p:none -type:%%i -acl:%%b -scope:ntgroups-only -mode:exec -a:no
            if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% call %fs.AdmDir%\rescreate.cmd %%a -p:none -type:%%i -acl:%%b -scope:adgroups-only -mode:exec -a:no

            if !errorlevel! NEQ %EL_STATUS_OK%             @echo !errorlevel! >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

            @echo.
          )
        )
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # loading target security groups:
      @echo.

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\groups.%VALUE_LABELID%.members.ini) do (
        if /i %%i EQU raw (
          for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
            @echo   + group definition: %%i-[%%~a]
            @echo.

            call :LoadRawGroup "%%~i" "%%~a" "%%b"
          )
        ) else (
          if /i %%i EQU remove (
            for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
              @echo   + group definition: %%i-[%%~a]
              @echo.

              call :UnloadGroup "%%~i" "%%~a" "%%b"
            )
          ) else (
            for /f "eol=# tokens=1,2,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
              @echo   + group definition: %%i-%%a-%%b
              @echo.

              if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    call %fs.AdmDir%\resload.cmd "l:%%c" %%a -type:%%i -role:%%b -scope:local    -mode:exec -a:no
              if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% call %fs.AdmDir%\resload.cmd "l:%%c" %%a -type:%%i -role:%%b -scope:ntdomain -mode:exec -a:no
              if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% call %fs.AdmDir%\resload.cmd "l:%%c" %%a -type:%%i -role:%%b -scope:addomain -mode:exec -a:no

              if !errorlevel! NEQ %EL_STATUS_OK%             @echo !errorlevel! >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

              @echo.
            )
          )
        )
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # final state of target security groups:
      @echo.

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (!fs.IniDir!\groups.%VALUE_LABELID%.ini) do (
        if /i %%i EQU raw (
          @echo   + groups labeled as: "%%~j"
          @echo.

          %sys.ColorDark%

          if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
            %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
          ) else (
            if /i "%COMPUTERNAME%" EQU "%ds.server%" (
              %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
            ) else (
              %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i /c:"%%~j"
            )
          )

          %sys.ColorNormal%
        ) else (
          for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%a in ("%%j") do (
            @echo   + groups labeled as: %%a
            @echo.

            %sys.ColorDark%

            if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
              %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
            ) else (
              if /i "%COMPUTERNAME%" EQU "%ds.server%" (
                %fs.BinDir%\lg . 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
              ) else (
                %fs.BinDir%\lg \\%ds.server%\. 2>nul | %fs.BinDir%\findstr /i %%a | %fs.BinDir%\findstr /i /v /c:"listed"
              )
            )

            %sys.ColorNormal%
          )
        )

        @echo.
      )


      @echo.
      @echo # final members of target security groups:
      @echo.

      for /f "eol=# tokens=*" %%j in (%fs.TmpDir%\%SET_LOGFILE:.log=.ini%) do (
        @echo   + members of: "%%~j"
        @echo.

        %sys.ColorDark%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
          %fs.BinDir%\lg "%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
        ) else (
          if /i "%COMPUTERNAME%" EQU "%ds.server%" (
            %fs.BinDir%\lg "%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
          ) else (
            %fs.BinDir%\lg "\\%ds.server%\%%~j" 2>nul | %fs.BinDir%\findstr /i /v /c:"listed"
          )
        )

        %sys.ColorNormal%
      )

      del /q /f %fs.TmpDir%\%SET_LOGFILE:.log=.ini%  >  nul

      @echo.
      %sys.ColorBright%
      @echo # SECURITY WARNING: don't forget to remove [groups.[group-label].ini] files from the system after installation process.
      %sys.ColorNormal%
    )


    if /i %user.SetDomainSession% EQU %STATUS_ON% (
      if /i "%COMPUTERNAME%" NEQ "%ds.server%" (
        @echo   + removing connection to domain [!ds.domain!] as user [!ds.domain!\!ds.user!]
        @echo.

        net use \\%ds.server%\c$ /d /y  >  nul

        if %errorlevel% NEQ %EL_NET_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo.

          %sys.ColorNormal%

          set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
        )
      )
    )

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   install groups [-id:{[group-label]^|list^|xlist}]
      @echo                  [-mode:{exec^|query}]
      @echo                  [-scope:{local^|ntdomain^|addomain}]
      @echo                  [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     install groups -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="install groups: [%VALUE_LABELID%] OpenADM System Operations Framework groups installed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd install.groups -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:no

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

goto :ExitInstallGroups



:LoadRawGroup

  for /f "eol=# tokens=1,* delims=%LIST_DELIMITER%" %%c in ("%~3") do (
    @echo     + member name: %%c
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    net localgroup "%~2" %%c /add
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% net group      "%~2" %%c /add
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% %fs.BinDir%\lg "\\%ds.server%\%~2" %%c -add

    if !errorlevel! NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   group type:  %~1
      @echo #   group name:  %~2
      @echo #   member name: %%c
      @echo.

      %sys.ColorNormal%

      set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    @echo.
    %sys.ColorNormal%

    if /i "%%d" NEQ "" call :LoadRawGroup "%~1" "%~2" "%%d"
    goto :EOF
  )



:UnloadGroup

  for /f "eol=# tokens=1,* delims=%LIST_DELIMITER%" %%c in ("%~3") do (
    @echo     + member name: %%c
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    net localgroup "%~2" %%c /delete
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% net group      "%~2" %%c /delete
    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% %fs.BinDir%\lg "\\%ds.server%\%~2" %%c -remove

    if !errorlevel! NEQ %EL_STATUS_OK% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo #
      @echo #   group type:  %~1
      @echo #   group name:  %~2
      @echo #   member name: %%c
      @echo.

      %sys.ColorNormal%

      set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )

    @echo.
    %sys.ColorNormal%

    if /i "%%d" NEQ "" call :UnloadGroup "%~1" "%~2" "%%d"
    goto :EOF
  )



:ExitInstallGroups