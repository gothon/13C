#Ifndef ACTOR_SPAWN_BI
#Define ACTOR_SPAWN_BI

#Include "../actor.bi"

Namespace act
	
Type Spawn Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(Spawn)
 
	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec2F)
	
	Declare Const Function getP() As Vec2F
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Vec2F p_ = Any
End Type

End Namespace

#EndIf