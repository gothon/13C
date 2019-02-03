#Include "chandelier.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../quadmodel.bi"
#Include "../physics.bi"
#Include "../texturecache.bi"
#Include "../aabb.bi"
#Include "../light.bi"

#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Chandelier, ActorTypes.CHANDELIER)

Const As Integer PLAYER_OFF_COUNTDOWN = 3

Const As Integer CHANDELIER_W = 32
Const As Integer CHANDELIER_H = 16

Const As UInteger INIT_FRAME = 0
Const As UInteger WINCE_FRAME = 1
Const As UInteger BROKEN_FRAME = 3
	
#Define COL_PTR CPtr(DynamicAABB Ptr, collider_)

Function Chandelier.createModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(CHANDELIER_W, CHANDELIER_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {srcImage}
	Return New QuadModel( _
			Vec3F(CHANDELIER_W, CHANDELIER_H, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)
End Function
	
Constructor Chandelier(parent As ActorBankFwd Ptr, p As Vec3F)
	This.animImage_ = New Image32()
	Base.Constructor( _
			parent, _
			createModel(animImage_), _
			New DynamicAABB(AABB(Vec2F(p.x, p.y), Vec2F(CHANDELIER_W, CHANDELIER_H))), _
			New Light(p + Vec3F(CHANDELIER_W*0.5, CHANDELIER_H*0.5, 8), Vec3F(1.0, 1.0, 0.9), 128))
	setType()
	
	model_->translate(Vec3F(p.x, p.y, 1))
	COL_PTR->enableGravity(FALSE)
	
	This.animImage_->bindIn(TextureCache.get("res/chandelier.png"))
	This.z_ = p.z
	This.solid_ = TRUE
	This.lastStoodOn_ = FALSE
	This.playerOffCountdown_ = -1
	This.breaking_ = FALSE
End Constructor

Destructor Chandelier()
	DEBUG_ASSERT(animImage_ <> NULL)
	Delete(animImage_)
End Destructor


Function Chandelier.update(dt As Double) As Boolean
	Dim As SimulationInterface Ptr sim_ = @GET_GLOBAL("SIMULATION INTERFACE", SimulationInterface)
	If sim_->getIntersectsBlockGrid(COL_PTR->getAABB()) = BlockType.SIGNAL Then Return TRUE
	
	model_->translate(COL_PTR->getDelta())
	light_->translate(COL_PTR->getDelta())
	
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	Dim As Boolean playerIsOn = FALSE
	Dim As Boolean touchingBelow = FALSE
	For i As Integer = 0 to COL_PTR->getArbiters().size() - 1
		Dim As Arbiter Ptr arb = @(COL_PTR->getArbiters()[i])
		If (arb->onAxis And AxisComponent.Y_P) AndAlso (arb->actorRef = player_) Then 
			breaking_ = TRUE
			playerIsOn = TRUE
		EndIf
		If (arb->onAxis And AxisComponent.Y_N) Then touchingBelow = TRUE
	Next i
	
	If solid_ Then 			
		If lastStoodOn_ AndAlso (Not playerIsOn) Then 
			playerOffCountdown_ = PLAYER_OFF_COUNTDOWN
		ElseIf (Not lastStoodOn_) AndAlso playerIsOn Then
			playerOffCountdown_ = -1
		EndIf
	End If 
	
	If playerOffCountdown_ > 0 Then playerOffCountdown_ -= 1
	
	If (playerOffCountdown_ = 0) AndAlso solid_ Then
		COL_PTR->ignore(player_)
		solid_ = FALSE
		COL_PTR->enableGravity(TRUE)
	EndIf

	If Not solid_ Then
		If touchingBelow Then 
			currentFrame_ = BROKEN_FRAME
			light_->off()
		Else
			If (Int(Rnd * 4) = 0) Then
				If light_->isOn() Then
					currentFrame_ = WINCE_FRAME + 1
					light_->off()
				Else
					currentFrame_ = WINCE_FRAME
					light_->on()
				EndIf
			EndIf 
		End If 
	ElseIf breaking_ OrElse playerIsOn Then 
		currentFrame_ = WINCE_FRAME
	Else
		currentFrame_ = INIT_FRAME
	End If
	
	animImage_->setOffset(currentFrame_*CHANDELIER_W, 0)
	lastStoodOn_ = playerIsOn
	
	Return FALSE
End Function

Sub Chandelier.notify()
	''
End Sub

Function Chandelier.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As Chandelier Ptr chan = New Chandelier(parent, Vec3F(COL_PTR->getAABB().o.x, COL_PTR->getAABB().o.y, z_))
	CPtr(DynamicAABB Ptr, chan->collider_)->setV(COL_PTR->getV())
	CPtr(DynamicAABB Ptr, chan->collider_)->ignore(COL_PTR->getIgnore())	
	CPtr(DynamicAABB Ptr, chan->collider_)->enableGravity(COL_PTR->gravityEnabled())	
	If Not light_->isOn() Then chan->light_->off()
	chan->currentFrame_ = currentFrame_
	chan->solid_ = solid_
	chan->lastStoodOn_ = FALSE
	chan->animImage_->setOffset(chan->currentFrame_ * CHANDELIER_W, 0)
	chan->playerOffCountdown_ = playerOffCountdown_
	chan->breaking_ = breaking_
	Return chan
End Function

End Namespace