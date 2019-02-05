#Ifndef UTIL_BI
#Define UTIL_BI

#Include "vec3f.bi"

Namespace util

Declare Function genUId() As ULongInt

Declare Function hash Naked Cdecl(x As Const ZString) As Long

#Ifdef MIN
#Undef MIN
#EndIf

#Ifdef MAX
#Undef MAX
#EndIf

Declare Function min(a As Integer, b As Integer) As Integer
Declare Function max(a As Integer, b As Integer) As Integer

Declare Function pathRelativeToAbsolute(ByRef src As Const String, ByRef rel As Const String) As String

Declare Function trimWhitespace(in As Const String) As String

Declare Sub decodeBase64(in As Const String, mem As Any Ptr)

Declare Function cloneZString(in As Const ZString Ptr) As ZString Ptr

Declare Sub clamp(x As Vec3F Ptr, min_ As Single, max_ As Single)

End Namespace

#EndIf
