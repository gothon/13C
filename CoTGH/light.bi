#Ifndef LIGHT_BI
#Define LIGHT_BI

#Include "vertex.bi"

Enum LightMode Explicit
	SOLID = 0
	FLICKER = 1
End Enum

Type Light
 Public:
 	Declare Constructor(ByRef p As Const Vec3F, ByRef c As Const Vec3F, r As Double, mode As LightMode)
 	Declare Destructor()
 	
	Declare Const Sub add(ByRef p As Const Vec3F, ByRef n As Const Vec3F, v As Vertex Ptr)
 	Declare Const Sub distanceAdd(ByRef p As Const Vec3F, v As Vertex Ptr)

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

Type LightPtr
	Declare Constructor() 'Nop
	Declare Constructor(p As Light Ptr)
	
	Declare Destructor()
	Declare Const Operator Cast() As Light Ptr
	
	As Light Ptr p = Any
End Type

#EndIf
