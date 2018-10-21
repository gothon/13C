#Ifndef IMAGEOPS_BI
#Define IMAGEOPS_BI

#Include "image32.bi"

Namespace imageops

'Sync an image to the screen buffer while scalining it by 2 in each dimension
Declare Sub sync2X(ByRef src As Const Image32)

'Sync an image to the screen buffer while scalining it by 4 in each dimension
Declare Sub sync4X(ByRef src As Const Image32)
  
End Namespace

#EndIf
