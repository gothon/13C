#Include "physics.bi"

#Include "debuglog.bi"
#Include "util.bi"
#Include "crt.bi"

DEFINE_PRIMITIVE_PTR(BlockGrid)
DEFINE_PRIMITIVE_PTR(DynamicAABB)

Const As Double MAX_VX = 400
Const As Double MAX_VY = 400
 
Constructor Collider() 
	This.parent_ = NULL
	This.refTag_ = -1
	This.enabled_ = TRUE
	This.ignore_ = NULL
End Constructor

Virtual Destructor Collider()
	DEBUG_ASSERT(refTag_ = -1)
End Destructor

Sub Collider.ignore(parent As act.Actor Ptr)
	ignore_ = parent
End Sub

Function Collider.getTag() As UInteger
	DEBUG_ASSERT(refTag_ <> -1)
	Return refTag_
End Function
  
Sub Collider.tag(tagz As UInteger)
	DEBUG_ASSERT(refTag_ = -1)
	DEBUG_ASSERT(tagz <> -1)
	refTag_ = tagz
End Sub

Sub Collider.untag()
	DEBUG_ASSERT(refTag_ <> -1)
	refTag_ = -1
End Sub

Function Collider.getParent() As act.Actor Ptr
	Return parent_
End Function

Const Function Collider.getIgnore() As act.Actor Ptr
	Return ignore_
End Function
	
Sub Collider.setParent(parent As act.Actor Ptr)
	parent_ = parent
End Sub

Const Function Collider.getDelegate() As Collider_Delegate
	Return colliderDelegate_
End Function

Const Function Collider.getDelta() As Vec2F
	Return delta_
End Function

Sub Collider.setDelta(ByRef delta As Const Vec2F)
	delta_ = delta
End Sub

Sub Collider.setEnabled(enabled As Boolean)
	enabled_ = enabled
End Sub

Const Function Collider.isEnabled() As Boolean
	Return enabled_
End Function

Sub deleteCollider(x As Collider Ptr)
	Select Case x->getDelegate()
		Case Collider_Delegate.BLOCKGRID:
			Delete(CPtr(BlockGrid Ptr, x))
		Case Collider_Delegate.DYNAMICAABB:
			Delete(CPtr(DynamicAABB Ptr, x))			
		Case Else
			DEBUG_ASSERT(FALSE)
	End Select
End Sub
	
Type ClipResult
	Declare Constructor() 'nop
	Declare Constructor(clipAxis As Axis, clipTime As Double)
	As Axis clipAxis = Any
	As Double clipTime = Any
End Type
	
Constructor ClipResult()
	''
End Constructor
	
Constructor ClipResult(clipAxis As Axis, clipTime As Double)
	This.clipAxis = clipAxis
	This.clipTime = clipTime
End Constructor

Constructor BlockGrid(w As UInteger, h As UInteger, l As Double)
	Base.Constructor()
	setDelegate()
	DEBUG_ASSERT(w >= 1)
	DEBUG_ASSERT(h >= 1)
	DEBUG_ASSERT(l > 0.0)
	This.w_ = w
	This.h_ = h
	This.l_ = l
	This.blocks_ = New BlockType[w * h]
End Constructor

Constructor BlockGrid(ByRef rhs As Const BlockGrid)
	This = rhs
End Constructor

Operator BlockGrid.Let(ByRef rhs As Const BlockGrid)
	Base.Constructor()
	setDelegate()
	This.w_ = rhs.w_
	This.h_ = rhs.h_
	This.l_ = rhs.l_
	This.blocks_ = New BlockType[This.w_ * This.h_]
  memcpy(This.blocks_, rhs.blocks_, This.w_*This.h_*SizeOf(BlockType))
End Operator

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
  
Const Function BlockGrid.getBlock(x As UInteger, y As UInteger) As BlockType
	If (x >= w_) OrElse (y >= h_) Then Return BlockType.NONE
	Return blocks_[y*w_ + x]
End Function

Const Function BlockGrid.getWidth() As UInteger
	Return w_
End Function

Const Function BlockGrid.getHeight() As UInteger
	Return h_
End Function

Const Function BlockGrid.getSideLength() As Double
	Return l_
End Function

Sub BlockGrid.setDelegate()
	colliderDelegate_ = Collider_Delegate.BLOCKGRID
End Sub

