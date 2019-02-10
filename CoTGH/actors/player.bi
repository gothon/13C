#Ifndef ACTOR_PLAYER_BI
#Define ACTOR_PLAYER_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../image32.bi"
#Include "../indexgraph.bi"
#Include "../actordefs.bi"
#Include "../darray.bi"
#Include "../actorbank.bi"
#Include "../vec2f.bi"

DECLARE_DARRAY(ActorPtr)

Namespace act
	
Enum LockState Explicit
	NONE = 0
	IDLE = 1
	WALK_RIGHT = 2
	WALK_LEFT = 3
End Enum
	
Type Player Extends DynamicCollidingModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Player)
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			model As QuadModelBase Ptr, _
			colliderPtr As ColliderFwd Ptr, _
			animImage As Image32 Ptr)
	Declare Destructor()
		
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Const Function getBounds() ByRef As Const AABB
 	Declare Const Function pressedDown() As Boolean
 	Declare Const Function pressedActivate() As Boolean
 	
 	Declare Const Function pressedSnap() As Boolean
 	Declare Const Function pressedPlace() As Boolean
 	
 	Declare Sub setDestinationPortal(dest As Const ZString Ptr)
 	Declare Sub disableCollision()
	Declare Sub setWarp(p As Vec2F, v As Vec2F, leadingX As Double, musicPosition As LongInt, facingRight As Boolean)
	Declare Sub leech()
	Declare Sub setOnIsland()
	Declare Sub setHasCamera(hasCamera As Boolean)
	
	Declare Sub placeSnapshot(replaceId As UInteger)
	Declare Const Function readyToPlace() As Boolean
	
	Declare Sub claimCarryable(statue As Actor Ptr)
	
	Declare Sub claimSnapshot( _
			embedId As UInteger Ptr, _
			snapshot As Image32 Ptr Ptr, _
			snapshotP As Vec2F Ptr, _
			snapshotV As Vec2F Ptr, _
			snapshotLeadingX As Double Ptr, _
			snapshotMusicPosition As LongInt Ptr, _
			snapshotFacingRight As Boolean Ptr)
	Declare Const Function hasSnapshot() As Boolean
	
	Declare Sub setLockState(state As LockState)
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Sub processAnimation()
 	Declare Sub updateCamera(snapToTarget As Boolean)
 	Declare Sub flipXUV()
 	Declare Sub checkArbiters()
 	Declare Sub processInteractions()
 	Declare Sub processPlatformingControls()
 	Declare Sub processStatues()
 	Declare Sub processCarrying()
 	
 	As Integer seenPlaques_ = Any
 	As Boolean hasCamera_ = Any
 	
 	As Boolean onIsland_ = Any
 	As Integer freezeAfterDie_ = Any
 	
 	As Boolean standingOnStatic_ = Any
 	
 	As LockState lockState_ = Any
 	As Boolean warpLock_ = Any
 	As AABB intersectPortalBounds_ = Any
 	
 	As ig_Index resetIndex_ = Any
 	As Boolean waitingForResetIndex_ = Any
 	As Double resetIndexLeadingX_ = Any
 	As Boolean resetIndexFacingRight_ = Any
 	
 	As DArray_ActorPtr carryableStatues_
 	As Boolean carryingStatue_ = Any
 	As FakeStatue Ptr fakeStatuePtr_ = Any
 	As Boolean firstPickUp_ = Any
 	As Integer statuePlaceCountdown_ = Any
 	
 	As Boolean grounded_ = Any
 	As Boolean lastGrounded_ = Any
 	As Boolean bonk_ = Any
 	As Boolean lastJumpPressed_ = Any
 	As Integer jumpBoostCounter_ = Any
 	As Integer lastGroundedCountdown_ = Any
 	As Integer airbornJumpRequestCountdown_ = Any
 	As Integer warpCountdown_ = Any
 	
 	As Boolean lastDownPressed_ = Any
 	As Boolean downLHEdge_ = Any
 	
 	As Boolean lastSwapPressed_ = Any
 	
 	As Boolean lastActivatePressed_ = Any
 	As Boolean activateLHEdge_ = Any
 	
 	As Boolean lastSnapPressed_ = Any
 	As Boolean snapLHEdge_ = Any
 	
 	As Boolean lastPlacePressed_ = Any
 	As Boolean placeLHEdge_ = Any
 	
 	As Integer warpParalyzeCountdown_ = Any
 	As UInteger embedId_ = Any
 	As ig_Index clonedIndex_ = Any
 	As Image32 Ptr snapshot_ = Any
 	As Boolean cloneRequested_ = Any
 	As Vec2F snapshotP_ = Any
 	As Vec2F snapshotV_ = Any
 	As Boolean snapshotFacingRight_ = Any
 	As Double snapshotLeadingX_ = Any 
 	As LongInt snapshotMusicPosition_ = Any
 	
 	As Boolean isWarped_ = Any
 	As Vec2F warpP_ = Any
 	As Vec2F warpV_ = Any
 	As Double warpLeadingX_ = Any
 	As LongInt warpMusicPosition_ = Any
 	As Boolean warpFacingRight_ = Any
 	
 	As Boolean facingRight_ = Any
 	As Image32 Ptr animImage_ = Any
 	As Image32 Ptr playerTex_ = Any
 	
 	As Integer walkFrame_ = 0
 	As Integer walkFrameDelay_ = 0
 	As Integer walkSpeed_ = 0
 	
 	As Integer idleFrame_ = 0
 	As Integer idleFrameDelay_ = 0
 	As Integer idleEndFrame_ = 0
 	As Integer idleFrameSpeed_ = 0
 	
 	As String destinationPortal_
End Type

End Namespace

#EndIf