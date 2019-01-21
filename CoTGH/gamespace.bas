#Include "gamespace.bi"

#Include "debuglog.bi"
#Include "actorbank.bi"
#Include "cameracontroller.bi"
#Include "graphwrapper.bi"
#Include "image32.bi"

Constructor Gamespace( _
		camera As CameraController Ptr, _
		graph As GraphWrapper Ptr, _
		target As Image32 Ptr, _
		globalBank As ActorBank Ptr, _
		timeStep As Double)
	DEBUG_ASSERT(camera <> NULL)
	This.camera_ = camera
	DEBUG_ASSERT(graph <> NULL)
	This.graph_ = graph
	DEBUG_ASSERT(target <> NULL)
	This.target_ = target
	This.globalBank_ = globalBank
	If globalBank <> NULL Then This.globalBank_->bindInto(@This)
	This.timeStep_ = timeStep
End Constructor

Destructor Gamespace()
	If globalBank_ <> NULL Then globalBank_->unbindFrom(@This)
	If staticBank_ <> NULL Then staticBank_->unbindFrom(@This)
	If activeBank_ <> NULL Then activeBank_->unbindFrom(@This)	
End Destructor
	
Sub Gamespace.init(stage As Const ZString Ptr)
	'''
	'''
	'''
End Sub
	
Sub Gamespace.update(dt As Double)
	If globalBank_ <> NULL Then globalBank_->update(timeStep_)
	If staticBank_ <> NULL Then staticBank_->update(timeStep_)
	If activeBank_ <> NULL Then activeBank_->update(timeStep_)
	While ((globalBank_ <> NULL) AndAlso globalBank_->hasNotifyQueued()) _
			OrElse ((staticBank_ <> NULL) AndAlso staticBank_->hasNotifyQueued()) _
			OrElse ((activeBank_ <> NULL) AndALso activeBank_->hasNotifyQueued())
		If globalBank_ <> NULL Then globalBank_->notify()
		If staticBank_ <> NULL Then staticBank_->notify()	
		If activeBank_ <> NULL Then activeBank_->notify()
	Wend
	If globalBank_ <> NULL Then globalBank_->purge()
	If staticBank_ <> NULL Then staticBank_->purge()
	If activeBank_ <> NULL Then activeBank_->purge()
End Sub

Sub Gamespace.draw() 
	If globalBank_ <> NULL Then globalBank_->project(camera_->proj())
	If staticBank_ <> NULL Then staticBank_->project(camera_->proj())
	If activeBank_ <> NULL Then activeBank_->project(camera_->proj())
	drawBuffer_.draw(target_)
End Sub
	
Function Gamespace.getDrawBuffer() As QuadDrawBuffer Ptr
	Return @drawBuffer_
End Function

Function Gamespace.getSimulation() As Simulation Ptr
	Return @sim_	
End Function

Sub Gamespace.addGlobalActor(key As Const ZString Ptr, actor As act.Actor Ptr)
	DEBUG_ASSERT(key <> NULL)
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
	
	Dim As act.Actor Ptr Ptr actorPtrAsStored = globals_.retrieve_ptr(*keyPtr)
	DEBUG_ASSERT(actorPtrAsStored <> NULL)
	Return *actorPtrAsStored
End Function

Sub Gamespace.removeGlobalActor(key As Const ZString Ptr)
	DEBUG_ASSERT(key <> NULL)
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
