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
  q->pZCentroid = (q->pV(0).p.z + q->pV(1).p.z + q->pV(2).p.z + q->pV(3).p.z) / 4.0f
End Sub

Static Function QuadModelBase.genId() As LongInt
  Return CLngInt(Rnd*CDbl(CUInt(&hffffffff)))*CLngInt(Rnd*CDbl(CUInt(&hffffffff)))
End Function

'faces forward
Sub populateQuadVerticesXY( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvSize As Const Vec2F, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x + size.x, start.y, start.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x + size.x, start.y - size.y, start.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y - size.y, start.z), _
                Vec2F(UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
End Sub

'If flipped = false quad faces right, o/w it faces left
Sub populateQuadVerticesYZ( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvSize As Const Vec2F, _
    flipped As Boolean, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x, start.y, start.z + size.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x, start.y - size.y, start.z + size.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y - size.y, start.z), _
                Vec2F(UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
  EndIf
End Sub

'If flipped = false quad faces down, o/w it faces up
Sub populateQuadVerticesXZ( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvSize As Const Vec2F, _
    flipped As Boolean, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z + size.z), _
                Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x + size.x, start.y, start.z + size.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x + size.x, start.y, start.z), _
                Vec2F(uvSize.x - UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(UV_ERROR_ADJ, uvSize.y - UV_ERROR_ADJ))
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
  EndIf
End Sub

Constructor QuadModel(grid() As Integer, gridCols As Integer, sideLength As Single, imagePath As String)
  construct()
  Dim As Integer gridRows = 1 + Int(UBound(grid)/gridCols) 'Const
  
  Dim As Image32 Ptr tex = TextureCache.get(imagePath) 'Const
 
  Dim As Integer w = tex->w() 'Const
  Dim As Integer h = tex->h() 'Const

  Dim As Single blockY = sideLength*(gridRows - 1)
  For y As Integer = 1 To gridRows - 2
    Dim As Single blockX = 0
    For x As Integer = 1 To gridCols - 2
      Dim As Integer centerOffset = y*gridCols + x 'Const
      Dim As Integer center = grid(centerOffset) 'Const

      If center = 1 Then
        Dim As Integer up = grid(centerOffset - gridCols) 'Const
        Dim As Integer right = grid(centerOffset + 1) 'Const
        Dim As Integer down = grid(centerOffset + gridCols) 'Const
        Dim As Integer left = grid(centerOffset - 1) 'Const
        
        Dim As Vertex v(0 To 3)
        populateQuadVerticesXY(Vec3F(blockX, blockY, 0.0f), Vec3F(sideLength, sideLength, 0.0f), Vec2F(w, h), v())
            
        DARRAY_PUSH( _
            Quad, _
            model, _
            Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, IIf(right = 1, TRUE, FALSE), IIf(down = 1, TRUE, FALSE)))
  
        If up = 0 Then
          populateQuadVerticesXZ( _
              Vec3F(blockX, blockY, 0.0f), _
              Vec3F(sideLength, 0.0f, -sideLength), _
              Vec2F(w, h), _
              FALSE, _
              v())
          DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, TRUE, TRUE))
        EndIf
        
        If right = 0 Then
          populateQuadVerticesYZ( _
              Vec3F(blockX + sideLength, blockY, 0.0f), _
              Vec3F(0.0f, sideLength, -sideLength), _
              Vec2F(w, h), _
              FALSE, _
              v())
          DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, TRUE, TRUE))
        EndIf
        
        If down = 0 Then
          populateQuadVerticesXZ( _
              Vec3F(blockX, blockY - sideLength, 0.0f), _
              Vec3F(sideLength, 0.0f, -sideLength), _
              Vec2F(w, h), _
              TRUE, _
              v())
          DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, TRUE, TRUE))
        EndIf
        
        If left = 0 Then
          populateQuadVerticesYZ( _
              Vec3F(blockX, blockY, 0.0f), _
              Vec3F(0.0f, sideLength, -sideLength), _
              Vec2F(w, h), _
              TRUE, _
              v())
          DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, TRUE, TRUE))
        EndIf
      End if
                
      blockX += sideLength
    Next x 
    blockY -= sideLength
  Next y
End Constructor

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
      Vertex(Vec3F(-hw, hh - 1, 0.0f),    Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, hh - 1, 0.0f), Vec2F(w - UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, -hh, 0.0f),    Vec2F(w - UV_ERROR_ADJ, h - UV_ERROR_ADJ)), _
      Vertex(Vec3F(-hw, -hh, 0.0f),       Vec2F(UV_ERROR_ADJ, h - UV_ERROR_ADJ))} 'Const

  DARRAY_PUSH(Quad, model, Type<Quad>(v(), tex, QuadTextureMode.TEXTURED, FALSE, FALSE))
End Constructor

Sub QuadSprite.project(ByRef projector As Const Projection)
  Dim As Quad Ptr q = @DARRAY_AT(Quad, model, 0)
  projector.projectBillboard(q->v(0), q->v(1), q->v(2), q->v(3), @q->pV(0), @q->pV(1), @q->pV(2), @q->pV(3))
  calcZCentroid(q)
End Sub
