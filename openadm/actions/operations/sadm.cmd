@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: sadm
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
@rem   Routes the user to the proper sadm sub-command and/or launches a given sub-command.
@rem
@rem Dependencies:
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   *.cmd           - openadm [sadm modules]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm <category>
@rem
@rem Disk locations:
@rem   fs.InstallDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:        <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:         <fs.SystemDrive>\openadm\bin\system
@rem   fs.ModulesDir:     <fs.SystemDrive>\openadm\modules\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <category> - stands for an administrative {resource|session|ic|do|acl}.
@rem
@rem Important notes:
@rem   It uses a text file located on <fs.InstallDir>:
@rem ------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

  set fs.SystemDrive=c:
  set fs.DataDrive=e:

  set fs.InstallDir=%fs.SystemDrive%\openadm\actions\operations
  set fs.ConfDir=%fs.SystemDrive%\openadm\conf
  set fs.BinDir=%fs.SystemDrive%\openadm\bin\system
  set fs.ModulesDir=%fs.SystemDrive%\openadm\modules\sadm

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


  set SET_CATEGORY=%1
  set SET_CMD=%2
  set SET_PARAMETERS=%3

  set VALUE_CATEGORY=%SET_CATEGORY:"=%
  set VALUE_CMD=%SET_CMD:-cmd:=%

  set VALUE_CATEGORY_RESOURCE=resource
  set VALUE_CATEGORY_SESSION=session
  set VALUE_CATEGORY_IC=ic
  set VALUE_CATEGORY_DO=do
  set VALUE_CATEGORY_ACL=acl
  set VALUE_CMD_CREATE=create
  set VALUE_CMD_DELETE=delete
  set VALUE_CMD_VIEW=view
  set VALUE_CMD_LOAD=load
  set VALUE_CMD_UNLOAD=unload
  set VALUE_CMD_EXEC=exec
  set VALUE_CMD_BACKUP=backup
  set VALUE_CMD_RESTORE=restore
  set VALUE_CMD_OPEN=open
  set VALUE_CMD_CLOSE=close
  set VALUE_CMD_MIRROR=mirror
  set VALUE_CMD_LIST=list
  set VALUE_CMD_QUERY=query

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%STATUS_OFF%


  if /i "%SET_CATEGORY%" EQU "" goto HELP


  :MAIN

    if /i {%VALUE_CATEGORY%} EQU {%VALUE_CATEGORY_RESOURCE%} (
      set input.ValueIsOk=%STATUS_OFF%

      if /i "%SET_CMD%"   NEQ ""                      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CREATE%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_DELETE%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_VIEW%"      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LOAD%"      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_UNLOAD%"    set input.ValueIsOk=%STATUS_ON%

      if /i {!input.ValueIsOk!} EQU {%STATUS_OFF%} (
        @echo.
        @echo   OpenADM version 3.5.1.0b2, Copyright ^(C^) 2006 Carlos Veira Lorenzo
        @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
        @echo   under GPL 2.0 license terms and conditions.
        @echo.
        @echo   sadm resource -cmd:{create^|delete^|view^|load^|unload}
        @echo.
      ) else (
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CREATE%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\rescreate.cmd %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_DELETE%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\resdelete.cmd %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_VIEW%"    for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\resview.cmd   %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LOAD%"    for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\resload.cmd   %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_UNLOAD%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\resunload.cmd %%k

        set user.ExitCode=!errorlevel!
      )
    )


    if /i {%VALUE_CATEGORY%} EQU {%VALUE_CATEGORY_SESSION%} (
      set input.ValueIsOk=%STATUS_OFF%

      if /i "%SET_CMD%"   NEQ ""                      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_OPEN%"      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CLOSE%"     set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_MIRROR%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LIST%"      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_QUERY%"     set input.ValueIsOk=%STATUS_ON%

      if /i {!input.ValueIsOk!} EQU {%STATUS_OFF%} (
        @echo.
        @echo   OpenADM version 3.5.1.0b2, Copyright ^(C^) 2006 Carlos Veira Lorenzo
        @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
        @echo   under GPL 2.0 license terms and conditions.
        @echo.
        @echo   sadm session -cmd:{open^|close^|mirror^|list^|query}
        @echo.
      ) else (
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_OPEN%"    for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\ssnopen.cmd   %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CLOSE%"   for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\ssnclose.cmd  %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_MIRROR%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\ssnmirror.cmd %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_LIST%"    for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\ssnlist.cmd   %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_QUERY%"   for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\ssnquery.cmd  %%k

        set user.ExitCode=!errorlevel!
      )
    )


    if /i {%VALUE_CATEGORY%} EQU {%VALUE_CATEGORY_IC%} (
      for /f "tokens=1,* delims= " %%i in ("%*") do call %fs.ModulesDir%\icctl.cmd %%j

      set user.ExitCode=!errorlevel!
    )


    if /i {%VALUE_CATEGORY%} EQU {%VALUE_CATEGORY_DO%} (
      set input.ValueIsOk=%STATUS_OFF%

      if /i "%SET_CMD%"   NEQ ""                      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CREATE%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_DELETE%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_EXEC%"      set input.ValueIsOk=%STATUS_ON%

      if /i {!input.ValueIsOk!} EQU {%STATUS_OFF%} (
        @echo.
        @echo   OpenADM version 3.5.1.0b2, Copyright ^(C^) 2006 Carlos Veira Lorenzo
        @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
        @echo   under GPL 2.0 license terms and conditions.
        @echo.
        @echo   sadm do -cmd:{create^|delete^|exec}
        @echo.
      ) else (
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_CREATE%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\docreate.cmd %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_DELETE%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\dodelete.cmd %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_EXEC%"    for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\doexec.cmd   %%k

        set user.ExitCode=!errorlevel!
      )
    )


    if /i {%VALUE_CATEGORY%} EQU {%VALUE_CATEGORY_ACL%} (
      set input.ValueIsOk=%STATUS_OFF%

      if /i "%SET_CMD%"   NEQ ""                      set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_BACKUP%"    set input.ValueIsOk=%STATUS_ON%
      if /i "%VALUE_CMD%" EQU "%VALUE_CMD_RESTORE%"   set input.ValueIsOk=%STATUS_ON%

      if /i {!input.ValueIsOk!} EQU {%STATUS_OFF%} (
        @echo.
        @echo   OpenADM version 3.5.1.0b2, Copyright ^(C^) 2006 Carlos Veira Lorenzo
        @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
        @echo   under GPL 2.0 license terms and conditions.
        @echo.
        @echo   sadm acl -cmd:{backup^|restore}
        @echo.
      ) else (
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_BACKUP%"  for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\aclbackup.cmd  %%k
        if /i "%VALUE_CMD%" EQU "%VALUE_CMD_RESTORE%" for /f "tokens=1,2,* delims= " %%i in ("%*") do call %fs.ModulesDir%\aclrestore.cmd %%k

        set user.ExitCode=!errorlevel!
      )
    )


    goto EXIT


  :HELP

    @echo.
    @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
    @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
    @echo   under GPL 2.0 license terms and conditions.
    @echo.
    @echo   sadm [resource^|session^|ic^|do^|acl]
    @echo.


  :EXIT

    %fs.BinDir%\colorx -c %sys.ColorOriginal%
    %fs.BinDir%\chcp %sys.CPOriginal%  >  nul

    exit /b !user.ExitCode!

endlocal