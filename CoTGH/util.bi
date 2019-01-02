#Ifndef UTIL_BI
#Define UTIL_BI

Namespace util

Declare Function genUId() As ULongInt

Declare Function hash Naked Cdecl(x As Const ZString) As Long

Declare Function min(a As Integer, b As Integer) As Integer
Declare Function max(a As Integer, b As Integer) As Integer

Declare Function pathRelativeToAbsolute(ByRef src As Const String, ByRef rel As Const String) As String

Declare Function trimWhitespace(in As Const String) As String

Declare Function getDecodeBase64AllocationSize(encodedSize As UInteger) As UInteger

Declare Function decodeBase64(in As Const String, mem As Any Ptr) As UInteger

End Namespace

#EndIf
