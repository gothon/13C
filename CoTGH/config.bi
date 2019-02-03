#Ifndef CONFIG_BI
#Define CONFIG_BI

Const As String CONFIG_FILE_NAME = "config.txt"

Type Config
 Public:
 	Declare Constructor(ByRef fileName As Const String = CONFIG_FILE_NAME)
	
	Declare Const Function getEntryPoint() ByRef As Const String
	
 Private:
 	As String entryPoint_
End Type

#EndIf
