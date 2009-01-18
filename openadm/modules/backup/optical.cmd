@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: backup optical
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
@rem   Back up files to Optical Media and performs operations to keep the log
@rem   files in a safe place and mood.
@rem
@rem Dependencies:
@rem   blat.exe        - www.blat.net (v2.5.0)
@rem   mkisofs.exe     - cygwin cdrtools (v2.01.01a04)
@rem   isovfy.exe      - cygwin cdrtools (v2.01.01a04)
@rem   readcd.exe      - cygwin cdrtools (v2.01.01a04)
@rem   cygwin1.dll     - cygwin (v1.5.18-1)
@rem   cdburn.exe      - win2k3 reskit
@rem   dvdburn.exe     - win2k3 reskit
@rem   sleep.exe       - win2k3 reskit
@rem   list.exe        - win2k3 reskit
@rem   net.exe         - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [backup.disk alert module]
@rem   archive.cmd     - openadm [fs.dir module]
@rem   clean.cmd       - openadm [fs.dir module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\backup optical {none|<source-dir>}
@rem                                <-id:{<group-label>|list|xlist}>
@rem                                <-mode:{raw|archive}>
@rem                                <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:     <fs.SystemDrive>\openadm\modules\backup
@rem   fs.SysOpDir:       <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:         <fs.SystemDrive>\openadm\bin\system
@rem   fs.ConfDir:        <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:         <fs.SystemDrive>\openadm\tmp
@rem   fs.LogsDir:        <fs.DataDrive>\logs\openadm\backup
@rem
@rem   fs.DestinationDir: [defined in optical.<group-label>.ini]
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <none>            - target object ignored. Used with -id:{list|xlist}.
@rem   <source-dir>      - selects source directory.
@rem   [-id:group-label] - label name which identifies the operation among other ones of the same type.
@rem   [-id:list]        - enumerates configuration files currently available for this operation.
@rem   [-id:xlist]       - shows contents of configuration files currently available for this operation.
@rem   [-mode:raw]       - raw mode: it takes actual files in target directory directly into the ISO file.
@rem   [-mode:archive]   - archive mode: it packs actual files into a ZIP file in target directory before taking them into the ISO file.
@rem   [-a:{yes|no}]     - alert mode: it triggers a post-scan log analysis.
@rem
@rem Restricted/Shortcut parameter combination matrix:
@rem   backup optical none -id:{list|xlist}
@rem
@rem Important notes:
@rem   It uses a text file located on:
@rem     - <fs.InstallDir> : optical.<group-label>.ini
@rem     - <fs.InstallDir> : optical.<group-label>.mkisofs.settings.ini
@rem     - <fs.ConfDir>    : customer.id.ini
@rem     - <fs.ConfDir>    : sys.alerts.ini
@rem     - <fs.ConfDir>    : el.iddb.ini
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\backup
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\backup

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

  set VALUE_SOURCE_NONE=none
  set VALUE_LABELID_LIST=list
  set VALUE_LABELID_XLIST=xlist
  set VALUE_OPERATIONMODE_RAW=raw
  set VALUE_OPERATIONMODE_ARCHIVE=archive
  set VALUE_OPERATIONMODE_NA=N/A

  set VALUE_INI_DISKTYPE_CD=cd
  set VALUE_INI_DISKTYPE_DVD=dvd

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_ARCHIVEFSDIR_OK=0
  set EL_ARCHIVEFSDIR_ERROR=1
  set EL_MKISOFS_OK=0
  set EL_MKISOFS_ERROR=1
  set EL_ISOVFY_OK=0
  set EL_ISOVFY_ERROR=1
  set EL_CDBURN_OK=0
  set EL_CDBURN_ERROR=1
  set EL_DVDBURN_OK=0
  set EL_DVDBURN_ERROR=1

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


    set fs.SourceDir=%SET_SOURCE:"=%
    if /i "%fs.SourceDir:~-1%" EQU "\" set fs.SourceDir=%fs.SourceDir:~0,-1%
    if not exist "!fs.SourceDir!" goto HELP


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
  for %%i in (%fs.LogsDir%\backup.optical-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=backup.optical-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\customer.id.ini     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\sys.alerts.ini      set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\customer.id.ini
    @echo #   %fs.ConfDir%\sys.alerts.ini
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
  if not exist %fs.SysOpDir%\archive.cmd                set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\clean.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\blat.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\mkisofs.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\isovfy.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\readcd.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\cygwin1.dll                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\cdburn.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\dvdburn.exe                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sleep.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\net.exe            set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.SysOpDir%\archive.cmd
    @echo #   %fs.SysOpDir%\clean.cmd
    @echo #   %fs.BinDir%\blat.exe
    @echo #   %fs.BinDir%\mkisofs.exe
    @echo #   %fs.BinDir%\isovfy.exe
    @echo #   %fs.BinDir%\readcd.exe
    @echo #   %fs.BinDir%\cygwin1.dll
    @echo #   %fs.BinDir%\cdburn.exe
    @echo #   %fs.BinDir%\dvdburn.exe
    @echo #   %fs.BinDir%\sleep.exe
    @echo #   %systemroot%\system32\wbem\net.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  if /i %context.SkipExec% EQU %STATUS_OFF% (
    set input.ValueIsOk=%STATUS_ON%

    if not exist %fs.InstallDir%\optical.%VALUE_LABELID%.ini                   set input.ValueIsOk=%STATUS_OFF%
    if not exist %fs.InstallDir%\optical.%VALUE_LABELID%.mkisofs.settings.ini  set input.ValueIsOk=%STATUS_OFF%

    if /i !input.ValueIsOk! EQU %STATUS_OFF% (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: input INI file does not exist.
      @echo #
      @echo #   %fs.InstallDir%\optical.%VALUE_LABELID%.ini
      @echo #   %fs.InstallDir%\optical.%VALUE_LABELID%.mkisofs.settings.ini
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
      for /f %%i in (%fs.ConfDir%\customer.id.ini) do set customer.id=%%i

      set mail.ServerUser=
      set mail.ServerPassword=

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\sys.alerts.ini) do (
        if /i "%%i" EQU "mail.ProfileIsActive"    set mail.ProfileIsActive=%%j
        if /i "%%i" EQU "mail.ProfileName"        set mail.ProfileName=%%j
        if /i "%%i" EQU "mail.log"                set mail.log=%%j
        if /i "%%i" EQU "mail.server"             set mail.server=%%j
        if /i "%%i" EQU "mail.ServerPort"         set mail.ServerPort=%%j
        if /i "%%i" EQU "mail.ServerUser"         set mail.ServerUser=%%j
        if /i "%%i" EQU "mail.ServerPassword"     set mail.ServerPassword=%%j
        if /i "%%i" EQU "mail.SourceDomain"       set mail.SourceDomain=%%j
        if /i "%%i" EQU "mail.DestinationDomain"  set mail.DestinationDomain=%%j
        if /i "%%i" EQU "mail.DestinationMailBox" set mail.DestinationMailBox=%%j
      )

      set mail.from=%COMPUTERNAME%.!customer.id!@!mail.SourceDomain!
      set mail.to=!mail.DestinationMailBox!@!mail.DestinationDomain!
      set mail.subject=

      for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.InstallDir%\optical.%VALUE_LABELID%.ini) do (
        if /i "%%i" EQU fs.DestinationDir    set fs.DestinationDir=%%~j

        if /i "%%i" EQU "device.type"          set sys.device.type=%%j
        if /i "%%i" EQU "device.drive"         set sys.device.drive=%%j
        if /i "%%i" EQU "device.id"            set sys.device.id=%%j
        if /i "%%i" EQU "device.MaxSize"       set sys.device.MaxSize=%%j
        if /i "%%i" EQU "device.MinRetries"    set sys.device.MinRetries=%%j
        if /i "%%i" EQU "device.MaxRetries"    set sys.device.MaxRetries=%%j

        if /i "%%i" EQU "sys.SleepTime"        set sys.SleepTime=%%j
        if /i "%%i" EQU "sys.AlertByMail"      set sys.AlertByMail=%%j
        if /i "%%i" EQU "sys.AlertByNetSend"   set sys.AlertByNetSend=%%j
        if /i "%%i" EQU "sys.AlertServerName"  set sys.AlertServerName=%%j
      )

      set fs.DestinationDir=!fs.DestinationDir:"=!
      if /i "!fs.DestinationDir:~-1!" EQU "\" set fs.DestinationDir=!fs.DestinationDir:~0,-1!
      if not exist "!fs.DestinationDir!" goto HELP

      set fs.DestinationDir.cygwin=!fs.DestinationDir:\=/!

      set mkisofs.SessionParameters=
      for /f "eol=# tokens=*" %%i in (%fs.InstallDir%\optical.%VALUE_LABELID%.mkisofs.settings.ini) do (
        set mkisofs.SessionParameters=!mkisofs.SessionParameters! %%i
      )

      set session.label=backup.optical-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%
    )


    set event.message="backup optical: [%VALUE_LABELID%] starting backup. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:      %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%

    if /i %context.SkipExec% EQU %STATUS_OFF% (
      %sys.ColorBright%
      @echo # source:           "!fs.SourceDir!"
      @echo # destination file: "!fs.DestinationDir!"
      @echo # group label:      %VALUE_LABELID%
      @echo # operation mode:   %VALUE_OPERATIONMODE%
      @echo # alert mode:       %VALUE_ALERTMODE%
      @echo # debug mode:       %VALUE_DEBUGMODE%
      @echo # ------------------------------------------------------------------------
      @echo # session label:    !session.label!
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
    )

    if /i %VALUE_LABELID% EQU %VALUE_LABELID_LIST% (
      @echo # current available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\optical.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%

      goto EXIT
    )


    if /i %VALUE_LABELID% EQU %VALUE_LABELID_XLIST% (
      @echo # showing contents of available configuration files:
      @echo.

      %sys.ColorDark%

      for %%i in (%fs.InstallDir%\optical.*.ini) do (
        @echo   + %%i
      )

      %sys.ColorNormal%


      %fs.BinDir%\list %fs.InstallDir%\optical.*.ini


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


    @echo # current status of source directory: "!fs.SourceDir!"
    @echo.

    set user.CurrentDir="%CD%"
    cd /d "!fs.SourceDir!"       >  nul

    %sys.ColorDark%

    dir  *.* /a /o:gen /q /l /c /4

    %sys.ColorNormal%

    cd /d %user.CurrentDir%  >  nul

    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # creating temporal structures on !fs.DestinationDir!
    @echo.

    set fs.TmpDir.archives=!fs.DestinationDir!\tmp\!session.label!\archives
    set fs.TmpDir.images=!fs.DestinationDir!\tmp\!session.label!\images
    set fs.TmpDir.images.cygwin=%fs.TmpDir.images:\=/%

    if not exist "%fs.TmpDir.archives%" (
      md "%fs.TmpDir.archives%"  >  nul
      @echo   + "%fs.TmpDir.archives%"
    )

    if not exist "%fs.TmpDir.images%" (
      md "%fs.TmpDir.images%"    >  nul
      @echo   + "%fs.TmpDir.images%"
    )


    set fs.files.packages.total=0
    if /i %VALUE_OPERATIONMODE% EQU %VALUE_OPERATIONMODE_ARCHIVE% (
      @echo.
      %sys.ColorBright%
      @echo ////////////////////////////////////////////////////////////////////////
      %sys.ColorNormal%
      @echo # building file archives on !fs.DestinationDir!:
      @echo.

      %sys.ColorDark%

      call %fs.SysOpDir%\archive.cmd fs.dir "!fs.SourceDir!" "%fs.TmpDir.archives%" -id:backup.optical.%VALUE_LABELID% -mode:tree -vol:!sys.device.MaxSize! -a:yes

      if not %errorlevel% EQU %EL_ARCHIVEFSDIR_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: unexpected error building archives.
        @echo #
        @echo #   source:      "!fs.SourceDir!"
        @echo #   destination: "%fs.TmpDir.archives%"
        @echo #   volume size: !sys.device.MaxSize!
        @echo.

        %sys.ColorNormal%

        set event.message="backup optical: [%VALUE_LABELID%] unexpeted error building archives. [%fs.LogFile%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

        %sys.ColorNormal%

        goto EXIT
      ) else (
        for %%i in ("%fs.TmpDir.archives%\backup.optical.%VALUE_LABELID%*.*") do (
          set /a fs.files.packages.total+=1
        )
      )

      %sys.ColorNormal%
    )

    @echo.
    %sys.ColorBright%
    @echo ////////////////////////////////////////////////////////////////////////
    %sys.ColorNormal%
    @echo # building ISO images on !fs.DestinationDir!:
    @echo.

    %sys.ColorDark%

    set fs.files.images.count=0
    if /i %VALUE_OPERATIONMODE% EQU %VALUE_OPERATIONMODE_ARCHIVE% (
      for %%i in ("%fs.TmpDir.archives%\backup.optical.%VALUE_LABELID%*.*") do (
        set fs.files.CurrentFile="%%~i"
        set fs.files.CurrentFile.cygwin=!fs.files.CurrentFile:\=/!

        @echo   + !fs.files.CurrentFile!
        @echo.

        %fs.BinDir%\mkisofs !mkisofs.SessionParameters! -o "%fs.TmpDir.images.cygwin%/backup.optical-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%-disk!fs.files.images.count!.iso" !fs.files.CurrentFile.cygwin!

        if not %errorlevel% EQU %EL_MKISOFS_OK% (
          @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

          call :MSG_ERR_ISOBUILD !fs.files.images.count!

          %sys.ColorNormal%

          goto EXIT
        ) else (
          call :MSG_OK_ISOBUILD  !fs.files.images.count!

          del /q /f %%i  >  nul
        )

        set /a fs.files.images.count+=1
      )
    ) else (
      set fs.SourceDir=%fs.SourceDir:"=%
      set fs.SourceDir.cygwin=%fs.SourceDir:\=/%

      @echo   + %fs.SourceDir.cygwin%
      @echo.

      %fs.BinDir%\mkisofs !mkisofs.SessionParameters! -o "%fs.TmpDir.images.cygwin%/backup.optical-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.iso" "%fs.SourceDir.cygwin%/*"

      if not %errorlevel% EQU %EL_MKISOFS_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        call :MSG_ERR_ISOBUILD %fs.files.images.count%

        %sys.ColorNormal%

        goto EXIT
      ) else (
        call :MSG_OK_ISOBUILD  %fs.files.images.count%
      )
    )

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo ////////////////////////////////////////////////////////////////////////
    %sys.ColorNormal%
    @echo # verifying ISO images on !fs.DestinationDir!:
    @echo.

    %sys.ColorDark%

    set fs.files.images.count=0
    for %%i in ("%fs.TmpDir.images%\backup.optical.%VALUE_LABELID%*.*") do (
      set fs.files.CurrentFile="%%~i"

      @echo   + !fs.files.CurrentFile!
      @echo.

      %fs.BinDir%\isovfy -i !fs.files.CurrentFile!

      if not %errorlevel% EQU %EL_ISOVFY_OK% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        call :MSG_ERR_ISOTEST !fs.files.images.count!

        %sys.ColorNormal%

        goto EXIT
      ) else (
        call :MSG_OK_ISOTEST  !fs.files.images.count!
      )

      set /a fs.files.images.count+=1
    )

    %sys.ColorNormal%


    @echo.
    %sys.ColorBright%
    @echo ////////////////////////////////////////////////////////////////////////
    %sys.ColorNormal%
    @echo # burning ISO images on !fs.DestinationDir!:
    @echo.

    %sys.ColorDark%

    set fs.files.images.count=0
    for %%i in ("%fs.TmpDir.images%\backup.optical.%VALUE_LABELID%*.*") do (
      call :TEST_DRIVE_READY

      @echo   + "%%~i"
      @echo.

      set EL_EXITCODE_OK=%EL_STATUS_OK%
      set EL_EXITCODE_ERROR=%EL_STATUS_ERROR%

      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_CD%  set EL_EXITCODE_OK=%EL_CDBURN_OK%
      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_DVD% set EL_EXITCODE_OK=%EL_DVDBURN_OK%
      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_CD%  set EL_EXITCODE_ERROR=%EL_CDBURN_ERROR%
      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_DVD% set EL_EXITCODE_ERROR=%EL_DVDBURN_ERROR%

      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_CD%  %fs.BinDir%\cdburn  !sys.device.drive! "%%~i"
      if /i !sys.device.type! EQU %VALUE_INI_DISKTYPE_DVD% %fs.BinDir%\dvdburn !sys.device.drive! "%%~i"

      if not %errorlevel% EQU %EL_EXITCODE_OK% (
        set user.ExitCode=%EL_EXITCODE_ERROR%

        call :MSG_ERR_ISOBURN !fs.files.images.count!

        %sys.ColorNormal%

        goto EXIT
      ) else (
        call :MSG_OK_ISOBURN  !fs.files.images.count!

        del /q /f "%%~i"  >  nul
      )

      set /a fs.files.images.count+=1
    )

    %sys.ColorNormal%


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   backup optical [{none^|[source-dir]}]
      @echo                  [-id:{[group-label]^|list^|xlist}]
      @echo                  [-mode:{raw^|archive}]
      @echo                  [-a:{yes^|no}]
      @echo.
      @echo   ----------------------------------------------------------------
      @echo.
      @echo   Restricted/Shortcut parameter combination matrix:
      @echo.
      @echo     backup optical none -id:{list^|xlist}
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      %sys.ColorNormal%
      @echo # clearing temporal structures on !fs.DestinationDir!
      @echo.

      %fs.SysOpDir%\clean.cmd fs.dir !fs.DestinationDir! -id:backup.optical.%VALUE_LABELID% -mode:tree -a:yes

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="backup optical: [%VALUE_LABELID%] backup finished. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd backup.optical -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes

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


