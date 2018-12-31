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


maputils.parseMap("res/example.tmx")

'translate ISG
'	
'
'
'



Dim As Projection proj = Projection(640, 480, 320, 240, 256)

ScreenRes 640, 480, 32

Dim As Image32 b = Image32(640, 480)   
Dim As QuadDrawBuffer drawBuffer

#Define QT(_X_) QuadModelTextureCube(_X_, _X_, _X_, _X_, _X_)
#Define QU() QuadModelTextureCube(2, 1, 2, 0, 2)

Dim As QuadModelTextureCube grid(0 To 1121) = { _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0),  QU(),  QU(), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(0), _
    QT(0), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(0), _
    QT(0), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(1), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), _
    QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0), QT(0)}
Dim As String worldTex(0 To 0) = {"res/cshapes3.png"}
Dim As QuadModelUVIndex uvIndices(0 To 1) = {QuadModelUVIndex(Vec2F(0, 0), Vec2F(16, 16), 0), QuadModelUVIndex(Vec2F(240, 32), Vec2F(256, 48), 0)}
Dim As QuadModel model = QuadModel(grid(), 22, 17, 3, 16, uvIndices(), worldTex())

Dim As QuadSprite model3 = QuadSprite("res/object.png")


Dim As AABB p = AABB(Vec2F(62.01, 65.0001), Vec2F(16, 24))
model3.translate(Vec3F(p.o.x+8,p.o.y+12,0))

model.translate(Vec3F(0,0,8))

Dim As physics.BlockGrid blocks = physics.BlockGrid(20, 15, 16)
blocks.PutBlock(0, 0, physics.BlockType.FULL)
blocks.PutBlock(0, 1, physics.BlockType.FULL)
blocks.PutBlock(0, 2, physics.BlockType.FULL)
blocks.PutBlock(0, 3, physics.BlockType.FULL)
blocks.PutBlock(0, 4, physics.BlockType.FULL)
blocks.PutBlock(0, 5, physics.BlockType.FULL)
blocks.PutBlock(0, 6, physics.BlockType.FULL)
blocks.PutBlock(0, 7, physics.BlockType.FULL)

blocks.PutBlock(1, 0, physics.BlockType.FULL)
blocks.PutBlock(2, 0, physics.BlockType.FULL)
blocks.PutBlock(3, 0, physics.BlockType.FULL)
blocks.PutBlock(4, 0, physics.BlockType.FULL)
blocks.PutBlock(5, 0, physics.BlockType.FULL)
blocks.PutBlock(6, 0, physics.BlockType.FULL)
blocks.PutBlock(7, 0, physics.BlockType.FULL)
blocks.PutBlock(7, 1, physics.BlockType.FULL)

blocks.PutBlock(8, 1, physics.BlockType.FULL)
blocks.PutBlock(9, 1, physics.BlockType.FULL)
blocks.PutBlock(10, 1, physics.BlockType.FULL)
blocks.PutBlock(11, 1, physics.BlockType.FULL)
blocks.PutBlock(12, 1, physics.BlockType.FULL)
blocks.PutBlock(13, 1, physics.BlockType.FULL)
blocks.PutBlock(14, 1, physics.BlockType.FULL)
blocks.PutBlock(15, 1, physics.BlockType.FULL)
blocks.PutBlock(16, 1, physics.BlockType.FULL)
blocks.PutBlock(17, 1, physics.BlockType.FULL)
blocks.PutBlock(18, 1, physics.BlockType.FULL)
blocks.PutBlock(19, 1, physics.BlockType.FULL)

blocks.PutBlock(19, 1, physics.BlockType.FULL)
blocks.PutBlock(19, 2, physics.BlockType.FULL)
blocks.PutBlock(19, 3, physics.BlockType.FULL)
blocks.PutBlock(19, 4, physics.BlockType.FULL)
blocks.PutBlock(19, 5, physics.BlockType.FULL)
blocks.PutBlock(19, 6, physics.BlockType.FULL)
blocks.PutBlock(19, 7, physics.BlockType.FULL)

blocks.PutBlock(4, 3, physics.BlockType.ONE_WAY_UP)
blocks.PutBlock(5, 3, physics.BlockType.ONE_WAY_UP)

drawBuffer.bind(@model)
drawBuffer.bind(@model3)

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

#define gridSize 16

#define playerWidth  16
#define playerHeight 24

#define init_gravity_pull -0.5
#define critical_velocity -10
#Define TEST_move_speed_X 1
#define TEST_jump_power 2

function z_ceil(byval x as double) as double
    return iif(x-int(x) > 0, int(x+1), int(x))
end Function
dim as double global_frame_time = 0.07 'so 35 frames = 1 second 
Dim As Vec2F v = Vec2F(0,-1)

Do
  


  
    'do player physics
    '-------------------apply global forces and stuff-----------------------
    'assume player has normal gravity (North to South)
    v.y += init_gravity_pull
    If v.y < critical_velocity then v.y = critical_velocity
    '-----------------------------------------------------------------------
    
    '-------------------apply control forces and stuff-----------------
    'assume player has normal controls (Fixed West to East)
    'up    48
    'right 4d
    'down  50
    'left  4b
    'space 39
    
    v.x *= 0.9 'treat friction constant N as = Infinity
    
    if multikey(fb.SC_LEFT) then v.x -= TEST_move_speed_X
    if multikey(fb.SC_RIGHT) then v.x += TEST_move_speed_X
    if multikey(fb.SC_UP) then v.y += TEST_jump_power
    
   	 
   	Dim As physics.ClipResult res = blocks.clipRect(p, v) 

    p.o += res.clipV
  	model3.translate(Vec3F(res.clipV.x, res.clipV.y, 0.0))
  
    If res.clipAxis And physics.Axis.X Then
    	If res.clipAxis And physics.Axis.Y Then
    		v = Vec2F(0,0)
    	Else 
    		v.x = 0
    	End If
    ElseIf res.clipAxis And physics.Axis.Y Then
    	v.y = 0
    EndIf


















	

  Line b.fbImg(), (0,0)-(639, 479), RGB(64,55,78), BF
  
  'Magic numbers are 14, 230 for y, z
  proj.placeAndLookAt( _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, 230), _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, -8))
  
  
  model.project(proj)
  model3.project(proj)
  
  drawBuffer.draw(@b)
  
  ScreenLock
  Put (0,0), b.fbImg(), PSET
  ScreenUnLock
  /'
  Locate 1, 1: Print fps / fpsCaptures, lastFps
  If (Timer - fpsTimer) > 1.0f Then
    fps += f
    lastFps = f
    fpsCaptures += 1
    f = 0
    fpsTimer = Timer
  EndIf
  f += 1
  '/
  Sleep 15
Loop Until MultiKey(FB.SC_ESCAPE)
drawBuffer.unbind(@model)
drawBuffer.unbind(@model3)
