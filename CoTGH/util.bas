#Include "util.bi"

#Include "debuglog.bi"

Namespace util
  
Function genUId() As ULongInt
  Return CLngInt(Rnd*CDbl(CUInt(&hffffffff))) Or (CLngInt(Rnd*CDbl(CUInt(&hffffffff))) Shl 32)
End Function

Function hash Naked Cdecl(x As Const ZString) As Long
  Asm
  #Ifdef __FB_64BIT__
    push    rbx
    mov     rax,                    14695981039346656037
    mov     rcx,                    1099511628211
    mov     rbx,                    dword ptr [esp+24]
util_hash_string_loopstart_64:
    mov     dl,                     byte ptr [rbx]
    or      dl,                     dl
    jz      util_hash_return_64
    xor     al,                     dl         
    mul     rcx
    inc     rbx
    jmp     util_hash_string_loopstart_64
util_hash_return_64:
    pop     rbx         
    ret
  #Else   
    push    ebx
    mov     eax,                    2166136261
    mov     ecx,                    16777619
    mov     ebx,                    dword ptr [esp+12]
util_hash_string_loopstart_32:
    mov     dl,                     byte ptr [ebx]
    or      dl,                     dl
    jz      util_hash_return_32
    xor     al,                     dl
    mul     ecx
    inc     ebx
    jmp     util_hash_string_loopstart_32
util_hash_return_32:
    pop     ebx
    ret
  #EndIf   
  End asm       
End Function

Function min(a As Integer, b As Integer) As Integer
	Return IIf(a <= b, a, b)
End Function

Function max(a As Integer, b As Integer) As Integer
	Return IIf(a >= b, a, b)
End Function

Function pathRelativeToAbsolute(ByRef src As Const String, ByRef rel As Const String) As String
	Return Left(src, InStrRev(src, "/")) & rel
End Function

Const As String WHITESPACE_SET = !" \t\n\v\f\r" 
 
Function trimWhitespace(in As Const String) As String
	Return Trim(in, Any WHITESPACE_SET)
End Function

Dim As UInteger ASCII_TABLE(0 To 255) = { _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 62,  0,  0,  0, 63, _
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61,  0,  0,  0,  0,  0,  0, _
   0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, _
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,  0,  0,  0,  0,  0, _
   0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, _
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, _
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}

Const As UByte EQUALS_CHAR = 61 '=

Sub decodeBase64(in As Const String, mem As Any Ptr)
	DEBUG_ASSERT((Len(in) And 3) = 0)
	If Len(in) = 0 Then Return
	
	Dim As Const UByte Ptr src = StrPtr(in)
	Dim As Const UByte Ptr endPtr = src + Len(in)
  
  Dim As UInteger bytes = Any
 	Do
		Dim As UInteger lookup1 = ASCII_TABLE(src[1])
		Dim As UInteger lookup2 = ASCII_TABLE(src[2])
		
		bytes = _
				((ASCII_TABLE(src[0]) Shl 2) Or (lookup1 Shr 4)) Or _
				(((lookup1 And &h0f) Shl 12) Or ((lookup2 Shr 2) Shl 8)) Or _
				(((lookup2 And &h03) Shl 22) Or (ASCII_TABLE(src[3]) Shl 16))

		mem += 3
		src += 4
		
		If src >= endPtr Then Exit Do
		*CPtr(UInteger Ptr, mem - 3) = bytes
 	Loop
 	mem -= 3
 	
  If *(endPtr - 1) = EQUALS_CHAR Then
    If *(endPtr - 2) = EQUALS_CHAR Then
    	*CPtr(UByte Ptr, mem) = bytes
	  Else
	  	*CPtr(UShort Ptr, mem) = bytes
    EndIf
  Else
	  *CPtr(UShort Ptr, mem) = bytes
	  *CPtr(UByte Ptr, mem + 2) = bytes Shr 16
  EndIf
End Sub

End Namespace
