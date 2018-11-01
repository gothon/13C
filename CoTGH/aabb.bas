#Include "aabb.bi"

Constructor AABB(ByRef o As Const Vec2F = Vec2F(), ByRef s As Const Vec2F = Vec2F)
  This.o = o
  This.s = s
End Constructor
  
Const Function AABB.intersects(ByRef other As Const AABB) As Boolean
  Dim As Vec2F extent = o + s 'Const
  Dim As Vec2F otherExtent = other.o + other.s 'Const
  
  Return Not (extent.x <= other.o.x OrElse _
      extent.y <= other.o.y OrElse _
      otherExtent.x <= o.x OrElse _
      otherExtent.y <= o.y)
End Function
