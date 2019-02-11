#Include "tilesetcache.bi"

#Include "hashmap.bi"
#Include "primitive.bi"

DECLARE_PRIMITIVE_PTR(Tileset)
DECLARE_DARRAY(TilesetPtr)

DEFINE_PRIMITIVE_PTR(Tileset)

dsm_HashMap_define(ZString, TilesetPtr)

Dim As DArray_TilesetPtr Ptr TilesetCache.tilesets
Static Shared As dsm.HashMap(ZString, TilesetPtr) cache

Sub TilesetCacheConstruct() Constructor
	TilesetCache.tilesets = New DArray_TilesetPtr()
End Sub

Sub TilesetCacheDestruct() Destructor
	For i As Integer = 0 To (*TilesetCache.tilesets).size() - 1
		Delete((*TilesetCache.tilesets)[i].getValue())
	Next i
	Delete(TilesetCache.tilesets)
End Sub

Static Function TilesetCache.get(tilesetPath As String) As Tileset Ptr
  Dim As TilesetPtr loadedTileset = TilesetPtr(NULL)
  Dim As String newPath = UCase(tilesetPath)
  If Not cache.retrieve(newPath, loadedTileset) Then
    DArray_TilesetPtr_Emplace((*TilesetCache.tilesets), New Tileset(newPath))
    loadedTileset = TilesetPtr((*TilesetCache.tilesets).back().getValue())
    cache.insert(newPath, loadedTileset)
  EndIf
  Return loadedTileset.getValue()
End Function