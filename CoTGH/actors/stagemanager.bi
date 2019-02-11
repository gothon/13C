#Ifndef ACTOR_STAGEMANAGER_BI
#Define ACTOR_STAGEMANAGER_BI

#Include "../actor.bi"
#Include "../vec3f.bi"

DECLARE_DARRAY(Vec2F)

Namespace act
	
Type GamespaceFwd As Any
Type StageManager Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(StageManager)
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			mapDims As Vec2F, _
			lightDir As Vec3F, _
			lightMin As Double, _
			lightMax As Double, _
			audioFile As Const ZString Ptr)
			
	Declare Const Function getMapDims() ByRef As Const Vec2F
	
	Declare Sub updateDelayPosition(ByRef p As Const Vec2F)
	Declare Const Function getDelayPosition() As Vec2F
	
	Declare Sub setLightMinMax(min As Double, max As Double)

	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Vec3F lightDir_ = Any
 	As Double lightMin_ = Any
 	As Double lightMax_ = Any
 	As Vec2F mapDims_ = Any
 	As String audioFile_
	As DArray_Vec2F lastPositions_
 	As Integer positionReadIndex_ = Any
End Type

End Namespace

#EndIf