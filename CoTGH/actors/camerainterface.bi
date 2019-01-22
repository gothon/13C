#Ifndef ACTOR_CAMERAINTERFACE_BI
#Define ACTOR_CAMERAINTERFACE_BI

#Include "../actor.bi"
#Include "../cameracontroller.bi"

Namespace act
	
Type CameraInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(CameraInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, camera As CameraController Ptr)
	
  Declare Sub placeAndLookAt(p As Vec3F, lookAt As Vec3F)
  Declare Sub snap(ByRef targetP As Const Vec2F, leadingX As Double)
  Declare Sub guide(ByRef target As Const Vec2F, facingRight As Boolean)
  Declare Const Function getP() As Vec2F
  Declare Const Function getLeadingX() As Double
  Declare Sub setMode(placeAndLookOnly As Boolean)
	
	Declare Sub update(dt As Double)
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As CameraController Ptr camera_ = NULL
 	
 	As Vec2F guideP_
 	As Boolean facingRight_ = TRUE
End Type

End Namespace

#EndIf