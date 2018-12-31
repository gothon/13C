#Ifndef QUADMODEL_BI
#Define QUADMODEL_BI

#Include "darray.bi"
#Include "projection.bi"
#Include "vec3f.bi"
#Include "vertex.bi"
#Include "image32.bi"


'make vertices index based
'register lights with quaddrawbuffer



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
      trimY As Boolean)

  As Vertex v(0 To 3)
  As Vertex pV(0 To 3)
  As Single zSort = Any
  As Boolean enabled = Any
  
  As Const Image32 Ptr texture = Any 'Const
  As QuadTextureMode mode = Any 'Const
  As Boolean trimX = Any 'Const
  As Boolean trimY = Any 'Const
End Type

DECLARE_DARRAY(Quad)

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
  Declare Const Function getQuad(i As Integer) As Const Quad Ptr
  
  'Hide/show this model. Will not be drawn by bound QuadDrawBuffers.
  Declare Sub hide()
  Declare Sub show()
  
  'Reference count mutators to track if this QuadModel or its data is referenced by another object i.e. a
  'QuadDrawBuffer
  Declare Sub bind()
  Declare Sub unbind()
 Protected:
  Declare Static Sub calcZSort(q As Quad Ptr)

  Declare Sub construct()
 
  As UInteger bindings = Any
  
  As ULongInt id_ = Any 'Const
  
  As DArray_Quad model
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

  Union
    As UInteger v 'Const
    Type
      As UInteger front : 6 'Const
      As UInteger up : 6 'Const
      As UInteger right : 6 'Const
      As UInteger down : 6 'Const
      As UInteger left : 6 'Const
    End Type
  End Union
End Type

'An empty quad model that can't be modified, used for initializing a QuadModel and assigning to it
'later.
Type QuadModelEmpty Extends QuadModelBase
  Declare Constructor()  
  
  Declare Sub project(ByRef projector As Const Projection)
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
  Declare Sub project(ByRef projector As Const Projection)
  
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
      tex() As Const Image32 Ptr)
  
  'Create a 3D volume of the specified size with it's lower left front corner at the origin. The back face is
  'omitted.
  Declare Constructor( _
      ByRef volumeDims As Const Vec3F, _
      ByRef texCube As Const QuadModelTextureCube, _
      uvIndices() As QuadModelUVIndex, _
      imagePaths() As String)
End Type

Type QuadSprite Extends QuadModelBase
 Public:
  Declare Sub project(ByRef projector As Const Projection)
  
  'Create a centered billboard sprite from the given image path.
  Declare Constructor(imagePath As String)
End Type

#EndIf
