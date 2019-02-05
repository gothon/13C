#Ifndef ACTOR_PORTAL_BI
#Define ACTOR_PORTAL_BI

#Include "../actor.bi"
#Include "../aabb.bi"

Namespace act

Enum PortalEnterMode Explicit
	NONE = 0,
	FROM_LEFT = 1,
	FROM_RIGHT = 2,
	FROM_CENTER = 3
End Enum

Type Portal Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(Portal)
 	Declare Destructor()
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			key As Const ZString Ptr, _
			region As AABB, _
			mode As PortalEnterMode, _
			toMap As Const ZString Ptr, _
			toPortal As Const ZString Ptr, _
			fadeMusic As Boolean)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
	Declare Function getMode() As PortalEnterMode
	Declare Function getRegion() As AABB
	
	Declare Sub waitForNoIntersect()
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As PortalEnterMode mode_
 	As AABB region_
 	As ZString Ptr toMap_ = NULL
 	As ZString Ptr toPortal_ = NULL
 	As Boolean waitingForNoIntersect_
 	As Integer requestGoCountdown_ = Any
 	As Boolean fadeMusic_ = Any
End Type

End Namespace

#EndIf