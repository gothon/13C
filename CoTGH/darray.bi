#Ifndef DARRAY_BI
#Define DARRAY_BI

#Include "debuglog.bi"
#Include "crt.bi"
#Include "null.bi"

'A basic dynamic array
#Macro DECLARE_DARRAY(_TYPENAME_)
#Ifndef DARRAY_##_TYPENAME_##_DECL
#Define DARRAY_##_TYPENAME_##_DECL

#Define DArray_##_TYPENAME_##_Emplace(ARRAY, PARAMETERS...) _
    (ARRAY).unused = New((ARRAY).pushBytes()) _TYPENAME_(PARAMETERS)
    
Type DArray_##_TYPENAME_
 Public:
  Const As UInteger DARRAY_INIT_CAPACITY = 16  
  Declare Constructor(initCapacity As UInteger = DARRAY_INIT_CAPACITY)
  
  Declare Constructor(ByRef rhs As DArray_##_TYPENAME_)
  Declare Operator Let(ByRef rhs As DArray_##_TYPENAME_)    
  
  Declare Destructor()

  Declare Sub resize(newSize As UInteger)
  Declare Sub reserve(numElements As UInteger)  
  Declare Sub push(ByRef x As Const _TYPENAME_)
  Declare Function back() ByRef As _TYPENAME_
  Declare Const Function backConst() ByRef As Const _TYPENAME_
  
  Declare Sub pop()
  Declare Sub clear()
  
  Declare Const Function size() As UInteger
  
  'Makes other array invalid (all ops will fail), copying it in the process
  Declare Sub consume(ByRef other As DArray_##_TYPENAME_)
  
  Declare Operator[](i As Integer) ByRef As _TYPENAME_
  Declare Const Function getConst(i As Integer) ByRef As Const _TYPENAME_
  
  'Not intended to be use directly, use DArray_TYPENAME_Emplace instead.
  Declare Function pushBytes() As _TYPENAME_ Ptr 
  
  'Unused: for assignment following emplace.
  As Any Ptr unused = Any
 Private:
  Declare Sub destruct()
  Declare Sub maybeIncreaseCapacity()
 
  As UInteger size_ = Any
  As UInteger capacity = Any
  As _TYPENAME_ Ptr elements = Any
End Type
#EndIf
#EndMacro

#Macro DEFINE_DARRAY(_TYPENAME_)
Constructor DArray_##_TYPENAME_(initCapacity As UInteger)
  DEBUG_ASSERT(initCapacity > 0)
  This.elements = Allocate(initCapacity*SizeOf(_TYPENAME_))
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ = 0
  This.capacity = initCapacity
End Constructor

Constructor DArray_##_TYPENAME_(ByRef rhs As DArray_##_TYPENAME_)
  This.elements = Allocate(rhs.capacity*SizeOf(_TYPENAME_))
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ = rhs.size_
  This.capacity = rhs.capacity
  memcpy(This.elements, rhs.elements, rhs.size_*SizeOf(_TYPENAME_))
End Constructor

Operator DArray_##_TYPENAME_.Let(ByRef rhs As DArray_##_TYPENAME_)
  If rhs.capacity > capacity AndAlso elements <> NULL Then
    elements = ReAllocate(elements, rhs.capacity*SizeOf(_TYPENAME_))
    DEBUG_ASSERT(This.elements <> NULL)
  ElseIf elements = NULL Then
    elements = Allocate(rhs.capacity*SizeOf(_TYPENAME_))
    DEBUG_ASSERT(This.elements <> NULL)
  End If
  size_ = rhs.size_
  capacity = rhs.capacity
  memcpy(elements, rhs.elements, rhs.size_*SizeOf(_TYPENAME_))
End Operator

Sub DArray_##_TYPENAME_.destruct()
  For i As Integer = 0 To size_ - 1
    elements[i].Destructor() 
  Next i
  DeAllocate(elements)
  elements = NULL
End Sub

Destructor DArray_##_TYPENAME_()
  If elements = NULL Then Return
  'destruct()
End Destructor

Sub DArray_##_TYPENAME_.resize(newSize As UInteger)
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(newSize >= 0)
  Dim As UInteger oldSize = size_
  size_ = newSize
  If newSize > oldSize Then
    maybeIncreaseCapacity()
    For i As Integer = oldSize To size_ - 1
      Dim As Any Ptr unused = New(@(elements[i])) _TYPENAME_()
    Next i
  ElseIf newSize < oldSize Then
    For i As Integer = newSize - 1 To oldSize Step -1
      elements[i].Destructor()
    Next i
  End if
End Sub

Sub DArray_##_TYPENAME_.reserve(numElements As UInteger) 
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(numElements > 0)
  size_ += numElements
  maybeIncreaseCapacity()
  size_ -= numElements
End Sub

Sub DArray_##_TYPENAME_.push(ByRef x As Const _TYPENAME_)
  DEBUG_ASSERT(elements <> NULL)
  size_ += 1
  maybeIncreaseCapacity()
  Dim As _TYPENAME_ Ptr newElement = New(@(elements[size_ - 1])) _TYPENAME_()
  *newElement = x
End Sub

Function DArray_##_TYPENAME_.back() ByRef As _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(size_ > 0)
  Return elements[size_ - 1]
End Function

Const Function DArray_##_TYPENAME_.backConst() ByRef As Const _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(size_ > 0)
  Return elements[size_ - 1]
End Function

Sub DArray_##_TYPENAME_.maybeIncreaseCapacity()
  If size_ > capacity Then
    Do
      capacity *= 2
    Loop While size_ > capacity
    This.elements = ReAllocate(This.elements, capacity*SizeOf(_TYPENAME_))
    DEBUG_ASSERT(This.elements <> NULL)
  EndIf
End Sub

Sub DArray_##_TYPENAME_.pop()
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(size_ > 0)
  elements[size_ - 1].Destructor()
  size_ -= 1  
End Sub

Sub DArray_##_TYPENAME_.clear()
  DEBUG_ASSERT(elements <> NULL)
  For i As Integer = 0 To size_ - 1
    elements[i].Destructor() 
  Next i
  size_ = 0
End Sub

Const Function DArray_##_TYPENAME_.size() As UInteger
  DEBUG_ASSERT(elements <> NULL)
  Return size_
End Function

Sub DArray_##_TYPENAME_.consume(ByRef other As DArray_##_TYPENAME_)
  DEBUG_ASSERT(elements <> NULL)
  This.elements = other.elements
  This.size_ = other.size_
  This.capacity = other.capacity
  
  other.elements = NULL
End Sub

Function DArray_##_TYPENAME_.pushBytes() As _TYPENAME_ Ptr 
  DEBUG_ASSERT(elements <> NULL)
  size_ += 1
  maybeIncreaseCapacity()
  Return @(elements[size_ - 1])
End Function

Operator DArray_##_TYPENAME_.[](i As Integer) ByRef As _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(i >= 0)
  DEBUG_ASSERT(i < size_)
  Return elements[i]
End Operator

Const Function DArray_##_TYPENAME_.getConst(i As Integer) ByRef As Const _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(i >= 0)
  DEBUG_ASSERT(i < size_)
  Return elements[i]
End Function
#EndMacro
#EndIf
