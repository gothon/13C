#Ifndef IMAGEOPS_BI
#Define IMAGEOPS_BI

#Include "image32.bi"
#Include "vec3f.bi"

Namespace imageops

'Sync an image to the screen buffer while scalining it by 2 in each dimension
Declare Sub sync2X(ByRef src As Const Image32)

'Sync an image to the screen buffer while scalining it by 4 in each dimension
Declare Sub sync4X(ByRef src As Const Image32)

'Multiply an image by a fixed color value
Declare Sub mulmix(src As Image32 Ptr, ByRef x As Const Vec3F)
  
End Namespace

#EndIf
