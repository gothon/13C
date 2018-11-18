#Include "byteblob.bi"

#Include "crt.bi"
#Include "debuglog.bi"
#Include "null.bi"

Constructor ByteBlob(capacity As UInteger)
  DEBUG_ASSERT(capacity > 4)
  This.bytes = Allocate(capacity)
  DEBUG_ASSERT(This.bytes <> NULL)
  This.capacity = capacity
  This.size = 0
End Constructor

Destructor ByteBlob() 
  DeAllocate(This.bytes)
End Destructor

Constructor ByteBlob(ByRef other As ByteBlob)
  DEBUG_ASSERT(FALSE)
End Constructor

Operator ByteBlob.Let(ByRef other As ByteBlob)
  DEBUG_ASSERT(FALSE)
End Operator

#Macro WRITE_INLINE(X)
  expandBy(SizeOf(X))
  *(CPtr(TypeOf(X) Ptr, @(CPtr(Byte Ptr, bytes)[size])) - 1) = (X)
#EndMacro
  
Sub ByteBlob.write(ByRef x As Const UInteger)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const Integer)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const Single)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const Double)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const Vec2F)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const Vec3F)
  WRITE_INLINE(x)
End Sub

Sub ByteBlob.write(ByRef x As Const String)
  Dim As UInteger newBytes = Len(x) + 1 'Const, includes space for Null terminator
  DEBUG_ASSERT(newBytes <= 65535)
  expandBy(newBytes + 2) 'Two extra bytes for a UShort specifiying the string length.
  memcpy(@(CPtr(Byte Ptr, bytes)[size - newBytes - 2]), StrPtr(x), newBytes)
  *(CPtr(UShort Ptr, @(CPtr(Byte Ptr, bytes)[size])) - 1) = newBytes
End Sub

Sub ByteBlob.write(x As Const Any Ptr, count As UInteger)
  expandBy(count)
  memcpy(@(CPtr(Byte Ptr, bytes)[size - count]), x, count) 
End Sub

Sub ByteBlob.expandBy(bytes As UInteger)
  size += bytes
  If size > capacity Then
    Do
      capacity *= 2
    Loop While size > capacity 
    bytes = ReAllocate(bytes, capacity)
    DEBUG_ASSERT(bytes <> NULL)
  EndIf
End Sub

#Macro READ_INLINE(X)
  DEBUG_ASSERT(SizeOf(X) <= size)
  size -= SizeOf(X)
  x = *CPtr(TypeOf(X) Ptr, @(CPtr(Byte Ptr, bytes)[size]))
#EndMacro
  
Sub ByteBlob.read(ByRef x As UInteger)
  DEBUG_ASSERT(size > SizeOf(x)
End Sub

Sub ByteBlob.read(ByRef x As Integer)
  READ_INLINE(x)
End Sub

Sub ByteBlob.read(ByRef x As Single)
  READ_INLINE(x)  
End Sub

Sub ByteBlob.read(ByRef x As Double)
  READ_INLINE(x)  
End Sub

Sub ByteBlob.read(ByRef x As Vec2F)
  READ_INLINE(x)  
End Sub

Sub ByteBlob.read(ByRef x As Vec3F)
  READ_INLINE(x)  
End Sub

Sub ByteBlob.read(ByRef x As String)
  DEBUG_ASSERT(2 <= size)
  size -= 2
  Dim As UShort sizeBytes = *CPtr(UShort Ptr, @(CPtr(Byte Ptr, bytes)[size])) 'Const
  DEBUG_ASSERT(sizeBytes <= size)
  size -= sizeBytes
  Dim As ZString Ptr stringPtr = *CPtr(ZString Ptr, @(CPtr(Byte Ptr, bytes)[size])) 'Const
  x = *stringPtr
End Sub

Sub ByteBlob.read(x As Any Ptr, count As UInteger)
  DEBUG_ASSERT(count <= size)
  size -= count
  memcpy(x, @(CPtr(Byte Ptr, bytes)[size]), count) 
End Sub
