#Ifndef ACTOR_PLAQUE_BI
#Define ACTOR_PLAQUE_BI

#Include "../actor.bi"
#Include "../aabb.bi"

Namespace act

Type Plaque Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(Plaque)
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			ByRef bounds As Const AABB, _
			ByRef text As Const String)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As AABB bounds_ = Any
 	As Boolean triggered_ = Any
	As String text_
	As Boolean displaying_ = Any
End Type

End Namespace

#EndIf