#Include "vertex.bi"

Constructor Vertex(ByRef p As Const Vec3F, ByRef t As Const Vec2F, ByRef c As Const Vec3F, ByRef n As Const Vec3F)
  This.p = p
  This.t = t
  This.c = c
  This.n = n
End Constructor

Const Operator Vertex.cast() As String
	Return "p:" + Str(p) + "t:" + Str(t) + "c:" + Str(c) + "n:" + Str(n)
End Operator