Function ceilFromZero(x As Single) As Single
    Return IIf((x - Int(x)) > 0, Int(x + 1), Int(x))
End Function

Constructor Arbiter() 'disallowed
	DEBUG_ASSERT(FALSE)
End Constructor

Destructor Arbiter() 
	''
End Destructor
 	
Constructor Arbiter(onAxis As Axis, actorRef As act.Actor Ptr)
	This.onAxis = onAxis
	This.actorRef = actorRef
End Constructor

Constructor DynamicAABB(ByRef box As Const AABB)
	Base.Constructor()
	setDelegate()
	This.box_ = box
	This.v_ = Vec2F(0, 0)
	This.ignoreGrav_ = FALSE
End Constructor

Constructor DynamicAABB(ByRef rhs As Const DynamicAABB)
	This = rhs
End Constructor

Operator DynamicAABB.Let(ByRef rhs As Const DynamicAABB)
	Base.Constructor()
	setDelegate()
	This.box_ = rhs.box_
	This.v_ = rhs.v_
End Operator

Sub DynamicAABB.place(ByRef p As Const Vec2F)
	box_.o = p
End Sub

Sub DynamicAABB.setV(ByRef v As Const Vec2F)
	v_ = v
End Sub

Const Function DynamicAABB.getAABB() ByRef As Const AABB
	Return box_
End Function

Const Function DynamicAABB.getV() ByRef As Const Vec2F
	Return v_
End Function

Function DynamicAABB.getArbiters() ByRef As DArray_Arbiter
	Return arbiters_
End Function

Sub DynamicAABB.setDelegate()
	colliderDelegate_ = Collider_Delegate.DYNAMICAABB
End Sub

Sub DynamicAABB.enableGravity(x As Boolean)
	ignoreGrav_ = Not x
End Sub

Const Function DynamicAABB.gravityEnabled() As Boolean
	Return Not ignoreGrav_
End Function

