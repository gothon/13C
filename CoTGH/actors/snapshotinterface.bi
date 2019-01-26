#Ifndef ACTOR_SNAPSHOTINTERFACE_BI
#Define ACTOR_SNAPSHOTINTERFACE_BI

#Include "../actor.bi"
#Include "../image32.bi"

Namespace act
	
Type SnapshotInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(SnapshotInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, target As Const Image32 Ptr)
	
	Declare Const Function createSnapshot() As Image32 Ptr
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Const Image32 Ptr target_
End Type

End Namespace

#EndIf