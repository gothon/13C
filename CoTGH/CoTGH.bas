#Include "aabb.bi"
#Include "projection.bi"
#Include "cameracontroller.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#include "image32.bi"
#Include "imageops.bi"
#Include "quadmodel.bi"
#Include "quaddrawbuffer.bi"
#Include "physics.bi"
#Include "maputils.bi"


'translate ISG
'	
'
'
'

ScreenRes 640, 480, 32

Dim As CameraController camera = CameraController(Projection(640, 480, 320, 240, 256))
Dim As Image32 b = Image32(640, 480)   
Dim As QuadDrawBuffer drawBuffer

Dim As maputils.ParseResult res = maputils.parseMap("res/example.tmx")
Dim As QuadModelBase Ptr model = res.model

model->translate(Vec3F(0,0,8))
drawBuffer.bind(model)

Dim As Vec2F v = Vec2f(0.0, 0.0)
Dim As AABB p = AABB(Vec2F(60, 60), Vec2F(16, 24))
Dim As QuadSprite playerModel = QuadSprite("res/object.png")
playerModel.translate(Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5))

drawBuffer.bind(@playerModel)

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

Dim As Boolean grounded = FALSE
Dim As Boolean lastUpKey = FALSE
Dim As Boolean upKey = FALSE

Dim As Boolean facingRight = TRUE

Do  

	v.x *= IIf(grounded, 0.80, 0.95)
	If Abs(v.x) > 4 Then v.x = 4*Sgn(v.x)
	v -= Vec2F(0, 0.5)	
	
	lastUpKey = upKey
	upKey = MultiKey(fb.SC_UP)
	If grounded AndAlso upKey AndAlso Not lastUpKey Then v += Vec2F(0, 9)
	
	Dim As Single speed = IIf(grounded, 0.5, 0.1)
	If MultiKey(fb.SC_RIGHT) Then 
		v += Vec2F(speed, 0)
		facingRight = TRUE
	EndIf
	If MultiKey(fb.SC_LEFT) Then 
		v += Vec2F(-speed, 0)
		facingRight = FALSE
	EndIf

 	Dim As physics.ClipResult clipRes = res.blockGrid->clipRect(p, v) 

  p.o += clipRes.clipV
	playerModel.translate(Vec3F(clipRes.clipV.x, clipRes.clipV.y, 0.0))

	grounded = FALSE
  If clipRes.clipAxis And physics.Axis.X Then
  	If clipRes.clipAxis And physics.Axis.Y Then
  		grounded = IIf(v.y < 0, TRUE, FALSE)
  		v = Vec2F(0,0)
  	Else 
  		v.x = 0
  	End If
  ElseIf clipRes.clipAxis And physics.Axis.Y Then
  	grounded = IIf(v.y < 0, TRUE, FALSE)
  	v.y = 0
  EndIf
	
	camera.update(1.0, p.o + p.s*0.5, facingRight)
  
  playerModel.project(camera.proj())
  model->project(camera.proj())

	Line b.fbImg(), (0, 0)-(639, 479), RGB(0, 0, 0), BF
  drawBuffer.draw(@b)
  ScreenLock
  Put (0,0), b.fbImg(), PSET
  ScreenUnLock

  Locate 1, 1: Print fps / fpsCaptures, lastFps
  If (Timer - fpsTimer) > 1.0f Then
    fps += f
    lastFps = f
    fpsCaptures += 1
    f = 0
    fpsTimer = Timer
  EndIf
  f += 1
  Sleep 5
Loop Until MultiKey(FB.SC_ESCAPE)
drawBuffer.unbind(model)
drawBuffer.unbind(@playerModel)
Delete(res.model)
Delete(res.blockGrid)
