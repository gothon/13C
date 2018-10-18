#Include "vertex.bi"

Constructor Vertex(ByRef p As Const Vec3F, ByRef t As Const Vec2F)
  This.p = p
  This.t = t
End Constructor

Constructor Vertex(ByRef p As Const Vec3F)
  This.p = p
End Constructor
