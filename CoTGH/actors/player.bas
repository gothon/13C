#Include "player.bi"

#Include "../physics.bi"
#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../texturecache.bi"
#Include "../quadmodel.bi"
#Include "../indexgraph.bi"
#Include "../darray.bi"
#Include "../primitive.bi"
#Include "../audiocontroller.bi"

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

Const As Integer STATUE_ADJUST_X = 7
Const As Integer STATUE_ADJUST_Y = 6

Const As Integer FREEZE_DIE_FRAMES = 4

Const As Integer WARP_PARALYZE_DELAY = 3

#Define CAMERA_BUFFER_TL Vec2F(150, 100)
#Define CAMERA_BUFFER_BR Vec2F(150, 80)

DECLARE_DARRAY(AnyPtr)

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
	AudioController.cacheSample("res/oops.wav")
	AudioController.cacheSample("res/snap.wav")
	AudioController.cacheSample("res/scratch.wav")
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
 	This.carryingStatue_ = FALSE
 	This.fakeStatuePtr_ = NULL
 	This.firstPickUp_ = FALSE
 	This.statuePlaceCountdown_ = 0
 	This.lockState_ = LockState.NONE
 	This.warpLock_ = FALSE
 	This.resetIndex_ = NULL
 	This.waitingForResetIndex_ = FALSE
 	This.standingOnStatic_ = FALSE
 	This.onIsland_ = FALSE
 	This.freezeAfterDie_ = 0
 	This.warpParalyzeCountdown_ = 0
End Constructor

Destructor Player()
	Delete(animImage_)
	If snapshot_ <> NULL Then Delete(snapshot_)
	If clonedIndex_ <> NULL Then ig_DeleteIndex(@clonedIndex_)
	If resetIndex_ <> NULL Then ig_DeleteIndex(@resetIndex_)
End Destructor

Sub Player.updateCamera(snapToTarget As Boolean)
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

	Dim As CameraInterface Ptr interface = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	If snapToTarget Then 
		interface->snap(guideTarget, interface->getLeadingX())
	Else
		interface->guide(guideTarget, cameraRight)
	EndIf	
End Sub

Sub Player.flipXUV()
	Dim As Quad Ptr q = model_->getQuad(0)
	Swap q->v(0).t.x, q->v(1).t.x
	Swap q->v(2).t.x, q->v(3).t.x
End Sub

Sub Player.setWarp( _
			p As Vec2F, _
			v As Vec2F, _
			leadingX As Double, _
			musicPosition As LongInt, _
			facingRight As Boolean)
	isWarped_ = TRUE
	warpP_ = p
	warpV_ = v
	warpLeadingX_ = leadingX
	warpMusicPosition_ = musicPosition
	warpFacingRight_ = facingRight
End Sub

Sub Player.checkArbiters()
	lastGrounded_ = grounded_
	grounded_ = FALSE
	bonk_ = FALSE
	standingOnStatic_ = FALSE
	For i As Integer = 0 to COL_PTR->getArbiters().size() - 1
		Dim As Arbiter Ptr arb = @(COL_PTR->getArbiters()[i])
		If arb->onAxis And AxisComponent.Y_N Then 
			grounded_ = TRUE
			If arb->actorRef->getType() = ActorTypes.DECORATIVE_COLLIDER Then standingOnStatic_ = TRUE
		EndIf
		If arb->onAxis And AxisComponent.Y_P Then bonk_ = TRUE
	Next i
	If (Not grounded_) AndAlso lastGrounded_ Then lastGroundedCountdown_ = FALLING_JUMP_GRACE_FRAMES
End Sub

