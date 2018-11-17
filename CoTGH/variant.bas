#Include "variant.bi"

#Include "null.bi"
#Include "debuglog.bi"

Constructor Variant()
  DEBUG_ASSERT(FALSE)
End Constructor

Constructor Variant(ByRef x As Const Integer)
  This.t = INTEGER_
  This.integerValue = x
  This.stringValue = NULL
End Constructor

Constructor Variant(ByRef x As Const Single)
  This.t = SINGLE_
  This.singleValue = x
  This.stringValue = NULL
End Constructor

Constructor Variant(ByRef x As Const String)
  This.t = STRING_
  'Add one for the null terminator
  If (Len(x) + 1) <= LOCAL_STRING_BUFFER_N Then
    This.localStringValue = x
    This.stringValue = NULL
    Return
  EndIf
  This.stringValue = Allocate(Len(x) + 1)
  *This.stringValue = x
End Constructor

Constructor Variant(ByRef x As Const Vec2F) 
  This.t = VEC2F_
  This.xValue = x.x
  This.yValue = x.y
  This.stringValue = NULL
End Constructor

Constructor Variant(ByRef x As Const Vec3F)
  This.t = VEC3F_
  This.xValue = x.x
  This.yValue = x.y
  This.zValue = x.z
  This.stringValue = NULL
End Constructor

Destructor Variant()
  If stringValue = NULL Then Return
  Deallocate(stringValue)
End Destructor

Const Function Variant.getType() As Typename
  Return t
End Function
  
Const Function Variant.getInteger() As Const Integer Ptr
  DEBUG_ASSERT(t = INTEGER_)
  Return @integerValue
End Function

Const Function Variant.getSingle() As Const Single Ptr
  DEBUG_ASSERT(t = SINGLE_)
  Return @singleValue
End Function

Const Function Variant.getString() As Const ZString Ptr
  DEBUG_ASSERT(t = STRING_)
  If stringValue = NULL Then
    Return StrPtr(localStringValue)
  EndIf
  Return stringValue
End Function

'TODO(DotStarMoney): The below two getters are pretty sketchy... the hack works for now but should have an eye kept
'                    upon it.
Const Function Variant.getVec2F() As Const Vec2F Ptr
  DEBUG_ASSERT(t = VEC2F_)
  Return CPtr(Vec2F Ptr, @xValue)
End Function

Const Function Variant.getVec3F() As Const Vec3F Ptr
  DEBUG_ASSERT(t = VEC3F_)
  Return CPtr(Vec3F Ptr, @xValue)  
End Function
