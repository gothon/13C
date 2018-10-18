
#Include "vertex.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#Include "raster.bi"
#Include "image32.bi"

ScreenRes 1024, 768, 32, 2
ScreenSet 1,0


Dim As Image32 a = Image32(16, 16)
Dim As Image32 b = Image32(16, 16)

Dim As Single d = Timer
Do
  Cls
  Dim As Single ds = Timer - d
  Dim As Vec3F pts(0 To 3) = {Vec3F(511 + ds, 30, 0), Vec3F(900 + ds, 580, 0), Vec3F(800 + ds, 633, 0), Vec3F(100 + ds, 700, 0)}
  
  
  
  Dim As Vertex quad(0 To 3) = _
      {Type(pts(0)/32), Type(pts(1)/32), Type(pts(2)/32), Type(pts(3)/32)}
      
  raster.drawPlanarQuad(a, Vec3F(0,0,0), @quad(0), @quad(1), @quad(2), @quad(3), @b)
  
  Line (pts(0).x, pts(0).y)-(pts(1).x, pts(1).y), RGB(255,0,0)
  Line (pts(1).x, pts(1).y)-(pts(2).x, pts(2).y), RGB(255,0,0)
  Line (pts(2).x, pts(2).y)-(pts(3).x, pts(3).y), RGB(255,0,0)
  Line (pts(3).x, pts(3).y)-(pts(0).x, pts(0).y), RGB(255,0,0)
  
  For i As Integer = 0 To 100
    Line (0, i*32)-(1023, i*32), RGB(0, 128, 0)
    Line (i*32, 0)-(i*32, 767), RGB(0, 128, 0)
  Next
  
  Sleep 30
  flip
Loop Until MultiKey(FB.SC_ESCAPE)
