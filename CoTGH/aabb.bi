#Ifndef AABB_BI
#Define AABB_BI

#Include "vec2f.bi"

'An axis-aligned bounding box.
Type AABB
  'Requires origin and size
  Declare Constructor(ByRef o As Const Vec2F = Vec2F(), ByRef s As Const Vec2F = Vec2F)
  
  Declare Const Function intersects(ByRef other As Const AABB) As Boolean
  
  'origin
  As Vec2F o
  
  'bounding box size
  As Vec2F s 
End Type

#EndIf
