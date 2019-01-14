#Ifndef PHYSICS_BI
#Define PHYSICS_BI

#Include "aabb.bi"
#Include "vec2f.bi"
#Include "actor.bi"
#Include "primitive.bi"
#Include "staticlist.bi"

Type Collider Extends Object
 Public:
 	Declare Virtual Destructor()
 	
 	Declare Constructor(ByRef rhs As Const Collider) 'disallowed
  Declare Operator Let(ByRef rhs As Const Collider) 'disallowed
	
	Declare Function getTag() As UInteger
	Declare Sub tag(tagz As UInteger)
	Declare Sub untag()
	
	Declare Function getParent() As Actor Ptr
 Protected:
  Declare Constructor(parent As Actor Ptr)
 	Declare Constructor() 'nop
 
 	As Actor Ptr parent_ = Any 'const
 	As UInteger ref_tag_ = Any
End Type

Enum BlockType Explicit
	NONE = 0
	FULL = 1
	ONE_WAY_UP = 2
End Enum

'A static collide-able block grid.
Type BlockGrid Extends Collider
 Public:
	Declare Constructor(parent As Actor Ptr, w As UInteger, h As UInteger, l As Double)
	Declare Destructor() Override
	
	Declare Sub putBlock(x As UInteger, y As UInteger, t As BlockType)
  Declare Sub putBlock(index As UInteger, t As BlockType)
  
  Declare Const Function getBlock(x As UInteger, y As UInteger) As BlockType
  
	Declare Const Function getWidth() As UInteger
	Declare Const Function getHeight() As UInteger
	Declare Const Function getSideLength() As Double
 Private:
 	As BlockType Ptr blocks_ = Any
 	As Double l_ = Any
 	As UInteger w_ = Any
 	As UInteger h_ = Any
End Type

'Along which axis a collision occured
Enum AxisComponent Explicit
	NONE = 0
	X_P = 1
	X_N = 2
	Y_P = 4
	Y_N = 8
End Enum
Type Axis As UInteger

Type Arbiter
 	Declare Constructor() 'disallowed
 	Declare Destructor() 
 	
	Declare Constructor(onAxis As Axis, actorRef As Actor Ptr)
	
	As Axis onAxis = AxisComponent.NONE 'const
	As Actor Ptr actorRef = NULL 'const
End Type

DECLARE_DARRAY(Arbiter)

'A dynamic collide-able box.
Type DynamicAABB Extends Collider
 Public:
	Declare Constructor(parent As Actor Ptr, ByRef box As Const AABB)
	
	Declare Sub place(ByRef p As Const Vec2F)
	Declare Sub setV(ByRef v As Const Vec2F)
	
	Declare Const Function getAABB() ByRef As Const AABB
	Declare Const Function getV() ByRef As Const Vec2F
	
 	Declare Function getArbiters() ByRef As DArray_Arbiter
 Private:
 	As AABB box_ = Any
 	As Vec2F v_ = Any
 	
 	As DArray_Arbiter arbiters_
End Type

DECLARE_PRIMITIVE_PTR(BlockGrid)
DECLARE_PRIMITIVE_PTR(DynamicAABB)

DECLARE_STATICLIST(BlockGridPtr)
DECLARE_STATICLIST(DynamicAABBPtr)

Type Simulation
 Public:
 	Declare Constructor() 'nop
 	Declare Destructor() 'nop
 	
 	Declare Constructor(ByRef rhs As Const Actor) 'disallowed
  Declare Operator Let(ByRef rhs As Const Actor) 'disallowed
 	
 	Declare Sub setForce(ByRef f As Const Vec2F)
 	
 	Declare Sub add(grid As BlockGrid Ptr)
 	Declare Sub add(box As DynamicAABB Ptr)
 	
 	Declare Sub remove(grid As BlockGrid Ptr)
 	Declare Sub remove(box As DynamicAABB Ptr)
 	
 	Declare Sub update(dt As Double)
 	
 Private:
 	Declare Sub integrateAll(dt As Double)
 
 	As StaticList_BlockGridPtr grids_
 	As StaticList_DynamicAABBPtr boxes_
 	As Vec2F force_
End Type

#EndIf
