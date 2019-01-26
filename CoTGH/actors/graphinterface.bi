#Ifndef ACTOR_GRAPHINTERFACE_BI
#Define ACTOR_GRAPHINTERFACE_BI

#Include "../actor.bi"
#Include "../indexgraph.bi"

Namespace act

Type GamespaceFwd As Any
Type GraphInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(GraphInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, gs As GamespaceFwd Ptr)
	
	'--- actors should use these	
	Declare Sub requestClone()
	Declare Sub deleteIndex(index As ig_Index Ptr)
	Declare Function getClone() As ig_Index
	Declare Function unembedToIndex(ref As UInteger) As ig_Index
	Declare Sub requestGo(key As Const ZString Ptr)
	Declare Sub requestGoIndex(index As ig_Index)	
	Declare Sub embed(index As ig_Index, existingEmbed As UInteger, indexToUpdate As UInteger Ptr)
	'---

	Declare Sub setClone(index As ig_Index)
	Declare Function cloneRequested() As Boolean	
	Declare Function getRequestGoKeyAndClear() As String
	Declare Function getRequestGoIndexAndClear() As ig_Index
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As GamespaceFwd Ptr gs_ = NULL
 	As ig_Index requestedIndex_ = NULL
 	As Boolean cloneRequested_ = Any
 	
 	As ig_Index goIndex_ = NULL
 	As String goKey_
End Type

End Namespace

#EndIf