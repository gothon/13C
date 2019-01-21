#Include "portal.bi"

#Include "../util.bi"
#Include "../actortypes.bi"

Namespace act
ACTOR_REQUIRED_DEF(Portal, ActorTypes.PORTAL)
	
Constructor Portal(	_
		parent As ActorBankFwd Ptr, _
		key As Const ZString Ptr, _
		region As AABB, _
		mode As PortalEnterMode, _
		toMap As Const ZString Ptr, _
		toPortal As Const ZString Ptr)
	Base.Constructor(parent)
	setType()
		
	DEBUG_ASSERT(key <> NULL)
	setKey(key)
	
	This.region_ = region
	This.mode_ = mode
	DEBUG_ASSERT(toMap <> NULL)
	This.toMap_ = util.cloneZString(toMap)
	DEBUG_ASSERT(toPortal <> NULL)
	This.toPortal_ = util.cloneZString(toPortal)
End Constructor

Destructor Portal()
	DEBUG_ASSERT(toMap_ <> NULL)
	DeAllocate(toMap_)
	DEBUG_ASSERT(toPortal_ <> NULL)
	DeAllocate(toPortal_)
End Destructor
	
Function Portal.update(dt As Double) As Boolean
	Return FALSE
End Function

Sub Portal.notify()
	''
End Sub
 	
Function Portal.getMode() As PortalEnterMode
	Return mode_
End Function

Function Portal.getRegion() As AABB
	Return region_
End Function
	
Function Portal.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New Portal(parent, This.getKey(), region_, mode_, util.cloneZString(toMap_), util.cloneZString(toPortal_))
End Function

End Namespace
