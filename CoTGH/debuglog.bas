#Include "debuglog.bi"
#Include "char.bi"
#Include "null.bi"
#Include "crt.bi"

#Ifdef DEBUG

Const As String VERSION = "1.0"
Const As String FILENAME = "debug.log"
Const As Integer BUFFERSIZE = 2048

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
Dim As ZString Ptr DebugLog.textBuffer(0 To 1) 
Dim As UInteger DebugLog.textBufferN(0 To 1)
Dim As Integer DebugLog.activeBuffer
Dim As Any Ptr DebugLog.writerMutex
Dim As Any Ptr DebugLog.writerCond
Dim As Any Ptr DebugLog.writerThread
Dim As Boolean DebugLog.shouldQuit
Dim As UInteger DebugLog.fileHandle

Sub DebugLog.crash(err_text As String)
  Print "Unrecoverable DebugLog Error: " + err_text
  Print "Exiting program."
  sleep
  End(1)
End Sub

Sub DebugLog.debugOutputWorker(param As Any Ptr)
  Dim As Integer writeBufferIndex
  Dim As Integer copiedLogs = 0
  Do
    MutexLock writerMutex
      If (textBufferN(activeBuffer) = 0) AndAlso (Not shouldQuit) Then CondWait(writerCond, writerMutex)
      activeBuffer = 1 - activeBuffer
      CondSignal(writerCond)
    MutexUnLock writerMutex
    
    If Not shouldQuit OrElse copiedLogs = 0 Then
      writeBufferIndex = 1 - activeBuffer
      If textBufferN(writeBufferIndex) > 0 Then
        If Put(#fileHandle,, *textBuffer(writeBufferIndex), textBufferN(writeBufferIndex)) <> NULL Then
          crash("Disk full.")
        End If
        textBufferN(writeBufferIndex) = 0
        End If
    End If
    copiedLogs += 1
  Loop While shouldQuit = FALSE
End Sub

Sub DebugLog.construct()
  isSilent = FALSE
  textBuffer(0) = Callocate(SizeOf(char) * BUFFERSIZE)
  textBuffer(1) = Callocate(SizeOf(char) * BUFFERSIZE)
  If (textBuffer(0) = NULL) OrElse (textBuffer(1) = NULL) Then
    crash("Unable to allocate memory.")
  End If
  textBufferN(0) = 0
  textBufferN(1) = 0
  activeBuffer = 0
  writerMutex = MutexCreate
  writerCond = Condcreate
  If (writerMutex = NULL) OrElse (writerCond = NULL) Then
    crash("Unable to create mutex or condition variable.")
  End If    
  writerThread = ThreadCreate(@DebugLog.debugOutputWorker)
  If (writerThread = NULL) Then
    crash("Unable to spawn new thread.")
  End If
  shouldQuit = FALSE
  Kill FILENAME 
  fileHandle = FreeFile
  If Open(FILENAME For Binary As #fileHandle) <> NULL Then
    crash("Unable to open " + FILENAME + " with code " + Str(Err) + ".")
  End If
  Print #fileHandle, "DebugLog " + VERSION
  Print #fileHandle, "Started logging at: " + Time + ", " + Date
End Sub

Sub DebugLog.destruct()
  MutexLock writerMutex
  shouldQuit = true
  MutexUnLock writerMutex
  
  Condsignal(writerCond)
  ThreadWait(writerThread)
    
  DeAllocate(textBuffer(0))
  DeAllocate(textBuffer(1))
  MutexDestroy(writerMutex)
  CondDestroy(writerCond)
  Close #fileHandle
End Sub

Sub DebugLog.setSilent(isSilent As Boolean)
  DebugLog.isSilent = isSilent
End Sub

Sub DebugLog.log(text As String)  
  #Ifdef __FB_WIN32__
    text &= !"\r\n"
  #Else
    text &= !"\n"
  #EndIf 
  
  Dim As ZString Ptr textPtr = StrPtr(text)
  Dim As UInteger totalBytes = Len(text)
  Dim As UInteger curSeek = 0
  MutexLock(writerMutex)
    Do
      Dim As UInteger bytesToWrite = BUFFERSIZE - textBufferN(activeBuffer)
      If bytesToWrite > totalBytes Then bytesToWrite = totalBytes
      
      memcpy(textBuffer(activeBuffer) + textBufferN(activeBuffer), textPtr, bytesToWrite)
      
      totalBytes -= bytesToWrite
      textBufferN(activeBuffer) += bytesToWrite
      If totalBytes > 0 Then 
        CondWait(writerCond, writerMutex)
      Else
        CondSignal(writerCond)
      End If 
    Loop While totalBytes > 0
  MutexUnLock(writerMutex)
End Sub

Sub DebugLog.fatal(text As String)  
  log(text)
  destruct()
  End(1)
End Sub

#EndIf
