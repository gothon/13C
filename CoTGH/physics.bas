#Include "physics.bi"

#Include "debuglog.bi"
#Include "util.bi"

Namespace physics
	
Constructor ClipResult()
	''
End Constructor
	
Constructor ClipResult(ByRef clipV As Const Vec2F, clipAxis As Axis)
	This.clipV = clipV
	This.clipAxis = clipAxis
End Constructor
	
Constructor BlockGrid(w As UInteger, h As UInteger, l As Double)
	DEBUG_ASSERT(w >= 1)
	DEBUG_ASSERT(h >= 1)
	DEBUG_ASSERT(l > 0.0)
	This.w_ = w
	This.h_ = h
	This.l_ = l
	This.blocks_ = New BlockType[w * h]
End Constructor

Destructor BlockGrid()
	Delete(This.blocks_)
End Destructor

Sub BlockGrid.putBlock(x As UInteger, y As UInteger, t As BlockType)
	DEBUG_ASSERT(x < w_)
	DEBUG_ASSERT(y < h_)
	blocks_[y*w_ + x] = t
End Sub
Sub BlockGrid.putBlock(index As UInteger, t As BlockType)
	DEBUG_ASSERT(index < (w_*h_))
	blocks_[index] = t
End Sub
  
Function BlockGrid.getBlock(x As UInteger, y As UInteger) As BlockType
	DEBUG_ASSERT(x < w_)
	DEBUG_ASSERT(y < h_)
	Return blocks_[y*w_ + x]
End Function

Function ceilFromZero(x As Single) As Single
    Return IIf((x - Int(x)) > 0, Int(x + 1), Int(x))
End Function

Const As Double IMPACT_SOFTEN = 0.99

Function BlockGrid.clipRect( _
		ByRef rect As Const AABB, _
		ByVal v As Vec2F) As ClipResult
	If (v.x = 0) AndAlso (v.y = 0) Then Return ClipResult(v, Axis.NONE)

  Dim As Double boundX = Any
  Dim As Double boundY = Any
  
  Dim As Double roundX = Any
  Dim As Double roundY = Any
  
  Dim As Integer squareX = Any
  Dim As Integer squareY = Any
        
  If v.x > 0 Then 
      boundX = rect.o.x + rect.s.x 
      roundX = 1
      squareX = ceilFromZero(boundX / l_) - 1
  Else
      boundX = rect.o.x
      roundX = 0
      squareX = Int(boundX / l_)
  End If
  
  If v.y > 0 Then 
      boundY = rect.o.y + rect.s.y
      roundY = 1
      squareY = ceilFromZero(boundY / l_) - 1
  Else
      boundY = rect.o.y
      roundY = 0
      squareY = Int(boundY / l_) 
  End If
 	
 	Dim As Vec2F tEnd = rect.o   
  Dim As Double timeLeft = 1

  Dim As Double wallX = (squareX + roundX) * l_
  Dim As Double wallY = (squareY + roundY) * l_ 

  Dim As Integer rSignX = roundX * 2 - 1
  Dim As Integer rSignY = roundY * 2 - 1
 	
 	Dim As Axis collideAxis = Axis.NONE
  While TRUE
  	Dim As Double timeToX = IIf(v.x = 0, 1, (wallX - boundX) / v.x)
  	Dim As Double timeToY = IIf(v.y = 0, 1, (wallY - boundY) / v.y)
  	
    If (timeToX >= timeLeft) AndAlso (timeToY >= timeLeft) Then Exit While

		Dim As Axis overrideAxis = Axis.NONE		
		If (timeToX < 1) AndAlso (timeToY < 1) Then
	  	Dim As BlockType curBlock = GetBlock(squareX + rSignX, squareY + rSignY)
			If (timeToX = timeToY) AndAlso ((curBlock = BlockType.FULL) OrElse _
					((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0))) Then
				Dim As BlockType xBlock = GetBlock(squareX + rSignX, squareY)
				Dim As BlockType yBlock = GetBlock(squareX, squareY + rSignY)
				
				Dim As Boolean xSolid = (xBlock = BlockType.FULL)
				Dim As Boolean ySolid = ((yBlock = BlockType.FULL) OrElse ((yBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0)))
				
				If (xSolid AndAlso ySolid) OrElse ((Not xSolid) AndAlso (Not ySolid)) Then
					timeLeft = IIf(timeToX < timeToY, timeToX, timeToY)
					collideAxis = Axis.XY
					Exit While
				ElseIf ySolid Then
					overrideAxis = Axis.Y
				Else 'xSolid Then
					overrideAxis = Axis.X
				EndIf
			End If
		EndIf 

    If (timeToX < timeToY) OrElse (overrideAxis = Axis.X) Then   
    	Dim As Double shiftY = timeToX * v.y 

      Dim As Integer startSquareX = squareX + rSignX
      Dim As Integer startSquareY = Int((tEnd.y + shiftY) / l_)

    	Dim As Boolean wallHitX = FALSE      
      While (startSquareY * l_) <= (ceilFromZero(tEnd.y + rect.s.y + shiftY) - 1)	
	      If GetBlock(startSquareX, startSquareY) = BlockType.FULL Then 
	          wallHitX = TRUE 
	          Exit While
	      End If
        startSquareY += 1
      Wend
      
    	tEnd.x += (wallX - boundX)*IMPACT_SOFTEN
      tEnd.y += shiftY*IMPACT_SOFTEN
      
      boundX = wallX
      boundY += shiftY*IMPACT_SOFTEN
  
      wallX += rSignX * l_
      squareX += rSignX
      
      timeLeft -= timeToX

      If wallHitX = TRUE Then 
      	v.x = 0
      	timeToX = 1
      	If collideAxis = Axis.NONE Then 
      		collideAxis = Axis.X
      	ElseIf collideAxis = Axis.Y Then
      		collideAxis = Axis.XY
      	EndIf
      EndIf
    Else
      Dim As Double shiftX = timeToY * v.x
      
      Dim As Integer startSquareX = Int((tEnd.x + shiftX) / l_)       
      Dim As Integer startSquareY = squareY + rSignY

	    Dim As Boolean wallHitY = FALSE
      While (startSquareX * l_) <= (ceilFromZero(tEnd.x + rect.s.x + shiftX) - 1)
	      Dim As BlockType curBlock = GetBlock(startSquareX, startSquareY)
	      If (curBlock = BlockType.FULL) OrElse ((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0)) Then 
	        wallHitY = TRUE
	        Exit While  
	      End If
	      startSquareX += 1
      Wend
            
      tEnd.x += shiftX*IMPACT_SOFTEN
      tEnd.y += (wallY - boundY)*IMPACT_SOFTEN
      
      boundX += shiftX*IMPACT_SOFTEN
      boundY = wallY         
      
      wallY += rSignY * l_
      squareY += rSignY
      
      timeLeft -= timeToY
     
    	If wallHitY = TRUE Then
    		v.y = 0   
    		timeToY = 1
      	If collideAxis = Axis.NONE Then 
      		collideAxis = Axis.Y
      	ElseIf collideAxis = Axis.X Then
      		collideAxis = Axis.XY
      	EndIf
    	EndIf
    End If
  Wend
  
  tEnd += v * timeLeft

	Return ClipResult((tEnd - rect.o)*IIf(collideAxis = Axis.NONE, 1.0, IMPACT_SOFTEN), collideAxis)
End Function
End Namespace
