#Ifndef ACTOR_MENUCONTROLLER_BI
#Define ACTOR_MENUCONTROLLER_BI

#Include "../actor.bi"
#Include "../image32.bi"
#Include "../aabb.bi"

Namespace act
	
Type MenuController Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(MenuController)
 
	Declare Constructor(parent As ActorBankFwd Ptr, ByRef bounds As Const AABB)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As AABB bounds_ = Any
 	As LongInt introRoll_ = Any
 	As Boolean resetScreen_ = Any
 	As ModelActor Ptr titleActor_ = Any
 	As ModelActor Ptr arrowActor_ = Any
 	As ModelActor Ptr doorwayActor_ = Any
 	As Double t_ = Any
 	As Boolean isMatt_ = Any
 	As Double lightFade_ = Any
 	As Integer activatePlayerCountup_ = Any
End Type

End Namespace

#EndIf
