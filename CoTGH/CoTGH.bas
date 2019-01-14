#Include "aabb.bi"
#Include "projection.bi"
#Include "cameracontroller.bi"
#Include "physics.bi"
#Include "fbgfx.bi"
#Include "vec2f.bi"

ScreenRes 640, 480, 32, 2
ScreenSet 1,0 

Dim As BlockGrid grid = BlockGrid(NULL, 20, 15, 32)

For i As UInteger = 0 To 19
	grid.putBlock(i, 0, BlockType.FULL)
	grid.putBlock(i, 14, BlockType.FULL)
Next i

For i As UInteger = 1 To 13
	grid.putBlock(0, i, BlockType.FULL)
	grid.putBlock(19, i, BlockType.FULL)
Next i

grid.putBlock(9, 12, BlockType.FULL)
grid.putBlock(10, 12, BlockType.FULL)
grid.putBlock(11, 10, BlockType.ONE_WAY_UP)

Dim As DynamicAABB box = DynamicAABB(NULL, AABB(Vec2F(50, 300), Vec2F(32, 48)))

Randomize 10

Dim As Double range(0 To 4)
range(0) = 32 + Rnd*50
For i As Integer = 1 To 4
	range(i) = range(i - 1) + 80 + Rnd*50
Next i

Dim As DynamicAABB boxes(0 To 4) = { _ 
		DynamicAABB(NULL, AABB(Vec2F(range(0), 40), Vec2F(32, 32))), _
		DynamicAABB(NULL, AABB(Vec2F(range(1), 40), Vec2F(32, 32))), _
		DynamicAABB(NULL, AABB(Vec2F(range(2), 40), Vec2F(32, 32))), _
		DynamicAABB(NULL, AABB(Vec2F(range(3), 40), Vec2F(32, 32))), _
		DynamicAABB(NULL, AABB(Vec2F(range(4), 40), Vec2F(32, 32)))}
		
For i As Integer = 0 To 4
	boxes(i).setV(Vec2f(Rnd * 300 - 150, Rnd * 300 - 150))
Next i


Dim As Simulation sim
sim.setForce(Vec2F(0, 100))


sim.add(@grid)
sim.add(@box)

For i As Integer = 0 To 4
	sim.add(@(boxes(i)))
Next i

Dim As Boolean lastSpace = FALSE
Dim As boolean gravity = FALSE

Do 
	Dim As Vec2F v = box.getV() 

	If MultiKey(fb.SC_SPACE) Then
		If Not lastSpace Then 
			gravity = Not gravity
			If gravity Then
				sim.setForce(Vec2F(0, 0))
			Else
				sim.setForce(Vec2F(0, 100))
			EndIf
		EndIf
		lastSpace = TRUE
	Else 
		lastSpace = FALSE
	EndIf

	If MultiKey(fb.SC_UP) Then v.y -= 10
	If MultiKey(fb.SC_RIGHT) Then v.x += 10
	If MultiKey(fb.SC_DOWN) Then v.y += 10
	If MultiKey(fb.SC_LEFT) Then v.x -= 10

	box.setV(v)
	
	sim.update(0.03333)
	
	Cls
	For y As UInteger = 0 To 14
		For x As UInteger = 0 To 19
			If grid.getBlock(x, y) = BlockType.FULL Then
				Line (x*32, y*32)-(x*32+31, y*32+31), RGB(0,255,0), BF
			ElseIf grid.getBlock(x, y) = BlockType.ONE_WAY_UP Then
				Line (x*32, y*32+31)-(x*32+31, y*32+31), RGB(0,255,0), B
			EndIf
		Next x
	Next y

	Line (box.getAABB().o.x, box.getAABB().o.y)-(box.getAABB().o.x + box.getAABB().s.x - 1, box.getAABB().o.y + box.getAABB().s.y - 1), RGB(0,0,255), BF

	For i As Integer = 0 To 4
			Line (boxes(i).getAABB().o.x, boxes(i).getAABB().o.y)-(boxes(i).getAABB().o.x + boxes(i).getAABB().s.x - 1, boxes(i).getAABB().o.y + boxes(i).getAABB().s.y - 1), RGB(255,128,0), BF
	Next i
	

	Sleep 30
	flip
Loop Until MultiKey(fb.SC_ESCAPE)

sim.remove(@grid)
sim.remove(@box)

For i As Integer = 0 To 4
	sim.remove(@(boxes(i)))
Next i