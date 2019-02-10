#Include "camera.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../aabb.bi"
#Include "../light.bi"
#Include "../audiocontroller.bi"

#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Camera, ActorTypes.CAMERA)

Const As Integer CAMERA_W = 48
Const As Integer CAMERA_H = 48

Function Camera.createModel() As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(CAMERA_W, CAMERA_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {TextureCache.get("res/camera.png")}
	Return New QuadModel( _
			Vec3F(CAMERA_W, CAMERA_H, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)
End Function
	
Constructor Camera(parent As ActorBankFwd Ptr, ByRef box As Const AABB)
	Base.Constructor( _
			parent, _
			createModel(), _
			New Light(Vec3F(box.o.x + box.s.x*0.5, box.o.y + box.s.y*0.5, 8), Vec3F(1.0, 1.0, 1.0), 128))
	setType()
	
	model_->translate(Vec3F(box.o.x + box.s.x*0.5 - CAMERA_W*0.5, box.o.y + box.s.y*0.5 - CAMERA_H*0.5, -3))
	This.bounds_ = box
	This.t_ = 0
	AudioController.cacheSample("res/cameraget.wav")
End Constructor

Function Camera.update(dt As Double) As Boolean

	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	If player_->getBounds().intersects(bounds_) Then
		player_->setHasCamera(TRUE)
		AudioController.playSample("res/cameraget.wav")
		Return TRUE
	EndIf 

	Dim As Double drift = Sin(t_ * 6.28318530718 * 0.5)*0.5 'const
	t_ += dt
	
	model_->translate(Vec3F(0, 1, 0)*drift)
	light_->translate(Vec3F(0, 1, 0)*drift)
	
	If Int(Rnd * 2) = 0 Then 
		Dim As ActiveBankInterface Ptr activeInterface = @GET_GLOBAL("ACTIVEBANK INTERFACE", ActiveBankInterface)
		Dim As Vec2F sPosition = Any
		sPosition.x = (bounds_.o.x - 4) + (bounds_.s.x + 8)*Rnd
		sPosition.y = (bounds_.o.y - 4) + (bounds_.s.y + 8)*Rnd + 6
		activeInterface->add(New Spronkle(activeInterface->getParent(), sPosition, 0, FALSE))
	End If 

	Return FALSE
End Function

Sub Camera.notify()
	''
End Sub

Function Camera.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace