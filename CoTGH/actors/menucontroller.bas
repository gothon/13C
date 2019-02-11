#Include "menucontroller.bi"

#Include "../actortypes.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../debuglog.bi"
#Include "../actordefs.bi"
#Include "../actorbank.bi"
#Include "../audiocontroller.bi"
#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(MenuController, ActorTypes.MENUCONTROLLER)

Const As Single ARROW_X_CENTER = 176
Const As Single PLAYER_X_DELTA = 111

Const As Single LIGHT_DEC_PER_SEC = 0.5

Function createSprite(src As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadSprite Ptr model = New QuadSprite(src, src->w(), src->h())
	model->setZSortAdjust(-1000)
	Return model
End Function
	
Function addCreateModelActor(parent As ActorBankFwd Ptr, src As Image32 Ptr) As ModelActor Ptr
	Dim As ModelActor Ptr newDecorativeActor = New DecorativeModel(parent, createSprite(src))
	CPtr(ActorBank Ptr, parent)->add(newDecorativeActor)
	Return newDecorativeActor
End Function

Function createDoorwayModel() As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(32, 32), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {TextureCache.get("res/litdoorway.png")}
	Return New QuadModel( _
			Vec3F(32, 32, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)	
End Function
	
Constructor MenuController(parent As ActorBankFwd Ptr, ByRef bounds As Const AABB)
	Base.Constructor(parent)
	setType()
	
	This.titleActor_ = addCreateModelActor(parent, TextureCache.get("res/title.png"))
	This.titleActor_->getModel()->translate(Vec3F(175, 148, -80))
	
	This.arrowActor_ = addCreateModelActor(parent, TextureCache.get("res/darrow.png"))
	This.arrowActor_->getModel()->translate(Vec3F(ARROW_X_CENTER + PLAYER_X_DELTA*0.5, 68, 0))
	This.arrowActor_->getModel()->hide()	
	
	This.doorwayActor_ = New DecorativeModel(parent, createDoorwayModel())
	CPtr(ActorBank Ptr, parent)->add(This.doorwayActor_)
	This.doorwayActor_->getModel()->translate(Vec3F(bounds.o.x, bounds.o.y, -23.9))	
	
	AudioController.cacheSample("res/rollup.wav")
	AudioController.cacheSample("res/place.wav")
	AudioController.cacheSample("res/snap.wav")
		
	This.bounds_ = bounds
	This.introRoll_ = 0
	This.resetScreen_ = FALSE
	This.t_ = 0
	This.isMatt_ = FALSE
	This.lightFade_ = 1
	This.activatePlayerCountup_ = -1
End Constructor
	
Function MenuController.update(dt As Double) As Boolean
	Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	If introRoll_ = 0 Then
		player_->getModel()->hide()
		player_->setLockState(LockState.IDLE)
		player_->setCameraRelease(TRUE)
	End If 
	camera->snap(bounds_.o + bounds_.s*0.5 + Vec2F(0, 39), 0)	
	introRoll_ += 1
	Dim As Single introTime = introRoll_*dt 'const
	
	Dim As DrawBufferInterface Ptr dbInterface = @GET_GLOBAL("DRAWBUFFER INTERFACE", DrawBufferInterface)
	If activatePlayerCountup_ = -1 Then
		Dim As Overlay Ptr overlay_ = @GET_GLOBAL("OVERLAY", Overlay)
		If Not resetScreen_ Then 
			dbInterface->setLightScale(0)
			If introTime > 11 Then
				resetScreen_ = TRUE
				AudioController.playMusic()
				dbInterface->setGlobalLightMinMax(0, 0.5)	
				dbInterface->setLightScale(1.0)
				titleActor_->getModel()->setDrawMode(QuadTextureMode.TEXTURED)
			ElseIf introTime > 9 Then 
				overlay_->textLine("")
			ElseIf introTime > 7 Then
				AudioController.playSample("res/rollup.wav")
			ElseIf introTime > 6 Then
				overlay_->textLine("...and wonder how you ended up here?")
			ElseIf introTIme > 5 Then
				overlay_->textLine("")
			ElseIf introTime > 2 Then
				overlay_->textLine("Do you ever look back on the past...")
			Else
				overlay_->textLine("")			
			EndIf
		ElseIf introTime > 14 Then
			overlay_->textLine("Press X")
			arrowActor_->getModel()->show()
			If MultiKey(fb.SC_LEFT) Then 
				If Not isMatt_ Then 
					arrowActor_->getModel()->translate(Vec3F(-1, 0, 0)*PLAYER_X_DELTA)
					AudioController.playSample("res/place.wav", Vec2F(0, 500))
				EndIf
	
				isMatt_ = TRUE
			ElseIf MultiKey(fb.SC_RIGHT) Then
				If isMatt_ Then 
					arrowActor_->getModel()->translate(Vec3F(1, 0, 0)*PLAYER_X_DELTA)
					AudioController.playSample("res/place.wav", Vec2F(0, 500))
				EndIf
	
				isMatt_ = FALSE
			EndIf
			
			If MultiKey(fb.SC_X) Then
				camera->flashIn()
				AudioController.fadeOut()
				titleActor_->getModel()->setDrawMode(QuadTextureMode.TEXTURED_CONST)
				arrowActor_->getModel()->hide()	
				overlay_->textLine("")
				activatePlayerCountup_ = 0
				AudioController.playSample("res/snap.wav")
				player_->getModel()->show()
				player_->getModel()->setDrawMode(QuadTextureMode.TEXTURED)
				doorwayActor_->getModel()->setDrawMode(QuadTextureMode.TEXTURED)
				Dim As FakePlayer Ptr fakePlayer_ = @GET_GLOBAL(IIf(isMatt_, "MAMBAZO", "ZAMASTER"), FakePlayer)
				fakePlayer_->getModel()->hide()
				Dim As Vec2F goP = Vec2F(IIf(isMatt_, 112, 224), bounds_.o.y)	
				player_->place(goP, isMatt_)
				player_->setIsMatt(isMatt_)
			EndIf
		End If
		Dim As Double drift = Sin(t_ * 6.28318530718 * 0.9)*0.3 'const
		t_ += dt
		arrowActor_->getModel()->translate(Vec3F(0, 1, 0)*drift)
	Else
		dbInterface->setLightScale(lightFade_)
		lightFade_ -= dt*LIGHT_DEC_PER_SEC
		If lightFade_ < 0 Then 
			lightFade_ = 0
			player_->setLockState(LockState.NONE)
			Dim As FakePlayer Ptr fakePlayer_ = @GET_GLOBAL(IIf(isMatt_, "ZAMASTER", "MAMBAZO"), FakePlayer)
			fakePlayer_->getModel()->hide()
		EndIf
		activatePlayerCountup_ += 1 
	End If
	Return FALSE
End Function

Sub MenuController.notify()
	''
End Sub
	
Function MenuController.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace