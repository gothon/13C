#Include "decorativemodel.bi"

Namespace act
	
Constructor DecorativeModel(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	ModelActor.Constructor(parent, model)
End Constructor

Constructor DecorativeModel(ByRef other As Const DecorativeModel)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator DecorativeModel.Let(ByRef other As Const DecorativeModel)
	DEBUG_ASSERT(FALSE)	
End Operator
	
Function DecorativeModel.clone() As Actor Ptr Override
	Dim As QuadModelBase Ptr newModel = Any
	If *model_ Is QuadModel Then
		newModel = New QuadModel(*CPtr(QuadModel Ptr, model_))		
	Else
		newModel = New QuadSprite(*CPtr(QuadSprite Ptr, model_))
	EndIf
	Return New DecorativeModel(parent_, newModel)
End Function

End Namespace