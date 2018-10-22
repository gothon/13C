#Ifndef TEXTURECACHE_BI
#Define TEXTURECACHE_BI

#Include "darray.bi"
#Include "image32.bi"

Type TextureCacheInitializationObject
 Public:
  Declare Constructor(construct As Sub(), destruct As Sub())
  Declare Destructor()
 Private:
  As Sub() destruct
End Type

'A cache of textures so that referencing a texture by filename is a safe pattern even after initializing an object
'that uses textures.
Type TextureCache
  Declare Static Function get(texturePath As String) As Image32 Const Ptr
 Protected:
  Declare Constructor()
  Declare Static Sub construct()
  Declare Static Sub destruct()
 
 Private:
  Static As TextureCacheInitializationObject initializationObject
  Static As DArray images 'Image32
  
  As Integer _ignored_
End Type

#EndIf
