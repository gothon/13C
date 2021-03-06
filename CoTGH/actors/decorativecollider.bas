#Include "decorativecollider.bi"

#Include "../actortypes.bi"
#Include "../debuglog.bi"

Namespace act
ACTOR_REQUIRED_DEF(DecorativeCollider, ActorTypes.DECORATIVE_COLLIDER)
		
Constructor DecorativeCollider(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As Collider Ptr)
	Base.Constructor(parent, model, collider)
	setType()
End Constructor

Function DecorativeCollider.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As QuadModelBase Ptr newModel = Any
	If model_->getDelegate() = QuadModelBase_Delegate.QUADMODEL Then
		newModel = New QuadModel(*CPtr(QuadModel Ptr, model_))		
	ElseIf model_->getDelegate() = QuadModelBase_Delegate.QUADSPRITE Then
		newModel = New QuadSprite(*CPtr(QuadSprite Ptr, model_))
	Else
		DEBUG_ASSERT(FALSE)
	EndIf
	
	Dim As Collider Ptr newCollider = Any
	If CPtr(Collider Ptr, collider_)->getDelegate() = Collider_Delegate.BLOCKGRID Then
		newCollider = New BlockGrid(*CPtr(BlockGrid Ptr, collider_))		
	ElseIf CPtr(Collider Ptr, collider_)->getDelegate() = Collider_Delegate.DYNAMICAABB Then
		newCollider = New DynamicAABB(*CPtr(DynamicAABB Ptr, collider_))
	Else
		DEBUG_ASSERT(FALSE)
	EndIf
	
	Return New DecorativeCollider(parent, newModel, newCollider)
End Function

End Namespace