Sub Player.processPlatformingControls()
	Dim As Double speed = IIf(grounded_, GROUND_SPEED, AIR_SPEED)*IIf(carryingStatue_, 0.9, 1.0)
	Dim As Double friction = IIf(grounded_, GROUND_FRICTION, AIR_FRICTION)*IIf(carryingStatue_, 0.95, 1.0)
	If ((lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_LEFT)) OrElse (lockState_ = LockState.WALK_LEFT) Then 
		COL_PTR->setV(COL_PTR->getV() + Vec2F(-speed, 0))
		If facingRight_ = TRUE Then 
			If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(Vec3F(-STATUE_ADJUST_X*2, 0, 0))
			flipXUV()
		EndIf
		facingRight_ = FALSE
	EndIf
	If ((lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_RIGHT)) OrElse (lockState_ = LockState.WALK_RIGHT) Then
		COL_PTR->setV(COL_PTR->getV() + Vec2F(speed, 0))
		If facingRight_ = FALSE Then 
			If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(Vec3F(STATUE_ADJUST_X*2, 0, 0))
			flipXUV()
		EndIf
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
	If (lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_Z) OrElse queuedJumpRequest Then
		If (lastJumpPressed_ = FALSE) OrElse queuedJumpRequest Then
			If grounded_ OrElse (lastGroundedCountdown_ > 0) Then
				COL_PTR->setV(Vec2F(COL_PTR->getV().x, JUMP_INIT_VEL*IIf(carryingStatue_, 0.75, 1.0)))			
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
		Dim As Double boostAmount = _
				JUMP_BOOST_VEL*(JUMP_BOOST_DECAY^(JUMP_BOOST_FRAMES - jumpBoostCounter_))*IIf(carryingStatue_, 0.75, 1.0) 'const
		COL_PTR->setV(COL_PTR->getV() + Vec2F(0, boostAmount))	
	EndIf	
	If grounded_ Then airbornJumpRequestCountdown_ = 0
	
	downLHEdge_ = FALSE
	If (lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_UP) Then 
		If lastDownPressed_ = FALSE Then downLHEdge_ = TRUE
		lastDownPressed_ = TRUE	
	Else
		lastDownPressed_ = FALSE
	EndIf
	
	activateLHEdge_ = FALSE
	If (lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_X) Then 
		If lastActivatePressed_ = FALSE Then activateLHEdge_ = TRUE
		lastActivatePressed_ = TRUE	
	Else
		lastActivatePressed_ = FALSE
	EndIf
	
	If (lockState_ = LockState.NONE) AndAlso MultiKey(fb.SC_SPACE) AndAlso (Not cloneRequested_) Then 
		If lastSwapPressed_ = FALSE Then isSnapshotting_ = Not isSnapshotting_
		lastSwapPressed_ = TRUE	
	Else
		lastSwapPressed_ = FALSE
	EndIf
End Sub

Sub Player.setLockState(state As LockState)
	lockState_ = state
End Sub

Sub Player.disableCollision()
	COL_PTR->setEnabled(FALSE)
End Sub

Sub Player.claimCarryable(statue As Actor Ptr)
	carryableStatues_.push(statue)
End Sub

Sub Player.processStatues()
	If Not activateLHEdge_ Then Return
	If cloneRequested_ Then Return
	If carryingStatue_ Then Return
	For i As Integer = 0 To carryableStatues_.size() - 1
		Dim As Statue Ptr statue_ = CPtr(Statue Ptr, carryableStatues_[i].getValue())
		Dim As Const AABB Ptr statueAabb = @(CPtr(DynamicAABB Ptr, statue_->getCollider)->getAABB())	
		Dim As Boolean statueToRight = (statueAabb->o.x - COL_PTR->getAABB().o.x) > 0
		If facingRight_ Eqv statueToRight Then
			statue_->collect()
			carryingStatue_ = TRUE
			fakeStatuePtr_ = New FakeStatue(parent_)
			
			Dim As QuadModelBase Ptr fakeStatueModel = fakeStatuePtr_->getModel()
			
			fakeStatueModel->translate(Vec2F(-FAKE_STATUE_WIDTH*0.5, 0))
			fakeStatueModel->translate(COL_PTR->getAABB().o + Vec2F(COL_PTR->getAABB().s.x*0.5, 0))
			
			fakeStatueModel->translate(Vec3F(IIf(facingRight_, STATUE_ADJUST_X - 1, -STATUE_ADJUST_X - 0.5), STATUE_ADJUST_Y, 0.0))
			CPtr(ActorBank Ptr, parent_)->add(fakeStatuePtr_)
			firstPickUp_ = TRUE
			Exit For
		EndIf
	Next i		
End Sub

