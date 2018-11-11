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

Constructor QuadDrawElement(q As Const Quad Ptr, parentId As ULongInt)
  This.q = q
  This.parentId = parentId
End Constructor

Destructor QuadDrawBuffer()
  DEBUG_ASSERT(quads.size() = 0)
End Destructor

Sub QuadDrawBuffer.bind(model As QuadModelBase Ptr)
  DEBUG_ASSERT(model->size() > 0)
  Dim As UInteger nextIndex = quads.size()
  quads.reserve(model->size())
  For i As Integer = 0 To model->size() - 1
    DArray_QuadDrawElement_Emplace(quads, model->getQuad(i), model->id())
    nextIndex += 1
  Next i
  model->bind()
End Sub

Sub QuadDrawBuffer.unbind(model As QuadModelBase Ptr)
  Dim As Integer curQuadIndex = 0
  While (curQuadIndex < quads.size())
    If quads[curQuadIndex].parentId = model->id() Then
      Swap quads.back(), quads[curQuadIndex]
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
    Dim As Const Quad Ptr q = quads[i].q
    If (Not q->enabled) OrElse backfaceTest(*q) Then Continue For
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
    Dim As QuadDrawElement qElement = quads[i] 'Const
    Dim As Integer j = i - 1
    While j >= 0 AndAlso (quads[j].q->zCentroid > qElement.q->zCentroid)
       quads[j + 1] = quads[j]
        j -= 1
    Wend
    quads[j + 1] = qElement  
    i += 1
  Wend
End Sub

Static Function QuadDrawBuffer.backfaceTest(ByRef q As Const Quad) As Boolean
  Dim As Vec2F ab = Vec2F(q.pV(1).p.x - q.pV(0).p.x, q.pV(1).p.y - q.pV(0).p.y) 'Const
  Dim As Vec2F bc = Vec2F(q.pV(2).p.x - q.pV(1).p.x, q.pV(2).p.y - q.pV(1).p.y) 'Const
  Return vecmath.cross(ab, bc) < 0
End Function
