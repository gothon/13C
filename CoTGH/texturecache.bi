#Ifndef TEXTURECACHE_BI
#Define TEXTURECACHE_BI

#Include "darray.bi"
#Include "image32.bi"
#Include "primitive.bi"

DECLARE_PRIMITIVE_PTR(Image32)
DECLARE_DARRAY(Image32Ptr)

'A cache of textures so that referencing a texture by filename is a safe pattern even after initializing an object
'that uses textures.
Type TextureCache
 Public:
  'Paths should be in all upper-case to prevent the need to UCase on every get.
  Declare Static Function get(texturePath As String) As Image32 Ptr

  Static As DArray_Image32Ptr Ptr images  
  As Integer _ignored_
End Type

#EndIf
