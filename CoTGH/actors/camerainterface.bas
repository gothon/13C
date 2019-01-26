#Include "camerainterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../cameracontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(CameraInterface, ActorTypes.CAMERAINTERFACE)
	
Constructor CameraInterface(parent As ActorBankFwd Ptr, camera As CameraController Ptr)
	Base.Constructor(parent)
	setType()

	setKey("CAMERA INTERFACE")
	
	This.camera_ = camera	
End Constructor

Sub CameraInterface.placeAndLookAt(p As Vec3F, lookAt As Vec3F)
	camera_->placeAndLookAt(p, lookAt)
End Sub

Sub CameraInterface.snap(ByRef targetP As Const Vec2F, leadingX As Double)
	camera_->snap(targetP, leadingX)
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

Sub CameraInterface.update(dt As Double)
	camera_->update(dt, guideP_, facingRight_)
End Sub

Function CameraInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace