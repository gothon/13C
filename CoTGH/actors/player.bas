#Include "player.bi"

#Include "../physics.bi"
#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../texturecache.bi"
#Include "../quadmodel.bi"

#Include "fbgfx.bi"

Const As Double GROUND_SPEED = 18
Const As Double GROUND_FRICTION = 0.75

Const As Double AIR_SPEED = 3
Const As Double AIR_FRICTION = 0.99

Const As Double MAX_HORIZONTAL_SPEED = 50

Const As UInteger JUMP_BOOST_FRAMES = 15

Const As Double JUMP_INIT_VEL = 45
Const As Double JUMP_BOOST_VEL = 45
Const As Double JUMP_BOOST_DECAY = 0.7

Const As UInteger LANDING_JUMP_GRACE_FRAMES = 3
Const As UInteger FALLING_JUMP_GRACE_FRAMES = 4

Const As UInteger WARP_ANIM_COUNTDOWN = 60

#Define CAMERA_BUFFER_TL Vec2F(150, 100)
#Define CAMERA_BUFFER_BR Vec2F(150, 80)

Namespace act
ACTOR_REQUIRED_DEF(Player, ActorTypes.PLAYER)
	
#Define COL_PTR CPtr(DynamicAABB Ptr, collider_)
	
Constructor Player( _
		parent As ActorBankFwd Ptr, _
		model As QuadModelBase Ptr, _
		colliderPtr As ColliderFwd Ptr, _
		animImage As Image32 Ptr)
	Base.Constructor(parent, model, colliderPtr)
	setType()
	setKey("PLAYER")
	
	Dim As Vec2f translate = COL_PTR->getAABB().o + COL_PTR->getAABB().s*0.5 
	This.model_->translate(Vec3F(translate.x, translate.y, 0))

	This.facingRight_ = TRUE

	animImage->setOffset(16, 0)
	
	This.animImage_ = animImage
	This.animImage_->bindIn(TextureCache.get("res/mambazo.png"))
	This.lastDownPressed_ = FALSE
	This.downLHEdge_ = FALSE
	This.destinationPortal_ = ""
	This.grounded_ = FALSE
	This.lastJumpPressed_ = FALSE
	This.jumpBoostCounter_ = 0
	This.bonk_ = FALSE
	This.lastGroundedCountdown_ = 0
	This.lastGrounded_ = FALSE
	This.airbornJumpRequestCountdown_ = 0
	This.walkFrame_ = -1
	This.walkFrameDelay_ = 0
	This.idleFrame_ = -1
	This.lastActivatePressed_ = FALSE
 	This.activateLHEdge_ = FALSE
 	This.clonedIndex_ = NULL
 	This.snapshot_ = NULL
 	This.cloneRequested_ = FALSE
 	This.lastSwapPressed_ = FALSE
 	This.isSnapshotting_ = TRUE
 	This.isWarped_ = FALSE
 	This.embedId_ = -1
 	This.warpCountdown_ = 0
End Constructor

Destructor Player()
	Delete(animImage_)
	If snapshot_ <> NULL Then Delete(snapshot_)
	If clonedIndex_ <> NULL Then
		Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
		graph->deleteIndex(@clonedIndex_)
	EndIf
End Destructor

Sub Player.updateCamera()
	Dim As Boolean cameraRight = facingRight_

	Dim As Vec2F guideTarget = COL_PTR->getAABB().o + COL_PTR->getAABB().s*0.5
	Dim As Vec2F cameraBound = GET_GLOBAL("STAGEMANAGER", StageManager).getMapDims() _
			- Vec2F(CAMERA_BUFFER_BR.x, CAMERA_BUFFER_TL.y)
	
	If guideTarget.x < CAMERA_BUFFER_TL.x Then 
		guideTarget.x = CAMERA_BUFFER_TL.x
		cameraRight = FALSE
	ElseIf guideTarget.x > cameraBound.x Then
		guideTarget.x = cameraBound.x
		cameraRight = TRUE
	EndIf
 
	If guideTarget.y < CAMERA_BUFFER_BR.y Then 
		guideTarget.y = CAMERA_BUFFER_BR.y
	ElseIf guideTarget.y > cameraBound.y Then
		guideTarget.y = cameraBound.y
	EndIf

	GET_GLOBAL("CAMERA INTERFACE", CameraInterface).guide(guideTarget, cameraRight)	
