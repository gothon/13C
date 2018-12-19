#Include "util.bi"

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


End Namespace
