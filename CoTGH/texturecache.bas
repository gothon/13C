#Include "texturecache.bi"

#Include "hashmap.bi"

Type Image32Ptr As Image32 Ptr 
dsm_HashMap_define(ZString, Image32Ptr)

Type TextureCacheAccessor Extends TextureCache
 Public:
  Declare Static Sub construct_()
  Declare Static Sub destruct_()
 Private:
  As Integer _placeholder_
End Type
Sub TextureCacheAccessor.construct_()
  construct()
End Sub
Sub TextureCacheAccessor.destruct_()
  destruct()
End Sub
Constructor TextureCacheInitializationObject(construct As Sub(), destruct As Sub())
  construct()
  This.destruct = destruct
End Constructor
Destructor TextureCacheInitializationObject()
  destruct()
End Destructor
Dim As TextureCacheInitializationObject TextureCache.initializationObject = _
    TextureCacheInitializationObject(@TextureCacheAccessor.construct_, _ 
                                     @TextureCacheAccessor.destruct_)
Dim As DArray TextureCache.images = DARRAY_CREATE(Image32)

Static Shared As dsm.HashMap(ZString, Image32Ptr) cache

Static Sub TextureCache.construct()
  'Nop
End Sub

Static Sub TextureCache.destruct()
  For i As Integer = 0 To images.size() - 1
    DARRAY_AT(Image32, images, i).Destructor()
  Next i
End Sub

Static Function TextureCache.get(texturePath As String) As Image32 Const Ptr
  Dim As Image32Ptr loadedImage = NULL
  If Not cache.retrieve(texturePath, loadedImage) Then
    images.expandBy(1)
    loadedImage = New(images.getPtr(images.size() - 1)) Image32(texturePath)
    cache.insert(texturePath, loadedImage)
  EndIf
  Return loadedImage
End Function