#Ifndef ACTOR_STAGEMANAGER_BI
#Define ACTOR_STAGEMANAGER_BI

#Include "../actor.bi"
#Include "../vec3f.bi"

Namespace act
	
Type StageManager Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(StageManager)
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			mapDims As Vec2F, _
			lightDir As Vec3F, _
			lightMin As Double, _
			lightMax As Double)
			
	Declare Const Function getMapDims() ByRef As Const Vec2F
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Vec3F lightDir_ = Any
 	As Double lightMin_ = Any
 	As Double lightMax_ = Any
 	As Vec2F mapDims_ = Any
End Type

End Namespace

#EndIf