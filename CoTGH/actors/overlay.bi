#Ifndef ACTOR_OVERLAY_BI
#Define ACTOR_OVERLAY_BI

#Include "../actor.bi"
#Include "../image32.bi"

Namespace act

Type Overlay Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(Overlay)

	Declare Constructor(parent As ActorBankFwd Ptr, target As Image32 Ptr)
	
 	Declare Sub draw()
 	Declare Sub setPhoto(photo As Image32 Ptr)
 	Declare Sub setHasCamera(hasCamera As Boolean)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Image32 Ptr target_ = Any
 	As Image32 Ptr photo_ = Any
 	As Boolean hasCamera_ = Any
End Type

End Namespace

#EndIf
