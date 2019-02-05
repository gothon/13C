#Ifndef ACTOR_ISLANDZONE_BI
#Define ACTOR_ISLANDZONE_BI

#Include "../actor.bi"
#Include "../aabb.bi"

Namespace act

Type IslandZone Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(IslandZone)

	Declare Constructor(parent As ActorBankFwd Ptr, bounds As AABB)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As AABB bounds_
End Type

End Namespace

#EndIf
