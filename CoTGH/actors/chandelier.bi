#Ifndef ACTOR_CHANDELIER_BI
#Define ACTOR_CHANDELIER_BI

#Include "../actor.bi"

Namespace act
	
Type Chandelier Extends DynamicCollidingModelLightActor
 Public:
 	ACTOR_REQUIRED_DECL(Chandelier)
 
	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec3F)			
	Declare Destructor()

	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Static Function createModel(srcImage As Image32 Ptr) As QuadModelBase Ptr
 
 	As Double z_ = Any
 	As Image32 Ptr animImage_ = Any
 	As Boolean solid_ = Any
 	As Boolean lastStoodOn_ = Any
	As Integer currentFrame_ = Any
 	As Boolean restedOn_ = Any
 	As Integer playerOffCountdown_ = Any
 	As Boolean breaking_ = Any
End Type

End Namespace

#EndIf