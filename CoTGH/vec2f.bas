#Include "vec2f.bi"

#Include "debuglog.bi"

Constructor Vec2F(x As Single, y As Single)
  This.x = x
  This.y = y
End Constructor

Constructor Vec2F(ByRef vec2f As Const Vec2F)
  This.x = vec2f.x
  This.y = vec2f.y
End Constructor  

Const Operator Vec2F.cast() As String
  Return "(" + Str(x) + ", " + Str(y) + ")"
End Operator

Const Function Vec2F.m() As Single
  Return Sqr(x*x + y*y)
End Function

Operator Vec2F.*=(rhs As Single)
  x *= rhs
  y *= rhs
End Operator

Operator Vec2F.*=(ByRef rhs As Const Vec2F)
  x *= rhs.x
  y *= rhs.y
End Operator

Operator Vec2F./=(rhs As Single)
  DEBUG_ASSERT(rhs <> 0.0f)
  x /= rhs
  y /= rhs
End Operator

Operator Vec2F.+=(ByRef rhs As Const Vec2F)
  x += rhs.x
  y += rhs.y
End Operator

Operator Vec2F.-=(ByRef rhs As Const Vec2F)
  x -= rhs.x
  y -= rhs.y
End Operator

Operator *(lhs As Single, ByRef rhs As Const Vec2F) As Vec2F
  Return Vec2F(lhs*rhs.x, lhs*rhs.y)
End Operator

Operator *(ByRef lhs As Const Vec2F, rhs As Single) As Vec2F
  Return Vec2F(lhs.x*rhs, lhs.y*rhs)
End Operator

Operator /(ByRef lhs As Const Vec2F, rhs As Single) As Vec2F
  DEBUG_ASSERT(rhs <> 0.0f)
  Return Vec2F(lhs.x/rhs, lhs.y/rhs)
End Operator

Operator *(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F
  Return Vec2F(lhs.x*rhs.x, lhs.y*rhs.y)
End Operator

Operator +(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F
  Return Vec2F(lhs.x + rhs.x, lhs.y + rhs.y)
End Operator

Operator -(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F
  Return Vec2F(lhs.x - rhs.x, lhs.y - rhs.y)
End Operator

Operator -(ByRef v As Const Vec2F) As Vec2F
  Return Vec2F(-v.x, -v.y)
End Operator
