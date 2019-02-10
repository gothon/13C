#Ifndef ACTOR_CAMERAINTERFACE_BI
#Define ACTOR_CAMERAINTERFACE_BI

#Include "../actor.bi"
#Include "../cameracontroller.bi"
#Include "../vec3f.bi"

Namespace act
	
Type GamespaceFwd As Any
Type CameraInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(CameraInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, camera As CameraController Ptr, gs As GamespaceFwd Ptr)
	
  Declare Sub snap(ByRef targetP As Const Vec2F, leadingX As Double)
  Declare Sub guide(ByRef target As Const Vec2F, facingRight As Boolean)
  Declare Const Function getP() As Vec2F
  Declare Const Function getLeadingX() As Double
  Declare Sub fadeOut()
  Declare Sub fadeIn()
  Declare Sub bleedIn()
  Declare Sub flashIn()
  Declare Sub setAddMixV(cV As Single)
  Declare Sub setAddMix(ByRef c As Const Vec3F)
  Declare Sub resetAddMixV()
  Declare Sub setYOffset(yOffset As Single)
  
  Declare Sub setMulMixPercent(p As Double, v As Double)
  
  Declare Sub zoomToTarget(ByRef t As Const Vec3F)
  Declare Sub endZoom()
	
	Declare Sub update(dt As Double)
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Const Function getZoomP(t As Single) As Vec3F
 	Declare Const Function getZoomTarget(t As Single) As Vec3F
 	
 
 	As CameraController Ptr camera_ = NULL
 	As GamespaceFwd Ptr gs_ = NULL
 	
 	As Single yOffset_ = Any
 	
 	As Vec3F addmix_ = Any
 	As Vec3F mulmix_ = Any
 	As Single fadeV_ = Any
 	As Single mixV_ = Any
 	As Vec2F guideP_
 	As Boolean facingRight_ = TRUE
 	
 	As Vec3F zoomTarget_ = Any
 	As Vec3F zoomSource_ = Any
 	As Vec3F zoomSourceLook_ = Any
 	As Double zoomT_ = Any
 	
 	as Boolean zoomMode_ = Any
End Type

End Namespace

#EndIf