#Ifndef ACTOR_PLAYER_BI
#Define ACTOR_PLAYER_BI

#Include "../actor.bi"
#Include "../aabb.bi"
#Include "../image32.bi"

Namespace act
	
Type Player Extends DynamicCollidingModelActor
 Public:
 	ACTOR_REQUIRED_DECL(Player)
 
	Declare Constructor( _
			parent As ActorBankFwd Ptr, _
			model As QuadModelBase Ptr, _
			colliderPtr As ColliderFwd Ptr, _
			animImage As Image32 Ptr)
	Declare Virtual Destructor()
		
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Const Function getBounds() ByRef As Const AABB
 	Declare Const Function pressedDown() As Boolean
 	Declare Sub setDestinationPortal(dest As Const ZString Ptr)
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Sub updateCamera()
 	Declare Sub flipXUV()
 	
 	As Boolean lastDownPressed_ = Any
 	As Boolean downLHEdge_ = Any
 	
 	As Boolean facingRight_ = Any
 	As Image32 Ptr animImage_ = Any
 	As Image32 Ptr playerTex_ = Any
 	
 	As String destinationPortal_
End Type

End Namespace

#EndIf