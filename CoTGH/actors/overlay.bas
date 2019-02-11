#Include "overlay.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../image32.bi"
#Include "../debuglog.bi"
#Include "../texturecache.bi"
#Include "../raster.bi"
#Include "../vertex.bi"
#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Overlay, ActorTypes.OVERLAY)

Const As Single UV_ERROR_ADJ = 0.01
Const As Integer TEXT_BG_COL = RGB(128, 100, 80)
Const As Integer TEXT_BG_BORDER_COL = RGB(64, 50, 40)
Const As Integer TEXT_BORDER = 10
Const As Integer TEXT_OFFSET = 20

Function prepareFont() As fb.IMAGE Ptr
	Dim As fb.IMAGE Ptr fontTemp = TextureCache.get("res/musee.png")->fbImg()
	Dim As fb.IMAGE Ptr customFont = ImageCreate(256*16, 17)
	DEBUG_ASSERT(customFont <> NULL)
	Dim As UByte Ptr p = Any
	ImageInfo customFont,,,,, p
	p[0] = 0
	p[1] = 0
	p[2] = 255
	For i As Integer = 0 To 255
    p[3 + i] = 16
		Dim As Integer sx = (i*16) Mod 256 'const
		Dim As Integer sy = Int(i / 16) * 16 'const
		Put customFont, (i*16, 1), fontTemp, (sx, sy)-(sx + 15, sy + 15), PSET
	Next i
	Return customFont
End Function
	
Constructor Overlay(parent As ActorBankFwd Ptr, target As Image32 Ptr)
	Base.Constructor(parent)
	setType()
	setKey("OVERLAY")

	DEBUG_ASSERT(target->w() = 640)
	DEBUG_ASSERT(target->h() = 480)

	This.target_ = target
	This.photo_ = NULL
	This.hasCamera_ = FALSE
	This.font_ = prepareFont()
End Constructor

Destructor Overlay()
	DEBUG_ASSERT(font_ <> NULL)
	ImageDestroy(font_)
End Destructor

Sub Overlay.setHasCamera(hasCamera As Boolean)
	hasCamera_ = hasCamera
End Sub

Sub Overlay.drawText(x As Integer, y As Integer, ByRef t As Const String)
	Draw String target_->fbImg(), (x, y), t,, font_
End Sub

Sub Overlay.drawTextBox()
	If text_ = "" Then Return
	
	Dim As Integer offsetY = 0
	Dim As Integer curTextPos = 0
	Dim As Integer lastTextPos = 0
	
	Line target_->fbImg(), (0, 0)-(639, TEXT_BORDER - 1), TEXT_BG_COL, BF	
	While curTextPos < Len(text_) 
		Line target_->fbImg(), (0, offsetY + TEXT_BORDER)-(639, offsetY + TEXT_OFFSET + TEXT_BORDER - 1), TEXT_BG_COL, BF
		
		lastTextPos = curTextPos
		While (curTextPos < Len(text_)) AndALso (Mid(text_, 1 + curTextPos, 1) <> "|")
			curTextPos += 1
		Wend
		drawText(0, TEXT_BORDER + offsetY, Mid(text_, lastTextPos + 1, curTextPos - lastTextPos))
		curTextPos += 1
		offsetY += TEXT_OFFSET
	Wend
	Line target_->fbImg(), (0, offsetY + TEXT_BORDER)-(639, offsetY + 2*TEXT_BORDER - 3), TEXT_BG_COL, BF	
	Line target_->fbImg(), (3, 3)-(636, offsetY + 2*TEXT_BORDER - 6), TEXT_BG_BORDER_COL, B
	Line target_->fbImg(), (2, 2)-(637, offsetY + 2*TEXT_BORDER - 5), TEXT_BG_BORDER_COL, B
End Sub

Sub Overlay.textLine(ByRef text As Const String)
	centerText_ = text
End Sub

Sub Overlay.drawOverlay()
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
	
	drawTextBox()
	
	If centerText_ <> "" Then
		Dim As Integer x = 320 - Len(centerText_)*16*0.5 'const
		Dim As Integer y = 240 - 8 'const
		drawText(x, y, centerText_)	
	End If
End Sub

Sub Overlay.drawTextToScreen(x As Integer, y As Integer, ByRef text As Const String)
	Draw String (x, y), text,, font_
End Sub

Sub Overlay.showText(ByRef text As Const String)
	text_ = text
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
