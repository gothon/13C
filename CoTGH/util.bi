#Ifndef UTIL_BI
#Define UTIL_BI

Namespace util

Declare Function genUId() As ULongInt

Declare Function hash Naked Cdecl(x As Const ZString) As Long
  
End Function
End Namespace

#EndIf
