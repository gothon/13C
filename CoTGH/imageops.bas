#Include "imageops.bi"
#Include "pixel32.bi"
#Include "debuglog.bi"

Namespace imageops
  
Sub sync2X(ByRef src As Const Image32)
  Dim As Integer scnW
  Dim As Integer scnH
  Dim As Integer pixelBits
  ScreenInfo scnW, scnH, pixelBits
  
  DEBUG_ASSERT(src.w() Mod 16 = 0)
  DEBUG_ASSERT(src.w()*2 = scnW) 
  DEBUG_ASSERT(src.h()*2 = scnH) 
  DEBUG_ASSERT(pixelBits = 32)
 
  Dim As Const Pixel32 Ptr srcPixels = src.constPixels()
  Dim As Pixel32 Ptr dstPixels = ScreenPtr
  
  Dim As Integer w = src.w() 'Const
  Dim As Integer h = src.h() 'Const
  
  ScreenLock
  Asm
    mov         esi,        [srcPixels]
    mov         edi,        [dstPixels]

    mov         eax,        [w]
    mov         ebx,        [h]

    mov         edx,        eax
    shl         edx,        2
    
    shr         eax,        4
    
    shl         ebx,        1

  imageops_fast2X_row_copy:

    mov         ecx,        eax

  imageops_fast2X_col_copy:

    movdqa      xmm0,       0[esi]
    movaps      xmm1,       xmm0
    shufps      xmm0,       xmm0,       &B01010000
    shufps      xmm1,       xmm1,       &B11111010

    movdqa      xmm2,       16[esi]
    movaps      xmm3,       xmm2
    shufps      xmm2,       xmm2,       &B01010000
    shufps      xmm3,       xmm3,       &B11111010

    movdqa      xmm4,       32[esi]
    movaps      xmm5,       xmm4
    shufps      xmm4,       xmm4,       &B01010000
    shufps      xmm5,       xmm5,       &B11111010

    movdqa      xmm6,       48[esi]
    movaps      xmm7,       xmm6
    shufps      xmm6,       xmm6,       &B01010000
    shufps      xmm7,       xmm7,       &B11111010

    movdqa      0[edi],     xmm0
    movdqa      16[edi],    xmm1
    movdqa      32[edi],    xmm2
    movdqa      48[edi],    xmm3
    movdqa      64[edi],    xmm4
    movdqa      80[edi],    xmm5
    movdqa      96[edi],    xmm6
    movdqa      112[edi],   xmm7

    add         esi,        64
    add         edi,        128

    dec         ecx
    jnz         imageops_fast2X_col_copy

    test        ebx,        1
    jnz         imageops_fast2X_no_reset_row

    sub         esi,        edx

  imageops_fast2X_no_reset_row:

    dec         ebx
    jnz         imageops_fast2X_row_copy
  End Asm
  ScreenUnlock
End Sub
  
Sub sync4X(ByRef src As Const Image32)
  Dim As Integer scnW
  Dim As Integer scnH
  Dim As Integer pixelBits
  ScreenInfo scnW, scnH, pixelBits
  
  DEBUG_ASSERT(src.w() Mod 8 = 0)
  DEBUG_ASSERT(src.w()*4 = scnW) 
  DEBUG_ASSERT(src.h()*4 = scnH) 
  DEBUG_ASSERT(pixelBits = 32)
 
  Dim As Const Pixel32 Ptr srcPixels = src.constPixels()
  Dim As Pixel32 Ptr dstPixels = ScreenPtr
  
  Dim As Integer w = src.w() 'Const
  Dim As Integer h = src.h() 'Const
  
  Dim As Integer lineCount = 4
  
  ScreenLock
  Asm
    mov         esi,        [srcPixels]
    mov         edi,        [dstPixels]

    mov         eax,        [w]
    mov         ebx,        [h]

    mov         edx,        eax
    shl         edx,        2   ' edx = 4*w
    
    shr         eax,        3   ' eax = w/8

    shl         ebx,        2   ' ebx = 4*h

  imageops_fast4X_row_copy:

    mov         ecx,        eax   'ecx = w/8

  imageops_fast4X_col_copy:

    movdqa      xmm0,       0[esi]
    movaps      xmm1,       xmm0
    movaps      xmm2,       xmm0
    movaps      xmm3,       xmm0
    shufps      xmm0,       xmm0,       &B00000000
    shufps      xmm1,       xmm1,       &B01010101
    shufps      xmm2,       xmm2,       &B10101010
    shufps      xmm3,       xmm3,       &B11111111    

    movdqa      xmm4,       16[esi]
    movaps      xmm5,       xmm4
    movaps      xmm6,       xmm4
    movaps      xmm7,       xmm4
    shufps      xmm4,       xmm4,       &B00000000
    shufps      xmm5,       xmm5,       &B01010101
    shufps      xmm6,       xmm6,       &B10101010
    shufps      xmm7,       xmm7,       &B11111111    

    movdqa      0[edi],     xmm0
    movdqa      16[edi],    xmm1
    movdqa      32[edi],    xmm2
    movdqa      48[edi],    xmm3
    movdqa      64[edi],    xmm4
    movdqa      80[edi],    xmm5
    movdqa      96[edi],    xmm6
    movdqa      112[edi],   xmm7

    add         esi,        32
    add         edi,        128

    dec         ecx
    jnz         imageops_fast4X_col_copy

    dec         [lineCount]
    jz          imageops_fast4X_no_reset_row

    sub         esi,        edx
  
    jmp         imageops_fast4x_row_complete
  imageops_fast4X_no_reset_row:

    mov         [lineCount],4

  imageops_fast4x_row_complete:
  
    dec         ebx
    jnz         imageops_fast4X_row_copy
  
  End Asm
  ScreenUnlock
End Sub
  
End Namespace