Function clipDynamicAABBToBlockGrid( _
		ByRef rect As Const DynamicAABB, _
		ByRef grid As Const BlockGrid, _
		dt As Double) As ClipResult
	Dim As Vec2F v = rect.getV() 'const
	If (v.x = 0) AndAlso (v.y = 0) Then Return ClipResult(AxisComponent.NONE, dt)

  Dim As Double boundX = Any
  Dim As Double boundY = Any
  
  Dim As Double roundX = Any
  Dim As Double roundY = Any
  
  Dim As Integer squareX = Any
  Dim As Integer squareY = Any
        
  If v.x > 0 Then 
      boundX = rect.getAABB().o.x + rect.getAABB().s.x 
      roundX = 1
      squareX = ceilFromZero(boundX / grid.getSideLength()) - 1
  Else
      boundX = rect.getAABB().o.x
      roundX = 0
      squareX = Int(boundX / grid.getSideLength())
  End If
  
  If v.y > 0 Then 
      boundY = rect.getAABB().o.y + rect.getAABB().s.y
      roundY = 1
      squareY = ceilFromZero(boundY / grid.getSideLength()) - 1
  Else
      boundY = rect.getAABB().o.y
      roundY = 0
      squareY = Int(boundY / grid.getSideLength()) 
  End If
 	
 	Dim As Vec2F tEnd = rect.getAABB().o  
  Dim As Double timeLeft = dt

  Dim As Double wallX = (squareX + roundX) * grid.getSideLength()
  Dim As Double wallY = (squareY + roundY) * grid.getSideLength() 

  Dim As Integer rSignX = roundX * 2 - 1 'const
  Dim As Integer rSignY = roundY * 2 - 1 'const
  
  Dim As AxisComponent xAxis = IIf(v.x > 0, AxisComponent.X_P, AxisComponent.X_N) 'const
  Dim As AxisComponent yAxis = IIf(v.y > 0, AxisComponent.Y_P, AxisComponent.Y_N) 'const
   
 	While TRUE
  	Dim As Double timeToX = IIf(v.x = 0, dt, (wallX - boundX) / v.x)
  	Dim As Double timeToY = IIf(v.y = 0, dt, (wallY - boundY) / v.y)
  	
    If (timeToX >= timeLeft) AndAlso (timeToY >= timeLeft) Then Exit While

		Dim As Boolean overrideXAxis = FALSE	
		If (timeToX < 1) AndAlso (timeToY < 1) Then
	  	Dim As BlockType curBlock = grid.getBlock(squareX + rSignX, squareY + rSignY)
			If (timeToX = timeToY) AndAlso ((curBlock = BlockType.FULL) OrElse _
					((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0))) Then
				Dim As BlockType xBlock = grid.getBlock(squareX + rSignX, squareY)
				Dim As BlockType yBlock = grid.getBlock(squareX, squareY + rSignY)
				
				Dim As Boolean xSolid = (xBlock = BlockType.FULL)
				Dim As Boolean ySolid = ((yBlock = BlockType.FULL) OrElse ((yBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0)))
				
				If (xSolid AndAlso ySolid) OrElse ((Not xSolid) AndAlso (Not ySolid)) Then
					Return ClipResult(xAxis Or yAxis, dt - (timeLeft - timeToX))
				ElseIf xSolid Then
					overrideXAxis = TRUE
				EndIf
			End If
		EndIf 

    If (timeToX < timeToY) OrElse overrideXAxis Then   
    	Dim As Double shiftY = timeToX*v.y 

      Dim As Integer startSquareX = squareX + rSignX
      Dim As Integer startSquareY = Int((tEnd.y + shiftY) / grid.getSideLength())

    	Dim As Boolean wallHitX = FALSE      
      While (startSquareY*grid.getSideLength()) <= (ceilFromZero(tEnd.y + rect.getAABB().s.y + shiftY) - 1)
	      If grid.getBlock(startSquareX, startSquareY) = BlockType.FULL Then 
	          wallHitX = TRUE 
	          Exit While
	      End If
        startSquareY += 1
      Wend
      timeLeft -= timeToX
      If wallHitX = TRUE Then Return ClipResult(xAxis, dt - timeLeft)
      
    	tEnd.x += (wallX - boundX)
      tEnd.y += shiftY
      
      boundX = wallX
      boundY += shiftY
  
      wallX += rSignX*grid.getSideLength()
      squareX += rSignX
    Else
      Dim As Double shiftX = timeToY * v.x
      
      Dim As Integer startSquareX = Int((tEnd.x + shiftX) / grid.getSideLength())       
      Dim As Integer startSquareY = squareY + rSignY

	    Dim As Boolean wallHitY = FALSE
      While (startSquareX * grid.getSideLength()) <= (ceilFromZero(tEnd.x + rect.getAABB().s.x + shiftX) - 1)
	      Dim As BlockType curBlock = grid.getBlock(startSquareX, startSquareY)
	      If (curBlock = BlockType.FULL) OrElse ((curBlock = BlockType.ONE_WAY_UP) AndAlso (v.y < 0.0)) Then 
	        wallHitY = TRUE
	        Exit While  
	      End If
	      startSquareX += 1
      Wend
      timeLeft -= timeToY
    	If wallHitY = TRUE Then Return ClipResult(yAxis, dt - timeLeft)
            
      tEnd.x += shiftX
      tEnd.y += (wallY - boundY)
      
      boundX += shiftX
      boundY = wallY         
      
      wallY += rSignY*grid.getSideLength()
      squareY += rSignY
    End If
 	Wend
	Return ClipResult(AxisComponent.NONE, dt)
End Function

