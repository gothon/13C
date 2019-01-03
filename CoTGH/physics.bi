#Ifndef PHYSICS_BI
#Define PHYSICS_BI

#Include "aabb.bi"
#Include "vec2f.bi"

Namespace physics
Enum BlockType Explicit
	NONE = 0
	FULL = 1
	ONE_WAY_UP = 2
End Enum

'Along which axis a collision occured
Enum Axis Explicit
	NONE = 0
	X = 1
	Y = 2
	XY = 3
End Enum

'Result of a collision. No collision is when clipAxis = Axis.NONE
Type ClipResult
	Declare Constructor() 'nop
	Declare Constructor(ByRef clipV As Const Vec2F, clipAxis As Axis)
	As Vec2F clipV = Any
	As Axis clipAxis = Any
End Type

'A collide-able block grid.
Type BlockGrid
 Public:
	Declare Constructor(w As UInteger, h As UInteger, l As Double)
	Declare Destructor()
	
	Declare Sub putBlock(x As UInteger, y As UInteger, t As BlockType)
  Declare Sub putBlock(index As UInteger, t As BlockType)
  
  Declare Function getBlock(x As UInteger, y As UInteger) As BlockType

	'Given a rect not currently interpenetrating the block grid moving over v, get an updated
	'v clipped to the block grid. It is assumed that v is traveled over for 1s.
	Declare Function clipRect( _
			ByRef rect As Const AABB, _
			ByVal v As Vec2F) As ClipResult
			
 Private:
 	As BlockType Ptr blocks_
 	as Double l_
 	as UInteger w_
 	as UInteger h_
End Type

End Namespace

#EndIf