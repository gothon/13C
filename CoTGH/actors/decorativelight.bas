#Include "decorativelight.bi"

#Include "../actortypes.bi"

Namespace act
ACTOR_REQUIRED_DEF(DecorativeLight, ActorTypes.DECORATIVE_LIGHT)
	
Constructor DecorativeLight(parent As ActorBankFwd Ptr, light As Light Ptr)
	Base.Constructor(parent, light)
	setType()
End Constructor

Function DecorativeLight.update(dt As Double) As Boolean
	light_->update(dt)
	Return FALSE
End Function

Sub DecorativeLight.notify()
	''
End Sub
 	
Function DecorativeLight.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Dim As Light Ptr newLight = New Light(*light_)
	Return New DecorativeLight(parent, newLight)
End Function

End Namespace
