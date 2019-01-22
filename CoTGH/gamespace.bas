#Include "gamespace.bi"

#Include "debuglog.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "graphwrapper.bi"
#Include "image32.bi"
#Include "indexgraph.bi"

Constructor Gamespace( _
		camera As CameraController Ptr, _
		graph As GraphWrapper Ptr, _
		target As Image32 Ptr, _
		globalBank As ActorBank Ptr)
	DEBUG_ASSERT(camera <> NULL)
	This.camera_ = camera
	DEBUG_ASSERT(graph <> NULL)
	This.graph_ = graph
	DEBUG_ASSERT(target <> NULL)
	This.target_ = target
	This.globalBank_ = globalBank
	DEBUG_ASSERT(This.globalBank_ <> NULL)
	addSystemActors()
	This.globalBank_->bindInto(@This)	  
	transitionOccured_ = FALSE
End Constructor

Destructor Gamespace()
	If primaryIndex_ <> NULL Then ig_DeleteIndex(@primaryIndex_)
	globalBank_->unbindFrom()
	If staticBank_ <> NULL Then staticBank_->unbindFrom()
	If activeBank_ <> NULL Then 
		activeBank_->unbindFrom()
		Delete(activeBank_)
	EndIf
End Destructor

Sub Gamespace.addSystemActors()
	graphInterfaceActor_ = New act.GraphInterface(globalBank_, @This)
	globalBank_->add(graphInterfaceActor_)
	cameraInterfaceActor_ = New act.CameraInterface(globalBank_, camera_)
	globalBank_->add(cameraInterfaceActor_)
	globalBank_->add(New act.DrawBufferInterface(globalBank_, @drawBuffer_))
	globalBank_->add(New act.TransitionNotifier(globalBank_, @transitionOccured_))
	globalBank_->add(New act.SimulationInterface(globalBank_, @sim_))
End Sub
	
Sub Gamespace.init(stage As Const ZString Ptr)
	DEBUG_ASSERT(graph_->getGraph() <> NULL)
	DEBUG_ASSERT(primaryIndex_ = NULL)
	primaryIndex_ = ig_CreateIndex(graph_->getGraph(), stage)

	staticBank_ = CPtr(ActorBank Ptr, ig_GetSharedContent(primaryIndex_))
	activeBank_ = CPtr(ActorBank Ptr, ig_GetContent(primaryIndex_))->clone()

	staticBank_->bindInto(@This)
	activeBank_->bindInto(@This)
	transitionOccured_ = TRUE
End Sub
	
Sub Gamespace.update(dt As Double)
	DEBUG_ASSERT(primaryIndex_ <> NULL)
	
	Dim As Boolean continueUpdate = Any
	Do 
		continueUpdate = FALSE
		sim_.update(dt)
		
		globalBank_->update(dt)
		staticBank_->update(dt)
		activeBank_->update(dt)
		While globalBank_->hasNotifyQueued() OrElse staticBank_->hasNotifyQueued() OrElse activeBank_->hasNotifyQueued()
			globalBank_->notify()
			staticBank_->notify()	
			activeBank_->notify()
		Wend
		globalBank_->purge()
		staticBank_->purge()
		activeBank_->purge()
		
		cameraInterfaceActor_->update(dt)
		
		If graphInterfaceActor_->cloneRequested() Then graphInterfaceActor_->setClone(clone())
		
		Dim As String goKey = graphInterfaceActor_->getRequestGoKeyAndClear()
		Dim As ig_Index goIndex = graphInterfaceActor_->getRequestGoIndexAndClear()
		If goKey <> "" Then
			go(StrPtr(goKey))
			transitionOccured_ = TRUE
			continueUpdate = TRUE
		ElseIf goIndex <> NULL Then
			go(@goIndex)
			transitionOccured_ = TRUE
			continueUpdate = TRUE
		Else 
			transitionOccured_ = FALSE
		EndIf 
	Loop While continueUpdate
End Sub

