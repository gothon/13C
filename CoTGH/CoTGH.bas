#Include "projection.bi"
#Include "vertex.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#include "image32.bi"
#Include "raster.bi"
#Include "imageops.bi"

Dim As Projection proj = Projection(320, 240, 5, 5, 2)
Dim As Vertex cube(0 To 7) = { _
    Type(Vec3F(-1, 1, 1)), Type(Vec3F(1, 1, 1)), Type(Vec3F(1, 1, -1), Vec2F(15.9,0.1), Vec3f(1.0, 0.0, 0.0)), Type(Vec3F(-1, 1, -1), Vec2F(0.1,0.1),  Vec3f(0.0, 1.0, 0.0)), _
    Type(Vec3F(-1, -1, 1)), Type(Vec3F(1, -1, 1)), Type(Vec3F(1, -1, -1), Vec2F(15.9,15.9),  Vec3f(0.0, 0.0, 1.0)), Type(Vec3F(-1, -1, -1), Vec2F(0.1,15.9),  Vec3f(1.0, 1.0, 0.0))}
    
Dim As Vertex scn(0 To 7)
ScreenRes 1280, 960, 32

Dim As Image32 a = Image32(16, 16)
Dim As Image32 b = Image32(320, 240) 

For y As Integer = 0 To 15
  For x As Integer = 0 To 15
    Dim As Integer col = (x xor y) * 20
    If col > 255 Then col = 255
    PSet a.fbImg(), (x, y), RGB(col, col, col)
  Next x
Next y

Dim As Single t = 5.5
Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 
Do
  Line b.fbImg(), (0,0)-(319, 239), RGB(64,55,78), BF
  t = Timer * 1
    proj.placeAndLookAt(Vec3F(Sin(t*0.5)*4, 0, Cos(t*0.5)*4), Vec3F(0, 0, 0))
  For i As Integer = 0 To 7
    proj.project(cube(i), @scn(i))
    scn(i).c = cube(i).c
  Next i
  
  raster.drawPlanarQuad_TexturedModulated(a, @scn(3), @scn(2), @scn(6), @scn(7), false, false, @b)
  
  Line b.fbImg(), (scn(0).p.x, scn(0).p.y)-(scn(1).p.x, scn(1).p.y)
  Line b.fbImg(), (scn(1).p.x, scn(1).p.y)-(scn(2).p.x, scn(2).p.y)
  Line b.fbImg(), (scn(2).p.x, scn(2).p.y)-(scn(3).p.x, scn(3).p.y)
  Line b.fbImg(), (scn(3).p.x, scn(3).p.y)-(scn(0).p.x, scn(0).p.y)
  
  Line b.fbImg(), (scn(4).p.x, scn(4).p.y)-(scn(5).p.x, scn(5).p.y)
  Line b.fbImg(), (scn(5).p.x, scn(5).p.y)-(scn(6).p.x, scn(6).p.y)
  Line b.fbImg(), (scn(6).p.x, scn(6).p.y)-(scn(7).p.x, scn(7).p.y)
  Line b.fbImg(), (scn(7).p.x, scn(7).p.y)-(scn(4).p.x, scn(4).p.y)
  
  Line b.fbImg(), (scn(0).p.x, scn(0).p.y)-(scn(4).p.x, scn(4).p.y)
  Line b.fbImg(), (scn(1).p.x, scn(1).p.y)-(scn(5).p.x, scn(5).p.y)
  Line b.fbImg(), (scn(2).p.x, scn(2).p.y)-(scn(6).p.x, scn(6).p.y)
  Line b.fbImg(), (scn(3).p.x, scn(3).p.y)-(scn(7).p.x, scn(7).p.y)

  imageops.sync4X(b)
  
  Locate 1, 1: Print fps / fpsCaptures, lastFps
  If (Timer - fpsTimer) > 1.0f Then
    fps += f
    lastFps = f
    fpsCaptures += 1
    f = 0
    fpsTimer = Timer
  EndIf
  f += 1
Loop Until MultiKey(FB.SC_ESCAPE)