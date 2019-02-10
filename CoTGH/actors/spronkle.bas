#Include "spronkle.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"

Namespace act
ACTOR_REQUIRED_DEF(Spronkle, ActorTypes.SPRONKLE)

Const As Single SPRONKLE_W = 8
Const As Single SPRONKLE_H = 8

Const As Integer SPRONKLE_FRAMES = 4
Const As Integer SPRONKLE_FRAME_DELAY_MAX = 5

Function createSpronkleModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(SPRONKLE_W, SPRONKLE_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {srcImage}
	Return New QuadModel( _
			Vec3F(SPRONKLE_W, SPRONKLE_H, 0), QuadModelTextureCube(1, 0, 0, 0, 0), uvIndex(), tex(), FALSE)
End Function
	
Constructor Spronkle(parent As ActorBankFwd Ptr, p As Vec3F, speed As Single, isDark As Boolean)
	This.animImage_ = New Image32()

	Base.Constructor(parent, createSpronkleModel(This.animImage_))
	setType()
	
	This.model_->translate(Vec3F(p.x - SPRONKLE_W*0.5, p.y - SPRONKLE_H*0.5, p.z))
	This.model_->setDrawMode(QuadTextureMode.TEXTURED)
	
	This.p_ = p
	This.animImage_->bindIn(TextureCache.get("res/spronkle.png"))
	This.speed_ = speed
	This.frame_ = 0
	This.delay_ = 1 + (SPRONKLE_FRAME_DELAY_MAX - 1)*speed
	This.dark_ = isDark
End Constructor

Function Spronkle.update(dt As Double) As Boolean

	If delay_ > 0 Then
		delay_ -= 1
	ElseIf delay_ = 0 Then
		frame_ += 1
		If frame_ = SPRONKLE_FRAMES Then Return TRUE
		delay_ = 1 + (SPRONKLE_FRAME_DELAY_MAX - 1)*speed_
	End If 

	animImage_->setOffset(frame_*SPRONKLE_W, IIf(dark_, 0, 8))	
	Return FALSE
End Function

Sub Spronkle.notify()
	''
End Sub

Function Spronkle.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As Spronkle Ptr s = New Spronkle(parent, p_, speed_, dark_)
	s->frame_ = frame_
	s->delay_ = delay_
	Return s
End Function

End Namespace
