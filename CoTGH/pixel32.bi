#Ifndef PIXEL32_BI
#Define PIXEL32_BI

'RGBA pixel value
Type Pixel32
  Declare Constructor()
  Declare Constructor (r As UByte, g As UByte, b As UByte, a As UByte = 255)
  
  Union
    value As UInteger
    Type
      As UByte r : 8
      As UByte g : 8
      As UByte b : 8
      As UByte a : 8
    End Type
  End Union
End Type

#EndIf
