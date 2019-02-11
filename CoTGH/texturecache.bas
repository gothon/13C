#Include "texturecache.bi"

#Include "hashmap.bi"
#Include "primitive.bi"

DECLARE_PRIMITIVE_PTR(Image32)
DECLARE_DARRAY(Image32Ptr)

DEFINE_PRIMITIVE_PTR(Image32)

dsm_HashMap_define(ZString, Image32Ptr)

Dim As DArray_Image32Ptr Ptr TextureCache.images
Static Shared As dsm.HashMap(ZString, Image32Ptr) cache

Sub TextureCacheConstruct() Constructor
	TextureCache.images = New DArray_Image32Ptr()
End Sub

Sub TextureCacheDestruct() Destructor
	For i As Integer = 0 To (*TextureCache.images).size() - 1
		Delete((*TextureCache.images)[i].getValue())
	Next i
	Delete(TextureCache.images)
End Sub

Static Function TextureCache.get(texturePath As String) As Image32 Ptr
  Dim As Image32Ptr loadedImage = Image32Ptr(NULL)
  Dim As String newPath = UCase(texturePath)
  If Not cache.retrieve(newPath, loadedImage) Then
    DArray_Image32Ptr_Emplace((*TextureCache.images), New Image32(newPath))
    loadedImage = Image32Ptr((*TextureCache.images).back().getValue())
    cache.insert(newPath, loadedImage)
  EndIf
  Return loadedImage.getValue()
End Function