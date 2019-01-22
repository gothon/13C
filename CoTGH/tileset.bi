#Ifndef TILESET_BI
#Define TILESET_BI

#Include "image32.bi"
#Include "vec2f.bi"

Enum TransType Explicit
	SOLID = 0
	SEMI_SOLID = 1
	CLEAR = 2
End Enum

'A tileset. Since images are cached, no destructor is neccessary.
Type Tileset
 Public:
  Declare Constructor()
  
  Declare Destructor() 'nop
 
  'Load a tileset from a .tsx file
  Declare Constructor(path As Const ZString Ptr)
     
  'Returns a pointer to the image data
  Declare Const Function image() As Const Image32 Ptr
  
  'Populate the start coords of the tile at the given index
  Declare Const Sub getTileStart(index As UInteger, start As Vec2F Ptr)
  
  'Populate the size of the tile at the given index
  Declare Const Sub getTileSize(size As Vec2F Ptr)
  
  Declare Const Function getTransType(a As Vec2F, b As Vec2F) As TransType
  
 Private:  
  As Const Image32 Ptr image_ = Any 'const ptr

  As UInteger tileWidth_ = Any 'const  
  As UInteger tileHeight_ = Any 'const
  
  As UInteger totalTiles_ = Any 'const
  
  As TransType Ptr transTypes_ = Any
End Type

#EndIf
