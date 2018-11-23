#Ifndef BYTEBLOB_BI
#Define BYTEBLOB_BI

#Include "vec2f.bi"
#Include "vec3f.bi"

'A blob of binary data used for serialization. 
Type ByteBlob
 Public:
  Const As UInteger INITIAL_CAPACITY = 64
  Declare Constructor(capacity As UInteger = INITIAL_CAPACITY)
  Declare Destructor()
  
  Declare Constructor(ByRef other As ByteBlob) 'Disallowed
  Declare Operator Let(ByRef other As ByteBlob) 'Disallowed
  
  Declare Sub write(ByRef x As Const UInteger)
  Declare Sub write(ByRef x As Const Integer)
  Declare Sub write(ByRef x As Const Single)
  Declare Sub write(ByRef x As Const Double)
  Declare Sub write(ByRef x As Const Vec2F)
  Declare Sub write(ByRef x As Const Vec3F)
  Declare Sub write(ByRef x As Const String)
  Declare Sub write(x As Const Any Ptr, count As UInteger)
  
  
  Declare Sub read(ByRef x As UInteger)
  Declare Sub read(ByRef x As Integer)
  Declare Sub read(ByRef x As Single)
  Declare Sub read(ByRef x As Double)
  Declare Sub read(ByRef x As Vec2F)
  Declare Sub read(ByRef x As Vec3F)
  Declare Sub read(ByRef x As String)
  Declare Sub read(x As Any Ptr, count As UInteger)
  
  Declare Const Function sizeBytes() As UInteger
  Declare Const Function getBytes() As Const Any Ptr
  
 Private:
  Declare Sub expandBy(bytes As UInteger)
 
  As UInteger capacity
  As UInteger size
  As Any Ptr bytes
End Type

#EndIf