End Sub

Sub Player.flipXUV()
	Dim As Quad Ptr q = model_->getQuad(0)
	Swap q->v(0).t.x, q->v(1).t.x
	Swap q->v(2).t.x, q->v(3).t.x
End Sub

Sub Player.setWarp(p As Vec2F, v As Vec2F)
	isWarped_ = TRUE
	warpP_ = p
	warpV_ = v
End Sub

Sub Player.checkArbiters()
	lastGrounded_ = grounded_
	grounded_ = FALSE
	bonk_ = FALSE
	For i As Integer = 0 to COL_PTR->getArbiters().size() - 1
		Dim As Arbiter Ptr arb = @(COL_PTR->getArbiters()[i])
		If arb->onAxis And AxisComponent.Y_N Then grounded_ = TRUE
		If arb->onAxis And AxisComponent.Y_P Then bonk_ = TRUE
	Next i
	If (Not grounded_) AndAlso lastGrounded_ Then lastGroundedCountdown_ = FALLING_JUMP_GRACE_FRAMES
End Sub

Sub Player.processPlatformingControls()
	Dim As Double speed = IIf(grounded_, GROUND_SPEED, AIR_SPEED)
	Dim As Double friction = IIf(grounded_, GROUND_FRICTION, AIR_FRICTION)
	If MultiKey(fb.SC_LEFT) Then 
		COL_PTR->setV(COL_PTR->getV() + Vec2F(-speed, 0))
		If facingRight_ = TRUE Then flipXUV()
		facingRight_ = FALSE
	EndIf
	If MultiKey(fb.SC_RIGHT) Then 
		COL_PTR->setV(COL_PTR->getV() + Vec2F(speed, 0))
		If facingRight_ = FALSE Then flipXUV()
		facingRight_ = TRUE
	EndIf
	COL_PTR->setV(Vec2F(COL_PTR->getV().x*friction, COL_PTR->getV().y))
	If COL_PTR->getV().x > MAX_HORIZONTAL_SPEED Then
		COL_PTR->setV(Vec2F(MAX_HORIZONTAL_SPEED, COL_PTR->getV().y))	
	ElseIf COL_PTR->getV().x < -MAX_HORIZONTAL_SPEED Then
		COL_PTR->setV(Vec2F(-MAX_HORIZONTAL_SPEED, COL_PTR->getV().y))			
	EndIf

	If bonk_ Then jumpBoostCounter_ = 0
	If airbornJumpRequestCountdown_ > 0 Then airbornJumpRequestCountdown_ -= 1
	Dim As Boolean queuedJumpRequest = _
			((airbornJumpRequestCountdown_ > 0) AndAlso (grounded_ AndAlso (Not lastGrounded_))) 'const
	If MultiKey(fb.SC_Z) OrElse queuedJumpRequest Then
		If (lastJumpPressed_ = FALSE) OrElse queuedJumpRequest Then
			If grounded_ OrElse (lastGroundedCountdown_ > 0) Then
				COL_PTR->setV(Vec2F(COL_PTR->getV().x, JUMP_INIT_VEL))			
				jumpBoostCounter_ = JUMP_BOOST_FRAMES
			ElseIf Not grounded_ Then
				airbornJumpRequestCountdown_ = LANDING_JUMP_GRACE_FRAMES
			EndIf 
		EndIf
		lastJumpPressed_ = TRUE
	Else
		lastJumpPressed_ = FALSE
		jumpBoostCounter_ = 0
		If grounded_ Then jumpBoostCounter_ = 0
	EndIf
	If jumpBoostCounter_ > 0 Then
		jumpBoostCounter_ -= 1
		Dim As Double boostAmount = JUMP_BOOST_VEL*(JUMP_BOOST_DECAY^(JUMP_BOOST_FRAMES - jumpBoostCounter_)) 'const
		COL_PTR->setV(COL_PTR->getV() + Vec2F(0, boostAmount))	
	EndIf	
	If grounded_ Then airbornJumpRequestCountdown_ = 0
	
	downLHEdge_ = FALSE
	If MultiKey(fb.SC_UP) Then 
		If lastDownPressed_ = FALSE Then downLHEdge_ = TRUE
		lastDownPressed_ = TRUE	
	Else
		lastDownPressed_ = FALSE
	EndIf
	
	activateLHEdge_ = FALSE
	If MultiKey(fb.SC_X) Then 
		If lastActivatePressed_ = FALSE Then activateLHEdge_ = TRUE
		lastActivatePressed_ = TRUE	
	Else
		lastActivatePressed_ = FALSE
	EndIf
	
	If MultiKey(fb.SC_SPACE) Then 
		If lastSwapPressed_ = FALSE Then isSnapshotting_ = Not isSnapshotting_
		lastSwapPressed_ = TRUE	
	Else
		lastSwapPressed_ = FALSE
	EndIf
