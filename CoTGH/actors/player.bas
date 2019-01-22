#Include "player.bi"

#Include "../physics.bi"
#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../texturecache.bi"
#Include "../quadmodel.bi"

#Include "fbgfx.bi"

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
	
	Dim As Vec2f translate = COL_PTR->getAABB().o + COL_PTR->getAABB().s * 0.5
	This.model_->translate(Vec3F(translate.x, translate.y, 0))

	This.facingRight_ = TRUE
	
	This.animImage_ = animImage
	This.animImage_->bindIn(TextureCache.get("res/mambazo.png"))
	This.lastDownPressed_ = FALSE
	This.downLHEdge_ = FALSE
	This.destinationPortal_ = ""
End Constructor

Virtual Destructor Player()
	Delete(animImage_)
End Destructor
 
#Define CAMERA_BUFFER_TL Vec2F(150, 100)
#Define CAMERA_BUFFER_BR Vec2F(150, 64)

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

Function Player.update(dt As Double) As Boolean
	If GET_GLOBAL("TRANSITION NOTIFIER", TransitionNotifier).happened() Then
		Dim As Vec2F spawnP = Any
		If destinationPortal_ = "" Then 
			spawnP = GET_GLOBAL("SPAWN", Spawn).getP()
		Else
			Dim As Portal Ptr portal_ = @GET_GLOBAL(StrPtr(destinationPortal_), Portal)
			portal_->waitForNoIntersect()
			spawnP = portal_->getRegion().o
		EndIf 
		Dim As Vec2F diff = spawnP - COL_PTR->getAABB().o
		COL_PTR->place(spawnP)
		model_->translate(Vec3F(diff.x, diff.y, 0))
		model_->translate(COL_PTR->getDelta())
	Else
		model_->translate(COL_PTR->getDelta())
	EndIf

	updateCamera()

	If MultiKey(fb.SC_LEFT) Then 
		COL_PTR->setV(COL_PTR->getV() + Vec2F(-5,0))
		If facingRight_ = TRUE Then flipXUV()
		facingRight_ = FALSE
	EndIf

	If MultiKey(fb.SC_RIGHT) Then 
		COL_PTR->setV(COL_PTR->getV() + Vec2F(5,0))
		If facingRight_ = FALSE Then flipXUV()
		facingRight_ = TRUE
	EndIf

	If MultiKey(fb.SC_UP) Then COL_PTR->setV(COL_PTR->getV() + Vec2F(0,1))
	
	downLHEdge_ = FALSE
	If MultiKey(fb.SC_DOWN) Then 
		If lastDownPressed_ = FALSE Then downLHEdge_ = TRUE
		lastDownPressed_ = TRUE	
	Else
		lastDownPressed_ = FALSE
	EndIf
	
	Return FALSE
End Function

Const Function Player.pressedDown() As Boolean
	Return downLHEdge_
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