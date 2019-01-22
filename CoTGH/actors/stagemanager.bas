#Include "stagemanager.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"

Namespace act
ACTOR_REQUIRED_DEF(StageManager, ActorTypes.STAGEMANAGER)
	
Constructor StageManager( _
		parent As ActorBankFwd Ptr, _
		mapDims As Vec2F, _
		lightDir As Vec3F, _
		lightMin As Double, _
		lightMax As Double)
	Base.Constructor(parent)
	setType()

	setKey("STAGEMANAGER")
	
	This.lightDir_ = lightDir
	This.lightMin_ = lightMin
	This.lightMax_ = lightMax	
	This.mapDims_ = mapDims
End Constructor

Const Function StageManager.getMapDims() ByRef As Const Vec2F
	Return mapDims_
End Function

Function StageManager.update(dt As Double) As Boolean
	If GET_GLOBAL("TRANSITION NOTIFIER", act.TransitionNotifier).happened() Then
		Dim As DrawBufferInterface Ptr dbInterface = @GET_GLOBAL("DRAWBUFFER INTERFACE", DrawBufferInterface)
		dbInterface->setGlobalLightDirection(lightDir_)
		dbInterface->setGlobalLightMinMax(lightMin_, lightMax_)		
		
		Dim As SimulationInterface Ptr sInterface = @GET_GLOBAL("SIMULATION INTERFACE", SimulationInterface)
		sInterface->setForce(Vec2F(0, -10))
	EndIf
	Return FALSE
End Function

Sub StageManager.notify()
	''
End Sub
	
Function StageManager.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New StageManager(parent, mapDims_, lightDir_, lightMin_, lightMax_)
End Function

End Namespace
