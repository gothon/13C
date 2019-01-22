#Include "debuglog.bi"
#Include "char.bi"
#Include "null.bi"
#Include "crt.bi"

#Ifdef DEBUG

Const As String VERSION = "1.0"
Const As String FILENAME = "debug.log"

Type DebugLogAccessor Extends DebugLog
 Public:
  Declare Static Sub construct_()
  Declare Static Sub destruct_()
 Private:
  As Integer _placeholder_
End Type
Sub DebugLogAccessor.construct_()
  construct()
End Sub
Sub DebugLogAccessor.destruct_()
  destruct()
End Sub
Constructor DebugLogInitializationObject(debuglogConstruct As Sub(), debuglogDestruct As Sub())
  debuglogConstruct()
  This.debuglogDestruct = debuglogDestruct
End Constructor
Destructor DebugLogInitializationObject()
  debuglogDestruct()
End Destructor
Dim As DebugLogInitializationObject DebugLog.initializationObject = _
    DebugLogInitializationObject(@DebugLogAccessor.construct_, _ 
                                 @DebugLogAccessor.destruct_)

Dim As Boolean DebugLog.isSilent
Dim As UInteger DebugLog.fileHandle

Sub DebugLog.crash(err_text As String)
  Print "Unrecoverable DebugLog Error: " + err_text
  Print "Exiting program."
  sleep
  End(1)
End Sub

Sub DebugLog.construct()
  isSilent = FALSE
  Kill FILENAME 
  fileHandle = FreeFile
  If Open(FILENAME For Binary As #fileHandle) <> NULL Then
    crash("Unable to open " + FILENAME + " with code " + Str(Err) + ".")
  End If
  Print #fileHandle, "DebugLog " + VERSION
  Print #fileHandle, "Started logging at: " + Time + ", " + Date
End Sub

Sub DebugLog.destruct()
  Close #fileHandle
  Print "DebugLog successfully closed."
End Sub

Sub DebugLog.setSilent(isSilent As Boolean)
  DebugLog.isSilent = isSilent
End Sub

Sub DebugLog.log(text As String)  
	If isSilent Then Return
  #Ifdef __FB_WIN32__
    text &= !"\r\n"
  #Else
    text &= !"\n"
  #EndIf 
	If Put(#fileHandle,,text) <> NULL Then crash("Disk full.")
End Sub

Sub DebugLog.fatal(text As String)  
  log(text)
  End(1)
End Sub

#EndIf
