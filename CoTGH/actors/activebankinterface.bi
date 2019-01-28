#Ifndef ACTOR_ACTIVEBANKINTERFACE_BI
#Define ACTOR_ACTIVEBANKINTERFACE_BI

#Include "../actor.bi"
#Include "../actorbank.bi"

Namespace act
	
Type ActiveBankInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(ActiveBankInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, activeBank As ActorBank Ptr Ptr)
	
  Declare Sub add(act As Actor Ptr)
  Declare Function getParent() As ActorBankFwd Ptr
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As ActorBank Ptr Ptr activeBank_
End Type

End Namespace

#EndIf