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
			title As String, _
			dates As String, _
			body As String)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As AABB bounds_ = Any
 	As Boolean triggered_ = Any
	As String title_
	As String dates_
	As String body_
End Type

End Namespace

#EndIf