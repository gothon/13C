#Include "quadmodel.bi"

#Include "texturecache.bi"
#Include "debuglog.bi"
#Include "image32.bi"

Const As Single UV_ERROR_ADJ = 0.01

Constructor Quad(v() As Vertex, texture As Image32 Ptr, mode As QuadTextureMode, trimX As Boolean, trimY As Boolean)
  This.v(0) = v(0)
  This.v(1) = v(1)
  This.v(2) = v(2)
  This.v(3) = v(3)
  This.texture = texture
  This.mode = mode
  This.trimX = trimX
  This.trimY = trimY
End Constructor

Destructor QuadModelBase()
  DEBUG_ASSERT(bindings = 0)
End Destructor

Sub QuadModelBase.translate(ByRef d As Const Vec3F)
  For i As Integer = 0 To model.size() - 1
    Dim As Quad Ptr q = @DARRAY_AT(Quad, model, i)
    q->v(0).p += d
    q->v(1).p += d
    q->v(2).p += d
    q->v(3).p += d
  Next i
End Sub

Const Function QuadModelBase.id() As LongInt
  Return id_
End Function

Const Function QuadModelBase.size() As UInteger
  Return model.size()
End Function

Const Function QuadModelBase.getQuad(i As Integer) As Const Quad Ptr
  Return model.getConstPtr(i)
End Function

Sub QuadModelBase.bind()
  bindings += 1
End Sub

Sub QuadModelBase.unbind()
  DEBUG_ASSERT(bindings > 0)
  bindings -= 1
End Sub  

Sub QuadModelBase.construct()
  This.id_ = genId()
  This.bindings = 0
End Sub

Static Sub QuadModelBase.calcZCentroid(q As Quad Ptr)
  q ->pZCentroid = (q->pV(0).p.z + q->pV(1).p.z + q->pV(2).p.z + q->pV(3).p.z) / 4.0f
End Sub

Static Function QuadModelBase.genId() As LongInt
  Return CLngInt(Rnd*CDbl(CUInt(&hffffffff)))*CLngInt(Rnd*CDbl(CUInt(&hffffffff)))
End Function

Sub QuadModel.project(ByRef projector As Const Projection)
  For i As Integer = 0 To model.size() - 1
    Dim As Quad Ptr q = @DARRAY_AT(Quad, model, i)
    projector.project(q->v(0), @q->pV(0))
    projector.project(q->v(1), @q->pV(1))  
    projector.project(q->v(2), @q->pV(2))  
    projector.project(q->v(3), @q->pV(3))
    calcZCentroid(q)
  Next i
End Sub

Constructor QuadSprite(imagePath As String)
  construct()

  Dim As Image32 Ptr tex = TextureCache.get(imagePath) 'Const
 
  Dim As Integer w = tex->w() 'Const
  Dim As Integer h = tex->h() 'Const
  Dim As Integer hw = w * 0.5f 'Const
  Dim As Integer hh = h * 0.5f 'Const
  
  Dim As Vertex v(0 To 3) = { _
      Vertex(Vec3F(-hw, hh - 1, 0.0f), Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, hh - 1, 0.0f), Vec2F(w - UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, -hh, 0.0f), Vec2F(w - UV_ERROR_ADJ, h - UV_ERROR_ADJ)), _
      Vertex(Vec3F(-hw, -hh, 0.0f), Vec2F(UV_ERROR_ADJ, h - UV_ERROR_ADJ))} 'Const

  DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, FALSE, FALSE))
End Constructor

Sub QuadSprite.project(ByRef projector As Const Projection)
  Dim As Quad Ptr q = @DARRAY_AT(Quad, model, 0)
  projector.projectBillboard(q->v(0), q->v(1), q->v(2), q->v(3), @q->pV(0), @q->pV(1), @q->pV(2), @q->pV(3))
  calcZCentroid(q)
End Sub
