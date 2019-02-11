#Include "graphwrapper.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "projection.bi"
#Include "image32.bi"
#Include "gamespace.bi"
#Include "aabb.bi"
#Include "texturecache.bi"
#Include "fbgfx.bi"
#Include "fpslimiter.bi"
#Include "imageops.bi"
#Include "util.bi"
#Include "config.bi"
#Include "audiocontroller.bi"

Const As UInteger PHYSICAL_SCRX = 640
Const As UInteger PHYSICAL_SCRY = 480

Const As UInteger LOGICAL_SCRX = 320
Const As UInteger LOGICAL_SCRY = 240

Dim As Double FRAME_TIME = 1.0 / 30.0

Sub waitKey()
	While InKey() <> ""
		''
	Wend
	GetKey()
End Sub

ScreenRes PHYSICAL_SCRX, PHYSICAL_SCRY, 32
SetMouse ,,0

Dim As String choice = ""
While (choice <> "Y") AndAlso (choice <> "N")
	Input "Fullscreen (recommended)? [Y/N] ", choice
	choice = UCase(choice)
Wend
If choice = "Y" Then 
	ScreenRes PHYSICAL_SCRX, PHYSICAL_SCRY, 32,,1
	SetMouse ,,0
EndIf

Print "Lode..."

Dim As Config cfg 'const

Dim As CameraController camera = CameraController( _ 
		Projection(PHYSICAL_SCRX, PHYSICAL_SCRY, LOGICAL_SCRX, LOGICAL_SCRY, 256))
Dim As GraphWrapper graph = GraphWrapper(cfg.getEntryPoint())
Dim As Image32 target = Image32(PHYSICAL_SCRX, PHYSICAL_SCRY)

Dim As ActorBank Ptr bank = New ActorBank()
Dim As Image32 Ptr playerSprite = New Image32()
Dim As act.Player Ptr player = New act.Player( _
		bank, _
		New QuadSprite(playerSprite, 16, 24), _
		New DynamicAABB(AABB(Vec2F(60, 60), Vec2F(15, 24))), _
		playerSprite)
bank->add(player)
				
AudioController.pauseMusic()
AudioController.setMusicVol(0.25)
AudioController.cacheMusic("res/no_more_freebasic.mp3")

Scope
	Dim As Gamespace gs = Gamespace(@camera, @graph, @target, bank)
	Dim As FpsLimiter limiter
	gs.init(StrPtr(cfg.getEntryPoint()))
	Do
		gs.update(FRAME_TIME)
		AudioController.update(FRAME_TIME)

		Line target.fbImg(), (0, 0)-(PHYSICAL_SCRX - 1, PHYSICAL_SCRY - 1), 0, BF
		gs.draw()

		limiter.sync()
		ScreenLock
		Put (0, 0), target.fbImg(), PSet
		ScreenUnLock
	Loop Until MultiKey(fb.SC_ESCAPE) OrElse gs.shouldEnd()
	If gs.shouldEnd() Then
		Dim As act.Overlay Ptr overlay = CPtr(act.Overlay Ptr, bank->getGlobalActor("OVERLAY"))
		AudioController.switchMusic("res/no_more_freebasic.mp3")
		Line (0, 0)-(639, 479), RGB(160, 110, 100), BF
		Sleep 4000, 1
		
		overlay->drawTextToScreen(0,  20, "FreeBASIC. I guess this is goodbye.     ")
		overlay->drawTextToScreen(0,  60, "I (Zamaster) grew up with this community")
		overlay->drawTextToScreen(0,  80, "back when many of us were active at")
		overlay->drawTextToScreen(0, 100, "Pete's QB Site. It's easy to let go of ")
		overlay->drawTextToScreen(0, 120, "what I feel is a frustrating")
		overlay->drawTextToScreen(0, 140, "programming language, but it's harder to")
		overlay->drawTextToScreen(0, 160, "let go of the nostalgia.")
		overlay->drawTextToScreen(0, 200, "Our community is like all " + Str(player->getBrokenArtifacts()) + " of")
		overlay->drawTextToScreen(0, 220, "those statues and chandeliers you just ")
		overlay->drawTextToScreen(0, 240, "broke, temporary. However, we keep the")
		overlay->drawTextToScreen(0, 260, "memories and friendships, and I don't")
		overlay->drawTextToScreen(0, 280, "find that frustrating at all.")
		waitKey()
		
		Line (0, 0)-(639, 479), RGB(160, 110, 100), BF
		overlay->drawTextToScreen(0,  20, "Either way, goodbye. I'll miss you.")
		
		Dim As Integer completionPercent = Int((player->seenPlaques() / 19.0)*100)
		If completionPercent = 99 Then completionPercent = 100
		overlay->drawTextToScreen(0,  60, "Oh and you found " + Str(completionPercent) + "% of the")
		overlay->drawTextToScreen(0,  80, "exhibits.")
		
		If completionPercent = 100 Then
			overlay->drawTextToScreen(0,  120, "Amazing!")
		ElseIf completionPercent < 50 Then
			overlay->drawTextToScreen(0,  120, "You can do better than that...")	
		Else
			overlay->drawTextToScreen(0,  120, "Not bad.")	
		EndIf
		waitKey()
	End If
End Scope

Delete(bank)