Function clipDynamicAABBToDynamicAABB( _
		ByRef rectA As Const DynamicAABB, _
		ByRef rectB As Const DynamicAABB, _
		dt As Double) As ClipResult
	If (rectA.getV().x = 0) AndAlso (rectA.getV().y = 0) AndAlso _
			(rectB.getV().x = 0) AndAlso (rectB.getV().y = 0) Then Return ClipResult(AxisComponent.NONE, dt)
	
	Dim As Boolean bBeyondAX = rectB.getAABB().o.x > rectA.getAABB().o.x 'const
	Dim As Boolean bBeyondAY = rectB.getAABB().o.y > rectA.getAABB().o.y 'const
	
	Dim As Double timeToX = Any
	If _
			((Sgn(rectA.getV().x) = 0) AndAlso IIf(bBeyondAX, Sgn(rectB.getV().x) > 0, Sgn(rectB.getV().x) < 0)) OrElse _
			((Sgn(rectB.getV().x) = 0) AndAlso IIf(bBeyondAX, Sgn(rectA.getV().x) < 0, Sgn(rectA.getV().x) > 0)) OrElse _
			(((Sgn(rectA.getV().x)*Sgn(rectB.getV().x)) = -1) AndAlso (bBeyondAX Xor (Sgn(rectA.getV().x) = 1))) Then 
		timeToX = dt
	Else
		Dim As Double boundAX = rectA.getAABB().o.x + IIf(bBeyondAX, rectA.getAABB().s.x, 0) 'const
		Dim As Double boundBX = rectB.getAABB().o.x + IIf(bBeyondAX, 0, rectB.getAABB().s.x) 'const
	 	timeToX = _
				IIf(rectB.getV().x <> rectA.getV().x, (boundAX - boundBX) / (rectB.getV().x - rectA.getV().x), dt) 'const
	End If
				
	Dim As Double timeToY = Any
	If _
			((Sgn(rectA.getV().y) = 0) AndAlso IIf(bBeyondAY, Sgn(rectB.getV().y) > 0, Sgn(rectB.getV().y) < 0)) OrElse _
			((Sgn(rectB.getV().y) = 0) AndAlso IIf(bBeyondAY, Sgn(rectA.getV().y) < 0, Sgn(rectA.getV().y) > 0)) OrElse _
			(((Sgn(rectA.getV().y)*Sgn(rectB.getV().y)) = -1) AndAlso (bBeyondAY Xor (Sgn(rectA.getV().y) = 1))) Then 
		timeToY = dt
	Else
		Dim As Double boundAY = rectA.getAABB().o.y + IIf(bBeyondAY, rectA.getAABB().s.y, 0) 'const
		Dim As Double boundBY = rectB.getAABB().o.y + IIf(bBeyondAY, 0, rectB.getAABB().s.y) 'const
		timeToY = _
				IIf(rectB.getV().y <> rectA.getV().y, (boundAY - boundBY) / (rectB.getV().y - rectA.getV().y), dt) 'const
	End If 
	
	If (timeToX > -0.001) AndAlso (timeToX < 0) Then 
		timeToX = 0 
	Elseif timeToX < 0 Then
		timeToX = dt
	EndIf
	
	If (timeToY > -0.001) AndAlso (timeToY < 0) Then 
		timeToY = 0 
	ElseIf timeToY < 0 Then
		timeToY = dt
	EndIf
	
	If (timeToX >= dt) AndAlso (timeToY >= dt) Then Return ClipResult(AxisComponent.NONE, dt)
	
	If timeToX < dt Then
		Dim As Double shiftedBoundAYLow = rectA.getAABB().o.y + timeToX*rectA.getV().y 'const
		Dim As Double shiftedBoundAYHigh = shiftedBoundAYLow + rectA.getAABB().s.y 'const
		Dim As Double shiftedBoundBYLow = rectB.getAABB().o.y + timeToX*rectB.getV().y 'const
		Dim As Double shiftedBoundBYHigh = shiftedBoundBYLow + rectB.getAABB().s.y 'const
		If (shiftedBoundAYHigh <= shiftedBoundBYLow) OrElse (shiftedBoundBYHigh <= shiftedBoundAYLow) Then timeToX = dt
	End If
	
	If timeToY < dt Then
		Dim As Double shiftedBoundAXLow = rectA.getAABB().o.x + timeToY*rectA.getV().x 'const
		Dim As Double shiftedBoundAXHigh = shiftedBoundAXLow + rectA.getAABB().s.x 'const
		Dim As Double shiftedBoundBXLow = rectB.getAABB().o.x + timeToY*rectB.getV().x 'const
		Dim As Double shiftedBoundBXHigh = shiftedBoundBXLow + rectB.getAABB().s.x 'const
		If (shiftedBoundAXHigh <= shiftedBoundBXLow) OrElse (shiftedBoundBXHigh <= shiftedBoundAXLow) Then timeToY = dt
	End If
		
	If (timeToX >= dt) AndAlso (timeToY >= dt) Then Return ClipResult(AxisComponent.NONE, dt)

	If timeToX < timeToY Then
		Return ClipResult(AxisComponent.X_P Or AxisComponent.X_N, timeToX)
	ElseIf timeToY < timeToX Then
		Return ClipResult(AxisComponent.Y_P Or AxisComponent.Y_N, timeToY)
	Else
		Return ClipResult(AxisComponent.X_P Or AxisComponent.X_N Or AxisComponent.Y_P Or AxisComponent.Y_N, timeToX)	
	EndIf
