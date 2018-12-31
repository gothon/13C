#Ifndef TILESET_BI
#Define TILESET_BI

#Include "image32.bi"
#Include "vec2f.bi"

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
  
 Private:  
  As Const Image32 Ptr image_ = Any 'const ptr

  As UInteger tileWidth_ = Any 'const  
  As UInteger tileHeight_ = Any 'const
  
  As UInteger totalTiles_ = Any 'const
End Type

#EndIf
