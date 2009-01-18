' -----------------------------------------------------------------------------
' authtor: Carlos Veira Lorenzo - cveira@dotpi.com
' date:    2005/11/1
' version: 1.5
' -----------------------------------------------------------------------------
' Usage: rtelprotect.vbs [-d:{0|1|2|3}]
' -----------------------------------------------------------------------------
' object dependencies:
'   WScript
'
' WMI provider dependencies:
'   Win32_NTLogEvent
' -----------------------------------------------------------------------------


Option Explicit


' -----------------------------------------------------------------------------

Const WMI_TARGET               = "//./root/cimv2"
Const WMI_CONNECTION_LOCALE    = "[locale=ms_409]"                     ' american english

Const WMI_SEC_IMPERSONATION    = "impersonationLevel=impersonate"      ' [impersonate|delegate]
Const WMI_SEC_PRIVS            = "(security)"                          ' ([!]backup, [!]debug, [!]security, [!]shutdown)
'Const WMI_SEC_AUTHLEVEL        = "authenticationLevel=pktPrivacy"
'Const WMI_SEC_AUTHORITY        = "authority=kerberos:mydomain\server"
'Const WMI_SEC_AUTHORITY        = "authority=ntlmdomain:mydomain"

Const WMI_WQL_QUERYLOG         = "SELECT * FROM __InstanceDeletionEvent WHERE TargetInstance ISA 'Win32_NTLogEvent'"
Const WMI_WQL_QUERYINSTANCES   = "SELECT * FROM Win32_Process           WHERE Name = 'cscript.exe' and CommandLine like '%rtelprotect.vbs%'"

Const LOG_SEPARATOR            = "|"

Const DBG_LEVEL_0              = ":0"
Const DBG_LEVEL_1              = ":1"
Const DBG_LEVEL_2              = ":2"
Const DBG_LEVEL_3              = ":3"

Const ERROR_CMDLINE            = 10
Const ERROR_RUNTIME            = 1
Const ERROR_NOTSINGLEINSTANCE  = 2
Const ERROR_OK                 = 0

Const PARAM_DEBUG              = "-d"
Const PARAM_HELP               = "-?"

Const ELOG_SUCCESS             = 0
Const ELOG_ERROR               = 1
Const ELOG_WARNING             = 2
Const ELOG_INFORMATION         = 4
Const ELOG_AUDIT_SUCCESS       = 8
Const ELOG_AUDIT_FAILURE       = 16

Dim   strWMISecContext
Dim   strWMIConnection

'strWMISecContext               = "{" & WMI_SEC_IMPERSONATION & ", " & WMI_SEC_AUTHLEVEL & ", " & WMI_SEC_AUTHORITY & ", " & WMI_SEC_PRIVS & "}"
strWMISecContext               = "{" & WMI_SEC_IMPERSONATION & ", " & WMI_SEC_PRIVS & "}"
strWMIConnection               = "winmgmts:" & strWMISecContext & WMI_CONNECTION_LOCALE & "!" & WMI_TARGET



' -----------------------------------------------------------------------------
Sub displayHelpMessage()
  WScript.Echo
  WScript.Echo "  Usage: rtelprotect.vbs [-d:{0|1|2|3}]"
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
Function crlf2xml(strField)
  Dim strNewLine

  strNewLine = Chr(13) & Chr(10)
  crlf2xml   = replace(strField, strNewLine, "<br />")
End Function



' -----------------------------------------------------------------------------
Sub isSingleInstance()
  Dim colInstances

  Set colInstances = GetObject(strWMIConnection).ExecQuery(WMI_WQL_QUERYINSTANCES)

  If colInstances.Count > 1 Then
    eventCreate ELOG_ERROR, "rtelprotect: execution aborted. There is more than one instance runing."
    WScript.Echo "  execution aborted: there is more than one instance runing."
    WScript.Quit (ERROR_NOTSINGLEINSTANCE)
  End If

  Set colInstances = nothing
End Sub



