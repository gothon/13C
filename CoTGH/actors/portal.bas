#Include "portal.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"

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
	This.waitingForNoIntersect_ = FALSE
End Constructor

Destructor Portal()
	DEBUG_ASSERT(toMap_ <> NULL)
	DeAllocate(toMap_)
	DEBUG_ASSERT(toPortal_ <> NULL)
	DeAllocate(toPortal_)
End Destructor
	
Sub Portal.waitForNoIntersect()
	waitingForNoIntersect_ = TRUE
End Sub
	
Function Portal.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
	If Not player_->getBounds().intersects(region_) Then 
		waitingForNoIntersect_ = FALSE
		Return FALSE
	EndIf
	If waitingForNoIntersect_ Then Return FALSE
	If (mode_ = PortalEnterMode.FROM_CENTER) AndAlso (Not player_->pressedDown()) Then Return FALSE
	
	player_->setDestinationPortal(*toPortal_)
	GET_GLOBAL("GRAPH INTERFACE", GraphInterface).requestGo(toMap_)

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
