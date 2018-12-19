#Include "projection.bi"
#Include "vec3f.bi"
#Include "fbgfx.bi"
#include "image32.bi"
#Include "imageops.bi"
#Include "quadmodel.bi"
#Include "quaddrawbuffer.bi"
#Include "physics.bi"

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
model3.translate(Vec3F(32+8,252,0))

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

Dim As AABB p = AABB(Vec2F(32, 240), Vec2F(16, 24))

Dim As Integer f = 0
Dim As Single fps = 0
Dim As Single lastFps
Dim As Integer fpsCaptures = 0
Dim As Single fpsTimer = Timer 

#define gridSize 16

#define playerWidth  16
#define playerHeight 24

#define init_gravity_pull -4
#define critical_velocity 50
#define TEST_move_speed_X 10
#define TEST_jump_power 40

function z_ceil(byval x as double) as double
    return iif(x-int(x) > 0, int(x+1), int(x))
end Function
dim as double global_frame_time = 0.07 'so 35 frames = 1 second 
Dim As Vec2F v

Do
  


  
    'do player physics
    '-------------------apply global forces and stuff-----------------------
    'assume player has normal gravity (North to South)
    v.y += init_gravity_pull
    if abs(v.y) > critical_velocity then v.y = sgn(v.y) * critical_velocity
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
    


    
    '--------------------------------------------------------------------
    
    '------------------perform collision checking-------------------------
    
    'assume player is currently collision free
    dim as double bound_x, bound_y, round_x, round_y, timeToX, timeToY, tent_x, tent_y, wall_x, wall_y, square_x, square_y
    dim as double start_square_x, start_square_y, time_left, rsign_x, rsign_y, shift_x, shift_y
    dim as Boolean wall_hit_x, wall_hit_y, corner_collide

    
    if v.y > 0 then 
        bound_y = p.o.y + p.s.y
        round_y = 1
        square_y = z_ceil(bound_y / gridSize) - 1
    else
        bound_y = p.o.y
        round_y = 0
        square_y = int(bound_y / gridSize) 
    end if
    
    if v.x > 0 then 
        bound_x = p.o.x + p.s.x 
        round_x = 1
        square_x = z_ceil(bound_x / gridSize) - 1                  'the grid column our boundary falls into
    else
        bound_x = p.o.x
        round_x = 0
        square_x = int(bound_x / gridSize)
    end if
    tent_x = p.o.x
    tent_y = p.o.y
    
    time_left = global_frame_time
    timeToX = global_frame_time 'since we dont know that we will even hit anything yet
    timeToY = global_frame_time

    wall_y = (square_y + round_y) * gridSize 
    wall_x = (square_x + round_x) * gridSize             'the actual position of the boundary wall     
    
    rsign_x = round_x*2 - 1
    rsign_y = round_y*2 - 1

    while time_left > 0
        
        if v.x <> 0 then timeToX = (wall_x - bound_x) / v.x 
        if v.y <> 0 then timeToY = (wall_y - bound_y) / v.y
    
        if (timeToX >= time_left) and (timeToY >= time_left) then
        
            tent_x += v.x * time_left
            tent_y += v.y * time_left
         
            time_left = 0 'we'll always pretend we moved the full amount, also test code
            
            exit while 'EXIT 
        end if
       
        corner_collide = FALSE
        if (timeToX = timeToY) andAlso _
        		((blocks.GetBlock(square_x + rsign_x, square_y + rsign_y) = physics.BlockType.FULL) OrElse ((blocks.GetBlock(square_x + rsign_x, square_y + rsign_y) = physics.BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0))) then corner_collide = TRUE
        
        if timeToX < timeToY then
           
            shift_y = timeToX * v.y
        
            start_square_y = int((tent_y + shift_y) / gridSize)
            start_square_x = square_x + sgn(v.x)
    
            wall_hit_x = FALSE
            while start_square_y*16 <= z_ceil(tent_y + playerHeight + shift_y) - 1
                if blocks.GetBlock(start_square_x, start_square_y) = physics.BlockType.FULL then 
                    wall_hit_x = TRUE 
                    exit while
                end if
               
                start_square_y += 1
            wend
            
            if wall_hit_x = TRUE orElse corner_collide = FALSE then
                
                tent_x += wall_x - bound_x
                bound_x = wall_x
            
                tent_y  += shift_y
                bound_y += shift_y
            
                wall_x   += gridSize*rsign_x
                square_x += rsign_x
                
                time_left -= timeToX
    
                if wall_hit_x = TRUE then 
                    v.x = 0
                    timeToX = global_frame_time
                end if    
            end if
        else 
            
            shift_x = timeToY * v.x
            
            start_square_y = square_y + sgn(v.y)
            start_square_x = int((tent_x + shift_x) / gridSize) 
            
            wall_hit_y = FALSE
            while start_square_x*16 <= z_ceil(tent_x + playerWidth + shift_x) - 1
               
                If ((blocks.GetBlock(start_square_x, start_square_y) = physics.BlockType.FULL) OrElse ((blocks.GetBlock(start_square_x, start_square_y) = physics.BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0))) then 
                    wall_hit_y = TRUE 'so there was a wall here
                    exit while
                   
                end if
                
                start_square_x += 1
            wend
            
            if wall_hit_y = TRUE orElse corner_collide = FALSE then
                
                tent_y += wall_y - bound_y
                bound_y = wall_y          
                
                tent_x  += shift_x
                bound_x += shift_x
                
                wall_y   += gridSize*rsign_y
                square_y += rsign_y
                
                time_left -= timeToY
               
                if wall_hit_y = TRUE then 
                    v.y = 0
                    timeToY = global_frame_time 
                end if
                
            end if
       
        end if
        
        if wall_hit_x = FALSE and wall_hit_y = FALSE and corner_collide = TRUE then
           
            if abs(v.y) > abs(v.x) then
                v.y = 0
                timeToY = global_frame_time
            else
                v.x = 0
                timeToX = global_frame_time
            end if
        end if
    wend
    
   
  	model3.translate(Vec3F(tent_x - p.o.x, tent_y - p.o.y, 0.0))
  
    p.o.x = tent_x
    p.o.y = tent_y





















	

  Line b.fbImg(), (0,0)-(639, 479), RGB(64,55,78), BF
  
  'Magic numbers are 14, 230 for y, z
  proj.placeAndLookAt( _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, 230), _
  		Vec3F(p.o.x + p.s.x*0.5, p.o.y + p.s.y*0.5 + 14, -8))
  
  
  model.project(proj)
  model3.project(proj)
  
  drawBuffer.draw(@b)
  
  Put (0,0), b.fbImg(), PSET
  'imageops.sync2X(b)
  
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
drawBuffer.unbind(@model)
drawBuffer.unbind(@model3)
