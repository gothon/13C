#Include "statue.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../quadmodel.bi"
#Include "../physics.bi"
#Include "../texturecache.bi"

#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Statue, ActorTypes.STATUE)

Const As UInteger INIT_FRAME = 0
Const As UInteger WINCE_FRAME = 1

Const As UInteger BREAK_START_FRAME = 2
Const As UInteger BREAK_END_FRAME = 12

Const As UInteger BREAK_FRAME_DELAY = 2

Const As Integer STATUE_W = 16
Const As Integer STATUE_H = 32
	
Const As Integer CARRY_BUFFER_X = 2
Const As Integer CARRY_LEVEL_Y_DEC = 20

Const As Integer PLAYER_OFF_COUNTDOWN = 2
	
#Define COL_PTR CPtr(DynamicAABB Ptr, collider_)

Function Statue.createModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(STATUE_W, STATUE_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {srcImage}
	Return New QuadModel( _
			Vec3F(STATUE_W, STATUE_H, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)
End Function
	
Constructor Statue(parent As ActorBankFwd Ptr, p As Vec3F)
	This.animImage_ = New Image32()
	Base.Constructor(parent, createModel(animImage_), New DynamicAABB(AABB(Vec2F(p.x, p.y), Vec2F(STATUE_W, STATUE_H))))
	setType()
	
	model_->translate(p)
	
	This.animImage_->bindIn(TextureCache.get("res/bhust.png"))
	This.currentFrame_ = INIT_FRAME
	This.z_ = p.z
	This.solid_ = TRUE
	This.lastStoodOn_ = FALSE
	This.frameCounter_ = BREAK_FRAME_DELAY
	This.collectRequested_ = FALSE
	This.restedOn_ = FALSE
	This.playerOffCountdown_ = -1
End Constructor

Destructor Statue()
	DEBUG_ASSERT(animImage_ <> NULL)
	Delete(animImage_)
End Destructor

Sub Statue.collect()
	collectRequested_ = TRUE
End Sub

Function Statue.update(dt As Double) As Boolean
	If collectRequested_ Then Return TRUE
	
	Dim As SimulationInterface Ptr sim_ = @GET_GLOBAL("SIMULATION INTERFACE", SimulationInterface)
	If sim_->getIntersectsBlockGrid(COL_PTR->getAABB()) = BlockType.SIGNAL Then Return TRUE
	
	model_->translate(COL_PTR->getDelta())
	
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	Dim As Boolean playerIsOn = FALSE
	If solid_ Then 	
		For i As Integer = 0 to COL_PTR->getArbiters().size() - 1
			Dim As Arbiter Ptr arb = @(COL_PTR->getArbiters()[i])
			If arb->onAxis And AxisComponent.Y_P Then
				restedOn_ = TRUE
				If arb->actorRef = player_ Then playerIsOn = TRUE
			EndIf
		Next i
		
		If lastStoodOn_ AndAlso (Not playerIsOn) Then 
			playerOffCountdown_ = PLAYER_OFF_COUNTDOWN
		ElseIf (Not lastStoodOn_) AndAlso playerIsOn Then
			playerOffCountdown_ = -1
		EndIf
	End If 
	
	If (playerOffCountdown_ = 0) AndAlso solid_ Then
		COL_PTR->ignore(player_)
		solid_ = FALSE
		currentFrame_ = BREAK_START_FRAME
	EndIf
			
	If playerOffCountdown_ > 0 Then playerOffCountdown_ -= 1
			
	If (currentFrame_ >= BREAK_START_FRAME) AndAlso (currentFrame_ <> BREAK_END_FRAME) Then
		frameCounter_ -= 1
		If frameCounter_ = 0 Then 
			frameCounter_ = BREAK_FRAME_DELAY
			currentFrame_ += 1
		EndIf
	ElseIf playerIsOn Then 
		currentFrame_ = WINCE_FRAME
	End If
	
	If currentFrame_ = INIT_FRAME Then
		processCarryable()
	EndIf
	
	animImage_->setOffset(currentFrame_ * STATUE_W, 0)
	lastStoodOn_ = playerIsOn
	
	Return FALSE
End Function

Sub Statue.processCarryable()
	If restedOn_ Then Return
	If COL_PTR->getV().m() <> 0 Then Return
	
	Dim As GraphInterface Ptr graph = @GET_GLOBAL("GRAPH INTERFACE", GraphInterface)
	If graph->cloneRequested() Then Return
	
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	
	Dim As AABB carryBounds = COL_PTR->getAABB()
	carryBounds.o.x -= CARRY_BUFFER_X
	carryBounds.s.x += 2*CARRY_BUFFER_X
	carryBounds.s.y -= CARRY_LEVEL_Y_DEC
	
	Dim As AABB playerBounds = CPtr(DynamicAABB Ptr, player_->getCollider())->getAABB()
	playerBounds.s.y -= CARRY_LEVEL_Y_DEC
	
	If carryBounds.intersects(playerBounds) Then player_->claimCarryable(@This)
End Sub

Sub Statue.notify()
	''
End Sub

Function Statue.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As Statue Ptr statch = New Statue(parent, Vec3F(COL_PTR->getAABB().o.x, COL_PTR->getAABB().o.y, z_))
	CPtr(DynamicAABB Ptr, statch->collider_)->setV(COL_PTR->getV())
	statch->currentFrame_ = currentFrame_
	statch->solid_ = solid_
	CPtr(DynamicAABB Ptr, statch->collider_)->ignore(COL_PTR->getIgnore())
	statch->lastStoodOn_ = FALSE
	statch->frameCounter_ = frameCounter_
	statch->animImage_->setOffset(statch->currentFrame_ * STATUE_W, 0)
	statch->collectRequested_ = collectRequested_
	statch->playerOffCountdown_ = playerOffCountdown_
	Return statch
End Function

End Namespace