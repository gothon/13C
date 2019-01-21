#Include "quaddrawbuffer.bi"

#Include "debuglog.bi"
#Include "vecmath.bi"
#Include "raster.bi"

Constructor QuadDrawElement()
  'Nop
End Constructor

Destructor QuadDrawElement()
  'Nop
End Destructor

Constructor QuadDrawElement(q As Quad Ptr, parentId As ULongInt)
  This.q = q
  This.parentId = parentId
End Constructor

Constructor QuadDrawBuffer()
	This.globalLightMin_ = 1
	This.globalLightMax_ = 1
	This.globalLightDirection_ = Vec3F(0, 0, -1)
End Constructor

Sub QuadDrawBuffer.setGlobalLightDirection(ByRef d As Const Vec3F)
	globalLightDirection_ = d
	vecmath.normalize(@globalLightDirection_)
End Sub

Sub QuadDrawBuffer.setGlobalLightMinMax(min As Double, max As Double)
	globalLightMin_ = min
	globalLightMax_ = max
	DEBUG_ASSERT(min <= max)
End Sub

Destructor QuadDrawBuffer()
  DEBUG_ASSERT(quads_.size() = 0)
  DEBUG_ASSERT(lights_.size() = 0)
End Destructor

Sub QuadDrawBuffer.bind(model As QuadModelBase Ptr)
	If model = NULL Then Return
  DEBUG_ASSERT(model->size() > 0)
  Dim As UInteger nextIndex = quads_.size()
  quads_.reserve(model->size())
  For i As Integer = 0 To model->size() - 1
    DArray_QuadDrawElement_Emplace(quads_, model->getQuad(i), model->id())
    nextIndex += 1
  Next i
  model->bind()
End Sub

Sub QuadDrawBuffer.unbind(model As QuadModelBase Ptr)
	If model = NULL Then Return
  Dim As Integer curQuadIndex = 0
  While (curQuadIndex < quads_.size())
    If quads_[curQuadIndex].parentId = model->id() Then
      Swap quads_.back(), quads_[curQuadIndex]
      quads_.pop()
      Continue While
    EndIf
    curQuadIndex += 1
  Wend
  model->unbind()
End Sub

Sub QuadDrawBuffer.bind(l As Light Ptr)
	If l = NULL Then Return
  lights_.push(l)
  l->bind()
End Sub

Sub QuadDrawBuffer.unbind(l As Light Ptr)
	If l = NULL Then Return
  For i As UInteger = 0 To lights_.size()
    If lights_[i] = l Then
      Swap lights_.back(), lights_[i]
      lights_.pop()
      Exit For
    EndIf
  Next i
  l->unbind()
End Sub

Sub QuadDrawBuffer.draw(dst As Image32 Ptr)
  sort()
  For i As Integer = quads_.size() - 1 To 0 Step -1
    Dim As Quad Ptr q = quads_[i].q
    If (Not q->enabled) OrElse (q->cull AndAlso backfaceTest(*q)) Then Continue For
    If ((q->pV(0).p.x < 0) AndAlso _
    		(q->pV(1).p.x < 0) AndAlso _
    		(q->pV(2).p.x < 0) AndAlso _
    		(q->pV(3).p.x < 0)) OrElse _
    		((q->pV(0).p.x >= dst->w()) AndAlso _
    		(q->pV(1).p.x >= dst->w()) AndAlso _
    		(q->pV(2).p.x >= dst->w()) AndAlso _
    		(q->pV(3).p.x >= dst->w())) OrElse _
    		((q->pV(0).p.y < 0) AndAlso _
    		(q->pV(1).p.y < 0) AndAlso _
    		(q->pV(2).p.y < 0) AndAlso _
    		(q->pV(3).p.y < 0)) OrElse _    		  
    		((q->pV(0).p.y >= dst->h()) AndAlso _
    		(q->pV(1).p.y >= dst->h()) AndAlso _
    		(q->pV(2).p.y >= dst->h()) AndAlso _
    		(q->pV(3).p.y >= dst->h())) Then Continue For    
    Select Case q->mode
    	Case QuadTextureMode.FLAT:
    		lightQuad(q)
        raster.drawPlanarQuad_Flat( _
            *q->texture, _ 
            @q->pV(0), _ 
            @q->pV(1), _ 
            @q->pV(2), _ 
            @q->pV(3), _ 
            q->trimX, _ 
            q->trimY, _ 
            dst)
      Case QuadTextureMode.TEXTURED:
        raster.drawPlanarQuad_Textured( _
            *q->texture, _ 
            @q->pV(0), _ 
            @q->pV(1), _ 
            @q->pV(2), _ 
            @q->pV(3), _ 
            q->trimX, _ 
            q->trimY, _ 
            dst)
    	Case QuadTextureMode.TEXTURED_MOD:
    		lightQuad(q)
        raster.drawPlanarQuad_TexturedModulated( _
            *q->texture, _ 
            @q->pV(0), _ 
            @q->pV(1), _ 
            @q->pV(2), _ 
            @q->pV(3), _ 
            q->trimX, _ 
            q->trimY, _ 
            dst)
    	Case QuadTextureMode.TEXTURED_CONST:
    		lightQuadConst(q)
        raster.drawPlanarQuad_TexturedConstant( _
            *q->texture, _ 
            @q->pV(0), _ 
            @q->pV(1), _ 
            @q->pV(2), _ 
            @q->pV(3), _ 
            q->trimX, _ 
            q->trimY, _ 
            dst)
    End Select
  Next i 
