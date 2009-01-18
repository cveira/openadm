:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/ACL_SYSTEM_PROFILE/ACL_LOCAL_SYSTEM_PROFILE/g" %i
:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/ACL_AUDIT_SYSTEM/ACL_LOCAL_AUDIT_SYSTEM/g" %i

:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/"n:/^"n:^%COMPUTERNAME^%\\/g" %i
:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/"n:/^"n:^%ds.domain^%\\/g" %i

:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/COMPUTERNAME/ds.domain/g" %i
:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/ACL_LOCAL_SYSTEM_PROFILE/ACL_DOMAIN_SYSTEM_PROFILE/g" %i
:: for /r . %i in (*.cmd) do C:\openadm\bin\system\sed.exe -i -T "s/ACL_LOCAL_AUDIT_SYSTEM/ACL_DOMAIN_AUDIT_SYSTEM/g" %i

C:\openadm\bin\system\RSaR.exe *.cmd "\%sid." /s /i
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds." /s /i
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.system\%" /s /i /r="%sid.system%"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.service\%" /s /i /r="%sid.service%"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.NetworkService\%" /s /i /r="%sid.NetworkService%"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.CreatorOwner\%" /s /i /r="%sid.CreatorOwner%"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.AuthUsers\%" /s /i /r="%sid.AuthUsers%"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid.administrators\%" /s /i /r="%sid.administrators%"

C:\openadm\bin\system\RSaR.exe *.cmd "\%COMPUTERNAME\%\\\%sid" /s /i /r="%sid"
C:\openadm\bin\system\RSaR.exe *.cmd "\%ds.domain\%\\\%sid" /s /i /r="%sid"
C:\openadm\bin\system\RSaR.exe *.cmd "\\role-svc-mail" /s /i /r="\¡role-svc-mail"
C:\openadm\bin\system\RSaR.exe *.cmd "\\sys-svc-mail" /s /i /r="\¡sys-svc-mail"

:: Domain Members and Sand-alone Computers
C:\openadm\bin\system\RSaR.exe *.cmd "ds.domain" /s /i /r="COMPUTERNAME"
:: C:\openadm\bin\system\RSaR.exe *.cmd "ace n:" /s /i /r="ace \"n:"
C:\openadm\bin\system\RSaR.exe *.cmd "ACL_DOMAIN_SYSTEM_PROFILE" /s /i /r="ACL_LOCAL_SYSTEM_PROFILE"
C:\openadm\bin\system\RSaR.exe *.cmd "ACL_DOMAIN_AUDIT_SYSTEM" /s /i /r="ACL_LOCAL_AUDIT_SYSTEM"


:: Domain Controllers
C:\openadm\bin\system\RSaR.exe *.cmd "COMPUTERNAME" /s /i /r="ds.domain"
C:\openadm\bin\system\RSaR.exe *.cmd "ACL_LOCAL_SYSTEM_PROFILE" /s /i /r="ACL_DOMAIN_SYSTEM_PROFILE"
C:\openadm\bin\system\RSaR.exe *.cmd "ACL_LOCAL_AUDIT_SYSTEM" /s /i /r="ACL_DOMAIN_AUDIT_SYSTEM"

C:\openadm\bin\system\RSaR.exe *.cmd "role-job" /s /i /r="sys-job"
C:\openadm\bin\system\RSaR.exe *.cmd "role-svc" /s /i /r="sys-svc"
C:\openadm\bin\system\RSaR.exe *.cmd "role-" /s /i

C:\openadm\bin\system\RSaR.exe *.cmd "C:\\Documents and Settings" /s /i
C:\openadm\bin\system\RSaR.exe *.ini "C:\\Documents and Settings" /s /i

C:\openadm\bin\system\RSaR.exe *.cmd "logs\\preporter" /s /i /r="logs\net\preporter"
C:\openadm\bin\system\RSaR.exe *.cmd "logs\\mail" /s /i /r="logs\services\mail"



C:\openadm\bin\system\RSaR.exe *.cmd "if /i %1 EQU MAIN" /s /i  /r="if %1 EQU MAIN"
C:\openadm\bin\system\RSaR.exe *.inf "clearpagefileatshutdown=4,1" /s /i /r="clearpagefileatshutdown=4,0"



C:\openadm\bin\system\RSaR.exe *.cmd "\%fs.ModulesDir\%\\\%icctl.profile\%" /s /i /r="%fs.ModulesDir%\icctl\%icctl.profile%"



C:\openadm\bin\system\RSaR.exe *.cmd "\%errorlevel\% NEQ \%EL_SETACL_OK\%" /s /i /r="{!errorlevel!} NEQ {%EL_SETACL_OK%}"

C:\openadm\bin\system\RSaR.exe *.cmd "grant=system=f /grant=builtin\\administrators=f" /s /i /r="revoke=system /revoke=builtin\\administrators"
C:\openadm\bin\system\RSaR.exe *.cmd "p:full" /s /i /r="p:full;m:revoke"

c:\openadm\bin\system\RSaR.exe *.inf "¡res-fs-system__Members =" /s /i /r="¡res-fs-system__Members = ¡job-security,¡job-system,¡job-disk,¡job-backup"
c:\openadm\bin\system\RSaR.exe *.inf "¡res-fs-system__Members =" /s /i /r="¡res-fs-system__Members = ¡sys-job-security,¡sys-job-system,¡sys-job-disk,¡sys-job-backup"
c:\openadm\bin\system\RSaR.exe *.inf "¡res-fs-system__Members = E-MOTIONS\\¡res-fs-system" /s /i /r="¡res-fs-system__Members = ¡job-security,¡job-system,¡job-disk,¡job-backup,E-MOTIONS\¡res-fs-system"

c:\openadm\bin\system\RSaR.exe *.inf "machine\\system\\currentcontrolset\\services\\netlogon\\parameters\\maximumpasswordage=4,30" /s /i /r=";machine\system\currentcontrolset\services\netlogon\parameters\maximumpasswordage=4,30"
c:\openadm\bin\system\RSaR.exe *.inf "maximumpasswordage=4,30" /s /i /r="maximumpasswordage=4,90"


:: Version
C:\openadm\bin\system\RSaR.exe *.cmd "cveira \[at\] xlnetworks.net" /s /i /r="cveira [at] thinkinbig.org"
C:\openadm\bin\system\RSaR.exe *.cmd "@rem   http://www.deepzone.org/\n" /s /i /r=""
C:\openadm\bin\system\RSaR.exe *.cmd "openitc.org" /s /i /r="thinkinbig.org"
C:\openadm\bin\system\RSaR.exe *.cmd "3.5.1.0b2 alpha" /s /i /r="3.5.1.0b2-20090118-0"
C:\openadm\bin\system\RSaR.exe *.cmd "3.5.0.0" /s /i /r="3.5.1.0b2"
C:\openadm\bin\system\RSaR.exe *.cmd "2006/09/01" /s /i /r="2009/01/18"


