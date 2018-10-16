#Include "vertex.bi"

Constructor Vertex(ByRef p As Const Vec3F, ByRef t As Const Vec2F, c As Single)
  This.p = p
  This.t = t
  This.c = c
End Constructor

Constructor Vertex(ByRef p As Const Vec3F)
  This.p = p
  This.c = 0.0f
End Constructor
