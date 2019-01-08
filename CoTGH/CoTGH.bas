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

#Include "indexgraph.bi"



Dim As ig_GraphBuilder gb = ig_CreateGraphBuilder()


Dim As ig_Data testA = Type<ig_Data>(4, New Integer(111))
Dim As ig_Data testB = Type<ig_Data>(9, StrPtr("garbonzo"))

ig_AddBaseToBuilder(gb, "rooma", testA, testB)

Delete(CPtr(Integer Ptr, testA.raw))

Dim As ig_IndexGraph graph = ig_Build(@gb)

Dim As ig_Index ind = ig_CreateIndex(graph, "rooma")

Dim As ig_Data ret = ig_GetContent(ind)

Print *CPtr(ZString Ptr, ret.raw)

ig_DeleteIndex(@ind)

ig_DeleteGraph(@graph)

sleep


/'
ScreenRes 640, 480, 32

Dim As CameraController camera = CameraController(Projection(640, 480, 320, 240, 256))
Dim As Image32 b = Image32(640, 480)   
Dim As QuadDrawBuffer drawBuffer
drawBuffer.setGlobalLightMinMax(0, 0.5)
drawBuffer.setGlobalLightDirection(Vec3F(0.1, -0.5, -1))

Dim As maputils.ParseResult res = maputils.parseMap("res/example.tmx")

For i As UInteger = 0 To res.models.size() - 1
	res.models[i].p->translate(Vec3F(0,0,8))
	drawBuffer.bind(res.models[i])
Next i

For i As UInteger = 0 To res.lights.size() - 1
	res.lights[i].p->translate(Vec3F(0,0,8))
	drawBuffer.bind(res.lights[i])
Next i

Dim As Vec2F v = Vec2f(0.0, 0.0)
Dim As AABB p = AABB(Vec2F(60, 60), Vec2F(16, 24))
Dim As QuadSprite playerModel = QuadSprite("res/object.png")
Dim As Light playerLight = Light(Vec3F(0, 0, 0), Vec3F(0, 1, 0), 128, LightMode.SOLID)


playerModel.translate(Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5))
playerLight.translate(Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5))
playerLight.off()

drawBuffer.bind(@playerLight)
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

	v.x *= IIf(grounded, 0.80, 0.97)
	If Abs(v.x) > 4 Then v.x = 4*Sgn(v.x)
	v -= Vec2F(0, 0.5)	
	
	lastUpKey = upKey
	upKey = MultiKey(fb.SC_UP)
	If grounded AndAlso upKey AndAlso Not lastUpKey Then v += Vec2F(0, 9)
	
	Dim As Single speed = IIf(grounded, 0.4, 0.05)
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
	playerLight.translate(Vec3F(clipRes.clipV.x, clipRes.clipV.y, 0.0))

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
	
	For i As UInteger = 0 To res.lights.size() - 1
		res.lights[i].p->update(0.3333) 
	Next i
	playerLight.update(0.3333)	
	
	camera.update(1.0, p.o + p.s*0.5, facingRight)
  
  playerModel.project(camera.proj())
	For i As UInteger = 0 To res.models.size() - 1
		res.models[i].p->project(camera.proj())
	Next i

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
  Sleep 10
Loop Until MultiKey(FB.SC_ESCAPE)

drawBuffer.unbind(@playerModel)
drawBuffer.unbind(@playerLight)

For i As UInteger = 0 To res.models.size() - 1
	drawBuffer.unbind(res.models[i].p)
	Delete(res.models[i].p)
Next i

For i As UInteger = 0 To res.lights.size() - 1
	drawBuffer.unbind(res.lights[i].p)
	Delete(res.lights[i].p)
Next i

Delete(res.blockGrid)
'/