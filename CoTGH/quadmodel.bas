#Include "quadmodel.bi"

#Include "texturecache.bi"
#Include "debuglog.bi"
#Include "image32.bi"
#Include "pixel32.bi"
#Include "raster.bi"
#Include "util.bi"
#Include "vecmath.bi"

Const As Single UV_ERROR_ADJ = 0.01

Constructor Quad( _ 
		v() As Vertex, _
		texture As Const Image32 Ptr, _
	  mode As QuadTextureMode, _
	  trimX As Boolean, _
	  trimY As Boolean, _
	  ByRef fixedNorm As Const Vec3F, _
	  useVertexNorm As Boolean, _
	  cull As Boolean)
  This.v(0) = v(0)
  This.v(1) = v(1)
  This.v(2) = v(2)
  This.v(3) = v(3)
  This.texture = texture
  This.mode = mode
  This.trimX = trimX
  This.trimY = trimY
  This.cull = cull
  This.fixedNorm = fixedNorm
  This.useVertexNorm = useVertexNorm
  This.enabled = TRUE
End Constructor

Constructor Quad()
  'Nop
End Constructor

Destructor Quad()
  'Nop
End Destructor

Constructor QuadModelBasePtr()
	''
End Constructor

Constructor QuadModelBasePtr(p As QuadModelBase Ptr)
	This.p = p
End Constructor

Destructor QuadModelBasePtr()
	''
End Destructor

Operator QuadModelBasePtr.Cast() As QuadModelBase Ptr
	Return p
End Operator

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

Function QuadModelBase.getQuad(i As Integer) As Quad Ptr
  Return @(model_[i])
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
  
  v(0).n = Vec3F(0, 0, 1)
  v(1).n = Vec3F(0, 0, 1)
  v(2).n = Vec3F(0, 0, 1)
  v(3).n = Vec3F(0, 0, 1)               
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
                
  v(0).n = Vec3F(1, 0, 0)
  v(1).n = Vec3F(1, 0, 0)
  v(2).n = Vec3F(1, 0, 0)
  v(3).n = Vec3F(1, 0, 0)
                    
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
  	Swap v(0).t, v(1).t
  	Swap v(2).t, v(3).t
  	
  	v(0).n.x = -1
  	v(1).n.x = -1
  	v(2).n.x = -1
  	v(3).n.x = -1
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
                
  v(0).n = Vec3F(0, 1, 0)
  v(1).n = Vec3F(0, 1, 0)
  v(2).n = Vec3F(0, 1, 0)
  v(3).n = Vec3F(0, 1, 0)
                                
  If flipped Then
    Swap v(0), v(1)
    Swap v(2), v(3)
    Swap v(0).t, v(3).t
  	Swap v(1).t, v(2).t
  	
  	v(0).n.y = -1
  	v(1).n.y = -1
  	v(2).n.y = -1
  	v(3).n.y = -1
  EndIf
End Sub

Constructor QuadModelTextureCube()
  This.front = 0
  This.up = 0
  This.right = 0
  This.down = 0
  This.left = 0
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

Const Function QuadModelTextureCube.v() As UInteger
	Return front Or up Or right Or down Or left
End Function 

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

Enum TransType Explicit
	SOLID = 0
	SEMI_SOLID = 1
	CLEAR = 2
End Enum

Function getTransType( _
		img As Const Image32 Ptr, _
		x0 As UInteger, _
		y0 As UInteger, _
		x1 As UInteger, _
		y1 As UInteger) As TransType
	Dim As Boolean seenTrans = FALSE
	For y As UInteger = y0 To y1 - 1
		For x As UInteger = x0 To x1 - 1
			Dim As Pixel32 col = *(img->constPixels() + (y*img->w()) + x) 'const
			If seenTrans AndAlso (col.value <> raster.TRANSPARENT_COLOR_INT) Then 
				Return TransType.SEMI_SOLID
			ElseIf (Not seenTrans) AndAlso (col.value = raster.TRANSPARENT_COLOR_INT) Then
				If (x <> x0) OrElse (y <> y0) Then Return TransType.SEMI_SOLID
				seenTrans = TRUE
			EndIf
		Next x
	Next y
	Return IIf(seenTrans, TransType.CLEAR, TransType.SOLID)
End Function

Function cubeIsSolid( _
		ByRef cube As Const QuadModelTextureCube, _
		transT() As Const TransType) As Boolean
	Return (transT(cube.front - 1) Or _
			transT(cube.up - 1) Or _
			transT(cube.right - 1) Or _
			transT(cube.down - 1) Or _
			transT(cube.left - 1)) = TransType.SOLID	
