#Include "leecher.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../quadmodel.bi"
#Include "../texturecache.bi"

Namespace act
ACTOR_REQUIRED_DEF(Leecher, ActorTypes.LEECHER)

Const As Single LEECHER_W = 32
Const As Single LEECHER_H = 32

Const As Integer LEECHER_FRAMES = 10
Const As Integer LEECHER_FRAME_DELAY = 3

Function createModel(srcImage As Image32 Ptr, tileX As Integer, tileY As Integer) As QuadModelBase Ptr
	Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(LEECHER_W, LEECHER_H), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {srcImage}
	Return New QuadModel( _
			Vec3F(LEECHER_W, LEECHER_H, 0), QuadModelTextureCube(1, 0, 0, 0, 0), uvIndex(), tex(), FALSE, tileY, tileX)
End Function
	
Constructor Leecher(parent As ActorBankFwd Ptr, bounds As AABB, startFrameOffset As Integer, z As Single)
	This.animImage_ = New Image32()

	Base.Constructor(parent, createModel(This.animImage_, -Int(-(bounds.s.x / LEECHER_W)), -Int(-(bounds.s.y / LEECHER_H))))
	setType()
	
	This.z_ = z
	This.startFrameOffset_ = startFrameOffset
	This.model_->translate(Vec3F(bounds.o.x, bounds.o.y, This.z_))
	This.model_->setDrawMode(QuadTextureMode.TEXTURED)
	This.animImage_->bindIn(TextureCache.get("res/leecher.png"))
	This.bounds_ = bounds
	This.frame_ = startFrameOffset
	This.delay_ = LEECHER_FRAME_DELAY*IIf(startFrameOffset <> 0, 2, 1)
End Constructor

Function Leecher.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)	
	If player_->getBounds().intersects(bounds_) Then player_->leech()
	
	If Int(Rnd * 5) = 0 Then 
		Dim As ActiveBankInterface Ptr activeInterface = @GET_GLOBAL("ACTIVEBANK INTERFACE", ActiveBankInterface)
		Dim As Vec3F sPosition = Any
		sPosition.x = bounds_.o.x + bounds_.s.x*Rnd
		sPosition.y = bounds_.o.y + bounds_.s.y*Rnd
		sPosition.z = z_
		activeInterface->add(New Spronkle(activeInterface->getParent(), sPosition, 0.5, TRUE))
	End If
	
	delay_ -= 1
	If delay_ <= 0 Then
		delay_ = LEECHER_FRAME_DELAY*IIf(startFrameOffset_ <> 0, 2, 1)
		frame_ = (frame_ + 1) Mod LEECHER_FRAMES
	EndIf
	animImage_->setOffset(frame_*LEECHER_W, 0)
	
	Return FALSE
End Function

Sub Leecher.notify()
	''
End Sub

Function Leecher.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New Leecher(parent, bounds_, startFrameOffset_, z_)
End Function

End Namespace