End Sub

Sub QuadDrawBuffer.lightQuad(q As Quad Ptr)
	Dim As Double l = (1 - vecmath.dot(q->fixedNorm, globalLightDirection_))*0.5
	l *= globalLightMax_ - globalLightMin_
	l += globalLightMin_

	Dim As Vec3F col = Vec3F(1.0, 1.0, 1.0)*l 'const

	q->pV(0).c = col
	q->pV(1).c = col
	q->pV(2).c = col
	q->pV(3).c = col

	If q->useVertexNorm Then
		For i As UInteger = 0 To lights_.size() - 1
			Dim As Const Light Ptr light = lights_.getConst(i)
			light->add(q->v(0).p, q->v(0).n, @q->pV(0))
			light->add(q->v(1).p, q->v(1).n, @q->pV(1))
			light->add(q->v(2).p, q->v(2).n, @q->pV(2))
			light->add(q->v(3).p, q->v(3).n, @q->pV(3))
		Next i
	Else
		For i As UInteger = 0 To lights_.size() - 1
			Dim As Const Light Ptr light = lights_.getConst(i)	
			light->distanceAdd(q->v(0).p, @q->pV(0))
			light->distanceAdd(q->v(1).p, @q->pV(1))
			light->distanceAdd(q->v(2).p, @q->pV(2))
			light->distanceAdd(q->v(3).p, @q->pV(3))
		Next i		
	EndIf 

	vecmath.maxsat(@(q->pV(0).c))
	vecmath.maxsat(@(q->pV(1).c))
	vecmath.maxsat(@(q->pV(2).c))
	vecmath.maxsat(@(q->pV(3).c))
End Sub


Sub QuadDrawBuffer.lightQuadConst(q As Quad Ptr)
	Dim As Double l = (1 - vecmath.dot(q->fixedNorm, globalLightDirection_))*0.5
	l *= globalLightMax_ - globalLightMin_
	l += globalLightMin_

	Dim As Vec3F col = Vec3F(1.0, 1.0, 1.0)*l 'const

	q->pV(0).c = col

	If q->useVertexNorm Then
		For i As UInteger = 0 To lights_.size() - 1
			Dim As Const Light Ptr light = lights_.getConst(i)
			light->add(q->v(0).p, q->v(0).n, @q->pV(0))
		Next i
	Else
		For i As UInteger = 0 To lights_.size() - 1
			Dim As Const Light Ptr light = lights_.getConst(i)	
			light->distanceAdd(q->v(0).p, @q->pV(0))
		Next i		
	EndIf 

	vecmath.maxsat(@(q->pV(0).c))
	q->pV(1).c = q->pV(0).c
	q->pV(2).c = q->pV(0).c
	q->pV(3).c = q->pV(0).c
End Sub

Sub QuadDrawBuffer.sort()
  'Insertion sort since we expect between draw() calls that little will change
  Dim As Integer i = 1
  While i < quads_.size()
    Dim As QuadDrawElement qElement = quads_[i] 'Const
    Dim As Integer j = i - 1
    While j >= 0 AndAlso (quads_[j].q->zSort > qElement.q->zSort)
       quads_[j + 1] = quads_[j]
        j -= 1
    Wend
    quads_[j + 1] = qElement  
    i += 1
  Wend
End Sub

Static Function QuadDrawBuffer.backfaceTest(ByRef q As Const Quad) As Boolean
  Dim As Vec2F ab = Vec2F(q.pV(1).p.x - q.pV(0).p.x, q.pV(1).p.y - q.pV(0).p.y) 'Const
  Dim As Vec2F bc = Vec2F(q.pV(2).p.x - q.pV(1).p.x, q.pV(2).p.y - q.pV(1).p.y) 'Const
  Return vecmath.cross(ab, bc) < 0
End Function
