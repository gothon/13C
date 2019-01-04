#Include "quadmodel.bi"

#Include "texturecache.bi"
#Include "debuglog.bi"
#Include "image32.bi"
#Include "util.bi"

Const As Single UV_ERROR_ADJ = 0.01

Constructor Quad(v() As Vertex, texture As Const Image32 Ptr, mode As QuadTextureMode, trimX As Boolean, trimY As Boolean)
  This.v(0) = v(0)
  This.v(1) = v(1)
  This.v(2) = v(2)
  This.v(3) = v(3)
  This.texture = texture
  This.mode = mode
  This.trimX = trimX
  This.trimY = trimY
  This.enabled = TRUE
End Constructor

Constructor Quad()
  'Nop
End Constructor

Destructor Quad()
  'Nop
End Destructor

Destructor QuadModelBase()
  DEBUG_ASSERT(bindings_ = 0)
End Destructor

Sub QuadModelBase.translate(ByRef d As Const Vec3F)
  For i As Integer = 0 To model_.size() - 1
    Dim As Quad Ptr q = @(model_[i])
    q->v(0).p += d
    q->v(1).p += d
    q->v(2).p += d
    q->v(3).p += d
  Next i
End Sub

Const Function QuadModelBase.id() As ULongInt
  Return id_
End Function

Const Function QuadModelBase.size() As UInteger
  Return model_.size()
End Function

Const Function QuadModelBase.getQuad(i As Integer) As Const Quad Ptr
  Return @(model_.getConst(i))
End Function

Sub QuadModelBase.bind()
  bindings_ += 1
End Sub

Sub QuadModelBase.unbind()
  DEBUG_ASSERT(bindings_ > 0)
  bindings_ -= 1
End Sub  

Sub QuadModelBase.hide()
  For i As Integer = 0 To model_.size() - 1
    model_[i].enabled = FALSE
  Next i
End Sub

Sub QuadModelBase.show()
  For i As Integer = 0 To model_.size() - 1
    model_[i].enabled = TRUE
  Next i
End Sub  

Sub QuadModelBase.construct()
  This.id_ = util.genUId()
  This.bindings_ = 0
End Sub

Static Sub QuadModelBase.calcZSort(q As Quad Ptr)
	Dim As Single minZ = q->pV(0).p.z
	If q->pV(1).p.z > minZ Then minZ = q->pV(1).p.z
	If q->pV(2).p.z > minZ Then minZ = q->pV(2).p.z
	If q->pV(3).p.z > minZ Then minZ = q->pV(3).p.z
  q->zSort = minZ
End Sub

