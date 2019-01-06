#Ifndef VECMATH_BI
#Define VECMATH_BI

#Include "vec2f.bi"
#Include "vec3f.bi"

'Vector math utilities
Namespace vecmath

'Dot product
Declare Function dot OverLoad (ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Single
Declare Function dot OverLoad (ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Single

'Cross product
Declare Function cross OverLoad (ByRef lhs As Const Vec2F, ByRef rhs As Const Vec2F) As Single
Declare Function cross OverLoad (ByRef lhs As Const Vec3F, ByRef rhs As Const Vec3F) As Vec3F

'Normalize
Declare Sub normalize OverLoad (v As Vec2F Const Ptr)
Declare Sub normalize OverLoad (v As Vec3F Const Ptr)

'Saturate Max
Declare Sub maxsat OverLoad (v As Vec2F Const Ptr)
Declare Sub maxsat OverLoad (v As Vec3F Const Ptr)

End Namespace

#EndIf
