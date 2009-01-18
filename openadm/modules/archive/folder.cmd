@echo off

@rem --------------------------------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: archive folder
@rem --------------------------------------------------------------------------------------------------------------
@rem Description:
@rem   Creates a package with the log files stored on a
@rem   given directory and stores it on an archive
@rem   repository.
@rem
@rem Dependencies:
@rem   eventcreate.exe - win2k3 server
@rem   sleep.exe       - win2k3 reskit
@rem   7za.exe         - www.7-zip.org (v4.32)
@rem   zip.exe         - www.info-zip.org (v2.31)
@rem   unzip.exe       - www.info-zip.org (v5.52)
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [archive.folder alert module]
@rem
@rem Usage:
@rem   <fs.SysOpDir>\archive folder <source-dir>
@rem                                <archive-dir>
@rem                                <-id:group-label>
@rem                                <-mode:{tree|dir|dirfull}>
@rem                                <-vol:{none|99m|99g}>
@rem                                <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir: <fs.SystemDrive>\openadm\modules\archive
@rem   fs.ConfDir:    <fs.SystemDrive>\openadm\conf
@rem   fs.TmpDir:     <fs.SystemDrive>\openadm\tmp
@rem   fs.SysOpDir:   <fs.SystemDrive>\openadm\actions\operations
@rem   fs.BinDir:     <fs.SystemDrive>\openadm\bin\system
@rem   fs.LogsDir:    <fs.DataDrive>\logs\openadm\archive
@rem
@rem   source-dir:     <source-dir>
@rem   archive-dir:    <archive-dir>
@rem --------------------------------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <source-dir>          - existing full-path directory name.
@rem   <archive-dir>         - existing full-path directory name.
@rem   <-id:group-label>     - label name which identifies the operation among other ones of the same type.
@rem   [-mode:tree]          - archives the whole directory tree starting at <source-dir>.
@rem   [-mode:dir]           - only archives the files located at <source-dir>.
@rem   [-mode:dirfull]       - only archives ALL the files located at <source-dir>. Unlike the
@rem                           dir mode, it does not exclude files created/modified on or after
@rem                           the current day.
@rem   [-vol:{none|99m|99g}] - volume mode: splits the zip file into multiple volume files.
@rem   [-a:{yes|no}]         - alert  mode: it triggers a post-scan log analysis.
@rem
@rem Important notes:
@rem   It uses several text files located on <fs.ConfDir>:
@rem     - el.iddb.ini
@rem
@rem   This script works on a directory basis. It does not take care about any current
@rem   transaction. For example in the case o an application that performs log rotation
@rem   every month, carrying out an archive process over the directory in with that logs
@rem   are being stored, would lead to serveral scenarios:
@rem
@rem     a. data written the first day of the month would be filed to the last month
@rem        archive.
@rem
@rem     b. the current log is blocked by the application. In this case the archive
@rem        process may fail or the file is skipped. There is no way know what is to
@rem        going to happen until it does.
@rem
@rem   That is why the archive process excludes from processing every log from the
@rem   current day. It excludes de current day and archives everything behind.
@rem
@rem   This is done through the the functions provided by Info-ZIP.
@rem
@rem   WARNING: verify the output of %date% in order to the script to operate the
@rem   right way.
@rem --------------------------------------------------------------------------------------------------------------


setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\modules\archive
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.TmpDir=%fs.SystemDrive%\openadm\tmp
  set fs.CmdbDir=%fs.SystemDrive%\openadm\cmdb\local
  set fs.SysOpDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.LogsDir=%fs.DataDrive%\logs\openadm\archive

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
  set SET_DESTINATION=%2
  set SET_LABELID=%3
  set SET_ARCHIVEMODE=%4
  set SET_VOLUMEMODE=%5
  set SET_ALERTMODE=%6
  set SET_LOGFILE=%7
  set SET_SSNSEQ=%8

  set VALUE_LABELID=%SET_LABELID:-id:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%
  set VALUE_ARCHIVEMODE=%SET_ARCHIVEMODE:-mode:=%
  set VALUE_VOLUMEMODE=%SET_VOLUMEMODE:-vol:=%

  set VALUE_ARCHIVEMODE_TREE=tree
  set VALUE_ARCHIVEMODE_DIR=dir
  set VALUE_ARCHIVEMODE_DIRFULL=dirfull
  set VALUE_VOLUMEMODE_NONE=none

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_ZIP_OK=0
  set EL_ZIP_ERROR=1
  set EL_7ZIP_OK=0
  set EL_7ZIP_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%


  if /i "%SET_SOURCE%"          EQU ""     goto HELP
  if /i "%SET_DESTINATION%"     EQU ""     goto HELP
  if /i %SET_LABELID:~0,3%      NEQ -id    goto HELP
  if /i %SET_ARCHIVEMODE:~0,2%  NEQ -mode  goto HELP
  if /i %SET_VOLUMEMODE:~0,2%   NEQ -vol   goto HELP
  if /i %SET_ALERTMODE:~0,2%    NEQ -a     goto HELP


  set fs.SourceDir=%SET_SOURCE:"=%
  if /i %fs.SourceDir:~-1% EQU \ set fs.SourceDir=%fs.SourceDir:~0,-1%
  if not exist "%fs.SourceDir%" goto HELP

  set fs.DestinationDir=%SET_DESTINATION:"=%
  if /i %fs.DestinationDir:~-1% EQU \ set fs.DestinationDir=%fs.DestinationDir:~0,-1%
  if not exist "%fs.DestinationDir%" goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_TREE%    set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_DIR%     set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_DIRFULL% set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%  set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\folder-%VALUE_LABELID%-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=folder-%VALUE_LABELID%-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini        set input.ValueIsOk=%STATUS_OFF%

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
  if not exist %fs.BinDir%\mtee.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\colorx.exe                   set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\datex.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.SysOpDir%\alert.cmd                  set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\zip.exe                      set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\unzip.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\7zip.exe                     set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.BinDir%\sleep.exe                    set input.ValueIsOk=%STATUS_OFF%

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
    @echo #   %fs.BinDir%\zip.exe
    @echo #   %fs.BinDir%\unzip.exe
    @echo #   %fs.BinDir%\7zip.exe
    @echo #   %fs.BinDir%\sleep.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
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

    set event.message="archive folder: [%VALUE_LABELID%] archiving "%fs.SourceDir%" on "%fs.DestinationDir%". [%fs.LogsDir%\%SET_LOGFILE%]"
    %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "archive:folder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:     %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    @echo # source dir:      "%fs.SourceDir%"
    @echo # destination dir: "%fs.DestinationDir%"
    @echo # group label:     %VALUE_LABELID%
    @echo # archive mode:    %VALUE_ARCHIVEMODE%
    @echo # volume set:      %VALUE_VOLUMEMODE%
    @echo # alert mode:      %VALUE_ALERTMODE%
    @echo # ------------------------------------------------------------------------
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


    @echo # target directory contents:
    @echo.

    %sys.ColorDark%

    set user.CurrentDir="%CD%"
    cd /d "%fs.SourceDir%"  >  nul

    if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_TREE% (
      dir  *.* /a /o:gen /q /l /c /4 /s
    ) else (
      dir  *.* /a /o:gen /q /l /c /4
    )

    %sys.ColorNormal%

    set archive.name="%fs.DestinationDir%\%VALUE_LABELID%-%yy%%mm%-%fs.LogFileCount%.zip"
    set archive.AltName="%fs.DestinationDir%\_%VALUE_LABELID%-%yy%%mm%-%fs.LogFileCount%.zip"


    @echo.
    %sys.ColorBright%
    @echo ////////////////////////////////////////////////////////////////////////
    %sys.ColorNormal%
    @echo # archiving: %archive.name%
    @echo.

    %sys.ColorDark%

    if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_DIRFULL% %fs.BinDir%\zip -9vTm  -b "%fs.DestinationDir%\"                      %archive.name% *.*
    if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_DIR%     %fs.BinDir%\zip -9vTm  -b "%fs.DestinationDir%\" -tt %yyyy%-%mm%-%dd% %archive.name% *.*
    if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_TREE%    %fs.BinDir%\zip -9vTmr -b "%fs.DestinationDir%\" -tt %yyyy%-%mm%-%dd% %archive.name% *.*

    if not {!errorlevel!} EQU {%EL_ZIP_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: archive creation failed.
      @echo #
      @echo #   archive.name: %archive.name%
      @echo.

      %sys.ColorNormal%

      set event.message="archive folder: [%VALUE_LABELID%] archive creation failed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "archive:folder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

      goto EXIT
    )

    %sys.ColorNormal%


    if /i %VALUE_VOLUMEMODE% NEQ %VALUE_VOLUMEMODE_NONE% (
      @echo.
      %sys.ColorBright%
      @echo ////////////////////////////////////////////////////////////////////////
      %sys.ColorNormal%
      @echo # spliting file: %archive.name%
      @echo.

      %sys.ColorDark%

      ren %archive.name% %archive.AltName% > nul

      %fs.BinDir%\7za a -tzip %archive.name% %archive.AltName% -m9 -w"%fs.DestinationDir%" -v%VALUE_VOLUMEMODE%

      if not {!errorlevel!} EQU {%EL_7ZIP_OK%} (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR: archive spliting failed.
        @echo #
        @echo #   archive.name:    %archive.name%
        @echo #   archive.altname: %archive.AltName%
        @echo.

        %sys.ColorNormal%

        set event.message="archive folder: [%VALUE_LABELID%] archive spliting failed. [%fs.LogsDir%\%SET_LOGFILE%]"
        %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "archive:folder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

        goto EXIT
      )

      %sys.ColorNormal%
    )

    @echo.
    %sys.ColorBright%
    @echo ////////////////////////////////////////////////////////////////////////
    %sys.ColorNormal%
    @echo # integrity validation of volume files: %archive.name%
    @echo.

    %sys.ColorDark%

    %fs.BinDir%\7za t %archive.name% *.* -r -w"%fs.DestinationDir%"

    if not {!errorlevel!} EQU {%EL_7ZIP_OK%} (
      @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%SET_LOGFILE:.log=.exit%

      %sys.ColorRed%

      @echo.
      @echo # ERROR: archive integrity validation failed.
      @echo #
      @echo #   archive.name: %archive.name%
      @echo.

      %sys.ColorNormal%

      set event.message="archive folder: [%VALUE_LABELID%] splited archive testing failed. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "archive:folder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul

      del /q /f %archive.name:.zip=%.*      >  nul
      ren %archive.AltName% %archive.name%  >  nul

      goto EXIT
    )

    %sys.ColorNormal%


    if /i %VALUE_VOLUMEMODE% NEQ %VALUE_VOLUMEMODE_NONE% )
      del /q /f %archive.AltName%           >  nul
    )


    @echo.
    %sys.ColorBright%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # target directory final state:
    @echo.

    %sys.ColorDark%

    if /i %VALUE_ARCHIVEMODE% EQU %VALUE_ARCHIVEMODE_TREE% (
      dir  *.* /a /o:gen /q /l /c /4 /s
    ) else (
      dir  *.* /a /o:gen /q /l /c /4
    )

    %sys.ColorNormal%

    cd /d %user.CurrentDir% >  nul

    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   archive folder [source-dir]
      @echo                  [archive-dir]
      @echo                  [-id:group-label]
      @echo                  [-mode:{tree^|dir^|dirfull}]
      @echo                  [-v:{none^|99m^|99g}]
      @echo                  [-a:{yes^|no}]
      @echo.

      goto END


    :EXIT

      @echo.
      %sys.ColorBright%
      @echo # ------------------------------------------------------------------------
      for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
      @echo # ========================================================================
      %sys.ColorNormal%

      set event.message="archive folder: [%VALUE_LABELID%] "%fs.SourceDir%" archived on "%fs.DestinationDir%". [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "archive:folder [%VALUE_LABELID%] [%SET_SSNSEQ%]" /d !event.message! > nul


    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd archive.folder -l:%SET_LOGFILE% -id:%VALUE_LABELID% -trap:yes

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul

    copy /v /y %fs.LogsDir%\%fs.LogFile:folder=% "%fs.DestinationDir%"  >  nul

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