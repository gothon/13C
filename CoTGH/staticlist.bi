#Ifndef STATICLIST_BI
#Define STATICLIST_BI

#Include "debuglog.bi"
#Include "crt.bi"
#Include "null.bi"

'An array backed doubly linked list that returns an index when adding an element.
'This index is never invalidated until the element at that index is removed. This is useful for
'index based add/lookup/remove in constant time without repeated allocations. 
#Macro DECLARE_STATICLIST(_TYPENAME_)
#Ifndef STATICLIST_##_TYPENAME_##_DECL
#Define STATICLIST_##_TYPENAME_##_DECL

#Macro StaticList_##_TYPENAME_##_Emplace(LIST, INDEX_RET, PARAMETERS...) 
  INDEX_RET = (LIST).addBytes()
  (LIST).unused = New((LIST).getBytes(INDEX_RET)) _TYPENAME_(PARAMETERS)
#EndMacro
    
Type StaticList_##_TYPENAME_##_ElementType
  As _TYPENAME_ x = Any
  As UInteger prevIndex = Any
  As UInteger nextIndex = Any
End Type
    
Type StaticList_##_TYPENAME_
 Public:
  Const As UInteger STATICLIST_INIT_CAPACITY = 16  
  Declare Constructor(initCapacity As UInteger = STATICLIST_INIT_CAPACITY)
  
  Declare Constructor(ByRef rhs As StaticList_##_TYPENAME_) 'Disallowed
  Declare Operator Let(ByRef rhs As StaticList_##_TYPENAME_) 'Disallowed
  
  Declare Destructor()
  
  Declare Sub remove(index As UInteger)
  
  'For iterating over the list; use like so:
  '
  '  Dim As UInteger index = -1 'Pass -1 into getNext to get the index of the first element.
  '  While(list.getNext(@index))
  '	   Print list.get(index)
  '	 Wend
  '
  Declare Function getNext(index As UInteger Ptr) As Boolean
  
  Declare Function get(index As UInteger) ByRef As _TYPENAME_
  Declare Const Function getConst(index As UInteger) ByRef As Const _TYPENAME_
   
  Declare Sub clear()
  
  Declare Const Function size() As UInteger
 
  'DO NOT USE, these methods are for StaticList_##_TYPENAME_##_Emplace which should be used instead. 
  Declare Function addBytes() As UInteger
  Declare Function getBytes(index As UInteger) As Any Ptr

  'Unused: for assignment following emplace.
  As Any Ptr unused = Any
 Private:
 
  'Number of elements tracked in element array
  As UInteger size_ = Any
  
  'Total amount of elements available in current allocation
  As UInteger capacity = Any
  
  'Number of elements actually holding user data, what would be expected when calling size()
  As UInteger usedSize = Any
  
  As UInteger lastValidIndex = Any
  As StaticList_##_TYPENAME_##_ElementType Ptr elements = Any
End Type
#EndIf
#EndMacro

#Macro DEFINE_STATICLIST(_TYPENAME_)

Constructor StaticList_##_TYPENAME_(initCapacity As UInteger)
  DEBUG_ASSERT(initCapacity > 0)
  This.elements = Allocate(initCapacity*SizeOf(StaticList_##_TYPENAME_##_ElementType))
  DEBUG_ASSERT(This.elements <> NULL)
  This.size_ = 0
  This.capacity = initCapacity
  This.usedSize = 0
  This.lastValidIndex = 0
End Constructor

Constructor StaticList_##_TYPENAME_(ByRef rhs As StaticList_##_TYPENAME_)
  DEBUG_ASSERT(FALSE)
End Constructor

Operator StaticList_##_TYPENAME_.Let(ByRef rhs As StaticList_##_TYPENAME_)
  DEBUG_ASSERT(FALSE)
End Operator

Destructor StaticList_##_TYPENAME_()
  If elements = NULL Then Return
  clear()
  DeAllocate(elements)
  elements = NULL
End Destructor

Const Function StaticList_##_TYPENAME_.size() As UInteger
  DEBUG_ASSERT(elements <> NULL)
  Return usedSize
End Function

Function StaticList_##_TYPENAME_.addBytes() As UInteger
  DEBUG_ASSERT(elements <> NULL)
  Dim As UInteger newElementIndex = -1
  If size_ = 0 Then
    elements[0].prevIndex = 0
    elements[0].nextIndex = 1
    
    newElementIndex = 0
    size_ = 1
  ElseIf elements[lastValidIndex].nextIndex = size_ Then
    If size_ >= capacity Then
      capacity *= 2
      elements = ReAllocate(elements, capacity*SizeOf(StaticList_##_TYPENAME_##_ElementType))
      DEBUG_ASSERT(This.elements <> NULL)
    EndIf
    elements[size_].prevIndex = lastValidIndex
    elements[size_].nextIndex = size_ + 1
    
    newElementIndex = size_
    lastValidIndex = newElementIndex
    size_ += 1
  ElseIf usedSize = 0 Then
    newElementIndex = lastValidIndex
  Else
    newElementIndex = elements[lastValidIndex].nextIndex
    lastValidIndex = newElementIndex
  EndIf
  usedSize += 1
  Return newElementIndex
End Function

Function StaticList_##_TYPENAME_.getBytes(index As UInteger) As Any Ptr
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(index < size_)
  Return @(elements[index].x)
End Function

Function StaticList_##_TYPENAME_.get(index As UInteger) ByRef As _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(index < size_)
  Return elements[index].x
End Function  
  
Const Function StaticList_##_TYPENAME_.getConst(index As UInteger) ByRef As Const _TYPENAME_
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(index < size_)
  Return elements[index].x
End Function
   
Sub StaticList_##_TYPENAME_.clear()
  DEBUG_ASSERT(elements <> NULL)
  Dim As UInteger curIndex = lastValidIndex
  While usedSize > 0
    elements[curIndex].x.Destructor()
    curIndex = elements[curIndex].prevIndex
    usedSize -= 1
  Wend
  lastValidIndex = curIndex
End Sub
  
Function StaticList_##_TYPENAME_.getNext(index As UInteger Ptr) As Boolean
	If usedSize = 0 Then Return FALSE
	If *index = -1 Then 
		*index = lastValidIndex
		Return TRUE
	EndIf

	'If we're on the first element of the list:
	If elements[*index].prevIndex = *index Then Return FALSE
	
	*index = elements[*index].prevIndex
	Return TRUE
End Function

Sub StaticList_##_TYPENAME_.remove(index As UInteger)
  DEBUG_ASSERT(elements <> NULL)
  DEBUG_ASSERT(index < size_)
  DEBUG_ASSERT(usedSize > 0)
  
  elements[index].x.Destructor()
  
  If elements[index].prevIndex <> index Then
    elements[elements[index].prevIndex].nextIndex = elements[index].nextIndex
  EndIf
  
  If index <> lastValidIndex Then
    If elements[index].prevIndex = index Then
      'If we removed the element at the start of the list, make sure the new start of the list also loops back on
      'itself.
      elements[elements[index].nextIndex].prevIndex = elements[index].nextIndex  
    Else 
      elements[elements[index].nextIndex].prevIndex = elements[index].prevIndex
    EndIf
  EndIf
    
  usedSize -= 1
  If usedSize = 0 Then Return
  
  'Isn't included in above branch in case of return
  If index <> lastValidIndex Then
    'We don't actually have to change the last valid index here
    elements[index].prevIndex = lastValidIndex
    elements[index].nextIndex = elements[lastValidIndex].nextIndex
      
    If elements[lastValidIndex].nextIndex < size_ Then
      elements[elements[lastValidIndex].nextIndex].prevIndex = index
    EndIf
    elements[lastValidIndex].nextIndex = index
  Else 
    lastValidIndex = elements[lastValidIndex].prevIndex
    elements[lastValidIndex].nextIndex = index
  End If  
End Sub

#EndMacro
#EndIf