End Function

Function adjacentCubeIsSolid( _
		ByRef cube As Const QuadModelTextureCube, _
		transT() As Const TransType) As Boolean
	Return (cube.v() <> 0) AndAlso cubeIsSolid(cube, transT())
End Function

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
  
  Dim As TransType uvQuadTransType(0 To UBound(uvIndices)) = Any
  For i As UInteger = 0 To UBound(uvIndices)
  	Dim As QuadModelUVIndex uvIndex = uvIndices(i) 'const
  	uvQuadTransType(i) = getTransType( _
  			tex(uvIndex.imageIndex), _
  			uvIndex.uvStart.x, _
  			uvIndex.uvStart.y, _
  			uvIndex.uvEnd.x, _
  			uvIndex.uvEnd.y)
  Next i

  Dim As Single blockZ = 0.0f
  For z As Integer = 1 To gridDepth
    Dim As Single blockY = sideLength*gridHeight
    For y As Integer = 1 To gridHeight
      Dim As Single blockX = 0
      For x As Integer = 1 To gridWidth
        Dim As Integer centerOffset = z*zOffset + y*yOffset + x 'const
        Dim As QuadModelTextureCube texCube = grid(centerOffset) 'const
        If texCube.v() <> 0 Then
          Dim As Boolean up = adjacentCubeIsSolid(grid(centerOffset - yOffset), uvQuadTransType()) 'const
          Dim As Boolean right = adjacentCubeIsSolid(grid(centerOffset + 1), uvQuadTransType()) 'const
          Dim As Boolean down = adjacentCubeIsSolid(grid(centerOffset + yOffset), uvQuadTransType()) 'const
          Dim As Boolean left = adjacentCubeIsSolid(grid(centerOffset - 1), uvQuadTransType()) 'const
          Dim As Boolean front = adjacentCubeIsSolid(grid(centerOffset - zOffset), uvQuadTransType()) 'const
          Dim As Boolean back = adjacentCubeIsSolid(grid(centerOffset + zOffset), uvQuadTransType()) 'const
    
          Dim As Vertex v(0 To 3)
          
      	  Dim As Boolean cull = cubeIsSolid(texCube, uvQuadTransType()) 'const
					
          If (Not front) AndAlso _
          		(texCube.front <> 0) AndAlso _
          		(uvQuadTransType(texCube.front - 1) <> TransType.CLEAR) Then
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
                QuadTextureMode.TEXTURED_MOD, _
                IIf(right <> 0, TRUE, FALSE), _
                IIf(down <> 0, TRUE, FALSE), _
                Vec3F(0, 0, 1), _
                TRUE, _
                cull)
          End if

          If (Not up) AndAlso _
          		(texCube.up <> 0) AndAlso _
          		(uvQuadTransType(texCube.up - 1) <> TransType.CLEAR) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.up - 1)
            populateQuadVerticesXZ( _
                Vec3F(blockX, blockY, blockZ), _
                Vec3F(sideLength, 0.0f, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                FALSE, _
                v())
            DArray_Quad_Emplace( _
            		model_, _
            		v(), _
            		tex(curTex->imageIndex), _
            		QuadTextureMode.TEXTURED_MOD, _
            		TRUE, _
            		TRUE, _
            		Vec3F(0, 1, 0), _
            		TRUE, _
            		cull)
          EndIf
          
      		If (Not right) AndAlso _
          		(texCube.right <> 0) AndAlso _
          		(uvQuadTransType(texCube.right - 1) <> TransType.CLEAR) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.right - 1)
            populateQuadVerticesYZ( _
                Vec3F(blockX + sideLength, blockY, blockZ), _
                Vec3F(0.0f, sideLength, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                FALSE, _
                v())
            DArray_Quad_Emplace( _
            		model_, _
            		v(), _
            		tex(curTex->imageIndex), _
            		QuadTextureMode.TEXTURED_MOD, _
            		TRUE, _
            		TRUE, _
            		Vec3F(1, 0, 0), _
            		TRUE, _
            		cull)
          EndIf
          
        	If (Not down) AndAlso _
          		(texCube.down <> 0) AndAlso _
          		(uvQuadTransType(texCube.down - 1) <> TransType.CLEAR) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.down - 1)
            populateQuadVerticesXZ( _
                Vec3F(blockX, blockY - sideLength, blockZ), _
                Vec3F(sideLength, 0.0f, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                TRUE, _
                v())
            DArray_Quad_Emplace( _
            		model_, _
            	  v(), _
            	  tex(curTex->imageIndex), _
            	  QuadTextureMode.TEXTURED_MOD, _
            	  TRUE, _
            	  TRUE, _
            	  Vec3F(0, -1, 0), _
            	  TRUE, _
            	  cull)
          EndIf
          
          If (Not left) AndAlso _
          		(texCube.left <> 0) AndAlso _
          		(uvQuadTransType(texCube.left - 1) <> TransType.CLEAR) Then
            Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.left - 1)
            populateQuadVerticesYZ( _
                Vec3F(blockX, blockY, blockZ), _
                Vec3F(0.0f, sideLength, sideLength), _
                curTex->uvStart, _
                curTex->uvEnd, _
                TRUE, _
                v())
            DArray_Quad_Emplace( _
            		model_, _
            		v(), _
            		tex(curTex->imageIndex), _
            		QuadTextureMode.TEXTURED_MOD, _
            		TRUE, _
            		TRUE, _
            		Vec3F(-1, 0, 0), _
            		TRUE, _
            		cull)
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
    tex() As Const Image32 Ptr)
  construct()    
        
  Dim As Vertex v(0 To 3)

  If texCube.front <> 0 Then
    Dim As Const QuadModelUVIndex Ptr curTex = @uvIndices(texCube.front - 1)
    populateQuadVerticesXY( _
        Vec3F(0.0f, volumeDims.y, 0.0f), _
        Vec3F(volumeDims.x, volumeDims.y, 0.0f), _
        curTex->uvStart, _
        curTex->uvEnd, _
        v())
    DArray_Quad_Emplace( _
    		model_, _
    		v(), _
    		tex(curTex->imageIndex), _
    		QuadTextureMode.TEXTURED_MOD, _
    		FALSE, _
    		FALSE, _
    		Vec3F(0, 0, 1), _
    		IIf((texCube.up <> 0) OrElse _
    				(texCube.right <> 0) OrElse _
    				(texCube.down <> 0) OrElse _
    				(texCube.left <> 0), TRUE, FALSE))
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
    DArray_Quad_Emplace( _
    		model_, _
    		v(), _
    		tex(curTex->imageIndex), _
    		QuadTextureMode.TEXTURED_MOD, _
    		FALSE, _
    		FALSE, _
    		Vec3F(0, 1, 0), _
    		TRUE)
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
    DArray_Quad_Emplace( _
    		model_, _
    		v(), _
    		tex(curTex->imageIndex), _
    		QuadTextureMode.TEXTURED_MOD, _
    		FALSE, _
    		FALSE, _
    		Vec3F(1, 0, 0), _
    		TRUE)
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
    DArray_Quad_Emplace( _
    		model_, _
    		v(), _
    		tex(curTex->imageIndex), _
    		QuadTextureMode.TEXTURED_MOD, _
    		FALSE, _
    		FALSE, _
    		Vec3F(0, -1, 0), _
    		TRUE)
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
    DArray_Quad_Emplace( _
    		model_, _
    		v(), _
    		tex(curTex->imageIndex), _
    		QuadTextureMode.TEXTURED_MOD, _
    		FALSE, _
    		FALSE, _
    		Vec3F(-1, 0, 0), _
    		TRUE)
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

