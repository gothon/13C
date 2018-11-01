#Ifndef EPHEMERALVARIANT_BI
#Define EPHEMERALVARIANT_BI

#Include "vec2f.bi"
#Include "vec3f.bi"

'An immutable variant for temporarily capturing variables passed into parameters whose types are not known statically.
Type EphemeralVariant
 Public:
  Declare Constructor(ByRef x As Const Integer)
  Declare Constructor(ByRef x As Const Single)
  Declare Constructor(ByRef x As Const String)
  Declare Constructor(ByRef x As Const Vec2F) 
  Declare Constructor(ByRef x As Const Vec3F)
  
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
  Declare Const Function getString() As Const ZString Ptr
  Declare Const Function getVec2F() ByRef As Const Vec2F
  Declare Const Function getVec3F() ByRef As Const Vec3F
  
 Private:
  As Typename t 'Const
  Union
    As Integer integerValue 'Const
    
    As Single singleValue 'Const
    
    As Const ZString Ptr stringValue 'Const
    
    Type
      As Single vec2fXValue 'Const
      As Single vec2fYValue 'Const
    End Type
    
    As Const Vec3F Ptr vec3fValue 'Const
  End Union
End Type

#EndIf
