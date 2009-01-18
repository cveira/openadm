' -----------------------------------------------------------------------------
' authtor: Carlos Veira Lorenzo - cveira@dotpi.com
' date:    2005/11/1
' version: 1.5
' -----------------------------------------------------------------------------
' Usage: rtelcollect.vbs <-?|-na|-a:{w|sw|s|hus|vhus|ss|vss}> [-d:{0|1|2|3}]
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

Const WMI_WQL_QUERYLOG         = "SELECT * FROM __InstanceCreationEvent WHERE TargetInstance ISA 'Win32_NTLogEvent'"
Const WMI_WQL_QUERYINSTANCES   = "SELECT * FROM Win32_Process           WHERE Name = 'cscript.exe' and CommandLine like '%rtelcollect.vbs%'"

Const LOG_SEPARATOR            = "|"

Const DBG_LEVEL_0              = ":0"
Const DBG_LEVEL_1              = ":1"
Const DBG_LEVEL_2              = ":2"
Const DBG_LEVEL_3              = ":3"

Const DBG_THRESHOLD_0          = 5
Const DBG_THRESHOLD_1          = 10
Const DBG_THRESHOLD_2          = 25
Const DBG_THRESHOLD_3          = 50

Const SEC_AUDITPROFILE_W       = ":w"     ' workstation profile
Const SEC_AUDITPROFILE_SW      = ":sw"    ' secure workstation profile
Const SEC_AUDITPROFILE_S       = ":s"     ' server profile
Const SEC_AUDITPROFILE_HUS     = ":hus"   ' heavily used server profile
Const SEC_AUDITPROFILE_VHUS    = ":vhus"  ' very heavily used server profile
Const SEC_AUDITPROFILE_SS      = ":ss"    ' secure server profile
Const SEC_AUDITPROFILE_VSS     = ":vss"   ' very secure server profile

Const SEC_THRESHOLD_W          = 10       ' workstation profile
Const SEC_THRESHOLD_SW         = 5        ' secure workstation profile
Const SEC_THRESHOLD_S          = 250      ' server profile
Const SEC_THRESHOLD_HUS        = 500      ' heavily used server profile
Const SEC_THRESHOLD_VHUS       = 1000     ' very heavily used server profile
Const SEC_THRESHOLD_SS         = 50       ' secure server profile
Const SEC_THRESHOLD_VSS        = 25       ' very secure server profile

Const SYS_AUDIT_THRESHOLD      = 250

Const SEC_AUDIT_LAUNCH         = "c:\openadm\actions\operations\scan.cmd el.sec -profile:all   -range:day -a:yes -d:no"
Const SYS_AUDIT_LAUNCH         = "c:\openadm\actions\operations\scan.cmd el.sys -profile:mhost -range:day -a:yes -d:no"

Const ERROR_CMDLINE            = 10
Const ERROR_RUNTIME            = 1
Const ERROR_NOTSINGLEINSTANCE  = 2
Const ERROR_OK                 = 0

Const PARAM_DEBUG              = "-d"
Const PARAM_AUDIT_ON           = "-a"
Const PARAM_AUDIT_OFF          = "-na"
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
  WScript.Echo "  Usage: rtelcollect.vbs <-?|-na|-a:{w|sw|s|hus|vhus|ss|vss}> [-d:{0|1|2|3}]"
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
    eventCreate ELOG_ERROR, "rtelcollect: execution aborted. There is more than one instance runing."
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
  Dim isAuditMode

  Dim strDebugLevel
  Dim strAuditProfile

  Dim intDebugThreshold
  Dim intAuditThreshold

  Dim intDebugCount
  Dim intSecAuditCount
  Dim intSysAuditCount

  Set objCmdLine = WScript.Arguments

  If (objCmdLine.Count <> 1) and (objCmdLine.Count <> 2) Then
    displayHelpMessage
    WScript.Quit (ERROR_CMDLINE)
  End If


  If LCase(objCmdLine.Item(0)) = PARAM_HELP Then
    displayHelpMessage
    WScript.Quit (ERROR_OK)
  End If

  If Left(LCase(objCmdLine.Item(0)),2) = PARAM_AUDIT_ON Then
    isAuditMode     = True
    strAuditProfile = replace(LCase(objCmdLine.Item(0)), PARAM_AUDIT_ON, "")

    Select Case strAuditProfile
      Case SEC_AUDITPROFILE_W
        intAuditThreshold = SEC_THRESHOLD_W
      Case SEC_AUDITPROFILE_SW
        intAuditThreshold = SEC_THRESHOLD_SW
      Case SEC_AUDITPROFILE_S
        intAuditThreshold = SEC_THRESHOLD_S
      Case SEC_AUDITPROFILE_HUS
        intAuditThreshold = SEC_THRESHOLD_HUS
      Case SEC_AUDITPROFILE_VHUS
        intAuditThreshold = SEC_THRESHOLD_VHUS
      Case SEC_AUDITPROFILE_SS
        intAuditThreshold = SEC_THRESHOLD_SS
      Case SEC_AUDITPROFILE_VSS
        intAuditThreshold = SEC_THRESHOLD_VSS
      Case Else
        displayHelpMessage
        WScript.Quit (ERROR_CMDLINE)
    End Select
  Else
    isAuditMode = False
  End If

  If objCmdLine.Count = 2 Then
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
    eventCreate ELOG_ERROR, "rtelcollect: ERROR #" & Err.Number & LOG_SEPARATOR & Err.Source & LOG_SEPARATOR & Err.Description & "#"
    WScript.Quit (ERROR_RUNTIME)
  end if

  If isDebugMode Then eventCreate ELOG_SUCCESS, "rtelcollect: waiting for events..."

  intDebugCount      = 0
  intSecAuditCount   = 0
  intSysAuditCount   = 0
  Set objCmdShell    = WScript.CreateObject("WScript.Shell")

  Do
    set objLogEvent  = colLogEvents.NextEvent

    intDebugCount    = intDebugCount    + 1
    intSecAuditCount = intSecAuditCount + 1
    intSysAuditCount = intSysAuditCount + 1

    If isAuditMode and (intSecAuditCount > intAuditThreshold) Then
      ' asyncronous audit execution
      objCmdShell.Run SEC_AUDIT_LAUNCH, 0, False
      intSecAuditCount = 0
    End If

    If isAuditMode and (intSecAuditCount > SYS_AUDIT_THRESHOLD) Then
      ' asyncronous audit execution
      objCmdShell.Run SYS_AUDIT_LAUNCH, 0, False
      intSysAuditCount = 0
    End If

    If isDebugMode and (intDebugCount > intDebugThreshold) Then
      eventCreate ELOG_SUCCESS, "rtelcollect: " & DBG_STILLALIVE_THRESHOLD & " events collected in real time"
      intDebugCount = 0
    End If

    if err <> 0 then
      eventCreate ELOG_ERROR, "rtelcollect: ERROR #" & Err.Number & LOG_SEPARATOR & Err.Source & LOG_SEPARATOR & Err.Description & "#"
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

  If isDebugMode Then eventCreate ELOG_SUCCESS, "rtelcollect: finished"

  Set colLogEvents = nothing
  Set objCmdShell  = nothing
  Set objCmdLine   = nothing
End Sub

Main

WScript.Quit (ERROR_OK)