#Include "overlay.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../image32.bi"
#Include "../texturecache.bi"
#Include "../raster.bi"
#Include "../vertex.bi"
#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Overlay, ActorTypes.OVERLAY)

Const As Single UV_ERROR_ADJ = 0.01
	
Constructor Overlay(parent As ActorBankFwd Ptr, target As Image32 Ptr)
	Base.Constructor(parent)
	setType()
	setKey("OVERLAY")
	
	'Cache the HUD images
	TextureCache.get("res/hud.png")

	This.target_ = target
	This.photo_ = NULL
	This.hasCamera_ = FALSE
End Constructor

Sub Overlay.setHasCamera(hasCamera As Boolean)
	hasCamera_ = hasCamera
End Sub

Sub Overlay.draw()
	Dim As Image32 Ptr hud = TextureCache.get("res/hud.png")
	Dim As Integer scnH = target_->h()
	
	If photo_ <> NULL Then
		Dim As Vec2F adj = Vec2F(1, 1)*UV_ERROR_ADJ 'const
		Dim As Vec2F adj90 = Vec2F(1, -1)*UV_ERROR_ADJ 'const
		Dim As Vertex v(0 To 3) = { _
				Vertex(Vec3F(118, 410, 1), Vec2F(0, 0) + adj), _
				Vertex(Vec3F(165, 393, 1), Vec2F(64, 0) - adj90), _
				Vertex(Vec3F(183, 435, 1), Vec2F(64, 48) - adj), _
				Vertex(Vec3F(133, 452, 1), Vec2F(0, 48) + adj90)}
		raster.drawPlanarQuad_Textured(*photo_, @(v(0)), @(v(1)), @(v(2)), @(v(3)), FALSE, FALSE, target_)
	
		Put target_->fbImg(), (110, scnH - 92), hud->fbImg(), (96*2, 0)-(96*3 - 1, 95), TRANS
	End If
	If hasCamera_ Then Put target_->fbImg(), (15, scnH - 92), hud->fbImg(), (0, 0)-(95, 95), Trans
End Sub

Sub Overlay.setPhoto(photo As Image32 Ptr)
	photo_ = photo
End Sub

Function Overlay.update(dt As Double) As Boolean
	Return FALSE
End Function

Sub Overlay.notify()
	''
End Sub

Function Overlay.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
