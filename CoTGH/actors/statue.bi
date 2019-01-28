#Ifndef ACTOR_STATUE_BI
#Define ACTOR_STATUE_BI

#Include "../actor.bi"
#Include "../image32.bi"

Namespace act
	
Type Statue Extends DynamicCollidingModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Statue)
 
	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec3F)			
	Declare Destructor()

	Declare Sub collect()

	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Static Function createModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
 	Declare Sub processCarryable()
 
 	As Double z_ = Any
 	As Integer currentFrame_ = Any
 	As Image32 Ptr animImage_ = Any
 	As Boolean solid_ = Any
 	As Boolean lastStoodOn_ = Any
 	As UInteger frameCounter_ = Any
 	As Boolean collectRequested_ = Any
 	As Boolean restedOn_ = Any
 	As UInteger playerOffCountdown_ = Any
End Type

End Namespace

#EndIf