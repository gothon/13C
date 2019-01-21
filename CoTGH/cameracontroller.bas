#Include "cameracontroller.bi"

Const As Double LEAD_X_LENGTH = 30

Constructor CameraController(ByRef baseProj As Const Projection)
	This.proj_ = baseProj
	This.p_ = Vec2F(0, 0)
	This.needsUpdate_ = TRUE
	This.leadingX_ = LEAD_X_LENGTH
End Constructor

Sub CameraController.setMode(placeAndLookOnly As Boolean)
	placeAndLookOnly_ = placeAndLookOnly
End Sub

Sub CameraController.snap(ByRef targetP As Const Vec2F, leadingX As Double)
	p_ = targetP
	leadingX_ = leadingX
	needsUpdate_ = TRUE
End Sub

Sub CameraController.placeAndLookAt(p As Vec3F, lookAt As Vec3F)
	pPlace_ = p
	pLook_ = lookAt
	needsUpdate_ = TRUE
End Sub

Const Function CameraController.getP() As Vec2F
	Return p_
End Function

Const Function CameraController.getLeadingX() As Double
	Return leadingX_
End Function

Sub CameraController.update(t As Double, ByRef targetP As Const Vec2F, facingRight As Boolean)
	If Not placeAndLookOnly_ Then 
		Dim As Double leadTarget = Any
		leadTarget = IIf(facingRight, LEAD_X_LENGTH, -LEAD_X_LENGTH)
		leadingX_ += Sgn(leadTarget - leadingX_)*t*1.0
		If Abs(leadingX_) > LEAD_X_LENGTH Then leadingX_ = LEAD_X_LENGTH*Sgn(leadingX_)
		p_ = targetP + Vec2F(leadingX_, 0)
		needsUpdate_ = TRUE
	EndIf 
End Sub
  
Function CameraController.proj() ByRef As Const Projection
	If needsUpdate_ Then 
		needsUpdate_ = FALSE
		If Not placeAndLookOnly_ Then
			proj_.placeAndLookAt(Vec3F(p_.x - leadingX_*0.5, p_.y + 44, 180), Vec3F(p_.x, p_.y + 24, 0))
		Else 
			proj_.placeAndLookAt(pPlace_, pLook_)
		EndIf 
	EndIf
	Return proj_
End Function