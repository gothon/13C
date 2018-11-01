#Include "ephemeralvariant.bi"

#Include "null.bi"
#Include "debuglog.bi"

Constructor EphemeralVariant(ByRef x As Const Integer)
  This.t = INTEGER_
  This.integerValue = x
End Constructor

Constructor EphemeralVariant(ByRef x As Const Single)
  This.t = SINGLE_
  This.singleValue = x
End Constructor

Constructor EphemeralVariant(ByRef x As Const String)
  This.t = STRING_
  This.stringValue = StrPtr(x)
End Constructor

Constructor EphemeralVariant(ByRef x As Const Vec2F) 
  This.t = VEC2F_
  This.vec2fXValue = x.x
  This.vec2fYValue = x.y
End Constructor

Constructor EphemeralVariant(ByRef x As Const Vec3F)
  This.t = VEC3F_
  This.vec3fValue = @x
End Constructor

Const Function EphemeralVariant.getType() As Typename
  Return t
End Function
  
Const Function EphemeralVariant.getInteger() As Integer
  DEBUG_ASSERT(t = INTEGER_)
  Return integerValue
End Function

Const Function EphemeralVariant.getSingle() As Single
  DEBUG_ASSERT(t = SINGLE_)
  Return singleValue
End Function

Const Function EphemeralVariant.getString() As Const ZString Ptr
  DEBUG_ASSERT(t = STRING_)
  Return stringValue
End Function

Const Function EphemeralVariant.getVec3F() ByRef As Const Vec3F
  DEBUG_ASSERT(t = VEC3F_)
  Return *vec3fValue
End Function

'TODO(DotStarMoney): The getter below is pretty sketchy... the hack works for now but should have an eye kept
'                    upon it.
Const Function EphemeralVariant.getVec2F() ByRef As Const Vec2F
  DEBUG_ASSERT(t = VEC2F_)
  Return *CPtr(Vec2F Ptr, @vec2fXValue)
End Function
