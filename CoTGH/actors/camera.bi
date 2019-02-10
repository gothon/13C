#Ifndef ACTOR_CAMERA_BI
#Define ACTOR_CAMERA_BI

#Include "../actor.bi"
#Include "../aabb.bi"

Namespace act
	
Type Camera Extends DynamicModelLightActor
 Public:
 	ACTOR_REQUIRED_DECL(Camera)
 
	Declare Constructor(parent As ActorBankFwd Ptr, ByRef box As Const AABB)			

	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Static Function createModel() As QuadModelBase Ptr
 
 	Dim As Double t_
 	Dim As AABB bounds_
End Type

End Namespace

#EndIf