#Include "portal.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"
#Include "../audiocontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(Portal, ActorTypes.PORTAL)

Const As Integer MAP_TRANSITION_COUNTDOWN = 10
	
Constructor Portal(	_
		parent As ActorBankFwd Ptr, _
		key As Const ZString Ptr, _
		region As AABB, _
		mode As PortalEnterMode, _
		toMap As Const ZString Ptr, _
		toPortal As Const ZString Ptr, _
		fadeMusic As Boolean)
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
	This.requestGoCountdown_ = -1
	This.fadeMusic_ = fadeMusic
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
	If *toPortal_ = "NONE" Then Return FALSE
	If requestGoCountdown_ = -1 Then
		Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
		If Not player_->getBounds().intersects(region_) Then 
			waitingForNoIntersect_ = FALSE
			Return FALSE
		EndIf
		If waitingForNoIntersect_ Then Return FALSE
		If (mode_ = PortalEnterMode.FROM_CENTER) _
				AndAlso ((Not player_->pressedDown()) OrElse (Not player_->isGrounded())) Then Return FALSE
		
		requestGoCountdown_ = MAP_TRANSITION_COUNTDOWN
		If fadeMusic_ Then AudioController.fadeOut()
		Dim As CameraInterface Ptr camera = @GET_GLOBAL("CAMERA INTERFACE", CameraInterface)
		camera->fadeOut()
		If mode_ = PortalEnterMode.FROM_LEFT Then
			player_->setLockState(LockState.WALK_RIGHT)
		ElseIf mode_ = PortalEnterMode.FROM_RIGHT Then
			player_->setLockState(LockState.WALK_LEFT)
		Else
			player_->setLockState(LockState.IDLE)
		EndIf
	Else
		If requestGoCountdown_ > 0 Then
			requestGoCountdown_ -= 1
		ElseIf requestGoCountdown_ = 0 Then
			Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)
			player_->disableCollision()
			player_->setDestinationPortal(*toPortal_)
			GET_GLOBAL("GRAPH INTERFACE", GraphInterface).requestGo(toMap_)
			requestGoCountdown_ = -1
		End If
	End If

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
	Return New Portal( _
			parent, This.getKey(), region_, mode_, util.cloneZString(toMap_), util.cloneZString(toPortal_), fadeMusic_)
End Function

End Namespace