Sub Player.processInteractions()
	processStatues()
	carryableStatues_.clear()
	
	Dim As CameraInterface Ptr camera_ = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
	If resetIndex_ = NULL AndAlso (Not waitingForResetIndex_) Then
		graph->requestClone()
		resetIndexLeadingX_ = camera_->getLeadingX()
		resetIndexFacingRight_ = facingRight_
		waitingForResetIndex_ = TRUE
		Return
	ElseIf waitingForResetIndex_ Then
		resetIndex_ = graph->getClone()
		waitingForResetIndex_ = FALSE
	EndIf
	
	If Not isSnapshotting_ Then Return
	If carryingStatue_ Then Return

	If Not cloneRequested_ Then
		If activateLHEdge_ Then 
			If snapshot_ <> NULL Then
				graph->deleteIndex(@clonedIndex_)
				Delete(snapshot_)
				snapshot_ = NULL
			EndIf
			camera_->flashIn()
			graph->requestClone()
			cloneRequested_ = TRUE
			AudioController.playSample("res/snap.wav")
		EndIf
	Else
		cloneRequested_ = FALSE
		clonedIndex_ = graph->getClone()
		
		Dim As SnapshotInterface Ptr snapInterface = @GET_GLOBAL("SNAPSHOT INTERFACE", SnapshotInterface)
		snapshot_ = snapInterface->getSnapshot()
		snapshotP_ = COL_PTR->getAABB().o
		snapshotV_ = COL_PTR->getV()
		
		snapshotFacingRight_ = facingRight_
		snapshotLeadingX_ = camera_->getLeadingX()
		snapshotMusicPosition_ = AudioController.getPlaybackPosition()
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
		snapshotV As Vec2F Ptr, _
		snapshotLeadingX As Double Ptr, _
		snapshotMusicPosition As LongInt Ptr, _
		snapshotFacingRight As Boolean Ptr)
	DEBUG_ASSERT(snapshot_ <> NULL)
	*embedId = embedId_
	embedId_ = -1
	
	*snapshot = snapshot_
	snapshot_ = NULL
	
	*snapshotP = snapshotP_
	*snapshotV = snapshotV_
	
	*snapshotLeadingX = snapshotLeadingX_
	*snapshotMusicPosition = snapshotMusicPosition_
	
	*snapshotFacingRight = snapshotFacingRight_
End Sub

