#Include "projection.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#include "image32.bi"
#Include "imageops.bi"
#Include "quadmodel.bi"
#Include "quaddrawbuffer.bi"

Dim As Projection proj = Projection(320, 240, 320, 240, 1)

ScreenRes 1280, 960, 32

Dim As Image32 b = Image32(320, 240)   
Dim As QuadSprite sprite = QuadSprite("res/itsastoneluigi.png")
Dim As QuadSprite sprite2 = QuadSprite("res/itsastoneluigi.png")
Dim As QuadDrawBuffer drawBuffer

sprite2.translate(Vec3F(15.2, 0.0, 0.0))

drawBuffer.bind(@sprite2)
drawBuffer.bind(@sprite)



Dim As Single z=0.9

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

Do
  
  Line b.fbImg(), (0,0)-(319, 239), RGB(64,55,78), BF
  
  proj.placeAndLookAt(Vec3F(0, 0, 0.9), Vec3F(0, 0, 0))

  
  sprite.project(proj)
  sprite2.project(proj)
  
  
  drawBuffer.draw(@b)
  
  imageops.sync4X(b)
  Locate 1, 1: Print fps / fpsCaptures, lastFps, z
  If (Timer - fpsTimer) > 1.0f Then
    fps += f
    lastFps = f
    fpsCaptures += 1
    f = 0
    fpsTimer = Timer
  EndIf
  f += 1
  
Loop Until MultiKey(FB.SC_ESCAPE)
drawBuffer.unbind(@sprite)
drawBuffer.unbind(@sprite2)