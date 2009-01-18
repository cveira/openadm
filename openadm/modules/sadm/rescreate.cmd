@echo off

@rem ------------------------------------------------------------------------------------
@rem Author:      Carlos Veira Lorenzo - cveira [at] thinkinbig.org
@rem Version:     3.5.1.0b2-20090118-0
@rem Date:        2009/01/18
@rem Script name: rescreate
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
@rem   Creates a local resource.
@rem
@rem Dependencies:
@rem   setacl.exe      - setacl.sf.net (v2.0.2)
@rem   wmic.exe        - win2k3 server
@rem   net.exe         - win2k3 server
@rem   dsadd.exe       - win2k3 server
@rem   eventcreate.exe - win2k3 server
@rem   mtee.exe        - http://www.commandline.co.uk (v2.0)
@rem   datex.exe       - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   colorx.exe      - http://internet.cybermesa.com/~bstewart/ (v2.0)
@rem   alert.cmd       - openadm [rescreate alert module]
@rem
@rem Usage:
@rem   <fs.InstallDir>\sadm resource -cmd:create
@rem                                 <res-label>
@rem                                 <-p:{none|"name"|"full-path-name"}>
@rem                                 <-type:[¡]{org|role|svc|job|fs|web|ftp|ts|reg|scm|db|prn|vcs|ur|dr|ras|vpn|fw|mail|chat|vmm|dcom|arole|elog|hw}>
@rem                                 <-acl:{single|bit|default|default-inherit|full|full-inherit}>
@rem                                 <-scope:{local|ntdomain|addomain|lgroups-only|ntgroups-only|adgroups-only|tfolder-only|secapply-only}>
@rem                                 <-mode:{exec|test}>
@rem                                 <-a:{yes|no}>
@rem
@rem Disk locations:
@rem   fs.InstallDir:   <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.SysOpDir:     <fs.SystemDrive>\openadm\actions\operations
@rem   fs.ConfDir:      <fs.SystemDrive>\openadm\conf
@rem   fs.BinDir:       <fs.SystemDrive>\openadm\bin\system
@rem   fs.ModulesDir:   <fs.SystemDrive>\openadm\modules\sadm
@rem   fs.TmpDir:       <fs.SystemDrive>\openadm\tmp
@rem   fs.CmdbDir:      <fs.SystemDrive>\openadm\cmdb\local
@rem   fs.LogsDir:      <fs.DataDrive>\logs\openadm\sadm
@rem ------------------------------------------------------------------------------------
@rem Usage notes:
@rem   <res-label>            - resource label name.
@rem   [-type:¡]              - defines system service resource.
@rem   [-type:org]            - resource type: organizational entity.
@rem   [-type:role]           - resource type: organizational entity.
@rem   [-type:svc]            - resource type: service resource.
@rem   [-type:job]            - resource type: planned job resource.
@rem   [-type:fs]             - resource type: file system resource.
@rem   [-type:web]            - resource type: web server or http accessible resource.
@rem   [-type:ftp]            - resource type: ftp server or ftp accessible resource.
@rem   [-type:reg]            - resource type: registry key.
@rem   [-type:scm]            - resource type: service control manager resource.
@rem   [-type:db]             - resource type: database resource.
@rem   [-type:prn]            - resource type: printer.
@rem   [-type:vcs]            - resource type: version control system or version control resource.
@rem   [-type:ur]             - resource type: system user right.
@rem   [-type:dr]             - resource type: digital right.
@rem   [-type:ras]            - resource type: remote access service.
@rem   [-type:vpn]            - resource type: virtual private network.
@rem   [-type:fw]             - resource type: firewall access.
@rem   [-type:mail]           - resource type: mail server or mail accessible resource.
@rem   [-type:chat]           - resource type: chat server or chat accessible resource.
@rem   [-type:vmm]            - resource type: virtual machine monitor resource.
@rem   [-type:dcom]           - resource type: DCOM resource.
@rem   [-type:arole]          - resource type: web or LoB application internal role.
@rem   [-type:elog]           - resource type: event log resources.
@rem   [-type:hw]             - resource type: hardware device resources.
@rem   [-acl:single]          - single access profile (1): chg. + inherit from parent.
@rem   [-acl:bit]             - simple access profile (2): chg, da. (inherit from parent).
@rem   [-acl:default]         - regular access profile (3): chg, ro, da.
@rem   [-acl:default-inherit] - inherit security from parent and add new regular access control profiles.
@rem   [-acl:full]            - access profile (5): chg, ro, da, w, rw.
@rem   [-acl:full-inherit]    - inherit security from parent and add new full access control profiles.
@rem   [-p:none]              - no operation will be done against any target.
@rem   [-p:"name"]            - represents the parent resource name (usually a folder).
@rem   [-p:"full-path-name"]  - represents the parent resource full-path and name.
@rem   [-scope:local]         - target objects and security belong to local system and security objects too.
@rem   [-scope:ntdomain]      - target objects and security belong to local system but security objects belong to local NT4 domain.
@rem   [-scope:addomain]      - target objects and security belong to local system but security objects belong to local AD domain.
@rem   [-scope:lgroups-only]  - just creates local groups on local system.
@rem   [-scope:ntgroups-only] - just creates local groups on local NT4 domain.
@rem   [-scope:adgroups-only] - just creates local groups on local AD domain.
@rem   [-scope:tfolders-only] - just creates local folders on local system.
@rem   [-scope:secapply-only] - just applies existing security groups to existing local resources.
@rem   [-mode:exec]           - it sets execution mode: changes will be done on the system.
@rem   [-mode:test]           - it sets test mode: no changes will be done on the system.
@rem   [-a:{yes|no}]          - alert mode: it triggers a post-execution log analysis.
@rem
@rem  Restricted parameter matrix combination:
@rem   -type:¡                                                >> -p:none
@rem   -type:{org|db|prn|scm|ur|dr|ras|vpn|fw|mail|chat|vmm|
@rem          dcom|arole|elog|hw}                             >> -p:none
@rem   -type:{reg}                                            >> -p:"full-path-name"
@rem   -type:¡                                                >> -type:¡{role|svc|job}
@rem
@rem   -type:¡                                                >> -acl:single
@rem   -type:{fs|web|ftp|ts|hw}                               >> -acl:{bit|default|default-inherit|full|full-inherit}
@rem   -type:{org|role|svc|job|ur|dr|ras|vpn|fw|chat}         >> -acl:single
@rem   -type:{vmm|arole}                                      >> -acl:{default|full}
@rem   -type:{vcs|mail}                                       >> -acl:{single|default}
@rem   -type:{reg}                                            >> -acl:{bit|default-inherit}
@rem   -type:{db|prn|scm|dcom|elog}                           >> -acl:{bit}
@rem
@rem   -type:{db|prn|scm|ur|dr|ras|vpn|fw|mail|chat|vmm|
@rem          dcom|arole|elog|hw}                             >> -scope:{lgroups-only|ntgroups-only|adgroups-only}
@rem   -type:{org}                                            >> -scope:{ntgroups-only|adgroups-only}
@rem   -p:none                      -type:{reg}               >> -scope:{lgroups-only|ntgroups-only|adgroups-only}
@rem   -p:"full-path-name"          -type:{reg}               >> -scope:{local|secapply-only}
@rem   -p:none                      -type:{fs|web|ftp|ts|vcs} >> -scope:{lgroups-only|ntgroups-only|adgroups-only}
@rem   -p:{"name"|"full-path-name"} -type:{fs|web|ftp|ts|vcs} >> -scope:{local|tfolders-only|secapply-only}
@rem   -p:none                      -type:[¡]{role|svc|job}   >> -scope:{lgroups-only|ntgroups-only|adgroups-only}
@rem   -p:"full-path-name"          -type:[¡]{role|svc|job}   >> -scope:{local|tfolders-only|secapply-only}
@rem
@rem   -type:[¡]{svc}                                         >> reslabel ::= {db*|web*|ftp*|vcs*|*}
@rem
@rem Important notes:
@rem   It uses several text files located on:
@rem     - <fs.ConfDir> : domain.ini
@rem     - <fs.ConfDir> : el.iddb.ini
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


  set SET_RESLABEL=%1
  set SET_RESPARENT=%2
  set SET_RESTYPE=%3
  set SET_ACLPROFILE=%4
  set SET_SCOPE=%5
  set SET_OPMODE=%6
  set SET_ALERTMODE=%7
  set SET_LOGFILE=%8
  set SET_SSNSEQ=%9

  set VALUE_RESLABEL=%SET_RESLABEL%
  set VALUE_RESPARENT=%SET_RESPARENT:-p:=%
  set VALUE_RESTYPE=%SET_RESTYPE:-type:=%
  set VALUE_ACLPROFILE=%SET_ACLPROFILE:-acl:=%
  set VALUE_SCOPE=%SET_SCOPE:-scope:=%
  set VALUE_OPMODE=%SET_OPMODE:-mode:=%
  set VALUE_ALERTMODE=%SET_ALERTMODE:-a:=%

  set VALUE_RESLABEL=%VALUE_RESLABEL:"=%
  set VALUE_RESPARENT=%VALUE_RESPARENT:"=%
  if /i %VALUE_RESPARENT:~-1% EQU \ set VALUE_RESPARENT=%VALUE_RESPARENT:~0,-1%

  set VALUE_RESPARENT_NONE=none
  set VALUE_RESPARENT_ISDRIVE=:
  set VALUE_RESTYPE_SYSPRIV=¡
  set VALUE_RESTYPE_ORG=org
  set VALUE_RESTYPE_ROLE=role
  set VALUE_RESTYPE_SVC=svc
  set VALUE_RESTYPE_JOB=job
  set VALUE_RESTYPE_FS=fs
  set VALUE_RESTYPE_WEB=web
  set VALUE_RESTYPE_FTP=ftp
  set VALUE_RESTYPE_TS=ts
  set VALUE_RESTYPE_REG=reg
  set VALUE_RESTYPE_SCM=scm
  set VALUE_RESTYPE_DB=db
  set VALUE_RESTYPE_PRN=prn
  set VALUE_RESTYPE_VCS=vcs
  set VALUE_RESTYPE_UR=ur
  set VALUE_RESTYPE_DR=dr
  set VALUE_RESTYPE_RAS=ras
  set VALUE_RESTYPE_VPN=vpn
  set VALUE_RESTYPE_FW=fw
  set VALUE_RESTYPE_MAIL=mail
  set VALUE_RESTYPE_CHAT=chat
  set VALUE_RESTYPE_VMM=vmm
  set VALUE_RESTYPE_DCOM=dcom
  set VALUE_RESTYPE_APPROLE=arole
  set VALUE_RESTYPE_ELOG=elog
  set VALUE_RESTYPE_HW=hw
  set VALUE_ACLPROFILE_SINGLE=single
  set VALUE_ACLPROFILE_BIT=bit
  set VALUE_ACLPROFILE_DEFAULT=default
  set VALUE_ACLPROFILE_DEFAULTINHERIT=default-inherit
  set VALUE_ACLPROFILE_FULL=full
  set VALUE_ACLPROFILE_FULLINHERIT=full-inherit
  set VALUE_SCOPE_LOCAL=local
  set VALUE_SCOPE_NTDOMAIN=ntdomain
  set VALUE_SCOPE_ADDOMAIN=addomain
  set VALUE_SCOPE_LGROUPSONLY=lgroups-only
  set VALUE_SCOPE_NTGROUPSONLY=ntgroups-only
  set VALUE_SCOPE_ADGROUPSONLY=adgroups-only
  set VALUE_SCOPE_TFOLDERSONLY=tfolders-only
  set VALUE_SCOPE_SECAPPLYONLY=apply-only
  set VALUE_OPMODE_EXEC=exec
  set VALUE_OPMODE_TEST=test

  if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
    set VALUE_RESTYPE_ORG=¡org
    set VALUE_RESTYPE_ROLE=¡role
    set VALUE_RESTYPE_SVC=¡svc
    set VALUE_RESTYPE_JOB=¡job
    set VALUE_RESTYPE_FS=¡fs
    set VALUE_RESTYPE_WEB=¡web
    set VALUE_RESTYPE_FTP=¡ftp
    set VALUE_RESTYPE_TS=¡ts
    set VALUE_RESTYPE_REG=¡reg
    set VALUE_RESTYPE_SCM=¡scm
    set VALUE_RESTYPE_DB=¡db
    set VALUE_RESTYPE_PRN=¡prn
    set VALUE_RESTYPE_VCS=¡vcs
    set VALUE_RESTYPE_UR=¡ur
    set VALUE_RESTYPE_DR=¡dr
    set VALUE_RESTYPE_RAS=¡ras
    set VALUE_RESTYPE_VPN=¡vpn
    set VALUE_RESTYPE_FW=¡fw
    set VALUE_RESTYPE_MAIL=¡mail
    set VALUE_RESTYPE_CHAT=¡chat
    set VALUE_RESTYPE_VMM=¡vmm
    set VALUE_RESTYPE_DCOM=¡dcom
    set VALUE_RESTYPE_APPROLE=¡arole
    set VALUE_RESTYPE_ELOG=¡elog
    set VALUE_RESTYPE_HW=¡hw
  )

  set VALUE_ACCESSROLE_RX=rx
  set VALUE_ACCESSROLE_RW=rw
  set VALUE_ACCESSROLE_RWX=rwx
  set VALUE_ACCESSROLE_RWXD=rwxd
  set VALUE_ACCESSROLE_WO=wo
  set VALUE_ACCESSROLE_RO=ro
  set VALUE_ACCESSROLE_LO=lo
  set VALUE_ACCESSROLE_DA=da

  set STATUS_ON=1
  set STATUS_OFF=0
  set STATUS_YES=yes
  set STATUS_NO=no

  set EL_STATUS_OK=0
  set EL_STATUS_ERROR=1
  set EL_NET_OK=0
  set EL_NET_ERROR=1
  set EL_DSADD_OK=0
  set EL_DSADD_ERROR=1
  set EL_SETACL_OK=0
  set EL_SETACL_ERROR=1
  set EL_WMIC_OK=0
  set EL_WMIC_ERROR=1

  set LIST_DELIMITER=,
  set FIELD_DELIMITER=;

  set user.ExitCode=%EL_STATUS_OK%
  set ds.SettingsFile=%fs.ConfDir%\domain.ini


  if not exist %fs.LogsDir% md %fs.LogsDir%  >  nul

  set fs.LogFileCount=0
  for %%i in (%fs.LogsDir%\rescreate-%yy%%mm%%dd%*.log) do (
    set /a fs.LogFileCount+=1
  )

  set fs.LogFile=rescreate-%yy%%mm%%dd%-%fs.LogFileCount%.log


  set input.ValueIsOk=%STATUS_ON%

  if not exist %fs.ConfDir%\el.iddb.ini         set input.ValueIsOk=%STATUS_OFF%
  if not exist %fs.ConfDir%\domain.ini          set input.ValueIsOk=%STATUS_OFF%

  if /i !input.ValueIsOk! EQU %STATUS_OFF% (
    @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

    %sys.ColorRed%

    @echo.
    @echo # ERROR: input INI file does not exist.
    @echo #
    @echo #   %fs.ConfDir%\el.iddb.ini
    @echo #   %fs.ConfDir%\domain.ini
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
  if not exist %fs.BinDir%\dsadd.exe                    set input.ValueIsOk=%STATUS_OFF%
  if not exist %systemroot%\system32\net.exe            set input.ValueIsOk=%STATUS_OFF%
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
    @echo #   %fs.BinDir%\setacl.exe
    @echo #   %fs.BinDir%\dsadd.exe
    @echo #   %systemroot%\system32\net.exe
    @echo #   %systemroot%\system32\wbem\wmic.exe
    @echo #
    @echo # aborting program.
    @echo.

    %sys.ColorNormal%

    goto HELP
  )


  for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%fs.ConfDir%\el.iddb.ini) do (
    if /i %%i EQU resource.begin          set event.BeginId=%%j
    if /i %%i EQU resource.end            set event.EndId=%%j
    if /i %%i EQU resource.begin.TestMode set event.TestModeBeginId=%%j
    if /i %%i EQU resource.end.TestMode   set event.TestModeEndId=%%j
    if /i %%i EQU resource.event          set event.id=%%j
  )


  if /i %SET_RESPARENT:~0,2%  NEQ -p     goto HELP
  if /i %SET_RESTYPE:~0,5%    NEQ -type  goto HELP
  if /i %SET_ACLPROFILE:~0,4% NEQ -acl   goto HELP
  if /i %SET_SCOPE:~0,6%      NEQ -scope goto HELP
  if /i %SET_OPMODE:~0,5%     NEQ -mode  goto HELP
  if /i %SET_ALERTMODE:~0,2%  NEQ -a     goto HELP

  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DB%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_UR%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DR%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_RAS%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VPN%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FW%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_MAIL%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_CHAT%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VMM%                  set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DCOM%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_APPROLE%              set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ELOG%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_HW%                   set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%                    set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN%                 set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%              set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY%             set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY%             set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE%         set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_BIT%            set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULT%        set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_DEFAULTINHERIT% set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULL%           set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_FULLINHERIT%    set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_OPMODE% EQU %VALUE_OPMODE_EXEC%                   set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_OPMODE% EQU %VALUE_OPMODE_TEST%                   set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  set input.ValueIsOk=%STATUS_OFF%

  if /i %VALUE_ALERTMODE% EQU %STATUS_YES%                       set input.ValueIsOk=%STATUS_ON%
  if /i %VALUE_ALERTMODE% EQU %STATUS_NO%                        set input.ValueIsOk=%STATUS_ON%

  if /i %input.ValueIsOk% EQU %STATUS_OFF% goto HELP


  if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
    setlocal enabledelayedexpansion
      set restype.SysPrivIsOk=%STATUS_OFF%

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE%             set restype.SysPrivIsOk=%STATUS_ON%
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%              set restype.SysPrivIsOk=%STATUS_ON%
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%              set restype.SysPrivIsOk=%STATUS_ON%

      if /i !restype.SysPrivIsOk! EQU %STATUS_OFF%               set VALUE_RESTYPE=%VALUE_RESTYPE:¡=%
    endlocal
  )


  set ContextStage.SkipGroupCreation=%STATUS_ON%
  set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
  set ContextStage.SkipSecurityConfig=%STATUS_ON%

  set scope.IsLocal=%STATUS_OFF%
  set scope.IsAD=%STATUS_OFF%

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% set scope.IsLocal=%STATUS_ON%

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN% (
    set scope.IsLocal=%STATUS_OFF%
    set scope.IsAD=%STATUS_ON%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN% (
    set scope.IsLocal=%STATUS_OFF%
    set scope.IsAD=%STATUS_OFF%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%
    set scope.IsLocal=%STATUS_ON%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%
    set scope.IsLocal=%STATUS_OFF%
    set scope.IsAD=%STATUS_OFF%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%
    set scope.IsLocal=%STATUS_OFF%
    set scope.IsAD=%STATUS_ON%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% (
    set ContextStage.SkipGroupCreation=%STATUS_ON%
    set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%
    set scope.IsLocal=%STATUS_OFF%
  )

  if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% (
    set ContextStage.SkipGroupCreation=%STATUS_ON%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_OFF%
  )


  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%

    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%

    setlocal enabledelayedexpansion
      set input.ValueIsOk=%STATUS_OFF%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_ON%
      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_ON%

      if /i !input.ValueIsOk! EQU %STATUS_OFF% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR - invalid parameter combination.
        @echo #
        @echo #   resource parent: %VALUE_RESPARENT%
        @echo #   resource type:   %VALUE_RESTYPE%
        @echo #   acl profile:     %VALUE_ACLPROFILE%
        @echo #   scope:           %VALUE_SCOPE%
        @echo #
        @echo # aborting program.

        %sys.ColorNormal%

        goto HELP
      )
    endlocal
  )


  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%

    if /i %VALUE_RESPARENT% EQU %VALUE_RESPARENT_NONE% (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_ON%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      endlocal
    ) else (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_ON%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      endlocal

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        set ContextStage.SkipGroupCreation=%STATUS_OFF%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_ON%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_RESPARENT:~1,1% NEQ %VALUE_RESPARENT_ISDRIVE% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR - invalid parameter combination.
        @echo #
        @echo #   resource parent: %VALUE_RESPARENT%
        @echo #   resource type:   %VALUE_RESTYPE%
        @echo #   acl profile:     %VALUE_ACLPROFILE%
        @echo #   scope:           %VALUE_SCOPE%
        @echo #
        @echo # aborting program.

        %sys.ColorNormal%

        goto HELP
      )
    )
  )


  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%

    if /i %VALUE_RESPARENT% EQU %VALUE_RESPARENT_NONE% (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_ON%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      endlocal
    ) else (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_ON%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      endlocal

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        set ContextStage.SkipGroupCreation=%STATUS_OFF%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_ON%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_RESPARENT:~1,1% NEQ %VALUE_RESPARENT_ISDRIVE% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR - invalid parameter combination.
        @echo #
        @echo #   resource parent: %VALUE_RESPARENT%
        @echo #   resource type:   %VALUE_RESTYPE%
        @echo #   acl profile:     %VALUE_ACLPROFILE%
        @echo #   scope:           %VALUE_SCOPE%
        @echo #
        @echo # aborting program.

        %sys.ColorNormal%

        goto HELP
      )
    )
  )


  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB% (
    set ContextStage.SkipGroupCreation=%STATUS_OFF%
    set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
    set ContextStage.SkipSecurityConfig=%STATUS_ON%

    if /i %VALUE_RESPARENT% EQU %VALUE_RESPARENT_NONE% (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_ON%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      endlocal
    ) else (
      setlocal enabledelayedexpansion
        set input.ValueIsOk=%STATUS_ON%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADDOMAIN%     set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_OFF%

        if /i !input.ValueIsOk! EQU %STATUS_OFF% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      endlocal

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL% (
        set ContextStage.SkipGroupCreation=%STATUS_OFF%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
        set ContextStage.SkipSecurityConfig=%STATUS_ON%
      )

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% (
        set ContextStage.SkipGroupCreation=%STATUS_ON%
        set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
        set ContextStage.SkipSecurityConfig=%STATUS_OFF%
      )

      if /i %VALUE_RESPARENT:~1,1% NEQ %VALUE_RESPARENT_ISDRIVE% (
        @echo %EL_STATUS_ERROR% >> %fs.TmpDir%\%fs.LogFile:.log=.exit%

        %sys.ColorRed%

        @echo.
        @echo # ERROR - invalid parameter combination.
        @echo #
        @echo #   resource parent: %VALUE_RESPARENT%
        @echo #   resource type:   %VALUE_RESTYPE%
        @echo #   acl profile:     %VALUE_ACLPROFILE%
        @echo #   scope:           %VALUE_SCOPE%
        @echo #
        @echo # aborting program.

        %sys.ColorNormal%

        goto HELP
      )
    )
  )


  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DB% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_BIT%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_BIT%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_BIT%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_UR% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DR% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_RAS% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VPN% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FW% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_MAIL% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    if /i %VALUE_ACLPROFILE% NEQ %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_CHAT% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VMM% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    if /i %VALUE_ACLPROFILE% NEQ %VALUE_ACLPROFILE_FULL% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DCOM% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_BIT%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_APPROLE% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    if /i %VALUE_ACLPROFILE% NEQ %VALUE_ACLPROFILE_FULL% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ELOG% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_BIT%
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_HW% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS% (
    if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% (
    if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% (
    if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS% (
    if /i %VALUE_ACLPROFILE% EQU %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% (
    if /i %VALUE_ACLPROFILE% NEQ %VALUE_ACLPROFILE_SINGLE% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
    if /i %VALUE_ACLPROFILE% NEQ %VALUE_ACLPROFILE_BIT% (
      set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_DEFAULTINHERIT%
    )
  )

  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ORG%  set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ROLE% set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SVC%  set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_JOB%  set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%

  if /i %VALUE_RESTYPE:~0,1% EQU %VALUE_RESTYPE_SYSPRIV% (
    set VALUE_RESPARENT=%VALUE_RESPARENT_NONE%
    set VALUE_ACLPROFILE=%VALUE_ACLPROFILE_SINGLE%
  )


  if /i %VALUE_RESPARENT% EQU %VALUE_RESPARENT_NONE% (
    setlocal enabledelayedexpansion
      set input.ValueIsOk=%STATUS_OFF%

      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LGROUPSONLY%  set input.ValueIsOk=%STATUS_ON%
      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_NTGROUPSONLY% set input.ValueIsOk=%STATUS_ON%
      if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_ADGROUPSONLY% set input.ValueIsOk=%STATUS_ON%

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DB% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_UR% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DR% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_RAS% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VPN% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FW% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_MAIL% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_CHAT% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VMM% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_DCOM% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_APPROLE% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_ELOG% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_HW% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
        set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
        set ContextStage.SkipGroupCreation=%STATUS_OFF%
        set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
        set ContextStage.SkipSecurityConfig=%STATUS_ON%
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% (
        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LGROUPSONLY%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_ON%
        )
      )
    endlocal
  ) else (
    setlocal enabledelayedexpansion
      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_ON%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_TS% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )

      if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% (
        set input.ValueIsOk=%STATUS_OFF%

        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_LOCAL%        set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_TFOLDERSONLY% set input.ValueIsOk=%STATUS_ON%
        if /i %VALUE_SCOPE% EQU %VALUE_SCOPE_SECAPPLYONLY% set input.ValueIsOk=%STATUS_ON%

        if !input.ValueIsOk! NEQ %STATUS_ON% (
          set VALUE_SCOPE=%VALUE_SCOPE_LOCAL%
          set ContextStage.SkipGroupCreation=%STATUS_OFF%
          set ContextStage.SkipTargetFolderCreation=%STATUS_OFF%
          set ContextStage.SkipSecurityConfig=%STATUS_OFF%
        )
      )
    endlocal
  )


  if /i %context.IsCallBack% EQU %STATUS_ON% goto MAIN

  set cmdb.ScriptName=%fs.LogFile:.log=.cmd%
  set cmdb.RequestedAction=%~dpnx0 %*

  call %~dpnx0 MAIN %* %fs.LogFile% %dd%-%fs.LogFileCount% 2>&1 | %fs.BinDir%\mtee /c /d /t %fs.LogsDir%\%fs.LogFile%
  goto END

  :MAIN

    echo.

    set fs.FsRootDir=e:\pub\fs
    set fs.WebRootDir=e:\pub\web
    set fs.FtpRootDir=e:\pub\ftp
    set fs.VcsRootDir=e:\pub\vcs
    set fs.DbRootDir=e:\pub\db
    set fs.BackupRootDir=e:\backup
    set fs.ArchiveRootDir=e:\archive
    set fs.TsRootDir=c:\bin
    set fs.ServicesRootDir=c:\services


    if %scope.IsLocal% EQU %STATUS_OFF% (
      set ds.CurrentDomain=""

      if /i %scope.IsAD% EQU %STATUS_ON% (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%ds.SettingsFile%) do (
          if /i %%i EQU domain       set ds.domain=%%j
          if /i %%i EQU server       set ds.server=%%j
          if /i %%i EQU user         set ds.user=%%j
          if /i %%i EQU password     set ds.passwd=%%j
          if /i %%i EQU ldap.ResPath set ds.ResourceObjectsPath=%%j
          if /i %%i EQU ldap.AdmPath set ds.AdmObjectsPath=%%j
          if /i %%i EQU ldap.OrgPath set ds.OrgObjectsPath=%%j
          if /i %%i EQU ldap.SvcPath set ds.ServiceObjectsPath=%%j
          if /i %%i EQU ldap.JobPath set ds.JobObjectsPath=%%j
        )

        set ds.CurrentDomain=%ds.domain%\
      ) else (
        for /f "eol=# tokens=1,* delims=%FIELD_DELIMITER%" %%i in (%ds.SettingsFile%) do (
          if /i %%i EQU domain       set ds.domain=%%j
          if /i %%i EQU server       set ds.server=%%j
          if /i %%i EQU user         set ds.user=%%j
          if /i %%i EQU password     set ds.passwd=%%j
        )

        set ds.CurrentDomain=%ds.domain%\
      )
    )


    set input.LabelName=%VALUE_RESLABEL%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_SCM% set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_PRN% set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_REG% set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FS%  set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_WEB% set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_FTP% set input.LabelName=%VALUE_RESLABEL: =.%
    if /i %VALUE_RESTYPE% EQU %VALUE_RESTYPE_VCS% set input.LabelName=%VALUE_RESLABEL: =.%


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

    set ACL_SYSTEM_PROFILE_FS=-ace "n:%ds.CurrentDomain%!res-fs-system;p:change" -ace "n:%ds.CurrentDomain%!res-fs-system-%VALUE_ACCESSROLE_DA%;p:read_ex;m:deny" -ace "n:%ds.CurrentDomain%!res-fs-system-%VALUE_ACCESSROLE_RX%;p:read_ex" -ace "n:%ds.CurrentDomain%!res-fs-system-%VALUE_ACCESSROLE_LO%;p:list_folder" -ace "n:%ds.CurrentDomain%!res-fs-system-%VALUE_ACCESSROLE_WO%;p:write" -ace "n:%ds.CurrentDomain%!res-fs-system-%VALUE_ACCESSROLE_RWX%;p:read_ex,write" -ace "n:%ds.CurrentDomain%role-adm-system;p:full"
    set ACL_USER_DEFAULT_PROFILE_FS=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RX%;p:read_ex" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:read_ex;m:deny"
    set ACL_USER_DEFAULT_PROFILE_REG=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RO%;p:read" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:read;m:deny"
    set ACL_USER_FULL_PROFILE_FS=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RWX%;p:read_ex,write" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RW%;p:read,write" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_WO%;p:write" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RX%;p:read_ex" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RO%;p:read" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_LO%;p:list_folder" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:read_ex;m:deny"
    set ACL_USER_BIT_PROFILE_FS=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_RX%;p:read_ex" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:read_ex;m:deny"
    set ACL_USER_BIT_PROFILE_REG=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:read" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:read;m:deny"
    set ACL_USER_BIT_PROFILE_PRN=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:print" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:print;m:deny"
    set ACL_USER_BIT_PROFILE_SCM=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:start_stop" -ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%-%VALUE_ACCESSROLE_DA%;p:start_stop;m:deny"
    set ACL_USER_SINGLE_PROFILE_VCS=-ace "n:%ds.CurrentDomain%res-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_ROLE=-ace "n:%ds.CurrentDomain%%VALUE_RESTYPE:¡=%-adm-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_ROLE_SYSPRIV=-ace "n:%ds.CurrentDomain%!%VALUE_RESTYPE:¡=%-adm-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_JOB=-ace "n:%ds.CurrentDomain%sys-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_JOB_SYSPRIV=-ace "n:%ds.CurrentDomain%¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_SVC=-ace "n:%ds.CurrentDomain%sys-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change"
    set ACL_USER_SINGLE_PROFILE_SVC_SYSPRIV=-ace "n:%ds.CurrentDomain%¡sys-%VALUE_RESTYPE:¡=%-%input.LabelName%;p:change"

    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      set event.message="sadm res.create.%VALUE_RESTYPE%: creating resource [%input.LabelName%:%VALUE_RESPARENT%:%VALUE_RESTYPE%:%VALUE_ACLPROFILE%:%VALUE_SCOPE%]"
    ) else (
      set event.message="sadm res.create.%VALUE_RESTYPE%: [test-mode] creating resource [%input.LabelName%:%VALUE_RESPARENT%:%VALUE_RESTYPE%:%VALUE_ACLPROFILE%:%VALUE_SCOPE%]"
    )

    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      %fs.BinDir%\eventcreate /id %event.BeginId% /l application /t information /so "sadm:res.create.%VALUE_RESTYPE% [%input.LabelName%] [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      %fs.BinDir%\eventcreate /id %event.TestModeBeginId% /l application /t information /so "sadm:res.create.%VALUE_RESTYPE% [%input.LabelName%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    %sys.ColorBright%
    @echo # ========================================================================
    for /f %%i in ('%fs.BinDir%\datex') do @echo # %%i
    @echo # ------------------------------------------------------------------------
    @echo # launched by:             %USERDOMAIN%\%USERNAME%
    @echo # ------------------------------------------------------------------------
    %sys.ColorNormal%
    @echo # resource label:          "%input.LabelName%"
    @echo # resource parent:         "%VALUE_RESPARENT%"
    @echo # resource type:           %VALUE_RESTYPE%
    @echo # acl profile:             %VALUE_ACLPROFILE%
    @echo # scope:                   %VALUE_SCOPE%
    @echo # operation mode:          %VALUE_OPMODE%
    @echo # alert mode:              %VALUE_ALERTMODE%
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


    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      if /i %ContextStage.SkipGroupCreation% EQU %STATUS_OFF% (
        call %fs.ModulesDir%\rescreate.CreateGroups.cmd
      )
    ) else (
      call %fs.ModulesDir%\rescreate.QueryGroups.cmd
    )


    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      if /i %ContextStage.SkipTargetFolderCreation% EQU %STATUS_OFF% (
        call %fs.ModulesDir%\rescreate.CreateFolders.cmd
      )
    ) else (
      call %fs.ModulesDir%\rescreate.QueryFolders.cmd
    )


    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      if /i %ContextStage.SkipSecurityConfig% EQU %STATUS_OFF% (
        call %fs.ModulesDir%\rescreate.ApplySecurity.cmd
      )
    ) else (
      call %fs.ModulesDir%\rescreate.QuerySecurity.cmd
    )


    if exist %fs.TmpDir%\%SET_LOGFILE:.log=.exit% (
      %sys.ColorRed%

      @echo.
      @echo # ERROR: unexpected operation error.
      @echo.

      %sys.ColorNormal%

      set event.message="sadm res.create.%VALUE_RESTYPE%: unexpected operation error. [%fs.LogsDir%\%SET_LOGFILE%]"
      %fs.BinDir%\eventcreate /id %event.id% /l application /t error /so "sadm:res.create.%VALUE_RESTYPE% [%input.LabelName%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    goto EXIT


    :HELP

      @echo.
      @echo   OpenADM version 3.5.1.0b2, Copyright (C) 2006 Carlos Veira Lorenzo
      @echo   OpenADM comes with ABSOLUTELY NO WARRANTY. This is free software
      @echo   under GPL 2.0 license terms and conditions.
      @echo.
      @echo   sadm resource -cmd:create
      @echo     [res-label]
      @echo     [-p:{none^|"name"^|"full-path-name"}]
      @echo     [-type:[¡]{org^|role^|svc^|job^|fs^|web^|ftp^|ts^|reg^|scm^|db^|prn^|vcs^|ur^|dr^|
      @echo                ras^|vpn^|fw^|mail^|chat^|vmm^|dcom^|arole^|elog^|hw}]
      @echo     [-acl:{single^|bit^|default^|default-inherit^|full^|full-inherit}]
      @echo     [-scope:{local^|ntdomain^|addomain^|lgroups-only^|ntgroups-only^|adgroups-only^|
      @echo              tfolder-only^|secapply-only}]
      @echo     [-mode:{exec^|test}]
      @echo     [-a:{yes^|no}]
      @echo.
      @echo   restricted parameter matrix combination:
      @echo     -type:¡                              ^> -p:none
      @echo     -type:{org^|db^|prn^|scm^|ur^|dr^|
      @echo            ras^|vpn^|fw^|mail^|chat^|
      @echo            vmm^|dcom^|arole^|elog^|hw}   ^> -p:none
      @echo     -type:{reg}                          ^> -p:"full-path-name"
      @echo     -type:¡                              ^> -type:¡{role^|svc^|job}
      @echo     --------------------------------------------------------------------------------
      @echo     -type:¡                              ^> -acl:single
      @echo     -type:{fs^|web^|ftp^|ts^|hw}         ^> -acl:{bit^|default^|default-inherit^|
      @echo                                                   full^|full-inherit}
      @echo     -type:{org^|role^|svc^|job^|ur^|
      @echo            dr^|ras^|vpn^|fw^|chat}       ^> -acl:single
      @echo     -type:{vmm^|arole}                   ^> -acl:{default^|full}
      @echo     -type:{vcs^|mail}                    ^> -acl:{single^|default}
      @echo     -type:{reg}                          ^> -acl:{bit^|default-inherit}
      @echo     -type:{db^|prn^|scm^|dcom^|elog}     ^> -acl:{bit}
      @echo     --------------------------------------------------------------------------------
      @echo     -type:{db^|prn^|scm^|ur^|dr^|ras^|
      @echo            vpn^|fw^|mail^|chat^|vmm^|
      @echo            dcom^|arole^|elog^|hw}        ^> -scope:{lgroups-only^|ntgroups-only^|
      @echo                                                     adgroups-only}
      @echo     -type:{org}                          ^> -scope:{ntgroups-only^|adgroups-only}
      @echo     -p:none             -type:{reg}      ^> -scope:{lgroups-only^|ntgroups-only^|
      @echo                                                     adgroups-only}
      @echo     -p:"full-path-name" -type:{reg}      ^> -scope:{local^|secapply-only}
      @echo     -p:none             -type:{fs^|web^|ftp^|ts^|vcs}
      @echo                                          ^> -scope:{lgroups-only^|ntgroups-only^|
      @echo                                                     adgroups-only}
      @echo     -p:{"name"^|"full-path-name"} -type:{fs^|web^|ftp^|ts^|vcs}
      @echo                                          ^> -scope:{local^|tfolders-only^|
      @echo                                                     secapply-only}
      @echo     -p:none             -type:[¡]{role^|svc^|job}
      @echo                                          ^> -scope:{lgroups-only^|ntgroups-only^|
      @echo                                                     adgroups-only}
      @echo     -p:"full-path-name" -type:[¡]{role^|svc^|job}
      @echo                                          ^> -scope:{local^|tfolders-only^|
      @echo                                                     secapply-only}
      @echo     --------------------------------------------------------------------------------
      @echo     -type:[¡]{svc}                       ^> reslabel = {db*^|web*^|ftp*^|vcs*^|*}
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
      set event.message="sadm res.create.%VALUE_RESTYPE%: resource [%input.LabelName%:%VALUE_RESPARENT%:%VALUE_RESTYPE%:%VALUE_ACLPROFILE%:%VALUE_SCOPE%] created"
    ) else (
      set event.message="sadm res.create.%VALUE_RESTYPE%: [test-mode] resource [%input.LabelName%:%VALUE_RESPARENT%:%VALUE_RESTYPE%:%VALUE_ACLPROFILE%:%VALUE_SCOPE%] created"
    )

    if /i %VALUE_OPMODE% NEQ %VALUE_OPMODE_TEST% (
      %fs.BinDir%\eventcreate /id %event.EndId% /l application /t information /so "sadm:res.create.%VALUE_RESTYPE% [%input.LabelName%] [%SET_SSNSEQ%]" /d !event.message! > nul
    ) else (
      %fs.BinDir%\eventcreate /id %event.TestModeEndId% /l application /t information /so "sadm:res.create.%VALUE_RESTYPE% [%input.LabelName%] [%SET_SSNSEQ%]" /d !event.message! > nul
    )


    if /i %VALUE_ALERTMODE% EQU %STATUS_YES% call %fs.SysOpDir%\alert.cmd rescreate -l:%SET_LOGFILE% -trap:yes

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