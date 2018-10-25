#Ifndef QUADMODEL_BI
#Define QUADMODEL_BI

#Include "darray.bi"
#Include "projection.bi"
#Include "vec3f.bi"
#Include "vertex.bi"
#Include "image32.bi"

'These map to raster.drawPlanarQuad_X methods
Enum QuadTextureMode Explicit
  FLAT
  TEXTURED
  TEXTURED_MOD
  TEXTURED_CONST
End Enum

Type Quad
  Declare Constructor( _
      v() As Vertex, _
      texture As Image32 Ptr, _
      mode As QuadTextureMode, _
      trimX As Boolean, _
      trimY As Boolean)
  
  As Vertex v(0 To 3)
  As Vertex pV(0 To 3)
  As Single zCentroid
  As Image32 Ptr texture 'Const
  As QuadTextureMode mode 'Const
  As Boolean trimX 'Const
  As Boolean trimY 'Const
End Type

'A model made entirely of quads.
Type QuadModelBase Extends Object
 Public:
  Declare Destructor()
 
  'Projects this model using the given projector: required to bind this to a QuadDrawBuffer
  Declare Abstract Sub project(ByRef projector As Const Projection)
 
  'Translate the model by the given vector
  Declare Sub translate(ByRef d As Const Vec3F)
 
  'Unique ID given at construction
  Declare Const Function id() As LongInt
  
  'Count of quads in this model.
  Declare Const Function size() As UInteger
  
  'Retrieve a pointer to a projected quad.
  Declare Const Function getQuad(i As Integer) As Const Quad Ptr
  
  'Reference count mutators to track if this QuadModel or its data is referenced by another object i.e. a
  'QuadDrawBuffer
  Declare Sub bind()
  Declare Sub unbind()
 Protected:
  Declare Static Sub calcZCentroid(q As Quad Ptr)
  Declare Static Function genId() As LongInt
  
  Declare Sub construct()
 
  As UInteger bindings
  
  As LongInt id_ 'Const
  
  As DArray model = DARRAY_CREATE(Quad) 'Const
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
      As UInteger Right : 6 'Const
      As UInteger down : 6 'Const
      As UInteger Left : 6 'Const
    End Type
  End Union
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
      imagePaths() As String)
  
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
