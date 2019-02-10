#Include "plaque.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../audiocontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(Plaque, ActorTypes.PLAQUE)

Const As Integer CAMERA_Y_OFFSET = 30
	
Constructor Plaque( _
			parent As ActorBankFwd Ptr, _
			ByRef bounds As Const AABB, _
			ByRef text As Const String)
	Base.Constructor(parent)
	setType()
		
	AudioController.cacheSample("res/place.wav")
		
	This.bounds_ = bounds
	This.text_ = text
	This.triggered_ = FALSE
	This.displaying_ = FALSE
End Constructor
	
Function Plaque.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	If player_->getBounds().intersects(bounds_) Then
		If player_->pressedActivate() Then 
			displaying_ = Not displaying_
			Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)	
			If displaying_ Then 
				GET_GLOBAL("OVERLAY", Overlay).showText(text_)
				camera->setYOffset(CAMERA_Y_OFFSET)
			Else
				GET_GLOBAL("OVERLAY", Overlay).showText("")
				camera->setYOffset(0)
				AudioController.playSample("res/place.wav", Vec2F(0, 500))
			EndIf
			If Not triggered_ Then
				triggered_ = TRUE
				player_->addPlaque()
			Else
				AudioController.playSample("res/place.wav", Vec2F(0, 500))
			EndIf
		End If 
	Else
		If displaying_ Then 
			GET_GLOBAL("OVERLAY", Overlay).showText("")
			Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)	
			camera->setYOffset(0)
			AudioController.playSample("res/place.wav", Vec2F(0, 500))
		EndIf
		displaying_ = FALSE
	EndIf
	If (Not triggered_) AndAlso (Int(Rnd * 20) = 0) Then 
		Dim As ActiveBankInterface Ptr activeInterface = @GET_GLOBAL("ACTIVEBANK INTERFACE", ActiveBankInterface)
		Dim As Vec2F sPosition = Any
		sPosition.x = (bounds_.o.x - 4) + (bounds_.s.x + 8)*Rnd
		sPosition.y = (bounds_.o.y - 4) + (bounds_.s.y + 8)*Rnd
		activeInterface->add(New Spronkle(activeInterface->getParent(), sPosition, 0.5, FALSE))
	End If 
	
	Return FALSE
End Function

Sub Plaque.notify()
	''
End Sub
	
Function Plaque.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
