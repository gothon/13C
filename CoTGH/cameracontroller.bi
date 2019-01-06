#Ifndef CAMERACONTROLLER_BI
#Define CAMERACONTROLLER_BI

#Include "vec2f.bi"
#Include "projection.bi"

Type CameraController
 Public:
  Declare Constructor(ByRef baseProj As Const Projection)
  
  Declare Sub snap(ByRef targetP As Const Vec2F)
  Declare Sub update(t As Double, ByRef targetP As Const Vec2F, facingRight As Boolean)
  
	Declare Function proj() ByRef As Const Projection
 Private:
 	As Projection proj_ = Any
 	
 	As Vec2F p_ = Any
 	As Double leadingX_ = Any
 	As Double leadingXV_ = Any
 	As Boolean needsUpdate_ = Any
End Type

#EndIf