Sub Gamespace.draw() 
	DEBUG_ASSERT(primaryIndex_ <> NULL)
	globalBank_->project(camera_->proj())
	staticBank_->project(camera_->proj())
	activeBank_->project(camera_->proj())
	drawBuffer_.draw(target_)
End Sub
	
Function Gamespace.getDrawBuffer() As QuadDrawBuffer Ptr
	Return @drawBuffer_
End Function

Function Gamespace.getSimulation() As Simulation Ptr
	Return @sim_	
End Function

Sub Gamespace.go(key As Const ZString Ptr)
	ig_SetContent(primaryIndex_, activeBank_)
	activeBank_->unbindFrom()
	staticBank_->unbindFrom()
	
	ig_Go(primaryIndex_, key)
	graph_->compact()
	
	staticBank_ = CPtr(ActorBank Ptr, ig_GetSharedContent(primaryIndex_))
	activeBank_ = CPtr(ActorBank Ptr, ig_GetContent(primaryIndex_))->clone()
	
	staticBank_->bindInto(@This)
	activeBank_->bindInto(@This)
End Sub

Sub Gamespace.go(index As ig_Index Ptr)
	activeBank_->unbindFrom()
	staticBank_->unbindFrom()
	
	Delete(activeBank_)
	
	ig_ConsumeIndex(primaryIndex_, index)
	graph_->compact()
	
	staticBank_ = CPtr(ActorBank Ptr, ig_GetSharedContent(primaryIndex_))
	activeBank_ = CPtr(ActorBank Ptr, ig_GetContent(primaryIndex_))->clone()
	
	staticBank_->bindInto(@This)
	activeBank_->bindInto(@This)
End Sub

Function Gamespace.embed(index As ig_Index Ptr) As UInteger
	Return ig_Embed(primaryIndex_, index)
End Function

Sub Gamespace.unembed(ref As UInteger)
	ig_Unembed(primaryIndex_, ref)
End Sub

Function Gamespace.clone() As ig_Index
	ig_SetContent(primaryIndex_, activeBank_)
	graph_->compact()
	activeBank_ = activeBank_->clone()
	Return ig_CloneIndex(primaryIndex_)
End Function

Sub Gamespace.addGlobalActor(key As Const ZString Ptr, actor As act.Actor Ptr)
	If key = NULL Then Return
	'
	'NOTE: This is an awful hack, we're basically erasing the const'ness of the const char*	-_-. The way to fix this
	'is to switch hashmap to use Const ZString not ZString.
	'
	Dim As String keyUcase = UCase(*CPtr(ZString Ptr, CLng(key)))
	Dim As ZString Ptr keyPtr = StrPtr(keyUCase)
	'
	
	DEBUG_ASSERT(Not globals_.exists(*keyPtr))
	globals_.insert(*keyPtr, actor)
End Sub

Function Gamespace.getGlobalActor(key As Const ZString Ptr) As act.Actor Ptr
	DEBUG_ASSERT(key <> NULL)
	'
	'NOTE: This is an awful hack, we're basically erasing the const'ness of the const char*	-_-. The way to fix this
	'is to switch hashmap to use Const ZString not ZString.
	'
	Dim As String keyUcase = UCase(*CPtr(ZString Ptr, CLng(key)))
	Dim As ZString Ptr keyPtr = StrPtr(keyUCase)
	'
	
	Dim As ActorPtr Ptr actorPtrAsStored = globals_.retrieve_ptr(*keyPtr)
	DEBUG_ASSERT(actorPtrAsStored <> NULL)
	Return *actorPtrAsStored
End Function

Sub Gamespace.removeGlobalActor(key As Const ZString Ptr)
  If key = NULL Then Return
	'
	'NOTE: This is an awful hack, we're basically erasing the const'ness of the const char*	-_-. The way to fix this
	'is to switch hashmap to use Const ZString not ZString.
	'
	Dim As String keyUcase = UCase(*CPtr(ZString Ptr, CLng(key)))
	Dim As ZString Ptr keyPtr = StrPtr(keyUCase)
	'
		
	DEBUG_ASSERT(globals_.exists(*keyPtr))
	globals_.remove(*keyPtr)
End Sub
