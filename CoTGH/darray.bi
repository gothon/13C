#Ifndef DARRAY_BI
#Define DARRAY_BI

Const As UInteger DARRAY_INIT_CAPACITY = 16

#Define DARRAY_CREATE(_TYPENAME_) DArray(DARRAY_INIT_CAPACITY, SizeOf(_TYPENAME_))
#Define DARRAY_CREATE_WITH_CAPACITY(_TYPENAME_, CAPACITY) DArray(CAPACITY, SizeOf(_TYPENAME_))

#Define DARRAY_AT(_TYPENAME_, ARRAY, INDEX) (*CPtr(_TYPENAME_ Ptr, ARRAY.getPtr(INDEX)))
#Define DARRAY_SET(_TYPENAME_, ARRAY, INDEX, ELEMENT) ARRAY.set(INDEX, @ELEMENT)
#Define DARRAY_PUSH(_TYPENAME_, ARRAY, ELEMENT) ARRAY.push(@ELEMENT)

'A basic dynamic array for holding types that themselves will not allocate memory.
Type DArray
 Public:
  Declare Constructor(ByRef rhs As DArray) 'disallowed
  Declare Constructor(initCapacity As Integer, objSizeBytes As Integer)
  Declare Destructor()
  
  Declare Sub expandBy(newObjectN As UInteger)
  
  Declare Function getPtr(i As Integer) As Any Ptr
  Declare Const Function getConstPtr(i As Integer) As Const Any Ptr

  Declare Sub push(obj As Any Ptr)
  Declare Sub set(i As Integer, obj As Any Ptr)

  Declare Sub pop()
  
  Declare Const Function size() As UInteger
 Private:
  Declare Sub maybeIncreaseCapacity()
 
  As Any Ptr elements
  
  As UInteger elementSize 'Const
  As UInteger size_
  As UInteger capacity
End Type

#EndIf
