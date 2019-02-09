#Include "graphwrapper.bi"

#Include "primitive.bi"
#Include "util.bi"
#Include "indexgraph.bi"
#Include "maputils.bi"
#Include "actordefs.bi"
#Include "debuglog.bi"
 	
DECLARE_DARRAY(ZStringPtr)
 	
Constructor GraphWrapper(entryMap As Const ZString Ptr)
	Dim As ig_GraphBuilder builder = ig_CreateGraphBuilder()
	Dim As DArray_ZStringPtr stages
	
	Dim As String entryMapUpperCase = UCase(*entryMap)
	stages.push(util.cloneZString(StrPtr(entryMapUpperCase)))
	While stages.size() > 0
 		DEBUG_LOG("Loading " + *(stages.back().getValue()))
		Dim As maputils.ParseResult res = maputils.parseMap(stages.back())
		addActorsToBuilder(builder, stages.back(), res.bank)
		
		DeAllocate(stages.back())
		stages.pop()
		For i As Integer = 0 To res.connections.size() - 1
			Dim As String relativeConnection = _
					util.pathRelativeToAbsolute(entryMapUpperCase, UCase(*(res.connections[i].getValue())))
			
			If ig_BuilderKeyExists(builder, StrPtr(relativeConnection)) = 0 Then
				Dim As Boolean duplicatedInList = FALSE
				If stages.size() <> 0 Then					
					For q As Integer = 0 To stages.size() - 1
						If relativeConnection = *(stages[q].getValue()) Then
							duplicatedInList = TRUE
							Exit For
						EndIf
					Next q
				End If
						
				If Not duplicatedInList Then stages.push(util.cloneZString(StrPtr(relativeConnection)))
			EndIf
			
			DeAllocate(res.connections[i])
		Next i
	Wend
	This.indexGraph_ = ig_Build(@builder)
	ig_ClearCompactedList()
End Constructor

Sub GraphWrapper.compact()
	Dim As ActorBank Ptr Ptr list = ig_GetCompactedList()
	For i As Integer = 0 To ig_GetCompactedListN() - 1
		Delete(list[i])
	Next i
	Delete(list)
	ig_ClearCompactedList()
End Sub

Destructor GraphWrapper()
	DEBUG_LOG("Graph reports " + Str(ig_GetCompactedListN()) + " dead node(s).")
	ig_DeleteGraph(@indexGraph_)
	compact()
End Destructor
	
Static Sub GraphWrapper.addActorsToBuilder( _
		builder As ig_GraphBuilder, _
		stageName As Const ZString Ptr, _
		bank As ActorBank Ptr)
	Dim As ActorBank Ptr sharedBank = separateIntoSharedBank(bank)
	ig_AddBaseToBuilder(builder, stageName, sharedBank, bank)	
End Sub

Function actorIsShared(actor As act.Actor Ptr) As Boolean
	Select Case As Const actor->getType()
		Case act.ActorTypes.STATUE 
			Return FALSE
		Case act.ActorTypes.PAINTING
			Return FALSE
		Case act.ActorTypes.CHANDELIER
			Return FALSE
		Case act.ActorTypes.STAGEMANAGER
			Return FALSE
		Case Else
			Return TRUE
	End Select
End Function
	
Static Function GraphWrapper.separateIntoSharedBank(bank As ActorBank Ptr) As ActorBank Ptr
	Dim As ActorBank Ptr sharedBank = New ActorBank()
	bank->transferIf(@actorIsShared, sharedBank)
	Return sharedBank
End Function

Function GraphWrapper.getGraph() As ig_IndexGraph
	Return indexGraph_
End Function
	
	