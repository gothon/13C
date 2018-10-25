#Include "projection.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#include "image32.bi"
#Include "imageops.bi"
#Include "quadmodel.bi"
#Include "quaddrawbuffer.bi"

Dim As Projection proj = Projection(320, 240, 320, 240, 256)

ScreenRes 1280, 960, 32

Dim As Image32 b = Image32(320, 240)   
Dim As QuadDrawBuffer drawBuffer

#Define QT(_X_) QuadModelTextureCube(_X_, _X_, _X_, _X_, _X_)

Dim As QuadModelTextureCube grid(0 To 47) = { _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(1), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(1), QT(1), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0)}

Dim As String textures(0 To 0) =  {"res/itsastoneluigi.png"}
Dim As QuadModelUVIndex uvIndices(0 To 0) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(16, 16), 0)}
Dim As QuadModel model = QuadModel(grid(), 4, 3, 4, 16, uvIndices(), textures())

Dim As String textures3(0 To 0) =  {"res/clock.png"}
Dim As QuadModelUVIndex uvIndices3(0 To 2) = { _
    QuadModelUVIndex(Vec2F(0, 0), Vec2F(16, 40), 0), _
    QuadModelUVIndex(Vec2F(16, 0), Vec2F(32, 40), 0), _
    QuadModelUVIndex(Vec2F(32, 34), Vec2F(48, 40), 0)}
Dim As QuadModel model3 = _
    QuadModel(Vec3F(16, 40, 16), QuadModelTextureCube(1, 3, 2, 3, 2), uvIndices3(), textures3())

model.translate(Vec3F(0, 0, 0.0f))
model3.translate(Vec3F(0, 16, -15.9f))

Dim As Single z = 0

drawBuffer.bind(@model)
drawBuffer.bind(@model3)

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

Do
  
  Line b.fbImg(), (0,0)-(319, 239), 0, BF 'RGB(64,55,78), BF
  z = Sin(Timer) * 100
  'Magic numbers are 14, 230 for y, z
  proj.placeAndLookAt(Vec3F(60, 100, 112+z), Vec3F(0, 0, 0))
  
  model.project(proj)
  model3.project(proj)

  
  drawBuffer.draw(@b)
  
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
  'Sleep 30
Loop Until MultiKey(FB.SC_ESCAPE)
drawBuffer.unbind(@model)
drawBuffer.unbind(@model3)