Function Player.update(dt As Double) As Boolean
	Dim As CameraInterface Ptr camera_ = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
	Dim As Boolean snapCamera = FALSE
	If GET_GLOBAL("TRANSITION NOTIFIER", TransitionNotifier).happened() Then
		snapCamera = TRUE
		carryableStatues_.clear() 
		COL_PTR->setEnabled(TRUE)
		Dim As Vec2F spawnP = Any
		If isWarped_ Then
			isWarped_ = FALSE	
			spawnP = warpP_
			COL_PTR->setV(warpV_)
			camera_->snap(Vec2F(0, 0), warpLeadingX_)
			If facingRight_ Then 
				If Not warpFacingRight_ Then 
					If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(Vec3F(-STATUE_ADJUST_X*2, 0, 0))
					flipXUV()
				EndIf
			Else
				If warpFacingRight_ Then 
					If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(Vec3F(STATUE_ADJUST_X*2, 0, 0))
					flipXUV()
				EndIf
			EndIf
			facingRight_ = warpFacingRight_
			AudioController.switchMusic(NULL, warpMusicPosition_)
			setLockState(LockState.NONE)
			warpParalyzeCountdown_ = WARP_PARALYZE_DELAY
			camera_->setMulMixPercent(0.75, 0.01)
		ElseIf destinationPortal_ = "" Then 
			spawnP = GET_GLOBAL("SPAWN", Spawn).getP()
		Else
			Dim As Portal Ptr portal_ = @GET_GLOBAL(StrPtr(destinationPortal_), Portal)	
			Select Case portal_->getMode()
				Case PortalEnterMode.FROM_LEFT
					camera_->snap(camera_->getP(), 99999)
					portal_->waitForNoIntersect()
					spawnP = portal_->getRegion().o + Vec2F(portal_->getRegion().s.x - COL_PTR->getAABB().s.x, 0)
					warpLock_ = TRUE
				Case PortalEnterMode.FROM_RIGHT
					camera_->snap(camera_->getP(), -99999)		
					portal_->waitForNoIntersect()	
					spawnP = portal_->getRegion().o
					warpLock_ = TRUE
				Case PortalEnterMode.FROM_CENTER
					spawnP = portal_->getRegion().o + Vec2F((portal_->getRegion().s.x - COL_PTR->getAABB().s.x)*0.5, 0)
					lockState_ = LockState.NONE
				Case Else
					DEBUG_ASSERT(FALSE)
			End Select	
			Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
			camera->fadeIn()
			intersectPortalBounds_ = portal_->getRegion()
		EndIf 
		Dim As Vec2F diff = spawnP - COL_PTR->getAABB().o
		COL_PTR->place(spawnP)
		Dim As Vec3F modelTranslate = Vec3F(diff.x, diff.y, 0) + Vec3F(COL_PTR->getDelta())
		If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(modelTranslate)
		model_->translate(modelTranslate)
		warpCountdown_ = WARP_ANIM_COUNTDOWN
		AudioController.fadeIn()
	Else
		model_->translate(COL_PTR->getDelta())
		If fakeStatuePtr_ <> NULL Then fakeStatuePtr_->getModel()->translate(COL_PTR->getDelta())
		
		Dim As StageManager Ptr stageManager_ = @GET_GLOBAL("STAGEMANAGER", StageManager)
		Dim As SimulationInterface Ptr sim_ = @GET_GLOBAL("SIMULATION INTERFACE", SimulationInterface)
		If sim_->getIntersectsBlockGrid(COL_PTR->getAABB()) = BlockType.SIGNAL Then
			If carryingStatue_ Then 
				carryingStatue_ = FALSE	
				DEBUG_ASSERT(fakeStatuePtr_ <> NULL)
				CPtr(ActorBank Ptr, parent_)->remove(fakeStatuePtr_)
				fakeStatuePtr_ = NULL
			End If
			
			AudioController.playSample("res/oops.wav")
			Dim As Vec2F warpBackPos = stageManager_->getDelayPosition()

	 		freezeAfterDie_ = FREEZE_DIE_FRAMES
	 		lockState_ = LockState.IDLE
			Dim As Vec2F playerModelTranslate = warpBackPos - COL_PTR->getAABB().o 'const
			COL_PTR->place(warpBackPos)	
			model_->translate(playerModelTranslate)	
			camera_->bleedIn()
			COL_PTR->setV(Vec2F(0, 0))
			If snapshot_ <> NULL Then
				ig_DeleteIndex(@clonedIndex_)
				Delete(snapshot_)
				snapshot_ = NULL
			EndIf
			snapCamera = TRUE
		ElseIf standingOnStatic_ AndAlso (Not onIsland_) Then
			stageManager_->updateDelayPosition(COL_PTR->getAABB().o)
		End If
	EndIf
	If warpLock_ Then
		If Not intersectPortalBounds_.intersects(COL_PTR->getAABB()) Then 
			lockState_ = LockState.NONE
			warpLock_ = FALSE
		EndIf
	EndIf
	If freezeAfterDie_ > 0 Then
		freezeAfterDie_ -= 1
		If freezeAfterDie_ = 1 Then lockState_ = LockState.NONE
	EndIf 
		
	updateCamera(snapCamera)
	
	checkArbiters()
	processPlatformingControls()
	processAnimation()
	processInteractions()
	processCarrying()
	
	If lastGroundedCountdown_ > 0 Then lastGroundedCountdown_ -= 1
	If warpCountdown_ > 0 Then warpCountdown_ -= 1
	If statuePlaceCountdown_ > 0 Then statuePlaceCountdown_ -= 1
	If warpParalyzeCountdown_ > 0 Then warpParalyzeCountdown_ -= 1
	firstPickUp_ = FALSE
	onIsland_ = FALSE
	
	'''
	/'
	Print "JUMP = Z"
	Print "SWITCH MODE = SPACE"
	Print "SNAPSHOT/PLACE/PICK-UP/PLACE = X"
	Print "ENTER = UP"
	Print "HAS SNAPSHOT? " + Str(snapshot_ <> NULL)
	Print "MODE: " + IIf(isSnapshotting_, "SNAPSHOT MODE", "PLACEMENT MODE")
	'/
	'''
	
	Return FALSE
End Function

Sub Player.setOnIsland()
	onIsland_ = TRUE
End Sub

