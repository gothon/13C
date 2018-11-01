#Ifndef VARIANT_BI
#Define VARIANT_BI

#Include "vec2f.bi"
#Include "vec3f.bi"

'An immutable variant for statically unknown types.
Type Variant
 Public:
  Declare Constructor(ByRef x As Const Integer)
  Declare Constructor(ByRef x As Const Single)
  Declare Constructor(ByRef x As Const String)
  Declare Constructor(ByRef x As Const Vec2F) 
  Declare Constructor(ByRef x As Const Vec3F)
  
  Declare Destructor()
  
  Enum Typename
   UNKNOWN_
   INTEGER_
   SINGLE_
   STRING_
   VEC2F_
   VEC3F_
  End Enum
  
  Declare Const Function getType() As Typename
  
  Declare Const Function getInteger() As Integer
  Declare Const Function getSingle() As Single
  Declare Const Function getString() As ZString Ptr
  Declare Const Function getVec2F() ByRef As Vec2F
  Declare Const Function getVec3F() ByRef As Vec3F
  
 Private:
  Const As Integer LOCAL_STRING_BUFFER_N = 16

  As Typename t 'Const
  As ZString Ptr stringValue 'Const
  Union
    As Integer integerValue 'Const
    
    As Single singleValue 'Const
    
    'This is used if the string is small enough to fit to avoid an extra allocation
    As ZString*LOCAL_STRING_BUFFER_N localStringValue 'Const
    
    Type
      As Single xValue 'Const
      As Single yValue 'Const
      As Single zValue 'Const
    End Type
  End Union
End Type

#EndIf 
