#Include "tilesetcache.bi"

#Include "hashmap.bi"

dsm_HashMap_define(ZString, TilesetPtr)

Constructor TilesetPtr()
  'Nop
End Constructor

Destructor TilesetPtr()
  'Nop
End Destructor
  
Constructor TilesetPtr(p As Tileset Ptr)
  This.p = p
End Constructor

Dim As DArray_Tileset TilesetCache.tilesets
Static Shared As dsm.HashMap(ZString, TilesetPtr) cache

Static Function TilesetCache.get(tilesetPath As String) As Const Tileset Ptr
  Dim As TilesetPtr loadedTileset = TilesetPtr(NULL)
  If Not cache.retrieve(tilesetPath, loadedTileset) Then
    DArray_Tileset_Emplace(tilesets, tilesetPath)
    loadedTileset = TilesetPtr(@tilesets.back())
    cache.insert(tilesetPath, loadedTileset)
  EndIf
  Return loadedTileset.p
End Function