#Include "quaddrawbuffer.bi"

#Include "debuglog.bi"
#Include "vecmath.bi"
#Include "raster.bi"

Constructor QuadDrawBuffer()
  'Nop
End Constructor

Destructor QuadDrawBuffer()
  DEBUG_ASSERT(quads.size() = 0)
End Destructor

Sub QuadDrawBuffer.bind(model As QuadModelBase Ptr)
  Dim As UInteger nextIndex = quads.size()
  quads.expandBy(model->size())
  For i As Integer = 0 To model->size() - 1
    DARRAY_SET(QuadDrawElement, quads, nextIndex, Type<QuadDrawElement>(model->getQuad(i), model->id()))
    nextIndex += 1
  Next i
  model->bind()
End Sub

Sub QuadDrawBuffer.unbind(model As QuadModelBase Ptr)
  Dim As Integer curQuadIndex = 0
  While (curQuadIndex < quads.size())
    If DARRAY_AT(QuadDrawElement, quads, curQuadIndex).parentId = model->id() Then
      Swap DARRAY_AT(QuadDrawElement, quads, curQuadIndex), DARRAY_AT(QuadDrawElement, quads, quads.size() - 1)
      quads.pop()
      Continue While
    EndIf
    curQuadIndex += 1
  Wend
  model->unbind()
End Sub

Sub QuadDrawBuffer.draw(dst As Image32 Ptr)
  sort()
  For i As Integer = quads.size() - 1 To 0 Step -1
    Dim As Const Quad Ptr q = DARRAY_AT(QuadDrawElement, quads, i).q
    If backfaceTest(*q) Then Continue For
    Select Case q->mode
      Case QuadTextureMode.FLAT:
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

Sub QuadDrawBuffer.sort()
  'Insertion sort since we expect between draw() calls that little will change
  Dim As Integer i = 1
  While i < quads.size()
    Dim As QuadDrawElement qElement = DARRAY_AT(QuadDrawElement, quads, i) 'Const
    Dim As Integer j = i - 1
    While j >= 0 AndAlso DARRAY_AT(QuadDrawElement, quads, j).q->zCentroid > qElement.q->zCentroid
        DARRAY_AT(QuadDrawElement, quads, j + 1) = DARRAY_AT(QuadDrawElement, quads, j)
        j -= 1
    Wend
    DARRAY_AT(QuadDrawElement, quads, j + 1) = qElement  
    i += 1
  Wend
End Sub

Static Function QuadDrawBuffer.backfaceTest(ByRef q As Const Quad) As Boolean
  Dim As Vec2F ab = Vec2F(q.pV(1).p.x - q.pV(0).p.x, q.pV(1).p.y - q.pV(0).p.y) 'Const
  Dim As Vec2F bc = Vec2F(q.pV(2).p.x - q.pV(1).p.x, q.pV(2).p.y - q.pV(1).p.y) 'Const
  Return vecmath.cross(ab, bc) < 0
End Function
