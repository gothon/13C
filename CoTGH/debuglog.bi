#Ifndef DEBUGLOG_BI
#Define DEBUGLOG_BI

#Include "debug.bi"

#Ifdef DEBUG
#define DEBUG_LINE_ID "[" &__FILE__& "::" &__FUNCTION__& "(" & __LINE__ & ")] "
#EndIf

#Macro DEBUG_LOG(_X_)
#Ifdef DEBUG
DebugLog.log(DEBUG_LINE_ID & (_X_))
#EndIf
#EndMacro

#Macro DEBUG_ASSERT_WITH_MESSAGE(_C_, _X_)
#Ifdef DEBUG
If Not (_C_) Then 
  DebugLog.fatal("ASSERT FAILED (" & #_C_ & ") " & DEBUG_LINE_ID & (_X_))
End If
#EndIf
#EndMacro

#Macro DEBUG_ASSERT(_C_)
#Ifdef DEBUG
If Not (_C_) Then 
  DebugLog.fatal("ASSERT FAILED (" & #_C_ & ") " & DEBUG_LINE_ID)
End If
#EndIf
#EndMacro

#Ifdef DEBUG
Type DebugLogInitializationObject
 Public:
  Declare Constructor(debuglogConstruct As Sub(), debuglogDestruct As Sub())
  Declare Destructor()
 Private:
  As Sub() debuglogDestruct
End Type

Type DebugLog
 Public:
  Declare Static Sub setSilent(is_silent As Boolean)
  Declare Static Sub log(text As String)
  Declare Static Sub fatal(text As String)
 Protected:
  Declare Constructor()
  Declare Static Sub construct()
  Declare Static Sub destruct()
 Private:
  Static As DebugLogInitializationObject initializationObject
  Static As Boolean isSilent
  Static As UInteger fileHandle
      
  Declare Static Sub crash(err_text As String)

  As Integer _placeholder_
End Type
#EndIf

#EndIf
