#Include "stagemanager.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../audiocontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(StageManager, ActorTypes.STAGEMANAGER)

Const As Integer MAX_POSITION_MEMORY = 30

Const As Double GRAVITY_FORCE = 250
Dim As ZString Ptr DEFAULT_MUSIC = StrPtr("res/laile_tesseract.mp3")
	
Constructor StageManager( _
		parent As ActorBankFwd Ptr, _
		mapDims As Vec2F, _
		lightDir As Vec3F, _
		lightMin As Double, _
		lightMax As Double, _
		audioFile As Const ZString Ptr)
	Base.Constructor(parent)
	setType()

	setKey("STAGEMANAGER")
	
	This.lightDir_ = lightDir
	This.lightMin_ = lightMin
	This.lightMax_ = lightMax	
	This.mapDims_ = mapDims
	This.audioFile_ = IIf(audioFile = NULL, *DEFAULT_MUSIC, *audioFile)
	This.positionReadIndex_ = 0
	AudioController.cacheMusic(audioFile_)
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
		sInterface->setForce(Vec2F(0, -GRAVITY_FORCE))
		
		AudioController.switchMusic(audioFile_)
	EndIf
	Return FALSE
End Function

Sub StageManager.updateDelayPosition(ByRef p As Const Vec2F)
	If lastPositions_.size() >= MAX_POSITION_MEMORY Then
		positionReadIndex_ = (positionReadIndex_ + 1) Mod MAX_POSITION_MEMORY
		lastPositions_[positionReadIndex_] = p
	Else 
		lastPositions_.push(p)
		positionReadIndex_ = lastPositions_.size() - 1
	EndIf
End Sub

Const Function StageManager.getDelayPosition() As Vec2F
	DEBUG_ASSERT(lastPositions_.size() > 0)
	Return lastPositions_.getConst((positionReadIndex_ + 1) Mod lastPositions_.size())
End Function

Sub StageManager.notify()
	''
End Sub
	
Function StageManager.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As StageManager Ptr stageManager_ = _
			New StageManager(parent, mapDims_, lightDir_, lightMin_, lightMax_, StrPtr(audioFile_))
	stageManager_->lastPositions_ = lastPositions_
	stageManager_->positionReadIndex_ = positionReadIndex_
	Return stageManager_
End Function

End Namespace