:TEST_DRIVE_READY

  setlocal enabledelayedexpansion
    set fs.TmpDir.cygwin=%fs.TmpDir:\=/%
    set local.SleepTime=!sys.SleepTime!
    set sys.device.RetryCount=0


    :TEST_RETRY
      %fs.BinDir%\readcd dev=!sys.device.id! f=%fs.TmpDir.cygwin%/readcd.out sectors=1
      @echo.

      if %errorlevel% NEQ %EL_STATUS_OK% (
        set /a sys.device.RetryCount+=1

        if /i !sys.device.RetryCount! GEQ !sys.device.MaxRetries! (
          call :MSG_ERR_TIMEOUT !sys.device.RetryCount! !local.SleepTime!
          del /q /f %fs.TmpDir%\readcd.out  >  nul

          %sys.ColorNormal%

          goto EXIT
        )

        if /i !sys.device.RetryCount! GTR !sys.device.MinRetries! (
          if /i !sys.device.RetryCount! LSS !sys.device.MaxRetries! set /a local.SleepTime+=!local.SleepTime!
        )

        call :MSG_ERR_DRIVENOTREADY !sys.device.RetryCount! !local.SleepTime!

        %fs.BinDir%\sleep !local.SleepTime!

        goto TEST_RETRY
      )

      del /q /f %fs.TmpDir%\readcd.out  >  nul
  endlocal

  goto :EOF