End Function

Constructor Simulation()
	''
End Constructor

Destructor Simulation()
	''
End Destructor
 	
Constructor Simulation(ByRef rhs As Const Simulation)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator Simulation.Let(ByRef rhs As Const Simulation)
	DEBUG_ASSERT(FALSE)
End Operator
 	
Sub Simulation.setForce(ByRef f As Const Vec2F)
	force_ = f
End Sub

Sub Simulation.add(c As Collider Ptr)
	If c = NULL Then Return
	Select Case As Const c->getDelegate()
		Case Collider_Delegate.BLOCKGRID:
			add(CPtr(BlockGrid Ptr, c))
		Case Collider_Delegate.DYNAMICAABB:
			add(CPtr(DynamicAABB Ptr, c))
		Case Else
			DEBUG_ASSERT(FALSE)	
	End Select
End Sub
 	
Sub Simulation.add(grid As BlockGrid Ptr)
	If grid = NULL Then Return
	Dim As UInteger tag = Any
	StaticList_BlockGridPtr_Emplace(grids_, tag, grid)
	grid->tag(tag)
End Sub

Sub Simulation.add(box As DynamicAABB Ptr)
	If box = NULL Then Return
	Dim As UInteger tag = Any
	StaticList_DynamicAABBPtr_Emplace(boxes_, tag, box)
	box->tag(tag)	
End Sub

Sub Simulation.remove(c As Collider Ptr)
	If c = NULL Then Return
	Select Case As Const c->getDelegate()
		Case Collider_Delegate.BLOCKGRID:
			remove(CPtr(BlockGrid Ptr, c))
		Case Collider_Delegate.DYNAMICAABB:
			remove(CPtr(DynamicAABB Ptr, c))
		Case Else
			DEBUG_ASSERT(FALSE)	
	End Select
End Sub
 	
Sub Simulation.remove(grid As BlockGrid Ptr)
 	If grid = NULL Then Return
	grids_.remove(grid->getTag())
	grid->untag()
End Sub

Sub Simulation.remove(box As DynamicAABB Ptr)
	If box = NULL Then Return
	boxes_.remove(box->getTag())
	box->untag()
End Sub
 	
Type CollisionEvent
	As Double t = Any
	As Axis onAxis = AxisComponent.NONE
	As Collider Ptr a = Any
	As Collider Ptr b = Any
	As Boolean isBoxToBox = Any
End Type

Sub Simulation.integrateAll(dt As Double)
	Dim As UInteger updateIndex = -1
  While(boxes_.getNext(@updateIndex))
		Dim As DynamicAABB Ptr box = boxes_.get(updateIndex).getValue() 'const

		Dim As Vec2F delta = box->getV()*dt*timeMultiplier_
		
		box->place(box->getAABB().o + delta)
		box->setDelta(box->getDelta() + delta)
  Wend
End Sub

Sub Simulation.setTimeMultiplier(m As Single)
	timeMultiplier_ = m
End Sub

Const As Double IMPACT_SOFTEN = 0.99
 	
