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
  
 Private:
  Declare Sub updateView()
  Declare Const Function toCamera(ByRef vert As Const Vec3F) As Vec3F
  Declare Sub placeInternal(ByRef p_ As Const Vec3F)
  Declare Sub lookAtInternal(ByRef lookP As Const Vec3F)
 
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
