#Include "actor.bi"

#Include "debuglog.bi"

DEFINE_PRIMITIVE_PTR(Actor)
 	 	
Virtual Destructor Actor()
	DEBUG_ASSERT(refs_ = 0)
End Destructor
 	 	
Constructor Actor(ByRef rhs As Const Actor)
	DEBUG_ASSERT(FALSE)
End Constructor

Operator Actor.Let(ByRef rhs As Const Actor)
	DEBUG_ASSERT(FALSE)
End Operator
 	
Virtual Function Actor.update(t As Single) As Boolean
	''
	Return FALSE
End Function
 	
Sub Actor.ref()
	refs_ += 1
End Sub
 	
Sub Actor.unref()
	DEBUG_ASSERT(refs_ > 0)
	refs_ -= 1
End Sub
