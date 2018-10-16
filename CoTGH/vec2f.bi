#Ifndef VEC2F_BI
#Define VEC2F_BI

'2D vector
Type Vec2F
  'Independantly initializes the x and y components.
  Declare Constructor(x As Single = 0.0f, y As Single = 0.0f)
  
  'Makes a copy of the given vector.
  Declare Constructor(ByRef vec2f As Const Vec2F)
 
  'String form of the vector.
  Declare Const Operator Cast() As String
  
  'Return the magnitude of this vector. 
  Declare Const Function m() As Single
  
  'Multiply this vector by a scalar.
  Declare Operator *=(rhs As Single)
  
  'Point-wise multiply this vector by another.
  Declare Operator *=(ByRef rhs As Const Vec2F)
  
  'Divide this vector by a scalar.
  Declare Operator /=(rhs As Single)
  
  'Point-wise add another vector to this.
  Declare Operator +=(ByRef rhs As Const Vec2F)
  
  'Point-wise subtract another vector from this.
  Declare Operator -=(ByRef rhs As Const Vec2F)
  
  As Single x
  As Single y
End Type

'Multiply each component of rhs by lhs.
Declare Operator *(lhs As Single, ByRef rhs As Const Vec2F) As Vec2F
'Multiply each component of lhs by rhs.
Declare Operator *(ByRef lhs As Const Vec2F, rhs As Single) As Vec2F

'Divide each component of lhs by rhs.
Declare Operator /(ByRef lhs As Const Vec2F, rhs As Single) As Vec2F

'Point-wise multiply lhs and rhs.
Declare Operator *(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F

'Point-wise add lhs and rhs.
Declare Operator +(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F

'Point-wise subtract rhs from lhs.
Declare Operator -(ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Vec2F

'Invert the given vector.
Declare Operator -(ByRef v As Const Vec2F) As Vec2F

#EndIf
