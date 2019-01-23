#Ifndef QUADMODEL_BI
#Define QUADMODEL_BI

#Include "darray.bi"
#Include "projection.bi"
#Include "vec3f.bi"
#Include "vertex.bi"
#Include "image32.bi"
#Include "tileset.bi"

'These map to raster.drawPlanarQuad_X methods
Enum QuadTextureMode Explicit
  FLAT
  TEXTURED
  TEXTURED_MOD
  TEXTURED_CONST
End Enum

Type Quad
  Declare Constructor() 'For DArray
  Declare Destructor() 'For DArray
  
  Declare Constructor( _
      v() As Vertex, _
      texture As Const Image32 Ptr, _
      mode As QuadTextureMode, _
      trimX As Boolean, _
      trimY As Boolean, _
      ByRef fixedNorm As Const Vec3F, _
      useVertexNorm As Boolean, _
      cull As Boolean = TRUE)

  As Vertex v(0 To 3)
  As Vertex pV(0 To 3)
  As Single zSort = Any
  As Boolean enabled = Any
  
  As Const Image32 Ptr texture = Any 'Const
  As QuadTextureMode mode = Any 'Const
  As Boolean trimX = Any 'Const
  As Boolean trimY = Any 'Const
  As Boolean cull = Any 'Const
  
  As Boolean useVertexNorm = Any
  As Vec3F fixedNorm = Any 'Const
End Type

DECLARE_DARRAY(Quad)

Enum QuadModelBase_Delegate Explicit
	UNKNOWN,
	QUADMODEL,
	QUADSPRITE
End Enum

'A model made entirely of quads.
Type QuadModelBase Extends Object
 Public:
  Declare Destructor()
 
  'Projects this model using the given projector: required to bind this to a QuadDrawBuffer
  Declare Abstract Sub project(ByRef projector As Const Projection)
 
  'Translate the model by the given vector
  Declare Sub translate(ByRef d As Const Vec3F)
 
  'Unique ID given at construction
  Declare Const Function id() As ULongInt
  
  'Count of quads in this model.
  Declare Const Function size() As UInteger
  
  'Retrieve a pointer to a projected quad.
  Declare Function getQuad(i As Integer) As Quad Ptr
  
  'Hide/show this model. Will not be drawn by bound QuadDrawBuffers.
  Declare Sub hide()
  Declare Sub show()
  
  'Reference count mutators to track if this QuadModel or its data is referenced by another object i.e. a
  'QuadDrawBuffer
  Declare Sub bind()
  Declare Sub unbind()
  
  Declare Const Function getDelegate() As QuadModelBase_Delegate
 Protected:
  As QuadModelBase_Delegate quadModelBaseDelegate_ = QuadModelBase_Delegate.UNKNOWN
  Declare Abstract Sub setDelegate()
 
  Declare Abstract Sub calcZSort(q As Quad Ptr)
  Declare Sub construct()
 
  As UInteger bindings_ = Any
  
  As ULongInt id_ = Any 'Const
  
  As DArray_Quad model_
End Type

Declare Sub deleteQuadModelBase(x As QuadModelBase Ptr)
Declare Sub projectQuadModelBase(x As QuadModelBase Ptr, ByRef projector As Const Projection)

Type QuadModelBasePtr
	Declare Constructor() 'Nop
	Declare Constructor(p As QuadModelBase Ptr)
	
	Declare Destructor()
	Declare Operator Cast() As QuadModelBase Ptr
	
	As QuadModelBase Ptr p = Any
End Type

Type QuadModelTextureCube
  Declare Constructor()
  Declare Constructor(v As UInteger)
  Declare Constructor( _
      front As UInteger, _
      up As UInteger, _
      right As UInteger, _
      down As UInteger, _
      left As UInteger)
  Declare Const Function v() As UInteger 

  As UInteger front 'const
  As UInteger up 'const
  As UInteger right 'const
  As UInteger down 'const
  As UInteger left 'const
End Type

Type QuadModelUVIndex
  Declare Constructor()
  Declare Constructor(ByRef uvStart As Const Vec2F, ByRef uvEnd As Const Vec2F, imageIndex As Integer)
  
  As Vec2F uvStart 'Const
  As Vec2F uvEnd 'Const
  As UInteger imageIndex 'Const
End Type

Type QuadModel Extends QuadModelBase
 Public:
  Declare Sub project(ByRef projector As Const Projection) Override
  
  'Declare custom copy constructor/assignment to avoid copying binding counter
  Declare Constructor(ByRef other As Const QuadModel)
  Declare Operator Let(ByRef other As Const QuadModel)
  
  'Create a grid of 3D blocks from a 3D grid. Blocks are added where grid() <> 1. grid() is assumed to be flattened
  'row-major order and padded with zeroed texture cubes at each border. The back face of each block (cube) is not 
  'created. The created blocks are positioned such that the lower left front corner sits at (0, 0, 0).
  Declare Constructor( _
      grid() As QuadModelTextureCube, _
      gridWidth As Integer, _
      gridHeight As Integer, _
      gridDepth As Integer, _
      sideLength As Single, _
      uvIndices() As QuadModelUVIndex, _
      tilesets() As Const Tileset Ptr)
  
  'Create a 3D volume of the specified size with it's lower left front corner at the origin. The back face is
  'omitted.
  Declare Constructor( _
      ByRef volumeDims As Const Vec3F, _
      ByRef texCube As Const QuadModelTextureCube, _
      uvIndices() As QuadModelUVIndex, _
      tex() As Const Image32 Ptr)
       
 Protected:
  Declare Sub calcZSort(q As Quad Ptr) Override
  Declare Sub setDelegate() Override
  
  As Double zSortAdjust_
End Type

Type QuadSprite Extends QuadModelBase
 Public:
  Declare Sub project(ByRef projector As Const Projection) Override
  
  'Declare custom copy constructor/assignment to avoid copying binding counter
  Declare Constructor(ByRef other As Const QuadSprite)
  Declare Operator Let(ByRef other As Const QuadSprite)
  
  'Create a centered billboard sprite from the given image.
  Declare Constructor(tex As Const Image32 Ptr, w As Integer, h As Integer)
  
 Protected:
  Declare Sub calcZSort(q As Quad Ptr) Override
  Declare Sub setDelegate() Override
End Type

#EndIf
