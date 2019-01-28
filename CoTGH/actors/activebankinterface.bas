#Include "activebankinterface.bi"

#Include "../debuglog.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"

Namespace act
ACTOR_REQUIRED_DEF(ActiveBankInterface, ActorTypes.ACTIVEBANKINTERFACE)
	
Constructor ActiveBankInterface(parent As ActorBankFwd Ptr, activeBank As ActorBank Ptr Ptr)
	Base.Constructor(parent)
	setType()

	setKey("ACTIVEBANK INTERFACE")
	
	This.activeBank_ = activeBank	
End Constructor

Sub ActiveBankInterface.add(act As Actor Ptr)
	(*activeBank_)->add(act)
End Sub
  
Function ActiveBankInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
