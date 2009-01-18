
C:\openadm\actions\install\copy2bin.cmd     -id:main  -mode:exec
C:\openadm\actions\install\sac2bin.cmd      -id:main  -mode:exec
C:\openadm\actions\install\sac2modules.cmd  -id:main  -mode:exec

C:\openadm\actions\operations\mirror.cmd    http.get download.sysinternals.com  c:\openadm\tmp  -id:sysinternals  -p:no  -a:no
C:\openadm\actions\operations\mirror.cmd    http.get www.joeware.net            c:\openadm\tmp  -id:joeware       -p:no  -a:no

C:\openadm\bin\system\unzip.exe             -jo C:\openadm\tmp\*.zip -d C:\openadm\tmp

C:\openadm\actions\install\copy2bin.cmd     -id:downloaded -mode:exec

C:\openadm\actions\operations\clean.cmd     folder C:\openadm\tmp -id:openadm.tmp -mode:dir -a:no