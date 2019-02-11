#Include "fakeplayer.bi"

#Include "../actortypes.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"
#Include "../debuglog.bi"
#Include "../image32.bi"

Namespace act
ACTOR_REQUIRED_DEF(FakePlayer, ActorTypes.FAKEPLAYER)

Static Function FakePlayer.createModel(animImage As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(16, 24), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {animImage}
	Return New QuadModel( _
			Vec3F(16, 24, 0), _
			QuadModelTextureCube(1, 0, 0, 0, 0), _
			uvIndex(), _
			tex(), _
			FALSE)
End Function
	
Constructor FakePlayer(parent As ActorBankFwd Ptr, p As Vec3F, isMatt As Boolean, faceRight As Boolean)
	This.animImage_ = New Image32()
	Base.Constructor(parent, createModel(This.animImage_))
	setType()
	setKey(IIf(isMatt, StrPtr("MAMBAZO"), StrPtr("ZAMASTER")))
	
	model_->translate(p)
	
	If Not faceRight Then 
		Dim As Quad Ptr q = model_->getQuad(0)
		Swap q->v(0).t.x, q->v(1).t.x
		Swap q->v(2).t.x, q->v(3).t.x
	End If
	
	This.animImage_->bindIn(TextureCache.get("res/player.png"))

	This.idleFrame_ = -1
	This.isMatt_ = isMatt
End Constructor

Destructor FakePlayer()
	DEBUG_ASSERT(animImage_ <> NULL)
	Delete(animImage_)
End Destructor
	
Function FakePlayer.update(dt As Double) As Boolean	
	Dim As UInteger curFrame = 0
	
	If idleFrame_ = -1 Then
		If Int(Rnd * 50) = 0 Then
			If Int(Rnd * 12) > 0 Then
				idleFrame_ = 1
				idleEndFrame_ = 2
				idleFrameSpeed_ = 3
			Else
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
	
	animImage_->setOffset(curFrame * 16, IIf(isMatt_, 0, 24))
	
	Return FALSE
End Function

Sub FakePlayer.notify()
	''
End Sub
	
Function FakePlayer.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace