#Include "decorativelight.bi"

Namespace act
	
Constructor DecorativeLight(parent As ActorBankFwd Ptr, light As Light Ptr)
	LightActor.Constructor(parent, light)
End Constructor

Constructor DecorativeLight(ByRef other As Const DecorativeLight)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator DecorativeLight.Let(ByRef other As Const DecorativeLight)
	DEBUG_ASSERT(FALSE)	
End Operator
	
Sub DecorativeLight.update(dt As Double) Override
	light_.update(dt)
End Sub

Sub DecorativeLight.notify() Override
	''
End Sub
 	
Function DecorativeLight.clone() As Actor Ptr Override
	Dim As Light Ptr newLight = New Light(*light_)
	Return New DecorativeLight(parent_, newLight)
End Function

End Namespace
