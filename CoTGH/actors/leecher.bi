#Ifndef ACTOR_LEECHER_BI
#Define ACTOR_LEECHER_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../image32.bi"

Namespace act

Type Leecher Extends DynamicModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Leecher)

	Declare Constructor(parent As ActorBankFwd Ptr, bounds As AABB, startFrameOffset As Integer, z As Single)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As AABB bounds_ = Any
 	As Single z_ = Any
 	As Integer startFrameOffset_ = Any
 	As Image32 Ptr animImage_ = Any
 	As Integer frame_ = Any
 	As Integer delay_ = Any
End Type

End Namespace

#EndIf
