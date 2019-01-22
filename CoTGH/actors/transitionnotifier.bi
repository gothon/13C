#Ifndef ACTOR_TRANSITIONNOTIFIER_BI
#Define ACTOR_TRANSITIONNOTIFIER_BI

#Include "../actor.bi"

Namespace act
	
Type TransitionNotifier Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(TransitionNotifier)
 
	Declare Constructor(parent As ActorBankFwd Ptr, transitionFlag As Boolean Ptr)
	
	Declare Const Function happened() As Boolean
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Boolean Ptr transitionFlag_
End Type

End Namespace

#EndIf