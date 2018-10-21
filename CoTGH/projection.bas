#Include "projection.bi"

#Include "vecmath.bi"
#Include "vec2f.bi"

'Constants to make indices into the view matrix more clear.
Const As UInteger MAT_X_AXIS = 0
Const As UInteger MAT_Y_AXIS = 3
Const As UInteger MAT_Z_AXIS = 6
Const As UInteger MAT_VIEW_T = 9

Const As UInteger MAT_X = 0
Const As UInteger MAT_Y = 1
Const As UInteger MAT_Z = 2

Constructor Projection( _
    viewWidth As Integer, viewHeight As Integer, planeWidth As Single, planeHeight As Single, planeDepth As Single)
  This.halfViewWidth = CSng(viewWidth)*0.5f
  This.halfViewHeight = CSng(viewHeight)*0.5f
  
  This.planeWMul = viewWidth / planeWidth
  This.planeHMul = viewHeight / planeHeight
  This.planeDepth = planeDepth
  
  'Vector defining x axis
  This.v(MAT_X_AXIS + MAT_X) = 1.0f
  This.v(MAT_X_AXIS + MAT_Y) = 0.0f
  This.v(MAT_X_AXIS + MAT_Z) = 0.0f
 
  'Vector defining y axis
  This.v(MAT_Y_AXIS + MAT_X) = 0.0f
  This.v(MAT_Y_AXIS + MAT_Y) = 1.0f
  This.v(MAT_Y_AXIS + MAT_Z) = 0.0f
  
  'Vector defining z axis
  This.v(MAT_Z_AXIS + MAT_X) = 0.0f
  This.v(MAT_Z_AXIS + MAT_Y) = 0.0f
  This.v(MAT_Z_AXIS + MAT_Z) = 1.0f

  This.v(MAT_VIEW_T + MAT_X) = 0.0f
  This.v(MAT_VIEW_T + MAT_Y) = 0.0f
  This.v(MAT_VIEW_T + MAT_Z) = 0.0f
End Constructor

Sub Projection.place(ByRef p_ As Const Vec3F)
  placeInternal(p_)
  updateView()
End Sub
  
Sub Projection.translate(ByRef dP As Const Vec3F)
  p_ += dP
  updateView()
End Sub
  
Sub Projection.lookAt(ByRef lookP As Const Vec3F)
  lookAtInternal(lookP)
  updateView()
End Sub

Sub Projection.placeAndLookAt(ByRef p_ As Const Vec3F, ByRef lookP As Const Vec3F)
  placeInternal(p_)
  lookAtInternal(lookP)
  updateView()
End Sub

Sub Projection.updateView()
  v(MAT_VIEW_T + MAT_X) = _
      -vecmath.dot(Vec3F(v(MAT_X_AXIS + MAT_X), v(MAT_Y_AXIS + MAT_X), v(MAT_Z_AXIS + MAT_X)), p_)
  v(MAT_VIEW_T + MAT_Y) = _
      -vecmath.dot(Vec3F(v(MAT_X_AXIS + MAT_Y), v(MAT_Y_AXIS + MAT_Y), v(MAT_Z_AXIS + MAT_Y)), p_)
  v(MAT_VIEW_T + MAT_Z) = _
      -vecmath.dot(Vec3F(v(MAT_X_AXIS + MAT_Z), v(MAT_Y_AXIS + MAT_Z), v(MAT_Z_AXIS + MAT_Z)), p_)
End Sub
  
Sub Projection.placeInternal(ByRef p_ As Const Vec3F)
  This.p_ = p_
End Sub

Sub Projection.lookAtInternal(ByRef lookP As Const Vec3F)
  Static UP_VEC As Vec3F = Vec3F(0.0f, 1.0f, 0.0f)
  
  Dim As Vec3F za = p_ - lookP
  vecmath.normalize(@za)
 
  Dim As Const Vec3F xa = vecmath.cross(UP_VEC, za)
  Dim As Const Vec3F ya = vecmath.cross(za, xa)

  v(MAT_X_AXIS + MAT_X) = xa.x
  v(MAT_X_AXIS + MAT_Y) = ya.x
  v(MAT_X_AXIS + MAT_Z) = za.x
 
  v(MAT_Y_AXIS + MAT_X) = xa.y
  v(MAT_Y_AXIS + MAT_Y) = ya.y
  v(MAT_Y_AXIS + MAT_Z) = za.y
  
  v(MAT_Z_AXIS + MAT_X) = xa.z
  v(MAT_Z_AXIS + MAT_Y) = ya.z
  v(MAT_Z_AXIS + MAT_Z) = za.z
End Sub
  
Const Function Projection.p() As Vec3F
  Return p_
End Function
  
Const Sub Projection.project(ByRef in As Const Vertex, out As Vertex Ptr)
  out->p = toCamera(in.p)
  
  out->p.z = planeDepth / out->p.z

  out->p.x = out->p.x*out->p.z*planeWMul + halfViewWidth
  out->p.y = out->p.y*out->p.z*planeHMul + halfViewHeight
  
  out->t = in.t * out->p.z
End Sub

Const Function Projection.toCamera(ByRef vert As Const Vec3F) As Vec3F
  With vert
    Return Vec3f( _
        .x*v(MAT_X_AXIS + MAT_X) _
			+ .y*v(MAT_Y_AXIS + MAT_X) _
			+ .z*v(MAT_Z_AXIS + MAT_X) _
			+ v(MAT_VIEW_T + MAT_X), _
        .x*v(MAT_X_AXIS + MAT_Y) _
			+ .y*v(MAT_Y_AXIS + MAT_Y) _
			+ .z*v(MAT_Z_AXIS + MAT_Y) _
			+ v(MAT_VIEW_T + MAT_Y), _
        .x*v(MAT_X_AXIS + MAT_Z) _
			+ .y*v(MAT_Y_AXIS + MAT_Z) _
			+ .z*v(MAT_Z_AXIS + MAT_Z) _
			+ v(MAT_VIEW_T + MAT_Z))
  End With
End Function
