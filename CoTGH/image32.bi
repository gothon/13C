#Ifndef IMAGE32_BI
#Define IMAGE32_BI

#Include "pixel32.bi"

'32 bit image
Type Image32
 Public:
  Declare Constructor(w As Integer, h As Integer)
    
  Declare Destructor()
    
  Declare Function pixels() As Pixel32 Ptr
  Declare Function w() As Integer
  Declare Function h() As Integer
 Private:
  As Integer w_ 'Const
  As Integer h_ 'Const
  
  As Pixel32 Ptr pixels_ 'Const Ptr
End Type

#EndIf
