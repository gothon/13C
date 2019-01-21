#Ifndef ACTORS_DECORATIVEMODEL_BI
#Define ACTORS_DECORATIVEMODEL_BI

#Include "../actor.bi"
#Include "../quadmodel.bi"

Namespace act
	
Type DecorativeModel Extends ModelActor
 Public:
  ACTOR_REQUIRED_DECL(DecorativeModel)
 
  'Takes ownership of model
	Declare Constructor(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)

 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
End Type
	
End Namespace

#EndIf