:MSG_ERR_DRIVENOTREADY

  setlocal
    set SET_RETRY_COUNT=%1
    set SET_SLEEPTIME=%2

    @echo.
    @echo # WARNING: optical drive is not ready.
    @echo #
    @echo #   retry count: %SET_RETRY_COUNT%
    @echo #   sleep time:  %SET_SLEEPTIME%
    @echo.

    set event.message="backup optical: [%VALUE_LABELID%] optical drive is not ready. [#%SET_RETRY_COUNT%: %SET_SLEEPTIME% seconds]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    call :SEND_NOTIFICATION %event.message%
  endlocal

  goto :EOF


:MSG_ERR_TIMEOUT

  setlocal
    set SET_RETRY_COUNT=%1
    set SET_SLEEPTIME=%2

    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: optical drive is not ready. RetryCount exceeded MaxRetries.
    @echo #
    @echo #   retry count: %SET_RETRY_COUNT%
    @echo #   sleep time:  %SET_SLEEPTIME%
    @echo.

    %sys.ColorNormal%

    set event.message="backup optical: [%VALUE_LABELID%] RetryCount exceeded MaxRetries. [#%SET_RETRY_COUNT%: %SET_SLEEPTIME% seconds]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    call :SEND_NOTIFICATION %event.message%
  endlocal

  goto :EOF


