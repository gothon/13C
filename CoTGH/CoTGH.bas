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

Const As String STAGE_ENTRY_POINT = "RES/PUZZLE_TEST2.TMX"

Const As UInteger PHYSICAL_SCRX = 640
Const As UInteger PHYSICAL_SCRY = 480

Const As UInteger LOGICAL_SCRX = 320
Const As UInteger LOGICAL_SCRY = 240

Dim As Double FRAME_TIME = 1.0 / 30.0

ScreenRes PHYSICAL_SCRX, PHYSICAL_SCRY, 32
SetMouse ,,0
Print "Lode..."

Dim As CameraController camera = CameraController( _ 
		Projection(PHYSICAL_SCRX, PHYSICAL_SCRY, LOGICAL_SCRX, LOGICAL_SCRY, 256))
Dim As GraphWrapper graph = GraphWrapper(STAGE_ENTRY_POINT)
Dim As Image32 target = Image32(PHYSICAL_SCRX, PHYSICAL_SCRY)

Dim As ActorBank Ptr bank = New ActorBank()
Dim As Image32 Ptr playerSprite = New Image32()
bank->add( _
		New act.Player( _
				bank, _
				New QuadSprite(playerSprite, 16, 24), _
				New DynamicAABB(AABB(Vec2F(60, 60), Vec2F(15, 24))), _
				playerSprite))

Scope
	Dim As Gamespace gs = Gamespace(@camera, @graph, @target, bank)
	Dim As FpsLimiter limiter
	gs.init(StrPtr(STAGE_ENTRY_POINT))
	Do
		gs.update(FRAME_TIME)
		
		Line target.fbImg(), (0, 0)-(PHYSICAL_SCRX - 1, PHYSICAL_SCRY - 1), 0, BF
		gs.draw()
				 
		limiter.sync()
		ScreenLock
		Put (0, 0), target.fbImg(), PSet
		ScreenUnLock
		Locate 1,1: Print limiter.getFps()
	Loop Until MultiKey(fb.SC_ESCAPE)
End Scope

Delete(bank)
