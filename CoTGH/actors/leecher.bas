#Include "leecher.bi"

#Include "../util.bi"
#Include "../actordefs.bi"
#Include "../actortypes.bi"
#Include "../actorbank.bi"

Namespace act
ACTOR_REQUIRED_DEF(Leecher, ActorTypes.LEECHER)
	
Constructor Leecher(parent As ActorBankFwd Ptr, bounds As AABB)
	Base.Constructor(parent)
	setType()
	
	This.bounds_ = bounds
End Constructor

Function Leecher.update(dt As Double) As Boolean
	Dim As Player Ptr player_ = @GET_GLOBAL("PLAYER", Player)	
	If player_->getBounds().intersects(bounds_) Then player_->leech()
	
	Return FALSE
End Function

Sub Leecher.notify()
	''
End Sub

Function Leecher.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	Return New Leecher(parent, bounds_)
End Function

End Namespace
