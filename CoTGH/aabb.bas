#Include "aabb.bi"

Constructor AABB(ByRef o As Const Vec2F = Vec2F(), ByRef s As Const Vec2F = Vec2F())
  This.o = o
  This.s = s
End Constructor
  
Const Function AABB.intersects(ByRef other As Const AABB) As Boolean
  Dim As Vec2F extent = o + s 'Const
  Dim As Vec2F otherExtent = other.o + other.s 'Const
  
  If extent.x <= other.o.x Then Return FALSE
  If extent.y <= other.o.y Then Return FALSE
  If otherExtent.x <= o.x Then Return FALSE
  If otherExtent.y <= o.y Then Return FALSE
  
  Return TRUE
End Function
