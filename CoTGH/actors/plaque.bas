#Include "plauqe.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../audiocontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(Plaque, ActorTypes.PLAQUE)
	
Constructor Plaque( _
			parent As ActorBankFwd Ptr, _
			ByRef bounds As Const AABB, _
			title As String, _
			dates As String, _
			body As String)
	Base.Constructor(parent)
	setType()
		
	This.bounds_ = bounds
	This.title_ = title
	This.dates_ = dates
	This.body_ = body
	This.triggered_ = FALSE
End Constructor
	
Function Plaque.update(dt As Double) As Boolean

	Return FALSE
End Function

Sub Plaque.notify()
	''
End Sub
	
Function Plaque.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
