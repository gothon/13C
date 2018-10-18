#Include "vec3f.bi"

#Include "debuglog.bi"

Constructor Vec3F(x As Single, y As Single, z As Single)
  This.x = x
  This.y = y
  This.z = z
End Constructor

Constructor Vec3F(ByRef vec2f As Const Vec2F)
  This.x = vec2f.x
  This.y = vec2f.y
  This.z = 0.0f
End Constructor  

Constructor Vec3F(ByRef vec3f As Const Vec3F)
  This.x = vec3f.x
  This.y = vec3f.y
  This.z = vec3f.z
End Constructor  

Const Operator Vec3F.cast() As String
  Return "(" + Str(x) + ", " + Str(y) + ", " + Str(z) + ")"
End Operator

Const Function Vec3F.m() As Single
  Return Sqr(x*x + y*y + z*z)
End Function

Operator Vec3F.*=(rhs As Single)
  x *= rhs
  y *= rhs
  z *= rhs
End Operator

Operator Vec3F.*=(ByRef rhs As Const Vec3F)
  x *= rhs.x
  y *= rhs.y
  z *= rhs.z
End Operator

Operator Vec3F./=(rhs As Single)
  DEBUG_ASSERT(rhs <> 0.0f)
  x /= rhs
  y /= rhs
  z /= rhs
End Operator

Operator Vec3F.+=(ByRef rhs As Const Vec3F)
  x += rhs.x
  y += rhs.y
  z += rhs.z
End Operator

Operator Vec3F.-=(ByRef rhs As Const Vec3F)
  x -= rhs.x
  y -= rhs.y
  z -= rhs.z
End Operator

Operator *(lhs As Single, ByRef rhs As Const Vec3F) As Vec3F
  Return Vec3F(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z)
End Operator

Operator *(ByRef lhs As Const Vec3F, rhs As Single) As Vec3F
  Return Vec3F(lhs.x*rhs, lhs.y*rhs, lhs.z*rhs)
End Operator

Operator /(ByRef lhs As Const Vec3F, rhs As Single) As Vec3F
  DEBUG_ASSERT(rhs <> 0.0f)
  Return Vec3F(lhs.x/rhs, lhs.y/rhs, lhs.z/rhs)
End Operator

Operator *(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F
  Return Vec3F(lhs.x*rhs.x, lhs.y*rhs.y, lhs.z*rhs.z)
End Operator

Operator +(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F
  Return Vec3F(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
End Operator

Operator -(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F
  Return Vec3F(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
End Operator

Operator -(ByRef v As Const Vec3F) As Vec3F
  Return Vec3F(-v.x, -v.y, -v.z)
End Operator
