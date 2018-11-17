#ifndef AABBINDEX_BI
#define AABBINDEX_BI

#Include "aabb.bi"
#Include "darray.bi"
#Include "util.bi"

#Macro DECLARE_SIMPLEAABBINDEX(_TYPENAME_)
#Ifndef SIMPLEAABBINDEX_##_TYPENAME_##_DECL
#Define SIMPLEAABBINDEX_##_TYPENAME_##_DECL

Type SimpleAABBIndex_##_TYPENAME_##_Element
  Declare Constructor()
  Declare Destructor()
  
  Declare Constructor(ByRef x As Const _TYPENAME_, ByRef bounds As Const AABB, id As ULongInt)
  
  As _TYPENAME_ x
  As AABB bounds
  As ULongInt id
End Type

DECLARE_DARRAY(SimpleAABBIndex_##_TYPENAME_##_Element)

Type SimpleAABBIndex_##_TYPENAME_
 Public:
 	Declare Function add(ByRef index As Const AABB, ByRef x As Const _TYPENAME_) As ULongInt
 	Declare Function add(ByRef index As Const AABB, id As ULongInt, ByRef x As Const _TYPENAME_) As ULongInt
 	
 	Declare Sub remove(id As ULongInt)
	Declare Const Sub query(ByRef predicate As Const AABB, result As DArray_SimpleAABBIndex_##_TYPENAME_##_Element Ptr)
	Declare Const Sub filter(ByRef predicate As Const AABB, result As DArray_SimpleAABBIndex_##_TYPENAME_##_Element Ptr)
	
 Private:
  
  As DArray_SimpleAABBIndex_##_TYPENAME_##_Element elements
End Type
#EndIf
#EndMacro

#Macro DEFINE_SIMPLEAABBINDEX(_TYPENAME_)

Constructor SimpleAABBIndex_##_TYPENAME_##_Element()
  'Nop
End Constructor

Destructor SimpleAABBIndex_##_TYPENAME_##_Element()
  'Nop
End Destructor

Constructor SimpleAABBIndex_##_TYPENAME_##_Element(ByRef x As Const _TYPENAME_, ByRef bounds As Const AABB, id As ULongInt)
  This.x = x
  This.bounds = bounds
  This.id = id
End Constructor

Function SimpleAABBIndex_##_TYPENAME_.add(ByRef index As Const AABB, ByRef x As Const _TYPENAME_) As ULongInt
  Return add(index, util.genUId(), x)
End Function

Function SimpleAABBIndex_##_TYPENAME_.add(ByRef index As Const AABB, id As ULongInt, ByRef x As Const _TYPENAME_) As ULongInt
  DArray_SimpleAABBIndex_##_TYPENAME_##_Element_Emplace(elements, x, index, uid)
  Return id
End Function

Sub SimpleAABBIndex_##_TYPENAME_.remove(id As ULongInt)
  For i As Integer = 0 To elements.size() - 1
    If elements[i].id = id Then
      Swap elements.back(), elements[i]
      elements.pop()
      Return
    EndIf
  Next i
End Sub

Const Sub SimpleAABBIndex_##_TYPENAME_.query( _
    ByRef predicate As Const AABB, _
    result As DArray_SimpleAABBIndex_##_TYPENAME_##_Element Ptr)
  result->clear()
  For i As Integer = 0 To elements.size() - 1
    If elements.getConst(i).bounds.intersects(predicate) Then result->push(elements.getConst(i))
  Next i
End Sub

Const Sub SimpleAABBIndex_##_TYPENAME_.filter( _
    ByRef predicate As Const AABB, _
    result As DArray_SimpleAABBIndex_##_TYPENAME_##_Element Ptr)
  Dim As Integer i = 0
  While (i < result->size()) 
    If Not (*result)[i].bounds.intersects(predicate) Then
      Swap result->back(), (*result)[i]
      result->pop()
    Else 
      i += 1
    EndIf 
  Wend
End Sub

#EndMacro

#EndIf