'faces forward
Sub populateQuadVerticesXY( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvStart As Const Vec2F, _
    ByRef uvEnd As Const Vec2F, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x + size.x, start.y, start.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x + size.x, start.y - size.y, start.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y - size.y, start.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
End Sub

'If flipped = false quad faces right, o/w it faces left
Sub populateQuadVerticesYZ( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvStart As Const Vec2F, _
    ByRef uvEnd As Const Vec2F, _
    flipped As Boolean, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x, start.y, start.z - size.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x, start.y - size.y, start.z - size.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y - size.y, start.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
  	Swap v(0).t, v(1).t
  	Swap v(2).t, v(3).t
  EndIf
End Sub

'If flipped = false quad faces down, o/w it faces up
Sub populateQuadVerticesXZ( _
    ByRef start As Const Vec3F, _
    ByRef size As Const Vec3F, _
    ByRef uvStart As Const Vec2F, _
    ByRef uvEnd As Const Vec2F, _
    flipped As Boolean, _
    v() As Vertex)
  v(0) = Vertex(Vec3F(start.x, start.y, start.z - size.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(1) = Vertex(Vec3F(start.x + size.x, start.y, start.z - size.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvStart.y + UV_ERROR_ADJ))
  v(2) = Vertex(Vec3F(start.x + size.x, start.y, start.z), _
                Vec2F(uvEnd.x - UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
  v(3) = Vertex(Vec3F(start.x, start.y, start.z), _
                Vec2F(uvStart.x + UV_ERROR_ADJ, uvEnd.y - UV_ERROR_ADJ))
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
    Swap v(0).t, v(3).t
  	Swap v(1).t, v(2).t
  EndIf
End Sub

Constructor QuadModelTextureCube()
  This.v = 0
End Constructor

Constructor QuadModelTextureCube(v As UInteger)
  This.v = v
End Constructor

Constructor QuadModelTextureCube( _
    front As UInteger, _
    up As UInteger, _
    right As UInteger, _
    down As UInteger, _
    left As UInteger)
  This.front = front
  This.up = up
  This.right = right
  This.down = down
  This.left = left
End Constructor

Constructor QuadModelUVIndex()
  This.uvStart = Vec2F()
  This.uvEnd = Vec2F()
  This.imageIndex = 0
End Constructor

Constructor QuadModelUVIndex(ByRef uvStart As Const Vec2F, ByRef uvEnd As Const Vec2F, imageIndex As Integer)
  This.uvStart = uvStart
  This.uvEnd = uvEnd
  This.imageIndex = imageIndex
End Constructor

Constructor QuadModel(ByRef other As Const QuadModel)
	construct()
	This.model_ = other.model_
End Constructor

Operator QuadModel.Let(ByRef other As Const QuadModel)
	construct()
	This.model_ = other.model_
End Operator

Constructor QuadModel( _
    grid() As QuadModelTextureCube, _
    gridWidth As Integer, _
    gridHeight As Integer, _
    gridDepth As Integer, _
    sideLength As Single, _
    uvIndices() As QuadModelUVIndex, _
    tex() As Const Image32 Ptr)
  construct()
 
  Dim As Integer yOffset = gridWidth+2 'const
  Dim As Integer zOffset = (gridWidth+2)*(gridHeight+2) 'const

  Dim As Single blockZ = 0.0f
  For z As Integer = 1 To gridDepth
    Dim As Single blockY = sideLength*gridHeight
    For y As Integer = 1 To gridHeight
      Dim As Single blockX = 0
      For x As Integer = 1 To gridWidth
        Dim As Integer centerOffset = z*zOffset + y*yOffset + x 'const
        Dim As QuadModelTextureCube texCube = grid(centerOffset) 'const
        If texCube.v <> 0 Then
          Dim As Boolean up = grid(centerOffset - yOffset).v <> 0 'const
          Dim As Boolean right = grid(centerOffset + 1).v <> 0 'const
          Dim As Boolean down = grid(centerOffset + yOffset).v <> 0 'const
          Dim As Boolean left = grid(centerOffset - 1).v <> 0 'const
          Dim As Boolean front = grid(centerOffset - zOffset).v <> 0 'const
          Dim As Boolean back = grid(centerOffset + zOffset).v <> 0 'const
          
          Dim As Vertex v(0 To 3)

          If (Not front) AndAlso (texCube.front <> 0) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.front - 1)
            populateQuadVerticesXY( _
                Vec3F(blockX, blockY, blockZ), _
                Vec3F(sideLength, sideLength, 0.0f), _
                curTex->uvStart, _
                curTex->uvEnd, _
                v())
            DArray_Quad_Emplace( _
                model_, _
                v(), _
                tex(curTex->imageIndex), _
                QuadTextureMode.TEXTURED, _
                IIf(right <> 0, TRUE, FALSE), _
                IIf(down <> 0, TRUE, FALSE))
          End if

          If (Not up) AndAlso (texCube.up <> 0) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.up - 1)
            populateQuadVerticesXZ( _
                Vec3F(blockX, blockY, blockZ), _
                Vec3F(sideLength, 0.0f, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                FALSE, _
                v())
            DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, TRUE, TRUE)
          EndIf
          
          If (Not right) AndAlso (texCube.right <> 0) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.right - 1)
            populateQuadVerticesYZ( _
                Vec3F(blockX + sideLength, blockY, blockZ), _
                Vec3F(0.0f, sideLength, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                FALSE, _
                v())
            DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, TRUE, TRUE)
          EndIf
          
          If (Not down) AndAlso (texCube.down <> 0) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.down - 1)
            populateQuadVerticesXZ( _
                Vec3F(blockX, blockY - sideLength, blockZ), _
                Vec3F(sideLength, 0.0f, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                TRUE, _
                v())
            DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, TRUE, TRUE)
          EndIf
          
          If (Not left) AndAlso (texCube.left <> 0) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.left - 1)
            populateQuadVerticesYZ( _
                Vec3F(blockX, blockY, blockZ), _
                Vec3F(0.0f, sideLength, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                TRUE, _
                v())
            DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, TRUE, TRUE)
          EndIf
        End if                  
        blockX += sideLength
      Next x 
      blockY -= sideLength
    Next y
    blockZ -= sideLength
  Next z
End Constructor

Constructor QuadModel( _
    ByRef volumeDims As Const Vec3F, _
    ByRef texCube As Const QuadModelTextureCube, _
    uvIndices() As QuadModelUVIndex, _
    imagePaths() As String)
  construct()    
      
  Dim As Image32 Ptr tex(0 To UBound(imagePaths)) 'const
  For i As Integer = 0 To UBound(imagePaths)
    tex(i) = TextureCache.get(imagePaths(i))
  Next i
  
  Dim As Vertex v(0 To 3)

  If texCube.front <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.front - 1)
    populateQuadVerticesXY( _
        Vec3F(0.0f, volumeDims.y, 0.0f), _
        Vec3F(volumeDims.x, volumeDims.y, 0.0f), _
        curTex->uvStart, _
        curTex->uvEnd, _
        v())
    DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, FALSE, FALSE)
  End If
  
  If texCube.up <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.up - 1)
    populateQuadVerticesXZ( _
        Vec3F(0.0f, volumeDims.y, 0.0f), _
        Vec3F(volumeDims.x, 0.0f, volumeDims.z), _
        curTex->uvStart, _
        curTex->uvEnd, _
        FALSE, _
        v())
    DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, FALSE, FALSE)
  EndIf
  
  If texCube.right <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.right - 1)
    populateQuadVerticesYZ( _
        Vec3F(volumeDims.x, volumeDims.y, 0.0f), _
        Vec3F(0.0f, volumeDims.y, volumeDims.z), _
        curTex->uvStart, _
        curTex->uvEnd, _
        FALSE, _
        v())
    DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, FALSE, FALSE)
  EndIf
  
  If texCube.down <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.down - 1)
    populateQuadVerticesXZ( _
        Vec3F(0.0f, 0.0f, 0.0f), _
        Vec3F(volumeDims.x, 0.0f, volumeDims.z), _
        curTex->uvStart, _
        curTex->uvEnd, _
        TRUE, _
        v())
    DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, FALSE, FALSE)
  EndIf
  
  If texCube.left <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.left - 1)
    populateQuadVerticesYZ( _
        Vec3F(0.0f, volumeDims.y, 0.0f), _
        Vec3F(0.0f, volumeDims.y, volumeDims.z), _
        curTex->uvStart, _
        curTex->uvEnd, _
        TRUE, _
        v())
    DArray_Quad_Emplace(model_, v(), tex(curTex->imageIndex), QuadTextureMode.TEXTURED, FALSE, FALSE)
  EndIf
