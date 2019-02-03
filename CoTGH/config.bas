#Include "config.bi"

#Include "debuglog.bi"

Constructor Config(ByRef fileName As Const String)
	Dim As Integer f = FreeFile
	Dim As Integer configOpenSuccess = Open("config.txt" For Input As #f)
	DEBUG_ASSERT(configOpenSuccess = 0)
	
	Dim As String key
	Dim As String value
	
	While Not Eof(f)
		Input #f, key, value
		key = UCase(Trim(key))
		value = UCase(Trim(value))
		
		If key = "ENTRYPOINT" Then entryPoint_ = value	
	
	Wend
	
	Close #f
End Constructor

Const Function Config.getEntryPoint() ByRef As Const String
	Return entryPoint_
End Function	