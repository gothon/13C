#Ifndef ACTOR_FAKEPLAYER_BI
#Define ACTOR_FAKEPLAYER_BI

#Include "../actor.bi"
#Include "../image32.bi"

Namespace act
	
Type FakePlayer Extends DynamicModelActor
 Public:
 	ACTOR_REQUIRED_DECL(FakePlayer)
 
	Declare Constructor(parent As ActorBankFwd Ptr, p As Vec3F, isMatt As Boolean, faceRight As Boolean)
	Declare Destructor()
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Static Function createModel(animImage As Image32 Ptr) As QuadModelBase Ptr
 
 	As Image32 Ptr animImage_ = NULL
 	As Integer idleFrame_ = Any 
 	As Integer idleEndFrame_ = Any
 	As Integer idleFrameSpeed_ = Any
 	As Integer idleFrameDelay_ = Any
 	As Boolean isMatt_ = Any
End Type

End Namespace

#EndIf
