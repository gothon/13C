#Ifndef MAPUTILS_BI
#Define MAPUTILS_BI

#Include "actor.bi"
#Include "primitive.bi"
#Include "darray.bi"

Type ActorPtr As act.ActorPtr

DECLARE_DARRAY(ActorPtr)
DECLARE_DARRAY(ZStringPtr)

Namespace maputils
	
Type ParseResult
	As DArray_ZStringPtr connections
	As DArray_ActorPtr actors
End Type

Declare Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	
End Namespace

#EndIf
