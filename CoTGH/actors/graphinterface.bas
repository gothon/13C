#Include "graphinterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../gamespace.bi"
#Include "../indexgraph.bi"

Namespace act
ACTOR_REQUIRED_DEF(GraphInterface, ActorTypes.GRAPHINTERFACE)
	
Constructor GraphInterface(parent As ActorBankFwd Ptr, gs As GamespaceFwd Ptr)
	Base.Constructor(parent)
	setType()

	setKey("GRAPH INTERFACE")
	
	This.gs_ = gs	
	This.cloneRequested_ = FALSE
End Constructor

Const Function GraphInterface.cloneRequested() As Boolean
	Return cloneRequested_
End Function

Sub GraphInterface.requestClone()
	DEBUG_ASSERT(Not cloneRequested_)
	DEBUG_ASSERT(requestedIndex_ = NULL)
	cloneRequested_ = TRUE
End Sub

Sub GraphInterface.setClone(index As ig_Index)
	DEBUG_ASSERT(cloneRequested_)
	requestedIndex_ = index
	cloneRequested_ = FALSE
End Sub

Function GraphInterface.getClone() As ig_Index
	DEBUG_ASSERT(requestedIndex_ <> NULL)
	Dim As ig_Index tempIndex = requestedIndex_
	requestedIndex_ = NULL
	Return tempIndex
End Function
	
Sub GraphInterface.requestGo(key As Const ZString Ptr)
	DEBUG_ASSERT(goIndex_ = NULL)
	DEBUG_ASSERT(goKey_ = "")
	DEBUG_ASSERT(*key <> "")
	goKey_ = *key
End Sub

Function GraphInterface.getRequestGoKeyAndClear() As String
	Dim As String tempKey = goKey_
	goKey_ = ""
	Return tempKey
End Function

Sub GraphInterface.requestGoIndex(index As ig_Index)
	DEBUG_ASSERT(goIndex_ = NULL)
	DEBUG_ASSERT(goKey_ = "")
	goIndex_ = index	
End Sub
	
Sub GraphInterface.requestGoBaseIndex(stage As String)	
	DEBUG_ASSERT(goIndex_ = NULL)
	DEBUG_ASSERT(goKey_ = "")
	goIndex_ = CPtr(Gamespace Ptr, gs_)->makeBaseIndex(stage)	
End Sub
	
Function GraphInterface.getRequestGoIndexAndClear() As ig_Index
	Dim As ig_Index tempIndex = goIndex_
	goIndex_ = NULL
	Return tempIndex
End Function

Sub GraphInterface.deleteIndex(index As ig_Index Ptr)
	CPtr(Gamespace Ptr, gs_)->deleteIndex(index)	
End Sub

Function GraphInterface.unembedToIndex(ref As UInteger) As ig_Index
	Return CPtr(Gamespace Ptr, gs_)->unembedToIndex(ref)	
End Function

Sub GraphInterface.embed(index As ig_Index, existingEmbed As UInteger, indexToUpdate As UInteger Ptr)
	DEBUG_ASSERT(index <> NULL)
	DEBUG_ASSERT(indexToUpdate <> NULL)
	CPtr(Gamespace Ptr, gs_)->requestEmbed(index, existingEmbed, indexToUpdate)	
End Sub

Function GraphInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
