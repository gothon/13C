#Ifndef TAGINDEX_BI
#Define TAGINDEX_BI

#Include "hashmap.bi"
#Include "darray.bi"
#include "debuglog.bi"
#Include "staticlist.bi"
#Include "primitive.bi"

#Define TAGINDEX_RESULT_ARRAY(_TYPENAME_) DArray_TagIndex_##_TYPENAME_##_ResultElement

'An index of string tags to values.
'
'The contained value type must allow default construction and assignment.
#Macro DECLARE_TAGINDEX(_TYPENAME_)
#Ifndef TAGINDEX_##_TYPENAME_##_DECL
#Define TAGINDEX_##_TYPENAME_##_DECL

Type TagIndex_##_TYPENAME_##_ResultElement
  Declare Destructor()
  Declare Constructor() 'Disallowed
  Declare Constructor(ByRef x As Const _TYPENAME_, id As UInteger)
  
  As _TYPENAME_ x 'Const
  As UInteger id 'Const
End Type

'The tag map
DECLARE_DARRAY(UInteger_)
dsm_HashMap_define(ZString, DArray_UInteger_)

'The element array list
DECLARE_STATICLIST(_TYPENAME_)

'An array of results
DECLARE_DARRAY(TagIndex_##_TYPENAME_##_ResultElement)

Type TagIndex_##_TYPENAME_
 Public:
  Declare Constructor()
  Declare Constructor(ByRef rhs As TagIndex_##_TYPENAME_) 'Disallowed
  Declare Operator Let(ByRef rhs As TagIndex_##_TYPENAME_) 'Disallowed
 
 	Declare Function add(tag As String, ByRef x As Const _TYPENAME_) As UInteger
 	
 	'For specifying the stored id that will also be returned. This is for adding elements with multiple tags, 
 	'i.e. the first overload produces a UID which is reused in subsequent add calls to include the rest of the
 	'tags.
 	Declare Sub addExisting(tag As String, id As UInteger)
 	
 	Declare Sub removeTag(tag As String, id As UInteger)
 	
 	'Should only be called once all tags associated with this id have been removed.
 	Declare Sub removeElement(id As UInteger)
 	
 	'Also clears the result array.
	Declare Const Sub query(predicate As String, result As DArray_TagIndex_##_TYPENAME_##_ResultElement Ptr)
	
	Declare Const Sub filter(predicate As String, result As DArray_TagIndex_##_TYPENAME_##_ResultElement Ptr)
	
	Declare Const Function size() As UInteger
	
 Private:
  As dsm.HashMap(ZString, DArray_UInteger_) table
  As StaticList_##_TYPENAME_ elements
End Type
#EndIf
#EndMacro

#Macro DEFINE_TAGINDEX(_TYPENAME_)
Constructor TagIndex_##_TYPENAME_##_ResultElement()
  DEBUG_ASSERT(FALSE)
End Constructor

Destructor TagIndex_##_TYPENAME_##_ResultElement()
  'Nop
End Destructor

Constructor TagIndex_##_TYPENAME_##_ResultElement(ByRef x As Const _TYPENAME_, id As UInteger)
  This.x = x
  This.id = id
End Constructor

Constructor TagIndex_##_TYPENAME_()
  ''
End Constructor

Constructor TagIndex_##_TYPENAME_(ByRef rhs As TagIndex_##_TYPENAME_)
  DEBUG_ASSERT(FALSE)
End Constructor

Operator TagIndex_##_TYPENAME_.Let(ByRef rhs As TagIndex_##_TYPENAME_)
  DEBUG_ASSERT(FALSE)
End Operator
 
Function TagIndex_##_TYPENAME_.add(tag As String, ByRef x As Const _TYPENAME_) As UInteger
  Dim As UInteger elementId = Any
  StaticList_##_TYPENAME_##_Emplace(elements, elementId, x)
  Dim As DArray_UInteger_ Ptr idList = table.retrieve_ptr(tag)
  If idList = NULL Then
    Dim As DArray_UInteger_ ids
    ids.push(elementId)
    table.insert(tag, ids)
    Return elementId  
  EndIf 
  idList->push(elementId)
  Return elementId
End Function
 
Sub TagIndex_##_TYPENAME_.addExisting(tag As String, id As UInteger)
  Dim As DArray_UInteger_ Ptr idList = table.retrieve_ptr(tag)
  If idList = NULL Then
    Dim As DArray_UInteger_ ids
    ids.push(id)
    table.insert(tag, ids)
    Return
  EndIf 
  idList->push(id)
End Sub

Sub TagIndex_##_TYPENAME_.removeTag(tag As String, id As UInteger)
  Dim As DArray_UInteger_ Ptr idList = table.retrieve_ptr(tag)
  DEBUG_ASSERT(idList <> NULL)
  For i As Integer = 0 To idList->size() - 1
    If (*idList)[i] = id Then 
      Swap idList->back(), (*idList)[i]
      idList->pop()
      If idList->size() = 0 Then table.remove(tag)
      Return
    EndIf
  Next i
  DEBUG_ASSERT(FALSE)
End Sub

Sub TagIndex_##_TYPENAME_.removeElement(id As UInteger)
  elements.remove(id)
End Sub

Const Function TagIndex_##_TYPENAME_.size() As UInteger
  Return elements.size()
End Function

Const Sub TagIndex_##_TYPENAME_.query(predicate As String, result As DArray_TagIndex_##_TYPENAME_##_ResultElement Ptr)
  result->clear()
  Dim As Const DArray_UInteger_ Ptr idList = table.retrieve_constptr(predicate)
  If idList = NULL Then Return
  For i As Integer = 0 To idList->size() - 1
    DArray_TagIndex_##_TYPENAME_##_ResultElement_Emplace( _
        *result, _
        elements.getConst(idList->getConst(i)), _
        idList->getConst(i).getValue())
  Next i
End Sub

Const Sub TagIndex_##_TYPENAME_.filter(predicate As String, result As DArray_TagIndex_##_TYPENAME_##_ResultElement Ptr)
  Dim As Const DArray_UInteger_ Ptr idList = table.retrieve_constptr(predicate)
  If idList = NULL Then 
    result->clear()
    Return
  EndIf
  Dim As Integer i = 0
  While i < result->size()
    
    Dim As Boolean foundMatch = FALSE
    For q As Integer = 0 To idList->size() - 1
      If (*result)[i].id = idList->getConst(q) Then
        foundMatch = TRUE
        Exit For
      EndIf
    Next q
  
    If foundMatch Then
      i += 1
    Else
      Swap result->back(), (*result)[i]
      result->pop()
    EndIf
  Wend
End Sub
#EndMacro

#EndIf
