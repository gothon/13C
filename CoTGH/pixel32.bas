#Include "pixel32.bi"

Constructor Pixel32()
  'Nop
End Constructor
 
Constructor Pixel32(r As UByte, g As UByte, b As UByte, a As UByte)
  This.r = r
  This.g = g
  This.b = b
  This.a = a
End Constructor
