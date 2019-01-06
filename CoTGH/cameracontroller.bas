#Include "cameracontroller.bi"

Const As Double LEAD_X_LENGTH = 30

Constructor CameraController(ByRef baseProj As Const Projection)
	This.proj_ = baseProj
	This.p_ = Vec2F(0, 0)
	This.needsUpdate_ = TRUE
	This.leadingX_ = LEAD_X_LENGTH
End Constructor

Sub CameraController.snap(ByRef targetP As Const Vec2F)
	p_ = targetP
	needsUpdate_ = TRUE
End Sub

Sub CameraController.update(t As Double, ByRef targetP As Const Vec2F, facingRight As Boolean)
	Dim As Double leadTarget = Any
	leadTarget = IIf(facingRight, LEAD_X_LENGTH, -LEAD_X_LENGTH)
	leadingX_ += Sgn(leadTarget - leadingX_)*t*1.0
	If Abs(leadingX_) > LEAD_X_LENGTH Then leadingX_ = LEAD_X_LENGTH*Sgn(leadingX_)
	p_ = targetP + Vec2F(leadingX_, 0)
	needsUpdate_ = TRUE
End Sub
  
Function CameraController.proj() ByRef As Const Projection
	If needsUpdate_ Then 
		needsUpdate_ = FALSE
		proj_.placeAndLookAt(Vec3F(p_.x - leadingX_*0.1, p_.y + 44, 200), Vec3F(p_.x, p_.y + 24, 0))
	EndIf
	Return proj_
End Function