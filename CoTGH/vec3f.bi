#Ifndef VEC3F_BI
#Define VEC3F_BI

#Include "vec2f.bi"

'3D vector
Type Vec3F
  'Independantly initializes the x, y, and z components.
  Declare Constructor(x As Single = 0.0f, y As Single = 0.0f, z As Single = 0.0f)
  
  'Initializes the x and y components using the given vector, sets z to 0.
  Declare Constructor(ByRef vec2f As Const Vec2F)
  
  'Makes a copy of the given vector.
  Declare Constructor(ByRef vec3f As Const Vec3F)
 
  'String form of the vector.
  Declare Const Operator Cast() As String
  
  'Return the magnitude of this vector. 
  Declare Const Function m() As Single
  
  'Multiply this vector by a scalar.
  Declare Operator *=(rhs As Single)
  
  'Point-wise multiply this vector by another.
  Declare Operator *=(ByRef rhs As Const Vec3F)
  
  'Divide this vector by a scalar.
  Declare Operator /=(rhs As Single)
  
  'Point-wise add another vector to this.
  Declare Operator +=(ByRef rhs As Const Vec3F)
  
  'Point-wise subtract another vector from this.
  Declare Operator -=(ByRef rhs As Const Vec3F)
  
  As Single x
  As Single y
  As Single z
End Type

'Multiply each component of rhs by lhs.
Declare Operator *(lhs As Single, ByRef rhs As Const Vec3F) As Vec3F
'Multiply each component of lhs by rhs.
Declare Operator *(ByRef lhs As Const Vec3F, rhs As Single) As Vec3F

'Divide each component of lhs by rhs.
Declare Operator /(ByRef lhs As Const Vec3F, rhs As Single) As Vec3F

'Point-wise multiply lhs and rhs.
Declare Operator *(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F

'Point-wise add lhs and rhs.
Declare Operator +(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F

'Point-wise subtract rhs from lhs.
Declare Operator -(ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F

'Invert the given vector.
Declare Operator -(ByRef v As Const Vec3F) As Vec3F

#EndIf
