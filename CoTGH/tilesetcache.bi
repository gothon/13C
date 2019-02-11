#Ifndef TILESETCACHE_BI
#Define TILESETCACHE_BI

#Include "darray.bi"
#Include "tileset.bi"
#Include "primitive.bi"

DECLARE_PRIMITIVE_PTR(Tileset)
DECLARE_DARRAY(TilesetPtr)

'A cache of tilesets so that referencing a tilesets by filename is a safe pattern even after initializing an object
'that uses tilesets.
Type TilesetCache
 Public:
  'Paths should be in all upper-case to prevent the need to UCase on every get.
  Declare Static Function get(tilesetPath As String) As Tileset Ptr

  Static As DArray_TilesetPtr Ptr tilesets
  
  As Integer _ignored_
End Type

#EndIf