Sub Simulation.update(dt As Double)
	Dim As UInteger resetIndex = -1
  While(boxes_.getNext(@resetIndex))
  	Dim As DynamicAABB Ptr box = boxes_.get(resetIndex).getValue()
  	box->getArbiters().clear()
  	
  	Dim As Vec2F v = box->getV()
  	If box->gravityEnabled() Then v += force_*dt*timeMultiplier_
  	If Abs(v.x) > MAX_VX Then v.x = Sgn(v.x)*MAX_VX
		If Abs(v.y) > MAX_VY Then v.y = Sgn(v.y)*MAX_VY
		box->setV(v)
		
  	box->setDelta(Vec2F(0, 0))
  Wend
	
	While dt > 0
		Dim As CollisionEvent event
		event.t = dt
	
		Dim As UInteger indexA = -1
	  While(boxes_.getNext(@indexA))
  		Dim As DynamicAABB Ptr boxA = boxes_.get(indexA).getValue()
  		If Not boxA->isEnabled() Then Continue While
  		Dim As UInteger indexB = indexA
  		If (boxA->getIgnore() = NULL) Then 
	  		While(boxes_.getNext(@indexB))
	  			Dim As DynamicAABB Ptr boxB = boxes_.get(indexB).getValue() 'const
	  			If (Not boxB->isEnabled()) OrElse (boxB->getIgnore() <> NULL) Then Continue While
	  			Dim As ClipResult res = clipDynamicAABBToDynamicAABB(*boxA, *boxB, dt) 'const
	  			If (res.clipAxis = AxisComponent.NONE) OrElse (res.clipTime >= event.t) Then Continue While
	  			
	  			event.t = res.clipTime
	  			event.onAxis = res.clipAxis
	  			event.a = boxA
	  			event.b = boxB
	  			event.isBoxToBox = TRUE
	  		Wend
  		End If
  		indexB = -1
  		While(grids_.getNext(@indexB))
  			Dim As BlockGrid Ptr gridB = grids_.get(indexB).getValue() 'const 		
				If (Not gridB->isEnabled()) _
						OrElse ((gridB->getParent() = boxA->getIgnore()) AndAlso (boxA->getIgnore() <> NULL)) Then Continue While
  			Dim As ClipResult res = clipDynamicAABBToBlockGrid(*boxA, *gridB, dt) 'const
  			If (res.clipAxis = AxisComponent.NONE) OrElse (res.clipTime >= event.t) Then Continue While
  			
  			event.t = res.clipTime
  			event.onAxis = res.clipAxis
  			event.a = boxA
  			event.b = gridB
  			event.isBoxToBox = FALSE
  		Wend	
	  Wend
		
		If event.t >= dt Then 
			integrateAll(event.t)
			dt = 0
			Continue While
		EndIf
		
		event.t *= IMPACT_SOFTEN
		integrateAll(event.t)
	  dt -= event.t
	  
	  Dim As DynamicAABB Ptr boxA = CPtr(DynamicAABB Ptr, event.a)
	  Dim As DynamicAABB Ptr boxB = IIf(event.isBoxToBox, CPtr(DynamicAABB Ptr, event.b), NULL)
	   	
	  If boxB = NULL Then
		  If event.onAxis And (AxisComponent.X_P Or AxisComponent.X_N) Then boxA->setV(Vec2F(0.0, boxA->getV().y))
		  If event.onAxis And (AxisComponent.Y_P Or AxisComponent.Y_N) Then boxA->setV(Vec2F(boxA->getV().x, 0.0))
		  Dim As Boolean foundGridArbiter = FALSE
		  For i As Integer = 0 To boxA->getArbiters().size() - 1
		  	If boxA->getArbiters()[i].actorRef = event.b->getParent() Then 
		  		boxA->getArbiters()[i].onAxis Or= event.onAxis
		  		foundGridArbiter = TRUE
		  		Exit For
		  	EndIf
		  Next i
	  	If foundGridArbiter = FALSE Then DArray_Arbiter_Emplace(boxA->getArbiters(), event.onAxis, event.b->getParent())
	  Else
	  	Dim As Axis arbiterAxisA = AxisComponent.NONE
	  	Dim As Axis arbiterAxisB = AxisComponent.NONE
	 
		  If event.onAxis And (AxisComponent.X_P Or AxisComponent.X_N) Then 
		  	If Sgn(boxA->getV().x) = Sgn(boxB->getV().x) Then
		  		If boxA->getV().x > boxB->getV().x Then 
		  			boxA->setV(Vec2F(0.0, boxA->getV().y))
		  		Else
		  			boxB->setV(Vec2F(0.0, boxB->getV().y))
		  		EndIf
		  	Else
		  		boxA->setV(Vec2F(0.0, boxA->getV().y))
		  		boxB->setV(Vec2F(0.0, boxB->getV().y))
		  	EndIf
		  	If boxA->getAABB().o.x > boxB->getAABB().o.x Then
		  		arbiterAxisA Or= AxisComponent.X_N
		  		arbiterAxisB Or= AxisComponent.X_P
		  	Else
		  		arbiterAxisA Or= AxisComponent.X_P
		  		arbiterAxisB Or= AxisComponent.X_N		  		
		  	EndIf
		  EndIf 
		  
	  	If event.onAxis And (AxisComponent.Y_P Or AxisComponent.Y_N) Then 
		  	If Sgn(boxA->getV().y) = Sgn(boxB->getV().y) Then
		  		'traveling in the same direction
		  		If boxA->getV().y > boxB->getV().y Then 
		  			boxA->setV(Vec2F(boxA->getV().x, 0.0))
		  		Else
		  			boxB->setV(Vec2F(boxB->getV().x, 0.0))
		  		EndIf
		  	Else
		  		'collided head on
		  		boxA->setV(Vec2F(boxA->getV().x, 0.0))
		  		boxB->setV(Vec2F(boxB->getV().x, 0.0))
		  	EndIf
		  	If boxA->getAABB().o.y > boxB->getAABB().o.y Then
		  		arbiterAxisA Or= AxisComponent.Y_N
		  		arbiterAxisB Or= AxisComponent.Y_P
		  	Else
		  		arbiterAxisA Or= AxisComponent.Y_P
		  		arbiterAxisB Or= AxisComponent.Y_N		  		
		  	EndIf
	  	End If
		 
	  	DArray_Arbiter_Emplace(boxA->getArbiters(), arbiterAxisA, event.b->getParent())	  	
		 	DArray_Arbiter_Emplace(boxB->getArbiters(), arbiterAxisB, event.a->getParent())
	  End If
	Wend