End Sub

Sub Player.disableCollision()
	COL_PTR->setEnabled(FALSE)
End Sub

Sub Player.processInteractions()
	Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
	If Not isSnapshotting_ Then Return
	Locate 1,1: Print "READY TO SNAPSHOT"
	If Not cloneRequested_ Then
		If activateLHEdge_ Then 
			If snapshot_ <> NULL Then
				graph->deleteIndex(@clonedIndex_)
				Delete(snapshot_)
				snapshot_ = NULL
			EndIf
			graph->requestClone()
			cloneRequested_ = TRUE
		EndIf
	Else
		cloneRequested_ = FALSE
		clonedIndex_ = graph->getClone()
		
		Dim As SnapshotInterface Ptr snapInterface = @GET_GLOBAL("SNAPSHOT INTERFACE", SnapshotInterface)
		snapshot_ = snapInterface->createSnapshot()
		snapshotP_ = COL_PTR->getAABB().o
		snapshotV_ = COL_PTR->getV()
		
		Dim As CameraInterface Ptr camera_ = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
		snapshotFacingRight_ = facingRight_
		snapshotLeadingX_ = camera_->getLeadingX()
	EndIf 
End Sub

Const Function Player.hasSnapshot() As Boolean
	Return snapshot_ <> NULL
End Function

Sub Player.placeSnapshot(replaceId As UInteger)
	DEBUG_ASSERT(snapshot_ <> NULL)
	GET_GLOBAL("GRAPH INTERFACE", GraphInterface).embed(clonedIndex_, replaceId, @embedId_)	
	clonedIndex_ = NULL
End Sub

Const Function Player.readyToPlace() As Boolean
	Return embedId_ <> -1
End Function

Sub Player.claimSnapshot( _
		embedId As UInteger Ptr, _
		snapshot As Image32 Ptr Ptr, _
		snapshotP As Vec2F Ptr, _
		snapshotV As Vec2F Ptr)
	DEBUG_ASSERT(snapshot_ <> NULL)
	*embedId = embedId_
	embedId_ = -1
	
	*snapshot = snapshot_
	snapshot_ = NULL
	
	*snapshotP = snapshotP_
	*snapshotV = snapshotV_
End Sub

