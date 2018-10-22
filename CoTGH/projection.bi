#Ifndef PROJECTION_BI
#Define PROJECTION_BI

#Include "vec3f.bi"
#Include "vertex.bi"

'A perspective projector.
Type Projection
 Public:
  Declare Constructor( _
      viewWidth As Integer, viewHeight As Integer, planeWidth As Single, planeHeight As Single, planeDepth As Single)
  
  'Position the eye at p
  Declare Sub place(ByRef p_ As Const Vec3F)
  
  'Move the eye by dP 
  Declare Sub translate(ByRef dP As Const Vec3F)
  
  'Point the eye at lookP
  Declare Sub lookAt(ByRef lookP As Const Vec3F)
  
  'Position the eye at p and point the eye at lookP, more efficient then separate calls to place then lookAt.
  Declare Sub placeAndLookAt(ByRef p_ As Const Vec3F, ByRef lookP As Const Vec3F)
  
  'Get the eye position
  Declare Const Function p() As Vec3F
  
  'Return a vertex whose position and texture coordinates have been projected
  Declare Const Sub project(ByRef in As Const Vertex, out As Vertex ptr)
  
  'Take 4 vertices forming a quad parallel to the XY plane and billboard project them.
  Declare Const Sub projectBillboard( _
      ByRef in0 As Const Vertex, _
      ByRef in1 As Const Vertex, _
      ByRef in2 As Const Vertex, _
      ByRef in3 As Const Vertex, _ 
      out0 As Vertex Ptr, _
      out1 As Vertex Ptr, _
      out2 As Vertex Ptr, _
      out3 As Vertex Ptr)
 Private:
  Declare Sub updateView()
  Declare Const Function toCamera(ByRef vert As Const Vec3F) As Vec3F
  Declare Sub placeInternal(ByRef p_ As Const Vec3F)
  Declare Sub lookAtInternal(ByRef lookP As Const Vec3F)
  
  Declare Const Sub perspectiveProjCoordinate(coord As Vec3F Ptr)
 
  As Single halfViewWidth 'Const
  As Single halfViewHeight 'Const
  As Single planeWMul 'Const
  As Single planeHMul 'Const
  As Single planeDepth 'Const
  
  'Eye position
  As Vec3F p_
  
  'View matrix
  As Single v(0 To 11)
End Type 

#EndIf