Sub Player.processCarrying()
	If Not carryingStatue_ Then Return
	If Not activateLHEdge_ Then Return
	If Not grounded_ Then Return
	If firstPickUp_ Then Return
	
	Dim As AABB targetBox = _
			AABB(COL_PTR->getAABB().o + Vec2F(IIf(facingRight_, COL_PTR->getAABB().s.x, -16)), Vec2F(16, 32))
	
	Dim As Double boxStartX = targetBox.o.x 'const	
	Dim As SimulationInterface Ptr sim = @GET_GLOBAL("SIMULATION INTERFACE", SimulationInterface)
	
	Dim As Double shiftDir = IIf(facingRight_, -1, 1)
	Dim As AABB playerBox = COL_PTR->getAABB()
	Dim As Boolean canPlace = TRUE
	Dim As Boolean movePlayer = TRUE
	Do
		Dim As AABB testBox = targetBox
		testBox.o += Vec2F(0, 1)
		testBox.s -= Vec2F(0, 2)
		
		Dim As DArray_AnyPtr statueIntersects = sim->getIntersects(testBox)
		Dim As Boolean relevantIntersects = FALSE
		For i As Integer = 0 To statueIntersects.size() - 1
			If statueIntersects[i].getValue() <> @This Then 
				relevantIntersects = TRUE
				Exit For
			EndIf
		Next i
		If Not relevantIntersects Then Exit Do
		targetBox.o.x += shiftDir
		If (targetBox.o.x - boxStartX)*shiftDir > 16 Then 
			canPlace = FALSE
			Exit Do
		EndIf
		
		If movePlayer Then
			playerBox.o.x += shiftDir
			Dim As AABB testPlayerBox = playerBox
			testPlayerBox.o += Vec2F(0, 1)
			testPlayerBox.s -= Vec2F(0, 2)
			
			Dim As DArray_AnyPtr playerIntersects = sim->getIntersects(testPlayerBox)
			Dim As Boolean playerRelevantIntersects = FALSE
			For i As Integer = 0 To playerIntersects.size() - 1
				If playerIntersects[i].getValue() <> @This Then 
					playerRelevantIntersects = TRUE
					Exit For
				EndIf
			Next i
			
			If playerRelevantIntersects Then
				playerBox.o.x -= shiftDir
				movePlayer = FALSE
			EndIf
		End If
	Loop
	If Not canPlace Then Return

	carryingStatue_ = FALSE	
	Dim As Vec2F playerModelTranslate = playerBox.o - COL_PTR->getAABB().o
	COL_PTR->place(playerBox.o)	
	model_->translate(playerModelTranslate)	

	DEBUG_ASSERT(fakeStatuePtr_ <> NULL)
	CPtr(ActorBank Ptr, parent_)->remove(fakeStatuePtr_)
	fakeStatuePtr_ = NULL
	
	Dim As ActiveBankInterface Ptr activeInterface = @GET_GLOBAL("ACTIVEBANK INTERFACE", ActiveBankInterface)
	activeInterface->add(New Statue(activeInterface->getParent(), Vec3F(targetBox.o.x, targetBox.o.y, 1)))
	statuePlaceCountdown_ = 2
End Sub

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
			curFrame = IIf(carryingStatue_, 10, 6) + walkFrame_
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
	Return downLHEdge_ AndAlso (warpParalyzeCountdown_ = 0)
End Function

Const Function Player.pressedActivate() As Boolean
	Return activateLHEdge_ AndAlso (Not isSnapshotting_) _
			AndAlso (Not carryingStatue_) _
			AndAlso (statuePlaceCountdown_ = 0) _
			AndAlso (warpParalyzeCountdown_ = 0)
End Function

Const Function Player.getBounds() ByRef As Const AABB
	Return COL_PTR->getAABB()
End Function

Sub Player.setDestinationPortal(dest As Const ZString Ptr)
	destinationPortal_ = *dest
End Sub

Sub Player.leech()
	If snapshot_ <> NULL Then
		Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
		graph->deleteIndex(@clonedIndex_)
		Delete(snapshot_)
		snapshot_ = NULL
	EndIf
	Dim As ActiveBankInterface Ptr activeInterface = @GET_GLOBAL("ACTIVEBANK INTERFACE", ActiveBankInterface)
	Dim As Vec3F sPosition = Any
	sPosition.x = COL_PTR->getAABB().o.x + COL_PTR->getAABB().s.x*Rnd
	sPosition.y = COL_PTR->getAABB().o.y + COL_PTR->getAABB().s.y*Rnd
	sPosition.z = 1
	If Int(Rnd * 3) = 0 Then AudioController.playSample("res/scratch.wav", Vec2F(0, 600))
	activeInterface->add(New Spronkle(activeInterface->getParent(), sPosition, ))
End Sub

Sub Player.notify()
	''
End Sub

Function Player.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace