#Ifndef SIMPLETAGINDEX_BI
#Define SIMPLETAGINDEX_BI

#Include "hashmap.bi"
#Include "darray.bi"
#include "debuglog.bi"
#Include "util.bi"

#Macro DECLARE_SIMPLETAGINDEX(_TYPENAME_)
#Ifndef SIMPLETAGINDEX_##_TYPENAME_##_DECL
#Define SIMPLETAGINDEX_##_TYPENAME_##_DECL

Type SimpleTagIndex_##_TYPENAME_##_Element
  Declare Constructor()
  Declare Destructor()
  
  Declare Constructor(ByRef x As Const _TYPENAME_, id As ULongInt)
  
  As _TYPENAME_ x
  As ULongInt id
End Type

DECLARE_DARRAY(SimpleTagIndex_##_TYPENAME_##_Element)
dsm_HashMap_define(ZString, DArray_SimpleTagIndex_##_TYPENAME_##_Element)

Type SimpleTagIndex_##_TYPENAME_
 Public:
 	Declare Function add(index As String, ByRef x As Const _TYPENAME_) As ULongInt
 	
 	'For specifying the stored id that will also be returned. This is for adding elements with multiple tags, 
 	'i.e. the first overload produces a UID which is reused in subsequent add calls to include the rest of the
 	'tags.
 	Declare Function add(index As String, id As ULongInt, ByRef x As Const _TYPENAME_) As ULongInt
 	
 	'Requires the original tag with which the element was added
 	Declare Sub remove(tag As String, id As ULongInt)
 	
 	'Clears the result array
	Declare Const Sub query(predicate As String, result As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr)
	Declare Const Sub filter(predicate As String, result As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr)
	
 Private:
  As dsm.HashMap(ZString, DArray_SimpleTagIndex_##_TYPENAME_##_Element) table
End Type
#EndIf
#EndMacro

#Macro DEFINE_SIMPLETAGINDEX(_TYPENAME_)

Constructor SimpleTagIndex_##_TYPENAME_##_Element()
  'Nop
End Constructor

Destructor SimpleTagIndex_##_TYPENAME_##_Element()
  'Nop
End Destructor

Constructor SimpleTagIndex_##_TYPENAME_##_Element(ByRef x As Const _TYPENAME_, id As ULongInt)
  This.x = x
  This.id = id
End Constructor

Function SimpleTagIndex_##_TYPENAME_.add(tag As String, id As ULongInt, ByRef x As Const _TYPENAME_) As ULongInt
  Dim As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr element = table.retrieve_ptr(tag)
  If element = NULL Then
    Dim As DArray_SimpleTagIndex_##_TYPENAME_##_Element newElement
    DArray_SimpleTagIndex_##_TYPENAME_##_Element_Emplace(newElement, x, id)
    table.insert(tag, newElement)
    Return id
  EndIf
  DArray_SimpleTagIndex_##_TYPENAME_##_Element_Emplace(*element, x, id)
  Return id
End Function

Function SimpleTagIndex_##_TYPENAME_.add(tag As String, ByRef x As Const _TYPENAME_) As ULongInt
  Return add(tag, util.genUId(), x)
End Function

Sub SimpleTagIndex_##_TYPENAME_.remove(tag As String, id As ULongInt)
  Dim As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr element = table.retrieve_ptr(tag)
  DEBUG_ASSERT(element <> NULL)
  For i As Integer = 0 To element->size() - 1
    If (*element)[i].id = id Then
      Swap element->back(), (*element)[i]
      element->pop()
      Return
    EndIf
  Next i
  DEBUG_ASSERT(FALSE)
End Sub

Const Sub SimpleTagIndex_##_TYPENAME_.query( _
    predicate As String, _
    result As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr)
  result->clear()
  Dim As Const DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr element = table.retrieve_constptr(predicate)
  If element = NULL Then Return
  For i As Integer = 0 To element->size() - 1
    DArray_SimpleTagIndex_##_TYPENAME_##_Element_Emplace(*result, element->getConst(i).x, element->getConst(i).id)
  Next i
End Sub

Const Sub SimpleTagIndex_##_TYPENAME_.filter( _
    predicate As String, _
    result As DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr)
  Dim As Const DArray_SimpleTagIndex_##_TYPENAME_##_Element Ptr element = table.retrieve_constptr(predicate)
  If element = NULL Then
    result->clear()
    Return   
  EndIf
  Dim As Integer q = 0 
  While (q < result->size())
    For i As Integer = 0 To element->size() - 1
      'I'm sorry father for I have sinned.
      If element->getConst(i).id = (*result)[q].id Then GoTo nextQ
    Next i
    Swap result->back(), (*result)[q]
    result->pop()
    q -= 1

    nextQ:
    q += 1
  Wend
End Sub
#EndMacro

#EndIf
