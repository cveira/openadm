' -----------------------------------------------------------------------------
' authtor: Carlos Veira Lorenzo - cveira@dotpi.com
' date:    2005/04/07
' version: 1.0
' -----------------------------------------------------------------------------
' Usage: elsave.vbs <app|sec|sys|sim|ds|frs|dns>"
' -----------------------------------------------------------------------------
' object dependencies:
'   WScript
'
' WMI provider dependencies:
'   Win32_NTEventLogFile
' -----------------------------------------------------------------------------


Option Explicit


' -----------------------------------------------------------------------------
Const WMI_TARGET               = "//./root/cimv2"
Const WMI_CONNECTION_LOCALE    = "[locale=ms_409]"                     ' american english

Const WMI_SEC_IMPERSONATION    = "impersonationLevel=impersonate"      ' [impersonate|delegate]
Const WMI_SEC_PRIVS            = "(backup)"                            ' ([!]backup, [!]debug, [!]security, [!]shutdown)
'Const WMI_SEC_AUTHLEVEL        = "authenticationLevel=pktPrivacy"
'Const WMI_SEC_AUTHORITY        = "authority=kerberos:mydomain\server"
'Const WMI_SEC_AUTHORITY        = "authority=ntlmdomain:mydomain"

Const WMI_WQL_QUERY            = "SELECT * FROM Win32_NTEventLogFile WHERE LogFileName='"

Const EL_NAME_APP              = "Application"
Const EL_NAME_SEC              = "Security"
Const EL_NAME_SYS              = "System"
Const EL_NAME_SIM              = "GFI LANguard System Integrity Monitor 3"
Const EL_NAME_DS               = "Directory Service"
Const EL_NAME_FRS              = "File Replication Service"
Const EL_NAME_DNS              = "DNS Server"

Const SAVE_APP                 = "app"
Const SAVE_SEC                 = "sec"
Const SAVE_SYS                 = "sys"
Const SAVE_SIM                 = "sim"
Const SAVE_DS                  = "ds"
Const SAVE_FRS                 = "frs"
Const SAVE_DNS                 = "dns"

Const EL_PATH                  = "e:\logs\eventlog"
Const EL_EXT                   = ".evt"

Const ERROR_CMDLINE            = 10
Const ERROR_RUNTIME            = 1
Const ERROR_OK                 = 0

Const ELOG_SUCCESS             = 0
Const ELOG_ERROR               = 1
Const ELOG_WARNING             = 2
Const ELOG_INFORMATION         = 4
Const ELOG_AUDIT_SUCCESS       = 8
Const ELOG_AUDIT_FAILURE       = 16

Dim   strWMISecContext
Dim   strWMIConnection

Dim   strPath, strLogFile
Dim   strDate
Dim   strMonth, strDay, strHour, strMinute, strSeconds

'strWMISecContext  = "{" & WMI_SEC_IMPERSONATION & ", " & WMI_SEC_AUTHLEVEL & ", " & WMI_SEC_AUTHORITY & ", " & WMI_SEC_PRIVS & "}"
strWMISecContext  = "{" & WMI_SEC_IMPERSONATION & ", " & WMI_SEC_PRIVS & "}"
strWMIConnection  = "winmgmts:" & strWMISecContext & WMI_CONNECTION_LOCALE & "!" & WMI_TARGET


strMonth   = Month(Now)
If strMonth < 10 Then strMonth = "0" & strMonth

strDay     = Day(Now)
If strDay < 10 Then strDay = "0" & strDay

strHour    = Hour(Now)
If strHour < 10 Then strHour = "0" & strHour

strMinute  = Minute(Now)
If strMinute < 10 Then strMinute = "0" & strMinute

strSeconds = Second(Now)
If strSeconds < 10 Then strSeconds = "0" & strSeconds

strDate    = Year(Now) & strMonth & strDay & "-" & strHour & strMinute & strSeconds


' -----------------------------------------------------------------------------
Sub displayHelpMessage()
  WScript.Echo
  WScript.Echo "  Usage: elsave.vbs <app|sec|sys|sim|ds|frs|dns>"
  WScript.Echo
End Sub



' -----------------------------------------------------------------------------
Sub eventCreate(intEvtType, strMsg)
  Dim objShell

  Set objShell = Wscript.CreateObject("Wscript.Shell")

  objShell.LogEvent intEvtType, strMsg

  Set objShell = nothing
End Sub



' -----------------------------------------------------------------------------
Sub saveELog(strLogFile, strLogName)
  Dim colLogFiles, objLogfile
  Dim errBackupLog

  Set colLogFiles = GetObject(strWMIConnection).ExecQuery(WMI_WQL_QUERY & strLogName & "'")

  For Each objLogfile in colLogFiles
     errBackupLog = objLogFile.BackupEventLog(strLogFile)

     If errBackupLog <> 0 Then
          Wscript.Echo "elsave: the " &  strLogName & " event log could not be backed up."
          eventCreate ELOG_ERROR, "elsave: the " &  strLogName & " event log could not be backed up."

          WScript.Quit (ERROR_RUNTIME)
      Else
          objLogFile.ClearEventLog()
      End If
  Next

  Set colLogFiles = nothing
  Set objLogfile  = nothing
End Sub


' -----------------------------------------------------------------------------
Sub Main
  Dim objCmdLine
  Dim strELog

  Set objCmdLine = WScript.Arguments
  If objCmdLine.Count <> 1 Then
    displayHelpMessage
    WScript.Quit (ERROR_CMDLINE)
  End If

  strELog = LCase(objCmdLine.Item(0))

  Select Case strELog
    case SAVE_APP
      strLogFile = EL_PATH & "\" & SAVE_APP & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_APP

    case SAVE_SEC
      strLogFile = EL_PATH & "\" & SAVE_SEC & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_SEC

    case SAVE_SYS
      strLogFile = EL_PATH & "\" & SAVE_SYS & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_SYS

    case SAVE_SIM
      strLogFile = EL_PATH & "\" & SAVE_SIM & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_SIM

    case SAVE_DS
      strLogFile = EL_PATH & "\" & SAVE_DS & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_DS

    case SAVE_FRS
      strLogFile = EL_PATH & "\" & SAVE_FRS & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_FRS

    case SAVE_DNS
      strLogFile = EL_PATH & "\" & SAVE_DNS & "-" & strDate & EL_EXT
      saveELog strLogFile, EL_NAME_DNS

    Case Else
      displayHelpMessage
      WScript.Quit (ERROR_CMDLINE)
  End Select

  Set objCmdLine   = nothing
End Sub


Main

WScript.Quit (ERROR_OK)