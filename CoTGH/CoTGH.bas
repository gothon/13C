#Include "projection.bi"
#Include "vertex.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"

Dim As Projection proj = Projection(1024, 768, 5, 5, 2)

Dim As Vertex cube(0 To 7) = { _
    Type(Vec3F(-1, 1, 1)), Type(Vec3F(1, 1, 1)), Type(Vec3F(1, 1, -1)), Type(Vec3F(-1, 1, -1)), _
    Type(Vec3F(-1, -1, 1)), Type(Vec3F(1, -1, 1)), Type(Vec3F(1, -1, -1)), Type(Vec3F(-1, -1, -1))}
    
Dim As Vertex scn(0 To 7)

ScreenRes 1024, 768, 32

Dim As Single t = Timer
Do
  Cls
  
  proj.placeAndLookAt(Vec3F(Sin(Timer*0.5)*4, 0, Cos(Timer*0.5)*4), Vec3F(0, 0, 0))

  For i As Integer = 0 To 7
    scn(i) = proj.project(cube(i))
  Next i
  
  Line (scn(0).p.x, scn(0).p.y)-(scn(1).p.x, scn(1).p.y)
  Line (scn(1).p.x, scn(1).p.y)-(scn(2).p.x, scn(2).p.y)
  Line (scn(2).p.x, scn(2).p.y)-(scn(3).p.x, scn(3).p.y)
  Line (scn(3).p.x, scn(3).p.y)-(scn(0).p.x, scn(0).p.y)
  
  Line (scn(4).p.x, scn(4).p.y)-(scn(5).p.x, scn(5).p.y)
  Line (scn(5).p.x, scn(5).p.y)-(scn(6).p.x, scn(6).p.y)
  Line (scn(6).p.x, scn(6).p.y)-(scn(7).p.x, scn(7).p.y)
  Line (scn(7).p.x, scn(7).p.y)-(scn(4).p.x, scn(4).p.y)
  
  Line (scn(0).p.x, scn(0).p.y)-(scn(4).p.x, scn(4).p.y)
  Line (scn(1).p.x, scn(1).p.y)-(scn(5).p.x, scn(5).p.y)
  Line (scn(2).p.x, scn(2).p.y)-(scn(6).p.x, scn(6).p.y)
  Line (scn(3).p.x, scn(3).p.y)-(scn(7).p.x, scn(7).p.y)
  
  Sleep 10
Loop Until MultiKey(FB.SC_ESCAPE)
