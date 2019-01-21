#Include "decorativemodel.bi"

#Include "../actortypes.bi"

Namespace act
ACTOR_REQUIRED_DEF(DecorativeModel, ActorTypes.DECORATIVE_MODEL)
	
Constructor DecorativeModel(parent As ActorBankFwd Ptr, model As QuadModelBase Ptr)
	Base.Constructor(parent, model)
	setType()
End Constructor
	
Function DecorativeModel.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As QuadModelBase Ptr newModel = Any
	If *model_ Is QuadModel Then
		newModel = New QuadModel(*CPtr(QuadModel Ptr, model_))		
	Else
		newModel = New QuadSprite(*CPtr(QuadSprite Ptr, model_))
	EndIf
	Return New DecorativeModel(parent, newModel)
End Function

End Namespace