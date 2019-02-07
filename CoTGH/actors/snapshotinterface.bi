#Ifndef ACTOR_SNAPSHOTINTERFACE_BI
#Define ACTOR_SNAPSHOTINTERFACE_BI

#Include "../actor.bi"
#Include "../image32.bi"

Namespace act
	
Type SnapshotInterface Extends Actor
 Public:
 	ACTOR_REQUIRED_DECL(SnapshotInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, target As Const Image32 Ptr)
	Declare Destructor()
	
	Declare Function getSnapshot() As Image32 Ptr
	Declare Sub capture()
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Const Image32 Ptr target_
 	As Image32 Ptr captured_
End Type

End Namespace

#EndIf