' -----------------------------------------------------------------------------
Sub Main
  Dim objCmdLine
  Dim objCmdShell
  Dim colLogEvents, objLogEvent

  Dim isDebugMode
  Dim strDebugLevel

  Dim intDebugThreshold

  Dim intDebugCount

  Set objCmdLine = WScript.Arguments

  If (objCmdLine.Count > 1) and (objCmdLine.Count <> 2) Then
    displayHelpMessage
    WScript.Quit (ERROR_CMDLINE)
  End If


  If LCase(objCmdLine.Item(0)) = PARAM_HELP Then
    displayHelpMessage
    WScript.Quit (ERROR_OK)
  End If

  If objCmdLine.Count = 1 Then
    If Left(LCase(objCmdLine.Item(1)),2) = PARAM_DEBUG Then
      isDebugMode   = True
      strDebugLevel = replace(LCase(objCmdLine.Item(1)), PARAM_DEBUG, "")

      Select Case strDebugLevel
        Case DBG_LEVEL_0
          intDebugThreshold = DBG_THRESHOLD_0
        Case DBG_LEVEL_1
          intDebugThreshold = DBG_THRESHOLD_1
        Case DBG_LEVEL_2
          intDebugThreshold = DBG_THRESHOLD_2
        Case DBG_LEVEL_3
          intDebugThreshold = DBG_THRESHOLD_3
        Case Else
          displayHelpMessage
          WScript.Quit (ERROR_CMDLINE)
      End Select
    Else
      isDebugMode = False
    End If
  End If


  isSingleInstance

  Set colLogEvents = GetObject(strWMIConnection).ExecNotificationQuery(WMI_WQL_QUERYLOG)

  if err <> 0 then
    eventCreate ELOG_ERROR, "rtelprotect: ERROR #" & Err.Number & LOG_SEPARATOR & Err.Source & LOG_SEPARATOR & Err.Description & "#"
    WScript.Quit (ERROR_RUNTIME)
  end if

  If isDebugMode Then eventCreate ELOG_SUCCESS, "rtelprotect: waiting for events..."

  intDebugCount      = 0
  Set objCmdShell    = WScript.CreateObject("WScript.Shell")

  Do
    set objLogEvent  = colLogEvents.NextEvent

    intDebugCount    = intDebugCount + 1

    If isDebugMode and (intDebugCount > intDebugThreshold) Then
      eventCreate ELOG_SUCCESS, "rtelprotect: " & DBG_STILLALIVE_THRESHOLD & " events collected in real time"
      intDebugCount = 0
    End If

    if err <> 0 then
      eventCreate ELOG_ERROR, "rtelprotect: ERROR #" & Err.Number & LOG_SEPARATOR & Err.Source & LOG_SEPARATOR & Err.Description & "#"
      WScript.Quit (ERROR_RUNTIME)
    else
      WScript.Echo objLogEvent.TargetInstance.LogFile                & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.RecordNumber)     & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.TimeGenerated)    & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.TimeWritten)      & LOG_SEPARATOR & _
                   objLogEvent.TargetInstance.SourceName             & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.EventType)        & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.EventIdentifier)  & LOG_SEPARATOR & _
                   CStr(objLogEvent.TargetInstance.EventCode)        & LOG_SEPARATOR & _
                   objLogEvent.TargetInstance.User                   & LOG_SEPARATOR & _
                   objLogEvent.TargetInstance.Category               & LOG_SEPARATOR & _
                   objLogEvent.TargetInstance.CategoryString         & LOG_SEPARATOR & _
                   objLogEvent.TargetInstance.ComputerName           & LOG_SEPARATOR & _
                   crlf2xml(objLogEvent.TargetInstance.Message)
    end if
  Loop

  If isDebugMode Then eventCreate ELOG_SUCCESS, "rtelprotect: finished"

  Set colLogEvents = nothing
  Set objCmdShell  = nothing
  Set objCmdLine   = nothing
End Sub

Main

WScript.Quit (ERROR_OK)