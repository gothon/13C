#Ifndef ACTOR_SPRONKLE_BI
#Define ACTOR_SPRONKLE_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../image32.bi"

Namespace act

Type Spronkle Extends DynamicModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Spronkle)

	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec3F, speed As Single = 0.5)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Vec3F p_
 	As Single speed_
 	As Image32 Ptr animImage_ = Any
 	As Integer frame_ = Any
 	As Integer delay_ = Any
End Type

End Namespace

#EndIf
