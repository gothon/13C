#Ifndef ACTOR_PLAYER_BI
#Define ACTOR_PLAYER_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../image32.bi"
#Include "../indexgraph.bi"
#Include "../actordefs.bi"
#Include "../darray.bi"
#Include "../actorbank.bi"

DECLARE_DARRAY(ActorPtr)

Namespace act
	
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
 	
 	Declare Sub setDestinationPortal(dest As Const ZString Ptr)
 	Declare Sub disableCollision()
	Declare Sub setWarp(p As Vec2F, v As Vec2F)
	
	Declare Sub placeSnapshot(replaceId As UInteger)
	Declare Const Function readyToPlace() As Boolean
	
	Declare Sub claimCarryable(statue As Actor Ptr)
	
	Declare Sub claimSnapshot( _
			embedId As UInteger Ptr, _
			snapshot As Image32 Ptr Ptr, _
			snapshotP As Vec2F Ptr, _
			snapshotV As Vec2F Ptr)
	Declare Const Function hasSnapshot() As Boolean
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Sub processAnimation()
 	Declare Sub updateCamera()
 	Declare Sub flipXUV()
 	Declare Sub checkArbiters()
 	Declare Sub processInteractions()
 	Declare Sub processPlatformingControls()
 	Declare Sub processStatues()
 	Declare Sub processCarrying()
 	
 	As DArray_ActorPtr carryableStatues_
 	As Boolean carryingStatue_ = Any
 	As FakeStatue Ptr fakeStatuePtr_ = Any
 	
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
 	As boolean activateLHEdge_ = Any
 	
 	As UInteger embedId_ = Any
 	As ig_Index clonedIndex_ = Any
 	As Image32 Ptr snapshot_ = Any
 	As Boolean cloneRequested_ = Any
 	As Vec2F snapshotP_ = Any
 	As Vec2F snapshotV_ = Any
 	As Boolean snapshotFacingRight_ = Any
 	As Double snapshotLeadingX_ = Any 
 	
 	As Boolean isSnapshotting_ = Any
 	
 	As Boolean isWarped_ = Any
 	As Vec2F warpP_ = Any
 	As Vec2F warpV_ = Any
 	
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