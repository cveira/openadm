@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: install users
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
@rem   Creates OpenADM System Operations Framework users on the local system.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   list.exe        - win2k3 reskit
@rem   net.exe         - win2k3 server
@rem   wmic.exe        - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [install.users alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\install users <-id:{<group-label>|list|xlist}>
@rem                               <-mode:{exec|query}>
@rem                               <-scope:{local|ntdomain|addomain}>
@rem                               <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\install
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
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
@rem   install users -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.ConfDir>    : users.ini
@rem     - <fs.InstallDir> : users.<group-label>.ini
@rem     - <%CD%>          : users.<group-label>.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem     - <fs.ConfDir>    : domain.ini
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

    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_YES%"      set input.ValueIsOk=%STATUS_ON%
    if /i "%VALUE_ALERTMODE%" EQU "%STATUS_NO%"       set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% goto HELP
  ) else (
    set VALUE_MODE=%VALUE_MODE_NA%
    set VALUE_SCOPE=%VALUE_SCOPE_NA%
    set VALUE_ALERTMODE=%STATUS_NO%
  )


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\users-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=users-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\users.ini           set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\domain.ini          set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\users.ini
    @echo #   %fs.ConfDir%\domain.ini
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

    if exist %CD%\users.%VALUE_LABELID%.ini             set input.ValueIsOk=%STATUS_ON%
    if exist %fs.InstallDir%\users.%VALUE_LABELID%.ini  set input.ValueIsOk=%STATUS_ON%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   first file location:  "%CD%\users.%VALUE_LABELID%.ini"
      @echo #   second file location: "%fs.InstallDir%\users.%VALUE_LABELID%.ini"
      @echo #
      @echo # aborting program.
      @echo.

      %sys.ColorNormal%

      goto HELP
    )

    set fs.IniDir=%fs.InstallDir%
    set fs.IniFile="%fs.InstallDir%\users.%VALUE_LABELID%.ini"

    if exist "%CD%\users.%VALUE_LABELID%.ini" (
      set fs.IniDir=%CD%
      set fs.IniFile="%CD%\users.%VALUE_LABELID%.ini"
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

    set event.message="install users: [%VALUE_LABELID%] installing OpenADM System Operations Framework users. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "install:users [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

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

      for %%i in ("%CD%\users.*.ini") do (
        @echo   + %%i
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # current defined settings in [%fs.InstallDir%]:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\users.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in ("%CD%\users.*.ini") do (
        @echo   + %%i
      )

      for %%i in (%fs.InstallDir%\users.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list "%CD%\users.*.ini"
      %fs.BinDir%\list "%fs.InstallDir%\users.*.ini"


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


    @echo # current state of OpenADM System Operations Framework users:

    set query.LikeSymbol="%%"

    @echo.
    @echo + administrative human users:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
      wmic useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
    ) else (
      if /i "%COMPUTERNAME%" EQU "!ds.server!" (
        wmic useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      ) else (
        wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      )
    )

    %sys.ColorNormal%

    @echo.
    @echo + automated process users:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
      wmic useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
    ) else (
      if /i "%COMPUTERNAME%" EQU "!ds.server!" (
        wmic useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
      ) else (
        wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
      )
    )

    %sys.ColorNormal%

    @echo.
    @echo + service users:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
      wmic useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
    ) else (
      if /i "%COMPUTERNAME%" EQU "!ds.server!" (
        wmic useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
      ) else (
        wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
      )
    )

    %sys.ColorNormal%

    @echo.
    @echo # current state of regular users:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
      wmic useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
    ) else (
      if /i "%COMPUTERNAME%" EQU "!ds.server!" (
        wmic useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      ) else (
        wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      )
    )

    %sys.ColorNormal%


    if /i %VALUE_MODE% EQU %VALUE_MODE_EXEC% (
      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # creating users:
      @echo.


      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
        @echo   + connecting to domain [!ds.domain!] as user [!ds.domain!\!ds.user!]
        @echo.

        %sys.ColorDark%

        net use \\!ds.server!\c$ /u:!ds.domain!\!ds.user! !ds.passwd!

        if %errorlevel% NEQ %EL_NET_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo.

          %sys.ColorNormal%

          set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups.%VALUE_MODE% [%SET_SSNSEQ%]" /d !event.message!  >  nul
        )

        @echo.
        %sys.ColorNormal%
      )


      set user.DefaultPassword=
      set user.Password=

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\users.ini) do (
        if /i %%i EQU default set user.DefaultPassword=%%j
        if /i %%i EQU default set user.Password=%%j
      )


      for /f "eol=# tokens=1-6 delims=%FIELD_DELIMITER%" %%a in (!fs.IniDir!\users.%VALUE_LABELID%.ini) do (
        @echo   + user: %%a
        @echo.

        %sys.ColorDark%

        set user.Password=!user.DefaultPassword!
        set user.IsActive=%STATUS_NO%

        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\users.ini) do if /i {%%i} EQU {%%a} set user.Password=%%j

        if /i {%%f} EQU {%STATUS_YES%} (
          set user.IsActive=%STATUS_NO%
        ) else (
          set user.IsActive=%STATUS_YES%
        )

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%    net user %%a !user.Password! /add /fullname:"%%~a" /expires:never /passwordchg:%%e /passwordreq:yes /active:!user.IsActive! /y
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% net user %%a !user.Password! /add /fullname:"%%~a" /expires:never /passwordchg:%%e /passwordreq:yes /active:!user.IsActive! /y
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
          if /i %%b EQU adm %fs.BinDir%\dsadd user "CN=%%~a,!ds.AdmObjectsPath!"     -samid "%%~a" -desc "%%~a" -pwd !user.Password! -pwdneverexpires %%c -mustchpwd %%d -canchpwd %%e -disabled %%f -s !ds.server! -u !ds.user! -p !ds.passwd!
          if /i %%b EQU job %fs.BinDir%\dsadd user "CN=%%~a,!ds.JobObjectsPath!"     -samid "%%~a" -desc "%%~a" -pwd !user.Password! -pwdneverexpires %%c -mustchpwd %%d -canchpwd %%e -disabled %%f -s !ds.server! -u !ds.user! -p !ds.passwd!
          if /i %%b EQU svc %fs.BinDir%\dsadd user "CN=%%~a,!ds.ServiceObjectsPath!" -samid "%%~a" -desc "%%~a" -pwd !user.Password! -pwdneverexpires %%c -mustchpwd %%d -canchpwd %%e -disabled %%f -s !ds.server! -u !ds.user! -p !ds.passwd!
          if /i %%b EQU org %fs.BinDir%\dsadd user "CN=%%~a,!ds.OrgObjectsPath!"     -samid "%%~a" -desc "%%~a" -pwd !user.Password! -pwdneverexpires %%c -mustchpwd %%d -canchpwd %%e -disabled %%f -s !ds.server! -u !ds.user! -p !ds.passwd!
        )

        if %errorlevel% NEQ %EL_STATUS_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo #
          @echo #   user: %%a
          @echo.

          %sys.ColorNormal%

          set event.message="install users: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:users [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
        )

        @echo.
        %sys.ColorNormal%
      )


      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
        @echo   + removing connection to domain [!ds.domain!] as user [!ds.domain!\!ds.user!]
        @echo.

        %sys.ColorDark%

        net use \\!ds.server!\c$ /d /y

        if %errorlevel% NEQ %EL_NET_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          %sys.ColorRed%

          @echo.
          @echo # ERROR: unexpected operation error.
          @echo.

          %sys.ColorNormal%

          set event.message="install groups: [%VALUE_LABELID%] unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
          %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "install:groups.%VALUE_MODE% [%SET_SSNSEQ%]" /d !event.message!  >  nul
        )

        @echo.
        %sys.ColorNormal%
      )


      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # final state of OpenADM System Operations Framework users:
      @echo.

      set query.LikeSymbol="%%"

      @echo.
      @echo + administrative human users:
      @echo.

      %sys.ColorDark%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        wmic useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      ) else (
        if /i "%COMPUTERNAME%" EQU "!ds.server!" (
          wmic useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
        ) else (
          wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '¡%query.LikeSymbol:"=%' and not (name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
        )
      )

      %sys.ColorNormal%

      @echo.
      @echo + automated process users:
      @echo.

      %sys.ColorDark%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        wmic useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
      ) else (
        if /i "%COMPUTERNAME%" EQU "!ds.server!" (
          wmic useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
        ) else (
          wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%'" list brief
        )
      )

      %sys.ColorNormal%

      @echo.
      @echo + service users:
      @echo.

      %sys.ColorDark%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        wmic useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
      ) else (
        if /i "%COMPUTERNAME%" EQU "!ds.server!" (
          wmic useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
        ) else (
          wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%'" list brief
        )
      )

      %sys.ColorNormal%

      @echo.
      @echo # final state of regular users:
      @echo.

      %sys.ColorDark%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        wmic useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
      ) else (
        if /i "%COMPUTERNAME%" EQU "!ds.server!" (
          wmic useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
        ) else (
          wmic /node:"!ds.server!" /user:"!ds.user!" /password:"!ds.passwd!" /implevel:impersonate useraccount where "not (name like '¡%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%job%query.LikeSymbol:"=%' or name like '%query.LikeSymbol:"=%svc%query.LikeSymbol:"=%')" list brief
        )
      )

      %sys.ColorBright%

      @echo # SECURITY WARNING: don't forget to remove/protect [%fs.ConfDir%\users.ini] after the installation process.

      %sys.ColorNormal%
    )


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   install users [-id:{[group-label]^|list^|xlist}]
      @echo                 [-mode:{exec^|query}]
      @echo                 [-scope:{local^|ntdomain^|addomain}]
      @echo                 [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     install users -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="install users: [%VALUE_LABELID%] OpenADM System Operations Framework users installed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "install:users [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd install.users -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:no

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