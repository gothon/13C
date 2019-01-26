#Ifndef TILESETCACHE_BI
#Define TILESETCACHE_BI

#Include "darray.bi"
#Include "tileset.bi"

DECLARE_DARRAY(Tileset)

Type TilesetPtr
  Declare Constructor()
  Declare Destructor()
  
  Declare Constructor(p As Tileset Ptr)
  
  As Tileset Ptr p
End Type

'A cache of tilesets so that referencing a tilesets by filename is a safe pattern even after initializing an object
'that uses tilesets.
Type TilesetCache
 Public:
  'Paths should be in all upper-case to prevent the need to UCase on every get.
  Declare Static Function get(tilesetPath As String) As Tileset Ptr

 Private:
  Static As DArray_Tileset tilesets
  
  As Integer _ignored_
End Type

#EndIf
