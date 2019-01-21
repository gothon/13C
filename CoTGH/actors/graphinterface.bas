#Include "graphinterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../gamespace.bi"

Namespace act
ACTOR_REQUIRED_DEF(GraphInterface, ActorTypes.GRAPHINTERFACE)
	
Constructor GraphInterface(parent As ActorBankFwd Ptr, gs As GamespaceFwd Ptr)
	Base.Constructor(parent)
	setType()

	setKey("GRAPH INTERFACE")
	
	This.gs_ = gs	
	This.cloneRequested_ = FALSE
End Constructor

Function GraphInterface.cloneRequested() As Boolean
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

Sub GraphInterface.requestGo(index As ig_Index)
	DEBUG_ASSERT(goIndex_ = NULL)
	DEBUG_ASSERT(goKey_ = "")
	goIndex_ = index	
End Sub
	
Function GraphInterface.getRequestGoIndexAndClear() As ig_Index
	Dim As ig_Index tempIndex = goIndex_
	goIndex_ = NULL
	Return tempIndex
End Function
	
Function GraphInterface.embed(index As ig_Index Ptr) As UInteger
	Return CPtr(Gamespace Ptr, gs_)->embed(index)
End Function

Sub GraphInterface.unembed(ref As UInteger)
	CPtr(Gamespace Ptr, gs_)->unembed(ref)
End Sub

Function GraphInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
