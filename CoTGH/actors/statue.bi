#Ifndef ACTOR_STATUE_BI
#Define ACTOR_STATUE_BI

#Include "../actor.bi"

Namespace act
	
Type Statue Extends DynamicCollidingModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Statue)
 
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, colliderPtr As ColliderFwd Ptr)

	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
End Type

End Namespace

#EndIf