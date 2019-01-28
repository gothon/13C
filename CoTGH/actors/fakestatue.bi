#Ifndef ACTOR_FAKESTATUE_BI
#Define ACTOR_FAKESTATUE_BI

#Include "../actor.bi"

Namespace act

Const As Integer FAKE_STATUE_WIDTH = 16
	
Type FakeStatue Extends ModelActor
 Public:
 	ACTOR_REQUIRED_DECL(FakeStatue)
 
	Declare Constructor(parent As ActorBankFwd Ptr)
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
End Type

End Namespace

#EndIf
