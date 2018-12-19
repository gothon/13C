#Include "physics.bi"

#Include "debuglog.bi"
#Include "util.bi"

Namespace physics
	
Constructor ClipResult()
	''
End Constructor
	
Constructor ClipResult(ByRef clipped As Const Vec2F, clipAxis As Axis)
	This.clipped = clipped
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

Function ceilFromZero(x As Double) As Double
    Return IIf((x - Int(x)) > 0, Int(x + 1), Int(x))
End Function

Function BlockGrid.clipRect( _
		ByRef rect As Const AABB, _
		ByVal v As Vec2F) As ClipResult
	If (v.x = 0) AndAlso (v.y = 0) Then Return ClipResult(rect.o + v, Axis.NONE)

  Dim As Single boundX = Any
  Dim As Single boundY = Any
  
  Dim As Single roundX = Any
  Dim As Single roundY = Any
  
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
  Dim As Single timeLeft = 1

  Dim As Single wallX = (squareX + roundX) * l_
  Dim As Single wallY = (squareY + roundY) * l_ 

  Dim As Integer rSignX = roundX * 2 - 1
  Dim As Integer rSignY = roundY * 2 - 1

  While TRUE
  	Dim As Single timeToX = 0
  	Dim As Single timeToY = 0
  	
    If v.x <> 0 Then timeToX = (wallX - boundX) / v.x 
    If v.y <> 0 Then timeToY = (wallY - boundY) / v.y

    If (timeToX >= timeLeft) AndAlso (timeToY >= timeLeft) Then Exit While

  	Dim As BlockType curBlock = GetBlock(squareX + rSignX, squareY + rSignY)
  	Dim As Boolean cornerCollide = IIf( _ 
				(timeToX = timeToY) AndAlso ((curBlock = BlockType.FULL) OrElse _
						((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0))), _
				TRUE, _
				FALSE)
     
    Dim As Boolean wallHitX = FALSE
    Dim As Boolean wallHitY = FALSE
    
    If timeToX < timeToY Then           
    	Dim As Integer shiftY = timeToX * v.y

      Dim As Integer startSquareX = squareX + rSignX
      Dim As Integer startSquareY = Int((tEnd.y + shiftY) / l_)

      While (startSquareY * l_) <= (ceilFromZero(tEnd.y + rect.s.y + shiftY) - 1)
	      If GetBlock(startSquareX, startSquareY) = BlockType.FULL Then 
	          wallHitX = TRUE 
	          Exit While
	      End If
        startSquareY += 1
      Wend
      
      If (wallHitX = TRUE) OrElse (cornerCollide = FALSE) Then
	      tEnd.x += wallX - boundX
	      tEnd.y += shiftY
	      
	      boundX = wallX
	      boundY += shiftY
	  
	      wallX += rSignX * l_
	      squareX += rSignX
	      
	      timeLeft -= timeToX
	
	      If wallHitX = TRUE Then 
	      	v.x = 0
	      	timeToX = 1
	      EndIf
      End If
    Else             
      Dim As Integer shiftX = timeToY * v.x
      
      Dim As Integer startSquareX = Int((tEnd.x + shiftX) / l_)       
      Dim As Integer startSquareY = squareY + rSignY

      While (startSquareX * l_) <= (ceilFromZero(tEnd.x + rect.s.x + shiftX) - 1)
	      Dim As BlockType curBlock = GetBlock(startSquareX, startSquareY)
	      If (curBlock = BlockType.FULL) OrElse ((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0)) Then 
	        wallHitY = TRUE
	        Exit While  
	      End If
	      startSquareX += 1
      Wend
            
      If (wallHitY = TRUE) OrElse (cornerCollide = FALSE) Then
        tEnd.x += shiftX
        tEnd.y += wallY - boundY
        
        boundX += shiftX
        boundY = wallY         
        
        wallY += rSignY * l_
        squareX += rSignY
        
        timeLeft -= timeToY
       
      	If wallHitY = TRUE Then 
      		v.y = 0   
      		timeToY = 1
      	EndIf
      End If
    End If
        
    If (wallHitX = FALSE) AndAlso (wallHitY = FALSE) AndAlso (cornerCollide = TRUE) Then
      If Abs(v.x) > Abs(v.y) Then
        v.x = 0
        timeToX = 1
      Else
        v.y = 0
        timeToY = 1
      End If
    End If
  Wend
  
  tEnd += v * timeLeft
  
  Dim As Axis collideAxis = Axis.NONE
  If v.x = 0 Then
  	If v.y = 0 Then
    	collideAxis = Axis.XY
  	Else 
  		collideAxis = Axis.X
  	EndIf
  ElseIf v.y = 0 then
  	collideAxis = Axis.Y
  EndIf 
	
	Return ClipResult(tEnd, collideAxis)
End Function
End Namespace
