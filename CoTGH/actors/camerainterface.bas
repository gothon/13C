#Include "camerainterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../cameracontroller.bi"
#Include "../gamespace.bi"
#Include "../util.bi"

Namespace act
ACTOR_REQUIRED_DEF(CameraInterface, ActorTypes.CAMERAINTERFACE)

Const As Single FADE_VELOCITY = 0.08
Const As Single FLASH_VELOCITY = 0.08
	
Constructor CameraInterface(parent As ActorBankFwd Ptr, camera As CameraController Ptr, gs As GamespaceFwd Ptr)
	Base.Constructor(parent)
	setType()

	setKey("CAMERA INTERFACE")
	
	This.camera_ = camera	
	This.gs_ = gs
	This.mulmix_ = Vec3F(1.0, 1.0, 1.0)
 	This.fadeV_ = FADE_VELOCITY
 	This.addmix_ = Vec3F(0.0, 0.0, 0.0)
End Constructor

Sub CameraInterface.placeAndLookAt(p As Vec3F, lookAt As Vec3F)
	camera_->placeAndLookAt(p, lookAt)
End Sub

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

Sub CameraInterface.setMode(placeAndLookOnly As Boolean)
	camera_->setMode(placeAndLookOnly)
End Sub

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

Sub CameraInterface.update(dt As Double)
	camera_->update(dt, guideP_, facingRight_)
	mulmix_ += Vec3F(1.0, 1.0, 1.0)*fadeV_
	addmix_ -= Vec3F(1.0, 1.0, 1.0)*FLASH_VELOCITY
	util.clamp(@mulmix_, 0.0, 1.0)
	util.clamp(@addmix_, 0.0, 1.0)
	CPtr(Gamespace Ptr, gs_)->setDrawMulmix(mulmix_, addmix_)
End Sub

Function CameraInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
