#Include "aabb.bi"
#Include "projection.bi"
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

Dim As Projection proj = Projection(640, 480, 320, 240, 256)
Dim As Image32 b = Image32(640, 480)   
Dim As QuadDrawBuffer drawBuffer

Dim As maputils.ParseResult res = maputils.parseMap("res/example.tmx")
Dim As QuadModelBase Ptr model = res.model

model->translate(Vec3F(0,0,8))
drawBuffer.bind(model)

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

Dim As Vec2F v = Vec2f(0.0, 0.0)

Dim As AABB p = AABB(Vec2F(40, 40), Vec2F(16, 24))

Do  
	v *= 0.9
	If MultiKey(fb.SC_UP) Then v += Vec2F(0, 1)
	If MultiKey(fb.SC_RIGHT) Then v += Vec2F(1, 0)
	If MultiKey(fb.SC_DOWN) Then v += Vec2F(0, -1)
	If MultiKey(fb.SC_LEFT) Then v += Vec2F(-1, 0)
	
	p.o += v
	
  proj.placeAndLookAt( _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, 230), _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, 0))
  
  model->project(proj)

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
  Sleep 15
Loop Until MultiKey(FB.SC_ESCAPE)
drawBuffer.unbind(model)
Delete(res.model)
Delete(res.blockGrid)
