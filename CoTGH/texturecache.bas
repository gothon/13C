#Include "texturecache.bi"

#Include "hashmap.bi"

Type Image32Ptr As Image32 Ptr 
dsm_HashMap_define(ZString, Image32Ptr)

Dim As DArray_Image32 TextureCache.images
Static Shared As dsm.HashMap(ZString, Image32Ptr) cache

Static Function TextureCache.get(texturePath As String) As Image32 Const Ptr
  Dim As Image32Ptr loadedImage = NULL
  If Not cache.retrieve(texturePath, loadedImage) Then
    DArray_Image32_Emplace(images, texturePath)
    cache.insert(texturePath, loadedImage)
  EndIf
  Return loadedImage
End Function