:SEND_NOTIFICATION

  setlocal
    set SET_NOTIFICATION=%1
    set VALUE_NOTIFICATION=%SET_NOTIFICATION:"=%

    if /i !sys.AlertByNetSend! EQU %STATUS_YES% net send !sys.AlertServerName! %VALUE_NOTIFICATION%

    if /i !sys.AlertByMail! EQU %STATUS.YES% (
      set mail.subject=%VALUE_NOTIFICATION%

      if !mail.ProfileIsActive! EQU %STATUS.YES% (
        %fs.BinDir%\blat - -body %VALUE_NOTIFICATION% -p !mail.ProfileName! -to !mail.to! -s !mail.subject! -attacht %sysinfo% -log %fs.LogsDir%\!mail.log! -timestamp -priority 1 -noh2
      ) else (
        if "!mail.ServerUser!" EQU "" (
          %fs.BinDir%\blat - -body %VALUE_NOTIFICATION% -to !mail.to! -f !mail.from! -s !mail.subject! -attacht %sysinfo% -server !mail.server! -port !mail.ServerPort! -log %fs.LogsDir%\!mail.log! -timestamp -priority 1 -noh2
        ) else (
          %fs.BinDir%\blat - -body %VALUE_NOTIFICATION% -to !mail.to! -f !mail.from! -s !mail.subject! -attacht %sysinfo% -server !mail.server! -port !mail.ServerPort! -log %fs.LogsDir%\!mail.log! -timestamp -priority 1 -noh2 -u !mail.ServerUser! -pw !mail.ServerPassword!
        )
      )
    )

    call :NOTIFICATION_ISOK %errorlevel% "%VALUE_NOTIFICATION%"
  endlocal

  goto :EOF