End Constructor

Sub QuadModel.project(ByRef projector As Const Projection)
  For i As Integer = 0 To model_.size() - 1
    Dim As Quad Ptr q = @(model_[i])
    projector.project(q->v(0), @q->pV(0))
    projector.project(q->v(1), @q->pV(1))  
    projector.project(q->v(2), @q->pV(2))  
    projector.project(q->v(3), @q->pV(3))
    calcZSort(q)
  Next i
End Sub

Constructor QuadSprite(ByRef other As Const QuadModel)
	construct()
	This.model_ = other.model_
End Constructor

Operator QuadSprite.Let(ByRef other As Const QuadModel)
	construct()
	This.model_ = other.model_
End Operator

Constructor QuadSprite(imagePath As String)
  construct()

  Dim As Image32 Ptr tex = TextureCache.get(imagePath) 'const
 
  Dim As Integer w = tex->w() 'const
  Dim As Integer h = tex->h() 'const
  Dim As Integer hw = w * 0.5f 'const
  Dim As Integer hh = h * 0.5f 'const
  
  Dim As Vertex v(0 To 3) = { _
      Vertex(Vec3F(-hw, hh - 1, 0.0f),    Vec2F(UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, hh - 1, 0.0f), Vec2F(w - UV_ERROR_ADJ, UV_ERROR_ADJ)), _
      Vertex(Vec3F(hw - 1, -hh, 0.0f),    Vec2F(w - UV_ERROR_ADJ, h - UV_ERROR_ADJ)), _
      Vertex(Vec3F(-hw, -hh, 0.0f),       Vec2F(UV_ERROR_ADJ, h - UV_ERROR_ADJ))} 'const

  DArray_Quad_Emplace(model_, v(), tex, QuadTextureMode.TEXTURED, FALSE, FALSE)
End Constructor

Sub QuadSprite.project(ByRef projector As Const Projection)
  Dim As Quad Ptr q = @(model_[0])
  projector.projectBillboard(q->v(0), q->v(1), q->v(2), q->v(3), @q->pV(0), @q->pV(1), @q->pV(2), @q->pV(3))
  calcZSort(q)
End Sub
