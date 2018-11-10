#ifndef AABBINDEX_BI
#define AABBINDEX_BI

#Include "aabb.bi"
#Include "darray.bi"

#Macro DECLARE_AABBINDEX(_TYPENAME_)
Type AABBIndex_##_TYPENAME_
 Public:
 	Declare Constructor()
 	
 	Declare Abstract Function add(ByRef index As Const AABB, ByRef x As Const _TYPENAME_) As ULongInt
 	Declare Abstract Sub remove(id As ULongInt)
 	
 	'Adds elements intersecting predicate to the result.
	Declare Abstract Sub query(ByRef predicate As Const AABB, result As DArray Ptr)
	
	'Removes elements in the result that don't match the predicate. May reorder the result array.
	Declare Abstract Sub filter(ByRef predicate As Const AABB, result As DArray Ptr)
	
 	
	
End Type
#EndMacro

#EndIf
