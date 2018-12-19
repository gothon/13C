#Ifndef UTIL_BI
#Define UTIL_BI

Namespace util

Declare Function genUId() As ULongInt

Declare Function hash Naked Cdecl(x As Const ZString) As Long

Declare Function min(a As Integer, b As Integer) As Integer
Declare Function max(a As Integer, b As Integer) As Integer

End Namespace

#EndIf
