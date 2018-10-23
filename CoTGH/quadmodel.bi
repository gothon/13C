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
  As Single pZCentroid
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

Type QuadModel Extends QuadModelBase
 Public:
  Declare Sub project(ByRef projector As Const Projection)
  
  'Create a grid of 3D blocks from a 2D grid. Blocks are added where grid() <> 1. grid() is assumed to be flattened
  'row-major order and padded with 0's at each border. The back face of each block (cube) is not created. The
  'created blocks are positioned such that the lower left front corner sits at (0, 0, 0).
  Declare Constructor(grid() As Integer, gridCols As Integer, sideLength As Single, imagePath As String)
End Type

Type QuadSprite Extends QuadModelBase
 Public:
  Declare Sub project(ByRef projector As Const Projection)
  
  'Create a centered billboard sprite from the given image path.
  Declare Constructor(imagePath As String)
End Type

#EndIf