End Sub

Function intersectsBlockGrid(ByRef grid As Const BlockGrid, ByRef box As Const AABB) As BlockType
	Dim As Integer ax = Int(box.o.x / grid.getSideLength()) 'const
	Dim As Integer ay = Int(box.o.y / grid.getSideLength()) 'const
	
	Dim As Vec2F extent = box.o + box.s
	
	Dim As Integer bx =	-Int(-(extent.x / grid.getSideLength())) - 1
	Dim As Integer by = -Int(-(extent.y / grid.getSideLength())) - 1
	
	If (bx < 0) OrElse (by < 0) OrElse (ax >= grid.getWidth()) OrElse (ay >= grid.getHeight()) Then Return FALSE
	
	ax = IIf(ax < 0, 0, ax)
	ay = IIf(ay < 0, 0, ay)
	
	bx = IIf(bx >= grid.getWidth(), grid.getWidth() - 1, bx)
	by = IIf(by >= grid.getHeight(), grid.getHeight() - 1, by)
	
	Dim As BlockType retType = BlockType.NONE
	For y As Integer = ay To by
		For x As Integer = ax To bx
			Dim As BlockType block = grid.getBlock(x, y)	
			If block = BlockType.SIGNAL Then retType = BlockType.SIGNAL
			If block = BlockType.FULL Then 
				retType = BlockType.FULL
				GoTo earlyOut
			EndIf
		Next x
	Next y
	earlyOut:
	Return retType
End Function

Const Function Simulation.getIntersects(ByRef box As Const AABB) As DArray_AnyPtr
	Dim As DArray_AnyPtr parents
	Dim As UInteger index = -1
	While(boxes_.getNext(@index))
		Dim As Const DynamicAABB Ptr boxB = boxes_.getConst(index).getValue() 'const
		If (Not boxB->isEnabled()) OrElse (boxB->getIgnore() <> NULL) Then Continue While
		If (boxB->getParent() <> NULL) AndAlso (boxB->getAABB().intersects(box)) Then parents.push(boxB->getParent())
	Wend	
	index = -1
	While(grids_.getNext(@index))
  	Dim As Const BlockGrid Ptr gridB = grids_.getConst(index).getValue() 'const 		
		If Not gridB->isEnabled() Then Continue While
		If (gridB->getParent() <> NULL) Then 
			Dim As BlockType intersectType = intersectsBlockGrid(*gridB, box) 'const
			If intersectType = BlockType.FULL Then parents.push(gridB->getParent())
		EndIf
	Wend	
	Return parents
End Function

Const Function Simulation.getIntersectsBlockGrid(ByRef box As Const AABB) As BlockType
	Dim As UInteger index = -1
	Dim As BlockType retType = BlockType.NONE
	While(grids_.getNext(@index))
  	Dim As Const BlockGrid Ptr gridB = grids_.getConst(index).getValue() 'const 		
		If Not gridB->isEnabled() Then Continue While
		If (gridB->getParent() <> NULL) Then 
			Dim As BlockType intersectType = intersectsBlockGrid(*gridB, box) 'const
			If intersectType = BlockType.FULL Then Return BlockType.FULL
			If intersectType <> BlockType.NONE Then retType = intersectType
		EndIf
	Wend		
	Return retType
End Function
