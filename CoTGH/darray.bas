#Include "darray.bi"

#include "crt/string.bi"
#Include "debuglog.bi"
#Include "null.bi"

Constructor DArray(ByRef rhs As DArray)
  DEBUG_ASSERT(FALSE)
End Constructor

Constructor DArray(initCapacity As Integer, objSizeBytes As Integer)
  This.capacity = initCapacity
  This.elementSize = objSizeBytes
  This.elements = Allocate(This.capacity*This.elementSize)
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ = 0
End Constructor

Destructor DArray()
  DEBUG_ASSERT(This.elements <> NULL)
  DeAllocate(This.elements)
End Destructor
  
Sub DArray.expandBy(newObjectN As UInteger)
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ += newObjectN
  maybeIncreaseCapacity()
End Sub
  
Function DArray.getPtr(i As Integer) As Any Ptr
  DEBUG_ASSERT(This.elements <> NULL)
  Return CPtr(Byte Ptr, This.elements) + i*This.elementSize
End Function

Const Function DArray.getConstPtr(i As Integer) As Const Any Ptr
  DEBUG_ASSERT(This.elements <> NULL)
  Return CPtr(Byte Ptr, This.elements) + i*This.elementSize
End Function

Sub DArray.set(i As Integer, obj As Any Ptr)
  DEBUG_ASSERT(This.elements <> NULL)
  memcpy(getPtr(i), obj, elementSize)
End Sub

Sub DArray.push(obj As Any Ptr)
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ += 1
  maybeIncreaseCapacity()
  memcpy(getPtr(This.size - 1), obj, elementSize)
End Sub

Sub DArray.maybeIncreaseCapacity()
  DEBUG_ASSERT(This.elements <> NULL)
  While This.size > This.capacity
    This.capacity *= 2
  Wend
  This.elements = ReAllocate(This.elements, This.capacity*This.elementSize)
  DEBUG_ASSERT(This.elements <> NULL)
End Sub

Sub DArray.pop()
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ -= 1
End Sub

Const Function DArray.size() As UInteger
  DEBUG_ASSERT(This.elements <> NULL)
  Return This.size_
End Function