Sub QuadModel.calcZSort(q As Quad Ptr)
	q->zSort = (q->pV(0).p.z + q->pV(1).p.z + q->pV(2).p.z + q->pV(3).p.z) * 0.25
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
      
  v(0).n = Vec3F(0, 0, 1)
  v(1).n = Vec3F(0, 0, 1)
  v(2).n = Vec3F(0, 0, 1)
  v(3).n = Vec3F(0, 0, 1)
  
  DArray_Quad_Emplace(model_, v(), tex, QuadTextureMode.TEXTURED_CONST, FALSE, FALSE, Vec3F(0, 0, 1), FALSE)
End Constructor

Sub QuadSprite.project(ByRef projector As Const Projection)
  Dim As Quad Ptr q = @(model_[0])
  projector.projectBillboard(q->v(0), q->v(1), q->v(2), q->v(3), @q->pV(0), @q->pV(1), @q->pV(2), @q->pV(3))
  calcZSort(q)
End Sub

Const As Double SPRITE_ZSHIFT_EPSILON = 0.01

Sub QuadSprite.calcZSort(q As Quad Ptr)
  q->zSort = (q->pV(0).p.z + q->pV(1).p.z + q->pV(2).p.z + q->pV(3).p.z)*0.25 - SPRITE_ZSHIFT_EPSILON
End Sub