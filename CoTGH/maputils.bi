#Ifndef MAPUTILS_BI
#Define MAPUTILS_BI

#Include "actorbank.bi"
#Include "primitive.bi"
#Include "darray.bi"

DECLARE_DARRAY(ZStringPtr)

Namespace maputils
	
Type ParseResult
	As DArray_ZStringPtr connections
	As ActorBank Ptr bank
End Type

Declare Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	
End Namespace

#EndIf
