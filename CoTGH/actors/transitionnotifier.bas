#Include "transitionnotifier.bi"

#Include "../actorbank.bi"
#Include "../debuglog.bi"

Namespace act
ACTOR_REQUIRED_DEF(TransitionNotifier, ActorTypes.TRANSITIONNOTIFIER)
	
Constructor TransitionNotifier(parent As ActorBankFwd Ptr, transitionFlag As Boolean Ptr)
	Base.Constructor(parent)
	setType()

	setKey("TRANSITION NOTIFIER")
	
	This.transitionFlag_ = transitionFlag
End Constructor

Const Function TransitionNotifier.happened() As Boolean
	Return *transitionFlag_
End Function

Function TransitionNotifier.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
