#Include "statue.bi"

#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../quadmodel.bi"
#Include "../physics.bi"

#Include "fbgfx.bi"

Namespace act
ACTOR_REQUIRED_DEF(Statue, ActorTypes.STATUE)
	
#Define COL_PTR CPtr(DynamicAABB Ptr, collider_)
	
Constructor Statue(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, colliderPtr As ColliderFwd Ptr)
	Base.Constructor(parent, model, colliderPtr)
	setType()
End Constructor

Function Statue.update(dt As Double) As Boolean
	model_->translate(COL_PTR->getDelta())
	Return FALSE
End Function

Sub Statue.notify()
	''
End Sub

Function Statue.clone(parent As ActorBankFwd Ptr) As Actor Ptr
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
	
	Return New Statue(parent, newModel, newCollider)
End Function

End Namespace