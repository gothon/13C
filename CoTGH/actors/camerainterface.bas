#Include "camerainterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../cameracontroller.bi"
#Include "../gamespace.bi"
#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actorbank.bi"
#Include "../vecmath.bi"

Namespace act
ACTOR_REQUIRED_DEF(CameraInterface, ActorTypes.CAMERAINTERFACE)

Const As Single FADE_VELOCITY = 0.08
Const As Single FLASH_VELOCITY = 0.08
	
Const As Single ZOOM_ANIM_SPEED = 1.55
	
Constructor CameraInterface(parent As ActorBankFwd Ptr, camera As CameraController Ptr, gs As GamespaceFwd Ptr)
	Base.Constructor(parent)
	setType()

	setKey("CAMERA INTERFACE")
	
	This.camera_ = camera	
	This.gs_ = gs
	This.mulmix_ = Vec3F(1.0, 1.0, 1.0)
 	This.fadeV_ = FADE_VELOCITY
 	This.mixV_ = -FLASH_VELOCITY
 	This.addmix_ = Vec3F(0.0, 0.0, 0.0)
 	This.zoomMode_ = FALSE
End Constructor

Sub CameraInterface.zoomToTarget(ByRef t As Const Vec3F)
	zoomTarget_ = t
	zoomSource_ = camera_->getAdjustedP()
	zoomSourceLook_ = camera_->getAdjustedTarget() - camera_->getAdjustedP()
	vecmath.normalize(@zoomSourceLook_)
	
	zoomT_ = 0
	zoomMode_ = TRUE
	camera_->setMode(TRUE)
End Sub

Const Function CameraInterface.getZoomP(t As Single) As Vec3F
	If t > 1 Then t = 1
	Return (zoomTarget_ - zoomSource_)*t + zoomSource_
End Function

Const Function CameraInterface.getZoomTarget(t As Single) As Vec3F
	Dim As Double adjustT = t
	If adjustT < 0 Then
		adjustT = 0
	ElseIf adjustT > 1 Then
		adjustT = 1
	EndIf
	Return getZoomP(t) + ((Vec3F(0, 0, -1) - zoomSourceLook_)*adjustT + zoomSourceLook_)
End Function

Sub CameraInterface.snap(ByRef targetP As Const Vec2F, leadingX As Double)
	camera_->snap(targetP, leadingX)
	guideP_ = targetP
End Sub

Const Function CameraInterface.getP() As Vec2F
	Return camera_->getP()
End Function

Const Function CameraInterface.getLeadingX() As Double
	Return camera_->getLeadingX()
End Function

Sub CameraInterface.guide(ByRef target As Const Vec2F, facingRight As Boolean)
	guideP_ = target
	facingRight_ = facingRight
End Sub

Sub CameraInterface.fadeOut()
	fadeV_ = -FADE_VELOCITY
End Sub

Sub CameraInterface.fadeIn()
	fadeV_ = FADE_VELOCITY	
End Sub

Sub CameraInterface.bleedIn()
	addmix_ = Vec3F(1.0, 0.5, 0.5)
End Sub

Sub CameraInterface.flashIn()
	addmix_ = Vec3F(1.0, 1.0, 1.0)
End Sub

Sub CameraInterface.endZoom()
	zoomMode_ = FALSE
End Sub

Sub CameraInterface.setAddMixV(cV As Single)
	mixV_ = cV
End Sub

Sub CameraInterface.setAddMix(ByRef c As Const Vec3F)
	addmix_ = c
End Sub

Sub CameraInterface.resetAddMixV()
 	mixV_ = -FLASH_VELOCITY
End Sub

Sub CameraInterface.setMulMixPercent(p As Double, v As Double)
	mulmix_ = Vec3F(1, 1, 1)*p
	fadeV_ = v
End Sub
  
Sub CameraInterface.update(dt As Double)
	Dim As Boolean transition = GET_GLOBAL("TRANSITION NOTIFIER", TransitionNotifier).happened()
	If transition Then
		resetAddMixV()
		setAddMix(Vec3F())
		zoomMode_ = FALSE
		camera_->setMode(FALSE)
	EndIf
	
	If (Not zoomMode_) Then
		camera_->update(dt, guideP_, facingRight_)
	ElseIf zoomMode_ Then 
		Dim As Single t = 1.7*((zoomT_ - 0.22)^2 - 0.05)
		camera_->placeAndLookAt(getZoomP(t), getZoomTarget(t))
		zoomT_ += ZOOM_ANIM_SPEED*dt
		If zoomT_ > 1.0 Then zoomT_ = 1.0
	End If
	
	mulmix_ += Vec3F(1.0, 1.0, 1.0)*fadeV_
	addmix_ += Vec3F(1.0, 1.0, 1.0)*mixV_
	
	util.clamp(@mulmix_, 0.0, 1.0)
	util.clamp(@addmix_, 0.0, 0.95)

	CPtr(Gamespace Ptr, gs_)->setDrawMulmix(mulmix_, addmix_)
End Sub

Function CameraInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
