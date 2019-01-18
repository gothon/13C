#Include "decorativecollider.bi"

Namespace act
	
Constructor DecorativeCollider(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr, collider As Collider Ptr)
	CollidingModelActor.Constructor(parent, model, collider)
End Constructor

Constructor DecorativeCollider(ByRef other As Const DecorativeCollider)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator DecorativeCollider.Let(ByRef other As Const DecorativeCollider)
	DEBUG_ASSERT(FALSE)	
End Operator
	
Function DecorativeCollider.clone() As Actor Ptr Override
	Dim As QuadModelBase Ptr newModel = Any
	If *model_ Is QuadModel Then
		newModel = New QuadModel(*CPtr(QuadModel Ptr, model_))		
	Else
		newModel = New QuadSprite(*CPtr(QuadSprite Ptr, model_))
	EndIf
	
	Dim As Collider Ptr newCollider = Any
	If *model_ Is BlockGrid Then
		newCollider = New BlockGrid(*CPtr(BlockGrid Ptr, collider_))		
	Else
		newCollider = New DynamicAABB(*CPtr(DynamicAABB Ptr, collider_))
	EndIf
	
	Return New DecorativeCollider(parent_, newModel, newCollider)
End Function

End Namespace