Function Player.update(dt As Double) As Boolean
	Dim As CameraInterface Ptr camera_ = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	If GET_GLOBAL("TRANSITION NOTIFIER", TransitionNotifier).happened() Then
		COL_PTR->setEnabled(TRUE)
		Dim As Vec2F spawnP = Any
		If isWarped_ Then
			isWarped_ = FALSE	
			spawnP = warpP_
			COL_PTR->setV(warpV_)
			camera_->snap(Vec2F(0, 0), snapshotLeadingX_)
			If facingRight_ Then 
				If Not snapshotFacingRight_ Then flipXUV()
			Else
				If snapshotFacingRight_ Then flipXUV()
			EndIf
			facingRight_ = snapshotFacingRight_
		ElseIf destinationPortal_ = "" Then 
			spawnP = GET_GLOBAL("SPAWN", Spawn).getP()
		Else
			Dim As Portal Ptr portal_ = @GET_GLOBAL(StrPtr(destinationPortal_), Portal)			
			If portal_->getMode() = PortalEnterMode.FROM_LEFT Then
				camera_->snap(camera_->getP(), 99999)
			ElseIf portal_->getMode() = PortalEnterMode.FROM_RIGHT Then
				camera_->snap(camera_->getP(), -99999)					
			EndIf
			If portal_->getMode() <> PortalEnterMode.FROM_CENTER Then portal_->waitForNoIntersect()
			spawnP = portal_->getRegion().o
		EndIf 
		Dim As Vec2F diff = spawnP - COL_PTR->getAABB().o
		COL_PTR->place(spawnP)
		model_->translate(Vec3F(diff.x, diff.y, 0))
		model_->translate(COL_PTR->getDelta())
		warpCountdown_ = WARP_ANIM_COUNTDOWN
	Else
		model_->translate(COL_PTR->getDelta())
	EndIf
	updateCamera()
	
	checkArbiters()
	processPlatformingControls()
	processAnimation()
	processInteractions()
	
	If lastGroundedCountdown_ > 0 Then lastGroundedCountdown_ -= 1
	If warpCountdown_ > 0 Then warpCountdown_ -= 1
	
	Return FALSE
End Function

Const As UInteger PLAYER_FRAME_WIDTH = 16
Const As UInteger JUMP_FRAME = 6

Const As Double WALK_ANIM_VEL_THRESH = 5

Const As UInteger WALK_SPEED = 2

Sub Player.processAnimation()
	Dim As UInteger curFrame = 0
	
	Dim As Double scaledXSpeed = 1.0 - (Abs(COL_PTR->getV().x) / MAX_HORIZONTAL_SPEED)
	walkSpeed_ = 4 + (WALK_SPEED*scaledXSpeed)^2
	
	If grounded_ Then
		If (Abs(COL_PTR->getV().x) > WALK_ANIM_VEL_THRESH) OrElse (walkFrame_ = 0) OrElse (walkFrame_ = 2) Then
			If walkFrame_ = -1 Then
				walkFrameDelay_ = 0
				walkFrame_ = 0
			EndIf
			curFrame = 6 + walkFrame_
			idleFrame_ = -1
		Else 
			walkFrame_ = -1
			walkFrameDelay_ = 0
			If idleFrame_ = -1 Then
				If Int(Rnd * 50) = 0 Then
					If Int(Rnd * 12) > 0 Then
						idleFrame_ = 1
						idleEndFrame_ = 2
						idleFrameSpeed_ = 3
					ElseIf warpCountdown_ = 0 Then 
						idleFrame_ = 2
						idleEndFrame_ = 6
						idleFrameSpeed_ = 10
					EndIf
					idleFrameDelay_ = idleFrameSpeed_
				EndIf
			Else
				idleFrameDelay_ -= 1
				If idleFrameDelay_ = 0 Then
					idleFrameDelay_ = idleFrameSpeed_
					idleFrame_ += 1
					If idleFrame_ = idleEndFrame_ Then idleFrame_ = -1
				EndIf
			EndIf
			curFrame = IIf(idleFrame_ <> -1, idleFrame_, 0)
		EndIf
	Else
		curFrame = JUMP_FRAME
		walkFrame_ = -1
	EndIf
	If walkFrame_ <> -1 Then 
		walkFrameDelay_ = (walkFrameDelay_ + 1) Mod walkSpeed_
		If walkFrameDelay_ = 0 Then walkFrame_ = (walkFrame_ + 1) Mod 4
	EndIf 
	
	animImage_->setOffset(curFrame * PLAYER_FRAME_WIDTH, 0)
End Sub

Const Function Player.pressedDown() As Boolean
	Return downLHEdge_
End Function

Const Function Player.pressedActivate() As Boolean
	Return activateLHEdge_ AndAlso (Not isSnapshotting_)
End Function

Const Function Player.getBounds() ByRef As Const AABB
	Return COL_PTR->getAABB()
End Function

Sub Player.setDestinationPortal(dest As Const ZString Ptr)
	destinationPortal_ = *dest
End Sub

Sub Player.notify()
	''
End Sub

Function Player.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace