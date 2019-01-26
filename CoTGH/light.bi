#Ifndef LIGHT_BI
#Define LIGHT_BI

#Include "vertex.bi"
#Include "primitive.bi"

Enum LightMode Explicit
	SOLID = 0
	FLICKER = 1
End Enum

Type Light
 Public:
 	Declare Constructor(ByRef p As Const Vec3F, ByRef c As Const Vec3F, r As Double, mode As LightMode)
 	Declare Destructor()
 	
	'Declare custom copy constructor/assignment to avoid copying binding counter
  Declare Constructor(ByRef other As Const Light)
  Declare Operator Let(ByRef other As Const Light)
 	
	Declare Const Function add(ByRef p As Const Vec3F, ByRef n As Const Vec3F, v As Vertex Ptr) As Boolean
 	Declare Const Function distanceAdd(ByRef p As Const Vec3F, v As Vertex Ptr) As Boolean

 	Declare Sub update(t As Double)
 	
 	Declare Sub translate(ByRef v As Const Vec3F)
 	
 	Declare Sub on()
 	Declare Sub off()
 	
  'Reference count mutators to track if this Light or its data is referenced by another object i.e. a
  'QuadDrawBuffer
  Declare Sub bind()
  Declare Sub unbind()
 Private:
  As UInteger bindings_ = Any
  
 	Declare Const Function inRange(ByRef p As Const Vec3F) As Boolean
 	Declare Sub updateExtent()
 	
 	'Position
 	As Vec3F p_ = Any
 	'Color
 	As Vec3F c_ = Any 'const
 	'Radius
 	As Double r_ = Any 'const
 	
 	As Vec3F minExtent_ = Any
 	As Vec3F maxExtent_ = Any
 	
 	As Boolean enabled_ = Any
 	
 	As LightMode mode_ = Any 'const
End Type

DECLARE_PRIMITIVE_PTR(Light)

#EndIf