:NOTIFICATION_ISOK

  setlocal
    set SET_ERRORCODE=%1
    set SET_NOTIFICATION=%2

    set VALUE_NOTIFICATION=%SET_NOTIFICATION:"=%

    if %SET_ERRORCODE% EQU %EL_STATUS_OK% (
      @echo.
      @echo # notification has been sended:
      @echo #
      @echo #   sender:        !mail.from!
      @echo #   recipient:     !mail.to!
      @echo #   subject:       !mail.subject!
      @echo #   body:          %VALUE_NOTIFICATION%
      @echo #   attached file: %sysinfo%
      @echo.

      set event.message="backup optical: notification has been sended. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t warning /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: unable to send mail notification:
      @echo #
      @echo #   sender:        !mail.from!
      @echo #   recipient:     !mail.to!
      @echo #   subject:       !mail.subject!
      @echo #   body:          %VALUE_NOTIFICATION%
      @echo #   attached file: %sysinfo%
      @echo.

      %sys.ColorNormal%

      set event.message="backup optical: unable to send mail notification. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )
  endlocal

  goto :EOF


:MSG_ERR_ISOBUILD

  setlocal
    set fs.BinDir=c:\jobs\bin

    set SET_IMAGE_COUNT=%1
    set SET_IMAGE_TOTAL=%2
    set SET_LOGFILE=%3
  set SET_SSNSEQ=%4

    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpeted error building ISO image.
    @echo #
    @echo #   image.count: %SET_IMAGE_COUNT%
    @echo #   image.total: %fs.files.packages.total%
    @echo.

    %sys.ColorNormal%

    set event.message="backup optical: [%VALUE_LABELID%] unexpeted error building ISO image [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
  endlocal

  goto :EOF


:MSG_OK_ISOBUILD

  setlocal
    set SET_IMAGE_COUNT=%1

    @echo.
    @echo # ISO image created successfully.
    @echo #
    @echo #   image.count: %SET_IMAGE_COUNT%
    @echo #   image.total: %fs.files.packages.total%
    @echo.

    set event.message="backup optical: [%VALUE_LABELID%] ISO image created successfully [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
  endlocal

  goto :EOF


:MSG_ERR_ISOTEST

  setlocal
    set SET_IMAGE_COUNT=%1

    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpeted error testing ISO image.
    @echo #
    @echo #   image.count: %SET_IMAGE_COUNT%
    @echo #   image.total: %fs.files.packages.total%
    @echo.

    %sys.ColorNormal%

    set event.message="backup optical: [%VALUE_LABELID%] unexpeted error testing ISO image [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul
  endlocal

  goto :EOF


:MSG_OK_ISOTEST

  setlocal
    set SET_IMAGE_COUNT=%1

    @echo.
    @echo # ISO image tested successfully.
    @echo #
    @echo #   image.count: %SET_IMAGE_COUNT%
    @echo #   image.total: %fs.files.packages.total%
    @echo.

    set event.message="backup optical: [%VALUE_LABELID%] ISO image tested successfully [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul
  endlocal

  goto :EOF


:MSG_ERR_ISOBURN

  setlocal
    set SET_IMAGE_COUNT=%1

    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: unexpeted error building ISO image [%SET_IMAGE_COUNT%/%fs.files.packages.total%].
    @echo.

    %sys.ColorNormal%

    set event.message="backup optical: [%VALUE_LABELID%] unexpeted error burning ISO image [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message!  >  nul

  endlocal

  goto :EOF


:MSG_OK_ISOBURN

  setlocal
    set SET_IMAGE_COUNT=%1

    @echo.
    @echo # ISO image burned successfully [%SET_IMAGE_COUNT%/%fs.files.packages.total%].
    @echo.

    set event.message="backup optical: [%VALUE_LABELID%] ISO image burned successfully [%SET_IMAGE_COUNT%/%fs.files.packages.total%]. [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.id% /l application /t information /so "backup:optical [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

  endlocal

  goto :EOF