#Include "decorativecollider.bi"

#Include "../actortypes.bi"

Namespace act
ACTOR_REQUIRED_DEF(DecorativeCollider, ActorTypes.DECORATIVE_COLLIDER)
		
Constructor DecorativeCollider(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As Collider Ptr)
	Base.Constructor(parent, model, collider)
	setType()
End Constructor

Function DecorativeCollider.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As QuadModelBase Ptr newModel = Any
	If *model_ Is QuadModel Then
		newModel = New QuadModel(*CPtr(QuadModel Ptr, model_))		
	Else
		newModel = New QuadSprite(*CPtr(QuadSprite Ptr, model_))
	EndIf
	
	Dim As Collider Ptr newCollider = Any
	If *CPtr(Collider Ptr, collider_) Is BlockGrid Then
		newCollider = New BlockGrid(*CPtr(BlockGrid Ptr, collider_))		
	Else
		newCollider = New DynamicAABB(*CPtr(DynamicAABB Ptr, collider_))
	EndIf
	
	Return New DecorativeCollider(parent, newModel, newCollider)
End Function

End Namespace