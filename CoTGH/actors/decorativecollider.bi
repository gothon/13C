#Ifndef ACTORS_DECORATIVECOLLIDER_BI
#Define ACTORS_DECORATIVECOLLIDER_BI

#Include "../actor.bi"
#Include "../quadmodel.bi"
#Include "../physics.bi"

Namespace act

Type DecorativeCollider Extends CollidingModelActor
 Public:
 	ACTOR_REQUIRED_DECL(DecorativeCollider)
 	
  'Takes ownership of model and collider
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As Collider Ptr)
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 	
End Type

End Namespace

#EndIf
