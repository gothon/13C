#Ifndef CAMERACONTROLLER_BI
#Define CAMERACONTROLLER_BI

#Include "vec2f.bi"
#Include "projection.bi"

Type CameraController
 Public:
  Declare Constructor(ByRef baseProj As Const Projection)
    
  Declare Sub placeAndLookAt(p As Vec3F, lookAt As Vec3F)
  Declare Sub snap(ByRef targetP As Const Vec2F, leadingX As Double)
  Declare Const Function getP() As Vec2F
  Declare Const Function getLeadingX() As Double
  Declare Sub setMode(placeAndLookOnly As Boolean)
  
  Declare Sub update(t As Double, ByRef targetP As Const Vec2F, facingRight As Boolean)
  
	Declare Function proj() ByRef As Const Projection
 Private:
 	As Projection proj_ = Any
 	
 	As Boolean placeAndLookOnly_ = FALSE
 	As Vec3F pPlace_
 	As Vec3F pLook_
 	
 	As Vec2F p_ = Any
 	As Double leadingX_ = Any
 	As Boolean needsUpdate_ = Any
End Type

#EndIf
