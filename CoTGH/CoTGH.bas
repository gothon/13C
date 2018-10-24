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
Dim As QuadModel model = QuadModel(grid(), 4, 3, 4, 16, textures())

model.translate(Vec3F(-140, -96, 0.0f))

Dim As Single z = 140

drawBuffer.bind(@model)

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

Do
  
  Line b.fbImg(), (0,0)-(319, 239), 0, BF 'RGB(64,55,78), BF
  z -= 0.01
  if z < -140 then z = 140
  proj.placeAndLookAt(Vec3F(40 + z, 14, 230), Vec3F(z, 0, 0))
  
  model.project(proj)

  
  drawBuffer.draw(@b)
  
  Circle b.fbImg(), (160, 140), 2, RGB(0, 255, 0),,,,F
  Circle b.fbImg(), (160, 175), 2, RGB(255, 0, 0),,,,F
  
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
