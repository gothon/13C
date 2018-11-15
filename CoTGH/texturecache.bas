#Include "texturecache.bi"

#Include "hashmap.bi"

dsm_HashMap_define(ZString, Image32Ptr)

Constructor Image32Ptr()
  'Nop
End Constructor

Destructor Image32Ptr()
  'Nop
End Destructor
  
Constructor Image32Ptr(p As Image32 Ptr)
  This.p = p
End Constructor

Dim As DArray_Image32 TextureCache.images
Static Shared As dsm.HashMap(ZString, Image32Ptr) cache

Static Function TextureCache.get(texturePath As String) As Image32 Const Ptr
  Dim As Image32Ptr loadedImage = Image32Ptr(NULL)
  If Not cache.retrieve(texturePath, loadedImage) Then
    DArray_Image32_Emplace(images, texturePath)
    loadedImage = Image32Ptr(@images.back())
    cache.insert(texturePath, loadedImage)
  EndIf
  Return loadedImage.p
End Function